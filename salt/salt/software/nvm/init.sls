{% from 'vars.jinja' import
  nvm_install_path,
  nvm_node_versions,
  nvm_revision,
with context %}

include:
  - auth.root

nvm-dependencies:
  pkg.installed:
    - pkgs:
      - g++
      - build-essential
      - libssl-dev
      - gcc

nvm-checkout:
  git.latest:
    - name: https://github.com/creationix/nvm.git
    - rev: {{ nvm_revision }}
    - target: {{ nvm_install_path }}
    - force_checkout: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: nvm-dependencies

/etc/profile.d/nvm.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        if [ -f "{{ nvm_install_path }}/nvm.sh" ]; then
          . {{ nvm_install_path }}/nvm.sh
        fi
    - require:
      - git: nvm-checkout

{% for version in nvm_node_versions %}
nvm-install-{{ version }}:
  cmd.run:
    - name: . {{ nvm_install_path }}/nvm.sh && nvm install {{ version }}
    - unless: . {{ nvm_install_path }}/nvm.sh && nvm ls {{ version }}
    - shell: /bin/bash
    - use_vt: True
    - require:
      - git: nvm-checkout
{% endfor %}
