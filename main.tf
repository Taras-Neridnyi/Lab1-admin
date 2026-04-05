terraform {
  backend "s3" {
    bucket         = "923485826734-terraform-tfstate"
    key            = "lab1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Обов'язковий модуль для неймінгу згідно з вимогами
module "labels" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "politeh"
  stage     = "dev"
  name      = "lab1"
}

# Виклик кастомного модуля для таблиці courses
module "table_courses" {
  source     = "./modules/dynamodb"
  table_name = "${module.labels.id}-courses"
}

# Виклик кастомного модуля для таблиці authors
module "table_authors" {
  source     = "./modules/dynamodb"
  table_name = "${module.labels.id}-authors"
}