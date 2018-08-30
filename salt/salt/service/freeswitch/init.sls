{% from 'vars.jinja' import
  freeswitch_default_password,
  freeswitch_git_checkout,
  freeswitch_git_revision,
  freeswitch_git_url,
  freeswitch_ip,
  freeswitch_verto_external_rtp_ip,
  server_encryption_password,
  server_env,
  server_id,
  server_ssl_cert,
  server_ssl_chain,
  server_ssl_key,
  server_type
with context %}

include:
  - repo.freeswitch
  - repo.freeswitch-debian-unstable
  - misc.ssl

# Set up the dependency line for the Git checkout. This is necessary because on
# Vagrant installs the checkout is an existing linked folder on the VM.
{% set git_checkout_dependency = server_type == 'vagrant' and ('file: ' + freeswitch_git_checkout) or 'git: freeswitch-git-checkout' -%}
# git_checkout_dependency is {{ git_checkout_dependency }}

freeswitch-group:
  group.present:
    - name: freeswitch
    - system: True

freeswitch-user:
  user.present:
    - name: freeswitch
    - system: True
    - gid_from_name: True
    - fullname: "FreeSWITCH system user"
    - createhome: False
    - require:
      - group: freeswitch-group

freeswitch-video-deps-package:
  pkg.installed:
    - name: freeswitch-video-deps-most
    - refresh: True

{{ freeswitch_git_checkout }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: freeswitch-video-deps-package

{% if server_type != 'vagrant' -%}
freeswitch-git-checkout:
  git.latest:
    - name: {{ freeswitch_git_url }}
    - rev: {{ freeswitch_git_revision }}
    - target: {{ freeswitch_git_checkout }}
    # Necessary to clear any patches out before updating the repository.
    - force_checkout : True
    - require:
      - pkg: freeswitch-video-deps-package
{% endif -%}

freeswitch-build:
  cmd.script:
    - source: salt://service/freeswitch/build.sh
    - cwd: {{ freeswitch_git_checkout }}
    - use_vt: True
    - require:
      - group: freeswitch-group
      - user: freeswitch-user
{% if server_type == 'vagrant' %}
      -  {{ git_checkout_dependency }}
    - unless: test -d /usr/local/freeswitch
{% else %}
    - onchanges:
      - {{ git_checkout_dependency }}
{% endif -%}

/usr/local/freeswitch/certs:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 750
    - require:
      - cmd: freeswitch-build

clean-freeswitch-ssl-certs:
  cmd.run:
    - name: rm -f agent.pem wss.pem
    - cwd: /usr/local/freeswitch/certs
    - require:
      - file: /usr/local/freeswitch/certs
    - onchanges:
      - file: /etc/ssl/certs/cert.pem
      - file: /etc/ssl/certs/chain.pem
      - file: /etc/ssl/private/key.pem

# Alternate state name required to avoid 'Recursive requisite found' error.
Add /usr/local/freeswitch/certs/agent.pem:
  file.managed:
    - name: /usr/local/freeswitch/certs/agent.pem
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - cmd: clean-freeswitch-ssl-certs

build-agent.pem:
  file.append:
    - name: /usr/local/freeswitch/certs/agent.pem
    - sources:
      - salt://etc/ssl/{{ server_ssl_cert }}
      - salt://etc/ssl/{{ server_ssl_key }}
    - require:
      - file: Add /usr/local/freeswitch/certs/agent.pem

# Alternate state name required to avoid 'Recursive requisite found' error.
Add /usr/local/freeswitch/certs/wss.pem:
  file.managed:
    - name: /usr/local/freeswitch/certs/wss.pem
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - cmd: clean-freeswitch-ssl-certs

build-wss.pem:
  file.append:
    - name: /usr/local/freeswitch/certs/wss.pem
    - sources:
      - salt://etc/ssl/{{ server_ssl_cert }}
      - salt://etc/ssl/{{ server_ssl_key }}
      - salt://etc/ssl/{{ server_ssl_chain }}
    - require:
      - file: Add /usr/local/freeswitch/certs/wss.pem

/usr/local/freeswitch/certs/cafile.pem:
  file.managed:
    - source: salt://etc/ssl/{{ server_ssl_chain }}
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - file: /usr/local/freeswitch/certs

/usr/local/freeswitch/db:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/images:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/log:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/log/cdr-csv:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - file: /usr/local/freeswitch/log

/usr/local/freeswitch/log/xml_cdr:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - file: /usr/local/freeswitch/log

/usr/local/freeswitch/recordings:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/run:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/storage:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/custom_vars_post.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/custom_vars_post.xml.jinja
    - template: jinja
    - context:
      freeswitch_default_password: {{ freeswitch_default_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/custom_vars_pre.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/custom_vars_pre.xml.jinja
    - template: jinja
    - context:
      freeswitch_ip: {{ freeswitch_ip }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/freeswitch.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/freeswitch.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/conference.conf.xml-caller-control-vmute:
  file.line:
    - name: /usr/local/freeswitch/conf/autoload_configs/conference.conf.xml
    - mode: ensure
    - content: '<control action="mute" digits="0"/><control action="vmute" digits="*0"/>'
    - before: '<control action="deaf mute" digits="*"/>'
    - indent: True
    - require:
      - cmd: freeswitch-build

{% if freeswitch_verto_external_rtp_ip %}
/usr/local/freeswitch/conf/autoload_configs/verto.conf.xml:
  file.line:
    - mode: replace
    - content: '<param name="ext-rtp-ip" value="{{ freeswitch_verto_external_rtp_ip }}"/>'
    - match: '.*<param.+ext-rtp-ip.+>'
    - indent: True
    - require:
      - cmd: freeswitch-build
{% endif %}

/usr/local/freeswitch/conf/dialplan/default/0000-video-conference-with-moderator.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/0000-video-conference-with-moderator.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

symlink-fs-cli-to-path:
  file.symlink:
    - name: /usr/local/bin/fs_cli
    - target: /usr/local/freeswitch/bin/fs_cli
    - require:
      - cmd: freeswitch-build

/etc/sysctl.d/vid.conf:
  file.managed:
    - source: salt://etc/sysctl.d/vid.conf
    - user: root
    - group: root
    - mode: 644

/etc/sysctl.d/core-dump.conf:
  file.managed:
    - source: salt://etc/sysctl.d/core-dump.conf
    - user: root
    - group: root
    - mode: 644

# This is a dummy file that allows systemd to manage the service using Salt's
# debian_service provider.
/etc/init.d/freeswitch:
  file.managed:
    - source: salt://etc/init.d/freeswitch
    - user: root
    - group: root
    - mode: 755

/lib/systemd/system/freeswitch.service:
  file.managed:
    - source: salt://service/freeswitch/systemd-freeswitch.service.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
    - user: root
    - group: root
    - mode: 644

freeswitch-service:
  service.running:
    - name: freeswitch
    - enable: true
    - require:
      - file: /etc/init.d/freeswitch
      - file: /lib/systemd/system/freeswitch.service
    - watch:
      - file: build-agent.pem
      - file: build-wss.pem
      - file: /usr/local/freeswitch/certs/cafile.pem
      - file: /usr/local/freeswitch/conf/autoload_configs/conference.conf.xml-caller-control-vmute
      - file: /usr/local/freeswitch/conf/autoload_configs/verto.conf.xml
      - file: /usr/local/freeswitch/conf/custom_vars_pre.xml
      - file: /usr/local/freeswitch/conf/custom_vars_post.xml
      - file: /usr/local/freeswitch/conf/dialplan/default/0000-video-conference-with-moderator.xml
      - file: /usr/local/freeswitch/conf/freeswitch.xml
      - cmd: freeswitch-build

/usr/local/bin/fs:
  file.managed:
    - source: salt://service/freeswitch/fs.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
    - user: root
    - group: root
    - mode: 755

{% if server_env != 'production' -%}
/usr/local/bin/fs-debug:
  file.managed:
    - source: salt://service/freeswitch/fs-debug
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/rebuild-freeswitch.sh:
  file.managed:
    - source: salt://service/freeswitch/rebuild.sh.jinja
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: freeswitch-build
{% endif -%}

extend:
  freeswitch-repo:
    pkgrepo.managed:
      - require_in:
        - pkg: freeswitch-video-deps-package
