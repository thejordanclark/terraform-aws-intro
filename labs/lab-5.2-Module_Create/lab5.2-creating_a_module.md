# Creating a Module

Lab Objective
- Convert the load balancer configuration in your code to a module
- Use the new module in your configuration

## Preparation

If you did not complete lab 5.1, you can simply copy the solution code from that lab (and do terraform apply) as the starting point for this lab.

## Lab

### Modify code to implement the module

In this lab we will convert the load balancer configuration to be a module implementation.  We will implement the module as a nested module, though in actual practice this module should probably be a module on its own.

Create a subdirectory called `load-balancer`.
```
mkdir load-balancer
```

#### Load balancer main

Copy the `lb.tf` file to the “load-balancer” sub-directory and rename the file to be “main.tf” in the "load-balancer" sub-directory.  (Recall that each module should have a main.tf file as the principal configuration entry point.)  Let's make a couple changes to the new main.tf file.

First, a module should include its provider requirements.  So add the following to the top of the `load-balancer/main.tf` file.  Note that we do not add a backend specification or a provider block since this is for a module.
```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = "> 1.0.0"
}
```

Next, cut the security group (resource `"aws_security_group" "lab-alb"`) from the `load-balancer/main.tf` file.
> Whether or not to create the security group within the module is a design decision. To avoid some complications from refactoring our code, we will leave the security group creation outside of the module code.

#### Load balancer variables

Within the `load-balancer` directory, create a file called `variables.tf`.

Go through the `load-balancer/main.tf` file and look for what arguments will need values passed into the module.  (The load balancer module cannot access the parent resources directly.)  These are candidates for the input variables for the load balancer module.

In the `load-balancer/variables.tf` file, add variables for the following:
  * VPC ID
  * Subnet IDs
  * Security group

Try to write the variables.tf code on your own initially. Compare your code to the solution below (or in the load-balancer/variables.tf file in the solution folder).

<details>

 _<summary>Click to see solution for load balancer module variables</summary>_

```
variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
  default = []
}
```
</details>

Open the `load-balancer/main.tf` file and use these variables to populate the corresponding arguments in the resources in the file.

#### Load balancer outputs

Within the `load-balancer` directory, create a file called `outputs.tf`.

Go through the root module's files to see where load balancer attributes are referenced.  These are candidates for output values from the load balancer module.

In the `load-balancer/outputs.tf` file, add outputs for the following:
  * load balancer target group ARN
  * load balancer public DNS name

Try to write this on your own initially.  Compare your code to the solution below (or in the load-balancer/outputs.tf file in the solution folder).

<details>

 _<summary>Click to see solution for load balancer module outputs</summary>_

```
output "target_group_arn" {
  value = aws_lb_target_group.lab.arn
}

output "dns_name" {
  value = aws_lb.lab.dns_name
}
```
</details>

At this point, you now have a nested module with inputs and outputs defined.  Next, let's use the new module.

### Modify code to call the new module

Open the file `lb.tf` in the root module (parent directory).  

Delete the two resources `"aws_lb" "lab"` and `"aws_lb_target_group" "lab"` since those are now in the load-balancer's main.tf file.

Add a call to the load balancer module, setting argument values corresponding to the input variables for the load balancer.  The module source should be "./load-balancer".

Try writing this on your own first. Compare your code to the solution below (or in the vm-cluster.tf file in the solution folder).

<details>

 _<summary>Click to see solution for calling load balancer module</summary>_

```
module "load-balancer" {
  source = "./load-balancer"

  vpc_id          = aws_vpc.lab.id
  subnets         = [aws_subnet.lab-public-1.id, aws_subnet.lab-public-2.id]
  security_groups = [aws_security_group.lab-alb.id]
}
```
</details>

In the root module, you now need to use the module outputs to replace references to the load balancer attributes.  Be sure to use the "module" prefix in the references.

* Update the reference for `target_group_arn` in "vm-cluster.tf"
* Update the value for `dns_name` in "outputs.tf" in the root module.

### Execute terraform commands

To run the terraform commands, you must be in the root module's directory.  :bangbang: **Verify you are in the root module folder.**  If not, move to that directory.

Let's now validate the code you've written.  If you run terraform validate at this point, you will get an error that you need to run terraform init first.  Do you recall why this is necessary?

Run terraform init.
```
terraform init
```

Run terraform validate and fix errors as appropriate.
```
terraform validate
```

Run terraform plan. You will see that Terraform wants to replace the load balancer and various ancillary resources.  Do you know why Terraform would need to do this? (*Hint: How does terraform reference resources?*)
```
terraform plan
```

Run terraform apply:
```
terraform apply
```

## Lab Cleanup

This is the final lab of the class.  When you are done with the lab and are satisfied with the results, please tear down everything you created by running terraform destroy:
```
terraform destroy
```

The destroy might take up to 10 minutes. (Destroying the internet gateway seems to take quite a while.)
