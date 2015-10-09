nodejs-packages:
  pkg.installed:
    - pkgs:
      - nodejs
      - nodejs-legacy

/usr/local/node:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: nodejs-packages

node-group:
  group.present:
    - name: node
    - system: True
    - require:
      - pkg: nodejs-packages

node-user:
  user.present:
    - name: node
    - system: True
    - gid_from_name: True
    - fullname: "NodeJS system user"
    - home: /usr/local/node
    - createhome: False
    - require:
      - pkg: nodejs-packages
      - group: node-group
      - file: /usr/local/node

/var/log/node:
  file.directory:
    - user: node
    - group: node
    - dir_mode: 755
    - require:
      - user: node-user
      - group: node-group
