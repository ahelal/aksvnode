#!/bin/sh
set -eu
rm -rf generated
mkdir -p generated

create_app(){
    TEMPLATE="${1}"
    APP_NAME="${2}"
    APP_SERVICES="${3}"
    echo "Generating ${APP_NAME}.yml"
    cat "template-ping-${TEMPLATE}.yml" \
            | sed -e "s/\${DOCKER_URL}/${DOCKER_URL}/" \
            | sed -e "s/\${APP_NAME}/${APP_NAME}/" \
            | sed -e "s/\${APP_SERVICES}/${APP_SERVICES}/" \
            > "generated/${APP_NAME}.yml"
}

# Create AKS
create_app "aks" "ping-a" "ping-b,ping-c,ping-1,ping-2,ping-3"
create_app "aks" "ping-b" "ping-a,ping-c,ping-1,ping-2,ping-3"
create_app "aks" "ping-c" "ping-a,ping-b,ping-1,ping-2,ping-3"
# Create ACI
create_app "aci" "ping-1" "ping-a,ping-b,ping-c,ping-2,ping-3"
create_app "aci" "ping-2" "ping-a,ping-b,ping-c,ping-1,ping-3"
create_app "aci" "ping-3" "ping-a,ping-b,ping-c,ping-1,ping-2"