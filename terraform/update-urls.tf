# ============================================
# Output pour mise à jour manuelle des URLs
# ============================================
# Après le premier déploiement, exécutez ces commandes 
# pour mettre à jour les conteneurs avec les URLs correctes

output "update_containers_command" {
  description = "Commands to update containers with correct URLs (run ~60s after first apply)"
  value = <<-EOT
    
    echo "⏳ Mise à jour des conteneurs avec les URLs correctes..."
    echo ""
    
    echo "📦 Mise à jour du conteneur Thread..."
    ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.thread.public_ip} "sudo docker stop marinelangrez-thread 2>/dev/null || true && sudo docker rm marinelangrez-thread 2>/dev/null || true && sudo docker run -d --name marinelangrez-thread -p 80:3000 -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 --restart unless-stopped ghcr.io/woorzz/forum-anonyme-thread:${var.image_tag}"
    
    echo "📦 Mise à jour du conteneur Sender..."
    ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.sender.public_ip} "sudo docker stop marinelangrez-sender 2>/dev/null || true && sudo docker rm marinelangrez-sender 2>/dev/null || true && sudo docker run -d --name marinelangrez-sender -p 8080:3000 -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} --restart unless-stopped ghcr.io/woorzz/forum-anonyme-sender:${var.image_tag}"
    
    echo ""
    echo "✅ Conteneurs mis à jour avec succès!"
    echo "🌐 Thread URL: http://${aws_instance.thread.public_ip}"
    echo "🌐 Sender URL: http://${aws_instance.sender.public_ip}:8080"
    
  EOT
}
