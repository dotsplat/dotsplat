# This script should be sourced in the context of your shell like so:
# source $HOME/.dotsplat.git/dotsplat.sh
# Once the dotsplat() function is defined, you can type
# "dotsplat cd CASTLE" to enter a castle.

function dotsplat() {
	if [ "$1" = "cd" ] && [ -n "$2" ]; then
		cd "$HOME/.dotsplat/repos/$2"
	else
		$HOME/.dotsplat.git/bin/dotsplat "$@"
	fi
}
