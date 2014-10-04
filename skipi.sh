#!/bin/bash
#SKPi (SKetchuP Installer)
#VERSION=20140731
#
#This is a script so SketchUp can be installed and configured easily.
#
#SYSTEM REQUIREMENTS
# This script is designed to run on most modern Linux systems - Debian, Ubuntu, Fedora, Arch, etc. It may run on other Unix based systems
# - Wine 1.5.4+ or above, with the main executable located in the system path (e.g. /usr/bin/wine)
# - Network connection for downloading required packages.
# - To run this script:
#    - Bash (4+ preferably to run this script
#    - Various external commands/packages - mktemp, wget, which, cabextract, unzip
# - These are the minimum specs for running SketchUp 8
#    - 1 GHz processor.
#    - 512 GB RAM.
#    - 500 MB of available hard-disk space.
#    - 3D class Video Card with 128+ MB, supporting OpenGL v1.5+ . Some intel cards may have issues.
#    - Licensing isn't supported over a Wide Area Network (WAN). Also, a windows license would need to be used.
#
#USAGE
# - Make this script executable, run it... no options yet
#
#KNOWN BUGS / REQUIRED FEATURES 
# - set theme
# - only does sketchup 8, no options
# - won't work if wine is not in path
# - wget exits with error if file already exists - could check with sha1sum first
# - if sha1sum mismatch, offer to re-download the file (remove the file, run download command first)

#OPTIONS - Here you can set some of the options used in this script - wrap the variables in "quotes"
	export WINEARCH="win32" #DEFAULT: "win32" - Set what architecture Wine uses - apparently crashes less as 32 bit.
	export WINEPREFIX="${HOME}/.sketchup8" #DEFAULT: "$HOME/.sketchup" - Set root directory for where SketchUp etc is installed
	SKP_CACHE_DIR="${HOME}/.cache/skipi" #DEFAULT: "${HOME}/.cache/skipi" - Where to download the required packages to
	
	#Stuff for downloading a package to fix network errors
	SKP_WININET="1" #DEFAULT: "1" - set to "1" to download and install 'MS Windows Internet API'. 
	SKP_WININET_URL="http://download.microsoft.com/download/E/6/A/E6A04295-D2A8-40D0-A0C5-241BFECD095E/W2KSP4_EN.EXE"
	SKP_WININET_BASENAME="$(basename "${SKP_WININET_URL}")"
	SKP_WININET_SHA1="fadea6d94a014b039839fecc6e6a11c20afa4fa8"

	#Stuff for downloading the exe windows installer - can be sourced from http://www.sketchup.com/download/all
	SKP_INSTALLER_URL="http://dl.trimble.com/sketchup/gsu8/FW-3-0-16846-EN.exe" #DEFAULT: "http://dl.trimble.com/sketchup/gsu8/FW-3-0-16846-EN.exe"
	SKP_INSTALLER_BASENAME="$(basename "${SKP_INSTALLER_URL}")"
	SKP_INSTALLER_SHA1="6c9a61fe12b21fe9a1d6b5ee1bb79f331a5fc36c"
	
	#Theme for Wine - from http://aerilius.deviantart.com/art/Ubuntu-Light-Themes-12-10-327631977
	SKP_THEME_URL="http://fc06.deviantart.net/fs70/f/2012/262/3/d/ubuntu_light_themes_12_10_by_aerilius-d5f2ag9.zip"
	#SKP_THEME_URL="https://dl.dropboxusercontent.com/s/up3f5ezxp6giawq/ubuntu_light_themes_12_10_by_aerilius-d5f2ag9.zip" #backup link
	SKP_THEME_SHA1="1b13673b5b2e892a1eb11f40239a8249d4629327"
	SKP_THEME_BASENAME="$(basename "${SKP_THEME_URL}")"
	SKP_THEME_NAME="UbuntuLight12.10"
	SKP_THEME_EXTRACTED="ubuntu_light_themes_12_10_by_aerilius-d5f2ag9"
	
	
	#To stop 'unable to initialize OpenGl' error, this should be set to "1". Any other (sensible) value (just use "0"...) and it will be ignored.
	SKP_8_HW_OK="1" #DEFAULT: "1" 0 

#FUNCTIONS
skp_error() {
	echo -e "\033[31mError: $@\033[0m" >&2 
}

skp_echo() {
	echo -ne "\033[0m$@\033[33m"
}


skp_download() {
#	#$1 = link ; $2 sha1sum
	echo -en "\033[33m"
	wget -nd -c "$1" || skp_error "Download failed"
	echo -e "\033[0m"

}
	WINE="$(which wine 2>/dev/null)"

#SCRIPT
	if [ -e "${WINEPREFIX}" ]; then
	#	skp_overwrite_check
		skp_error "WINEPREFIX already exists, exiting"
		exit 1
	fi
	

	#if NO OPTIONS
	# echo "Are you sure you just want to install SketchUp, and not specify any options?"
	
	if [ -x "${WINE}" ]; then echo "Wine executable found at '${WINE}'"
	else skp_error "Wine does no appear to be installed"
	echo -e "Wine needs to be installed to install SketchUp.\nYou can find out how to download and install Wine here:\n    http://www.winehq.org/site/download"
	exit 1
	fi
	
	#checks for wget, cabextract etc
	
	
	#Here is a rather bad way to check whether it is connected to the internet
	#ping -w 1 -c 1 $(ip r | grep default | cut -d ' ' -f 3) && net=1 || 

	mkdir "${SKP_CACHE_DIR}"
	cd "${SKP_CACHE_DIR}" #keeps it simple
#----
	skp_echo "Updating wine configuration - setting ${WINEPREFIX} as the config directory..."
		#To update the wine configuration
		wineboot 2> /dev/null
	skp_echo "done\n"
#----
	#Based on the great winetricks script (winetricks wininet). Shouldn't need to check whether it exists already as this should be a new wine config directory
	skp_echo "Downloading 'MS Windows Internet API'...\n"
		skp_download "${SKP_WININET_URL}" "${SKP_WININET_SHA1}"
	skp_echo "Extracting...\n"
		cabextract -d "${WINEPREFIX}/dosdevices/c:/windows/temp/_wininet" -L -F "i386/wininet.dl_" "${SKP_CACHE_DIR}/${SKP_WININET_BASENAME}"
		cabextract --directory="${WINEPREFIX}/dosdevices/c:/windows/system32" "${WINEPREFIX}/dosdevices/c:/windows/temp/_wininet/i386/wininet.dl_"
	skp_echo "Using native,builtin override for following DLLs: wininet"
		SKP_WININET_REG_FILE="$(mktemp)"
		echo -e 'REGEDIT4\n\n[HKEY_CURRENT_USER\Software\Wine\DllOverrides]\n"*wininet"="native,builtin"\n' > ${SKP_WININET_REG_FILE}
		wine regedit ${SKP_WININET_REG_FILE} 2> /dev/null
		rm ${SKP_WININET_REG_FILE}
		unset SKP_WININET_REG_FILE
	skp_echo "done\n"
#-----
	skp_echo "Downloading SketchUp installer... \n"
		skp_download "${SKP_INSTALLER_URL}" "${SKP_INSTALLER_SHA1}"

	skp_echo "Running SketchUp installer... "
	#using `wine start /unix ....` would mean that it would skip to the next step even if the installer has not finished...
	wine "FW-3-0-16846-EN.exe" 2> /dev/null
	skp_echo "done\n"
	
	if [ "${SKP_8_HW_OK}" = "1" ]; then
	skp_echo "Setting Registry settings - changing 'HKEY_CURRENT_USER\Software\Google\SketchUp8\GLConfig\Display\HW_OK' to '1' "
		SKP_8_REG_FILE="$(mktemp)"
		echo -e 'REGEDIT4\n\n[HKEY_CURRENT_USER\Software\Google\SketchUp8\GLConfig\Display]\n"FIRST_TIME"=dword:00000001\n"HW_OK"=dword:00000001\n' > ${SKP_8_REG_FILE}
		wine regedit ${SKP_8_REG_FILE} 2> /dev/null
		rm ${SKP_8_REG_FILE}
		unset SKP_8_REG_FILE
	skp_echo "done\n"
	fi
	
	#read -p "Do you want to download a theme for Wine [y/N]?" SKP_THEME_OPT	
		skp_echo "Downloading '${SKP_THEME_NAME}' theme"
			skp_download "${SKP_THEME_URL}" "${SKP_THEME_SHA1}"
		skp_echo "Extracting...\n"
			unzip ${SKP_THEME_BASENAME} -d "${WINEPREFIX}/drive_c/Program Files/"
		skp_echo "Theme download to 'C:/Program Files/${SKP_THEME_EXTRACTED}' - in winecfg, select 'Desktop Integration', 'Install Theme'.\nIf you want to install it, go to 'My Computer', 'C:', 'Program Files', then '${SKP_THEME_EXTRACTED}'. Then find & select the file ending with '*.msstyles'. Once it has installed, select the Theme form the drop-down menu, and press 'OK'.\n"
		wine winecfg 2> /dev/null
		
		
	
	echo -e "\033[0mFinished"

#CLEAN-UP
echo -ne "\033[0m"
unset WINEARCH
unset WINEPREFIX
#everything beginning with SKP
unset SKP_INSTALLER_URL
unset SKP_8_HW_OK
cd "$HOME"

exit
