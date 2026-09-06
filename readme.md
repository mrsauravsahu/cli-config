# cli-config
Helping you setup your CLI experience easily. Some goodies for the ol' terminal.
![M365Princess theme](./assets/star.png)

### Customize to your hearts content with [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh).

Few examples how you can make the cli your own with oh-my-posh themes.

#### M365Princess
![M365Princess theme from oh-my-posh](./assets/M365Princess.png)

#### atomic
![atomic theme from oh-my-posh](./assets/atomic.png)

#### powerlevel10k
![powerlevel10k theme from oh-my-posh](./assets/powerlevel10k_modern.png)

#### star
![star theme from oh-my-posh](./assets/star.png)

## getting started

You'll require these:
- zsh
- curl
- wget
- git

Note: For installing packages,  you'll also require a package manager. On Linux, cli-config  uses `apt`. For macOS, `brew` should be installed, which you can download from [homebrew](https://brew.sh/)'s website.


To check if you have everything installed

```zsh
which zsh curl wget git
```

should give you the path to all the four executables, like so:

```zsh
❯ which zsh curl wget git
/bin/zsh
/usr/local/bin/curl
/usr/local/bin/wget
/usr/bin/git
```

> Caution: Running the setup without these requirements will result in unknown consequences. If you have any issues, please raise an issue so we can solve it.

> Checkout [details.md](./details.md) for more details.

## install

Use the `init.sh` script to setup in a single step! You can visit the link - https://raw.githubusercontent.com/mrsauravsahu/cli-config/main/init.sh to see its raw contents, which is just a git clone followed by calling the `cli-config` script.

```bash
wget -O- https://raw.githubusercontent.com/mrsauravsahu/cli-config/main/init.sh | zsh -s -- -p default
```
This will create a folder called `cli-config` inside the current folder and installation will happen there.

Once the setup is done, your `~/.zshrc` will be symlinked to the [default profile](./profiles/default/.zshrc). You will be able to edit the `~/.zshrc` for any customizations.

## Features
- one script setup
- works with Mac and Linux (Ubuntu, Pop!_OS) & Windows (WSL)
- adds lots of helper tools to the shell
- easy theme switcher

---

## List of tools 

### Basics
- [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) for zsh plugins
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) for prompt customization and theming

### Programming Support
- [asdf](https://github.com/asdf-vm/asdf) single version manager for every runtime (node, python, go, dotnet, terraform, ...) via plugins

### Helpers and Goodies
- [direnv](https://github.com/direnv/direnv)
- [autojump](https://github.com/wting/autojump)
- [thefuck](https://github.com/nvbn/thefuck)

### Appearence
- [M365Princess theme from oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/M365Princess.omp.json)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)



## What's new? 🎉
- Runtime versions are managed solely by [asdf](https://github.com/asdf-vm/asdf) - the nvm, pyenv, gvm, tfenv and dotnet installers have been removed.
- Theming & Prompt customization support with [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh).
- Fresh new installation experience, powered by [Bash oo Framework](https://github.com/niieani/bash-oo-framework).
- Switch oh-my-posh themes with a single env variable `CLI_CONFIG_THEME`
- Extra tools available for Linux as well! Check out the [package list](extras/apt-list.txt).
- New extras package - [tmux](https://github.com/tmux/tmux/wiki)
- Setup apps and cool goodies on macOS with brew. Checkout the [extras](extras/setup.sh) script.

\-S
