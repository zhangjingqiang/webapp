# WebApp

Source code of Deploying Rails with Docker Kubernetes and ECS.

## Development

```
# Creating the Application
$ docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/app -w /usr/src/app rails rails new --skip-bundle --api --database postgresql webapp
$ cd webapp
$ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.3 bundle install

# Dockerizing Rails
$ touch webapp.conf
$ touch rails-env.conf
$ touch Dockerfile

# Setup Container
$ touch setup.sh
$ chmod +x setup.sh
$ touch docker-compose.yml

# Build and Run
$ docker-compose build
$ docker-compose up
$ curl -I localhost

# Adding a Rails Resource
$ docker-compose run --rm webapp bin/rails g scaffold articles title:string body:text
$ docker-compose run --rm webapp bin/rails db:migrate
$ docker-compose run --rm webapp bash -c "RAILS_ENV=test bin/rails db:create"
$ docker-compose run --rm webapp bash -c "RAILS_ENV=test bin/rake"
$ docker-compose exec webapp bin/rails c

# Log Issues
open: config/application.rb
edit: config.logger = Logger.new(STDOUT)
$ docker-compose up -d && docker-compose logs -f

# Pushing the App to DockerHub
$ docker login
$ touch .dockerignore
$ git init
$ git add -A
$ git commit -m 'Add dockerized Rails app'
$ LC=$(git rev-parse --short HEAD)
$ docker build -t <username>/webapp:${LC} .
$ docker push <username>/webapp:${LC}
# Use script to push
$ touch push.sh
$ chmod +x push
$ ./push.sh
```

