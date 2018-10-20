include:
  - software.nodejs

nodemon-package:
  npm.installed:
    - name: nodemon
    - user: root
    - require:
      - pkg: nodejs-packages

