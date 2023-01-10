#!/bin/bash

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    set ""
    RUN_USAGE=yes
fi

JUST_BUILD=${2:-no}
NO_UPDATE=${3:-no}

#XtrackVer="V5.2.2"
XtrackVer="V5.2.2a"
#XtrackVer="default"

XtrackVer="${1:-$XtrackVer}"

NoBlankVer=$(echo "$XtrackVer" | tr -d -c -- '-_[:alnum:]')

XtrackPath="$HOME/XtrackCAD/$NoBlankVer"
XtrackSrc="$HOME/XtrackCAD/src"
XtrackBuildDir="$XtrackPath/build-dbg"
XtrackInstallPrefix="$XtrackPath/install-dbg"

function usage() {
    cat <<-EOF
	$(basename $BASH_SOURCE) [ version ] [ skip-dependent-installs ] [ no-update ]
	version defaults to "$XtrackVer"
	skip-dependent-install defaults to "$JUST_BUILD", enter "yes" to skip
	no-update defaults to "$NO_UPDATE", enter "yes" to leave current src tree alone

	add quotes around version if it contains blanks

	EOF
    if [[ -d $XtrackSrc ]]; then
        echo "Recent versions:"
        echo
        cd $XtrackSrc
        hg tags --pager never | sed 's/tip    /default/' | head -10
    fi
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
    if ! hg incoming -b "$XtrackVer" -q --pager never; then
        echo "No remote changes"
        read -p "Build anyway (y/n)? " -N 1 -t 2 YN
        echo
        if [ "$YN" != "y" ]; then
            exit
        fi
    fi
    if [ $NO_UPDATE != "yes" ]; then
        hg pull http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad
    fi
else
    mkdir -p $XtrackSrc || exit
    hg clone http://hg.code.sf.net/p/xtrkcad-fork/xtrkcad $XtrackSrc
    cd $XtrackSrc
fi
rm -rf $XtrackPath || exit
mkdir -p $XtrackBuildDir || exit
if [ $NO_UPDATE != "yes" ]; then
    echo "Update for version $XtrackVer"
    sleep 2
    hg update "$XtrackVer"
fi
cd $XtrackBuildDir || exit

# defining location of cmocka library resulted in compile errors of unit tests
#cmake -DCMAKE_BUILD_TYPE=Debug -DCMOCKA_LIBRARY=/usr/lib/aarch64-linux-gnu/libcmocka.so -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$XtrackInstallPrefix -DCMAKE_C_FLAGS=-Wpointer-sign -DXTRKCAD_USE_GETTEXT=ON $XtrackSrc

# reduce inkscape output
mkdir -p ~/.config/inkscape/fonts
sudo mkdir -p /usr/share/inkscape/fonts

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
    cat <<-EOF > startXtrkCad_$NoBlankVer
	#!/bin/bash
	unset LD_LIBRARY_PATH
	unset XTRKCADLIB
	EOF
    if [ "$NoBlankVer" = "V5.2.2" -o "$NoBlankVer" = "V5.2.2a" -o -n "$BETA" ]; then
    cat <<-EOF >> startXtrkCad_$NoBlankVer
	# comment out if help works relative to current directory
	export XTRKCADLIB=$XtrackInstallPrefix/share/xtrkcad${BETA}
	EOF
    fi
    cat <<-EOF >> startXtrkCad_$NoBlankVer
	cd $XtrackInstallPrefix/bin
	exec $XtrackInstallPrefix/bin/xtrkcad${BETA}
	EOF
    chmod +x startXtrkCad_$NoBlankVer
    rm -f startXtrkCad
    ln -s startXtrkCad_$NoBlankVer startXtrkCad
    cat <<-EOF > $HOME/.local/share/applications/xtrkcad_${NoBlankVer}.desktop
	[Desktop Entry]
	Name=XTrackCAD_${NoBlankVer}
	Comment=Design model railroad layouts
	Exec=$HOME/.local/bin/startXtrkCad_${NoBlankVer}
	Icon=$XtrackInstallPrefix/share/xtrkcad${BETA}/logo.bmp
	Path=$XtrackInstallPrefix/bin
	Terminal=false
	Type=Application
	Categories=Graphics
	EOF
fi
