# Forum Anonyme — Déploiement complet

Ce README décrit la procédure complète pour développer, build, publier et déployer le projet "forum-anonyme" (API + frontends Nuxt "thread" et "sender") avec Docker et Terraform sur des instances EC2.

## 🔧 Architecture de configuration runtime

Les applications Nuxt (Sender et Thread) utilisent une **configuration runtime** au lieu de variables d'environnement au build. Cela permet d'utiliser des IPs dynamiques sans avoir à rebuild les images Docker.

### Comment ça fonctionne

1. **Fichier `config.js` dans `public/`** : Chaque frontend a un fichier `public/config.js` qui définit `window.RUNTIME_CONFIG` avec des valeurs par défaut (localhost).

2. **Chargement dans le HTML** : Le fichier est chargé via `<script src="/config.js"></script>` dans le head de Nuxt.

3. **Utilisation dans le code** : Les composants utilisent `window.RUNTIME_CONFIG.API_URL`, `window.RUNTIME_CONFIG.THREAD_URL`, etc.

4. **Injection par Terraform** : Après le déploiement, Terraform exécute `docker exec` pour remplacer le `config.js` dans les conteneurs avec les vraies IPs publiques.

---

## Contenu

- Pré-requis
- Workflow de développement local
- Build & push d'images Docker (local ou via GitHub Actions)
- Configuration Terraform et variables
- Déploiement (terraform apply)
- Vérifications et dépannage

---

## 1) Pré-requis

- macOS / Linux
- Git
- Docker (desktop)
- Terraform (v1.0+ recommandé)
- AWS CLI configuré (profil ou variables d'env) avec accès pour créer EC2, Security Groups, etc.
- Une paire de clés SSH (privée sur votre machine) et nommée dans `terraform/terraform.tfvars` (`key_pair_name`) et `~/.ssh/`.
- Un GitHub Personal Access Token (PAT) avec scope `write:packages`, `read:packages` (pour GHCR) et `repo` si le repo est privé.

---

## 2) Workflow local (dev)

Chaque service a son dossier :
- `api/` — Node API (Express / Fastify)
- `thread/` — Nuxt frontend pour lecture des messages
- `sender/` — Nuxt frontend pour poster des messages

Pour lancer en dev (par dossier) :

```bash
# API
docker-compose up -d # (si vous avez un docker-compose local pour l'API) ou
cd api && npm install && npm run dev

# Frontends
cd thread && npm install && npm run dev
cd sender && npm install && npm run dev
```

Les frontends lisent les URLs via `useRuntimeConfig().public` :
- `config.public.apiBase` → URL de l'API
- `config.public.senderUrl` → URL du sender
- `config.public.threadUrl` → URL du thread

En dev, ces valeurs ont des fallback vers `http://localhost:3000`, etc.

---

## 3) Build & push Docker images

Deux approches :
- Local : vous buildez et poussez manuellement
- CI : GitHub Actions build & push automatiquement (recommandé)

### A. Local (manuel)

1. Se connecter au GitHub Container Registry (GHCR) :

```bash
# Remplacez YOUR_GHCR_TOKEN par votre PAT
echo "YOUR_GHCR_TOKEN" | docker login ghcr.io -u <github-username> --password-stdin
```

2. Build les images (depuis la racine) :

```bash
docker build -t ghcr.io/woorzz/forum-anonyme-api:07bfc02 ./api
docker build -t ghcr.io/woorzz/forum-anonyme-thread:07bfc02 ./thread
docker build -t ghcr.io/woorzz/forum-anonyme-sender:07bfc02 ./sender
```

3. Pousser :

```bash
docker push ghcr.io/woorzz/forum-anonyme-api:07bfc02
docker push ghcr.io/woorzz/forum-anonyme-thread:07bfc02
docker push ghcr.io/woorzz/forum-anonyme-sender:07bfc02
```

> Remarque : si vous utilisez des noms d'images différents dans Terraform, retaggez (ex: `ghcr.io/woorzz/forum-anonyme-thread` vs `ghcr.io/woorzz/forum-anonyme-thread:07bfc02`).

### B. CI (GitHub Actions)

- Poussez votre commit sur `main` via GitHub Desktop ou `git push`.
- Allez dans `Actions` sur GitHub et vérifiez que le workflow build/push a bien réussi.
- Notez le tag utilisé par le workflow (habituellement le commit SHA court). Exemple : `07bfc02`.

---

## 4) Terraform — configuration

Fichiers importants : `terraform/variables.tf`, `terraform/terraform.tfvars`, `terraform/instances.tf`.

- `terraform/terraform.tfvars` doit contenir :
  - `aws_region`
  - `key_pair_name`
  - `db_password` (attention : sensible)
  - `github_token` (PAT utilisé par les instances pour `docker login` si vous utilisez `user_data` to pull images)
  - `image_tag` — le tag d'image que vous voulez déployer (ex: `07bfc02` ou `latest`).

Exemple `terraform/terraform.tfvars` :

```hcl
aws_region    = "eu-central-1"
key_pair_name = "marinelangrez-forum-keypair"
db_password   = "YourSecureDBPassword"
github_token  = "YOUR_GHCR_TOKEN"
image_tag     = "07bfc02"
```

Ne commitez jamais `terraform.tfvars` contenant des secrets dans un dépôt public.

---

## 5) Terraform — déployer

Initialiser et appliquer :

```bash
cd terraform
terraform init
terraform apply
# Répondez 'yes' si tout est ok
```

Ce que fait le module :
- Crée 4 instances EC2 : database, api, thread, sender
- Configure Docker via `user_data`, pull des images depuis GHCR et démarre des conteneurs
- **Injecte automatiquement** les IPs publiques dans `config.js` des conteneurs via `docker exec`
- Fournit des outputs : `api_url`, `thread_url`, `sender_url`, `ssh_commands`

**Important** : Les `null_resource` attendent ~2 minutes que les conteneurs soient prêts avant d'injecter les configs. C'est normal si l'apply prend du temps.

---

## 6) Vérifications

- Vérifier l'API :

```bash
curl -s http://<api_public_ip>:3000/messages
```

- Vérifier le sender (front) : ouvrez `http://<sender_public_ip>:8080` dans le navigateur
- Vérifier le thread : ouvrez `http://<thread_public_ip>` dans le navigateur

- Voir les logs Docker sur une instance :

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<instance_ip>
# puis
sudo docker ps -a
sudo docker logs <container_id>
```

---

## 7) Dépannage courant

1. `manifest unknown` / `denied` lors du `docker pull` :
   - Token GHCR invalide/expiré. Regénérer un PAT avec `read:packages write:packages`.
   - Assurez-vous que l'image avec le tag demandé existe sur GHCR.

2. `Network Error` dans le frontend :
   - Vérifier que `config.js` a bien été injecté : `ssh` sur l'instance et faire `sudo docker exec marinelangrez-thread cat /app/.output/public/config.js`
   - Si le fichier contient encore `localhost`, relancer `terraform apply` ou exécuter manuellement l'injection.
   - Tester l'API avec `curl` depuis votre machine.

3. Config.js pas injecté :
   - Les `null_resource` attendent que le conteneur soit prêt. Vérifiez les logs Terraform.
   - Si timeout SSH, vérifiez que votre clé privée est au bon endroit (`~/.ssh/marinelangrez-forum-keypair.pem`).
   - Vous pouvez réexécuter juste les null_resource : `terraform taint null_resource.inject_thread_config && terraform apply`

4. Dépendance cyclique dans Terraform :
   - ✅ **Résolu** : Nous n'utilisons plus de références croisées dans les `user_data`. Les `null_resource` s'exécutent après la création de toutes les instances.

---

## 8) Checklist finale (récapitulatif rapide)

- [ ] Mettre à jour les fichiers source et tester localement
- [ ] Commit & push sur GitHub
- [ ] Vérifier Actions CI -> images publiées sur GHCR
- [ ] Mettre à jour `terraform.tfvars` (image_tag, github_token, etc.)
- [ ] `terraform init && terraform apply` (les configs sont injectées automatiquement)
- [ ] Tester endpoints et UI

---

## 9) Architecture technique détaillée

### Injection runtime des configurations

**Problème** : Les builds Docker nécessitent des URLs statiques, mais les IPs AWS EC2 sont dynamiques.

**Solution** : Fichier `config.js` modifiable au runtime.

**Sender** (`sender/public/config.js`) :
```javascript
window.RUNTIME_CONFIG = {
  API_URL: 'http://localhost:3000',
  SENDER_URL: 'http://localhost:8080',
  THREAD_URL: 'http://localhost'
};
```

**Utilisation dans le code** :
```javascript
const getApiBase = () => {
  if (typeof window !== 'undefined' && window.RUNTIME_CONFIG) {
    return window.RUNTIME_CONFIG.API_URL
  }
  return 'http://localhost:3000'
}
```

**Injection Terraform** :
```hcl
resource "null_resource" "inject_sender_config" {
  provisioner "remote-exec" {
    inline = [
      "sudo docker exec marinelangrez-sender sh -c \"echo 'window.RUNTIME_CONFIG = { API_URL: \\\"http://${aws_instance.api.public_ip}:3000\\\", ... };' > /app/.output/public/config.js\""
    ]
  }
}
```

---