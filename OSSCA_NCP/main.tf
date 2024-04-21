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

resource "ncloud_subnet" "public_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.1.0/24"
	zone = "KR-2"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PUBLIC" // PUBLIC | PRIVATE
	usage_type = "GEN" // GEN(general) | LOADB(loadbalancer)
	name = "${ncloud_vpc.ossca_vpc.name}-pub-sub"
}

resource "ncloud_subnet" "private_subnet" {
	vpc_no = ncloud_vpc.ossca_vpc.id
	subnet = "10.0.2.0/24"
	zone = "KR-1"
	network_acl_no = ncloud_vpc.ossca_vpc.default_network_acl_no
	subnet_type = "PRIVATE"
	name = "${ncloud_vpc.ossca_vpc.name}-pri-sub"
	usage_type = "GEN"
}
