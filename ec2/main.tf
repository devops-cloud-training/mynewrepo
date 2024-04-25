resource "aws_instance" "my_first_server" {
  ami                     = "ami-04e5276ebb8451442"
  instance_type           = "t2.micro"
  key_name = aws_key_pair.my_public_key.id

  #provisioner "local-exec" {
  #  command = "echo ${aws_instance.my_first_server.public_ip} >> file.txt"
  #}

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = ""
    private_key = local_file.private_key_file.content
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
        "chmod 777 /tmp/script.sh",
        "sudo /tmp/script.sh"
    ]
  }
}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_file" {
    filename = "privatekey.pem"
    content = tls_private_key.mykey.private_key_pem
}

resource "aws_key_pair" "my_public_key" {
  key_name   = "my-public-key"
  public_key = tls_private_key.mykey.public_key_openssh
}