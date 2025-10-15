# ============================================
# Instance EC2 - Base de données PostgreSQL
# ============================================
resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Lancer PostgreSQL
    docker run -d --name marinelangrez-postgres \
      -e POSTGRES_DB=forum \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=${var.db_password} \
      -p 5432:5432 \
      --restart unless-stopped \
      postgres:15-alpine
    
    # Attendre que PostgreSQL soit prêt puis créer la table
    sleep 30
    docker exec marinelangrez-postgres psql -U postgres -d forum -c "
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        pseudo TEXT NOT NULL,
        text TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
      );
      INSERT INTO messages (pseudo, text) VALUES 
        ('MarineLangrez', 'Base de données déployée avec Terraform!'),
        ('System', 'PostgreSQL fonctionne parfaitement');
    "
  EOF
  )

  tags = {
    Name  = "MarineLangrez-Forum-Database"
    Type  = "Database"
    Owner = "MarineLangrez"
  }
}

# ============================================
# Instance EC2 - API
# ============================================
resource "aws_instance" "api" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.database]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    export GITHUB_TOKEN="${var.github_token}"
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    
    sleep 10
    
    docker stop marinelangrez-api 2>/dev/null || true
    docker rm marinelangrez-api 2>/dev/null || true
    
    docker pull ghcr.io/woorzz/forum-anonyme-api:${var.image_tag}
    
    docker run -d --name marinelangrez-api \
      -p 3000:3000 \
      -e DB_HOST=${aws_instance.database.private_ip} \
      -e DB_USER=postgres \
      -e DB_PASSWORD=${var.db_password} \
      -e DB_NAME=forum \
      -e DB_PORT=5432 \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme-api:${var.image_tag}

    echo "API ready" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
  EOF
  )

  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-API"
    Type  = "API"
    Owner = "MarineLangrez"
  }
}

# ============================================
# Instance EC2 - Thread (lecture)
# ============================================
resource "aws_instance" "thread" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.api]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io curl
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    export GITHUB_TOKEN="${var.github_token}"
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    sleep 10

    docker stop marinelangrez-thread 2>/dev/null || true
    docker rm marinelangrez-thread 2>/dev/null || true

    docker pull ghcr.io/woorzz/forum-anonyme-thread:${var.image_tag}

    # Récupérer sa propre IP publique via metadata
    SELF_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    docker run -d --name marinelangrez-thread \
      -p 80:3000 \
      -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 \
      -e NUXT_PUBLIC_THREAD_URL=http://$SELF_IP \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme-thread:${var.image_tag}

    echo "Thread ready" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
  EOF
  )

  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-Thread"
    Type  = "Frontend"
    Owner = "MarineLangrez"
  }
}

# ============================================
# Instance EC2 - Sender (envoi)
# ============================================
resource "aws_instance" "sender" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.api]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io curl
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    export GITHUB_TOKEN="${var.github_token}"
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    sleep 10

    docker stop marinelangrez-sender 2>/dev/null || true
    docker rm marinelangrez-sender 2>/dev/null || true

    docker pull ghcr.io/woorzz/forum-anonyme-sender:${var.image_tag}

    SELF_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    docker run -d --name marinelangrez-sender \
      -p 8080:3000 \
      -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 \
      -e NUXT_PUBLIC_SENDER_URL=http://$SELF_IP:8080 \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme-sender:${var.image_tag}

    echo "Sender ready" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
  EOF
  )

  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-Sender"
    Type  = "Frontend"
    Owner = "MarineLangrez"
  }
}

# ============================================
# Mise à jour des conteneurs avec les URLs finales
# ============================================

# Mise à jour du conteneur thread avec l'URL du sender
resource "null_resource" "update_thread_urls" {
  depends_on = [aws_instance.thread, aws_instance.sender]

  triggers = {
    thread_ip = aws_instance.thread.public_ip
    sender_ip = aws_instance.sender.public_ip
    api_ip    = aws_instance.api.public_ip
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
    host        = aws_instance.thread.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60", # Attendre que le conteneur initial soit démarré
      "docker stop marinelangrez-thread || true",
      "docker rm marinelangrez-thread || true",
      "docker run -d --name marinelangrez-thread -p 80:3000 -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 --restart unless-stopped ghcr.io/woorzz/forum-anonyme-thread:${var.image_tag}"
    ]
  }
}

# Mise à jour du conteneur sender avec l'URL du thread
resource "null_resource" "update_sender_urls" {
  depends_on = [aws_instance.thread, aws_instance.sender]

  triggers = {
    thread_ip = aws_instance.thread.public_ip
    sender_ip = aws_instance.sender.public_ip
    api_ip    = aws_instance.api.public_ip
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
    host        = aws_instance.sender.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60", # Attendre que le conteneur initial soit démarré
      "docker stop marinelangrez-sender || true",
      "docker rm marinelangrez-sender || true",
      "docker run -d --name marinelangrez-sender -p 8080:3000 -e NUXT_PUBLIC_API_BASE=http://${aws_instance.api.public_ip}:3000 -e NUXT_PUBLIC_SENDER_URL=http://${aws_instance.sender.public_ip}:8080 -e NUXT_PUBLIC_THREAD_URL=http://${aws_instance.thread.public_ip} --restart unless-stopped ghcr.io/woorzz/forum-anonyme-sender:${var.image_tag}"
    ]
  }
}
