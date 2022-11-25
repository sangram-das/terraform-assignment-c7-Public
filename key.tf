resource "aws_key_pair" "Key-Pair" {

  # Name of the Key
  key_name   = "MyKey"

  # Adding the SSH authorized key !
  public_key = file("~/.ssh/id_rsa.pub")
  
 }
