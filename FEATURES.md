# Features

Some features are only activated in either the development or production environments, and are noted as such below.

### The big ones you probably care most about

 * Setup script for a fully functional [Vagrant](https://www.vagrantup.com) development environment
 * FreeSWITCH setup:
   * Install FreeSWITCH repositories
   * Install video dependencies
   * Set up freeswitch system user/group
   * Check out FreeSWITCH code base
   * Compile
   * Install vanilla configs
   * Install 36xx videoconference extensions with support for moderator access
   * Configure IP address correctly based on environment
   * Set default password (both in FreeSWITCH config and Verto Communicator config)
   * Install ```fs``` executable, handy shortcut for logging into FreeSWITCH CLI
   * Install ```fs-debug``` executable, handy shortcut for logging into FreeSWITCH CLI with core dump enabled (dev only)
   * Install helper script for rebuilding FreeSWITCH (dev only)
 * [Verto Communicator](https://freeswitch.org/confluence/display/FREESWITCH/Verto+Communicator) setup:
   * Install node and all dependencies
   * Install bower and all dependencies
   * Install helper script for rebuilding
   * Build production-ready bundle (prod only)
   * Install helper script for running live reload server in development environments (dev only)
 * Configure Apache to serve Verto examples from these paths:
   * /verto-communicator: [Verto Communicator](https://freeswitch.org/confluence/display/FREESWITCH/Verto+Communicator)
   * /verto-video-demo: Original Verto video example (dev only)
   * /verto-demo: Original Verto audio example (dev only)
 * Install/configure SSL certs automatically based on configuration, for both Apache and FreeSWITCH
 * Install helper script for managing Vagrant virtual machine
 * Set up root SSH access (automatically for Vagrant, based on config for remote/production)
 * Set up ```.fs_cli_conf``` for passwordless access to ```fs_cli``` executable
 * Optionally set up a ```.bashrc``` for the root user, with some helpful shortcut commands for getting around the FreeSWITCH installation *(run ```alias``` from command line to see them)*

### Other stuff that also helps you!

 * Different actions taken based on the server environment Salt pillar setting (development or production builds)
 * Share common configuration across build environments in the ```common.sls``` file.
 * Bootstrap script for remote/production servers, which properly sets up the freeswitch-kickstart checkout and Salt
 * Script to automatically remove Vagrant VM.
 * Configure a secure firewall (using [Shorewall](http://shorewall.net))
 * Set up all necessary services (Apache, FreeSWITCH, etc) to start on boot.
 * Optimize kernel settings for video
 * Set up core dump capability for development environments
 * Configure timezone and hostname.
 * Set up NTP
 * Basic Postfix setup
 * Install git, sox, and a bunch of other generally useful tools not always installed by default *(see ```salt/salt/base-packages.sls``` for a fairly comprehensive list)*
 * Set up /root/bin
