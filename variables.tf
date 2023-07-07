variable PRE {
  type = string
  default = "prefix-"
  description = "prefix for all resources names"
}
variable OWNER {
  type = string
  default = "owner"
  description = "owner of all resources (nick)"
}
variable AWS_REGION {
  type = string
  default = "us-east-1"
}
variable AWS_RDS_PASS {
  type = string
  description = "password to postgres"
}
variable AWS_STATE_BUCKET {}
variable AWS_STATE_BUCKET_KEY {}
variable AWS_ACCESS_KEY_ID {}
variable AWS_SECRET_ACCESS_KEY {}