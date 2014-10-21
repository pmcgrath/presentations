#!/usr/bin/env bash
# Based on http://golang.org/doc/install
# Single GOPATH value\workspace is based on Andrew Gerrand's comment @ https://groups.google.com/forum/#!topic/golang-nuts/dxOFYPpJEXo and http://stackoverflow.com/questions/20722502/whats-a-good-best-practice-with-go-workspaces
# Summary of what the install does
# 	Get archive
#	Extract archive content to /usr/local/go
#	Add /usr/local/go/bin to path - either system wide or just for current user
#	Ensure ~/go directory exists for current user
#	Ensure GOPATH environment variable exists for current user
#	Ensure ~/go/bin is on path for current user
# Usage is
#	. install.sh
#	install-go 1.3 system
#	verify-go-install
#	
set -e
set -v

ensure-path-included()
{
	local -r profile=$1
	local -r path=$2
	local -r comment=$3

	grep "export PATH=\$PATH:$path" $profile -q
	if [ $? -eq 1 ]; then
 		echo -e "\n# $comment\nif [[ \$PATH != *$path* ]]; then export PATH=\$PATH:$path; fi" | sudo tee -a $profile

		# Source the profile so it is available to us in the current shell
		. $profile
	fi
}

ensure-gopath-set()
{
	local -r go_path=$1
	local -r profile=$HOME/.bashrc

	grep 'export GOPATH=' $profile -q
	if [ $? -eq 1 ]; then
 		echo -e "\n# Set GOPATH, only using a single GOPATH value\nexport GOPATH=$go_path" >> $profile

		# Source the profile so it is available to us in the current shell
		. $profile
	fi
}

install-go()
{
	if [ $# -ne 2 ]; then 
		echo "Usage is $FUNCNAME GoVersion InstallFor"
		echo "  i.e. $FUNCNAME 1.3 system"
		return
	fi
	
	local -r version=$1
	local -r install_for=$2

	# Change directory
	pushd $HOME

	# Get binary content
	archive=go$version.linux-amd64.tar.gz
	wget http://golang.org/dl/$archive
	sudo tar -C /usr/local -xzf $archive

	# Place on path if not already on path
	local profile=$HOME/.bashrc	
	if [ $install_for == 'system' ]; then profile=/etc/profile; fi
	ensure-path-included $profile /usr/local/go/bin
	
	# Create go dir for current user
	local -r go_path=$HOME/go
	mkdir -p $go_path
	
	# Create GOPATH environment variable exists
	ensure-gopath-set $HOME/go

	# Add go workspace bin directory to user's path	
	ensure-path-included $HOME/.bashrc $HOME/go/bin

	# Pop original location
	popd
}

verify-go-install()
{
	which go
	go version
	go env
	godoc fmt Println
}

