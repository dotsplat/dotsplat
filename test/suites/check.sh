#!/bin/bash

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
}

function setUp() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
}

function tearDown() {
	rm -rf "$DOTSPLAT/repos/rc-files"
}

function testUpToDate() {
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;32m   up to date${esc}0m rc-files\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the check command output." 0 $?
}

function testUpToDateWithSpacesInRepoName() {
	$DOTSPLAT_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN check "repo with spaces in name"
			expect -ex "${esc}1;36m     checking${esc}0m repo with spaces in name\r${esc}1;32m   up to date${esc}0m repo with spaces in name\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the check command output." 0 $?
	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function testBehind() {
	(cd "$DOTSPLAT/repos/rc-files"; git reset --hard HEAD^1) > /dev/null
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the check command output." 0 $?
	(cd "$DOTSPLAT/repos/rc-files"; git reset --hard HEAD@{1}) > /dev/null
}

function testAhead() {
	(
		cd "$DOTSPLAT/repos/rc-files"
		git config user.name "Dotsplat user"
		git config user.email "dotsplat@example.com"

		cat >> home/.bashrc <<EOF
#!/bin/bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
dotsplat --batch refresh
EOF
		git add home/.bashrc
		git commit -m 'Added dotsplat refresh check to .bashrc'
	) > /dev/null
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the check command output." 0 $?
	(cd "$DOTSPLAT/repos/rc-files"; git reset --hard HEAD^1) > /dev/null
}

source $SHUNIT2
