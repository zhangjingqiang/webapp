# WebApp

Source code of Deploying Rails with Docker Kubernetes and ECS.

## Install Docker and Docker Compose on workstation

From official site.

- Docker version: 1.13.1
- Docker compose version: 1.11.2

## Create a new rails application from zero

```
$ docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/app -w /usr/src/app rails rails new --skip-bundle --api --database postgresql webapp
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.3 bundle install
```

This will automattic download rails and ruby images.

```
$ docker-compose run --rm webapp bin/rails g scaffold articles title:string body:text
$ docker-compose run --rm webapp bin/rails db:migrate
$ docker-compose run --rm webapp bash -c "RAILS_ENV=test bin/rails db:create"
$ docker-compose run --rm webapp bash -c "RAILS_ENV=test bin/rake"
$ docker-compose exec webapp bin/rails c
```

## Push to Docker Hub

```
$ ./push.sh
```
