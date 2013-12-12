#!/usr/bin/env bash -e

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
}

function testList() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
	$DOTSPLAT_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN list
			expect -ex "${esc}1;37m     dotfiles${esc}0m $REPO_FIXTURES/dotfiles\r
${esc}1;37m module-files${esc}0m $REPO_FIXTURES/module-files\r
${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r
${esc}1;37mrepo with spaces in name${esc}0m $REPO_FIXTURES/repo with spaces in name\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$DOTSPLAT/repos/rc-files"
	rm -rf "$DOTSPLAT/repos/dotfiles"
	rm -rf "$DOTSPLAT/repos/module-files"
	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function testListWithSpacesInRepoName() {
	$DOTSPLAT_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN list
			expect -ex "${esc}1;37mrepo with spaces in name${esc}0m $REPO_FIXTURES/repo with spaces in name\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function testListAlteredUpstreamRemoteName() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	(cd $DOTSPLAT/repos/rc-files; git remote rename origin nigiro)
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN list
			expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$DOTSPLAT/repos/rc-files"
}

function testSlashInBranch() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	(cd $DOTSPLAT/repos/rc-files; git checkout branch/with/slash >/dev/null 2>&1)
	esc="\\u001b\\u005b"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN list
			expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$DOTSPLAT/repos/rc-files"
}

source $SHUNIT2
