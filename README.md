# lendenmc's dotfiles

## What's inside
This repository has two purposes as shown by its own structure:

#### dotfiles 
All of the repository's top-level files whose name **start with a dot** are meant to be synced to the home directory. The syncing process is *one-way*. Technically, it involves sourcing the script `./bootstrap.sh`, which is based on the Unix utility `rsync`. This script works when it is sourced from either a **bash**, **zsh** or **ksh93** interactive shell. Moreover, The shell **profile (dot)files** of this repository have been structured in a way that make it clear which files:

* are common to all supported shells
* involve a specific shell
* involve environment variables, aliases or functions
* are specific to a family of operating systems

This profile organization supports these shells:

* **bash**
* **zsh**
* **ksh**
* POSIX **sh** shells, which includes **dash**

#### setup scripts
As its name suggests, the `./setup` folder contains all the setup scripts, which are all launched via the `./setup/setup.sh` main script. These scripts can be used either to set up a brand new machine tailored to fit your development needs or to update an existing environment with the right settings and programs.  For portability reasons, these scripts are all **POSIX sh scripts**.

Though the bulk of the installation and settings scripts is geared toward a **macOS** development machine, the setup process is **\*nix-agnostic**. I had formerly tested these scripts on **OS X El Capitan** and **macOS Sierra**.

## A word for Pythonista

The python development environment generated by these scripts is heavily *Python 3*-oriented. It is time :wink:. This means that Mac users will definitely get a **Python 3-flavored Mac** !

The Python setup script uses the tool [pipx](https://pypa.github.io/pipx/) to install python command-line utilities in isolated environments

## Setting up a new machine

Depending on whether `curl` or `wget` is installed by default on your system, run one of these two commands in your terminal.

```
$ sh -c "$(curl -LsS https://raw.github.com/lendenmc/dotfiles/master/setup/setup.sh)"
```

```
$ sh -c "$(wget -qO- https://raw.github.com/lendenmc/dotfiles/master/setup/setup.sh)"
```

For instance, `curl` is installed by default on macOS while this is `wget` on Ubuntu.

During the installation process the dotfiles repository content will be installed by default into `$HOME/projects/dotfiles`, which will be created if it does not exist already. A prompt will ask you if this default installation path is suitable for you, if not you will be able to change it. Meanwhile, you will also be able to choose whether or not you want to overwrite an existing location. This approach is taken from [Cătălin’s dotfiles](https://github.com/alrra/dotfiles).

As an avid Mac user, most of the work have been made to set up a new macOS environment. So third-party software installation scripts, in other words programs installed with a package manager, have only been written for a Mac. These scripts leverage the Homebrew package manager. A global preferences script for the machine is only there for Mac as well. However, all scripts except for those inside the `./setup/macos` subdirectory are generic and should work on Unix-like systems. This includes in that order:

* [Remote git projects](./setup/remotes.sh)
	* clone a selection of remote git repositories (github, gitlab, etc.) listed in `./setup/projects/projects.txt` into your machine `~/projects`directory
* [Python](./setup/python)
	* install python command-line tools listed in `./setup/python/pipx_packages.txt` in isolated environments using [pipx](https://pypa.github.io/pipx/)
* [Node.js](./setup/node.js)
	* install Node version manager `nvm`
* [Visual Studio Code](./setup/vscode) user settings, keybindings and extensions
* [Shell config](./setup/shells.sh)
	* Edit the `/etc/shells` file to add newly installed shells, in particular the latest `bash` and `zsh` versions

#### MacOS machine setup

The main script `./setup/setup.sh` will first automatically detect whether you are running on Darwin or not and will run the macOS-specific parts accordingly. These are all contained in the `./setup/macos` subdirectory. That way, it will be easy in the future to expand the project to support other Unix-like systems, for instance by creating a `./setup/debian` folder for a Debian-specific setup. The macOS-only part of the setup will install the following things, provided that they are not already there:

* [Command Line Tool](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)
* [Homebew](http://brew.sh/) package manager
* [Homebrew formulas](./setup/macos/brew.sh) listed in `./setup/macos/brew_formulas.txt`
* [Homebrew casks](./setup/macos/brew_cask.sh) listed in `./setup/macos/brew_casks.txt`

Custom [macOS preferences](./setup/macos/preferences.sh) will be set up at the end.

The preferences of iTerm2, macOS terminal of choice, are not contained in the project as they are not really human-readable. An iTerm 2 profile can nonetheless manually be backed up as a JSON file and be manually imported back after the setup.

## Syncing the dotfiles to your home folder

Let's assume that `$HOME/projects/dotfiles` is now your local dotfiles repository. Run the following command:

```
$ . $HOME/projects/dotfiles/bootstrap.sh
```

This will first launch `rsync` and install all the "real" `.files` into your home directory. Except for `.git`and `.gitignore`, these include all the repository's top-level files or folders that start with a dot. Secondly, this script will source the right shell profile file by detecting what is your current shell, so that you can immediately work within the right context.

This rsync dotfiles management technique, together with the bootstrap script itself, have been taken from [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles). I have expanded Mathias's bash script to make it work on `bash`, `zsh` and `ksh93` all together, and made some slight modifications to it in order to both make it a bit more portable and fit the specificities of this project. 

#### Managing your dotfiles

In addition, the above command is used to manage your day-to-day dotfiles tweaking. The syncing method involves that all your dotfiles changes have to be made within your dotfiles repository, assuming that this repository is *version-controlled* by **git**. The bootstrap script is then used to enforce these changes into your home folder, so that you can for instance do some testing. It must be pointed out that the setup script does not initiate the repository set up with git and all the other steps involved (remote Github repository setup, ssh config setup, ...). You will have to done it manually for now. You can check this [link](https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh#L269-L281) for a fully automated solution that work for both macOS and Ubuntu. For now let's assume that your dotfiles repository has been fully git-initialized.

The key thing is to forget about editing your dotfiles straight from within your home folder. Tweak whatever config you want to test in your dotfiles repo, source the bootstrap script and see what happen. If you are not satisfied with your modifications and want to roll back, you are now able to leverage all the power of git to revert or modify these changes. All that is needed eventually is to source the bootstrap script again and again. Similarly, if you're happy with your changes, commit!

As you will quickly get bored of being prompted all the time to confirm that you want to overwrite your current dotfiles in your home repository, you can run this command instead:

```
$ set -- -f; . "$HOME"/projects/dotfiles/bootstrap.sh
```

Adding that kind of lines to your shell profile would make it even less painful

```
export DOTFILES="${HOME}/projects/dotfiles"
alias dsync='set -- -f; . ${DOTFILES}/bootstrap.sh'

```

so that you would only need to run

```
$ dsync
```

This alias is actually part of the dotfiles config.

## Structure of the shell profiles

I like zsh a lot but I still need to use bash some times. Basically I found myself constantly migrating some of my zsh lines into my bash profile, figuring out which part was compatible between the two, which part I did forget to include. This is no fun.  So I thought about a kind of base profile that would handle all the config that are common to as many shells as possible. It seems then quite fitting for me to use the

* `.profile`

file for that purpose, as it is an integral part of the bash profile files family. All shell-specific config has been put into .*rc types of profiles, which include:

* `.zshrc`
* `.bashrc`
* `.kshrc`
* `.shrc`

As far as bash is concerned, there is the additional profile file

* `.bash_profile`

which, here, is only referring to  `.bashrc` or `.profile` depending on the type of shell (interactive or not, login or not).

Whenever one of these files is sourced, the `.profile` file will be sourced right from the start. So one of the few duplicate lines that you will find across profiles will be similar to this:

```
if [ -r "${HOME}/.profile" ] && [ -f "${HOME}/.profile" ]; then . "${HOME}/.profile; fi"
```


#### Categories of profile files
On one hand, I did not want a monolithic and heavy `.profile`, so I split some part of it into more manageable categories:

* `.exports`
* `.aliases`
* `.functions`

On the other hand, I also wanted *machine*-independent dotfiles and did not want my macOS-specific lines such as Homebrew aliases, to pollute my config on a Linux machine. So every macOS-specific lines has been grouped under renamed files with a *.macos* extension:

* `.exports.macos`
* `.aliases.macos`
* `.functions.macos`

This solution is scalable. If I need in the future to do some development work on Ubuntu and create Ubuntu-specific aliases, functions or environment variables, I will create the same kind of files, only with a *.ubuntu* suffix this time. The `.profile` file will be responsible to source all these files together. Any line that is not part of one the categories above will be included in `.profile`as well.

#### Sourcing scripts within profiles
I do not enjoy checking for the `source whatever_external_script_.sh` type of lines in my profile files, nor do I like spending too much time figuring out the right region of the profile to put that kind of line. Therefore, I find it more comfortable to list those scripts's names under these text files, which make it clear which shell support which script:

* `.scripts.bash.txt`
* `.scripts.zsh.txt`
* `.scripts.ksh.txt`

This involves one text file for each type of shell. Near the bottom the corresponding .*rc profile, a generic `_source_from_text_file` function  is called. It will loop over each of these scripts and source them.

## Acknowledgements

Some ideas or parts of the code stem or have been inspired from these dotfiles projects: 

* [Mathias’s](https://github.com/mathiasbynens) [dotfiles](https://github.com/mathiasbynens/dotfiles)
* [Cătălin’s](https://github.com/alrra) [dotfiles](https://github.com/alrra/dotfiles)
* [Paul's](https://github.com/paulirish) [dotfiles](https://github.com/paulirish/dotfiles)
* [holman](https://github.com/holman) [does dotfiles](https://github.com/holman/dotfiles)

Writing portable shell scripts is not an easy task. I benefited a lot from the encyclopedic knowledge of some Unixers on [Unix & Linux StackExchange](http://unix.stackexchange.com/), most notably these experts:

* [Giles](http://unix.stackexchange.com/users/885/gilles)
* [Stéphane Chazelas](http://unix.stackexchange.com/users/22565/st%C3%A9phane-chazelas)
* [Dennis Williamson](http://unix.stackexchange.com/users/382/dennis-williamson)

Special thanks to [Doug Hellmann](https://github.com/dhellmann) for his [virtualenvwrapper.sh](http://virtualenvwrapper.readthedocs.io/) script. Checking out this code inspired me some handy shell scripting tricks and gave me a great example of a battle-tested portable shell script that is sourced.

Influential posts:

* [Dotfiles Are Meant to Be Forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked)
* [GitHub does dotfiles](https://dotfiles.github.io)
