nodesource-repo:
  pkgrepo.managed:
    - humanname: NodeJS packages
    - name: deb https://deb.nodesource.com/node_10.x stretch main
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - file: /etc/apt/sources.list.d/nodesource.list
