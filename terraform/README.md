# Déploiement du Forum Anonyme sur AWS avec Terraform - MarineLangrez

## 🚀 Architecture simplifiée avec Docker

Cette configuration utilise **Docker et Docker Compose** directement sur les instances EC2, sans scripts complexes.

## Prérequis

1. **AWS CLI installé et configuré** avec vos credentials
2. **Terraform installé** (version >= 1.0)
3. **Une paire de clés AWS** (Key Pair) créée dans votre région

## Architecture déployée

- **Instance Database** : PostgreSQL dans un conteneur Docker
- **Instance API** : API Node.js dans un conteneur Docker  
- **Instance Thread** : Interface HTML/JS de lecture avec Nginx
- **Instance Sender** : Interface HTML/JS d'envoi avec Nginx

Tout s'exécute automatiquement avec `docker-compose up -d` ! 🐳

## Étapes de déploiement

### 1. Créer votre paire de clés AWS (si pas encore fait)

```bash
# Via AWS CLI
aws ec2 create-key-pair --key-name marinelangrez-forum-keypair --query 'KeyMaterial' --output text > ~/.ssh/marinelangrez-forum-keypair.pem
chmod 400 ~/.ssh/marinelangrez-forum-keypair.pem
```

Ou créez-la via la console AWS EC2 > Key Pairs avec le nom `marinelangrez-forum-keypair`.

### 2. Configurer les variables

Éditez le fichier `terraform.tfvars` (à créer) :

```hcl
aws_region      = "eu-central-1"  # Changez selon votre région (Francfort par défaut)
key_pair_name   = "marinelangrez-forum-keypair"  # Nom de votre paire de clés
db_password     = "monMotDePasseSecurise"  # Changez le mot de passe
```

### 3. Initialiser Terraform

```bash
cd terraform/
terraform init
```

### 4. Planifier le déploiement

```bash
terraform plan
```

### 5. Déployer l'infrastructure

```bash
terraform apply
```

Tapez `yes` pour confirmer.

### 6. Récupérer les informations de connexion

```bash
terraform output
```

Vous obtiendrez :
- Les IPs publiques de chaque instance
- Les URLs d'accès aux applications
- Les commandes SSH pour vous connecter

## Architecture déployée

- **Instance Database** : PostgreSQL sur port 5432 (Docker)
- **Instance API** : API Node.js sur port 3000 (Docker)
- **Instance Thread** : Interface de lecture sur port 80 (Nginx)
- **Instance Sender** : Interface d'envoi sur port 8080 (Nginx)

Chaque service s'exécute automatiquement dans Docker ! 🎯

## Accès aux applications

Après le déploiement :

1. **API** : `http://<api_public_ip>:3000`
   - GET `/messages` : Récupérer les messages
   - POST `/messages` : Ajouter un message

2. **Interface de lecture** : `http://<thread_public_ip>:80`

3. **Interface d'envoi** : `http://<sender_public_ip>:8080`

## SSH vers les instances

```bash
# Connexion à la base de données
ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@<database_public_ip>

# Connexion à l'API
ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@<api_public_ip>

# Connexion à Thread
ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@<thread_public_ip>

# Connexion à Sender  
ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@<sender_public_ip>
```

## Nettoyage

Pour supprimer toute l'infrastructure :

```bash
terraform destroy
```

## Dépannage

### Les conteneurs ne démarrent pas
- Connectez-vous en SSH et vérifiez : `docker ps`
- Vérifiez les logs : `docker-compose logs`

### Problèmes de connexion à l'API
- Vérifiez que l'API répond : `curl http://localhost:3000/health`
- Vérifiez les security groups AWS

### Les interfaces web ne se chargent pas
- Vérifiez que Nginx écoute : `netstat -tlnp | grep 80`
- Vérifiez les logs : `docker logs <container_name>`