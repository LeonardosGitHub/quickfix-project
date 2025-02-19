# Quickfix - Feb. 2025

### Building two containers using podman using https://github.com/quickfix/quickfix to run Quickfix:
1) Quickfix Client - quickfix-project-client
2) Quickfix Server - quickfix-project-server


    #### BUILDING AND INSTALLING

    - podman compose build
    - podman compose up -d
    - podman exec -it quickfix-project-client bash
        - /usr/local/bin/tradeclient /quickfix-project/config/initiator.cfg
