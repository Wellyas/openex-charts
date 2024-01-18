# OpenEx Helm Chart

This is an unofficial Helm Chart for [OpenEx](https://openex.io). OpenEx is an open source platform allowing organizations to plan, schedule and conduct crisis exercises as well as adversary simulation campaign. OpenEx is an ISO 22398 compliant product and has been designed as a modern web application including a RESTFul API and an UX oriented frontend.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installation

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add wellyasopenex https://openex.github.io/openex-charts
```

then prepare your own `overrides.yaml` file and then install the chart with the following command:

```bash
helm install openex \
--namespace ${namespace} \
--create-namespace \
-f overrides.yaml \
wellyasopenex/openex
```

Be sure to replace `${namespace}` with your own namespace.

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


