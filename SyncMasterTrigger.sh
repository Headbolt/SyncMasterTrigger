#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	SyncMasterTrigger.sh
#	https://github.com/Headbolt/SyncMasterTrigger
#
#   This Script is designed for use in JAMF as a Login Script in a policy run at login,
#		that calls another Policy running a OneDrive Script by the same author.
#			Royal-Car-Settings.sh
#			https://github.com/Headbolt/Royal-Car-Settings
#		
#   - This script will ...
#			Check for the existance of a OneDrive folder and call a Relevant Policy
#
###############################################################################################################################################
#
# HISTORY
#
#	Version: 1.0 - 17/01/2020
#
#	- 17/01/2020 - V1.0 - Created by Headbolt
#
###############################################################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
UserName="$3" # Grab the Username of the current logged in user from built in JAMF variable #3
DefaultInstance="$4" # Grab the Default OneDrive Folder Name to be used from JAMF variable #4 eg OneDrive - Contoso
#
Pause="5"
elevate="YES"
ForeBack="BACKGROUND"
#
# Set the name of the script for later logging
ScriptName="append prefix here as needed - Login - OneDrive Settings"
#
###############################################################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# OneDrive Folder Search Function
#
OneDriveFolderSearch(){
#
/bin/echo Checking if OneDrive Folder Exists
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
GUID=$(sudo ls /Users/$UserName/Library/Application\ Support/OneDrive/settings/Business1/*.dat | rev | cut -c 5- | rev) # Get OneDrive Instance GUID.
IniFile=$(/bin/echo $GUID.ini) # Use GUID to locate .ini File
IniFileContents=$(cat "$IniFile") # Read contents of .ini file inot Variable
IFS='"' # Internal Field Seperator Delimiter is set to Double Quote (")
read -ra IniFileLines <<< "$IniFileContents" # Read File into array of lines split by the Double Quote (")
for i in "${IniFileLines[@]}" # Read in and Process each "Line"
	do
		LineSearch=$(/bin/echo $i | grep OneDrive) # Search each "Line" for the word OneDrive, should only be present on the line we want
		if [[ "$LineSearch" != "" ]] # If the "Line" is not blank then it will be the Line we are looking for
			then
				OneDriveFolderPath=$(echo $LineSearch) # Save the Target "Line" into a new Variable
		fi
done
#
IFS='/' # Internal Field Seperator Delimiter is set to Forward Slash (/)
read -ra OneDriveLines <<< "$OneDriveFolderPath" # Read path into array of lines split by the Forward Slash (/)
for i in "${OneDriveLines[@]}" # Read in and Process each "Line"
	do
		ODLineSearch=$(/bin/echo $i | grep OneDrive) # Search each "Line" for the word OneDrive, should only be present on the line we want
		if [[ "$ODLineSearch" != "" ]] # If the "Line" is not blank then it will be the Line we are looking for
			then
				OneDriveFolder=$(echo $ODLineSearch) # Save the Target "Line" into a new Variable
		fi
done
unset IFS # Reset the Internal Field Separator to normal
#
if [[ "$OneDriveFolder" != "" ]]
	then
		/bin/echo OneDriveFolder Found
		/bin/echo $OneDriveFolder
	else
		/bin/echo OneDriveFolder Not Found
fi
#
}
#
###############################################################################################################################################
#
# Call OneDrive Policy Function
#
CallOneDrivePolicy(){
#
/bin/echo Pausing $Pause Seconds, then running all Policies with the Trigger '"'$Trigger'"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
if [ "${elevate}" == YES ]
	then
		Elevate=sudo
		/bin/echo "Running Commands Elevated"
		/bin/echo # Outputting a Blank Line for Reporting Purposes
	else
		Elevate=""    
fi

if [ "${ForeBack}" == "FOREGROUND" ]
	then
		FB=""
		/bin/echo "Running Commands in the Foreground"
		/bin/echo # Outputting a Blank Line for Reporting Purposes
	else
		FB='&'
		/bin/echo "Running Commands in the Background"
		/bin/echo # Outputting a Blank Line for Reporting Purposes
fi
#
Command=$(/bin/echo sleep $Pause's' '&&' $Elevate /usr/local/bin/jamf policy -trigger '"'$Trigger'"' $FB)
#
/bin/echo "$Command"
#
eval "$Command"
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
/bin/echo Ending Script '"'$ScriptName'"'
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
#
# Beginning Processing
#
###############################################################################################################################################
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
SectionEnd
#
OneDriveFolderSearch
SectionEnd
#
if [[ "$OneDriveFolder" != "" ]]
	then
		Trigger="$OneDriveFolder"
		CallOneDrivePolicy
	else
		Trigger="$DefaultInstance"
		CallOneDrivePolicy
fi
#
SectionEnd
#
ScriptEnd
