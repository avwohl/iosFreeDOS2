# FreeDOS Command Reference

Commands and utilities included with FreeDOS. Adapted from the FreeDOS Help project.
For the complete reference covering all FreeDOS packages, visit: https://fdos.github.io/help/en/

## Internal Commands

These commands are built into COMMAND.COM and are always available.

### CD / CHDIR

```
Displays the name of a drive or changes the current directory. CD is
  100% compatible with the CHDIR command; there is no difference --
  beside the spelling -- between them.
```
**Syntax:**
```
1. CD
  2. CD [ drive ':' ] path
  3. CD '-'
  4. CD [..] [-] [\] [/?]
    drive  The drive letter, e.g. C:
    path   The directory, e.g. \example\
```
**Options:**
```
..  Specifies that you want to change to the parent directory.
  -   If "last directory" feature is enabled, change to last directory.
  \   Changes to root (C:\ or D:\ etc.)
  /?  Shows the help.
```

### COPY

```
Copies one or more source files to another location
```
**Syntax:**
```
1. COPY [{ option }] source [{ option }] target [{ option }]
  2. COPY [/A | /B] [drive][path]filename + [/A | /B] [drive]
     [path]filename [+ [...]] [/A | /B] [/V] [/Y | /-Y] [/?]
     [drive][path]filename
     source:   The source file. If more than one source file is
               specified, the target must be a directory.
     target:   The target of the COPY process. If target is a directory,
               the destination file is placed into this directory, but
               with the same filename as the source file.
               If exactly one source is specified, but no target, target
               defaults to just ., which represant the current directory.
     drive     The drive letter, e.g. C:
     path      The directory, e.g. \example\
     filename  The file name, e.g. test.txt
```
**Options:**
```
Unless stated otherwise all options of this command do follow the
  standard rules for options.
    /A  Forces ASCII mode, see below
    /B: Specifies the mode, in which the file is copied, /A forces ASCII
        and /B forces binary mode.
        These options do alter the mode of the file immediately
        preceeding them and all following ones, until changed again.
        In binary mode the file is copied and nothing is changed at all.
        In ASCII mode COPY takes special care about linefeeds / newline
        characters and the end-of-line character.
        On read, the newline characters, which are a sequence of two
        different bytes in DOS, are transformed into a single character,
        as known from Unix-style systems. On write, this single character
        is transformed into the two-byte sequence.
        So, if both files are copied with different modes, newline
        characters are transformed into either way.
        If the end-of-file character is found on read, the remaining
        contents of the file is ignored. On write, such character is
        appended after the last character has been written. By default,
        files are copied in binary mode, whereas devices, e.g.
        CON:, are copied in ASCII mode, but no end-of-file is appended.
    /V  Verifies that new files are written correctly.
    /Y  Suppresses prompting to confirm you want to overwrite an
        existing destination file.
    /-Y Causes prompting to confirm you want to overwrite an existing
        destination file.
    /?  Shows the help.
```

### DEL / ERASE

```
Del / erase deletes (erases) files.
```
**Syntax:**
```
1. DEL [{ options | pattern }]
     ERASE [{ options | pattern }]
  2. DEL [/P] [/V] [/?] [drive][path]filename
     ERASE [/P] [/V] [/?] [drive][path]filename
      drive     Specifies the drive letter where the file is, e.g. C:
      path      Specifies the path to where the file is, e.g. \example\
      filename  Specifies the file(s) to delete. Specify multiple
                files by using wildcards (*,?).
                A period may be used to specify all files in the
                current directory, and is the same as *.*
      pattern   If pattern matches a directory, all files within this
                directory are deleted.
```
**Options:**
```
/P  Prompts for confirmation before deleting each file.
  /V  Displays all deleted files.
  /?  Shows the help.
```
**Comments:>**
```
If pattern matches a directory, all files within this directory are
  deleted. When all files are to be deleted, a warning prompt is issued.
  For performance reasons DEL / ERASE overwrites the first letter of
  the filename by a '?'. It does not delete the file itself, but it
  deallocates the space where the content of the file is written.
  FreeDOS, as other DOSes, recognizes the renamed file (myfile.txt
  becomes ?yfile.txt) as deleted, no longer shows it and does not
  offer access to it. Programs like DEBUG which have sector access are
  able to read the contents of the file. As long as you do not write on
  the drive you have a chance to restore the file again with UNDELETE,
  only the first character of the filename will be lost (_yfile.txt).
  The only ways to delete the file CONTENTS FOR ABSOLUTELY CERTAIN are
  to fill the disk completely with other files or by using a wipeout
  tool. The only way to delete a file NAME FOR ABSOLUTELY CERTAIN is to
  REN / RENAME the file first (e.g. "a.") and to delete it later (only
  correct at 8.3 - not at long filenames!) You can also use ERASE
  instead of DEL.
  DEL is a command internal to command.com and needs no other file
  in order to work.
```

### DIR

```
DIR displays the contens of the directory
```
**Syntax:**
```
1. DIR [{ options | pattern }]
  2. DIR  [drive][path][filename][/P] [/W] [/A[[:]attributes]]
    [/O[[:]sortorder]] [/S] [/B] [/L] [/Y] [/?]
      drive     The drive letter, e.g. C:
      path      The directory, e.g. \example\
      filename  The file to display, e.g. test.txt
                [drive][path][filename]
                Specify drive, directory, and/or files to list. (Could
                be enhanced file specification or multiple filespecs.)
```
**Options:**
```
/A:   (All) Wildcards are matched against System and Hidden files, too.
  /A**: (Attribute) Wildcards are matched against files with selected
        attributes set or clear. The argument of the /A option is a
        sequence of:
        ?  meaning: attribute ? must be set, or
        -? meaning: attribute ? must not be set.
    The following attributes, the ? above, are supported:
        r | -r  Read-only files             -r Files that are not
                                               read-only
        h | -h  Hidden files                -h Files that are not hidden
        s | -s  System files                -s Files that are not system
                                               files
        d | -d  Directories                 -d Directories
        a | -a  Files with the archive      -a Files without the archive
                bit                            bit
  /B    (Bare) Displays the lines with the information of files and
        directories only. The ones displaying the volume label, the
        serial number, totals etc. are suppressed. In combination with
        /S the absolute path of the files is displayed.
  /L    (Lower-case) Filenames are displayed in lower-case letters
        rather than capitol ones.
  /O:   (Order default) is a synonym of /ONG.
  /O**: (Order) Sort the entries displayed in a specific order. The
        following sort orders are supported:
        d | -d  By date and time            -d Date/time reverse order.
        e | -e  By file extension A-Z       -e File extension (Z-A)
        g | -g  Group directories first     -g Group directories last.
        n | -n  By file name A-Z            -n By file name (Z-A)
        s | -s  By size (smallest-biggest)  -s By size (biggest-smallest)
        u       (unsorted)
  Each sort order, except U, may be prefixed by a hyphen to reverse the
  sort order. U effectively cancels any previous setting or specified
  sort order, e.g. to override an /O option from the DIRCMD ENVIRONMENT
  VARIABLE.
  If the same sort order is specified twice within the same /O option,
  the last one superceeds previous ones; if more than one /O option is
  specified, the last one superceeds all previous ones.
  Warning: The entries are cached within memory before displaying them;
  if FreeCOM runs short on memory, to sort is disabled completely or
  the entries are sorted in chunks only.
  /P    (Page) Page the output -- pause the display after issuing one
        screen-full.
  /S    (Subdirectories) Recursively display directories.
  /W    (Wide) Displays five filenames per line and suppress the
        information about the file size, date etc.
  /Y    (Year) Displays a 4-digit year, rather than just two digits.
  /4    (4digit Year) is a synonym of /Y.
  /?    Shows the help.
```

### MD / MKDIR

```
MD / MKDIR creates a directory or subdirectory.
```
**Syntax:**
```
MD [drive][path]pathname
  MD [/?]
     drive     The drive letter where you want to create a
               directory, e.g. C:
     path      The pathname which already exists, e.g. if you
               are already in a directory.
     pathname  The name of the directory you want to create,
               e.g. \example. This may also be the name of a
               subdirectory.
```
**Options:**
```
/?  Shows the help
```

### RD / RMDIR

```
RD / RMDIR removes (deletes) an empty directory.
```
**Syntax:**
```
RMDIR [drive:][path] [/?]
  RD [drive:][path] [/?]
        drive     The drive letter where you want to delete a
                  directory, e.g. C:
        path      The pathname which already exists, e.g. if you are
                  already in a directory.
```
**Options:**
```
/?  Shows the help.
```

### REN / RENAME

```
REN / RENAME renames a file/directory or files/directories.
```
**Syntax:**
```
REN [drive][path][directoryname1 | filename1]
      [directoryname2 | filename2] [/?]
  RENAME [drive][path][directoryname1 | filename1]
      [directoryname2 | filename2] [/?]
      drive           The drive letter, e.g. C:
      path            The directory, e.g. \example\ , complete:
                      "C:\example\"
      directoryname1  The name of the old subdirectory,
                      e.g. \dir_old , complete: "C:\example\dir_old"
      directoryname2  The name of the new subdirectory,
                      e.g. dir_new , complete: "dir_new"
      filename1       The old filename, e.g. \old_file.txt
                      complete: "C:\example\old_file.txt"
      filename2       The new filename, e.g. new_file.txt
                      complete: "new_file.txt"
```
**Options:**
```
/?  Shows the help.
```

### TYPE

```
TYPE displays the contents of text files.
```
**Syntax:**
```
TYPE [drive][path]filename
  TYPE [/?]
       drive     Specifies the drive letter to where the file is,
                 e.g. C:
       path      Specifies the path to where the file is,
                 e.g. \example\
       filename  Specifies the file to display, e.g. test.txt
```
**Options:**
```
/?  Shows the help.
```

### DATE

```
Displays or sets current date.
```
**Syntax:**
```
1. DATE
  2. DATE [ /D ]
  3. DATE [ /D ] date
```
**Options:**
```
All options must precede any arguments.
  none     You are prompted for a new date for your system.
           Values for the day (dd), month (mm), and year (yy or yyyy)
           may be seperated by periods, hyphens, or slashes. Either
           a 4-digit or 2-digit year may be used.
           So you can choose between:
           mm-dd-yy or mm-dd-yyyy e.g. date 04-22-07 or 04-22-2007
           mm/dd/yy or mm/dd/yyyy e.g. date 04/22/07 or 04/22/2007
           mm.dd.yy or mm.dd.yyyy e.g. date 04.22.07 or 04.22.2007
  /D       Prevents from prompting the user. The date is displayed only.
  /D date  The date is tried to be changed, but the loop is not entered
           on failure.
  /?       Shows the help.
```

### TIME

```
Displays or sets current time.
```
**Syntax:**
```
1. TIME
  2. TIME [ /T ]
  3. TIME [ /T ] time
```
**Options:**
```
All options must precede any arguments.
  none     You are prompted for a new time for your system.
           hh:mm
           hh:mm:ss
           hh:mm:ss.ss
           The time to set for your system.
           'hh' is the hour on a 12 or 24 hour clock.
           'mm' is the minute.
           'ss.ss' is seconds and hundredths of seconds.
  /T       Prevents from prompting the user, only he time is displayed.
  /T time  The time is tried to be changed, but the loop is not entered
           on failure.
  /?       Shows the help.
```

### VER

```
VER displays the FreeDOS version information. By default,
  only the version of the command shell (FreeCOM) is reported.
```
**Syntax:**
```
VER [/R] [/W] [/D] [/C]
```
**Options:**
```
none  Shows COMMAND.COM version number.
  /R    Shows the KERNEL and COMMAND.COM version numbers. When
        VERSION=x.yy is set in CONFIG.SYS / FDCONFIG.SYS
        it also shows this DOS version number.
  /W    Shows the FreeDOS command shell warranty.
  /D    Shows the FreeDOS command shell distribution information.
  /C    The FreeCOM acknowledgements section. It lists contributors.
```

### VOL

```
VOL displays the disk volume label and serial number, if they exist.
```
**Syntax:**
```
VOL [drive]
  VOL [/?]
      drive  Specifies the drive letter to display the volume
             label, e.g. C: and the serial number
```
**Options:**
```
/?  Shows the help.
```

## Batch File Commands

Commands for writing batch (.BAT) files.

### ECHO

```
ECHO displays messages, or turns command-echoing on or off.
  There also exists a CONFIG.SYS / FDCONFIG.SYS ECHO command.
  ECHO is a BATCH-FILE / AUTOEXEC.BAT / FDAUTO.BAT command.
  It can also be used in command line (except with @ - at symbol).
```
**Syntax:**
```
1. ECHO [ON | OFF]
  2. ECHO [message (string)]
  3. ECHO.
```
**Options:**
```
ON       ECHO mode is activated. If you use ECHO within a batch
           file, each command line is shown when it is executed.
  OFF      ECHO mode is deactivated. If you use ECHO within a batch
           file, the command line is not shown when it is executed.
           This does not affect the output of the command itself.
  message  The message you want to print on the screen.
  .        Displays an empty line.
  /?       Shows the help.
```

### FOR

```
FOR runs a specified command for each file in a set of files.
  FOR is a COMMAND LINE and a BATCH-FILE / AUTOEXEC.BAT /FDAUTO.BAT
  command.
```
**Syntax:**
```
FOR %variable IN (set) DO command [cmd-parameters] OR:
  FOR %%variable IN (set) DO command [cmd-paramters]
```
**Options:**
```
%variable       A name for the parameter that will be replaced
                  with each file name. The variable may only be one
                  character long.
  %%variable      A name for the parameter that will be replaced
                  with each file name. The variable may only be one
                  character long.
  (set)           Specifies a set of one or more files. Wildcards
                  and ? may be used.
  command         Specifies the command to run for each file.
  cmd-parameters  Specifies parameters or switches for the
                  specified command.
```

### GOTO

```
GOTO directs the command shell to a labelled line in a batch program.
  GOTO is a BATCH-FILE / AUTOEXEC.BAT / FDAUTO.BAT command.
```
**Syntax:**
```
GOTO  [ ':' ]label
```
**Options:**
```
label  Specifies a text string used in the batch program as a label.
         Both "goto label" and "goto :label" work.
  /?     Shows the help
```

### IF

```
Conditional execution of a command.
```
**Syntax:**
```
1. IF [ NOT ] EXIST file "command"
  2. IF [ NOT ] ERRORLEVEL number "command"
  3. IF [ NOT ] string '==' word "command"
  4. IF [ NOT ] quoted-string '==' quoted-string "command"
  5. IF /I string==STRING
```
**Options:**
```
command              Specifies the command to carry out if the condition
                       is met.
  NOT                  Specifies that the command shell should carry out
                       the command only if the condition is false.
                       (Without this, the command will be run if the
                       condition is true.)
  ERRORLEVEL number:   DOS Programs return a number when they exit,
                       which sometimes contains information on
                       whether the program was successful. If the
                       last program to exit returned the given number,
                       then the condition is true.
  string1==string2     If the two strings of characters are equal,
                       then the condition is true.
  exist [drive][path]  If the given file is there, then the condition
        filename       is true.
  /I string==STRING    Ignores uppercase / lowercase
```

### PATH

```
Display or set the search path for executable files.
```
**Syntax:**
```
1. PATH
   2. PATH [ '=' ] { path : ';' }
   3. PATH;
```
**Options:**
```
PATH  Displays the currently active search path.
  PATH= Assigns the specified paths to the search path.
        The leading equal sign, if present is ignored.
  PATH; Empties the search path.
  /?    Shows the help
```

### PAUSE

```
PAUSE suspends processing of a batch program and displays
  the message:
    "Press any key to continue...."
  or an optional specified message.
  PAUSE is a BATCH-FILE / AUTOEXEC.BAT / FDAUTO.BAT command.
```
**Syntax:**
```
PAUSE [message]
```
**Options:**
```
message  The message you want to be sent.
```

### SET

```
SET displays, sets, or removes ENVIRONMENT VARIABLE.
  SET is a BATCH-FILE / AUTOEXEC.BAT / FDAUTO.BAT command.
  It can also be used in command line.
```
**Syntax:**
```
SET [/C] [/I] [/P] [/E] [/U] [variable[=[string]]]
  SET [/?]
  variable  Specifies the ENVIRONMENT VARIABLE name.
  string    Specifies a series of characters to assign to the variable.
  * If no string is specified, the variable is removed from the
    ENVIRONMENT.
  Type SET without parameters to display the current environment
  variables. Type SET VAR to display the value of VAR.
```
**Options:**
```
/C  Forces to keep the exact case of the letters of the variable name;
      by default all letters are uppercased to keep compatibly.
  /I: has been temporarily included to the SET command to allow an easy
      way to display the current size of the ENVIRONMENT segment, because
      it is one of the most frequently reported, but not reproduceable
      bug report. Once this option has been encountered, all the
      remaining command line is ignored.
  /P: Prompts the user with the specified "string" and assigns the user's
      input to the variable. If no input is made, hence, one taps just
      ENTER, an empty value is assigned to the variable, which is then
      removed from the ENVIRONMENT.
  /E  Sets the given variable to the first line of output of the
      command pointed to by [string].
  /U  Changes the case of [string] to uppercase.
  /?  Shows the help.
```

### CHOICE

```
CHOICE / _CHOICE suspends processing and waits for the user to press a
  valid key from a given list of choices. Choice gives out an
  ERRORLEVEL (EXITCODE) which can be used for further work.
```
**Syntax:**
```
CHOICE [ /B ] [ /C[:]choices ] [ /N ] [ /S ] [ /T[:]c,nn ] [ text ]
         [/?]
  _CHOICE [ /B ] [ /C[:]choices ] [ /N ] [ /S ] [ /T[:]c,nn ] [ text ]
          [/?]
```
**Options:**
```
/B           Sounds an alert (beep) at prompt.
  /C[:]choices Specifies allowable keys in the prompt. When displayed,
               the keys will be separated by commas, will appear in
               brackets ([]), and will be followed by a question mark.
               If you don't specify the /C switch, choice uses YN as the
               default, you may also be 0 - 9 or A - Z. The colon (:) is
               optional.
  /N           Causes choice not to display the prompt. The text before
               the prompt is still displayed, however. If you specify
               the /N switch, the specified keys are still valid.
  /S           Causes choice to be case sensitive. If the /S switch is
               not specified, choice will accept either upper or lower
               case of the keys that the user specifies.
  /T[:]c,nn    Causes choice to pause for a specified number of seconds
               before defaulting to a specified key. The values for the
               /T switch are as follows:
               c   Specifies the character to display after nn seconds.
                   The character must be in the set of choices specified
                   by the /C switch.
               nn  Specifies the number of seconds to pause. Acceptable
                   values are from 0 to 99. If 0 is specified, there will
                   be no pause before defaulting.
  text       The text to display as a prompt (default=none).
  /?         Shows the help.
```

### CLS

```
CLS clears the screen and resets the character colours to white
  on black.
  CLS is a BATCH-FILE / AUTOEXEC.BAT / FDAUTO.BAT command.
  It can also be used in command line.
```
**Syntax:**
```
cls
```
**Options:**
```
- none -
```

## External Commands

Utility programs in C:\FREEDOS\BIN.

### EDIT

```
EDIT is the FreeDOS text editor.
```
**Syntax:**
```
edit [/B][/I][/H][/R][/?] [[drive][path]file]
       drive  The drive letter, e.g. C:
       path   The directory, e.g. \example\
       file   The file, e.g. test.txt. Wildcards can be used here.
              You can also open files within the program.
```
**Options:**
```
/B     Use a black and white (monochrome) display.
  /I     Use inverse color scheme.
  /H     Use 43/50 lines on EGA/VGA (highest video/text resolution
         available).
  /R     Open all files read-only.
  /?     Shows the help.
```

### MEM

```
MEM displays the amount of installed and free memory in your system.
```
**Syntax:**
```
MEM [options] [/?]
```
**Options:**
```
/ALL        Show all details of high memory area (HMA).
  /C          Classify modules using memory below 1 MB.
  /D          Same as /DEBUG by default, same as /DEVICE if /OLD used.
  /DEBUG      Show programs and devices in conventional and upper memory.
  /DEVICE     List of device drivers currently in memory.
  /E          Reports all information about Expanded Memory.
  /F          Same as /FREE by default, same as /FULL if /OLD used.
  /FREE       Show free conventional and upper memory blocks.
  /FULL       Full list of memory blocks.
  /M (name) | /MODULE (name)
              Show memory used by the given program or driver.
  /NOSUMMARY  Do not show the summary normally displayed when no other
              options are specified.
  /OLD        Compatability with FreeDOS MEM 1.7 beta.
  /P          Pauses after each screenful of information.
  /SUMMARY    Negates the /NOSUMMARY option.
  /U          List of programs in conventional and upper memory.
  /X          Reports all information about Extended Memory.
  /?          Shows the help.
```

### MORE

```
MORE displays a text file or the output of a command one screen
  at a time.
```
**Syntax:**
```
more < [drive][path]file
  command | MORE [/Tn]
  MORE [/Tn] file
  MORE [/Tn] < file
  MORE [/?]
       drive     Specifies the drive letter where the file is, e.g. C:
       path      Specifies the path to where the file is, e.g. \example\
       filename  Specifies the file you want to display, e.g. test.txt
       command   A command whose output you will pipe to the more program.
```
**Options:**
```
Tn  Sets the tabulator size to n, n has to be in the range
      between 1 and 9.
  /?  Shows the help.
  Keys:
    Space  Next page (only while viewing a file)
    N n    Next file (only while viewing a file)
    Q q    Quit program (only while viewing a file)
```

### DELTREE

```
FreeDOS DELTREE.COM is a freeware clone of Microsoft's DELTREE.EXE, a
  utility for quickly deleting files and directories with all included
  files and subdirectories.
  DELTREE doesn't care any file attributes, it does its job even files
  and directories have read-only, hidden or system-attributes!
```
**Syntax:**
```
DELTREE [/?] [/Y] [/V] [/D] [/X] filespec [filespec...] [@filelist]
          drive  The drive letter, e.g. C:
          path   The directory, e.g. \example
```
**Options:**
```
/Y            Deletes specified items without prompting.
  /V            Report counts and totals when finished.
  /D            Displays the debug info.
  /X            For testing; don't actually delete anything.
   @            FLAG to indicate the specified file as a "DR-DOS-type"
                filelist.
  /?            Shows the help.
```

### XCOPY

```
XCOPY copies files and directories, including subdirectories.
```
**Syntax:**
```
XCOPY source [destination] [options]
        source       Specifies the directory and/or name of file(s) to
                     copy. The source must be either a drive or a full
                     path.
        destination  Specifies the location and/or name of new file(s).
                     The destination to copy to. If not present, xcopy
                     assumes the working directory.
```
**Options:**
```
/A          Copies only files with the archive attribute set and
              doesn't change the attribute.
  /C          Continues copying even if errors occur.
  /D[:M/D/Y]  Copies only files which have been changed on or after the
              specified date. When no date is specified, only files which
              are newer than existing destination files will be copied.
  /E          Copies any subdirectories, even if empty.
  /F          Display full source and destination name.
  /H          Copies hidden and system files as well as unprotected
              and system files.
  /I          If destination does not exist and copying more than one
              file, assume destination is a directory.
  /L          List files without copying them. (simulates copying).
  /M          Copies only files with the archive attribute set and turns
              off the archive attribute of the source files after copying
              them.
  /N          Suppresses prompting to confirm you want to overwrite an
              existing destination file and skips these files.
  /P          Prompts for confirmation before creating each destination
              file.
  /Q          Quiet mode, don't show copied filenames.
  /R          Overwrite read-only files as well as unprotected files.
  /S          Copies directories and subdirectories except empty ones.
  /T          Creates directory tree without copying files. Empty
              directories will not be copied. To copy them add switch /E.
  /V          Verifies each new file.
  /W          Waits for a keypress before beginning.
  /Y          Suppresses prompting to confirm you want to overwrite an
              existing destination file and overwrites these files.
  /-Y         Causes prompting to confirm you want to overwrite an
              existing destination file.
  /?          Shows the help.
```

### FORMAT

```
FORMAT formats a hard drive or floppy disk. This prepares the medium
  for the use with FreeDOS. FDISK is not needed for floppy disks!
```
**Syntax:**
```
Simplified syntax:
    FORMAT drive [/V[:label]] [/Q] [/U] [/F:size] [/S] [/D]
    FORMAT drive [/V[:label]] [/Q] [/U] [/T:tracks /N:sectors] [/S] [/D]
    FORMAT drive [/V[:label]] [/Q] [/U] [/4] [/S] [/D]
    FORMAT [/?]
  Full syntax (including new features and backwards compatibility
  options):
  Harddisk drives:
    FORMAT drive: [/V[:label]] [/Q] [/U] [/Z:seriously]
                  [/S] [/A] [/D] [/Y]
  New features, all drives:
    FORMAT drive: [/Z:mirror | /Z:unformat] [/D] [/Y]
  Floppy disk drives:
    FORMAT drive: [/V[:label]] [/Q] [/U] [/F:size]
                  [/B | /S] [/D] [/Y]
    FORMAT drive: [/V[:label]] [/Q] [/U] [/T:cyls /N:sect]
                  [/B | /S] [/D] [/Y]
    FORMAT drive: [/V[:label]] [/Q] [/U] [/1] [/4]
                  [/B | /S] [/D] [/Y]
  Old DOS 1.x floppy disks:
    FORMAT drive: /8 [/Q] [/U] [/1] [/4] [/B | /S] [/D] [/Y]

         drive  The drive letter, e.g. C:
```
**Options:**
```
/1            Format a single-sided floppy disk (160k/180k).
  /4            Format a 160k/360k floppy disk in a 1.2 MB floppy drive.
                As 1.2 MB uses narrower tracks, format can be too weak
                for 360k drives.
  /8            Format a 5-1/4 inch floppy disk with 8 sectors per track
                (160k/320k, DOS 1.x).
  /A            Force metadata (reserved/boot sectors and FAT32s
                together) to be a multiple of 4k in size. The NTFS
                converter of WinXP wants that.
  /B            Reserve space to make a bootable disk (is dummy and
                cannot be combined with /s (SYS).
  /D            Be very verbose and show DEBUGGING output. For bug
                reports (always allowed). This even changes the returned
                error levels to be more "verbose".
  /F:size       Specifies the size of the floppy disk to format. Normal
                sizes are: 160, 180, 320, 360, 720, 1200, 1440, or 2880.
                To format to 720k in a drive which can do 1440k or more,
                you must use 720k DD media. /F shows a list of allowed
                sizes.
  /N:sectors    Specifies the number of sectors per track on a floppy
                disk.
  /Q            Quick formats the disk. The disk can be UNFORMATed and
                the bad cluster list is preserved (not preserved in
                /Q /U mode). This is the default if an existing
                filesystem is found.
  /Q /U         Quick formats the disk but does NOT preserve unformat
                data and does NOT wipe or scan the surface. Just deletes
                everything FAST. This is the default if an unformatted
                harddisk is detected.
  /S            Copies the operating system files to make the disk
                bootable. Needs SYS. The displayed size info describes
                the pre-SYS state!
  /T:tracks     Specifies the number of tracks on a floppy disk.
  /U            Unconditionally formats the disk. The disk cannot be
                UNFORMATed. Causes lowlevel format for floppy and
                surface scan, overwriting all data with "empty" sectors,
                for harddisk. This is the default if an unformatted
                floppy is detected. NOTE: This option may last VERY
                VERY long! Press ESC and wait to exit /U.
  /V:label      Specifies a volume LABEL for the disk, stores date and
                time of it (is not for 160k/320k disks).
  /Y            Do not prompt for a new floppy, just format at once.
                Similar to /AUTOTEST and /BACKUP switches in other
                FORMAT implementations. (Always allowed).
  /Z:longhelp   Gives detailed, technical usage information.
  /Z:mirror     Just save the "MIRROR" data for a later UNFORMAT. This
                will overwrite the very end of the disk with a copy of
                one FAT, root directory and main boot sector. If this
                space is in use, MIRROR will fail (new feature 0.91r).
                To force, you MIGHT use SafeFormat plus UnFormat instead
                - SafeFormat is allowed to overwrite data. It is not
                possible to save mirror data to another location.
  /Z:seriously  Suppresses the confirmation request when you use format
                with a hard disk. Similar to the /AUTOTEST switch in
                other FORMAT implementations.
  /Z:unformat   This will "restore" saved "MIRROR" data (copy it back,
                overwriting your FATs etc. with the backup). Do ONLY use
                this if you have just accidentally formatted a disk. In
                all other situations, UNFORMAT can seriously trash the
                disk contents.
  /?            Shows the help.
```

### FDISK

```
FDISK creates one or several partitions on a hard disk. After this,
  the partitions can be formatted and are ready to work with FreeDOS.
  To make them bootable you may have to set an 'active partition' and
  to run 'fdisk /ipl' (or: 'fdisk /mbr') and 'sys c:'.
  FDISK is not needed for floppy disks!
```
**Syntax:**
```
FDISK [drive#][argument]...
  no argument       Runs in interactive mode.
  /INFO             Displays partition information of <drive#>.
  /REBOOT           Reboots the Computer.
```
**Options:**
```
Commands to create and delete partitions:
  <size>  is a number for megabytes or MAX for maximum size
          or <number>,100 for <number> to be in percent.
  <type#> is a numeric partition type or FAT-12/16/32 if /SPEC not given.

  /PRI:<size> [/SPEC:<type#>]              Creates a primary partition.
  /EXT:<size>                              Creates an Extended DOS
                                           Partition.
  /LOG:<size> [/SPEC:<type#>]              Creates a logical drive.
  /PRIO,/EXTO,/LOGO                        Same as above, but avoids
                                           FAT32.
  /AUTO                                    Automatically partitions the
                                           disk.
  /DELETE {/PRI[:#] | /EXT | /LOG:<part#>  Deletes a partition.
           | /NUM:<part#>}                 ...logical drives start at
                                           /NUM=5.
  /DELETEALL                               Deletes all Partitions from
                                           <drive#>.

Setting active partitions:
  /ACTIVATE:<partition#>                   Sets <partition#> active.
  /DEACTIVATE                              Deactivates all partitions.

MBR (Master Boot Record) management:
  /CLEARMBR               Deletes all partitions and boot code.
  /LOADMBR                Loads part. table and code from "boot.mbr"
                          into MBR.
  /SAVEMBR                Saves partition table and code into file
                          "boot.mbr".

MBR code modifications leaving partitions intact:
  /IPL                    Installs the standard boot code into MBR
                          <drive#>.
                          ...Same as /MBR and /CMBR for compatibility.
  /SMARTIPL               Installs DriveSmart IPL into MBR <drive#>.
  /LOADIPL                Writes 440 code bytes from "boot.mbr" into MBR.

Advanced partition table modification:
  /MODIFY:<part#>,<type#>                    Changes partition type to
                                             <type#>. ...Logical drives
                                             start at "5".
  /MOVE:<srcpart#>,<destpart#>               Moves primary partitions.
  /SWAP:<1stpart#>,<2ndpart#>                Swaps primary partitions.

For handling flags on a hard disk:
  /CLEARFLAG[{:<flag#>} | /ALL}]             Resets <flag#> or all on
                                             <drive#>.
  /SETFLAG:<flag#>[,<value>]                 Sets <flag#> to 1 or
                                             <value>.
  /TESTFLAG:<flag#>[,<value>]                Tests <flag#> for 1 or
                                             <value>.

For obtaining information about the hard disk(s):
  /STATUS       Displays the current partition layout.
  /DUMP         Dumps partition information from all hard disks
               (for debugging).

Interactive user interface switches:
  /UI           Always starts UI if given as last argument.
  /MONO         Forces the user interface to run in monochrome mode.
  /FPRMT        Prompts for FAT32/FAT16 in interactive mode.
  /XO           Enables extended options.

Compatibility options:
  /X            Disables ext. INT 13 and LBA for the following commands.
```

### LABEL

```
LABEL creates, changes or deletes the volume label of a disk.
```
**Syntax:**
```
LABEL  [drive:][label] [/?]
    drive:  Specifies which drive you want to assign a label, e.g. C:
            If missing, the current drive is assumed.
```
**Options:**
```
label  Specifies the new LABEL you want to label the drive.
         If missing, LABEL prompts you for it.
  /?     Shows the help.
```

### ATTRIB

```
ATTRIB displays or changes file attributes.
```
**Syntax:**
```
ATTRIB { options | [drive][path]filename | /@[list] }
         drive     The drive letter, e.g. C:
         path      The directory, e.g. \example\
         filename  The file, e.g. test.exe
```
**Options:**
```
+A  Sets the Archive attribute.
  -A  Clears the Archive attribute.
  +H  Sets the Hidden attribute.
  -H  Clears the Hidden attribute.
  +R  Sets the Read-only attribute.
  -R  Clears the Read-only attribute.
  +S  Sets the System attribute.
  -S  Clears the System attribute.
  /@  Process files, listed in the specified file [or in stdin].
  /D  Process directory names for arguments with wildcards.
  /S  Process files in all directories in the specified path(es).
  /?  Shows the help.
```

## Additional Commands

These commands are specific to this app and are not part of standard FreeDOS.

### R (Read from Host)

Copies a file from your device (iPad/Mac) into DOS.

```
R <host-filename> <dos-path>
```

### W (Write to Host)

Copies a file from DOS to your device.

```
W <dos-path> <host-filename>
```

### NET

Loads the NE2000 network driver and gets an IP address via DHCP.

```
NET
```

After running NET, FTP, TELNET, PING, and HTGET are available.

---

Reference: FreeDOS Help Project (https://github.com/FDOS/help), licensed under GFDL.