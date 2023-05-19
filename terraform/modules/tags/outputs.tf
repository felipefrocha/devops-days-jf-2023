output "common_tags" {
  description = "Map of common tags to be applied to all product resources."
  value       = local.common_tags
}

output "common_prefix" {
  description = "Common prefix to be applied for resource."
  value       = local.common_prefix
}

output "current_time" {
  value = time_static.example.rfc3339
}