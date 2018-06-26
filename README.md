# Overview

This is a small demo app that uses Azure Key Vault to store database authentication keys and then shows how you might access those keys without hardcoding sensitive data. This demo
uses the following Azure resources:

* [Azure VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/)
* [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction)
* [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview)
* [Azure Managed Service Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-service-identity/overview)

The app itself is based on the [todo-app-java-on-azure](https://github.com/Microsoft/todo-app-java-on-azure) and is a very basic Java Spring app. 

The demo will show a few things:

* How to use Azure Managed Service Identity to allow the VM to authenticate against Azure
services without user credentials
* How to use Azure Managed Service Identity to retrive a secret from Azure Key Vault
* How to make that data available to a Java application running on the VM


## TOC

- [Overview](#overview)
  - [TOC](#toc)
  - [Requirements (will be installed via start.sh script)](#requirements-will-be-installed-via-startsh-script)
  - [Create VM](#create-vm)
  - [Create Key Vault](#create-key-vault)
  - [Create Azure Cosmos DB documentDB](#create-azure-cosmos-db-documentdb)
  - [Add Secret to Key Vault](#add-secret-to-key-vault)
  - [Configuration](#configuration)
  - [Run it](#run-it)

## Requirements (will be installed via start.sh script)

* [JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) 1.8 and above
* [Maven](https://maven.apache.org/) 3.0 and above

## Create VM

We will be using a VM with MSI enabled so that we can get details about our key vault without having to hardcode anything. 

1. Click the Create a resource button found on the upper left-hand corner of the Azure portal
2. Select Compute, and then select Ubuntu Server 16.04 LTS
3. Make sure to allow ports 22 and 8080, you will need that access later
4. When creating the VM make sure to enable Managed Service Identity, this is what will allow your VM to interact with Key Vault seamlessly


## Create Key Vault

1. At the top of the left navigation bar, select Create a resource > Security + Identity > Key Vault
2. Provide a Name for the new Key Vault
3. Locate the Key Vault in the same subscription and resource group as the VM you created earlier
4. Select Access policies and click Add new
5. In Configure from template, select Secret Management
6. Choose Select Principal, and in the search field enter the name of the VM you created earlier. Select the VM in the result list and click Select
7. Click OK to finishing adding the new access policy, and OK to finish access policy selection
8. Click Create to finish creating the Key Vault

## Create Azure Cosmos DB documentDB

1. Click Create a resource > Databases > Azure Cosmos DB
2. In the New account page, enter the settings for the new Azure Cosmos DB account The API should be `SQL` and to simplify things you'll probably want to create this in the same resource group and location as your VM
3. Once the Cosmos DB instance has been created, find it in the portal and select the `keys` tab. Take note of the `Primary Key` value as you will need that shortly

## Add Secret to Key Vault

1. Select All Resources, and find and select the Key Vault you created
2. Select Secrets, and click Add
3. Select Manual, from Upload options
4. Enter a name and value for the secret. You will need to know the name as it is used in the `start.sh` script. The value should be the Cosmos DB primary key from step #3 from [Create Azure Cosmos DB documentDB](#create-azure-cosmos-db-documentdb)
5. Leave the activation date and expiration date clear, and leave enabled as Yes
6. Click Create to create the secret



## Configuration

* You will need to update the `start.sh` script with your
  * Cosmos DB Endpoint (URL)
  * Key Vault Name and the name of your secret
  * Cosmos DB database name (does not have to exist)

* As part of the start.sh script, the system environment variables `DOCUMENTDB_URI`, `DOCUMENTDB_KEY` and `DOCUMENTDB_DBNAME` will be set.
  Then maven will substitute them during the build phase.
    ```
    azure.documentdb.uri=@env.DOCUMENTDB_URI@
    azure.documentdb.key=@env.DOCUMENTDB_KEY@
    azure.documentdb.database=@env.DOCUMENTDB_DBNAME@
    ``` 

## Run it

1. Run the project using `./start.sh`. This will update the VM, install the pre-reqs, build the app and then start it in the foreground
2. Open `http://YOUR_IP:8080` you can see the web pages to show the todo list app

