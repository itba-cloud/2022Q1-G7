provider "aws" {
  alias  = "aws"
  region = "us-east-1"

  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"

  default_tags {
    tags = {
      author     = "Grupo 7"
      version    = 1
      university = "ITBA"
      subject    = "Cloud Computing"
      created-by = "terraform"
    }
  }
}