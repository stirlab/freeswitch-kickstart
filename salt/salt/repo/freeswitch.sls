freeswitch-repo:
  pkgrepo.managed:
    - name: deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main
    - key_url: http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub
    - file: /etc/apt/sources.list.d/99-freeswitch.list
    - dist: jessie
    - require_in:
      - pkg: freeswitch-video-deps-most
