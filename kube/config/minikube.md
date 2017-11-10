~/.kube/config

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/username/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/username/.minikube/apiserver.crt
    client-key: /Users/username/.minikube/apiserver.key
```