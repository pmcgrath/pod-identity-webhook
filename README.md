# Webhook certificate
Uses the [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx/templates/admission-webhooks) method to manage the TLS certificate
- Will create a self signed TLS certificate and create a secret
- Will patch the mutating web hook's CA bundle with the CA
- Will use jobs for above
- Used helm hooks to manage the sequencing
- Webhook deployment will fail until the TLS cert is created
- Can use variations of to test RBAC `kubectl auth can-i get secrets/pod-identity-webhook --namespace kube-system --as system:serviceaccount:kube-system:pod-identity-webhook-admission`



# Webhook deployment
- Have **not** went with using k8s CSR approach to creating the TLS certificate as
  - The implementation is using a deprecated version, would need a signerName
  - Would need to approve the k8s CSR
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
