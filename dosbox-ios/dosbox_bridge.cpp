/*
 * dosbox_bridge.cpp - C bridge implementation for launching DOSBox from iOS
 *
 * This file provides the implementation of the C bridge functions.
 * It includes DOSBox headers and calls into DOSBox's initialization
 * and execution APIs.
 *
 * TODO: This is a skeleton.  The actual DOSBox integration will be
 * filled in once DOSBox-staging compiles as a static library for iOS.
 */

#include "dosbox_bridge.h"

#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

// TODO: Uncomment when DOSBox headers are available in the build
// #include "dosbox.h"
// #include "config/config.h"
// #include "gui/common.h"
// #include "shell/shell.h"

static std::atomic<bool> s_running{false};
static dosbox_frame_callback_t s_frame_cb = nullptr;
static void *s_frame_ctx = nullptr;

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

    // [autoexec] - mount disks and run commands
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

    /*
     * TODO: Replace this stub with actual DOSBox initialization:
     *
     *   1. Create CommandLine with: --conf <conf_path> --noprimaryconf
     *   2. control = std::make_unique<Config>(&command_line);
     *   3. init_config_dir();
     *   4. DOSBOX_InitModuleConfigsAndMessages();
     *   5. control->ParseConfigFiles(...);
     *   6. GFX_InitSdl();
     *   7. DOSBOX_InitModules();
     *   8. GFX_InitAndStartGui();
     *   9. MAPPER_BindKeys(get_sdl_section());
     *  10. SHELL_InitAndRun();   // blocks until exit
     *  11. DOSBOX_DestroyModules();
     *  12. GFX_Destroy();
     */

    // For now, just log that we would start
    fprintf(stderr, "[DOSBox Bridge] Would start DOSBox with config: %s\n", conf_path);

    free(conf_path);
    s_running.store(false);
    return 0;
}

void dosbox_request_shutdown(void)
{
    // TODO: Call DOSBOX_RequestShutdown() when linked
    s_running.store(false);
}

int dosbox_is_running(void)
{
    return s_running.load() ? 1 : 0;
}

/* ---------- input injection ---------- */

void dosbox_inject_key(int sdl_scancode, int pressed)
{
    // TODO: Push SDL_KEYDOWN/SDL_KEYUP event into SDL event queue
    // SDL_Event event;
    // event.type = pressed ? SDL_KEYDOWN : SDL_KEYUP;
    // event.key.keysym.scancode = (SDL_Scancode)sdl_scancode;
    // SDL_PushEvent(&event);
    (void)sdl_scancode; (void)pressed;
}

void dosbox_inject_char(uint16_t unicode_char)
{
    // TODO: Push SDL_TEXTINPUT event
    (void)unicode_char;
}

void dosbox_inject_mouse(int dx, int dy, int buttons)
{
    // TODO: Push SDL_MOUSEMOTION + SDL_MOUSEBUTTONDOWN/UP events
    (void)dx; (void)dy; (void)buttons;
}

void dosbox_inject_mouse_abs(int x, int y, int buttons)
{
    // TODO: Push absolute mouse position via SDL or DOSBox mouse API
    (void)x; (void)y; (void)buttons;
}
