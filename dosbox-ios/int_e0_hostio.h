/*
 * int_e0_hostio.h — INT E0h host file transfer for R.COM / W.COM
 */
#ifndef INT_E0_HOSTIO_H
#define INT_E0_HOSTIO_H

/* Call after DOSBOX_InitModules() to hook INT E0h.
 * host_dir: root directory for file transfers (app Documents dir on iOS).
 *           NULL or "" disables transfers (INT E0h returns CF=1). */
void HOSTIO_Init(const char *host_dir);

/* Cleanup — closes any open host files. */
void HOSTIO_Destroy();

#endif
