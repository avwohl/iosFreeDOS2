/*
 * glib_compat.h — Minimal glib compatibility shim for libslirp on iOS
 *
 * Maps glib types, memory functions, string utilities, assertions,
 * and logging to standard C equivalents. This allows building libslirp
 * without the full glib2 dependency.
 *
 * SPDX-License-Identifier: MIT
 */
#ifndef GLIB_COMPAT_H
#define GLIB_COMPAT_H

#include <assert.h>
#include <inttypes.h>
#include <signal.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#ifdef __APPLE__
#include <libkern/OSByteOrder.h>
#endif

/* ── Byte order (GLib G_BYTE_ORDER) ─────────────────────── */

#define G_BIG_ENDIAN    4321
#define G_LITTLE_ENDIAN 1234

#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#  define G_BYTE_ORDER G_BIG_ENDIAN
#else
#  define G_BYTE_ORDER G_LITTLE_ENDIAN
#endif

/* ── Pointer size ────────────────────────────────────────── */

#define GLIB_SIZEOF_VOID_P __SIZEOF_POINTER__

/* ── GLib basic types ────────────────────────────────────── */

typedef char gchar;
typedef unsigned char guchar;
typedef int gint;
typedef unsigned int guint;
typedef short gshort;
typedef unsigned short gushort;
typedef long glong;
typedef unsigned long gulong;
typedef int8_t gint8;
typedef uint8_t guint8;
typedef int16_t gint16;
typedef uint16_t guint16;
typedef int32_t gint32;
typedef uint32_t guint32;
typedef int64_t gint64;
typedef uint64_t guint64;
typedef size_t gsize;
typedef ssize_t gssize;
typedef int gboolean;
typedef void *gpointer;
typedef const void *gconstpointer;
typedef char **GStrv;

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

/* ── Compiler hints ──────────────────────────────────────── */

#define G_UNLIKELY(x) __builtin_expect(!!(x), 0)
#define G_LIKELY(x)   __builtin_expect(!!(x), 1)
#define G_GNUC_PRINTF(fmt, args) __attribute__((format(printf, fmt, args)))
#define G_STATIC_ASSERT(expr) _Static_assert(expr, #expr)
#define G_SIZEOF_MEMBER(type, member) sizeof(((type *)0)->member)

/* Platform detection */
#ifndef _WIN32
#define G_OS_UNIX 1
#endif

/* ── Memory allocation (abort on failure, like glib) ─────── */

static inline gpointer g_malloc(gsize n_bytes)
{
    gpointer p = malloc(n_bytes ? n_bytes : 1);
    if (!p) {
        fprintf(stderr, "g_malloc: out of memory (%" PRIu64 " bytes)\n",
                (uint64_t)n_bytes);
        abort();
    }
    return p;
}

static inline gpointer g_malloc0(gsize n_bytes)
{
    gpointer p = calloc(n_bytes ? n_bytes : 1, 1);
    if (!p) {
        fprintf(stderr, "g_malloc0: out of memory (%" PRIu64 " bytes)\n",
                (uint64_t)n_bytes);
        abort();
    }
    return p;
}

static inline gpointer g_realloc(gpointer mem, gsize n_bytes)
{
    gpointer p = realloc(mem, n_bytes ? n_bytes : 1);
    if (!p) {
        fprintf(stderr, "g_realloc: out of memory (%" PRIu64 " bytes)\n",
                (uint64_t)n_bytes);
        abort();
    }
    return p;
}

static inline void g_free(gpointer mem)
{
    free(mem);
}

#define g_new(type, count)  ((type *)g_malloc(sizeof(type) * (count)))
#define g_new0(type, count) ((type *)g_malloc0(sizeof(type) * (count)))

/* ── String utilities ────────────────────────────────────── */

static inline gchar *g_strdup(const gchar *str)
{
    return str ? strdup(str) : NULL;
}

/* strlcpy is available on macOS/iOS */
static inline gsize g_strlcpy(gchar *dest, const gchar *src, gsize dest_size)
{
    return strlcpy(dest, src, dest_size);
}

#define g_snprintf  snprintf
#define g_vsnprintf vsnprintf
#define g_strerror  strerror

static inline gboolean g_str_has_prefix(const gchar *str, const gchar *prefix)
{
    return strncmp(str, prefix, strlen(prefix)) == 0;
}

static inline gchar *g_strstr_len(const gchar *haystack, gssize haystack_len,
                                  const gchar *needle)
{
    if (haystack_len < 0)
        return (gchar *)strstr(haystack, needle);
    /* bounded search */
    gsize nlen = strlen(needle);
    for (gssize i = 0; i <= haystack_len - (gssize)nlen; i++) {
        if (memcmp(haystack + i, needle, nlen) == 0)
            return (gchar *)(haystack + i);
    }
    return NULL;
}

static inline guint g_strv_length(gchar **str_array)
{
    guint i = 0;
    if (str_array)
        while (str_array[i])
            i++;
    return i;
}

static inline void g_strfreev(gchar **str_array)
{
    if (str_array) {
        for (guint i = 0; str_array[i]; i++)
            g_free(str_array[i]);
        g_free(str_array);
    }
}

/* ── Environment ─────────────────────────────────────────── */

static inline const gchar *g_getenv(const gchar *variable)
{
    return getenv(variable);
}

/* ── GString (dynamic string) ────────────────────────────── */

typedef struct {
    gchar *str;
    gsize len;
    gsize allocated_len;
} GString;

static inline GString *g_string_new(const gchar *init)
{
    GString *s = (GString *)g_malloc(sizeof(GString));
    if (init) {
        s->len = strlen(init);
        s->allocated_len = s->len + 64;
        s->str = (gchar *)g_malloc(s->allocated_len);
        memcpy(s->str, init, s->len + 1);
    } else {
        s->len = 0;
        s->allocated_len = 64;
        s->str = (gchar *)g_malloc(s->allocated_len);
        s->str[0] = '\0';
    }
    return s;
}

static inline void g_string_append_printf(GString *string, const char *format, ...)
    __attribute__((format(printf, 2, 3)));

static inline void g_string_append_printf(GString *string, const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    char buf[1024];
    int n = vsnprintf(buf, sizeof(buf), format, ap);
    va_end(ap);
    if (n > 0) {
        gsize needed = string->len + (gsize)n + 1;
        if (needed > string->allocated_len) {
            string->allocated_len = needed * 2;
            string->str = (gchar *)g_realloc(string->str, string->allocated_len);
        }
        memcpy(string->str + string->len, buf, (gsize)n + 1);
        string->len += (gsize)n;
    }
}

static inline gchar *g_string_free(GString *string, gboolean free_segment)
{
    gchar *result = NULL;
    if (!free_segment)
        result = string->str;
    else
        g_free(string->str);
    g_free(string);
    return result;
}

/* ── GRand (random numbers — use arc4random on Apple) ────── */

typedef struct { int dummy; } GRand;

static inline GRand *g_rand_new(void)
{
    return g_new0(GRand, 1);
}

static inline void g_rand_free(GRand *rand_)
{
    g_free(rand_);
}

static inline gint32 g_rand_int_range(GRand *rand_ __attribute__((unused)),
                                      gint32 begin, gint32 end)
{
    return (gint32)(begin + (gint32)arc4random_uniform((uint32_t)(end - begin)));
}

/* ── Logging ─────────────────────────────────────────────── */

#define g_debug(fmt, ...)   do { /* silent */ } while (0)

#define g_warning(fmt, ...) \
    fprintf(stderr, "SLIRP WARNING: " fmt "\n", ##__VA_ARGS__)

#define g_critical(fmt, ...) \
    fprintf(stderr, "SLIRP CRITICAL: " fmt "\n", ##__VA_ARGS__)

#define g_error(fmt, ...) do { \
    fprintf(stderr, "SLIRP ERROR: " fmt "\n", ##__VA_ARGS__); \
    abort(); \
} while (0)

/* ── Assertions ──────────────────────────────────────────── */

#define g_assert(expr)          assert(expr)
#define g_assert_not_reached()  do { assert(0 && "not reached"); __builtin_unreachable(); } while (0)

#define g_warn_if_fail(expr) do { \
    if (G_UNLIKELY(!(expr))) \
        fprintf(stderr, "SLIRP: assertion '%s' failed at %s:%d\n", \
                #expr, __FILE__, __LINE__); \
} while (0)

#define g_warn_if_reached() \
    fprintf(stderr, "SLIRP: code should not be reached at %s:%d\n", \
            __FILE__, __LINE__)

#define g_return_if_fail(expr) do { \
    if (G_UNLIKELY(!(expr))) { \
        g_warn_if_fail(expr); \
        return; \
    } \
} while (0)

#define g_return_val_if_fail(expr, val) do { \
    if (G_UNLIKELY(!(expr))) { \
        g_warn_if_fail(expr); \
        return (val); \
    } \
} while (0)

/* ── GError (minimal stub — fork_exec is not used on iOS) ── */

typedef struct {
    int code;
    char *message;
} GError;

static inline void g_error_free(GError *error)
{
    if (error) {
        g_free(error->message);
        g_free(error);
    }
}

/* ── Shell/Process stubs (not used on iOS) ───────────────── */

typedef void (*GSpawnChildSetupFunc)(gpointer user_data);
typedef int GPid;

typedef enum {
    G_SPAWN_SEARCH_PATH = 1 << 2,
    G_SPAWN_DO_NOT_REAP_CHILD = 1 << 3,
} GSpawnFlags;

static inline gboolean g_shell_parse_argv(const gchar *command_line __attribute__((unused)),
                                          gint *argcp __attribute__((unused)),
                                          gchar ***argvp __attribute__((unused)),
                                          GError **error __attribute__((unused)))
{
    return FALSE;
}

static inline gboolean g_spawn_async_with_fds(
    const gchar *working_directory __attribute__((unused)),
    gchar **argv __attribute__((unused)),
    gchar **envp __attribute__((unused)),
    GSpawnFlags flags __attribute__((unused)),
    void *child_setup __attribute__((unused)),
    gpointer user_data __attribute__((unused)),
    void *child_pid __attribute__((unused)),
    gint stdin_fd __attribute__((unused)),
    gint stdout_fd __attribute__((unused)),
    gint stderr_fd __attribute__((unused)),
    GError **error __attribute__((unused)))
{
    return FALSE;
}

static inline gboolean g_spawn_async(
    const gchar *working_directory __attribute__((unused)),
    gchar **argv __attribute__((unused)),
    gchar **envp __attribute__((unused)),
    GSpawnFlags flags __attribute__((unused)),
    void *child_setup __attribute__((unused)),
    gpointer user_data __attribute__((unused)),
    void *child_pid __attribute__((unused)),
    GError **error __attribute__((unused)))
{
    return FALSE;
}

/* ── Debug string parsing (stub) ─────────────────────────── */

typedef struct {
    const char *key;
    int value;
} GDebugKey;

static inline guint g_parse_debug_string(const gchar *string __attribute__((unused)),
                                         const GDebugKey *keys __attribute__((unused)),
                                         guint nkeys __attribute__((unused)))
{
    return 0;
}

/* ── MIN / MAX ───────────────────────────────────────────── */

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif
#ifndef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif

/* ── Byte-order macros (big-endian ↔ host) ───────────────── */

#ifdef __APPLE__
#define GUINT16_FROM_BE(val) OSSwapBigToHostInt16(val)
#define GUINT16_TO_BE(val)   OSSwapHostToBigInt16(val)
#define GUINT32_FROM_BE(val) OSSwapBigToHostInt32(val)
#define GUINT32_TO_BE(val)   OSSwapHostToBigInt32(val)
#define GINT16_FROM_BE(val)  ((gint16)OSSwapBigToHostInt16((guint16)(val)))
#define GINT16_TO_BE(val)    ((gint16)OSSwapHostToBigInt16((guint16)(val)))
#define GINT32_FROM_BE(val)  ((gint32)OSSwapBigToHostInt32((guint32)(val)))
#define GINT32_TO_BE(val)    ((gint32)OSSwapHostToBigInt32((guint32)(val)))
#else
#include <endian.h>
#define GUINT16_FROM_BE(val) be16toh(val)
#define GUINT16_TO_BE(val)   htobe16(val)
#define GUINT32_FROM_BE(val) be32toh(val)
#define GUINT32_TO_BE(val)   htobe32(val)
#define GINT16_FROM_BE(val)  ((gint16)be16toh((guint16)(val)))
#define GINT16_TO_BE(val)    ((gint16)htobe16((guint16)(val)))
#define GINT32_FROM_BE(val)  ((gint32)be32toh((guint32)(val)))
#define GINT32_TO_BE(val)    ((gint32)htobe32((guint32)(val)))
#endif

/* ── Miscellaneous ───────────────────────────────────────── */

#define GLIB_CHECK_VERSION(major, minor, micro) 0
#define G_N_ELEMENTS(arr) (sizeof(arr) / sizeof((arr)[0]))

#endif /* GLIB_COMPAT_H */
