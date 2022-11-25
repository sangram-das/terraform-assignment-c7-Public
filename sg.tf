###### Get my IP  ##########
data "external" "whatismyip" {
  program = ["/bin/bash" , "./myip.sh"]
}

###### Public Web SG  ##########
resource "aws_security_group" "lb-sg" {
  name   = "${var.app_name}-${var.app_environment}-lb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#######  Bastion Host SG ##############
resource "aws_security_group" "jump-sg" {
  name   = "${var.app_name}-${var.app_environment}-jump-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######## Private Instances SG  ########
resource "aws_security_group" "ec2-sg" {
  depends_on = [
    aws_security_group.lb-sg
  ]
  name   = "${var.app_name}-${var.app_environment}-es-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  ingress {
    security_groups = [aws_security_group.lb-sg.id]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
