# Laptop Setup

I use this repo to set up a new macOS computer for development, updating it as I move
between projects and jobs and my requirements change.

### Prerequisites

1. Xcode CLI tools
   ```bash
   xcode-select --install
   ```
1. [homebrew](http://brew.sh) package manager
   ```bash
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   ```

### Installation

1. create a directory named `workspace` in your home directory.

    ```bash
    mkdir -p ~/workspace
    ```

1. clone this repo

    ```bash
    git clone git@github.com:tomas-nava/laptop-setup.git ~/workspace/
    ```
1. run the install script

    ```bash
    cd ~/workspace/laptop-setup
    ./install
    ```

Read the [install script](install) to see how the computer will be configured; read
the [Brewfile](Brewfile) to see what will be installed.

### Credit

Thanks to @zaksoup for introducing me to this way of managing configuration and
applications.
