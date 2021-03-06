#!/bin/bash

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
	$DOTSPLAT_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$DOTSPLAT/repos/rc-files"
	rm -rf "$DOTSPLAT/repos/dotfiles"
	rm -rf "$DOTSPLAT/repos/module-files"
	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${DOTSPLAT}*" -delete
}


function testOverwritePrompt() {
	touch $HOME/.bashrc
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	assertTrue "\`link' overwrote .bashrc" "[ -f $HOME/.bashrc -a ! -L $HOME/.bashrc ]"
}

function testOverwriteSkip() {
	touch $HOME/.bashrc
	$DOTSPLAT_FN --skip link rc-files > /dev/null
	assertTrue "\`link' overwrote .bashrc" "[ -f $HOME/.bashrc -a ! -L $HOME/.bashrc ]"
}

function testReSymlinkDirectory() {
	$DOTSPLAT_FN --batch link module-files > /dev/null
	local inode_before=$(get_inode_no $HOME/.my_module)
	$DOTSPLAT_FN --batch link module-files > /dev/null
	local inode_after=$(get_inode_no $HOME/.my_module)
	assertSame "\`link' re-linked the .my_module directory symlink" $inode_before $inode_after
}



function testDeepLinking() {
	mkdir -p $HOME/.config/bar.dir
	cat > $HOME/.config/foo.conf <<EOF
#I am just a regular foo.conf file 
[foo]
A=True
EOF
	cat > $HOME/.config/bar.dir/bar.conf <<EOF
#I am just a regular bar.conf file 
[bar]
A=True
EOF
	
	assertTrue "The .config/foo.conf file did not exist before symlinking" "[ -f $HOME/.config/foo.conf ]"
	#.config/foo.conf should be overwritten by a directory of the same name
	assertTrue "The .config/bar.dir/ directory did not exist before symlinking" "[ -d $HOME/.config/bar.dir ]"
	#.config/bar.dir should be overwritten by a file of the same name
	$DOTSPLAT_FN --batch --force link dotfiles > /dev/null
	assertTrue "'link' did not symlink the .config/foo.conf directory" "[ -d $HOME/.config/foo.conf ]"
	assertTrue "'link' did not symlink the .config/bar.dir directory" "[ -f $HOME/.config/bar.dir ]"
}

function testSymlinkDirectory() {
	$DOTSPLAT_FN --batch link module-files > /dev/null
	assertTrue "'link' did not symlink the .my_module symlink" "[ -L $HOME/.my_module ]"
}

function testGitDirIgnore() {
	$DOTSPLAT_FN --batch link dotfiles > /dev/null
	assertFalse "'link' did not ignore the .git submodule file" "[ -e $HOME/.vim/.git ]"
}

function testCastleWithSpacesInName() {
	$DOTSPLAT_FN --batch link repo\ with\ spaces\ in\ name > /dev/null
	assertSame "\`link' did not exit with status 0" 0 $?
	assertTrue "'link' did not symlink the .repowithspacesfile file" "[ -f $HOME/.repowithspacesfile ]"
}

function testMultipleCastles() {
	$DOTSPLAT_FN --batch link rc-files dotfiles repo\ with\ spaces\ in\ name > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSymlink $DOTSPLAT/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	assertSymlink "$DOTSPLAT/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

function testAllCastles() {
	$DOTSPLAT_FN --batch link > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSymlink $DOTSPLAT/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	assertSymlink "$DOTSPLAT/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

function get_inode_no() {
	stat -c %i $1 2>/dev/null || stat -f %i $1
}

function assertSymlink() {
	message=''
	if [[ $# == 3 ]]; then
		message=$1
		shift
	fi
	expected=$1
	path=$2
	target=$(readlink "$path")
	assertTrue "The file $path does not exist." "[ -e $path -o -L $path ]"
	[ -e $path -o -L $path ] || startSkipping
	assertTrue "The file $path is not a symlink." "[ -L $path ]"
	[ -L $path ] || startSkipping
	assertSame "The file $path does not point at the expected target." "$expected" "$target"
}

source $SHUNIT2
