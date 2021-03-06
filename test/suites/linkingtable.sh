#!/bin/bash

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$DOTSPLAT/repos/rc-files"
	rm -rf "$DOTSPLAT/repos/dotfiles"
	rm -rf "$DOTSPLAT/repos/module-files"
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${DOTSPLAT}*" -delete
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

## This is the linking table we are trying to verify:
## "not directory" can be a regular file or a symlink to either a file or a directory
##        $HOME\repo    | not directory | directory ##
## ---------------------|---------------|---------- ##
## nonexistent          | link          | mkdir     ##
## symlink to repofile  | identical     | rm!&mkdir ##
## file                 | rm?&link      | rm?&mkdir ##
## directory            | rm?&link      | identical ##
## directory (symlink)  | rm?&link      | identical ##


## First row: nonexistent
## First column: not directory
function testFileToNonexistent() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToNonexistent() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToNonexistent() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToNonexistent() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## First row: nonexistent
## Second column: directory
function testDirToNonexistent() {
	$DOTSPLAT_FN --batch link dotfiles > /dev/null
	assertFalse "\`link' symlinked the .ssh directory" "[ -L $HOME/.ssh ]"
	assertTrue "\`link' did not create the .ssh directory" "[ -d $HOME/.ssh ]"
}


## Second row: symlink to repofile
## First column: not directory
function testFileToReposymlink() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/.bashrc)
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/.bashrc)
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSame "\`link' re-linked the .bashrc file" $inode_before $inode_after
}

function testFileSymlinkToReposymlink() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/symlinked-file)
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/symlinked-file)
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-file $HOME/symlinked-file
	assertSame "\`link' re-linked symlinked-file" $inode_before $inode_after
}

function testDirSymlinkToReposymlink() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/symlinked-directory)
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/symlinked-directory)
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
	assertSame "\`link' re-linked symlinked-directory" $inode_before $inode_after
}

function testDeadSymlinkToReposymlink() {
	$DOTSPLAT_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/dead-symlink)
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/dead-symlink)
	assertSymlink $DOTSPLAT/repos/rc-files/home/dead-symlink $HOME/dead-symlink
	assertSame "\`link' re-linked dead-symlink" $inode_before $inode_after
}

## Second row: symlink to repofile
## Second column: directory
function testLegacySymlinks() {
	# Recreate the legacy scenario
	ln -s $DOTSPLAT/repos/dotfiles/home/.ssh $HOME/.ssh
	$DOTSPLAT_FN --batch --force link dotfiles > /dev/null
	# Without legacy handling if we were to run `file $HOME/.ssh/known_hosts` we would get
	# .ssh/known_hosts: symbolic link in a loop
	# The `test -e` is sufficient though
	assertTrue "known_hosts file is a symbolic loop or does not exist" "[ -e $HOME/.ssh/known_hosts ]"
}


## Third row: file
## First column: not directory
function testFileToFile() {
	touch $HOME/.bashrc
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToFile() {
	touch $HOME/symlinked-file
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToFile() {
	mkdir $HOME/symlinked-directory
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToFile() {
	touch $HOME/dead-symlink
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## Third row: file
## Second column: directory
function testDirToFile() {
	touch $HOME/.ssh
	$DOTSPLAT_FN --batch --force link dotfiles > /dev/null
	assertTrue "[ -d $HOME/.ssh ]"
	assertFalse "[ -L $HOME/.ssh ]"
}


## Fourth row: directory
## First column: not directory
function testFileToDir() {
	mkdir $HOME/.bashrc
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToDir() {
	mkdir $HOME/symlinked-file
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToDir() {
	mkdir $HOME/symlinked-directory
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToDir() {
	mkdir $HOME/dead-symlink
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## Fourth row: directory
## Second column: directory
function testDirToDir() {
	mkdir $HOME/.ssh
	local inode_before=$(get_inode_no $HOME/.ssh)
	$DOTSPLAT_FN --batch --force link dotfiles > /dev/null
	local inode_after=$(get_inode_no $HOME/.ssh)
	assertSame "\`link' recreated .ssh" $inode_before $inode_after
	assertTrue "[ -d $HOME/.ssh ]"
	assertFalse "[ -L $HOME/.ssh ]"
}


## Fourth row: directory
## First column: not directory
function testFileToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/.bashrc
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/.bashrc $HOME/.bashrc
	rm -rf $NOTHOME/symlink-target-dir
}

function testFileSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/symlinked-file
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-file $HOME/symlinked-file
	rm -rf $NOTHOME/symlink-target-dir
}

function testDirSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/symlinked-directory
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
	rm -rf $NOTHOME/symlink-target-dir
}

function testDeadSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/dead-symlink
	$DOTSPLAT_FN --batch --force link rc-files > /dev/null
	assertSymlink $DOTSPLAT/repos/rc-files/home/dead-symlink $HOME/dead-symlink
	rm -rf $NOTHOME/symlink-target-dir
}

## Fourth row: directory
## Second column: directory
function testDirToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/.ssh
	local inode_before=$(get_inode_no $HOME/.ssh)
	$DOTSPLAT_FN --batch --force link dotfiles > /dev/null
	local inode_after=$(get_inode_no $HOME/.ssh)
	assertSymlink $NOTHOME/symlink-target-dir $HOME/.ssh
	assertSame "\`link' recreated .ssh" $inode_before $inode_after
	assertTrue "[ -d $HOME/.ssh ]"
	assertTrue "[ -L $HOME/.ssh ]"
	rm -rf $NOTHOME/symlink-target-dir
}

source $SHUNIT2
