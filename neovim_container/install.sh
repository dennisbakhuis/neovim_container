#!/bin/bash
# Neovim Container - A devcontainer-like experience for Neovim.
# MIT License - Copyright (c) 2024 Dennis Bakhuis

# Add some sensible default packages
apt-get -y update && apt-get -y install \
	git \
	curl \
	make \
	fzf

############
## Neovim ##
############
# Official Neovim release
NEOVIM_TARBALL_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"

curl -LO "$NEOVIM_TARBALL_URL"
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# required for copilot and some vim plugins (lsp)
apt-get -y install build-essential nodejs npm

# Add Neovim to bashrc
printf '%s' '
##########
# Neovim #
##########
export PATH="$PATH:/opt/nvim-linux64/bin"
alias v="nvim"
' >>~/.bashrc

###################
## More packages ##
###################

# Put your additional packages here

##########################
### Linux Conveniences ###
##########################

# Add aliases
printf '%s' '
#######
# Git #
#######
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v"
alias gs="git status"
alias gr="git reset"
' >>~/.bashrc
