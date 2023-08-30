<!-- BEGIN_TF_DOCS -->
# terraform-aws-alb

Terraform module to create an Application Load Balancer (ALB) and associated resources.

## Usage

### Basic

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//."
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id                    = "vpc-1234567890"
    public_subnets            = ["subnet-1234567890", "subnet-1234567890"]
    default_security_group_id = "sg-1234567890"
  }
}

inputs = {
  name       = "test-example"
  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.public_subnets

  region      = "us-east-2"
  environment = "test"
  tags = {
    "CreatedBy" = "Terraform"
    "Company"   = "DeveloperTown"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.36.1 |

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener_certificate.alternate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener_certificate) | resource |
| [aws_alb_target_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_route53_record.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | A boolean flag to enable/disable access\_logs | `bool` | `false` | no |
| <a name="input_access_logs_prefix"></a> [access\_logs\_prefix](#input\_access\_logs\_prefix) | The S3 log bucket prefix | `string` | `""` | no |
| <a name="input_access_logs_s3_bucket_id"></a> [access\_logs\_s3\_bucket\_id](#input\_access\_logs\_s3\_bucket\_id) | An external S3 Bucket name to store access logs in. If specified, no logging bucket will be created. | `string` | `null` | no |
| <a name="input_alarm_unheathly_threshold"></a> [alarm\_unheathly\_threshold](#input\_alarm\_unheathly\_threshold) | Number of unheathy hosts that should cause an alarm if the actual is greater than or equal for 60 seconds | `number` | `1` | no |
| <a name="input_alb_access_logs_s3_bucket_force_destroy"></a> [alb\_access\_logs\_s3\_bucket\_force\_destroy](#input\_alb\_access\_logs\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The certificate to use with the SSL listener | `string` | `""` | no |
| <a name="input_dns_record_name"></a> [dns\_record\_name](#input\_dns\_record\_name) | he DNS name to use to create an alias record.  The Route53 hosted zone must be accessible via the dns\_zone\_role\_arn | `string` | `""` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | The ID of the Route53 hosted zone to create an alias record.  The Route53 hosted zone must be accessible via the dns\_zone\_role\_arn | `string` | `""` | no |
| <a name="input_dns_zone_role_arn"></a> [dns\_zone\_role\_arn](#input\_dns\_zone\_role\_arn) | The AWS assume role | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination for the health check request | `string` | `"/swagger/index.html"` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | Port on which the load balancer is listening | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | SSL Port on which the load balancer is listening | `number` | `443` | no |
| <a name="input_lifecycle_configuration_rules"></a> [lifecycle\_configuration\_rules](#input\_lifecycle\_configuration\_rules) | A list of S3 bucket v2 lifecycle rules, as specified in [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)"<br>These rules are not affected by the deprecated `lifecycle_rule_enabled` flag.<br>**NOTE:** Unless you also set `lifecycle_rule_enabled = false` you will also get the default deprecated rules set on your bucket. | <pre>list(object({<br>    enabled = bool<br>    id      = string<br><br>    abort_incomplete_multipart_upload_days = number<br><br>    # `filter_and` is the `and` configuration block inside the `filter` configuration.<br>    # This is the only place you should specify a prefix.<br>    filter_and = any<br>    expiration = any<br>    transition = list(any)<br><br>    noncurrent_version_expiration = any<br>    noncurrent_version_transition = list(any)<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `"ecs-cluster"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the role that will be assumed to create the resources in this module | `string` | `null` | no |
| <a name="input_sns_alarm_topic_arn"></a> [sns\_alarm\_topic\_arn](#input\_sns\_alarm\_topic\_arn) | The SNS Topic ARN to use for Cloudwatch Alarms | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to attach to the load balancer. | `list(string)` | `[]` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Suffix to be added to the name of each resource | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'Unit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to associate the load balancer security groups, and target group with. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | n/a |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | n/a |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | n/a |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | n/a |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | n/a |
<!-- END_TF_DOCS -->