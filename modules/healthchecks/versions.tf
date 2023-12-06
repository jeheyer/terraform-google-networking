terraform {
  required_version = ">= 1.5.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.49, < 5.0"
    }
  }
}
