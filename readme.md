# OpenEx Helm Chart

[OpenEx](https://openex.io) is an open source platform allowing organizations to plan, schedule and conduct crisis exercises as well as adversary simulation campaign. OpenEx is an ISO 22398 compliant product and has been designed as a modern web application including a RESTFul API and an UX oriented frontend.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## deploy command

change some value in deploy/terraform/main.tf and deploy with

```bash
terraform -chdir=deploy/terraform/ apply -auto-approve
```

## AdminAccount
puis créer un compte admin temporaire:

Pour cela ajouter les variables dans le ConfigMaps ***openex-env-vars***

```
OPENEX_ADMIN_EMAIL: YourEmail@example.com
OPENEX_ADMIN_PASSWORD: YourSecretPassword
```

```bash
kubectl edit cm openex-env-vars
kubectl rollout restart deploy openex
```

pensez à [redeployer](#deploy-command) le terraform pour supprimer ces variables temp.


