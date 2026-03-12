terraform {
  #   backend "azurerm" { 
  #   }  Running localy

  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source  = "hashicorp/azurerm"
      version = ">= 4.30.0" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    }
  }
}