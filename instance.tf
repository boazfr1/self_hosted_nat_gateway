resource "aws_instance" "nat_instance" {
  ami               = "ami-0ae8f15ae66fe8cda"
  instance_type     = "t3.micro"
  availability_zone = "us-east-1a"
  key_name          = data.aws_key_pair.nat.key_name


  #   subnet_id              = aws_subnet.public_subnet.id
  #   vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]

  network_interface {
    network_interface_id = aws_network_interface.nat_instance_interface.id
    device_index         = 0
  }

  #   source_dest_check = false


  provisioner "local-exec" {
    command = "aws ec2 modify-instance-attribute --instance-id ${self.id} --no-source-dest-check"
  }

  user_data = <<-EOF
                    #!/bin/bash
                    sudo yum update -y
                    sudo yum install iptables-services -y
                    sudo systemctl enable iptables
                    sudo systemctl start iptables

                    # Enable IP forwarding
                    echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/custom-ip-forwarding.conf
                    sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

                    # Identify the primary network interface
                    PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}')

                    # Configure NAT
                    sudo /sbin/iptables -t nat -A POSTROUTING -o $PRIMARY_INTERFACE -j MASQUERADE
                    sudo /sbin/iptables -A FORWARD -i $PRIMARY_INTERFACE -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
                    sudo /sbin/iptables -A FORWARD -i eth0 -o $PRIMARY_INTERFACE -j ACCEPT

                    # Save iptables rules
                    sudo service iptables save

                    # Ensure iptables rules are applied on boot
                    echo '#!/bin/bash' | sudo tee /etc/network/if-pre-up.d/iptables
                    echo 'iptables-restore < /etc/sysconfig/iptables' | sudo tee -a /etc/network/if-pre-up.d/iptables
                    sudo chmod +x /etc/network/if-pre-up.d/iptables
                EOF

  tags = {
    Name = "nat_instance"
  }
}


resource "aws_instance" "private_instance" {
  ami               = "ami-0ae8f15ae66fe8cda"
  instance_type     = "t3.micro"
  availability_zone = "us-east-1a"
  key_name          = data.aws_key_pair.nat.key_name



  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]



  tags = {
    Name = "private_instance"
  }
}

