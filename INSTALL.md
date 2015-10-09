## Installation

### Vagrant development servers.
 1. Install an SSH keypair on the host machine if one doesn't exist already.
 1. Install [Git](http://git-scm.com), [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org). OS X [Homebrew](http://brew.sh) users, consider easy installation via [Homebrew Cask](http://caskroom.io). *NOTE:* VirtualBox 5.x appears to have some issues creating symlinks. Until this issue is resolved, recommend to install the latest 4.3.x version (Homebrew Cask users can use [homebrew-cask-versions](https://github.com/caskroom/homebrew-versions)).
 1. Run the following command to checkout this project: ```git clone https://github.com/thehunmonkgroup/freeswitch-vagrant-dev.git```
 1. From the command line, change to the <code>vagrant</code> directory, and you'll find <code>settings.sh.example</code>. Copy that file in the same directory to <code>settings.sh</code>.
 1. Edit to taste, the default values (which are the commented out values in the example config) will most likely work just fine.
 1. Follow instructions below for configuring pillar data and SSL certs.
 1. From the command line, run <code>./development-environment-init.sh</code>.
 1. Once the script successfully completes the pre-flight checks, it will automatically handle the rest of the installation and setup. Relax, grab a cup of chai, and watch the setup process roll by on screen. :)
 1. If the setup script finds an SSH pubkey in the default location of the host's HOME directory, it will automatically install that pubkey to the VM. The end of the script outputs optional configuration you can add to your .ssh/config file, to enable easy root SSH access to the server.
 1. SSH into the VM, and run ```start-conference.sh```
 1. Visit <code>https://[server URL]:9001</code> in your browser, and you should see the main page for FreeSWTICH's Verto Communicator.
 1. The installed virtual machine can be controlled like any other Vagrant VM. See [this Vagrant cheat sheet](http://notes.jerzygangi.com/vagrant-cheat-sheet) for more details.
 1. If for any reason the installation fails, or you just want to completely remove the installed virtual machine, run the <code>vagrant/kill-development-environment.sh</code> script from the command line.

### Configuring pillar data

 * In the <code>salt/pillar/server</code> directory, you'll find an example configuration file.
 * Copy the file in the same directory, removing the .example extension.
 * Edit the configurations to taste. You can reference <code>salt/salt/vars.jinja</code> to see what variables are available, and the defaults for each.

### Configuring SSL data

You need valid SSL certificates in order for WebRTC to function properly, there are two options, easy and hard:

 1. Easy
   * Import <code>salt/salt/etc/ssl/cert.pem</code> as a trusted CA in your browser, and use the default configured <code>dev.freeswitch.local</code> domain. It should be pretty easy to find instructions to import the certificate into all major browsers.

 1. Hard
   * Get some from a provider. Note that the common name of the certificate must match the hostname on production servers, and the <code>SALT_MINION_ID</code> setting in settings.sh for Vagrant installs -- this allows Salt to auto configure the setup.
   * Place the following files into the <code>salt/salt/etc/ssl/</code> directory:
     * cert.pem: The server's SSL certificate.
     * key.pem: The server's SSL private key.
     * chain.pem: The SSL chain file or root certificate authority.

Note that the FreeSWITCH SSL files are constructed on the server automatically from the files listed above -- if the server certificate, key, or chain files are ever replaced, these files should be removed, and Salt's <code>state.highstate</code> should be run to rebuild them.
   * /usr/local/freeswitch/certs/agent.pem
   * /usr/local/freeswitch/certs/cafile.pem
   * /usr/local/freeswitch/certs/wss.pem

### Working with the FreeSWITCH checkout

The setup script clones a git repository for FreeSWITCH to the host machine, in the directory specified by the <code>FREESWITCH_GIT_DIR</code> setting in settings.sh (<code>${HOME}/git/freeswitch</code> by default). This directory is sync'd with the VM, which allows editing files directly from the checkout. The following directories will probably be of the most interest:
 * <code>html5/verto/verto_communicator/src</code>: The source code for Verto Communicator.

### Working with the VM
 * The virtual machine can be started, stopped, and restarted from the host using the <code>vagrant/manage-vm.sh</code> script. Run without arguments for usage.
 * The following scripts are available to be run while SSH'd into the VM:
   * <code>start-conference.sh</code>: Starts a development web server for Verto Communicator. The server will watch all files in the Verto Communicator package, and rebuild client-side assets on any changes. *NOTE: At this time, the grunt development server doesn't recognize the installed SSL certificates, so you'll most likely need to trust them manually.*
   * <code>rebuild-freeswitch.sh</code>: If the source code for FreeSWITCH is updated in your local checkout (most likely by a merge from upstream), this script can be used to rebuild FreeSWITCH.
   * <code>rebuild-conference.sh</code>: If the source code for Verto Communicator is updated such that its dependencies change, this script can be used to rebuild the dependencies.
