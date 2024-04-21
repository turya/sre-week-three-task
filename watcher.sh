#!/bin/bash

NAMESPACE=sre
DEPLOYMENT=swype-app
MAX_RESTARTS=5
SECONDS_BETWEEN_CHECKS=60

while true; do 
    RESTARTS=$(kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT} -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")

    if [ -z "$RESTARTS" ]; then
        echo "No pods found or unable to fetch restart count."
    else
        echo "Current number of restarts = ${RESTARTS}"

        if (( RESTARTS > MAX_RESTARTS )); then
            echo "Maximum Restarts Exceeded (${MAX_RESTARTS}). Shutting down the ${DEPLOYMENT} service."
            kubectl scale --replicas=0 deployment/${DEPLOYMENT} -n ${NAMESPACE}
            break 
        fi
    fi

    # pause between system checks 
    sleep $SECONDS_BETWEEN_CHECKS
done