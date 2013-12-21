#!/bin/bash

function setup_dotsplat {
	local hs_repo=$DOTSPLAT.git/
	mkdir -p $hs_repo
	ln -s $(cd $SCRIPTDIR/..; printf "$(pwd)")/dotsplat.sh $hs_repo/dotsplat.sh
	ln -s $(cd $SCRIPTDIR/../bin; printf "$(pwd)") $hs_repo/bin
	ln -s $(cd $SCRIPTDIR/../utils; printf "$(pwd)") $hs_repo/utils
}
