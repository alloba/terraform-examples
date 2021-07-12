# Purpose 

The goal here is to provide a working example of a terraform project that creates 
a working api gateway with auth.

Meaning: 
- Api Gateway
- Endpoint Definitions 
- Lambda integration
- Cognito User Pools
- Cognito App Client

The goal isn't to do anything very fancy with it, mostly this is just a way to force some kind of understanding on my part for the setup. 

# Project Layout

Ideally (knowing nothing about standard practices in terraform), I would like to have 
everything organized by aws service. So one file for the gateway, one file for the user pool, etc. 
(and one file for variables across the board)

We'll see how that actually survives as a goal as things actually develop.

the 'entry point' for the project is going to be `main.tf`

# Setup

Mostly the only thing that needs to be ensured here is that 
the proper AWS account settings are being used in the CLI.

Additionally, obviously you need the CLI tools installed to get anything done 
(AWS and Terraform).
