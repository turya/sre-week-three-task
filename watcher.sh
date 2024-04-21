#!/bin/bash

NAMESPACE=sre
DEPLOYMENT=swype-app
MAX_RESTARTS=5
SECONDS_BETWEEN_CHECKS=60

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "$TIMESTAMP: Starting restart monitor for ${DEPLOYMENT} in namespace ${NAMESPACE}"

while true; do 
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    RUNNING_PODS=$(kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT} -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')

    if [ -z "$RUNNING_PODS" ]; then
        echo "${TIMESTAMP}: No running pods found for ${DEPLOYMENT}."
    else
        RESTARTS=$(kubectl get pod $(echo $RUNNING_PODS | awk '{print $1}') -n ${NAMESPACE} -o jsonpath='{.status.containerStatuses[0].restartCount}')
        if [ -z "$RESTARTS" ]; then
            echo "${TIMESTAMP}: Unable to fetch restart count."
        else
            echo "${TIMESTAMP}: Current number of restarts = ${RESTARTS}"

            if (( RESTARTS > MAX_RESTARTS )); then
                echo "${TIMESTAMP}S: Maximum Restarts Exceeded (${MAX_RESTARTS}). Shutting down the ${DEPLOYMENT} service."
                kubectl scale --replicas=0 deployment/${DEPLOYMENT} -n ${NAMESPACE}
               break 
            fi
        fi
    fi

    # pause between system checks 
    sleep $SECONDS_BETWEEN_CHECKS
done