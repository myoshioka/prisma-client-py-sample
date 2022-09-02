# Sample application using Prisma Client Python

## Overview

- This repository is a sample application using [Prisma Client Python](https://github.com/RobertCraigie/prisma-client-py) with ARM environment.

## Description

This application is intended for use in an arm64-linux environment. However, Prisma Client Python does not yet support arm64-linux, so the Prisma engine is built and used directly in the docker container.
Prisma-Cli is used to download arm64 binaries.

## Getting Started


- Launch the container with docker-compose.

```bash
$ docker-compose up -d
```

- After login to the container, apply the schema to the Database and generate the Prisma Client code.

```bash
$ docker exec -it prisma-client-py-sample bash
prisma db push
```

- Execute the sample code.
  - Sample data is added to the Database and then the added data is fetched and displayed.

```bash
python src/main.py
```
