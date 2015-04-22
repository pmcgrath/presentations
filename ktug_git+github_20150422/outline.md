# Content 
- Breeze through git - Don't try to remember the commands, the concepts are the important thing
- Highlight features with github
- Discussion of any issues
- Please ask questions as we go - I'm not worried about covering this content, what ever people get value from
- Do you want to alter this or address in a different order


# What is git

## VCS
- File backups, centralised VCS, DVCS

## Centralised VCS
-Subversion

## Distributed VCS
- Peers

## Origin
- Linux issue
- OSS

## Compare to centralised VCS
- Subversion
- You control your own repository
 - Private repositories
 - No network connection required			
 - Fast branches - Just creates a file
 - Local merging - fetch remote branch and work from there
 - Your own private branches
 - Peers
 - Immutable content - sha1
 - Full history
 - Cloned repositories act as backups
 - Can still simulate a centralised model by allowing contributors to push content to a nominated repository

## Installation
- http://www.git-scm.com/
- For windows
  - a) Manual install
  - http://www.git-scm.com/download/win
  - At this time the latest version is v1.9.5 as opposed to the source version v2.3.5

 - b) GUI installs
  -http://www.git-scm.com/downloads/guis

 - c) chocolatey
  - https://chocolatey.org/packages/git

- For linux ubuntu - tracking latest

```bash
		sudo add-apt-repository ppa:git-core/ppa -y                                                                                                                      
		sudo apt-get update                                                                                                                                              
		sudo apt-get install git -y 
```

# Configuration
	Global config and per repository config
	Basic config
		git config --global user.email pmcgrath@gmail.com
		git config --global user.name pmcgrath
		cat ~/.gitconfig
			[user]
				email = pmcgrath@gmail.com
				name = pmcgrath
		# Windows line endings - CRLF v LF


Work with local repos
	Acknowledge that we did directory backups until we got comfortable - didn't take long, rarely lost data and only early on

	cd /tmp
	mkdir u1_repo && cd u1_repo
	tmux
		Create 2 panes
		resize so we can watch - : resize -D 15
	watch find .

	# Repo - This one has a working directory
	git init .
	echo Line 1 > afile
	git add afile
	git status
	git commit -m 'Initial commit'
	git status
	git log

	# Branch - See a new file created in .git/refs/heads
	git checkout -b b1

	# See that the ref just points to same commit as git log above
	cat .git/refs/heads/b1

	# Add content
	echo aaaaaa > bfile
	git add bfile
	git commit -m 'Added bfile'

	# Diffs
	cat .git/refs/heads/master
	cat .git/refs/heads/b1

	# Switch back to master
	git checkout master

	# Show b1 branch's tree
	git ls-tree $(cat .git/refs/heads/b1)
	git show 'blob hash'
	
	# Create a sync\centralised repo - a bare repo
	mkdir /tmp/repo && cd /tmp/repo
	git init . --bare

	# Make u1 repo aware of sync\centralised repo
	cd /tmp/u1_repo
	git remote add origin /tmp/repo
	git remote -v

	# Push u1 repo's master branch to the sync\centralised repo
	git checkout master
	git push origin master

	# Clone the repo for u2
	cd /tmp
	git clone /tmp/repo u2_repo
	cd u2_repo
	git remote -v
	git log


Git internals
	DAG
	Working directory rebuilds v bare repository
	Staging - add\commit sequence
	Commit - sha1
	Tree
	Blobs
	Tags

	Hooks
	
	Can now start thinking of it has a database that you can query


GitHub
	There are alternatives - bitbucket, gitlab, UNC share
	Issues 
		github DDOS outages
		Placing all your data with one provider (Same concerns as email - gmail, hotmail)
		Sensitive data - need controls to ensure no sensitive data placed on web - History makes available to any searches
	Social coding - Share\collobarate etc
	Services around hosting git repositories
		Hosted on web or can pay for github enterprise for on premise service
		Free plans\Paid plans - Corporate\team plans
		Issues
		Forking and pull requests for collabaration
		Wiki
		Releases
		Web hooks - build systems\docker etc
		Restrict contributors
		Project statistics
		Github pages 
		Documentation using markdown
		Gists
	OSS
		Most content seems to be moving here 
	Accessed primarily with 2 protocols
		https 
		ssh
	Accessed differently depending on just cloning or planning to contribute
	Demo
		Create github account
		Configure git
		Create a repository
		Clone 
		Add content 
		Push content

		Clone to a different location and repeat

		git log in both locations

		Show a pull request
			# Create account on github 'ted1234'
			# Fork repo pmcgrath/PMCG.Messaging.git

			# Add user
			sudo adduser ted

			# Switch user, configure git, create ssh key and clone 
			su ted
			cd ~
    			git config --list
 			git config --global user.name ted
			git config --global user.email 'ted1234@hotmail.com'
			git config --list
			cat .gitconfig
			ssh-keygen -t rsa -C "ted1234@hotmail.com"
  			ls .ssh/
			cat .ssh/id_rsa.pub
			# Add key in github
			mkdir -p ~/oss/github.com/ted1234 && cd ~/oss/github.com/ted1234
			git clone git@github.com:ted1234/PMCG.Messaging.git
			cd PMCG.Messaging
			git remote add upstream https://github.com/pmcgrath/PMCG.Messaging.git

			# Create branch, alter content and push branch to github forked repo
   			git checkout -b AlterDoc
   			vim readme.md
			git status
			git commit -am 'Clarified plugin restart detail'
			git diff master
			git push origin AlterDoc

			# Go to github and make pull request
			
			# Switch to original repo and merge pull request on github

			# Update local copy
			git fetch origin
			git checkout master
			git merge origin/master
			git log


Resources
	Main git website						http://git-scm.com/
	Free online git book						http://git-scm.com/book/en/v2
	Git workflows (Search for alternatives)				https://www.atlassian.com/git/tutorials/comparing-workflows/centralized-workflow
	github								https://github.com/
	Good alternative to github					https://bitbucket.org/
	Gitlab to run git on site (Simplier when used with docker)	https://about.gitlab.com/
	Github help (Reading this will give a good overview)		https://help.github.com/
	git protocols							http://git-scm.com/book/ch4-1.html
	github ssh configuration					https://help.github.com/articles/generating-ssh-keys/
	Manage github pull request from shell (Many others)		https://github.com/docker/gordon
	How do i ...?							google - never found a question we couldn't get an answer to
									youtube
