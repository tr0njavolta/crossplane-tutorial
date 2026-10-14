# Source: https://github.com/tr0njavolta/crossplane-tutorial/blob/main/gists/01-managed-resources.sh

##################################################################
# Crossplane Providers and Managed Resources | Tutorial (Part 2) #
##################################################################

# Additional Info:
# - Crossplane: https://crossplane.io

#################
# Chapter Setup #
#################

cd crossplane-tutorial

nix-shell --run $SHELL

chmod +x setup/01-managed-resources.sh

./setup/01-managed-resources.sh

source .env

helm upgrade --install crossplane crossplane \
    --repo https://charts.crossplane.io/stable \
    --namespace crossplane-system --create-namespace --wait

########################
# Crossplane Providers #
########################

cat providers/$HYPERSCALER-vm.yaml

kubectl apply --filename providers/$HYPERSCALER-vm.yaml

kubectl get pkgrev

kubectl get pkgrev

kubectl get crds

# Execute the command that follows only if you are using **AWS**.

kubectl --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

# Execute the command that follows only if you are using **Google Cloud**.

kubectl --namespace crossplane-system \
    create secret generic gcp-creds \
    --from-file creds=./gcp-creds.json

# Execute the command that follows only if you are using **Azure**.

kubectl --namespace crossplane-system \
    create secret generic azure-creds \
    --from-file creds=./azure-creds.json

cat providers/$HYPERSCALER-config.yaml

kubectl apply --filename providers/$HYPERSCALER-config.yaml

############################
# Create Managed Resources #
############################

cat examples/$HYPERSCALER-vm.yaml

kubectl apply --filename examples/$HYPERSCALER-vm.yaml

kubectl get managed

kubectl get managed

############################
# Update Managed Resources #
############################

diff examples/$HYPERSCALER-vm.yaml \
    examples/$HYPERSCALER-vm-bigger.yaml

kubectl apply --filename examples/$HYPERSCALER-vm-bigger.yaml

############################
# Delete Managed Resources #
############################

kubectl delete --filename examples/$HYPERSCALER-vm-bigger.yaml

######################
# Destroy Everything #
######################

chmod +x destroy/01-managed-resources.sh

./destroy/01-managed-resources.sh

exit
