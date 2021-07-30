# Private Cloud Module Information

Most infrastructure in AWS lives on a VPC. Very core. 
As a result, a lot of stuff needs a VPC in order to actually get running inside this project.
Additionally, VPCs actually have kind of an annoying amount of side-configuration that you will 
basically have to repeat every time you need to stand up a new private cloud. 

Instead of creating bespoke configurations each time, I would prefer fine-tuning a single 
module and getting it exactly how I want it. So here we are. 

## Expected Output
- Running this module will provide `n` public and private subnets, in the described availability zones. 
- There will be default routing rules for egress (allow all) and ingress (allow ports 80 and 443).
- If networking is enabled, `n` Elastic IPs and NAT Gateways will be created, to allow all public subnets to 
  broadcast / generally allow outbound traffic.
  
## Example TfVars
This mirrors the default values for the module, simply change them as needed.  

**Note** - Public subnets, private subnets, and availability zones must have the same number, since 
           they will all be mapped together. Expect failures if this is not the case. 


```
vpc-cidr-range            = "10.0.0.0/16"
availability-zones        = ["us-east-1a"]
public-subnet-cidrs       = ["10.0.1.0/24"]
private-subnet-cidrs      = ["10.0.3.0/24"]
enable-public-networking  = true
additional-tags = {
  Name: "testbed"
  Owner: "Alex Bates"
  Environment: "Testing"
}
```