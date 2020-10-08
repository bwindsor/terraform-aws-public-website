# terraform-aws-public-website
Creates a public website behind a cloudfront distribution, with SSL enabled, including support for multiple domain names (e.g. www.example.com as well as example.com). CORS is also configured for you.

The website files are hosted in an S3 bucket which is also created by the module.

# Usage
```hcl-terraform
module "website" {
    source = "bwindsor/public-website"
    
    deployment_name = "tf-my-project"
    website_dir = "${path.root}/website_files"
    additional_files = { "config.yaml" = <<EOF
a: 1
b: 2
EOF
  }
    hosted_zone_name = "example.com"
    custom_domain = "example.com"
    alternative_custom_domains = ["www.example.com"]
    template_file_vars = { api_url = "api.mysite.com" }
    is_spa = false
    csp_allow_default = ["api.mysite.com"]
    csp_allow_style = ["'unsafe-inline'"]
    csp_allow_img = ["data:"]
    csp_allow_font = []
    csp_allow_frame = []
    mime_types = {}
}
```

### Inputs
Ensure environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set.

* **deployment_name** A unique string to use for this module to make sure resources do not clash with others
* **website_dir** A folder containing all the files for your website. The contents of this folder, including all subfolders, will be stored in an S3 website and served as your website
* **additional_files** A mapping from file name (in S3) to file contents. For each (key,value) pair, a file will be created in S3 with the given key, with contents given by value
* **hosted_zone_name** The name of the hosted zone in Route53 where the SSL certificates will be created
* **custom_domain** The primary domain name to use for the website
* **alternative_custom_domains** A list of any alternative domain names. Typically this would just contain the same as *custom_domain* but prefixed by `www.`
* **template_file_vars** A mapping from substitution variable name to value. Any files inside `website_dir` which end in `.template` will be processed by Terraform's template provider, passing these variables for substitution. The file will have the `.template` suffix removed when uploaded to S3
* **is_spa** If your website is a single page application (SPA), this sets up the cloudfront redirects such that whenever an item is not found, the file `index.html` is returned instead
* **csp_allow_default** List of default domains to include in the Content Security Policy. Typically you would list the URL of your API here if your pages access that. Always includes `'self'`
* **csp_allow_style** List of places to allow CSP to load styles from. Always includes `'self'`
* **csp_allow_img** List of places to allow CSP to load images from. Always includes `'self'`
* **csp_allow_font** List of places to allow CSP to load fonts from. Always includes `'self'`
* **csp_allow_frame** List of places to allow CSP to load iframes from. Always includes `'self'`
* **mime_types** Map from file extension to MIME type. Defaults are provided, but you will need to provide any unusual extensions with a MIME type

### Outputs
* **url** The URL on which the home page of the website can be reached
* **alternate_urls** Alternate URLs which also point to the same home page as *url* does
