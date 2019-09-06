# OpsWorks AWS task

### Overview

This repo contains Terraform files for OpsWorks test assignment.

It creates AWS VPC, Gateway, Route, Security Group, Subnet and Key Pair and provisions Docker Swarm Cluster (1 manager, 1 worker)

Once underlying infrastructure has been provisioned:
- internal Docker registry is being deployed
- sample web Python Flask application is being built and pushed to internal registry
- application is being deployed as Docker Swarm Stack.

Web application uses Docker Engine API to display list of services and containers running in Docker Swarm cluster
One can click on any service or container name and get it's logs (stdout and stderr) displayed

### Instructions

1. Create terraform.tfvars file with the following sensitive AWS variables

    ```
    aws_access_key = "<aws access key>"
    aws_secret_key = "<aws secret key>"
    ```

2. Provision infrastructure by running Terraform deployment inside docker container

   ```
   # sudo ./provision.sh

   ...
   Outputs:

   master_url = http://A.B.C.D
   ```

3. Open <master_url> in your web browser and verify that web application is up and running as expected

4. (Optional) Verify status of Docker Swarm Cluster

    ```
    # ssh -i <path to SSH private key> ubuntu@<master_ip> sudo docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    ow5vi0u9yzn11cifxbikttjnd *   ip-10-95-0-100      Ready               Active              Leader              19.03.2
    mn8b8g82zojm386s0lxa8r87i     ip-10-95-0-177      Ready               Active                                  19.03.2
    
    ```
