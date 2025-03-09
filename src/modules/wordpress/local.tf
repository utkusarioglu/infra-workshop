locals {
  tld = "utkusarioglu.com"
  sld = "eks1"

  hostname = "${local.sld}.${local.tld}"
}
