# Neovim container - Develop (almost) like in a DevContainer
Develop inside a container using Neovim with your local settings.

For my work it is convenient to work in the same environment as the production
environment, regardless of what host computer I am using. Vscode has this nice
concept of DevContainers. I tried to look for a solution for Neovim but could
not find a proper solution. After some fiddling around I found out: you do
not need DevContainers. Neovim is a text-based application and not special tricks
are required. Vscode on the other hand is a GUI application and needs a more
complex setup using a client/server architecture.

This repos shows a way to work with Neovim inside your production container
while still using your local neovim config.

Requirements:
- Docker
- Git
- a Dockerfile

## Simple installation
I have created a simple installer to setup the scripts inside your project.

## What is actually happening
1. We build an image of the container if it does not yet exist:
```bash
docker build -t neovim_devcontainer .
```
