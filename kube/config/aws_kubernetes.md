~/.kube/config

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: VERYLONGSTRING
    server: https://52.32.34.173
  name: aws_kubernetes
contexts:
- context:
    cluster: aws_kubernetes
    user: aws_kubernetes
  name: aws_kubernetes
current-context: aws_kubernetes
kind: Config
preferences: {}
users:
- name: aws_kubernetes
  user:
    client-certificate-data: VERYLONGSTRING
    client-key-data: VERYLONGSTRING
    token: 6YkrOgBXQXCgeATdTiAzc6diZk6VwMfR
- name: aws_kubernetes-basic-auth
  user:
    password: XXXXXXXXXXXXXXXX
    username: admin
```
