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
--master-username webapp --master-user-password mysecretpassword --db-subnet-group-name webapp-postg\ res-subnet \
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
