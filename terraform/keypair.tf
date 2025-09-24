# Note: La paire de clés SSH est supposée exister déjà dans AWS
# Elle a été créée avec le nom 'marinelangrez-forum-keypair'
# 
# Si vous voulez la créer automatiquement, décommentez ci-dessous:
# resource "aws_key_pair" "forum_keypair" {
#   key_name   = var.key_pair_name
#   public_key = file("~/.ssh/marinelangrez-forum-keypair.pub")
#
#   tags = {
#     Name = "MarineLangrez-Forum-KeyPair"
#     Owner = "MarineLangrez"
#   }
# }