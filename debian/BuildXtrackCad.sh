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

#XtrackVer="V5.2.2"
XtrackVer="V5.2.2a"
#XtrackVer="default"

XtrackPath="$HOME/XtrackCAD/$XtrackVer"
XtrackSrc="$HOME/XtrackCAD/src"
XtrackBuildDir="$XtrackPath/build-dbg"
XtrackInstallPrefix="$XtrackPath/install-dbg"

cmake --version
sleep 2

cd $HOME
rm -rf $XtrackPath
mkdir -p $XtrackBuildDir

mkdir -p $XtrackSrc
hg clone http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad $XtrackSrc
cd $XtrackSrc
echo "Update for version $XtrackVer"
hg update $XtrackVer
cd $XtrackBuildDir

# defining location of cmocka library resulted in compile errors of unit tests
#cmake -DCMAKE_BUILD_TYPE=Debug -DCMOCKA_LIBRARY=/usr/lib/aarch64-linux-gnu/libcmocka.so -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

make || exit
make install || exit

if [ -d $HOME/.local/share/applications ]; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local/bin
    cat <<-EOF > startXtrkCad_$XtrackVer
	#!/bin/bash
	unset LD_LIBRARY_PATH
	unset XTRKCADLIB
	# comment out if help works relative to current directory
	export XTRKCADLIB=$XtrackInstallPrefix/share/xtrkcad
	cd $XtrackInstallPrefix/bin
	exec $XtrackInstallPrefix/bin/xtrkcad
	EOF
    chmod +x startXtrkCad_$XtrackVer
    ln -s -f startXtrkCad_$XtrackVer startXtrkCad
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
