/* Stub opus decoder for builds without libopusfile */
#define __SDL_SOUND_INTERNAL__
#include "SDL_sound.h"
#include "SDL_sound_internal.h"

static int opus_init(void) { return 1; }
static void opus_quit(void) {}
static int opus_open(Sound_Sample *sample, const char *ext) {
    (void)sample; (void)ext; return 0;
}
static void opus_close(Sound_Sample *sample) { (void)sample; }
static Uint32 opus_read(Sound_Sample *sample, void *buffer, Uint32 desired_frames) {
    (void)sample; (void)buffer; (void)desired_frames; return 0;
}
static int opus_rewind(Sound_Sample *sample) { (void)sample; return 0; }
static int opus_seek(Sound_Sample *sample, Uint32 ms) {
    (void)sample; (void)ms; return 0;
}

static const char *extensions_opus[] = { "OPUS", "OGG", NULL };

const Sound_DecoderFunctions __Sound_DecoderFunctions_OPUS = {
    {
        extensions_opus,
        "Opus audio (stub)",
        "stub"
    },
    opus_init,
    opus_quit,
    opus_open,
    opus_close,
    opus_read,
    opus_rewind,
    opus_seek
};
