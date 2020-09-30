/*
These are proxy provider blocks, they just declare that the calling module must pass
aws.main and aws.us-east-1 as providers
*/

provider "aws" {
  alias = "main"
}

provider "aws" {
  alias = "us-east-1"
}
