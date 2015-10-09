{% from 'vars.jinja' import server_env with context %}

base-packages:
  pkg.installed:
    - pkgs:
      - aptitude
      - bash-completion
      - colordiff
      - file
      - htop
      - logwatch
      - lynx
      - man
      - mutt
      - patch
      - patchutils
      - tcpdump
      - telnet
      - tmux
      - traceroute
      - unzip
      - vim
      - gdb
    - order: 3

