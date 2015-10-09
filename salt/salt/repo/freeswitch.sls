freeswitch-repo:
  pkgrepo.managed:
    - name: deb http://files.freeswitch.org/repo/deb/debian/ jessie main
    - key_url: http://files.freeswitch.org/repo/deb/debian/key.gpg
    - dist: jessie
    - file: /etc/apt/sources.list.d/99FreeSWITCH.test.list
    - require_in:
      - pkg: freeswitch-video-deps-most
