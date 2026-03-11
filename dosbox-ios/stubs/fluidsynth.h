/* Stub fluidsynth.h — FluidSynth is not available on iOS build.
 * Provides type declarations so midi code compiles without the library.
 * The actual FluidSynth code paths will fail at runtime (constructor throws).
 */
#ifndef FLUIDSYNTH_H
#define FLUIDSYNTH_H

#include <cstddef>

typedef struct _fluid_settings_t fluid_settings_t;
typedef struct _fluid_synth_t fluid_synth_t;

/* FluidSynth API stubs */
static inline fluid_settings_t* new_fluid_settings(void) { return nullptr; }
static inline void delete_fluid_settings(fluid_settings_t*) {}
static inline fluid_synth_t* new_fluid_synth(fluid_settings_t*) { return nullptr; }
static inline void delete_fluid_synth(fluid_synth_t*) {}

static inline int fluid_settings_setstr(fluid_settings_t*, const char*, const char*) { return 0; }
static inline int fluid_settings_setnum(fluid_settings_t*, const char*, double) { return 0; }
static inline int fluid_settings_setint(fluid_settings_t*, const char*, int) { return 0; }
static inline int fluid_settings_getnum(fluid_settings_t*, const char*, double*) { return 0; }

static inline int fluid_synth_sfload(fluid_synth_t*, const char*, int) { return -1; }
static inline int fluid_synth_write_float(fluid_synth_t*, int, void*, int, int, void*, int, int) { return -1; }
static inline int fluid_synth_write_s16(fluid_synth_t*, int, void*, int, int, void*, int, int) { return -1; }
static inline int fluid_synth_noteoff(fluid_synth_t*, int, int) { return 0; }
static inline int fluid_synth_noteon(fluid_synth_t*, int, int, int) { return 0; }
static inline int fluid_synth_cc(fluid_synth_t*, int, int, int) { return 0; }
static inline int fluid_synth_pitch_bend(fluid_synth_t*, int, int) { return 0; }
static inline int fluid_synth_program_change(fluid_synth_t*, int, int) { return 0; }
static inline int fluid_synth_channel_pressure(fluid_synth_t*, int, int) { return 0; }
static inline int fluid_synth_key_pressure(fluid_synth_t*, int, int, int) { return 0; }
static inline int fluid_synth_sysex(fluid_synth_t*, const char*, int, char*, int*, int*, int) { return 0; }
static inline int fluid_synth_system_reset(fluid_synth_t*) { return 0; }
static inline int fluid_synth_all_notes_off(fluid_synth_t*, int) { return 0; }
static inline int fluid_synth_all_sounds_off(fluid_synth_t*, int) { return 0; }
static inline int fluid_synth_set_gain(fluid_synth_t*, float) { return 0; }
static inline float fluid_synth_get_gain(fluid_synth_t*) { return 0; }
static inline int fluid_synth_set_chorus_on(fluid_synth_t*, int) { return 0; }
static inline int fluid_synth_set_chorus(fluid_synth_t*, int, double, double, double, int) { return 0; }
static inline int fluid_synth_set_reverb_on(fluid_synth_t*, int) { return 0; }
static inline int fluid_synth_set_reverb(fluid_synth_t*, double, double, double, double) { return 0; }
static inline int fluid_synth_set_polyphony(fluid_synth_t*, int) { return 0; }
static inline int fluid_synth_set_sample_rate(fluid_synth_t*, float) { return 0; }
static inline int fluid_synth_set_interp_method(fluid_synth_t*, int, int) { return 0; }

#define FLUID_CHORUS_MOD_SINE 0
#define FLUID_CHORUS_MOD_TRIANGLE 1
#define FLUID_INTERP_NONE 0
#define FLUID_INTERP_LINEAR 1
#define FLUID_INTERP_4THORDER 4
#define FLUID_INTERP_7THORDER 7

#endif /* FLUIDSYNTH_H */
