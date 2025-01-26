# DevContainer Configuration

[DevContainer](https://code.visualstudio.com/docs/devcontainers/containers) is a VSCode feature that allows developers to share a common workspace definition, by leveraging Docker to run the workspace, and using VSCode Remote Development extension, you can make sure the developer experience is the same across different computers

## Benefits

- Developers only need to have VSCode and Docker installed
- All dependencies necessary to work in the repository are contained in the docker image
- Makes it easier for new developers to start contributing to the project
- No extra setup required

### [Post-installation checklist](https://z2jh.jupyter.org/en/stable/jupyterhub/index.html)

export K8S_NAMESPACE='devex'

  - Verify that created Pods enter a Running state:

      kubectl --namespace=devex get pod

    If a pod is stuck with a Pending or ContainerCreating status, diagnose with:

      kubectl --namespace=devex describe pod <name_of_pod>

    If a pod keeps restarting, diagnose with:

      kubectl --namespace=devex logs --previous <name_of_pod>

  - Verify an external IP is provided for the k8s Service proxy-public.

      kubectl --namespace=devex get service proxy-public

    If the external ip remains <pending>, diagnose with:

      kubectl --namespace=devex describe service proxy-public

  - Verify web based access:

    You have not configured a k8s Ingress resource so you need to access the k8s
    Service proxy-public directly.

    If your computer is outside the k8s cluster, you can port-forward traffic to
    the k8s Service proxy-public with kubectl to access it from your
    computer.

      kubectl --namespace=devex port-forward service/proxy-public 8080:http

    Try insecure HTTP access: http://localhost:8080


### Simplified DevEx in bare-metal:

- [x] 3x K3s Clusters (DevExCluster, QA, Prod)

- [ ] Kubernetes (vanilla kubeadm installation) LB (Haproxy) + 3x control-planes + N workers

- [ ] ArgoCD + Ingress + Monitoring/Logging stack (Grafana, Prometheus, Opensearch)

- [ ] Github, Gitlab, Bitbucket.

- [ ] Basically, you promote your app from Dev -> Prod deploying you code in Github and ArgoCD sync does the rest.
