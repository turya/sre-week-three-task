# UpCommerce

## To operate:

If K8's is not already running:

```sh
minikube start
```

Once running, create the sre namespace in K8s:

```sh
kubectl create namespace sre
```

Deploy the project resources:

```sh
kubectl apply -f upcommerce-deployment.yml -n sre
kubectl apply -f swype-deployment.yml -n sre
```

## Monitoring and Automatic Remediation using the watcher.sh script.

At the time of this writing, we've been experiencing issues with the Swype.com payment provider service.  To alleviate this issue, we monitor the swype app binary and shut it down (by setting it's replicates to 0) if it experiences too many restarts.  To launch the monitor:

```sh
nohup bash watcher.sh </dev/null >> /tmp/swype-monitor.log 2>&1 &
```

This will run in the background and save the logs to /tmp/swype-monitor.log.  (The "</dev/null" suppreses the "nohup: ignoring input" message).

You can monitor the output of the script

```sh
tail -f /tmp/swype-monitor.log
```

To shut down the background process, you can use:

```sh
pkill -f '^bash watcher.sh'
```




## Potential tools for reducing toil

Our alert system is currently generating too many redundant tickets, creating unecessary toil.

We definitely need to capture all of these alerts, but we don't need tickets for all of them.

We're already using Prometheus and Grafana-we should be using these tools to identify trends and adjust alerting thresholds. 

Where remediation is known, we can continue to write bash scripts to monitor the alert stream, or we could consider using more advanced tools like Ansible or Rundeck.

We could consider looking into software like Pager Duty or Opsgenie to process our alert stream and consolidate/deduplicate redundant alerts.

We might consider using more advanced tools for consolidating and processing our alert logs, like Datadog or Splunk.

There are newer "AI" based systems like BigPanda and Moogsoft that claim to offer AI enhanced observability.

There are also tools like ServiceNow or JIRA Service Managment that can automatically process alert streams and prioritize and coordinate incident response.