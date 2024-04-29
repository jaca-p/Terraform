terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
			version = ">= 2.1.2"
    }
  }
  required_version = ">= 1.1.5"
}

provider "ncloud" {
	site = "public"
	support_vpc = true
	region = "KR"
}

resource "ncloud_vpc" "ossca_vpc" {
	name	= "ossca-vpc"
	ipv4_cidr_block = "10.0.0.0/16"
}

resource "ncloud_route_table" "ossca_route_table" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	supported_subnet_type = "PRIVATE"
}

resource "ncloud_nat_gateway" "ossca_nat_gw" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	zone = "KR-1"
}

resource "ncloud_route" "nat_route" {
	route_table_no = ncloud_route_table.ossca_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	target_type = "NATGW"
	target_name = ncloud_nat_gateway.ossca_nat_gw.name
	target_no = ncloud_nat_gateway.ossca_nat_gw.id
}

resource "ncloud_route_table_association" "route_table_subet-1" {
	route_table_no = ncloud_route_table.ossca_route_table.id
	subnet_no = ncloud_subnet.private_general_subnet-1.id
}

resource "ncloud_route_table_association" "route_table_subet-2" {
	route_table_no = ncloud_route_table.ossca_route_table.id
	subnet_no = ncloud_subnet.private_general_subnet-2.id
}
resource "ncloud_subnet" "public_general_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.1.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PUBLIC" // PUBLIC | PRIVATE
	usage_type = "GEN" // GEN(general) | LOADB(loadbalancer)
	name = "${ncloud_vpc.ossca_vpc.name}-pub-gen-sub"
}

resource "ncloud_subnet" "public_nat_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.2.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PUBLIC" // PUBLIC | PRIVATE
	usage_type = "NATGW"
	name = "${ncloud_vpc.ossca_vpc.name}-pub-natgw-sub"
}

resource "ncloud_subnet" "private_general_subnet-1" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.3.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PRIVATE" // PUBLIC | PRIVATE
	usage_type = "GEN" 
	name = "${ncloud_vpc.ossca_vpc.name}-pri-gen-sub-1"
}

resource "ncloud_subnet" "private_general_subnet-2" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.4.0/24"
	zone = "KR-2"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PUBLIC" // PUBLIC | PRIVATE
	usage_type = "GEN" 
	name = "${ncloud_vpc.ossca_vpc.name}-pri-gen-sub-2"
}

resource "ncloud_subnet" "private_lb_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.5.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PRIVATE"
	name = "${ncloud_vpc.ossca_vpc.name}-pri-loadb-sub"
	usage_type = "LOADB"
}
