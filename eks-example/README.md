# EKS Example Project

This example has a starting point of [This Repo](https://github.com/hashicorp/learn-terraform-provision-eks-cluster)
and largely leans on configuration described there. 

There is a bit of tweaking and fiddling on my end, but not overly much. 

This project creates all the surrounding infrastructure around and EKS instance as well (VPC/Subnets/etc.), 
so just keep that in mind. 

Cluster creation takes several minutes, so no worries if it kind of stalls during provisioning. 

## Post Terraform K8S Config

Once the cluster is set up, you have to point your local kubectl to the cluster. 
This can be done with the following command (ran from project root):  
`aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)`

## Update
Honestly as I look at setting up a k8s anything, it just looks so over the top and not like something 
I can care about currently. The terraform files here work exactly as advertised, but the remaining
kubectl config and setting things to up run and junk is omitted. Maybe I'll be back to this one day and 
can pick it back up. 
