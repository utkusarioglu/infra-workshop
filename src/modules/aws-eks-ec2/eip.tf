resource "aws_eip" "nat_gw_elastic_ip" {
  tags = {
    Name = "${local.name}-nat-eip"
  }
}
