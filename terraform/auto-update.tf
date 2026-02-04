# ============================================
# Mise à jour automatique des conteneurs après déploiement
# ============================================
# Utilise local-exec pour attendre que Docker soit installé
# puis met à jour les conteneurs avec les bonnes URLs

resource "null_resource" "update_containers" {
  depends_on = [aws_instance.thread, aws_instance.sender, aws_instance.api]

  triggers = {
    thread_ip = aws_instance.thread.public_ip
    sender_ip = aws_instance.sender.public_ip
    api_ip    = aws_instance.api.public_ip
    image_tag = var.image_tag
  }

  # Attendre et mettre à jour THREAD
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "⏳ Attente 2 minutes pour l'installation de Docker sur Thread..."
      sleep 120
      
      echo "🔄 Mise à jour du conteneur Thread..."
      ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        -i ${var.private_key_path} \
        ubuntu@${aws_instance.thread.public_ip} << 'EOF'
        
        # Attendre Docker
        for i in {1..30}; do
          if command -v docker >/dev/null 2>&1; then
            echo "✅ Docker détecté"
            break
          fi
          echo "Attente Docker... ($i/30)"
          sleep 10
        done
        
        # Attendre le conteneur initial
        for i in {1..20}; do
          if sudo docker ps -a 2>/dev/null | grep -q marinelangrez-thread; then
            echo "✅ Conteneur initial détecté"
            break
          fi
          echo "Attente conteneur... ($i/20)"
          sleep 5
        done
        
        # Recréer avec bonnes URLs
        sudo docker stop marinelangrez-thread 2>/dev/null || true
        sudo docker rm marinelangrez-thread 2>/dev/null || true
        
        sudo docker run -d --name marinelangrez-thread \
          -p 80:3000 \
          -e NUXT_PUBLIC_API_URL=http://${aws_instance.api.public_ip}:3000 \
          -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} \
          -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 \
          --restart unless-stopped \
          ghcr.io/woorzz/forum-anonyme-thread:${var.image_tag}
        
        echo "✅ Thread container updated"
        sudo docker ps | grep marinelangrez-thread
EOF
    EOT
  }

  # Attendre et mettre à jour SENDER
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "⏳ Attente 2 minutes pour l'installation de Docker sur Sender..."
      sleep 120
      
      echo "🔄 Mise à jour du conteneur Sender..."
      ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        -i ${var.private_key_path} \
        ubuntu@${aws_instance.sender.public_ip} << 'EOF'
        
        # Attendre Docker
        for i in {1..30}; do
          if command -v docker >/dev/null 2>&1; then
            echo "✅ Docker détecté"
            break
          fi
          echo "Attente Docker... ($i/30)"
          sleep 10
        done
        
        # Attendre le conteneur initial
        for i in {1..20}; do
          if sudo docker ps -a 2>/dev/null | grep -q marinelangrez-sender; then
            echo "✅ Conteneur initial détecté"
            break
          fi
          echo "Attente conteneur... ($i/20)"
          sleep 5
        done
        
        # Recréer avec bonnes URLs
        sudo docker stop marinelangrez-sender 2>/dev/null || true
        sudo docker rm marinelangrez-sender 2>/dev/null || true
        
        sudo docker run -d --name marinelangrez-sender \
          -p 8080:3000 \
          -e NUXT_PUBLIC_API_URL=http://${aws_instance.api.public_ip}:3000 \
          -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} \
          -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 \
          --restart unless-stopped \
          ghcr.io/woorzz/forum-anonyme-sender:${var.image_tag}
        
        echo "✅ Sender container updated"
        sudo docker ps | grep marinelangrez-sender
EOF
    EOT
  }
}
