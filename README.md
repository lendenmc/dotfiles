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

#### setup
The `./setup/setup.sh` script sets up a brand new machine or updates an existing environment. It is idempotent and safe to re-run. For portability reasons, it is a **POSIX sh script**.

I most recently tested it on **macOS Tahoma**, after switching from my old MacBook Pro running **macOS Monterey**. Versions between these two are very likely supported. Prior to that, I tested on OS X El Capitan and macOS Sierra back in 2016.

## Setting up a new machine

First, fork this repository on GitHub so the setup pulls *your* config (homebrew formulas, vscode extensions, projects to clone, shell profiles), not someone else's. Then export `DOTFILES_REPO` to point at your fork (`youruser/your-fork-name`) and, depending on whether `curl` or `wget` is installed by default on your system (e.g. `curl` on macOS, `wget` on Ubuntu), run one of the install commands below.

```sh
export DOTFILES_REPO=youruser/dotfiles
sh -c "$(curl -LsS https://raw.githubusercontent.com/$DOTFILES_REPO/master/setup/setup.sh)"
```

```sh
export DOTFILES_REPO=youruser/dotfiles
sh -c "$(wget -qO- https://raw.githubusercontent.com/$DOTFILES_REPO/master/setup/setup.sh)"
```

`DOTFILES_REPO` is required (the script fails fast if unset).

During the run you'll be prompted for your **git user name** (the name that will appear as the author of your commits) and **git user email** (the email that will appear as the author of your commits and is also embedded as the comment in the SSH key, so the same value gets reused for both). Those two values are written to `~/.gitconfig.local` rather than to the synced `~/.gitconfig`. This separation — inspired by [Paul Irish's dotfiles](https://github.com/paulirish/dotfiles/blob/master/.gitconfig) — keeps personal info (`user.name`, `user.email`, signing keys, anything else specific to a single machine or identity) out of the version-controlled `.gitconfig` while still being picked up by git, since `.gitconfig` `[include]`s `~/.gitconfig.local`. If `~/.gitconfig.local` already exists, the script reads from it and won't overwrite.

The synced `.gitconfig` also wires `core.excludesfile = ~/.gitignore.global`, so the repo's `.gitignore.global` (rsync'd to `$HOME` by `bootstrap.sh`) acts as a **user-wide** ignore list applied to *every* git repo on the machine — that's where universal noise like `.DS_Store`, `*.pyc`, and `.claude/` lives, so each individual repo's `.gitignore` only has to deal with what's specific to it.

The same email also seeds a personal SSH key generated at `~/.ssh/id_ed25519` (usable for any host, not just GitHub). The key is created with an empty passphrase, so add one yourself afterwards with `ssh-keygen -p -f ~/.ssh/id_ed25519` if you want one.

During the installation process the dotfiles repository content will be installed by default into `$HOME/projects/dotfiles`, which will be created if it does not exist already. A prompt will ask you if this default installation path is suitable for you, if not you will be able to change it. Meanwhile, you will also be able to choose whether or not you want to overwrite an existing location. This approach is taken from [Cătălin’s dotfiles](https://github.com/alrra/dotfiles).

The script automatically detects whether it is running on Darwin and runs macOS-specific parts accordingly. These live in the `./setup/macos` subdirectory, making it easy to add support for other systems (e.g. a `./setup/debian` folder). Everything else is generic and should work on Unix-like systems. This includes:

* **Tools** — install standalone tools (rustup, nvm, claude code) listed in `./setup/tools.txt`, skipped when already present
* **Projects** — clone remote git repositories listed in `./setup/projects.txt` into `~/projects`
* **Python** — install python command-line tools listed in `./setup/pipx_packages.txt` in isolated environments using [pipx](https://pypa.github.io/pipx/)
* **Node.js** — install Node version manager `nvm`, enable pnpm via corepack
* **Visual Studio Code** — symlink user settings, keybindings and install extensions listed in `./setup/vscode_extensions.txt`
* **Shells** — add newly installed shells to `/etc/shells`, set zsh as default

#### macOS machine setup

The macOS-only part of the setup will install the following, provided that they are not already there:

* [Command Line Tool](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)
* [Homebew](http://brew.sh/) package manager
* [Homebrew formulas](./setup/macos/brew.sh) listed in `./setup/macos/formulas.txt`
* [Homebrew casks](./setup/macos/brew_cask.sh) listed in `./setup/macos/casks.txt`

Custom [macOS preferences](./setup/macos/preferences.sh) will be set up at the end.

The preferences of iTerm2, macOS terminal of choice, are not contained in the project as they are not really human-readable. An iTerm 2 profile can nonetheless manually be backed up as a JSON file and be manually imported back after the setup.

> **Next step:** the setup script installs tooling and clones this repo into `$HOME/projects/dotfiles`, but it does **not** sync the dotfiles into your home directory. You still need to run `bootstrap.sh` (see the next section) to copy the `.files` into `$HOME`.

## Syncing the dotfiles to your home folder

Once the setup script has finished and your local dotfiles repository lives at `$HOME/projects/dotfiles`, run the following command:

```sh
. $HOME/projects/dotfiles/bootstrap.sh
```

This will first launch `rsync` and install all the "real" `.files` into your home directory. Except for `.git`and `.gitignore`, these include all the repository's top-level files or folders that start with a dot. Secondly, this script will source the right shell profile file by detecting what is your current shell, so that you can immediately work within the right context.

This rsync dotfiles management technique, together with the bootstrap script itself, have been taken from [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles). I have expanded Mathias's bash script to make it work on `bash`, `zsh` and `ksh93` all together, and made some slight modifications to it in order to both make it a bit more portable and fit the specificities of this project. 

#### Managing your dotfiles

In addition, the above command is used to manage your day-to-day dotfiles tweaking. The syncing method involves that all your dotfiles changes have to be made within your dotfiles repository, assuming that this repository is *version-controlled* by **git**. The bootstrap script is then used to enforce these changes into your home folder, so that you can for instance do some testing. It must be pointed out that the setup script does not initiate the repository set up with git and all the other steps involved (remote Github repository setup, ssh config setup, ...). You will have to done it manually for now. You can check this [link](https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh#L269-L281) for a fully automated solution that work for both macOS and Ubuntu. For now let's assume that your dotfiles repository has been fully git-initialized.

The key thing is to forget about editing your dotfiles straight from within your home folder. Tweak whatever config you want to test in your dotfiles repo, source the bootstrap script and see what happen. If you are not satisfied with your modifications and want to roll back, you are now able to leverage all the power of git to revert or modify these changes. All that is needed eventually is to source the bootstrap script again and again. Similarly, if you're happy with your changes, commit!

As you will quickly get bored of being prompted all the time to confirm that you want to overwrite your current dotfiles in your home repository, you can run this command instead:

```sh
set -- -f; . "$HOME"/projects/dotfiles/bootstrap.sh
```

Adding that kind of lines to your shell profile would make it even less painful

```sh
export DOTFILES="${HOME}/projects/dotfiles"
alias dsync='set -- -f; . ${DOTFILES}/bootstrap.sh'
```

so that you would only need to run

```sh
dsync
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

```sh
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
