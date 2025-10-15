# Instance EC2 pour la base de données PostgreSQL
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
    
    # Attendre que postgres soit prêt et créer la table
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

# Instance EC2 pour l'API 
resource "aws_instance" "api" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.database]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Version: ${formatdate("YYYY-MM-DD-hhmm", timestamp())}
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Exporter le token GitHub dans une variable d'environnement
    export GITHUB_TOKEN="${var.github_token}"
    
    # Authentification GitHub Container Registry avec login explicite
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    
    # Attendre un peu pour que l'authentification soit effective
    sleep 10
    
    # Arrêter et supprimer les conteneurs existants
    docker stop marinelangrez-api 2>/dev/null || true
    docker rm marinelangrez-api 2>/dev/null || true
    
    # Utiliser votre image API précompilée depuis GitHub Container Registry
    docker pull ghcr.io/woorzz/forum-anonyme/api:06bb140
    docker run -d --name marinelangrez-api \
      -p 3000:3000 \
      -e DB_HOST=${aws_instance.database.private_ip} \
      -e DB_PASSWORD=${var.db_password} \
      -e DB_USER=postgres \
      -e DB_NAME=forum \
      -e DB_PORT=5432 \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme/api:06bb140
    
    # Logs de debug
    echo "API Docker containers:" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
    docker logs marinelangrez-api >> /var/log/docker-setup.log 2>&1
    EOF
  )

  # Force la recréation de l'instance si user_data change
  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-API"
    Type  = "API"
    Owner = "MarineLangrez"
  }
}

# Instance EC2 pour Thread (interface de lecture)
resource "aws_instance" "thread" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.api]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Version: ${formatdate("YYYY-MM-DD-hhmm", timestamp())}
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Exporter le token GitHub dans une variable d'environnement
    export GITHUB_TOKEN="${var.github_token}"
    
    # Authentification GitHub Container Registry avec login explicite
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    
    # Attendre un peu pour que l'authentification soit effective
    sleep 10
    
    # Arrêter et supprimer les conteneurs existants
    docker stop marinelangrez-thread 2>/dev/null || true
    docker rm marinelangrez-thread 2>/dev/null || true
    
    # Utiliser votre image Thread précompilée depuis GitHub Container Registry
    docker pull ghcr.io/woorzz/forum-anonyme/thread:v2-1760515849
    docker run -d --name marinelangrez-thread \
      -p 80:3000 \
      -e API_URL=http://${aws_instance.api.private_ip}:3000 \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme/thread:v2-1760515849
    
    # Logs de debug  
    echo "Thread Docker containers:" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
    docker logs marinelangrez-thread >> /var/log/docker-setup.log 2>&1
    EOF
  )

  # Force la recréation de l'instance si user_data change
  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-Thread"
    Type  = "Frontend"
    Owner = "MarineLangrez"
  }
}

# Instance EC2 pour Sender (interface d'envoi)
resource "aws_instance" "sender" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  depends_on = [aws_instance.api]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Version: ${formatdate("YYYY-MM-DD-hhmm", timestamp())}
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Exporter le token GitHub dans une variable d'environnement
    export GITHUB_TOKEN="${var.github_token}"
    
    # Authentification GitHub Container Registry avec login explicite
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u woorzz --password-stdin
    
    # Vérifier l'authentification
    docker info | grep -A5 "Registry Mirrors"
    
    # Attendre un peu pour que l'authentification soit effective
    sleep 10
    
    # Arrêter et supprimer les conteneurs existants
    docker stop marinelangrez-sender 2>/dev/null || true
    docker rm marinelangrez-sender 2>/dev/null || true
    
    # Utiliser votre image Sender précompilée depuis GitHub Container Registry
    docker pull ghcr.io/woorzz/forum-anonyme/sender:06bb140
    docker run -d --name marinelangrez-sender \
      -p 8080:3000 \
      -e API_URL=http://${aws_instance.api.private_ip}:3000 \
      --restart unless-stopped \
      ghcr.io/woorzz/forum-anonyme/sender:06bb140
    
    # Logs de debug
    echo "Docker containers:" > /var/log/docker-setup.log
    docker ps -a >> /var/log/docker-setup.log
    docker logs marinelangrez-sender >> /var/log/docker-setup.log 2>&1
    EOF
  )

  # Force la recréation de l'instance si user_data change
  user_data_replace_on_change = true

  tags = {
    Name  = "MarineLangrez-Forum-Sender"
    Type  = "Frontend"
    Owner = "MarineLangrez"
  }
}