# Nexus Setup Project

This project is to maintain the infrastructure and configuration required to 
run Nexus for our developers. 

The project is split into three sections: 

- Terraform         - AWS infrastructure required to host nexus / route traffic / store artifacts / etc. 

- Docker            - Container configuration and settings required inside the Nexus application itself.   
                      (along with build scripts and deployment of the final container image)

- EC2-PassThrough   - This project is meant to temporarily provide a connection point to the EFS 
                      volume that is used by nexus. This is required to obtain the initial admin setup 
  
Specifics for project setup / execution can be found below. 


## Terraform 

Everything at or above the ECS cluster level is managed outside of this project by the ops team. 
Data collectors will be used to fetch any infrastructure that is needed at that level. 

This includes:  
- VPC
- Subnets
- R53 Hosted Zone
- ECS Cluster

Defined in this project are the following components: 

- Fargate service/task
- ECR Repository
- EFS Mount 
- Security Groups


## Setup Details

Steps: 

- Run the `terraform/` directory as a project (set terraform workspace, provide variables, apply)
- Run `deploy.sh` from the `docker` directory. This will push the image to ECR.
- Wait for the nexus image to finish loading fully (wait for `nexus2.dev.clearcaptions.com` to resolve).
- Default admin password will be created automatically. You have to SSH into the EFS files to read it. 
    - Run the `ec2-passthrough` project (workspace/variables/etc)
    - Run the commands listed below this section to connect and display the password.
    - **RUN TERRAFORM DESTROY ON THIS INSTANCE NOW** (`terraform destroy`)
- Remaining Nexus setup will be manual (not automation friendly).  
  Recommend following steps 
  [Here](https://help.liferay.com/hc/en-us/articles/360018164871-Creating-a-Maven-Repository)
    - Log in as `admin` using the password obtained previously
    - Create `SNAPSHOT` and `RELEASE` repositories as needed for maven. 
      The URLs created for this will be used going forward. 
- TODO: would love some logins based on credentials... In the meantime - 
  Create a generic user with rights to push/pull into the repos. 


### EC2 Connection / Password Steps

Note: be on VPN to connect to the EC2 instance.

Local Bit (pem key created during apply):   
`terraform apply`

`chmod 600 myKey.pem` 


SSH Bit (Requires outputs from both terraform projects): 
```bash
ssh -i myKey.pem ec2-user@[EC2_IP]
sudo umount /efs
sudo mount -t efs -o tls [file-system-id] /efs
cat /efs/mnt/efs/admin.password
```

