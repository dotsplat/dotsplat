#!/bin/bash

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/my_module > /dev/null
	$DOTSPLAT_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$DOTSPLAT/repos/dotfiles"
	rm -rf "$DOTSPLAT/repos/my_module"
	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function testPwd() {
	local dotfiles_home=$DOTSPLAT/repos/dotfiles
	local result=$($DOTSPLAT_FN cd dotfiles && pwd)
	assertSame "\`cd' did not change to the correct directory" "$dotfiles_home" "$result"
}

function testPwdNoHome() {
	local my_module_dir=$DOTSPLAT/repos/my_module
	local result=$($DOTSPLAT_FN cd my_module && pwd)
	assertSame "\`cd' did not change to the correct directory" "$my_module_dir" "$result"
}

function testNNonExistent() {
	local current_dir=$(pwd)
	local result=$($DOTSPLAT_FN cd non_existent 2>/dev/null; pwd)
	assertSame "\`cd' changed directory" "$current_dir" "$result"
}

function testNExitCode() {
	local result
	$DOTSPLAT_FN cd non_existent 2>/dev/null
	result=$?
	assertEquals "\`cd' did not exit with code 1" 1 $result
}

function testPwdWithSpaces() {
	local repo_home="$DOTSPLAT/repos/repo with spaces in name"
	local result=$($DOTSPLAT_FN cd repo\ with\ spaces\ in\ name && pwd)
	assertSame "\`cd' did not change to the correct directory" "$repo_home" "$result"
}

source $SHUNIT2
