#!/bin/bash

script_path=$(dirname "$0")

/bin/bash $script_path/../jupyterhub/validate.sh
/bin/bash $script_path/../postgresql/validate.sh
/bin/bash $script_path/../grafana/validate.sh
/bin/bash $script_path/../cert-manager/validate.sh
/bin/bash $script_path/../kafka/validate.sh
/bin/bash $script_path/../minio/validate.sh
/bin/bash $script_path/../apisix/validate.sh
/bin/bash $script_path/../prometheus/validate.sh
/bin/bash $script_path/../mongodb/validate.sh
