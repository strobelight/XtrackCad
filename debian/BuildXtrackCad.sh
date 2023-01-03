#!/bin/bash

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    set ""
    RUN_USAGE=yes
fi

JUST_BUILD=${2:-no}

#XtrackVer="V5.2.2"
XtrackVer="V5.2.2a"
#XtrackVer="default"

XtrackVer=${1:-$XtrackVer}

XtrackPath="$HOME/XtrackCAD/$XtrackVer"
XtrackSrc="$HOME/XtrackCAD/src"
XtrackBuildDir="$XtrackPath/build-dbg"
XtrackInstallPrefix="$XtrackPath/install-dbg"

function usage() {
    cat <<EOF
    $(basename $BASH_SOURCE) [ version ] [ skip-dependent-installs ]
    version defaults to $XtrackVer
    skip-dependent-install defaults to "$JUST_BUILD", enter "yes" to skip
EOF
}

if [ "$RUN_USAGE" = "yes" ]; then
    usage
    exit
fi

if [ $JUST_BUILD != "yes" ]; then
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
fi

echo "#############################################################"
echo "#    G E T   X T R A C K C A D   S O U R C E"
echo "#############################################################"

cmake --version
sleep 2

cd $HOME

if [[ -d $XtrackSrc ]]; then
    cd $XtrackSrc
    if ! hg incoming -q; then
        echo "No remote changes"
        read -p "Build anyway (y/n)? " -N 1 -t 2 YN
        echo
        if [ "$YN" != "y" ]; then
            exit
        fi
    fi
    hg pull http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad
else
    mkdir -p $XtrackSrc || exit
    hg clone http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad $XtrackSrc
    cd $XtrackSrc
fi
rm -rf $XtrackPath || exit
mkdir -p $XtrackBuildDir || exit
echo "Update for version $XtrackVer"
sleep 2
hg update $XtrackVer
cd $XtrackBuildDir || exit

# defining location of cmocka library resulted in compile errors of unit tests
#cmake -DCMAKE_BUILD_TYPE=Debug -DCMOCKA_LIBRARY=/usr/lib/aarch64-linux-gnu/libcmocka.so -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

make || exit
make install || exit

BETA=""
cd $XtrackInstallPrefix/bin
if [ -f xtrkcad-beta ]; then
    BETA="-beta"
fi

if [ -d $HOME/.local/share/applications ]; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local/bin
    cat <<-EOF > startXtrkCad_$XtrackVer
	#!/bin/bash
	unset LD_LIBRARY_PATH
	unset XTRKCADLIB
	EOF
    if [ "$XtrackVer" = "V5.2.2" -o "$XtrackVer" = "V5.2.2a" -o -n "$BETA" ]; then
    cat <<-EOF >> startXtrkCad_$XtrackVer
	# comment out if help works relative to current directory
	export XTRKCADLIB=$XtrackInstallPrefix/share/xtrkcad${BETA}
	EOF
    fi
    cat <<-EOF >> startXtrkCad_$XtrackVer
	cd $XtrackInstallPrefix/bin
	exec $XtrackInstallPrefix/bin/xtrkcad${BETA}
	EOF
    chmod +x startXtrkCad_$XtrackVer
    rm -f startXtrkCad
    ln -s startXtrkCad_$XtrackVer startXtrkCad
    cat <<-EOF > $HOME/.local/share/applications/xtrkcad_${XtrackVer}.desktop
	[Desktop Entry]
	Name=XTrackCAD_${XtrackVer}
	Comment=Design model railroad layouts
	Exec=$HOME/.local/bin/startXtrkCad_${XtrackVer}
	Icon=$XtrackInstallPrefix/share/xtrkcad${BETA}/logo.bmp
	Path=$XtrackInstallPrefix/bin
	Terminal=false
	Type=Application
	Categories=Graphics
	EOF
fi
