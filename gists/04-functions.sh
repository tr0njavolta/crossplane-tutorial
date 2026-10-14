# Source: https://github.com/tr0njavolta/crossplane-tutorial/blob/main/gists/04-functions.sh

########################################################
# Crossplane Composition Functions | Tutorial (Part 5) #
########################################################

# Additional Info:
# - Crossplane: https://crossplane.io
# - Kubernetes? Database Schema? Schema Management with Atlas Operator: https://youtu.be/1iZoEFzlvhM

###################
# What's Missing? #
###################

crossplane beta trace sqlclaim my-db --namespace a-team

################################
# Patch and Transform Function #
################################

# Open https://marketplace.upbound.io in a browser.

cat providers/function-patch-and-transform.yaml

kubectl apply \
    --filename providers/function-patch-and-transform.yaml

cat compositions/sql-v8/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v8/$HYPERSCALER.yaml

crossplane beta trace sqlclaim my-db --namespace a-team

##########################
# Go Templating Function #
##########################

kubectl get databases.postgresql.sql.crossplane.io

cat compositions/sql-v8/definition.yaml

kubectl apply --filename compositions/sql-v8/definition.yaml

cat providers/function-go-templating.yaml

kubectl apply --filename providers/function-go-templating.yaml

cat compositions/sql-v9/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v9/$HYPERSCALER.yaml

kubectl get databases.postgresql.sql.crossplane.io

cat examples/$HYPERSCALER-sql-v9.yaml

kubectl --namespace a-team apply \
    --filename examples/$HYPERSCALER-sql-v9.yaml

kubectl get databases.postgresql.sql.crossplane.io

kubectl --namespace a-team get secrets

# If you chose Azure, replace `my-db` with the server name (the same as the name of the Secret).

export DB_NAME=my-db

export PGUSER=$(kubectl --namespace a-team \
    get secret $DB_NAME --output jsonpath="{.data.username}" \
    | base64 -d)

export PGPASSWORD=$(kubectl --namespace a-team \
    get secret $DB_NAME --output jsonpath="{.data.password}" \
    | base64 -d)

export PGHOST=$(kubectl --namespace a-team \
    get secret $DB_NAME --output jsonpath="{.data.endpoint}" \
    | base64 -d)

kubectl run postgresql-client --rm -ti --restart='Never' \
    --image docker.io/bitnami/postgresql:16 \
    --env PGPASSWORD=$PGPASSWORD --env PGHOST=$PGHOST \
    --env PGUSER=$PGUSER --command -- sh

psql --host $PGHOST -U $PGUSER -d postgres -p 5432

\l

exit

exit

crossplane beta trace sqlclaim my-db --namespace a-team

cat compositions/sql-v10/definition.yaml

kubectl apply --filename compositions/sql-v10/definition.yaml

cat compositions/sql-v10/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v10/$HYPERSCALER.yaml

kubectl --namespace a-team get atlasschemas

cat examples/$HYPERSCALER-sql-v10.yaml

kubectl --namespace a-team apply \
    --filename examples/$HYPERSCALER-sql-v10.yaml

kubectl --namespace a-team get atlasschemas

kubectl run postgresql-client --rm -ti --restart='Never' \
    --image docker.io/bitnami/postgresql:16 \
    --env PGPASSWORD=$PGPASSWORD --env PGHOST=$PGHOST \
    --env PGUSER=$PGUSER --command -- sh

psql --host $PGHOST -U $PGUSER -d postgres -p 5432

\c db-01

\dt

\d videos

exit

exit

#######################
# Auto-Ready Function #
#######################

crossplane beta trace sqlclaim my-db --namespace a-team

cat providers/function-auto-ready.yaml

kubectl apply --filename providers/function-auto-ready.yaml

cat compositions/sql-v11/$HYPERSCALER.yaml

kubectl apply --filename compositions/sql-v11/$HYPERSCALER.yaml

crossplane beta trace sqlclaim my-db --namespace a-team

##############################################
# Building and Pushing Configuration Package #
##############################################

cat compositions/sql-v11/crossplane.yaml

cd compositions/sql-v11

crossplane xpkg build

# Replace `[...]` with the username

export UP_USER=[...]

crossplane xpkg login --username $UP_USER

crossplane xpkg push xpkg.upbound.io/$UP_USER/dot-sql:v0.0.11

rm dot-sql-*.xpkg

cd ../../

######################
# Destroy Everything #
######################

chmod +x destroy/04-functions.sh

./destroy/04-functions.sh

exit

####
#  #
####

# Spell check

# Diagram

#################
# Chapter Setup #
#################

cd crossplane-tutorial

nix-shell --run $SHELL

chmod +x setup/04-functions.sh

./setup/04-functions.sh

source .env
