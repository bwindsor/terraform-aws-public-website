output "url" {
  description = "URL of the main website"
  value = "https://${var.custom_domain}"
}

output "alternate_urls" {
  description = "Alternate URLs of the website"
  value = formatlist("https://%s", var.alternative_custom_domains)
}
