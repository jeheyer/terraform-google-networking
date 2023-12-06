terraform {
  required_version = ">= 1.5.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.49.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}
