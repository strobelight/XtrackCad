#!/bin/bash

BASE_DIR="$HOME/XtrackCAD"
DOC_DIR="$BASE_DIR/src/app/doc"

cd "$DOC_DIR" || exit
VER=$(hg branch)

BETA=""
if [ "$VER" = "default" ]; then
    BETA="-beta"
fi

WORKING_DIR="$BASE_DIR/$VER/install-dbg/share/xtrkcad${BETA}/html"
HELP_DIR="$BASE_DIR/$VER/build-dbg/app/help"

cd $HELP_DIR || exit
cd "$DOC_DIR" || exit

extract() {
    grep '^\\[ACHS]' $1 |\
    sed \
        -e 's/^\\[ACHS][0-9]*{//' \
        -e 's/}.*//' \
        -e '/^$/d' \
        -e 's/$/.html/' ;
}

# extract .html refs
FILES="\
contents.html \
`extract intro.but.in` \
`extract addm.but` \
`extract changem.but` \
`extract drawm.but` \
`extract editm.but` \
`extract filem.but` \
`extract helpm.but` \
`extract hotbar.but` \
`extract macrom.but` \
`extract managem.but` \
`extract optionm.but` \
`extract statusbar.but` \
`extract view_winm.but` \
`extract navigation.but` \
`extract appendix.but` \
`extract ${HELP_DIR}/messages.but` \
`extract upgrade.but` \
`extract warranty.but` \
IndexPage.html"

cd "$WORKING_DIR" || exit

TMPDIR=/tmp/makepdf$$
cleanup() {
    cd
    #ls -R $TMPDIR
    if [ "$TMPDIR" != "/tmp/makepdf" ]; then
        rm -rf $TMPDIR
    fi
    trap - 0 1 2 3 15 21 22
}

trap cleanup 0 1 2 3 15 21 22

# make copy of html files for modification
mkdir -p $TMPDIR
cp -R * $TMPDIR

cd $TMPDIR || exit

# remove previous/next/horizontal rules
sed -i '/Previous.*Next/d' *.html
sed -i 's/<hr>//g' *.html

echo $FILES | tr ' ' '\n' > files.txt

OUT="XTrackCAD_Users_Manual_${VER}.pdf"
rm -f $OUT

# prerequisite: depends on texlive
pandoc -o $OUT --variable geometry:margin=.5in,left=.8in,includefoot=true \
                  --variable fontfamily:sans \
                  --variable fontsize:12pt \
                  --file-scope \
                  $FILES

if [ -f $OUT ]; then
    mv $OUT $WORKING_DIR
    cd $WORKING_DIR
    echo "open $(pwd)/$OUT"
fi
