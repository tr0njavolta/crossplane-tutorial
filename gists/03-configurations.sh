# Source: https://github.com/tr0njavolta/crossplane-tutorial/blob/main/gists/03-configurations.sh

#########################################################
# Crossplane Configuration Packages | Tutorial (Part 4) #
#########################################################

#################
# Chapter Setup #
#################

cd crossplane-tutorial

nix-shell --run $SHELL

chmod +x setup/03-configurations.sh

./setup/03-configurations.sh

source .env

###################################
# Building Configuration Packages #
###################################

# Continue review

kubectl get compositions

kubectl get pkgrev

cd compositions/sql-v7

ls -1

cat crossplane.yaml

crossplane xpkg build

ls -1

# Open https://accounts.upbound.io in a browser and create an account if you do not have it already.

up repository create dot-sql

# Open https://marketplace.upbound.io in a browser, open the user in the top-right corner of the screen, and choose which account you'd like to manage.

# Replace `[...]` with the username

export UP_USER=[...]

crossplane xpkg login --username $UP_USER

crossplane xpkg push xpkg.upbound.io/$UP_USER/dot-sql:v0.0.7

rm dot-sql-*.xpkg

cd ../..

#####################################
# Installing Configuration Packages #
#####################################

cat providers/dot-sql-v7.yaml

yq --inplace \
    ".spec.package = \"xpkg.upbound.io/$UP_USER/dot-sql:v0.0.7\"" \
    providers/dot-sql-v7.yaml

kubectl apply --filename providers/dot-sql-v7.yaml

kubectl get pkgrev

kubectl get compositions

cat providers/$HYPERSCALER-config.yaml

kubectl apply --filename providers/$HYPERSCALER-config.yaml

kubectl apply \
    --filename providers/provider-kubernetes-incluster.yaml

kubectl --namespace a-team apply \
    --filename examples/$HYPERSCALER-sql-v6.yaml

crossplane beta trace sqlclaim my-db --namespace a-team

######################
# Destroy Everything #
######################

chmod +x destroy/03-configurations.sh

./destroy/03-configurations.sh

exit
