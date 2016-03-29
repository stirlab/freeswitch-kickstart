## Installation

### Vagrant development servers.
 1. Install an SSH keypair on the host machine if one doesn't exist already.
 1. Install [Git](http://git-scm.com), [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org). OS X [Homebrew](http://brew.sh) users, consider easy installation via [Homebrew Cask](http://caskroom.io).
 1. Run the following command to checkout this project: ```git clone https://github.com/thehunmonkgroup/freeswitch-kickstart.git```
 1. From the command line, change to the <code>vagrant</code> directory, and you'll find <code>settings.sh.example</code>. Copy that file in the same directory to <code>settings.sh</code>.
 1. Edit to taste, the default values (which are the commented out values in the example config) will most likely work just fine.
 1. Follow instructions below for configuring pillar data and SSL certs.
 1. From the command line, run <code>./development-environment-init.sh</code>.
 1. Once the script successfully completes the pre-flight checks, it will automatically handle the rest of the installation and setup. Relax, grab a cup of chai, and watch the setup process roll by on screen. :)
 1. If the setup script finds an SSH pubkey in the default location of the host's HOME directory, it will automatically install that pubkey to the VM. The end of the script outputs optional configuration you can add to your <code>.ssh/config</code> file, to enable easy root SSH access to the server.
 1. SSH into the VM, and as root, run ```start-conference.sh```
 1. Visit <code>https://dev.freeswitch.local:9001</code> in your browser, and you should see the main page for FreeSWTICH's [Verto Communicator](https://freeswitch.org/confluence/display/FREESWITCH/Verto+Communicator).
 1. Try out a video call! *(the defaults under the 'Settings' link should work without adjustment)*
 1. The installed virtual machine can be controlled like any other Vagrant VM. See [this Vagrant cheat sheet](http://notes.jerzygangi.com/vagrant-cheat-sheet) for more details.
 1. If for any reason the installation fails, or you just want to completely remove the installed virtual machine, run the <code>vagrant/kill-development-environment.sh</code> script from the command line.

##### Working with the Vagrant FreeSWITCH checkout

The setup script clones a git repository for FreeSWITCH to the host machine, in the directory specified by the <code>FREESWITCH_GIT_DIR</code> setting in <code>settings.sh</code> (<code>${HOME}/git/freeswitch</code> by default). This directory is sync'd with the VM, which allows editing files directly from the checkout. Once the initial setup of the source code repository is done, you have full control over what branch/tag/commit to rebuild FreeSWITCH from *(default is to build from latest master)*.

The following directories will probably be of the most interest:
 * <code>src</code>: The source code for FreeSWITCH.
 * <code>html5/verto/verto_communicator/src</code>: The source code for Verto Communicator.

##### Working with the Vagrant VM
 * The virtual machine can be started, stopped, and restarted from the host using the <code>vagrant/manage-vm.sh</code> script. Run without arguments for usage.
 * The following scripts are available to be run while SSH'd into the VM:
   * <code>start-conference.sh</code>: Starts a development web server for Verto Communicator. The server will watch all files in the Verto Communicator package, and rebuild client-side assets on any changes.
   * <code>rebuild-freeswitch.sh</code>: If the source code for FreeSWITCH is updated in your local checkout (most likely by a merge from upstream), this script can be used to rebuild FreeSWITCH.
   * <code>rebuild-conference.sh</code>: If the source code for Verto Communicator is updated such that its dependencies change, this script can be used to rebuild the dependencies.

### Remote (usually production) servers.
 1. Start with a fresh [Debian 8.x](https://www.debian.org/releases/jessie) install.
 1. Make sure the hostname of the server is set to the fully qualified domain name wanted for the installation. You can use the hostname command to set it, eg. ```hostname www.example.com```
 1. Load ```production/debian_bootstrap.sh``` to the server, make sure it's executable, and execute it.
 1. When it completes, follow the instructions below for configuring pillar data and SSL certs *(the bootstrap script installs freeswitch-kickstart at <code>/var/local/git/freeswitch-kickstart</code>)*.
 1. Run ```salt-call state.highstate```

##### Working with the remote server

 * It's important to note that the default Salt configuration is set up to trigger a rebuild of FreeSWITCH if the configured <code>software:freeswitch:git:revision</code> pillar setting is updated with new commits (this can happen if the setting is pointing to a branch). Since the default setting is <code>master</code>, you are highly encouraged to set this to something stable on your production server! *(like a commit hash or tag, or a stable branch used for production rollouts).
 * The following scripts are available to be run on the server:
   * <code>rebuild-conference.sh</code>: If the source code for Verto Communicator is updated, this script can be used to rebuild it.

### Configuring pillar data

 * In the <code>salt/pillar/server</code> directory, you'll find an example configuration file.
 * Copy the file in the same directory, removing the .example extension. Use the appropriate example based on the installation environment *(<code>development.sls</code> for development/Vagrant installs, <code>production.sls</code> for production installs)*.
 * Edit the configurations to taste. You can reference <code>salt/salt/vars.jinja</code> to see what variables are available, and the defaults for each.

### Configuring SSL certificates

You need valid SSL certificates in order for WebRTC to function properly, there are two options, easy and hard:

 1. Easy (recommended for Vagrant installs):
   * Import <code>salt/salt/etc/ssl/cert.pem</code> as a trusted CA in your browser, and use the default configured <code>dev.freeswitch.local</code> domain. It should be pretty easy to find instructions to import the certificate into all major browsers. Technically, you don't even have to import the certificate, it just avoids brower security warnings.

 1. Hard (recommended for production servers):
   * Get some from a SSL certificates from a provider. Note that the common name of the certificate must match the hostname on production servers, and the <code>SALT_MINION_ID</code> setting in <code>settings.sh</code> for Vagrant installs -- this allows Salt to auto configure the setup.
   * Place the following files into the <code>salt/salt/etc/ssl/</code> directory:
     * The server's SSL certificate.
     * The server's SSL private key.
     * The SSL chain file or root certificate authority.
   * In the pillar configuration, set the names of each file you installed in the <code>server:ssl</code> section *(see <code>production.sls.example</code> for the correct approach).

### Caveats

 * The Salt bootstrapping process can take quite awhile, so be patient.
 * If some of the Salt configuration steps fail, it's most often some kind of transient error (network or server glitch or outage) -- usually running <code>salt-call state.highstate</code> again will rectify the errors.
 * The project intends to support only the latest development branch installation by default, older branches may also install, but will not be actively maintained.
 * None of the bootstrapping scripts will work on Windows.
