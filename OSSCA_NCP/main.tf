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

resource "ncloud_network_acl" "ssh_nacl" {
   vpc_no      = ncloud_vpc.ossca_vpc.id
   name        = "ssh-nacl"
   description = "ssh in bastion"
}

resource "ncloud_network_acl_rule" "ssh_nacl_rule" {
  network_acl_no    = ncloud_network_acl.ssh_nacl.id

  inbound {
    priority    = 100
    protocol    = "TCP"
    rule_action = "ALLOW"
    ip_block    = "10.0.0.0/16"
    port_range  = "22"
  }
}

resource "ncloud_network_acl" "bastion_nacl" {
   vpc_no      = ncloud_vpc.ossca_vpc.id
   name        = "bastion-nacl"
   description = "bastion to private server ssh"
}

resource "ncloud_network_acl_rule" "bastion_nacl_rule" {
  network_acl_no    = ncloud_network_acl.bastion_nacl.id

  inbound {
    priority    = 100
    protocol    = "TCP"
    rule_action = "ALLOW"
    ip_block    = "0.0.0.0/0"
    port_range  = "22"
  }
}

resource "ncloud_route_table" "ossca_route_table" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	supported_subnet_type = "PRIVATE"
	name = "private-to-nat-gateway"
}

resource "ncloud_nat_gateway" "ossca_nat_gw" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	zone = "KR-1"
	subnet_no = ncloud_subnet.public_nat_subnet.id
}

resource "ncloud_route" "nat_route" {
	route_table_no = ncloud_route_table.ossca_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	target_type = "NATGW"
	target_name = ncloud_nat_gateway.ossca_nat_gw.name
	target_no = ncloud_nat_gateway.ossca_nat_gw.id
}

resource "ncloud_subnet" "public_general_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.1.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_network_acl.bastion_nacl.id
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
	network_acl_no = ncloud_network_acl.ssh_nacl.id
	subnet_type = "PRIVATE" // PUBLIC | PRIVATE
	usage_type = "GEN" 
	name = "${ncloud_vpc.ossca_vpc.name}-pri-gen-sub-1"
}

resource "ncloud_subnet" "private_general_subnet-2" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.4.0/24"
	zone = "KR-2"
	network_acl_no = ncloud_network_acl.ssh_nacl.id
	subnet_type = "PRIVATE" // PUBLIC | PRIVATE
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

resource "ncloud_server" "bastion_server" {
  subnet_no                 = ncloud_subnet.public_general_subnet.id
  name                      = "my-tf-server"
	server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
}

resource "ncloud_server" "nginx_server-1" {
  subnet_no                 = ncloud_subnet.private_general_subnet-2.id
  name                      = "my-tf-server"
	server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
}

resource "ncloud_server" "nginx_server-2" {
  subnet_no                 = ncloud_subnet.private_general_subnet-2.id
  name                      = "my-tf-server"
	server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
}



