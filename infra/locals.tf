# Locals shared by several files (the <name_prefix>-<env> name)
locals {
  name = "${var.name_prefix}-${var.env}"
}