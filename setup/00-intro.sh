#!/usr/bin/env bash
set -e

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
	'Setup for the Introduction chapter'

gum confirm '
Are you ready to start?
Select "Yes" only if you did NOT follow the story from the start (if you jumped straight into this chapter).
Feel free to say "No" and inspect the script if you prefer setting up resources manually.
' || exit 0

echo "
## You will need following tools installed:
|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|Linux Shell     |Yes                  |Use WSL if you are running Windows                 |
|Docker          |Yes                  |'https://docs.docker.com/engine/install'           |
|kind CLI        |Yes                  |'https://kind.sigs.k8s.io/docs/user/quick-start/#installation'|
|kubectl CLI     |Yes                  |'https://kubernetes.io/docs/tasks/tools/#kubectl'  |
|crossplane CLI  |Yes                  |'https://docs.crossplane.io/latest/cli'            |
|yq CLI          |Yes                  |'https://github.com/mikefarah/yq#install'          |
|Google Cloud account with admin permissions|If using Google Cloud|'https://cloud.google.com'|
|Google Cloud CLI|If using Google Cloud|'https://cloud.google.com/sdk/docs/install'        |
|AWS account with admin permissions|If using AWS|'https://aws.amazon.com'                  |
|AWS CLI         |If using AWS         |'https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html'|
|Azure account with admin permissions|If using Azure|'https://azure.microsoft.com'         |
|az CLI          |If using Azure       |'https://learn.microsoft.com/cli/azure/install-azure-cli'|

If you are running this script from **Nix shell**, most of the requirements are already set with the exception of **Docker** and the **hyperscaler account**.
" | gum format

gum confirm "
Do you have those tools installed?
" || exit 0

rm -f .env

#########################
# Control Plane Cluster #
#########################

kind create cluster --config kind.yaml

kubectl apply \
    --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

##############
# Crossplane #
##############

helm upgrade --install crossplane crossplane \
    --repo https://charts.crossplane.io/stable \
    --namespace crossplane-system --create-namespace \
    --version 2.4.2 --wait

kubectl apply \
    --filename providers/provider-kubernetes-incluster.yaml

kubectl apply --filename providers/provider-helm-incluster.yaml

kubectl apply --filename providers/provider-families.yaml

kubectl apply --filename providers/dot-kubernetes.yaml

kubectl apply --filename providers/dot-sql.yaml

kubectl apply --filename providers/dot-app.yaml

gum spin --spinner dot \
    --title "Waiting for Crossplane providers..." -- sleep 60

kubectl wait --for=condition=healthy provider.pkg.crossplane.io \
    --all --timeout=1800s

kubectl wait --for=condition=healthy \
    configuration.pkg.crossplane.io,function.pkg.crossplane.io \
    --all --timeout=600s

echo "## Which Hyperscaler do you want to use?" | gum format

HYPERSCALER=$(gum choose "google" "aws" "azure")

echo "export HYPERSCALER=$HYPERSCALER" >> .env

if [[ "$HYPERSCALER" == "google" ]]; then

    gcloud auth login

    PROJECT_ID=dot-$(date +%Y%m%d%H%M%S)

    echo "export PROJECT_ID=$PROJECT_ID" >> .env

    gcloud projects create ${PROJECT_ID}

    echo "## Open https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID and link a billing account" \
        | gum format

    gum input --placeholder "Press the enter key to continue."

    echo "## Open https://console.cloud.google.com/marketplace/product/google/container.googleapis.com?project=$PROJECT_ID and *ENABLE* the API" \
        | gum format

    gum input --placeholder "Press the enter key to continue."

    echo "## Open https://console.cloud.google.com/apis/library/sqladmin.googleapis.com?project=$PROJECT_ID and *ENABLE* the API" \
        | gum format

    gum input --placeholder "Press the enter key to continue."

    export SA_NAME=devops-toolkit

    export SA="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

    gcloud iam service-accounts create $SA_NAME \
        --project $PROJECT_ID

    export ROLE=roles/admin

    gcloud projects add-iam-policy-binding \
        --role $ROLE $PROJECT_ID --member serviceAccount:$SA

    gcloud iam service-accounts keys create gcp-creds.json \
        --project $PROJECT_ID --iam-account $SA

    kubectl --namespace crossplane-system \
        create secret generic gcp-creds \
        --from-file creds=./gcp-creds.json

    echo "
apiVersion: gcp.m.upbound.io/v1beta1
kind: ClusterProviderConfig
metadata:
  name: default
spec:
  projectID: $PROJECT_ID
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: gcp-creds
      key: creds" | kubectl apply --filename -

elif [[ "$HYPERSCALER" == "aws" ]]; then

    AWS_ACCESS_KEY_ID=$(gum input --placeholder "AWS Access Key ID" --value "$AWS_ACCESS_KEY_ID")
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> .env
    
    AWS_SECRET_ACCESS_KEY=$(gum input --placeholder "AWS Secret Access Key" --value "$AWS_SECRET_ACCESS_KEY" --password)
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> .env

    AWS_ACCOUNT_ID=$(gum input --placeholder "AWS Account ID" --value "$AWS_ACCOUNT_ID")
    echo "export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID" >> .env

    # Only needed for temporary credentials (key IDs starting with ASIA)
    AWS_SESSION_TOKEN=$(gum input \
        --placeholder "AWS Session Token (leave empty for AKIA keys)" \
        --value "$AWS_SESSION_TOKEN" --password)
    echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> .env

    echo "[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
${AWS_SESSION_TOKEN:+aws_session_token = $AWS_SESSION_TOKEN}
" >aws-creds.conf

    kubectl --namespace crossplane-system \
        create secret generic aws-creds \
        --from-file creds=./aws-creds.conf

    kubectl apply --filename providers/aws-config.yaml

else

    AZURE_TENANT_ID=$(gum input --placeholder "Azure Tenant ID" --value "$AZURE_TENANT_ID")

    az login --tenant $AZURE_TENANT_ID

    export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    az ad sp create-for-rbac --sdk-auth --role Owner --scopes /subscriptions/$SUBSCRIPTION_ID | tee azure-creds.json

    kubectl --namespace crossplane-system create secret generic azure-creds --from-file creds=./azure-creds.json

    kubectl apply --filename providers/azure-config.yaml

    DB_NAME=silly-demo-db-$(date +%Y%m%d%H%M%S)

    # Azure server names are global, so give the DB a unique name
    export DB_NAME
    yq --inplace '
      (select(.kind == "SQL") | .metadata.name) = env(DB_NAME) |
      (select(.kind == "Secret") | .metadata.name) = env(DB_NAME) + "-password" |
      (select(.kind == "Object") | .spec.references[0].patchesFrom.name) = env(DB_NAME)
    ' examples/azure-intro.yaml

fi

kubectl create namespace a-team

###########
# Argo CD #
###########

REPO_URL=$(git config --get remote.origin.url)
# workaround to avoid setting up SSH key in ArgoCD
REPO_URL=$(echo $REPO_URL | sed 's/git@github.com:/https:\/\/github.com\//') # replace git@github.com: to https://github.com/

yq --inplace ".spec.source.repoURL = \"$REPO_URL\"" argocd/apps.yaml

helm upgrade --install argocd argo-cd \
    --repo https://argoproj.github.io/argo-helm \
    --namespace argocd --create-namespace \
    --values argocd/helm-values.yaml --wait

kubectl apply --filename argocd/apps.yaml
