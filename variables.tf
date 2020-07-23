variable "profile" {
  description = "AWS credential profile to use for deployment"
  type = string
}

variable "deployment_name" {
  description = "Deployment name. This is used as a unique prefix on resource names/ids to stop clashes."
  type = string
}

variable "website_dir" {
  description = "Directory containing your website"
}
variable "additional_files" {
  description = "Mapping from website S3 key to file content"
  type        = map(string)
  default     = {}
}
variable "hosted_zone_name" {
  description = "Name of the already existing hosted zone in which SSL certificates will be created"
  type = string
}
variable "custom_domain" {
  description = "Custom domain name to use"
  type        = string
}
variable "alternative_custom_domains" {
  description = "Alternative custom domains which will redirect to the custom domain"
  type        = list(string)
  default     = []
}

variable "template_file_vars" {
  description = "Variables to substitute into any file with .template. in its name"
  type        = map(string)
  default     = {}
}

variable "is_spa" {
  description = "Whether this is a Single Page App. If so, all would-be 404 errors are returned as 200 and the contents of index.html"
  default     = false
}

variable "csp_allow_default" {
  type    = list(string)
  default = []
}

variable "csp_allow_style" {
  type = list(string)
  default = [
    "'unsafe-inline'",
    "https://fonts.googleapis.com"
  ]
}

variable "csp_allow_img" {
  type = list(string)
  default = [
    "data:"
  ]
}

variable "csp_allow_font" {
  type = list(string)
  default = [
    "https://fonts.gstatic.com"
  ]
}