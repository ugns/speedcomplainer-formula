{% from 'speedcomplainer/map.jinja' import speedcomplainer with context -%}

speedcomplainer:
  git.latest:
    - name: {{ speedcomplainer.source }}
    - rev: master
    - target: {{ speedcomplainer.virtualenv }}
    - force_reset: True
    - force_fetch: True
    - watch_in:
      - service: speedcomplainer

  virtualenv.managed:
    - name: {{ speedcomplainer.virtualenv }}
    - requirements: {{ speedcomplainer.virtualenv }}/requirements.txt
    - require:
      - git: speedcomplainer

  service.running:
    - enable: True
    - require:
      - file: speedcomplainer_config
      - file: speedcomplainer_init
    - order: last

speedcomplainer_init:
  file.managed:
    - name: {{ speedcomplainer.init_script }}
    - source: salt://speedcomplainer/files/{{ grains.init }}
    - mode: {{ speedcomplainer.init_mode }}
    - template: jinja
    - context:
        venv_path: {{ speedcomplainer.virtualenv }}
    - require:
      - virtualenv: speedcomplainer

speedcomplainer_config:
  file.managed:
    - name: {{ speedcomplainer.virtualenv }}/config.json
    - source: salt://speedcomplainer/files/{{ grains.init }}
    - mode: 600
    - template: jinja
    - context:
        config: {{ speedcomplainer.config }}
    - contents_newline: True
    - require:
      - git: speedcomplainer
    - watch_in:
      - service: speedcomplainer
