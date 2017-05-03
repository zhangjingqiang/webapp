# Setting Up Tools for Production

## Installing the AWS CLI

http://docs.aws.amazon.com/cli/latest/userguide/installing.html

```
$ curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
$ unzip awscli-bundle.zip
$ sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

$ aws --version
```

## Configuring the AWS CLI

http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html

```
$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: us-east-1
Default output format [None]: json
```

After running this command, your credentials will be saved under
~/.aws/credentials:

```
[default]
aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

And your configuration under /.aws/config:

```
[default]
output = json
region = us-east-1
```

### Several Profiles

```
[default]
aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

[work]
aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## Tips for Using the AWS CLI

```
$ aws ec2 describe-vpcs --region us-east-1 --query="Vpcs[*].{ID:VpcId,tags:Tags[0]}"
[
    {
        "ID": "vpc-e61cec82",
        "tags": null
    },
    {
        "ID": "vpc-a0e9c0c7",
        "tags": {
            "Value": "amazon-ecs-cli-setup-ecs-cluster",
            "Key": "aws:cloudformation:stack-name"
         }
    }
]
```

```
$ aws rds describe-db-instances --db-instance-identifier webapp-postgres --query 'DBInstances[*].{Status:DBInstanceStatus}'
[
    {
        "Status": "Running"
    }
]
```

```
$ aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-a0e9c0c7" --query="Subnets[*].SubnetId"
[
    "subnet-3a09f717",
    "subnet-e0906cbb"
]
```
