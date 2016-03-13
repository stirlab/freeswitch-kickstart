{% from 'vars.jinja' import
  freeswitch_default_password,
  freeswitch_git_checkout,
  freeswitch_git_revision,
  freeswitch_git_url,
  freeswitch_ip,
  server_encryption_password,
  server_env,
  server_id,
  server_type
with context %}

include:
  - repo.freeswitch
  - service.httpd

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

freeswitch-repo-deps-setenv:
  environ.setenv:
    - value:
        DEBIAN_FRONTEND: none
        APT_LISTCHANGES_FRONTEND: none
    - update_minion: True
    # Not the cleanest test, but it prevents the state from unnecessarily
    # re-executing.
    - unless: test -d /usr/share/doc/freeswitch-video-deps-most

freeswitch-video-deps-package:
  pkg.installed:
    - pkgs:
      # These packages are not included with the video-deps meta package,
      # and are required to build mod_av.
      - libyuv-dev
      - libvpx2-dev
      - freeswitch-video-deps-most
    - refresh: True
    - require:
      - environ: freeswitch-repo-deps-setenv

freeswitch-repo-deps-rmenv:
  environ.setenv:
    - false_unsets: True
    - value:
        DEBIAN_FRONTEND: False
        APT_LISTCHANGES_FRONTEND: False
    - update_minion: True
    - require:
      - pkg: freeswitch-video-deps-package
    # Not the cleanest test, but it prevents the state from unnecessarily
    # re-executing.
    - unless: test -d /usr/share/doc/freeswitch-video-deps-most

freeswitch-build:
  cmd.script:
    - source: salt://service/freeswitch/build.sh
    - cwd: {{ freeswitch_git_checkout }}
    - use_vt: True
    - require:
      - group: freeswitch-group
      - user: freeswitch-user
      - pkg: freeswitch-video-deps-package
    - unless: test -d /usr/local/freeswitch

/usr/local/freeswitch/certs:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 750
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/certs/agent.pem:
  file.managed:
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - file: /usr/local/freeswitch/certs

build-agent.pem:
  file.append:
    - name: /usr/local/freeswitch/certs/agent.pem
    - sources:
      - salt://etc/ssl/cert.pem
      - salt://etc/ssl/key.pem
    - require:
      - file: /usr/local/freeswitch/certs
      - file: /etc/ssl/certs/cert.pem
      - file: /etc/ssl/private/key.pem

/usr/local/freeswitch/certs/wss.pem:
  file.managed:
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - file: /usr/local/freeswitch/certs

build-wss.pem:
  file.append:
    - name: /usr/local/freeswitch/certs/wss.pem
    - sources:
      - salt://etc/ssl/cert.pem
      - salt://etc/ssl/key.pem
      - salt://etc/ssl/chain.pem
    - require:
      - file: /usr/local/freeswitch/certs
      - file: /etc/ssl/certs/cert.pem
      - file: /etc/ssl/private/key.pem
      - file: /etc/ssl/certs/chain.pem

/usr/local/freeswitch/certs/cafile.pem:
  file.managed:
    - source: salt://etc/ssl/chain.pem
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
      freeswitch_ip: {{ freeswitch_ip }}
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
      - file: /usr/local/freeswitch/conf/custom_vars_pre.xml
      - file: /usr/local/freeswitch/conf/custom_vars_post.xml
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

extend:
  freeswitch-repo:
    pkgrepo.managed:
      - require_in:
        - pkg: freeswitch-video-deps-package
