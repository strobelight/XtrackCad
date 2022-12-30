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
