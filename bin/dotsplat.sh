# This helper script should be sourced via an alias, e.g.
#
#   alias dotsplat="source $HOME/.dotsplat.git/bin/dotsplat.sh"
#
# Use portable syntax to accommodate as many Bourne-family shells as possible.
cat >&2 <<EOM
You are invoking dotsplat by sourcing bin/dotsplat.sh
This method of invocation is deprecated and will soon be removed.
Please consider adding \`source \$HOME/.dotsplat.git/dotsplat.sh'
to your .bashrc or .zshrc instead, this will define a dotsplat() function
that you can run instead.
(Read more here: https://github.com/andsens/homeshick/issues/57)
EOM
if [ "$1" = "cd" ] && [ -n "$2" ]; then
    if [ -d "$HOME/.dotsplat/repos/$2/home" ]; then
        cd "$HOME/.dotsplat/repos/$2/home"
    else
        cd "$HOME/.dotsplat/repos/$2"
    fi
else
    $HOME/.dotsplat.git/bin/dotsplat "$@"
fi
