# Source: https://github.com/tr0njavolta/crossplane-tutorial/blob/main/gists/02-compositions.sh

###############################################
# Crossplane Compositions | Tutorial (Part 3) #
###############################################

# Additional Info:
# - Crossplane: https://crossplane.io

#################
# Chapter Setup #
#################

cd crossplane-tutorial

nix-shell --run $SHELL

chmod +x setup/02-compositions.sh

./setup/02-compositions.sh

source .env

##################################
# Composite Resource Definitions #
##################################

cat compositions/sql-v1/definition.yaml

kubectl apply --filename compositions/sql-v1/definition.yaml

kubectl get compositeresourcedefinitions

kubectl get xrds

kubectl get crds | grep sql

kubectl explain sqls.devopstoolkitseries.com --recursive

cat examples/sql-v1.yaml

kubectl apply --filename examples/sql-v1.yaml

kubectl get sqls

kubectl get managed

kubectl get compositions

#########################
# Defining Compositions #
#########################

cat compositions/sql-v1/$HYPERSCALER.yaml

ls -1 compositions/sql-v1

kubectl apply --filename compositions/sql-v1

cat providers/sql-v1.yaml

kubectl apply --filename providers/sql-v1.yaml

kubectl get pkgrev

kubectl get pkgrev

cat providers/$HYPERSCALER-config.yaml

kubectl apply --filename providers/$HYPERSCALER-config.yaml

kubectl get compositions

cat examples/$HYPERSCALER-sql-v1.yaml

kubectl apply --filename examples/$HYPERSCALER-sql-v1.yaml

crossplane beta trace sql my-db

crossplane beta trace sql my-db

#####################################
# Resource References and Selectors #
#####################################

cat examples/$HYPERSCALER-vm.yaml

cat compositions/sql-v1/$HYPERSCALER.yaml

cat compositions/sql-v2/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v2

kubectl delete --filename examples/$HYPERSCALER-sql-v1.yaml

kubectl get managed

############
# Patching #
############

cat compositions/sql-v3/definition.yaml

kubectl apply --filename compositions/sql-v3/definition.yaml

cat compositions/sql-v3/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v3

cat examples/$HYPERSCALER-sql-v3.yaml

kubectl apply --filename examples/$HYPERSCALER-sql-v3.yaml

crossplane beta trace sql my-db

# Replace `[...]` with the full name of the one the Managed Resources.

export XR=[...]

kubectl get $XR --output yaml

###############################
# Managing Connection Secrets #
###############################

cat compositions/sql-v4/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v4

kubectl --namespace crossplane-system get secrets

kubectl --namespace crossplane-system get secrets

# Locate the secret with the name that starts with `my-db-` and has a timestamp suffix if you are using **Azure**, copy it, and use it as the value in the command that follows.
export DB=my-db

kubectl --namespace crossplane-system get secret $DB \
    --output yaml

#######################################
# Combining Providers in Compositions #
#######################################

export PGUSER=$(kubectl --namespace crossplane-system \
    get secret $DB --output jsonpath="{.data.username}" \
    | base64 -d)

export PGUSER=postgres

export PGPASSWORD=$(kubectl --namespace crossplane-system \
    get secret $DB --output jsonpath="{.data.password}" \
    | base64 -d)

export HOST_KEY=endpoint

export HOST_KEY=host

export HOST_KEY=publicIP

export PGHOST=$(kubectl --namespace crossplane-system \
    get secret $DB --output jsonpath="{.data.$HOST_KEY}" \
    | base64 -d)

kubectl run postgresql-client --rm -ti --restart='Never' \
    --image docker.io/bitnami/postgresql:16 \
    --env PGPASSWORD=$PGPASSWORD --env PGHOST=$PGHOST \
    --env PGUSER=$PGUSER --command -- sh

psql --host $PGHOST -U $PGUSER -d postgres -p 5432

\l

exit

exit

cat compositions/sql-v5/$HYPERSCALER.yaml

cat providers/sql-v5.yaml

kubectl apply --filename providers/sql-v5.yaml

kubectl get pkgrev

kubectl apply --filename compositions/sql-v5

kubectl run postgresql-client --rm -ti --restart='Never' \
    --image docker.io/bitnami/postgresql:16 \
    --env PGPASSWORD=$PGPASSWORD --env PGHOST=$PGHOST \
    --env PGUSER=$PGUSER --command -- sh

psql --host $PGHOST -U $PGUSER -d postgres -p 5432

\l

exit

exit

kubectl delete --filename examples/$HYPERSCALER-sql-v3.yaml

kubectl get managed

kubectl patch database.postgresql.sql.crossplane.io $DB \
    --patch '{"metadata":{"finalizers":[]}}' --type=merge

#############################
# Defining Composite Claims #
#############################

cat compositions/sql-v5/definition.yaml

cat compositions/sql-v6/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v6

cat examples/$HYPERSCALER-sql-v6.yaml

kubectl --namespace a-team apply \
    --filename examples/$HYPERSCALER-sql-v6.yaml

kubectl --namespace a-team get sqlclaims

crossplane beta trace sqlclaim my-db --namespace a-team

kubectl --namespace a-team get secrets

######################
# Destroy Everything #
######################

chmod +x destroy/02-compositions.sh

./destroy/02-compositions.sh

exit
