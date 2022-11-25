###############################
####### Loadbalancer ##########
##############################

resource "aws_lb" "lb" {
  name            = "${var.app_name}-${var.app_environment}-lb"
  subnets         = aws_subnet.pub_subnet.*.id
  security_groups = [aws_security_group.lb-sg.id]
}



###############################
### LB Target Groups ######
##############################

resource "aws_lb_target_group" "lb-tg" {
  name        = "${var.app_name}-${var.app_environment}-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "${var.tg_port}"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}
resource "aws_lb_target_group" "target_group_jenkins" {
  name        = "${var.app_name}-${var.app_environment}-tg-jenkins"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  #vpc_id      = "vpc-0252c0a76240939c5"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    port                = "8080"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-lb-tg-jenkins"
    Environment = var.app_environment
  }
}

###############################
####### LB Listener #########
##############################

resource "aws_lb_listener" "lb-lt" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.lb-tg]

  default_action {
    target_group_arn = aws_lb_target_group.lb-tg.arn
    type             = "forward"
  }
}
