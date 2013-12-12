dotsplat
=========
dotsplat is a fork of the excellent project [homeshick](https://github.com/andsens/homeshick) developed by [@andsens](https://github.com/andsens). Like homeshick, dotsplat keeps your dotfiles up to date using only git and bash. The main difference is that dotsplat imposes design decisions about how dotfiles should be deployed and thus can provide a framework on top of the base install to help provide:

* a consistent experience across both Mac and Linux systems
* documented examples that can benefit veteran and new users
* a flexible and modular dotfile design 
* a platform for unix education of dotfile managment for my classes and short courses

dotsplat is designed to be used with [scibrew](https://github.com/hovr2pi/homebrew-scibrew), a collection of taps for
[homebrew](http://brew.sh) that also supports [lmod](https://www.tacc.utexas.edu/tacc-projects/lmod/), Lua based module system that easily handles the MODULEPATH Hierarchical problem.

dotsplat is installed to your own home directory and does not require root privileges to be installed.
All of the documentation provided with homeshick applies to dotsplat:
* [tutorials](https://github.com/andsens/homeshick/wiki/Tutorials)
* [tips](https://github.com/andsens/homeshick/wiki/Automatic-deployment)
* [tricks](https://github.com/andsens/homeshick/wiki/Symlinking)
* [wiki](https://github.com/andsens/homeshick/wiki)

Installation
============

```bash
$ git clone git://github.com/hovr2pi/dotsplat.git $HOME/.dotsplat/dotsplat.git
```
