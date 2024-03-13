# 🎁 Neovim container - Develop (almost) like in a DevContainer
Develop inside your container using Neovim with your local settings.

For my work it is convenient to work in the same environment as the production
environment, regardless of what host computer I am using. Vscode has this nice
concept of DevContainers. I tried to look for a solution for Neovim but could
not find a proper solution. After some fiddling around I found out: you do
not need DevContainers. Neovim is a text-based application and not special tricks
are required. Vscode on the other hand is a GUI application and needs a more
complex setup using a client/server architecture.

| What I learned: you do no need DevContainers for Neovim.

This repos shows a workflow to work with Neovim inside your production container
while still using your local Neovim config.

Requirements:
- Docker
- a Dockerfile


## Screencast
![Screencast showing Neovim Containers](https://github.com/dennisbakhuis/neovim_container/blob/a8d246760051103204800d87530b7cec4344f13f/assets/neovim_container_demo.gif)

## Simple installation
I have created a simple installer to setup the scripts inside your project. Feel free
to first inspect the file. What it does is copy the required files from this repo
into the `.neovim` folder of your current folder. I recommend the root folder of the
project.

```bash
wget -q -O - wget https://raw.githubusercontent.com/dennisbakhuis/neovim_container/main/install_neovim_container.sh | bash
```

If the `Dockerfile` and `pyproject.toml` are in the current folder you can
simply start the container with:

```bash
.neovim/container.sh up
```

This will build the container, start the container, install all requirements, and
eventually start a terminal inside the container.

You can edit your specifics in the following three files, but this is not
required:
1. `.neovim/build.sh`     : Customize your build procedure
2. `.neovim/run.sh`       : Add additional parameters to the run command
3. `.neovim/install.sh`   : Install additional packages into the container
4. `.neovim/constants.sh` : Additional constants (optional)

To rebuild the container use:
```bash
.neovim/container.sh up --rebuild
```


## What is actually happening
1. It will check if the requirements are met:
- Dockerfile in current folder
- Pyproject.toml in current folder or project_name set manually through 
`--project_name` or PROJECT_NAME in constants.sh.

2. If the images does not exist, will first build the image using Docker.

3. If the images exists and the container is "stopped" it will start simply
start the container and start a terminal inside.

4. When there is no stopped container, the script will start one for the first
   time and mounting all local setting folders to have Neovim working. Next,
   install the requirements from `.neovim/install.sh`. When it is done it will
   open a terminal inside the container. 

5. After the terminal ends, the container is stopped automatically and can be
   started again next time, without re-install.
