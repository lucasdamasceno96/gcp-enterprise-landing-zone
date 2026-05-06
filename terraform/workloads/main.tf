terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "workloads/state"
  }
}
