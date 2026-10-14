# Source: https://github.com/tr0njavolta/crossplane-tutorial/blob/main/gists/00-intro.sh

##################################################################################
# Getting Started with Crossplane: A Glimpse Into the Future | Tutorial (part 1) #
##################################################################################

# Additional Info:
# - Crossplane: https://crossplane.io

#################
# Chapter Setup #
#################

# Install Nix by following the instructions at https://nix.dev/install-nix

# Install Docker by following the instructions at https://docs.docker.com/engine/install

# Install GitHub CLI by following the instructions at https://github.com/cli/cli?tab=readme-ov-file#installation


cd crossplane-tutorial

gh repo set-default

nix-shell --run $SHELL

chmod +x setup/00-intro.sh

./setup/00-intro.sh

source .env

#############################
# A Glimpse Into the Future #
#############################

cat examples/$HYPERSCALER-intro.yaml

cp examples/$HYPERSCALER-intro.yaml a-team/intro.yaml

git add .

git commit -m "Intro"

git push

# Open http://argocd.127.0.0.1.nip.io in a browser.

crossplane resource trace clusters.devopstoolkit.ai cluster-01 \
    --namespace a-team

crossplane resource trace sqls.devopstoolkit.live silly-demo-db \
    --namespace a-team

crossplane resource trace apps.devopstoolkit.live silly-demo \
    --namespace a-team

crossplane resource trace sqls.devopstoolkit.live silly-demo-db \
    --namespace a-team

crossplane resource trace clusters.devopstoolkit.ai cluster-01 \
    --namespace a-team

crossplane resource trace apps.devopstoolkit.live silly-demo \
    --namespace a-team

export KUBECONFIG=$PWD/kubeconfig.yaml

# Execute only if using Google Cloud

gcloud container clusters get-credentials cluster-01 \
    --region us-east1 --project $PROJECT_ID

# Execute only if using AWS

aws eks update-kubeconfig --region us-east-1 \
    --name cluster-01 --kubeconfig $KUBECONFIG

# Execute only if using Azure

az aks get-credentials --resource-group cluster-01 \
    --name cluster-01 --file $KUBECONFIG

kubectl get nodes

kubectl --namespace production get all,ingresses

######################
# Destroy Everything #
######################

unset KUBECONFIG

chmod +x destroy/00-intro.sh

./destroy/00-intro.sh

exit
