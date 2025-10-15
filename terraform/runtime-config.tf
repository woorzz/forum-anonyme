# ============================================
# Injection runtime de la configuration (config.js)
# ============================================
# Cette approche injecte les URLs dynamiques dans config.js
# sans rebuild des applications Nuxt

# Injection pour Thread
resource "null_resource" "inject_thread_config" {
  depends_on = [aws_instance.thread, aws_instance.sender, aws_instance.api]

  triggers = {
    thread_ip = aws_instance.thread.public_ip
    sender_ip = aws_instance.sender.public_ip
    api_ip    = aws_instance.api.public_ip
    image_tag = var.image_tag
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.thread.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Attendre que Docker et le conteneur soient prêts
      "sleep 120",
      
      # Créer le nouveau config.js avec les bonnes URLs
      "echo \"window.RUNTIME_CONFIG = { API_URL: 'http://${aws_instance.api.public_ip}:3000', SENDER_URL: 'http://${aws_instance.sender.public_ip}:8080', THREAD_URL: 'http://${aws_instance.thread.public_ip}' };\" > /tmp/config.js",
      
      # Copier dans le conteneur
      "sudo docker cp /tmp/config.js marinelangrez-thread:/app/.output/public/config.js",
      
      # Nettoyer
      "rm /tmp/config.js",
      
      # Vérifier
      "sudo docker exec marinelangrez-thread cat /app/.output/public/config.js"
    ]
  }
}

# Injection pour Sender
resource "null_resource" "inject_sender_config" {
  depends_on = [aws_instance.thread, aws_instance.sender, aws_instance.api]

  triggers = {
    thread_ip = aws_instance.thread.public_ip
    sender_ip = aws_instance.sender.public_ip
    api_ip    = aws_instance.api.public_ip
    image_tag = var.image_tag
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.sender.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Attendre que Docker et le conteneur soient prêts
      "sleep 120",
      
      # Créer le nouveau config.js avec les bonnes URLs
      "echo \"window.RUNTIME_CONFIG = { API_URL: 'http://${aws_instance.api.public_ip}:3000', SENDER_URL: 'http://${aws_instance.sender.public_ip}:8080', THREAD_URL: 'http://${aws_instance.thread.public_ip}' };\" > /tmp/config.js",
      
      # Copier dans le conteneur
      "sudo docker cp /tmp/config.js marinelangrez-sender:/app/.output/public/config.js",
      
      # Nettoyer
      "rm /tmp/config.js",
      
      # Vérifier
      "sudo docker exec marinelangrez-sender cat /app/.output/public/config.js"
    ]
  }
}
