# This helper script should be sourced via an alias, e.g.
#
#   alias dotsplat "source $HOME/.dotsplat.git/bin/dotsplat.csh"
#
if ( "$1" == "cd" && "x$2" != "x" ) then
    if ( -d "$HOME/.dotsplat/repos/$2/home" ) then
        cd "$HOME/.dotsplat/repos/$2/home"
    else
        cd "$HOME/.dotsplat/repos/$2"
    endif
else
    $HOME/.dotsplat.git/bin/dotsplat $*
endif
