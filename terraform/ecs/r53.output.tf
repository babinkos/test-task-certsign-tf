# records
output "route53_record_name" {
  description = "The name of the record"
  value       = module.records.route53_record_name # https://github.com/terraform-aws-modules/terraform-aws-route53/blob/master/modules/records/outputs.tf
}

output "route53_record_fqdn" {
  description = "FQDN built using the zone domain and name"
  value       = module.records.route53_record_fqdn
}
