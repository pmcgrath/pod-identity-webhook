# Webhook certificate
Uses the [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx/templates/admission-webhooks) method to manage the TLS certificate
- Will create a self signed TLS certificate and create a secret
- Will patch the mutating web hook's CA bundle with the CA
- Will use jobs for above
- Used helm hooks to manage the sequencing
- Webhook deployment will fail until the TLS cert is created
- Can use variations of this to test RBAC `kubectl auth can-i get secrets/pod-identity-webhook --namespace kube-system --as system:serviceaccount:kube-system:pod-identity-webhook-admission`

Could also use (cert-manager CA injector)[https://cert-manager.io/docs/concepts/ca-injector/] which would be easier, would not need any of the jobs for TLS creation and webhook caBundle patching
- The AWS repo now recommends using this

# Webhook deployment
- Have **not** went with using cert-manager approach to creating the TLS certificate as
  - This required changing the args, see the [source](https://github.com/aws/amazon-eks-pod-identity-webhook/blob/master/main.go)
- Since this uses an image based on the [scratch image](https://github.com/aws/amazon-eks-pod-identity-webhook/blob/master/Dockerfile) with no user we cannot set much [securityContext values](https://snyk.io/blog/10-kubernetes-security-context-settings-you-should-understand/)
- Lets use 1433 as a listening port rather than 443, this we can [drop all capabilities](https://learn.snyk.io/lessons/container-does-not-drop-all-default-capabilities/kubernetes/), also see [this](https://snyk.io/blog/kubernetes-securitycontext-linux-capabilities/)

# Watch list
- Image [tag updates](https://hub.docker.com/r/amazon/amazon-eks-pod-identity-webhook/tags)
- [Issues](https://github.com/aws/amazon-eks-pod-identity-webhook/issues)
  - Issue re bumping to admission review [v1](https://github.com/aws/amazon-eks-pod-identity-webhook/issues/132)
  - Default to use [regional STS endpoints](https://github.com/aws/amazon-eks-pod-identity-webhook/issues/130)
  - Proper [health probes](https://github.com/aws/amazon-eks-pod-identity-webhook/issues/98)

# References
- [Source](https://github.com/aws/amazon-eks-pod-identity-webhook)
- [ingress-nginx kube-webhook-certgen source](https://github.com/kubernetes/ingress-nginx/tree/main/images/kube-webhook-certgen/rootfs)
- [Self hosted setup doc](https://github.com/aws/amazon-eks-pod-identity-webhook/blob/master/SELF_HOSTED_SETUP.md)

# Chart info
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| webhook.awsRegion | string | `"eu-west-1"` |  |
| webhook.hpa.enabled | bool | `false` | Assumes resource metrics are available |
| webhook.hpa.maxReplicas | int | `4` |  |
| webhook.hpa.minReplicas | int | `2` |  |
| webhook.hpa.targetCPUUtilizationPercentage | int | `80` |  |
| webhook.hpa.targetMemoryUtilizationPercentage | int | `80` |  |
| webhook.image.repository | string | `"amazon/amazon-eks-pod-identity-webhook"` | See https://hub.docker.com/r/amazon/amazon-eks-pod-identity-webhook/tags |
| webhook.image.tag | string | `"v0.3.0"` |  |
| webhook.imagePullPolicy | string | `"IfNotPresent"` |  |
| webhook.nodeSelector | object | `{}` |  |
| webhook.pdb.enabled | bool | `false` |  |
| webhook.pdb.maxUnavailable | int | `1` |  |
| webhook.pdb.minAvailable | string | `nil` |  |
| webhook.priorityClassName | string | `"system-node-critical"` |  |
| webhook.probesInitialDelaySeconds | int | `5` | Will use this for the liveness and readiness probes, allowing time for the secret creation job to populate the k8s TLS secret and the patch job to update the webhook's caBundle |
| webhook.replicaCount | int | `2` |  |
| webhook.resources.limits.cpu | string | `"20m"` |  |
| webhook.resources.limits.memory | string | `"50Mi"` |  |
| webhook.resources.requests.cpu | string | `"20m"` |  |
| webhook.resources.requests.memory | string | `"50Mi"` |  |
| webhook.serviceMonitor.enabled | bool | `false` | Need to have the prometheus operator ServiceNonitor CRD before this can be enabled |
| webhook.tolerations | list | `[]` |  |
| webhook.topologySpreadConstraints | list | `[]` | See https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/ |
| webhookAdmission.failurePolicy | string | `"Ignore"` | Danger if you set to Fail may block pod creations unless the target service is healthy |
| webhookAdmission.image | object | `{"repository":"k8s.gcr.io/ingress-nginx/kube-webhook-certgen","tag":"v1.1.1"}` | See https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml |
| webhookAdmission.imagePullPolicy | string | `"IfNotPresent"` |  |
| webhookAdmission.nodeSelector | object | `{}` |  |
| webhookAdmission.priorityClassName | string | `"system-node-critical"` |  |
| webhookAdmission.resources | object | `{"limits":{"cpu":"15m","memory":"20Mi"},"requests":{"cpu":"15m","memory":"20Mi"}}` | Have found setting this to very low values delays the pod creation and startup time, ingress-nginx does not set these, these are reasonable defaults |
| webhookAdmission.reviewVersions | list | `["v1beta1"]` | Need to use v1beta1 as the AWS image implementation returns v1beta1 responses, see https://github.com/aws/amazon-eks-pod-identity-webhook/issues/132 |
| webhookAdmission.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
