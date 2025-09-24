# Configuration principale - Terraform Infrastructure as Code
# Projet: Forum Anonyme - MarineLangrez
# 
# Structure modulaire:
# - providers.tf: Configuration des providers AWS
# - data.tf: Sources de données (AMI Ubuntu)  
# - security.tf: Security groups et règles réseau
# - instances.tf: Instances EC2 (database, api, thread, sender)
# - keypair.tf: Configuration clés SSH
# - variables.tf: Variables d'entrée
# - outputs.tf: Variables de sortie
# - terraform.tfvars: Valeurs des variables (fichier local, non committé)
#
# Pour déployer:
# 1. Copier terraform.tfvars.example vers terraform.tfvars
# 2. Remplir les valeurs dans terraform.tfvars
# 3. terraform init
# 4. terraform plan
# 5. terraform apply