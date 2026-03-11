/*
 * dosbox_bridge.cpp - C bridge for launching DOSBox from iOS
 *
 * Implements the bridge functions by calling into DOSBox's initialization
 * and execution APIs.  This replaces DOSBox's main.cpp entry point.
 */

#include "dosbox_bridge.h"

#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

// DOSBox headers
#include "dosbox.h"
#include "config/config.h"
#include "config/setup.h"
#include "gui/common.h"
#include "gui/mapper.h"
#include "gui/render/render.h"
#include "shell/shell.h"
#include "shell/command_line.h"
#include "dos/dos_locale.h"
#include "misc/cross.h"
#include "utils/checks.h"

CHECK_NARROWING();

// Global config pointer (declared extern in DOSBox)
extern std::unique_ptr<Config> control;

static std::atomic<bool> s_running{false};
static dosbox_frame_callback_t s_frame_cb = nullptr;
static void *s_frame_ctx = nullptr;

// GFX_ShowMsg is referenced by DOSBox but defined in main.cpp which we don't include
void GFX_ShowMsg(const char* format, ...)
{
    char buf[512];
    va_list msg;
    va_start(msg, format);
    vsnprintf(buf, sizeof(buf), format, msg);
    va_end(msg);
    fprintf(stderr, "[DOSBox] %s\n", buf);
}

/* ---------- config file generation ---------- */

char *dosbox_write_config(const dosbox_config_t *cfg)
{
    if (!cfg || !cfg->working_dir) return nullptr;

    std::string path = std::string(cfg->working_dir) + "/dosbox-ios.conf";
    FILE *f = fopen(path.c_str(), "w");
    if (!f) return nullptr;

    // [dosbox]
    fprintf(f, "[dosbox]\n");
    fprintf(f, "machine=%s\n", cfg->machine ? cfg->machine : "svga_s3");
    fprintf(f, "memsize=%d\n", cfg->memsize > 0 ? cfg->memsize : 16);
    fprintf(f, "\n");

    // [cpu]
    fprintf(f, "[cpu]\n");
    if (cfg->cycles > 0)
        fprintf(f, "cycles=fixed %d\n", cfg->cycles);
    else
        fprintf(f, "cycles=max\n");
    fprintf(f, "\n");

    // [render]
    fprintf(f, "[render]\n");
    fprintf(f, "frameskip=%d\n", cfg->frameskip);
    fprintf(f, "\n");

    // [sblaster]
    fprintf(f, "[sblaster]\n");
    if (cfg->sb_enabled)
        fprintf(f, "sbtype=sb16\n");
    else
        fprintf(f, "sbtype=none\n");
    fprintf(f, "\n");

    // [gus]
    fprintf(f, "[gus]\n");
    fprintf(f, "gus=%s\n", cfg->gus_enabled ? "true" : "false");
    fprintf(f, "\n");

    // [speaker]
    fprintf(f, "[speaker]\n");
    fprintf(f, "pcspeaker=%s\n", cfg->speaker_enabled ? "true" : "false");
    fprintf(f, "\n");

    // [autoexec] — mount disks and set up boot
    fprintf(f, "[autoexec]\n");

    if (cfg->floppy_a_path)
        fprintf(f, "imgmount a \"%s\" -t floppy\n", cfg->floppy_a_path);
    if (cfg->floppy_b_path)
        fprintf(f, "imgmount b \"%s\" -t floppy\n", cfg->floppy_b_path);
    if (cfg->hdd_c_path)
        fprintf(f, "imgmount c \"%s\" -t hdd -fs fat\n", cfg->hdd_c_path);
    if (cfg->hdd_d_path)
        fprintf(f, "imgmount d \"%s\" -t hdd -fs fat\n", cfg->hdd_d_path);
    if (cfg->iso_path)
        fprintf(f, "imgmount e \"%s\" -t iso\n", cfg->iso_path);

    // Boot from floppy if present, otherwise enter shell on C:
    if (cfg->floppy_a_path)
        fprintf(f, "boot a:\n");
    else if (cfg->hdd_c_path)
        fprintf(f, "c:\n");

    // Additional autoexec commands
    if (cfg->autoexec) {
        for (int i = 0; cfg->autoexec[i]; i++)
            fprintf(f, "%s\n", cfg->autoexec[i]);
    }

    fclose(f);
    return strdup(path.c_str());
}

/* ---------- lifecycle ---------- */

int dosbox_start(const dosbox_config_t *cfg,
                 dosbox_frame_callback_t frame_cb,
                 void *context)
{
    if (s_running.load()) return -1;

    s_frame_cb = frame_cb;
    s_frame_ctx = context;

    // Write config file
    char *conf_path = dosbox_write_config(cfg);
    if (!conf_path) return -1;

    s_running.store(true);
    int return_code = 0;

    try {
        // Build command line: dosbox --conf <path> --noprimaryconf --nolocalconf
        std::vector<std::string> args = {
            "dosbox",
            "--conf", conf_path,
            "--noprimaryconf",
            "--nolocalconf"
        };

        // Convert to argc/argv for CommandLine
        int argc = static_cast<int>(args.size());
        std::vector<char*> argv;
        for (auto& a : args) argv.push_back(a.data());
        argv.push_back(nullptr);

        CommandLine command_line(argc, argv.data());
        control = std::make_unique<Config>(&command_line);

        init_config_dir();

        // Register config sections and messages
        DOS_Locale_AddMessages();
        RENDER_AddMessages();
        GFX_AddConfigSection();
        DOSBOX_InitModuleConfigsAndMessages();

        // Parse our config file
        control->ParseConfigFiles(get_config_dir());

        // Initialize SDL and DOSBox modules
        GFX_InitSdl();
        DOSBOX_InitModules();
        GFX_InitAndStartGui();

        MAPPER_BindKeys(get_sdl_section());

        // Start the DOS shell — this blocks until exit
        SHELL_InitAndRun();

        // Cleanup
        DOSBOX_DestroyModules();
        GFX_Destroy();

    } catch (const std::exception& e) {
        fprintf(stderr, "[DOSBox Bridge] Error: %s\n", e.what());
        return_code = 1;
    } catch (...) {
        fprintf(stderr, "[DOSBox Bridge] Unknown error\n");
        return_code = 1;
    }

    free(conf_path);
    s_running.store(false);
    return return_code;
}

void dosbox_request_shutdown(void)
{
    if (s_running.load()) {
        DOSBOX_RequestShutdown();
    }
    s_running.store(false);
}

int dosbox_is_running(void)
{
    return s_running.load() ? 1 : 0;
}

/* ---------- input injection ---------- */

void dosbox_inject_key(int sdl_scancode, int pressed)
{
    // Push SDL keyboard event into SDL's event queue
    // DOSBox polls SDL events in its main loop
    SDL_Event event = {};
    event.type = pressed ? SDL_KEYDOWN : SDL_KEYUP;
    event.key.keysym.scancode = static_cast<SDL_Scancode>(sdl_scancode);
    event.key.keysym.sym = SDL_GetKeyFromScancode(event.key.keysym.scancode);
    event.key.state = pressed ? SDL_PRESSED : SDL_RELEASED;
    SDL_PushEvent(&event);
}

void dosbox_inject_char(uint16_t unicode_char)
{
    // Push SDL text input event
    SDL_Event event = {};
    event.type = SDL_TEXTINPUT;
    // UTF-8 encode the character
    if (unicode_char < 0x80) {
        event.text.text[0] = static_cast<char>(unicode_char);
        event.text.text[1] = '\0';
    } else if (unicode_char < 0x800) {
        event.text.text[0] = static_cast<char>(0xC0 | (unicode_char >> 6));
        event.text.text[1] = static_cast<char>(0x80 | (unicode_char & 0x3F));
        event.text.text[2] = '\0';
    }
    SDL_PushEvent(&event);
}

void dosbox_inject_mouse(int dx, int dy, int buttons)
{
    SDL_Event event = {};
    event.type = SDL_MOUSEMOTION;
    event.motion.xrel = dx;
    event.motion.yrel = dy;
    event.motion.state = static_cast<uint32_t>(buttons);
    SDL_PushEvent(&event);
}

void dosbox_inject_mouse_abs(int x, int y, int buttons)
{
    SDL_Event event = {};
    event.type = SDL_MOUSEMOTION;
    event.motion.x = x;
    event.motion.y = y;
    event.motion.state = static_cast<uint32_t>(buttons);
    SDL_PushEvent(&event);
}
