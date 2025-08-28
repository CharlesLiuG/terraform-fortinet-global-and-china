## HOWTO DEPLOY
1.  MODIFY `terraform.tfvars` to fit your provisioning.
2.  FOLLOW `terraform` init-plan-apply procedure described in upper folders.
3.  CHECK `terraform output` whether there is any errors.
4.  ACCESS FortiGate using `terraform output` parameters.

## Standalone FortiGate Topology
![Image Text](https://gitee.com/danielshen/terraform-fortinet-china/raw/master/terraform-awschina/fgtvm-standalone-vpc/fgtvm-standalone-vpc.png)