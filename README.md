# Step 1

Prepare filte terraform.tfvars with below variables

```
ssh_user = ssh user
key_name = key name generated in ec2 secrets
private_key_path = path to pem file generated in ec2 secrets
access_key = iam access key
secret_key = iam secret key
```

```
chmod 400 <key_name>.pem
```

IAM user should have complete ec2 acccess

# Step 2

```
terraform init
terraform plan
terraform apply
```

# Step 3
```
ansible-playbook  -i <public ip of ec2>, --private-key <key_name>.pem nginx.yaml
```


