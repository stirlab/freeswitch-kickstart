# This is the very first state executed, mostly because we want these critical
# packages available as soon as possible.
early-packages:
  pkg.installed:
    - order: 1
    - pkgs:
      - curl
      - perl
      - wget

