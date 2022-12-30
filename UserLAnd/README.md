# UserLAnd

[UserLAnd](https://play.google.com/store/apps/details?id=tech.ula&gl=US) is an open-source app which allows you to run several Linux distributions like Ubuntu,
Debian, and Kali.

Install from the Google play store on to your device, and launch it.

## Initial Setup
Choose `debian` as terminal/ssh session. A file system will be created and updated with debian goodness, which could take a while.

You should see a terminal on your device with a prompt, but we're not going to do anything here but simply type `exit` to close it. What this did was leave behind the password so we can ssh into it from a computer with a bigger screen.

In the app, at the bottom, select `Filesystems`, press and hold the apps entry, choose `Edit`, press the eyeball on the `Password` entry and write it down.

At bottom, choose `Sessions` and choose `debian` session to restablish the terminal session.

Find the IP of your device and use a computer on the same network to ssh into it `ssh -p 2022 userland@<your_IP>`, something like `ssh -p 2022 userland@192.168.1.123`, enter the password.

At this point, you're in your device running debian.

## Update and Install Lxde
Let's update and add stuff

```
sudo -i bash
apt -y update
apt -y upgrade
apt -y install screen
apt -y install vim-tiny
apt -y install udisks2
rm -f /var/lib/dpkg/info/udisks2.postinst
dpkg --configure udisks2
apt -y install lxde
exit
```

If you have an ssh public key, you can place it on the device for easier access going forward (not having to enter the password all the time)

```
cd
id  # ensure userland user
mkdir .ssh
cat <<EOF > .ssh/authorized_keys
<paste your ssh public key (should be a single line with at most 3 space-separated fields)>
EOF
```

Enable ssh when lxde starts:

```
id  # ensure userland user
mkdir -p $HOME/.vnc
cat <<EOF > $HOME/.vnc/xstartup
sudo pkill -f dropbear
sudo /usr/sbin/dropbear -p 2022
/usr/bin/startlxde
EOF
```

Now exit the session.

But odd, that when you exit, UserLAnd hasn't really stopped it.  So, press and hold the `debian` entry, and choose `Stop Session`.

## Start Lxde
At the bottom, choose the `Apps` tab, and then choose `Lxde` and you should see an X11 session with a terminal open. On your computer, you should be able to ssh into the device, (presuming you've followed the steps above) for any other customizations you want.

_If you got an error message about support for only a single session, tap on Sessions at bottom, press and hold each entry until you see **Stop Session** and select that to stop it, then try Lxde again._

As you tap on the device, you'll see an overlay with keyboard, buttons, ability to move the overlay around, and 3 dots. Those 3 dots let you choose how your finger touching on the device operate (input mode), and the ability to disconnect, so that you can stop the session.

When done, press and hold the session to stop it. If the UserLAnd icon on the status bar does not disappear, you may have to force stop it.

## Import, Export, Saving, etc
The `/storage/internal` and `/storage/sdcard` (if inserted) directories are available to import, export, save, load, files to/from the device to the app.

_**Saving files with the app filesystem will be gone if the app is ever removed.**_

