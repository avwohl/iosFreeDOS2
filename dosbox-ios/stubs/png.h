/* Stub png.h for builds without libpng — provides type definitions only */
#ifndef PNG_H_STUB
#define PNG_H_STUB

#include <stdint.h>
#include <stdio.h>

typedef struct png_struct_def* png_structp;
typedef struct png_info_def* png_infop;
typedef png_structp* png_structpp;
typedef png_infop* png_infopp;
typedef uint8_t png_byte;
typedef uint8_t* png_bytep;
typedef const uint8_t* png_const_bytep;
typedef const char* png_const_charp;
typedef void* png_voidp;
typedef void (*png_error_ptr)(png_structp, png_const_charp);
typedef uint32_t png_uint_32;

#define PNG_COLOR_TYPE_RGB 2
#define PNG_COLOR_TYPE_PALETTE 3
#define PNG_INTERLACE_NONE 0
#define PNG_COMPRESSION_TYPE_DEFAULT 0
#define PNG_FILTER_TYPE_DEFAULT 0
#define PNG_RESOLUTION_UNKNOWN 0
#define PNG_LIBPNG_VER_STRING "stub"
#define PNG_ALL_FILTERS 0
#define Z_BEST_COMPRESSION 9

/* All png_* functions are stubs that return failure */
static inline png_structp png_create_write_struct(const char* v, void* e,
    png_error_ptr ef, png_error_ptr wf) {
    (void)v; (void)e; (void)ef; (void)wf; return NULL;
}
static inline png_infop png_create_info_struct(png_structp p) {
    (void)p; return NULL;
}
static inline void png_destroy_write_struct(png_structpp p, png_infopp i) {
    (void)p; (void)i;
}
static inline void png_init_io(png_structp p, FILE* f) { (void)p; (void)f; }
static inline void png_set_IHDR(png_structp p, png_infop i,
    png_uint_32 w, png_uint_32 h, int d, int c, int il, int cm, int fm) {
    (void)p; (void)i; (void)w; (void)h; (void)d; (void)c; (void)il; (void)cm; (void)fm;
}
static inline void png_set_pHYs(png_structp p, png_infop i,
    png_uint_32 x, png_uint_32 y, int u) {
    (void)p; (void)i; (void)x; (void)y; (void)u;
}
static inline void png_set_PLTE(png_structp p, png_infop i,
    const void* pal, int n) {
    (void)p; (void)i; (void)pal; (void)n;
}
static inline void png_write_info(png_structp p, png_infop i) { (void)p; (void)i; }
static inline void png_write_row(png_structp p, png_const_bytep r) { (void)p; (void)r; }
static inline void png_write_end(png_structp p, png_infop i) { (void)p; (void)i; }
static inline void png_set_compression_level(png_structp p, int l) { (void)p; (void)l; }
static inline void png_set_compression_mem_level(png_structp p, int l) { (void)p; (void)l; }
static inline void png_set_compression_strategy(png_structp p, int s) { (void)p; (void)s; }
static inline void png_set_compression_window_bits(png_structp p, int b) { (void)p; (void)b; }
static inline void png_set_compression_buffer_size(png_structp p, unsigned long s) { (void)p; (void)s; }
static inline void png_set_compression_method(png_structp p, int m) { (void)p; (void)m; }
static inline void png_set_filter(png_structp p, int m, int f) { (void)p; (void)m; (void)f; }

/* png_color struct */
typedef struct { png_byte red; png_byte green; png_byte blue; } png_color;

#endif /* PNG_H_STUB */
