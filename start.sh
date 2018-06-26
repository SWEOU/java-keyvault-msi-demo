#!/bin/bash


# pre-reqs
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install jq maven default-jdk -y

# get auth token
export KVTOKEN=`curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq -r .access_token`

# set envvars for app
export DOCUMENTDB_URI="YOUR_COSMOS_ENDPOINT"
export DOCUMENTDB_KEY=`curl -s https://YOUR_VAULT_NAME.vault.azure.net/secrets/YOUR_SECRET_NAME?api-version=2016-10-01 -H "Authorization: Bearer $KVTOKEN" | jq -r .value`
export DOCUMENTDB_DBNAME="YOUR_COSMOS_DBNAME"

# build app
mvn package

# start app
java -jar target/todo-app-java-on-azure-1.0-SNAPSHOT.jar
