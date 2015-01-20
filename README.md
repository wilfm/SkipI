SkipI
=====

Installer for SketchUp on Linux systems using Wine.
It should create a designated wineprefix, download and installs various prerequisistes such as wininet *(based on winetricks implementation)*, the sketchup installer *(from http://dl.trimble.com/sketchup/gsu8/FW-3-0-16846-EN.exe)*, and even a theme for wine *(http://aerilius.deviantart.com/art/Ubuntu-Light-Themes-12-10-327631977 - no option for themes as of yet)*

**System requirements**

This script is designed to run on most modern Linux systems - Debian, Ubuntu, Fedora, Arch, etc. It may run on other systems.
- Wine 1.5.4+ or above, with the main executable located in the system path (e.g. /usr/bin/wine)
- Network connection for downloading required packages.
- To run this script:
  - Bash (4+ preferably to run this script
  - Various external commands/packages - mktemp, wget, which, cabextract, unzip
- These are the minimum specs for running SketchUp 8
  - 1 GHz processor.
  - 512 GB RAM.
  - 500 MB of available hard-disk space.
  - 3D class Video Card with 128+ MB, supporting OpenGL v1.5+ . Some intel cards may have issues.
  - Licensing isn't supported over a Wide Area Network (WAN). Also, a windows license would need to be used.
- Fedora will need the 'wine-opencl' installed so the sketchup does contain a black screen.

**Usage**
 - Make this script executable, run it... no options yet

**Known bugs / required features**
 - set theme
 - only does sketchup 8, no options
 - won't work if wine is not in path
 - wget exits with error if file already exists - could check with sha1sum first
 - if sha1sum mismatch, offer to re-download the file (remove the file, run download command first)

Installation instructions
====

To use it, use the following commands for a Linux system:

    wget https://raw.githubusercontent.com/wilfm/SkipI/master/skipi.sh
    chmod +x skipi.sh
    ./skipi.sh

Note, you need to have the requriements above.
