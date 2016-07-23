{% from 'vars.jinja' import
  freeswitch_git_checkout,
  freeswitch_default_password,
  server_env,
  server_type
with context %}

include:
  - service.npm
  - service.freeswitch
  - service.httpd

{{ freeswitch_git_checkout }}/html5/verto/verto_communicator/src/config.json:
  file.managed:
    - source: salt://service/freeswitch/verto-communicator/config.json.jinja
    - template: jinja
    - context:
      freeswitch_default_password: {{ freeswitch_default_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

verto-communicator-node-packages:
  npm.installed:
    - pkgs:
      - bower
      - grunt
      - grunt-cli
    - require:
      - pkg: npm-package

npm-bootstrap-verto-communicator:
  npm.bootstrap:
    - name: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    # This effectively freezes the node modules, similar to how bower is below.
    - unless: test -d {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/node_modules
    - require:
      - npm: verto-communicator-node-packages

bower-bootstrap-verto-communicator:
  cmd.run:
    - name: /usr/local/bin/bower --allow-root --config.interactive=false install -F
    - cwd: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - unless: test -d {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/bower_components
    - use_vt: True
    - require:
      - npm: npm-bootstrap-verto-communicator

/usr/local/bin/rebuild-conference.sh:
  file.managed:
    - source: salt://service/freeswitch/verto-communicator/rebuild-conference.sh.jinja
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: bower-bootstrap-verto-communicator

{% if server_env == 'development' %}
/usr/local/bin/start-conference.sh:
  file.managed:
    - source: salt://service/freeswitch/verto-communicator/start-conference.sh.jinja
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: bower-bootstrap-verto-communicator
{% else -%}
verto-dist-build:
  cmd.run:
    - name: /usr/local/bin/grunt build
    - cwd: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - unless: test -d {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/dist
    - use_vt: True
    - require:
      - cmd: bower-bootstrap-verto-communicator

verto-communicator-symlink-html:
  file.symlink:
    - name: /var/www/html/verto-communicator
    - target: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/dist
    - require:
      - cmd: verto-dist-build
      - pkg: httpd-packages
{% endif -%}

