resource "aws_instance" "bastion" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.pub_subnet,
    aws_security_group.jump-sg,
  ]
  ami = "ami-0149b2da6ceec4bb0"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub_subnet.1.id
  key_name = "MyKey"
  vpc_security_group_ids = [aws_security_group.jump-sg.id]
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-bastion"
  }
}
resource "aws_instance" "jenkins" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.priv_subnet,
    aws_security_group.ec2-sg
  ]
  ami = "ami-0149b2da6ceec4bb0"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.priv_subnet.1.id
  key_name = "MyKey"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-jenkins"
  }
}
resource "aws_instance" "appserver" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.priv_subnet,
    aws_security_group.ec2-sg
  ]
  ami = "ami-0149b2da6ceec4bb0"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.priv_subnet.1.id
  key_name = "MyKey"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-appserver"
  }
}
resource "aws_eip" "eip_manager" {
  instance = aws_instance.bastion.id
  vpc = true

  tags = {
    Name = "${var.app_name}-${var.app_environment}-eip-bastion"
  }
}
