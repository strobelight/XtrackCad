# Build XtrackCad on Android Devices

## Prerequisite
Install the UserLAnd app with Lxde as documented in the UserLAnd directory of this repo.

## Steps
* copy the BuildXtrackCad.sh script to your device or sdcard (instead you can copy/paste later or scp it)
* start the lxde session
* ssh -p 2022 userland@<deviceIP>
* get the BuildXtrackCad.sh script to userland users' home directory 
  * eg, `cp /storage/sdcard/BuildXtrackCad.sh .`
  * copy / paste to vi session
* make script executable `chmod +x $HOME/BuildXtrackCad.sh`
* `$HOME/BuildXtrackCad.sh`

## Run
At the bottom left corner is the menu for apps to run. If the steps above are successful, you should find the XtrackCad app in the Graphics submenu.

## Saving plans
Unfortunately I dont have an sdcard to try, but it seems to me to be far easier to use an sdcard. Just insert the card, and export/save your track plans to `/storage/sdcard`.

Sure `storage/internal` is available, but seems harder to get to for access from another computer. Not all file management apps have access. One that does is `File Manager+` which asks for permissions to directories that an app normally shouldn't have access to.
