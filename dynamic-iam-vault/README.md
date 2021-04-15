# Dynamic IAM Vault

AWS secret engine in vault configured and vault admin generates new iam user and provides keys using vault 

# Steps

## Step 1 : Start Vault Server

```
vault server -dev -dev-root-token-id="education"
```

Go to localhost:8200 and login using token "education"

## Step 2
```
cd admin && terraform init && terraform apply
cd developer && terraform init && terraform apply
```