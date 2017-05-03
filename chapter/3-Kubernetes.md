# Kubernetes

## Main Objects

- Pods
- Replica Set
- Jobs
- Volumes
- Services
- Deployments

### Pods

```
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  labels:
    name: webapp
spec:
  containers:
  - image: pacuna/webapp:d15587c
    name: webapp
    env:
    - name: PASSENGER_APP_ENV
        value: production
      ports:
      - containerPort: 80
        name: webapp
      imagePullPolicy: Always
```

### Replica Set

```
apiVersion: extensions/v1beta1
kind: ReplicaSet
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  replicas: 3
  template:
    metadata:
      labels:
app: webapp
        tier: frontend
    spec:
      containers:
      - image: pacuna/webapp:d15587c
        name: webapp
        env:
        - name: PASSENGER_APP_ENV
          value: production
        ports:
        - containerPort: 80
          name: webapp
        imagePullPolicy: Always
```

### Jobs

```
apiVersion: batch/v1
kind: Job
metadata:
  name: setup
spec:
  template:
    metadata:
      name: setup
    spec:
      containers:
      - name: setup
          image: pacuna/webapp:ec4421
          command: ["./bin/rails", "db:migrate", "RAILS_ENV=production"]
          env:
          - name: PASSENGER_APP_ENV
            value: production
        restartPolicy: Never
```

### Volumes

```
spec:
  containers:
  - image: postgres:9.5.3
    name: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: mysecretpassword
    - name: POSTGRES_USER
      value: webapp
    - name: POSTGRES_DB
      value: webapp_production
    - name: PGDATA
      value: /var/lib/postgresql/data/pgdata
    ports:
    - containerPort: 5432
      name: postgres
    volumeMounts:
      - name: postgres-persistent-storage
        mountPath: /var/lib/postgresql/data
  volumes:
    - name: postgres-persistent-storage
      awsElasticBlockStore:
        volumeID: vol-fe268f4a
        fsType: ext4
```

### Services

```
apiVersion: v1
kind: Service
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  ports:
    - port: 80
 selector:
   app: webapp
   tier: frontend
type: LoadBalancer
```

### Deployments

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: postgres
  labels:
    app: webapp
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
app: webapp
        tier: postgres
    spec:
      containers:
      - image: postgres:9.5.3
        name: postgres
        env:
        - name: POSTGRES_PASSWORD
          value: mysecretpassword
        - name: POSTGRES_USER
          value: webapp
        - name: POSTGRES_DB
          value: webapp_production
        ports:
        - containerPort: 5432
          name: postgres
```

## Structuring the Files

```
$ mkdir -p kube
$ mkdir -p kube/deployments
$ mkdir -p kube/jobs
```

## Templates

### PostgreSQL

```
$ touch kube/deployments/postgres-deployment.yaml
```

### Setup Container

```
$ touch kube/jobs/setup-job.yaml
```

### Web Application

```
$ touch kube/deployments/webapp-deployment.yaml
```

## Minikube

https://github.com/kubernetes/minikube

### kubectl

https://kubernetes.io/docs/getting-started-guides/minikube/#download-kubectl

### Start Minikube

```
$ kubectl version
v1.6.0
$ minikube start --vm-driver=xhyve --kubernetes-version="v1.6.0"
Or
$ minikube start

$ minikube ip
$ minikube dashborad
```

### Running Our Templates with Minikube

```
$ kubectl create -f kube/deployments/postgres-deployment.yaml
$ kubectl describe deployment postgres
$ kubectl describe Pod postgres
$ kubectl create -f kube/jobs/setup-job.yaml
$ Pods=$(kubectl get Pods --selector=job-name=setup --output=jsonpath={.items..metadata.name})
$ kubectl logs $Pods
# To see only PostgreSQL pod
$ kubectl get Pods
$ kubectl create -f kube/deployments/webapp-deployment.yaml
$ kubectl get Pods
postgres-xxxxxxxx Running
webapp-xxxxxxxxx1 Running
webapp-xxxxxxxxx2 Running
webapp-xxxxxxxxx3 Running
$ kubectl logs webapp-xxxxxxxxx1
# Open browser to see web application
$ minikube service webapp

# Find NodePort
$ kubectl describe service webapp
Got IP and NodePort such as: http://192.168.64.7:30028
# Make a curl POST request to the end point:
$ curl -H "Content-Type: application/json" -X POST -d '{"title":"my first article","body":"Lorem ipsum dolor sit amet, consectetur adipiscing elit..."}' http://192.168.64.7:30028/articles
{"id":1,"title":"my first article","body":"Lorem ipsum dolor sit amet, consectetur adipiscing elit...","created_at":"2017-05-03T04:36:14.706Z","updated_at":"2017-05-03T04:36:14.706Z"}%
```

## Launching an AWS Kubernetes Cluster

```
$ kubectl config current-context
minikube
```

https://kubernetes.io/docs/getting-started-guides/aws/

Add to `~/.zshrc` and source it:
```
export NUM_NODES=2
export NODE_SIZE=t2.small
```

```
$ export KUBERNETES_PROVIDER=aws; curl -sS https://get.k8s.io | bash
# Check `~/.kube/config` if added `aws_kubernetes-basic-auth` name
$ kubectl config current-context
aws_kubernetes
```

Dashboard
https://52.32.34.173/ui

Because of the kubernetes version trouble, can't do this step now.

## Running the Templates in Production

```
$ docker-compose run --rm webapp bin/rake secret RAILS_ENV=production
# Change
config/secrets.yml
config/database.yml
$ kubectl delete -f kube/deployments/postgres-deployment.yaml
$ kubectl create -f kube/deployments/postgres-deployment.yaml

$ touch setup.production.sh
$ chmod +x setup.production.sh

$ git add .
$ git commit -m 'add production templates'
$ ./push.sh

$ git rev-parse --short HEAD
$ docker images
# Change new tag
kube/jobs/setup-job.yaml
$ kubectl delete -f kube/jobs/setup-job.yaml
$ kubectl create -f kube/jobs/setup-job.yaml

# Change new tag
kube/deployments/webapp-deployment.yaml
$ kubectl delete -f kube/deployments/webapp-deployment.yaml
$ kubectl create -f kube/deployments/webapp-deployment.yaml
$ kubectl describe service webapp
$ kubectl describe deployment webapp

$ curl -H "Content-Type: application/json" -X POST -d '{"title":"my first article","body":"Lorem ipsum dolor sit amet, consectetur adipiscing elit..."}' http://a333dae17845a11e6b47b06103f11903-585648094.us-west-2.elb.amazonaws.com/articles
{"id":1,"title":"my first article","body":"Lorem ipsum dolor sit amet,consectetur adipiscing elit...","created_at":"2016-09-27T03:07:36.706Z","updated_at":"2016-09-27T03:07:36.706Z"}%
```

## Adding Persistence

```
$ aws ec2 create-volume --region us-west-2 --availability-zone us-west-2a --size 10 --volume-type gp2
Add `awsElasticBlockStore` to kube/deployments/postgres-deployment.yaml
$ kubectl delete -f kube/deployments/postgres-deployment.yaml
$ kubectl create -f kube/deployments/postgres-deployment.yaml
$ kubectl describe rs postgres

$ aws ec2 describe-volumes --volume-ids vol-fe268f4a --region us-west-2

$ kubectl delete job/setup
$ kubectl create -f kube/jobs/setup-job.yaml
$ Pods=$(kubectl get Pods --selector=job-name=setup --output=jsonpath={.items..metadata.name})
$ kubectl logs $Pods

$ curl -H "Content-Type: application/json" -X POST -d '{"title":"my first article","body":"Lorem ipsum dolor sit amet, consectetur adipiscing elit..."}' http://a333dae17845a11e6b47b06103f11903-585648094.us-west-2.elb.amazonaws.com/articles
{"id":1,"title":"my first article","body":"Lorem ipsum dolor sit amet,consectetur adipiscing elit...","created_at":"2016-09-27T03:07:36.706Z","updated_at":"2016-09-27T03:07:36.706Z"}%

# Confirm persistence
$ kubectl delete -f kube/deployments/postgres-deployment.yaml
$ kubectl create -f kube/deployments/postgres-deployment.yaml
# Notice that don't setup!
$ curl http://a333dae17845a11e6b47b06103f11903-585648094.us-west-2.elb.amazonaws.com/articles
[{"id":1,"title":"my first article","body":"Lorem ipsum dolor sit amet,consectetur adipiscing elit...","created_at":"2016-09-27T03:07:36.706Z","updated_at":"2016-09-27T03:07:36.706Z"}]%
```

## Updating the Application

```
$ docker-compose run --rm webapp bin/rails g migration AddSlugToArticles slug:string
```
