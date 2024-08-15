data "aws_key_pair" "nat" {
  key_name = "nat"
  include_public_key = true
}