# Odoo Docker App

This repository contains all of the configuration files for spinning up an Odoo container at the various development stages: development, integration, testing and production.  Development servers should be synced with the development branch, testing and production should be synced with the master branch.  

The [proxy-docker](https://github.com/delphiniumdotdev/proxy-docker) app must be running for this app to work.  

## Installation

## Configuration and variables

In the repositories home directory create a new file called 'db_key' and enter the database password for postgres.  

Create a directory called '.env'. You will need to create a '.env' file for each development stage that contain the following variables:  

'.env.dev'
```txt
server_name=""
virtual_host=""
build_stage="development.Dockerfile"
app_stage="dev-app01-app"
```

'.env.integrate'
```txt
server_name=""
virtual_host=""
build_stage="integrate.Dockerfile"
app_stage="dev-app01-app"
```

'.env.prod'
```txt
server_name=""
virtual_host=""
app_stage="prod-app01-app"
```

The 'server_name' and 'virtual_host' variables both contain the url. The reason they are separated is that 'server_name' looks for a space between urls (i.e. somedomain.com www.somedomian.com) where as 'virtual_host' looks for a comma between urls (i.e. somedomain.com,www.somedomain.com).  

### Dev servers  

Run the following command to start the containers:  

```bash
docker compose --profile development --env-file .env/.env.dev up -d
```

The development profile pulls the latest build directly from the official Odoo image. All new/custom modules get put into the extra-addons folder. Create and push a new image to your docker image repository by first deleting the working development image. Confirm the permissions on the entrypoint.sh and wait-for-psql.py files are set to 755. Then create the integration container with:  

```bash
docker compose --profile development --env-file .env/.env.integrate up -d
```

Once the container is created run: ```docker ps``` and copy the container ID. Commit and tag the image with the current version number and 'latest':  

```bash
docker container commit <container-ID>  account/image_name:release
docker image tag account/repository:<version-number> account/image_name:latest
```

Push all image tags to docker hub or other repository:  

```bash
docker image push -a account/repository
```

### Test & Production servers  

In the Docker Compose file add the ```account/image_name:relaease``` name to the section:  

```bash
prod-app01-app:
  image: # The location of the image created by the development stage needs to be referenced here. i.e. for a Docker hub image: 'account/image_name:release'
```
Start the container (change 'env.test' to 'env.prod' as appropriate):  

```bash
docker compose --profile production --env-file .env/.env.test up -d
```

For production environments comment the NETWORK_ACCESS variable in the compose file. Also, these are the only files and directories required in the production environment: config/, .env/, db_key, docker-compose.yml, nginx/.
