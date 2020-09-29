variable "deployment_name" {
  description = "A unique string to use for this module to make sure resources do not clash with others"
  type = string
}

variable "website_dir" {
  description = "A folder containing all the files for your website. The contents of this folder, including all subfolders, will be stored in an S3 website and served as your website"
}
variable "additional_files" {
  description = "A mapping from file name (in S3) to file contents. For each (key,value) pair, a file will be created in S3 with the given key, with contents given by value"
  type        = map(string)
  default     = {}
}
variable "hosted_zone_name" {
  description = "The name of the hosted zone in Route53 where the SSL certificates will be created"
  type = string
}
variable "custom_domain" {
  description = "The primary domain name to use for the website"
  type        = string
}
variable "alternative_custom_domains" {
  description = "A list of any alternative domain names. Typically this would just contain the same as custom_domain but prefixed by www."
  type        = list(string)
  default     = []
}

variable "template_file_vars" {
  description = "A mapping from substitution variable name to value. Any files inside `website_dir` which end in `.template` will be processed by Terraform's template provider, passing these variables for substitution. The file will have the `.template` suffix removed when uploaded to S3."
  type        = map(string)
  default     = {}
}

variable "is_spa" {
  description = "If your website is a single page application (SPA), this sets up the cloudfront redirects such that whenever an item is not found, the file `index.html` is returned instead."
  default     = false
}

variable "csp_allow_default" {
  description = "List of default domains to include in the Content Security Policy. Typically you would list the URL of your API here if your pages access that. Always includes `'self'`."
  type    = list(string)
  default = []
}

variable "csp_allow_style" {
  description = "List of places to allow CSP to load styles from. Always includes `'self'`"
  type = list(string)
  default = []
}

variable "csp_allow_img" {
  description = "List of places to allow CSP to load images from. Always includes `'self'`"
  type = list(string)
  default = []
}

variable "csp_allow_font" {
  description = "List of places to allow CSP to load fonts from. Always includes `'self'`"
  type = list(string)
  default = [
    "https://fonts.gstatic.com"
  ]
}

variable "csp_allow_frame" {
  description = "List of places to allow CSP to load iframes from. Always includes `'self'`"
  type = list(string)
  default = []
}
