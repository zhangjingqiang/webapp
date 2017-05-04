# Continuous Integration

## Installing Jenkins

### Creating a Key Pair

```
$ aws ec2 create-key-pair --key-name Jenkins --query 'KeyMaterial' --output text > Jenkins.pem
$ chmod 400 Jenkins.pem
```

### Launching the Instance

```
$ aws ec2 run-instances --image-id ami-c481fad3 --subnet-id subnet-3a09f717 --count 1 --instance-type t2.medium --key-name Jenkins --security-group-ids sg-bbe6b3c1 --block-device-mappings '[{ "DeviceName": "/dev/xvda", "Ebs": { "VolumeSize": 20 } }]' --associate-public-ip-address
$ aws ec2 describe-instances --instance-ids i-729ea343 --query="Reservations[0].Instances[0].State"
```

### Connecting to the Instance

```
$ aws ec2 describe-instances --instance-ids i-729ea343 --query="Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicIp"
$ ssh ec2-user@184.72.110.253 -i Jenkins.pem
```

### Installing Dependencies

```
$ sudo su
# yum update -y
# yum install -y git nginx docker

Docker Compose
# curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
# chmod +x /usr/bin/docker-compose

Jenkins
# wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
# rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
# yum install -y jenkins
# usermod -a -G docker jenkins

# service jenkins start
# service docker start
# chkconfig jenkins on
# chkconfig docker on
# usermod -s /bin/bash jenkins
# usermod -m /var/lib/jenkins jenkins

kubectl
# curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/bin/

AWS CLI
# curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
# unzip awscli-bundle.zip
# ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

Docker Login
# docker login

# sudo su - jenkins
$ mkdir -p ~/.kube
$ touch ~/.kube/config
Copy local `~/.kube/config` to Jenkins server
$ kubectl get nodes

$ mkdir -p ~/.aws
$ touch ~/.aws/credentials
$ touch ~/.aws/config
Copy local files to those remote files in the server
$ aws ecs describe-clusters --cluster ecs-cluster
$ exit
# reboot 1

$ aws ec2 authorize-security-group-ingress --group-id sg-bbe6b3c1 --protocol tcp --port 8080 --cidr 0.0.0.0/0

$ ssh ec2-user@184.72.110.253 -i Jenkins.pem
# sudo su
# cat /var/lib/jenkins/secrets/initialAdminPassword
# exit
```

## Configuring a Job for Kubernetes

```
$ git add .
$ git commit -m 'fix db host for kubernetes'
$ git push origin master
```

### Push to Deploy

GitHub repository -> Settings -> Integratin & Services -> Add service -> Jenkins(GitHub plug-in)

Jenkins hook url:
http://184.72.110.253:8080/github-webhook/

### Running the Test Suite

```
$ docker-compose run --rm webapp bin/rails db:create RAILS_ENV=test
$ docker-compose run --rm webapp bin/rails db:migrate RAILS_ENV=test
$ docker-compose run --rm webapp bin/rake RAILS_ENV=test

$ touch docker-compose.test.yml
$ touch setup.test.sh
$ chmod +x setup.test.sh

$ git add -A
$ git commit -m 'Add testing stuff'
$ git push origin master
```
