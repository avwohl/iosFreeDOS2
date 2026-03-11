/*
 * DOSEmulator.mm - Objective-C++ bridge for DOSBox emulator
 *
 * Wraps the C dosbox_bridge API in an Objective-C class that the
 * SwiftUI layer can use.  Manages disk image storage, config generation,
 * and frame delivery to the delegate.
 */

#import "DOSEmulator.h"
#include "dosbox_bridge.h"
#include <atomic>
#include <mutex>
#include <string>
#include <mach/mach_time.h>

//=============================================================================
// Disk storage
//=============================================================================

static constexpr int MAX_DRIVES = 5;

/// Map drive numbers to slot indices.
///  0=A, 1=B, 0x80=C, 0x81=D, 0xE0=CD-ROM
static int drive_index(int drive) {
    if (drive >= 0 && drive < 2) return drive;
    if (drive >= 0x80 && drive < 0x82) return drive - 0x80 + 2;
    if (drive == 0xE0) return 4;
    return -1;
}

//=============================================================================
// Frame callback (C trampoline → Objective-C delegate)
//=============================================================================

static void frame_callback(const uint8_t *pixels, int width, int height, void *ctx)
{
    DOSEmulator *emu = (__bridge DOSEmulator *)ctx;
    id<DOSEmulatorDelegate> d = emu.delegate;
    if (d && [d respondsToSelector:@selector(emulatorFrameReady:width:height:)]) {
        NSData *data = [NSData dataWithBytes:pixels length:width * height * 4];
        int w = width, h = height;
        dispatch_async(dispatch_get_main_queue(), ^{
            [d emulatorFrameReady:data width:w height:h];
        });
    }
}

//=============================================================================
// DOSEmulator Implementation
//=============================================================================

@implementation DOSEmulator {
    // Disk images held in memory (for catalog disks loaded from NSData)
    uint8_t *_diskData[MAX_DRIVES];
    uint64_t _diskSize[MAX_DRIVES];
    bool     _diskIsManifest[MAX_DRIVES];
    std::atomic<bool> _manifestWriteFired;

    // Disk image paths on disk (for file-backed disks)
    NSString *_diskPath[MAX_DRIVES];

    // Temp directory for writing memory-backed disks to files
    NSString *_tmpDir;

    // Configuration
    DOSMachineType _machineType;
    int _memoryMB;
    BOOL _mouseEnabled;
    BOOL _speakerEnabled;
    BOOL _sbEnabled;
    DOSSpeedMode _speedMode;
    int _customCycles;

    dispatch_queue_t _emulatorQueue;
    BOOL _shouldRun;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        for (int i = 0; i < MAX_DRIVES; i++) {
            _diskData[i] = nullptr;
            _diskSize[i] = 0;
            _diskIsManifest[i] = false;
            _diskPath[i] = nil;
        }
        _manifestWriteFired.store(false);
        _machineType = DOSMachineSVGA;
        _memoryMB = 16;
        _mouseEnabled = YES;
        _speakerEnabled = YES;
        _sbEnabled = YES;
        _speedMode = DOSSpeedMax;
        _customCycles = 0;
        _emulatorQueue = dispatch_queue_create("com.iosFreeDOS.dosbox", DISPATCH_QUEUE_SERIAL);
        _shouldRun = NO;

        // Create temp directory for disk image files
        _tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dosbox-disks"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_tmpDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return self;
}

- (void)dealloc {
    [self stop];
    for (int i = 0; i < MAX_DRIVES; i++)
        delete[] _diskData[i];
}

#pragma mark - Configuration

- (void)setMachineType:(DOSMachineType)type { _machineType = type; }
- (void)setMemoryMB:(int)mb { _memoryMB = mb; }
- (void)setMouseEnabled:(BOOL)enabled { _mouseEnabled = enabled; }
- (void)setSpeakerEnabled:(BOOL)enabled { _speakerEnabled = enabled; }
- (void)setSoundBlasterEnabled:(BOOL)enabled { _sbEnabled = enabled; }

#pragma mark - Disk Management

- (BOOL)loadDisk:(int)drive fromPath:(NSString*)path {
    int idx = drive_index(drive);
    if (idx < 0) return NO;

    // Store the path — DOSBox will mount directly from the file
    _diskPath[idx] = [path copy];

    // Also read into memory for getDiskData / saveDisk
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return NO;

    delete[] _diskData[idx];
    _diskData[idx] = new uint8_t[data.length];
    memcpy(_diskData[idx], data.bytes, data.length);
    _diskSize[idx] = data.length;
    return YES;
}

- (BOOL)loadDisk:(int)drive fromData:(NSData*)data {
    int idx = drive_index(drive);
    if (idx < 0) return NO;

    delete[] _diskData[idx];
    _diskData[idx] = new uint8_t[data.length];
    memcpy(_diskData[idx], data.bytes, data.length);
    _diskSize[idx] = data.length;

    // Write to a temp file so DOSBox can mount it
    NSString *filename = [NSString stringWithFormat:@"drive_%d.img", drive];
    NSString *tmpPath = [_tmpDir stringByAppendingPathComponent:filename];
    [data writeToFile:tmpPath atomically:YES];
    _diskPath[idx] = tmpPath;

    return YES;
}

- (BOOL)isDiskLoaded:(int)drive {
    int idx = drive_index(drive);
    return idx >= 0 && _diskData[idx] != nullptr;
}

- (nullable NSData*)getDiskData:(int)drive {
    int idx = drive_index(drive);
    if (idx < 0 || !_diskData[idx]) return nil;

    // If disk is file-backed and DOSBox may have written to it, re-read
    if (_diskPath[idx] && _shouldRun) {
        NSData *fresh = [NSData dataWithContentsOfFile:_diskPath[idx]];
        if (fresh) return fresh;
    }

    return [NSData dataWithBytes:_diskData[idx] length:(NSUInteger)_diskSize[idx]];
}

- (BOOL)saveDisk:(int)drive toPath:(NSString*)path {
    NSData *data = [self getDiskData:drive];
    if (!data) return NO;
    return [data writeToFile:path atomically:YES];
}

- (uint64_t)diskSize:(int)drive {
    int idx = drive_index(drive);
    return (idx >= 0) ? _diskSize[idx] : 0;
}

- (int)loadISO:(NSString*)path {
    int idx = drive_index(0xE0);
    if (idx < 0) return -1;
    _diskPath[idx] = [path copy];

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return -1;

    delete[] _diskData[idx];
    _diskData[idx] = new uint8_t[data.length];
    memcpy(_diskData[idx], data.bytes, data.length);
    _diskSize[idx] = data.length;
    return 0xE0;
}

#pragma mark - Execution

- (BOOL)isRunning { return _shouldRun; }

- (void)startWithBootDrive:(int)drive {
    if (_shouldRun) return;
    _shouldRun = YES;

    // Build DOSBox config
    dosbox_config_t cfg = {};

    // Machine type
    switch (_machineType) {
        case DOSMachineVGA:      cfg.machine = "vgaonly"; break;
        case DOSMachineEGA:      cfg.machine = "ega"; break;
        case DOSMachineCGA:      cfg.machine = "cga"; break;
        case DOSMachineTandy:    cfg.machine = "tandy"; break;
        case DOSMachineHercules: cfg.machine = "hercules"; break;
        case DOSMachineSVGA:     cfg.machine = "svga_s3"; break;
    }

    cfg.memsize = _memoryMB;
    cfg.sb_enabled = _sbEnabled ? 1 : 0;
    cfg.speaker_enabled = _speakerEnabled ? 1 : 0;
    cfg.mouse_enabled = _mouseEnabled ? 1 : 0;

    // Cycles
    switch (_speedMode) {
        case DOSSpeedMax:   cfg.cycles = 0; break;
        case DOSSpeed3000:  cfg.cycles = 3000; break;
        case DOSSpeed8000:  cfg.cycles = 8000; break;
        case DOSSpeed20000: cfg.cycles = 20000; break;
        case DOSSpeed50000: cfg.cycles = 50000; break;
        case DOSSpeedFixed: cfg.cycles = _customCycles; break;
    }

    // Disk paths
    if (_diskPath[0]) cfg.floppy_a_path = [_diskPath[0] UTF8String];
    if (_diskPath[1]) cfg.floppy_b_path = [_diskPath[1] UTF8String];
    if (_diskPath[2]) cfg.hdd_c_path    = [_diskPath[2] UTF8String];
    if (_diskPath[3]) cfg.hdd_d_path    = [_diskPath[3] UTF8String];
    if (_diskPath[4]) cfg.iso_path      = [_diskPath[4] UTF8String];

    cfg.working_dir = [_tmpDir UTF8String];

    dispatch_async(_emulatorQueue, ^{
        dosbox_start(&cfg, frame_callback, (__bridge void *)self);
        self->_shouldRun = NO;
    });
}

- (void)stop {
    if (!_shouldRun) return;
    dosbox_request_shutdown();
    _shouldRun = NO;
    dispatch_sync(_emulatorQueue, ^{});
}

- (void)reset {
    [self stop];
}

#pragma mark - Input

- (void)sendCharacter:(unichar)ch {
    dosbox_inject_char(ch);
}

- (void)sendScancode:(uint8_t)ascii scancode:(uint8_t)scancode {
    // DOSBox uses SDL scancodes; we'll need a mapping from PC scancodes
    // to SDL scancodes.  For now, inject the PC scancode directly
    // (the bridge will translate).
    dosbox_inject_key(scancode, 1);  // press
    dosbox_inject_key(scancode, 0);  // release
    (void)ascii;
}

- (void)updateMouseX:(int)x y:(int)y buttons:(int)buttons {
    dosbox_inject_mouse_abs(x, y, buttons);
}

#pragma mark - Speed

- (void)setSpeed:(DOSSpeedMode)mode {
    _speedMode = mode;
    // TODO: if running, dynamically change DOSBox cycles
}

- (void)setCustomCycles:(int)cycles {
    _customCycles = cycles;
}

- (DOSSpeedMode)getSpeed {
    return _speedMode;
}

#pragma mark - Manifest tracking

- (void)setDiskIsManifest:(int)drive isManifest:(BOOL)manifest {
    int idx = drive_index(drive);
    if (idx >= 0) _diskIsManifest[idx] = manifest;
}

- (BOOL)pollManifestWriteWarning {
    return _manifestWriteFired.exchange(false);
}

@end
