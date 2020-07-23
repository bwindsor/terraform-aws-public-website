provider "aws" {
  profile = var.profile
  region  = "us-east-1"
  alias   = "protected-website-us-east-1"
}
