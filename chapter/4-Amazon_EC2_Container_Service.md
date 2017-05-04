# Amazon EC2 Container Service

## Concepts

- Container Instance
- Task Definition
- Service

```
$ aws ecs register-task-definition --cli-input-json file://webapp.json
$ aws ecs run-task --task-definition webapp:1 --cluster ecs-cluster
$ aws ecs run-task --task-definition webapp --overrides file://migrate-overrides.json --cluster ecs-cluster

$ aws ecs create-service --cli-input-json file://webapp-service.json
$ aws ecs update-service --service webapp-service --task-definition webapp --desired-count 3 --cluster ecs-cluster
```

## Configuring the ECS-CLI

http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html

```
$ ecs-cli --version
```

## Creating the Cluster Using the Amazon ECS CLI

Create pem
```
$ aws ec2 create-key-pair --key-name ecs-cluster-pem --query 'KeyMaterial' --output text > ecs-cluster-pem.pem
```

ECS config
```
$ ecs-cli configure --cluster ecs-cluster --region us-east-1
INFO[0000] Saved ECS CLI configuration for cluster (ecs-cluster)
```
Saved information to `~/.ecs/config`

Launch
```
$ ecs-cli up --keypair ecs-cluster-pem --capability-iam --size 2 --instance-type t2.medium
```

Describe clusters
```
$ aws ecs --region us-east-1 describe-clusters
$ aws ecs --region us-east-1 describe-clusters --clusters ecs-cluster
```

## DB Configuration

```
$ aws ec2 describe-vpcs --region us-east-1 --query="Vpcs[*].{ID:VpcId,tags:Tags[0]}"

$ aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-a0e9c0c7" --query="Subnets[*].SubnetId"

$ aws ec2 describe-security-groups --filters="Name=vpc-id,Values=vpc-a0e9c0c7" --query="SecurityGroups[*].{Description:Description,ID:GroupId}"

$ aws rds create-db-subnet-group --db-subnet-group-name webapp-postgres-subnet --subnet-ids subnet-3a09f717 subnet-e0906cbb --db-subnet-group-description "Subnet for PostgreSQL"

$ aws rds create-db-instance --db-name webapp_production --db-instance-identifier webapp-postgres \
--allocated-storage 20 --db-instance-class db.t2.medium --engine postgres \
--master-username webapp --master-user-password mysecretpassword --db-subnet-group-name webapp-postg\
res-subnet \
--vpc-security-group-id sg-bbe6b3c1

$ aws rds describe-db-instances --db-instance-identifier webapp-postgres --query 'DBInstances[*].{Status:DBInstanceStatus}'

$ aws rds describe-db-instances --db-instance-identifier webapp-postgres --query 'DBInstances[*].{URL:Endpoint.Address}'

$ aws ec2 authorize-security-group-ingress --group-id sg-bbe6b3c1 --protocol all --port all --source-group sg-bbe6b3c1
$ aws ec2 authorize-security-group-ingress --group-id sg-bbe6b3c1 --protocol tcp --port 22 --cidr 0.0.0.0/0
```

Add rds host to production in `config/database.yml`

```

$ git add .
$ git commit -m 'add database credentials for rds'
$ LC=$(git rev-parse --short HEAD)
$ docker build -t zhangjingqiang/webapp:ecs-${LC} .
$ docker push zhangjingqiang/webapp:ecs-${LC}
```

## Creating the Task Definition

```
$ mkdir ecs
$ mkdir ecs/task-definitions

$ aws ecs register-task-definition --cli-input-json file://ecs/task-definitions/webapp.json
$ aws ecs run-task --task-definition webapp:1 --cluster ecs-cluster
$ aws ecs list-tasks --cluster ecs-cluster
$ aws ecs describe-tasks --tasks arn:aws:ecs:us-east-1:586421825777:task/1133a3a7-811c-4672-ab95-2c343930825c --cluster ecs-cluster

$ touch ecs/task-definitions/migrate-overrides.json
$ aws ecs run-task --task-definition webapp:1 --overrides file://ecs/task-definitions/migrate-overrides.json --cluster ecs-cluster

1. Get our task identifier
$ aws ecs list-tasks --cluster ecs-cluster
2. Describe the task with that identifier filtered by the container instance identifier
$ aws ecs describe-tasks --tasks arn:aws:ecs:us-east-1:586421825777:task/1133a3a7-811c-4672-ab95-2c343930825c --cluster ecs-cluster --query="tasks[*].containerInstanceArn"
3. Using the instance identifier, get the instance ID
$ aws ecs describe-container-instances --container-instances arn:aws:ecs:us-east-1:586421825777:container-instance/edd5e9a7-7f29-43a6-98c1-b7d7dd912cd2 --query="containerInstances[*].ec2InstanceId" --cluster ecs-cluster
4. Using that ID, get the IP address by using the EC2 API
$ aws ec2 describe-instances --instance-ids i-69f4a17f --query="Reservations[0].Instances[0].PublicIpAddress"

$ curl -I http://54.164.16.149/articles
```

## Creating a Service for Our Application

```
$ touch app/controllers/pages_controller.rb

Create Load Balancer
$ aws elb create-load-balancer --load-balancer-name webapp-load-balancer --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP, InstancePort=80" --subnets subnet-3a09f717 subnet-e0906cbb --security-groups sg-bbe6b3c1

Stop Application
$ aws ecs list-tasks --cluster ecs-cluster
$ aws ecs stop-task --task arn:aws:ecs:us-east-1:586421825777:task/1133a3a7-811c-4672-ab95-2c343930825c --cluster ecs-cluster
$ mkdir ecs/services

Create Service
$ aws ecs create-service --generate-cli-skeleton > ecs/services/webapp-service.json --cluster ecs-cluster
$ aws ecs create-service --cli-input-json file://ecs/services/webapp-service.json

$ curl -I webapp-load-balancer-1711291190.us-east-1.elb.amazonaws.com/articles

$ curl -H "Content-Type: application/json" -X POST -d '{"title":"the title","body":"The body"}' http://webapp-load-balancer-1711291190.us-east-1.elb.amazonaws.com/articles
```

## Running Updates to Our Application

```
$ mkdir ecs/deploy
$ touch ecs/deploy/push.sh
$ touch ecs/deploy/migrate.sh
$ chmod +x ecs/deploy/*

$ git add -A
$ git commit -m 'add deploy scripts for ecs'

$ ./ecs/deploy/push.sh
$ ./ecs/deploy/migrate.sh
```
