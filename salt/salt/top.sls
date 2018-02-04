{% from 'vars.jinja' import server_env with context -%}

base:
  '*':
    - early-packages
    - update-packages
    - base-packages
    - service.firewall
    - service.network
    - auth.root
    - service.ssh
    - repo
    - misc
    - software.git
    - software.nvm
    - software.misc
    - service.salt-minion
    - service.ntp
    - service.postfix
    - service.httpd
    - service.freeswitch
    - service.freeswitch.verto-demo
    - service.freeswitch.verto-communicator
    # Run 'salt-call state.sls service.freeswitch.verto-demo.vids' to install,
    # or uncomment this line.
    # - service.freeswitch.verto-demo.vids
