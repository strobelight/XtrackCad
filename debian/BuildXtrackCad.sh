#!/bin/bash
sudo apt -y install mercurial
sudo apt -y install tortoisehg
sudo apt -y install python3-iniparse
sudo apt -y install cmake cmake-curses-gui
sudo apt -y install libzip4 libzip-dev
sudo apt -y install libmxml-dev libmxml1
sudo apt -y install inkscape libfreeimage-dev
sudo apt -y install libgtk2.0-dev
sudo apt -y install pandoc
sudo apt -y install libcmocka-dev

echo "#############################################################"
echo "#    G E T   X T R A C K C A D   S O U R C E"
echo "#############################################################"

XtrackPath="$HOME/XtrackCAD/V5.2.2"
XtrackVer="$(basename $XtrackPath)"
XtrackInstallPrefix="$XtrackPath/install-dbg"

cd $HOME
rm -rf $XtrackPath
mkdir -p $XtrackPath/build-dbg
cd $XtrackPath || exit
hg clone http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad src
cd src
echo "Update for version $XtrackVer"
hg update $XtrackVer
cd ../build-dbg

# defining location of cmocka library resulted in compile errors of unit tests
#cmake -DCMAKE_BUILD_TYPE=Debug -DCMOCKA_LIBRARY=/usr/lib/aarch64-linux-gnu/libcmocka.so -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON ../src

cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON ../src

make || exit
make install || exit

if [ -d $HOME/.local/share/applications ]; then
    mkdir -p $HOME/.local/bin
    cat <<-EOF > $HOME/.local/bin/startXtrkCad
	#!/bin/bash
	unset LD_LIBRARY_PATH
	export XTRKCADLIB=$XtrackInstallPrefix/share/xtrkcad
	cd $XtrackInstallPrefix/bin
	exec $XtrackInstallPrefix/bin/xtrkcad
	EOF
    chmod +x $HOME/.local/bin/startXtrkCad
    cat <<-EOF > $HOME/.local/share/applications/xtrkcad.desktop
	[Desktop Entry]
	Name=XTrackCAD
	Comment=Design model railroad layouts
	Exec=$HOME/.local/bin/startXtrkCad
	Icon=$XtrackInstallPrefix/share/xtrkcad/logo.bmp
	Path=$XtrackInstallPrefix/bin
	Terminal=false
	Type=Application
	Categories=Graphics
	EOF
fi
