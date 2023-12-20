data "aws_vpc" "selected" {
  default = true

}
data "aws_subnets" "pb-subnets" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  # filter {
  #   name = "tag:Name"
  #   values = [ "default*" ]
  # }

}
data "aws_ami" "al-2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10*"]
  }

  # filter {
  #   name = "virtualization-type"
  #   values = [ "hvm" ]
  # }
  # filter {
  #   name = "architecture"
  #   values = [ "x86_64" ]
  # }
  # filter {
  #   name = "name"
  #   values = ["al2023-ami-2023"]
  # }

}
resource "aws_launch_template" "pb-asg-lt" {
  name                   = "pb-lt"
  image_id               = data.aws_ami.al-2023.id
  instance_type          = "t2.micro"
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  user_data              = filebase64("user-data.sh")
  # base64encode(templatefile("user-data.sh", { user-data-git-token = var.git-token, user-data-git-name = var.git-name }))  # file("userdata/install.sh")
  depends_on = [github_repository_file.dbendpoint]
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "Web Serve₹of Phonebook Application"
    }
  }

}
resource "aws_alb_target_group" "pb-alb-tg" {
  name        = "phonebook-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

}
resource "aws_alb" "pb-alb" {
  name               = "phonebook-lb-tf"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = data.aws_subnets.pb-subnets.ids

}
resource "aws_alb_listener" "pb-listener" {
  load_balancer_arn = aws_alb.pb-alb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.pb-alb-tg.arn
  }

}
resource "aws_autoscaling_group" "pb-asg" {
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  name                      = "phonebook-asg"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_alb_target_group.pb-alb-tg.arn]
  vpc_zone_identifier       = aws_alb.pb-alb.subnets
  launch_template {
    id      = aws_launch_template.pb-asg-lt.id
    version = aws_launch_template.pb-asg-lt.latest_version
  }

}
resource "aws_db_instance" "pb-db-server" {
  instance_class              = "db.t2.micro"
  engine                      = "mysql"
  allocated_storage           = 20
  vpc_security_group_ids      = [aws_security_group.pb-db-sg.id]
  allow_major_version_upgrade = false
  publicly_accessible         = false
  db_name                     = "phonebookdb"
  username                    = "admin"
  backup_retention_period     = 0
  skip_final_snapshot         = true
  engine_version              = "8.0.32"
  password                    = "Oliver_1"
  multi_az                    = false
  identifier                  = "phonebook-app-db"
  monitoring_interval         = 0
  auto_minor_version_upgrade  = true
  port                        = 3306


}
resource "github_repository_file" "dbendpoint" {
  repository          = "Terraform-Phonebook-Application-deployed-on-AWS"
  file                = "dbserver.endpoint"
  branch              = "main"
  content             = aws_db_instance.pb-db-server.address
  overwrite_on_create = true

}