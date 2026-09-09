locals {
  common_tags = {
    product_id = "quota endpoint"
    facet      = "admin"
  }

  usernames = toset([for developer in yamldecode(file("${path.module}/developers.yaml")).developers : developer.username])
}
