# Step 1

Prepare terraform.tfvars with below variables

```
access_key = iam access key
secret_key = iam secret key
```

```
mvn clean install
mvn clean package
```

IAM user should have complete lambda, iam , aws gateway acccess

# Step 2

```
terraform init
terraform plan
terraform apply
```