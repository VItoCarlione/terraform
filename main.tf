resource random_password name {
  length  = length
  upper   = true
  lower   = true
  number  = true
  special = true

  keepers = {
    id = value
  }
}

