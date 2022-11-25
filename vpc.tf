####################################
###########  VPC   ###########
##################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-vpc"
  }

}

####################################
#### IGW for Internet access  ####
##################################

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-IGW"
  }

}

#############################
######## AZ's #########
#########################

data "aws_availability_zones" "available_zones" {
  state = "available"
}


###################################
######## Subnets ################
#################################

resource "aws_subnet" "pub_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-public-subnet-${count.index}"
  }

}

resource "aws_subnet" "priv_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 4 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-private-subnet-${count.index}"
  }
}

########################################
######## Routes for Public Subnets ######
########################################


resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.pub_subnet.*.id, count.index)
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public-route.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"

}

##########################################
######### Routes for Private Subnets #######
##########################################

resource "aws_eip" "eip-ngw-1" {
  vpc                       = true
  associate_with_private_ip = var.eip-1
  depends_on                = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat-gw-1" {
  allocation_id = aws_eip.eip-ngw-1.id
  subnet_id     = element(aws_subnet.pub_subnet.*.id, 0)
  depends_on    = [aws_eip.eip-ngw-1, aws_subnet.pub_subnet]

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-1-vpc"
  }

}

resource "aws_route_table" "private-route-1" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_association-priv-1" {
  subnet_id      = element(aws_subnet.priv_subnet.*.id, 0)
  route_table_id = aws_route_table.private-route-1.id
}

resource "aws_route" "priv_route-1" {
  route_table_id         = aws_route_table.private-route-1.id
  nat_gateway_id         = aws_nat_gateway.nat-gw-1.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_route_table" "private-route-2" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_association-priv-2" {
  subnet_id      = element(aws_subnet.priv_subnet.*.id, 1)
  route_table_id = aws_route_table.private-route-2.id
}

resource "aws_route" "priv_route-2" {
  route_table_id         = aws_route_table.private-route-2.id
  nat_gateway_id         = aws_nat_gateway.nat-gw-1.id
  destination_cidr_block = "0.0.0.0/0"

}
