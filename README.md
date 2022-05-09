# onlyoffice-fargate

This repository is primarily intended as an experimentation spot for different configurations of the OnlyOffice product deployed into an AWS environment.  All code in this repository is not necessarily secure, using best practices, or production-ready and should be treated as such.

## Modules

### network

This module describes an AWS VPC for deploying all the modules into.  It has four subnets in two different availability zones.  Two private and two public.  Also contains definitions for security groups needed to enable connectivity between different components.

### onlyoffice

This module contains the ECS resources (including the application load balancer) for deploying the OnlyOffice server.  It can be configured to connect to either the [rabbitmq](#rabbitmq) or [mq](#mq) modules (or neither if the AMQP_URI variable is removed).

### onlyoffice-ecr

Module contains a single ECR repository for storing the custom OnlyOffice docker image.

### mq

Module contains an AmazonMQ broker using the RabbitMQ engine.

### rabbitmq

Module contains ECS resources needed (including a network load balancer) to deploy a single rabbitmq instance.

### shared

Module contains a few resources that may need to be shared across multiple modules.  The onlyoffice ECS cluster is a notable example.

## Gitpod Support

### Disclaimer
**DO NOT ADD ANY AWS CREDENTIALS TO A RUNNING GITPOD WORKSPACE THAT YOU AREN'T COMFORTABLE WITH BAD ACTORS ACQUIRING**

This repository has been configured to run in Gitpod with some additional configurations.  It installs the latest version of Terraform and the AWS CLI.  That being said, I am unsure of the security model of Gitpod and would not recommend configuring it to use your AWS credentials.  

The button below can be used to open the master branch of the repository in a Gitpod workspace assuming you have a Gitpod account.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/awarrington0895/onlyoffice-fargate)