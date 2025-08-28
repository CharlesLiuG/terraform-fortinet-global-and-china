# Fortinet-AWS

## NOTICES!!!
* FortiGate-VM automation is available for `AWS.China` and `AWS.Global`.  
* For FortiGate version deatils, please refer to `Distribution Release Note`!!!  
* Pay-as-you-go (`PAYG`) is available ONLY with `FortiGate v7.2.x` in `AWS.China`.  

## Install awscli
[AWS Documentation for Installing awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  

* Linux  
``` sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

* Windows  
``` sh
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

* MacOS  
``` sh
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```


## Authenticating with AWS

### Configure awscli for long-time usage
``` sh
aws configure
AWS Access Key ID [AK]:
AWS Secret Access Key [SK]:
Default region name [cn-northwest-1 | cn-north-1]:
Default output format [yaml]:
```


### Configure awscli for one-time usage
* SETTING Linux ENV
``` sh
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_REGION="cn-northwest-1"
```

* SETTING Windows PowerShell ENV
``` sh
$env:AWS_ACCESS_KEY_ID="anaccesskey"
$env:AWS_SECRET_ACCESS_KEY="asecretkey"
$env:AWS_REGION="cn-northwest-1"
```


## Terraform configuration
[Terraform Registry Documentation for AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

* init  
`terraform init`

* plan  
MODIFY AS NEEDED > `terraform.tfvars`  
`terraform plan -out=tfplan`

* apply  
`terraform apply "tfplan"`

* destroy  
`terraform destroy`



## Terraformer CLI
[Terraformer for AWS](https://github.com/GoogleCloudPlatform/terraformer/blob/master/docs/aws.md)  
``` sh
terraformer-aws import aws --resources=vpc --filter=vpc=vpc-********** –-regions=cn-northwest-1
terraformer-aws import aws --resources=sg --filter=security_group=sg-************
terraformer-aws import aws --resources=eni --filter=network_interface=eni-**********
terraformer-aws import aws --resources=ec2_instance --filter=instances=i-************
terraformer-aws import aws --resources=rtb --filter=route_tables=rtb-**********
```

## AWSCLI examples
* search for ami of AWS.China FortiGate  
``` sh
aws ec2 describe-images --region cn-north-1 --owners aws-marketplace --filters "Name=name,Values=FGT_VM64_AWS*"
aws ec2 describe-images --region cn-northwest-1 --owners aws-marketplace --filters "Name=name,Values=FGT_VM64_AWS*"
aws ec2 describe-images --region cn-northwest-1 --filters "Name=image-id,Values=ami-075c9f159ee0bdc1c"
```