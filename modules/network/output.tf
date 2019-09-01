output "vpc_id" {
  value = "${aws_vpc.demo.id}"
}

output "app_subnet_ids" {
  value = "${aws_subnet.demo.*.id}"
}

output "gateway_subnet_ids" {
  value = "${aws_internet_gateway.demo.id}"
}
