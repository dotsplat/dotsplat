#!/bin/bash
function help {
	if [[ $1 ]]; then
		extended_help $1
		exit $EX_SUCCESS
	fi
printf "homes${bldblu}h${txtdef}ick uses git in concert with symlinks to track your precious dotfiles.

 Usage: dotsplat [options] TASK

 Tasks:
  dotsplat cd CASTLE                 # Enter a castle
  dotsplat clone URI..               # Clone URI as a castle for dotsplat
  dotsplat generate CASTLE..         # Generate a castle repo
  dotsplat list                      # List cloned castles
  dotsplat check [CASTLE..]          # Check a castle for updates
  dotsplat refresh [DAYS] [CASTLE..] # Check if a castle needs refreshing
  dotsplat pull [CASTLE..]           # Update a castle
  dotsplat link [CASTLE..]           # Symlinks all dotfiles from a castle
  dotsplat track CASTLE FILE..       # Add a file to a castle
  dotsplat help [TASK]               # Show usage of a task

 Aliases:
  symlink # Alias to link
  updates # Alias to check

 Runtime options:
   -q, [--quiet]    # Suppress status output
   -s, [--skip]     # Skip files that already exist
   -f, [--force]    # Overwrite files that already exist
   -b, [--batch]    # Batch-mode: Skip interactive prompts / Choose the default

 Note:
  To check, refresh, pull or symlink all your castles
  simply omit the CASTLE argument

"
}

function help_err {
	extended_help $1
	exit $EX_USAGE
}

function extended_help {
	case $1 in
		cd)
      printf "Enters a castle's home directory.\n"
      printf "NOTE: For this to work, dotsplat must be invoked via dotsplat.{sh,csh}.\n\n"
      printf "Usage:\n  dotsplat cd CASTLE"
      ;;
		clone)
      printf "Clones URI as a castle for dotsplat\n"
      printf "Usage:\n  dotsplat clone URL.."
      ;;
		generate)
      printf "Generates a repo prepped for usage with dotsplat\n"
      printf "Usage:\n  dotsplat generate CASTLE.."
      ;;
		list)
      printf "Lists cloned castles\n"
      printf "Usage:\n  dotsplat list"
      ;;
		check|updates)
      printf "Checks if a castle has been updated on the remote\n"
      printf "Usage:\n  dotsplat $1 [CASTLE..]"
      ;;
    refresh)
      printf "Checks if a castle has not been pulled in DAYS days.\n"
      printf "The default is one week.\n"
      printf "Usage:\n  dotsplat refresh [DAYS] [CASTLE..]"
      ;;
		pull)
      printf "Updates a castle. Also recurse into submodules.\n"
      printf "Usage:\n  dotsplat pull [CASTLE..]"
      ;;
		link|symlink)
      printf "Symlinks all dotfiles from a castle\n"
      printf "Usage:\n  dotsplat $1 [CASTLE..]"
      ;;
		track)
      printf "Adds a file to a castle.\n"
      printf "This moves the file into the castle and creates a symlink in its place.\n"
      printf "Usage:\n  dotsplat track CASTLE FILE.."
      ;;
		help)
      printf "Shows usage of a task\n"
      printf "Usage:\n  dotsplat help [TASK]"
      ;;
		*)    help  ;;
		esac
	printf "\n\n"
}
