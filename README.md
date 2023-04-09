NesToy32 is a program I developed between May of 2000 and July of 2000.  As of today, it is almost 23 years old.  It is written in Borland Delphi and is a successor to my NesToy application which was written in Turbo Pascal and was an MS-DOS application.

NesToy32 predates ROM managers such as Clrmamepro and Romcenter and, as far as I know, is one of the first of its kind.

I recently discovered the source code for NesToy32 on an old floppy disk and decided to upload it here for preservation.  I kept every revision of NesToy so I committed each revision as I would have if Github was a thing back then.

Below is an excerpt from the documentation included with the latest public release of NesToy32 (v1.1) from May 15, 2000 which is also available under Releases.  Many thanks to Zophar's Domain (https://www.zophar.net/) for keeping the archive online for all these years.  

-------------------------------------------------------------------------------------------------------

NesToy is a NES ROM management utility for your .NES Nintendo/Famicom
ROMs.  This program started out as a header information utility, but now,
using a database, can identify your NES ROMs and optionally repair any bad
headers it finds and rename the ROMs to full descriptive long file names.


** DO NOT DISTRIBUTE PRE-PATCHED ROMs unless they are your own work and
   you chose to distribute them that way.  A lot of work and effort is put
   into translating these games and all the author asks in return is that
   you distribute only the IPS patch in the original .zip with all
   documentation intact.  By distibuting pre-patched ROMs, the author
   is not getting the credit he or she deserves, and the person downloading
   the patch may not be aware of any issues concerning the patch that were
   detailed in the documentation.  NesToy will no longer display ANY
   translations or custom game hacks in the nesmiss.txt file to deter people
   from doing just this.  I would like to continue documenting these types
   of ROMs in NesToy so you can assure that you have applied the IPS patch
   to a good dump and the resulting ROM is correct.

   It has been pointed out to me that since NesToy has been released, the
   distribution of PRE-PATCHED ROMs on web sites, ftp sites, and in
   newsgroups has increased.  I WILL NOT HESITATE to remove any and all
   translations and game hacks from the database if this continues to be a
   problem.  It does not take any effort at all to distribute the original
   .zip's containing the IPS patches nor does it take any effort to apply
   them.  Plus, as an added bonus, it is completely legal to distribute the
   IPS patches and they are much smaller than the actual ROMs.


usage: NesToy.exe [parameters] pathname1 [pathname2] [pathname3] ...

Filenames can include wildcards (*,?) anywhere inside the filename.  Long
file names are allowed and if no filename is specified, (*.nes) is assumed.


Parameters
----------
  -b             Displays PRG and CHR information by # of blocks instead
                 of kB. (Example: Instead of 128kB, you would see 8x16kB)

  -c             Calculate Checksums (CRC-32).  All database operations
                 require this option and currently turn it on when used.
                 Additionally, one of the following will appear next to
                 the filename when -c is used.
                   * - ROM is identified and good.
                   ? - Unknown ROM
                   x - ROM is identified, but something is wrong with it.
                       Use -i for more information.
                   d - ROM is a duplicate
                   n - Name does not match ROM name in database
                   b - ROM is a bad dump

  -i             Outputs extended info if header or name are not correct.
                 If the information in a ROM's header does not match that
                 in the database, a second line of data will be displayed
                 illustrating the differences.  You will also see one of
                 the following.  
                   Bad [] - There is something wrong with the ROM.  Refer
                            to the codes inside the brackets for details.
                   Rep [] - The ROM has been repaired.
                   Ren [] - The ROM has been renamed.

                 Inside the brackets will contain one or more of the
                 following codes.
                   N - Name does not match that in database.
                   H - Header contains incorrect mapper info.
                   G - Header contains garbage.
                   T - There is trailing garbage at the end of the ROM.

                 If you see Can't Rename or Can't Repair, it means for
                 some reason, NesToy was unable to rename or repair the
                 ROM.

  -o[file]       Sends output to file. (DOS 8.3 filenames) If no filename
                 is specified, it defaults to output.txt.  If the file
                 exists, NesToy will append data to the end of the file.
 
  -ren[uscltp]   Renames ROMs to names stored in database (enables -c)
                   u- Replace spaces with underscores
                   s- Remove spaces completely from filename
                   c- Attach country codes to end of filenames
                   l- Convert ROMs to all lowercase names
                   t- Places the word "The" at the beginning of ROM names
                      instead of at the end.
                   p- Use periods in appropriate ROM names (Warning: Nesticle
                      will not load ROMs with extra periods in them.
                      Example: Dr Mario.nes would be named as Dr. Mario.nes

  -rep,-repair   Repairs ROM headers with those found in database (enables -c)
                 File is backed up before repair is made.

  -res,-resize   Automatically resizes ROMs if they contain duplicate or
                 unused banks of data. (enables -c).

  -ips           Patches a ROM if an appropriate IPS patch is found in the
                 fixfiles directory (Defined in nestoy.cfg.)  IPS patches are
                 named by the checksum of the ROM they are meant to patch.
  -m#
                 Filter listing by mapper #.  Example: if -m1 is used, only
                 ROMs with a mapper of 1 will be displayed.

  -f[hvbt4]      Filter listing by mapper data
                    h- Horizontal Mirroring     t- Trainer Present
                    v- Vertical Mirroring       4- 4 Screen Buffer
                    b- Contains SRAM (Battery backup)

  -u             Only display unknown ROMs (enables -c)
                 Only ROMs that are not found in the database will be
                 displayed.  If you have a ROM that you know is good, but
                 it is not in my database, please let me know so I can add
                 it to the database.

  -sub           Process all subdirectories under directories specified on
                 the path.  Scans up to six directories deep.

                 NesToy will alway skip over the duplicates directory in a
                 scan unless you directly specify it on the command line.

  -nobackup      Don't make backups before repairing or resizing ROMs.

  -log           Log to NESTOY.LOG any problems NesToy encounters while
                 sorting, renaming, or repairing ROMs.

  -missing[cbn]  Create a listing of missing ROMs.  If listing exists, it
                 will be updated.  Filename is defined in NESTOY.CFG.
                    c- Sort missing list by country
                    b- Bare listing (Name, country codes, and checksum only)
                    n- Force NesToy to create a new missing list, even if
                       one already exists (It will be overwritten.)

                 If a missing list already exists, NesToy will update the
                 list by removing any ROMs from the list that now exist.
                 NesToy will never add ROMs to the missing file, so when a
                 new release comes out with a database update, it is probably
                 a good idea to delete the missing file and have NesToy
                 create a new one to reflect the changes in the database.

                 You can adjust whether or not pirates, hacks, or bad dumps
                 are included in the output in the NESTOY.CFG file. 

  -sort[mb]      Sorts ROMs into directories by region or type.
                    m- Sorts ROMs by mapper # as well.
                    b- Sorts "Bad CHR" dumps into a CHR directory in the
                       Bad Dump directory.

                 North America   Japan        Europe           Asia 
                 U   (USA)       J   (Japan)  E   (Europe)     Asi (Asia)
                 Can (Canada)                 Fra (France) 
                                              Ger (Germany)
                                              Spa (Spain)
                                              Swe (Sweden)
                                              Ita (Italy)
                                              Aus (Australia)  

                 The following don't fall under any region
                    VS  - VS Unisystem\
                    P10 - Playchoice 10\
                    PD  - PD\ 
                    TR  - Translated\
                    GH  - Game Hacks\

                 Region codes are in order of priority.  In other words,
                 If a ROM is both U and J, it will go into USA\.

                 Bad dumps will go into Bad\, Hacked ROMs will go into
                 Hacked\ or Mapper Hacks\ depending on the type of hack.
                 Pirates will go into Pirate\.  You can also have these go
                 into their corresponding region directory instead.  Just
                 change the MOVE_BAD, MOVE_PIRATE, or MOVE_HACKED in the
                 NESTOY.CFG from TRUE to FALSE.

                 These are the default directories.  These can be changed
                 in the NESTOY.CFG (created the first time you run
                 NesToy.)

  -q[o]          Suppresses output to the screen (for those of you who
                 would prefer not to see what NesToy is up to.)
                    o- Suppresses output to the output file as well.

  -doall         Enables -c,-i,-ren,-repair,-resize,-sort, and -missing.

  -h,-?,-help    Displays the help screen

Paramters in brackets are optional.  Do not include the brackets when using
these paramaters.  Example:  You would use -missingc, not -missing[c].

All pathnames will be processed in the order they are entered on the
command line.  you may abort the program at any time by pressing ESC.  NesToy
will stop on the ROM it is at and then quit.  You can add command line
parameters, including pathnames, to the NESTOY.CFG file.


NESTOY.CFG
----------
You can assign the directories NesToy will sort your ROMs into if the -sort
command line option is used with the following entries.  Default entries are
shown.

  DIR_BASE =                         DIR_MAPHACKS = Mapper Hacks\
  DIR_ASIA = Asia\                   DIR_NORTHAMERICA = North America\
  DIR_BACKUP = Backup\               DIR_OTHER = Other\
  DIR_BAD = Bad\                     DIR_PC10 = Playchoice 10\
  DIR_DUPLICATES = Dupes\            DIR_PD = PD\
  DIR_EUROPE = Europe\               DIR_PIRATE = Pirate\
  DIR_GAMEHACKS = Game Hacks\        DIR_TRANS = Translated\
  DIR_HACKED = Hacked\               DIR_UNKNOWN = Unknown\
  DIR_JAPAN = Japan\                 DIR_VS = VS Unisystem\

DIR_BASE sets the base directory all the other directories will fall under.
If DIR_BASE is left empty, the base directory will default to the current
directory you run NesToy from.  DIR_BASE will only affect relative pathnames.
For example, if DIR_BASE is set to C:\ROMS\ and DIR_USA is set to USA\, then
DIR_USA will be expanded to C:\ROMS\USA\.  However, if DIR_USA is set to
something similar to C:\ROMS2\USA\, it will not be affected by DIR_BASE.

  DIR_FIXFILES = fixfiles\
  DIR_SAVESTATES =
  DIR_PATCHES =

DIR_FIXFILES should be set to the directory where the FixFiles (in .ips
format) are located.  These are available in a separate archive on the
NesToy website.  FixFiles are used by NesToy to automatically repair the
majority of the bad dumps in the NesToy database.

DIR_SAVESTATES should be set to your battery backup/savestate directory.
When renaming ROMs, NesToy will automatically rename any matching .SAV and
.ST* files it finds in this directory.  Leaving this entry empty will
disable this feature.

DIR_PATCHES should be set to your patches directory.  This works the same
as the DIR_SAVESTATES option, except NesToy will rename any matching .PAT
files in this directory.

MOVE_BAD = TRUE         Determine where NesToy will move bad dumps, pirates,
MOVE_HACKED = TRUE      and hacks when the -sort command line option is used.
MOVE_PIRATE = TRUE      If set to TRUE, bad dumps will be moved into the
                        DIR_BAD directory, pirates will be moved into the
                        DIR_PIRATE directory, and hacks will be moved into the
                        appropriate hack directory (DIR_GAMEHACKS, DIR_HACKED,
                        or DIR_MAPHACKS.)  If set to FALSE, ROMs will be moved
                        into their corresponding region directory instead.

SORT_TRANS = TRUE       Determines whether translations will be sorted into
                        sub directories by language in the translations
                        directory.

SORT_UNLICENSED = TRUE  Determines whether unlicensed ROMs will be sorted into
                        a sub directory called "Unlicensed" in the appropriate
                        region directory.

MISSING_BAD = FALSE     Determine what NesToy will include in the nesmiss.txt
MISSING_HACKED = TRUE   file when the -missing command line option is used. 
MISSING_PIRATE = TRUE   A setting of TRUE means ROMs of that type will be
                        included in the missing list.  If set to FALSE, ROMs
                        of that type will not be included.
                        
PARAM_MISSING = [cbn]   Default parameters can be assigned to be used with
PARAM_REN = [uscltp]    the -missing and -ren command line options with these
                        settings.  Valid parameters are shown in brackets.
                        These parameters are described in the "parameters"
                        section of these docs.

SHORT_NAMES = FALSE     Determines whether shorter names will be used for
                        some game titles.  (Example: if set to TRUE, instead
                        of "Zelda 2 - The Adventure of Link.nes", the ROM will
                        just be named "Zelda 2.nes")

JOLIET = FALSE          When set to TRUE, game titles over 64 characters in
                        length will automatically use their short name.  Use
                        this option when burning ROMs to a CD because the
                        joliet standard limits files to 64 characters in
                        length.

TAG_UNLICENSED = FALSE  Determines whether unlicensed ROMs will have (Unl)
                        attached to the end of the ROM name.

NO_BACKUP = FALSE       When set to TRUE,  has the same effect as the
                        -nobackup command line parameter


Output
------
* Zelda 2 - The Adventure of Link.nes       1 HB..  128kB  128kB  U  ba322865
|                 |                         | ||||    |      |    |     |
1                 2                         3 4567    8      9   10    11

 1 - ROM Status
     * - ROM is identified and good.
     ? - Unknown ROM
     x - ROM is identified, but something is wrong with it.
         Use -i for more information.
     d - ROM is a duplicate
     n - Name does not match ROM name in database
     b - ROM is a bad dump
 2 - File Name
 3 - Mapper #
 4 - Mirroring (H- Horizontal, V- Vertical)
 5 - Battery (SRAM)
 6 - Trainer Present
 7 - 4-Screen Buffer
 8 - Size of Program ROM (PRG)
 9 - Size of Character ROM (CHR)
10 - Country Code or ROM Type
       North America   Japan         Europe           Asia
       U   (USA)       J   (Japan)   E   (Europe)     Asi (Asia)
       Can (Canada)                  Fra (France) 
                                     Ger (Germany)
                                     Spa (Spain)
                                     Swe (Sweden)
                                     Ita (Italy)
                                     Aus (Australia)  
      
     ROM Types: P10 - Playchoice-10    TR  - Translation
                VS  - VS. Unisystem    GH  - Game Hack
                PD  - Public Domain

     A '@' next to the country code means its an unlicensed ROM.

11 - Checksum (CRC-32)

If (-c) is not used, 1, 10, and 11 will not be displayed.


Known issues
------------
* When NesToy is resizing (Wrong Size) ROMs, sometimes the result will still
  be marked with (Wrong Size).  Just run NesToy again on this ROM.  There are
  a handful of ROMs that need to be resized multiple times before they are
  reduced to their correct size.

* If you do not create a new missing file with each new release, any database
  additions made will not show up on the list.

* Bad dumps are not included by default in the missing ROMs listing.  You
  must set the appropriate options in the NESTOY.CFG to TRUE and then create
  a new missing list for these to show up.  Translations and Game Hacks will
  never show up in the nesmiss.txt file.

* Bad Dumps automatically detected by NesToy that are not in the database
  will never show up on the missing list.  NesToy uses several methods to
  identify corrupt ROMs, even if they are unknown to NesToy.

* Game Hacks not in NesToy's database may be flagged as (Bad CHR).  Please
  submit these to digitoxin@mindspring.com so that I may add them to
  NesToy's database.  

* When NesToy is moving and/or renaming a ROM, sometimes it encounters a ROM
  already there with the same name.  NesToy will first try to attach a
  country code to the ROM it is moving to differentiate it.  If that fails,
  NesToy will be unable to move/rename the ROM.  You will usually encounter
  this if you are using the same directory to store Japanese and USA ROMs or
  if you have unknown or misplaced ROMs in the destination directory.

* Remember, even though NesToy -doall invokes the default settings for
  -missing and -ren, you can still specify your own settings for these
  options on the command line or in the nestoy.cfg file.
  Example: NesToy -doall -renc will rename all your ROMs with country codes
  attached while still performing all the other options invoked by (-doall)
  normally.  

* NesToy has an internal limit of 4000 files per directory.  If you have
  more than 4000 files in a directory, NesToy will only process up to the
  4000th file.  If you have NesToy set to sort the ROMs it processes into
  different directories, you can just run NesToy again to process the
  remaining ROMs.


Differences between Pirates and Hacks
-------------------------------------
A pirated ROM is a ROM where the title and/or copyright information has been
altered, defaced, or removed.  Multi-Carts (ROMs containing multiple games)
are also considered pirates.  If anything else has modified in the ROM, then
it is considered a hack.  NesToy defines 3 different types of hacks.

  Mapper Hack - The ROM has been hacked to run under a different mapper.
  Game Hack   - The games graphics and/or program code has been significantly
                modified to change the look and gameplay of the game.
                Examples are the countless Super Mario Bros. hacks that exist
                on the web.
  Other Hacks - Any other type of hack that is not a pirate and does not fit
                in one of the above categories.  Trained ROMs fall into this
                category.


Mapper Information
------------------
There are several games set to mapper 118 that were previously set to mapper
4.  Mapper 118 seems to be similar to mapper 4, and although these games
never worked right under mapper 4 in any emulator, they do work when set to
mapper 118 in Famstasia which seems to emulate this mapper the best.  FwNES
also emulates mapper 118 partially.  Mapper 118 may not be the correct
mapper for these games, but currently they work best under this mapper.
These games are listed below.

  Alien Syndrome (U)
  Arumajiro (J)
  Goal! Two (U)
  Goal! Two (E)
  NES Play Action Football (U)
  Pro Sport Hockey (U)
  Ys 3 - Wanderers From Ys (J)


About bad dumps
---------------
Valid PRG sizes:   16,32,64,128,256,512,640,1024,1536,2048
Valid CHR sizes: 8,16,32,64,128,256,512,1024

If you have a ROM with values other than those listed above, it is a bad
dump.  Check the ROM list distributed with NesToy to see what the correct
size for the ROM is.  NesToy will detect these ROMs and mark them as bad.

Dragon Warrior 4 (Wrong Size)               1 HB.. 1024kB  -----  U  41413b06

This ROM is the wrong size.  The correct Dragon Warrior 4 ROM is 512kb, but
you may want to hold onto this one because Nesticle won't run the correct
ROM, but it plays this one fine.  NesToy cannot resize the 1024kb version of
this ROM to 512kb because of the unusual way data is duplicated in the ROM.
