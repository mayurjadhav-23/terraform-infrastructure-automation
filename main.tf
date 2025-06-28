resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-north-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}


resource "aws_route_table_association" "RTA2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "websg" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_s3_bucket" "s3buck" {
  bucket = "my-s3-demo-2025abc"

}

resource "aws_instance" "myec2-a" {
  ami              = var.ami_id
  instance_type    = var.inst_type
  subnet_id        = aws_subnet.sub1.id
  key_name         = var.key_name
  security_groups  = [aws_security_group.websg.id]
  user_data_base64 = base64encode(file("userdata.sh"))
}
resource "aws_instance" "myec2-b" {
  ami              = var.ami_id
  instance_type    = var.inst_type
  subnet_id        = aws_subnet.sub2.id
  key_name         = var.key_name
  security_groups  = [aws_security_group.websg.id]
  user_data_base64 = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "loadbal" {
  name               = "demo-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    name = "webb"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.myec2-a.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.myec2-b.id
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.loadbal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.test.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.loadbal.dns_name
}