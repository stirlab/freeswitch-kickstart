freeswitch-debian-unstable-repo:
  pkgrepo.managed:
    - name: deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main
    - key_url: https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub
    - file: /etc/apt/sources.list.d/99-freeswitch-debian-unstable.list
    - dist: jessie
    - require_in:
      - pkg: freeswitch-video-deps-most
