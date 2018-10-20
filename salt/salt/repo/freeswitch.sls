freeswitch-repo:
  pkgrepo.managed:
    - humanname: FreeSWITCH packages
    - name: deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main
    - key_url: https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc
    - file: /etc/apt/sources.list.d/99-freeswitch.list

freeswitch-src-repo:
  pkgrepo.managed:
    - humanname: FreeSWITCH source packages
    - name: deb-src http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main
    - key_url: https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc
    - file: /etc/apt/sources.list.d/99-freeswitch-src.list
