resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # later we restrict to ALB
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can restrict to your IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating launch template for EC2 instances
resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = "ami-0f58b397bc5c1f2e8" # Amazon Linux (Mumbai region)
  instance_type = "t2.micro"

  #this(vpc_security_group_ids) part come from terraform doc "aws_launch_template" you have to read Argument Reference
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
                #!/bin/bash
                yum update -y
                yum install -y git nodejs

                cd /home/ec2-user
                git clone https://github.com/heroku/node-js-sample.git

                cd node-js-sample
                npm install

                # Run app on port 80
                PORT=80 npm start > app.log 2>&1 &
                EOF
  )
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
}

#Create Auto Scaling Group (ASG)

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = var.private_subnet_ids #where you want to launch your ec2 instance

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }

}