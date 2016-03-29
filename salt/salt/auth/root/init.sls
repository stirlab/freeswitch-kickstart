{% from 'vars.jinja' import
  server_env,
  ssh_pubkeys_root,
  server_encryption_password,
  freeswitch_ip,
  user_root_install_bashrc
with context %}

{% for user, data in ssh_pubkeys_root.iteritems() %}
sshkey-{{ user }}:
  ssh_auth:
    - present
    - user: root
    - enc: {{ data.enc|default('ssh-rsa') }}
    - name: {{ data.key }}
    - comment: {{ user }}
{% endfor %}

/root/.fs_cli_conf:
  file.managed:
    - template: jinja
    - context:
      server_encryption_password: {{ server_encryption_password }}
    - source: salt://auth/root/fs_cli_conf.jinja
    - user: root
    - group: root
    - mode: 644

/root/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

{% if user_root_install_bashrc %}
/root/.bashrc:
  file.managed:
    - source: salt://auth/root/bashrc
    - user: root
    - group: root
    - mode: 644
{% endif %}
