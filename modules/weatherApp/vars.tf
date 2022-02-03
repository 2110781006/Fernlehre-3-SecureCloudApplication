variable "name" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "min_instances" {
  type = number
  default = 1
}

variable "max_instances" {
  type = number
  default = 1
}

variable "desired_instances" {
  type = number
  default = 1
}

variable "weatherstackToken" {
  description = "weatherstack api token"
  type = string
}

variable "gitHubToken" {
  description = "gitHubToken"
  type = string
}

variable "githubUser" {
  description = "GITHUB_USER"
  type = string
}

variable "githubClientId" {
  description = "GITHUB_CLIENT_ID"
  type = string
}

variable "githubClientSecret" {
  description = "GITHUB_CLIENT_SECRET"
  type = string
}