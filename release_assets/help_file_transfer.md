# File Transfer with R.COM and W.COM

FreeDOS includes two utilities for moving files between DOS and your device.

## R.COM — Read from Host

Copies a file from your device into a DOS file:

```
A:\> R hostfile.txt DOSFILE.TXT
File transferred.
```

## W.COM — Write to Host

Copies a DOS file out to your device:

```
A:\> W DOSFILE.TXT hostfile.txt
File transferred.
```

## Where Are Host Files?

**iOS (iPhone / iPad):**
When you use a bare filename like `output.txt`, it goes to the app's Documents folder. To find it, open the **Files** app and go to **On My iPhone** (or iPad) → **FreeDOS**. This is where R.COM reads from and W.COM writes to. Use AirDrop, iCloud, or any sharing method to get files into this folder.

Full paths starting with `/` won't work on iOS — the app is sandboxed and can only access its own Documents folder. Just use bare filenames.

**Mac (Catalyst):**
Bare filenames resolve to the app's container:
`~/Library/Containers/com.awohl.FreeDOS/Data/Documents/`

Open Finder, press Cmd+Shift+G, and paste that path.

**Command Line (freedos_cli):**
Host paths are relative to the directory where you launched `freedos_cli`. Absolute paths also work. The CLI is not sandboxed.

## Tips

- DOS filenames follow the 8.3 convention: `MYFILE.TXT`, not `My Long File.txt`
- R.COM creates (or overwrites) the DOS file
- W.COM creates (or overwrites) the host file
- Files transfer one byte at a time — large files take a moment
- Both utilities are on the FreeDOS boot floppy (drive A:)
- The host path is a native path — don't use DOS drive letters (like `C:\`) for it
