# Containerise Phoenix/Elixir project

- Build Docker image with a multi-stage dockerfile to mantain small size
- Makefile to provide simple commands to run

## Setup

- Create a new Phoenix project

`mix phx.new NAME_OF_THE_PROJECT`

- Edit Dockerfile's variable PROJECT_NAME
- Edit Makefile's variable CONTAINER_NAME


## Commands

From the project root

### Stop and remove container

`make clean`

### Build image

`make build`

### Build and start container

`make dockerize`