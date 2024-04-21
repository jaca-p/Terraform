terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
			version = ">= 2.1.2"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {
	support_vpc = true
	region = "KR"
}

