## HOWTO DEPLOY
1.  MODIFY `variables.tfvars` to fit your provisioning.
2.  FOLLOW `terraform` init-plan-apply procedure described in upper folders.
3.  CHECK `terraform output` whether there is any errors.
4.  ACCESS FortiGate using `terraform output` parameters.

## Standalone FortiGate Topology
![Image text](https://gitee.com/danielshen/terraform-fortinet-china/raw/master/terraform-alicloud/fgtvm-standalone-cen-tr/fgtvm-standalone-cen-tr.png)