# azure-terraform-vault-workshop
This repo contains demonstration code for standing up a HashiCorp Vault training lab on Microsoft Azure. You can use it for a half-day Terraform workshop, a half-day Vault workshop or combined day-long workshop covering both. To set up and run either or both workshops, simply follow the instructions below.

### Setup instructions
1. Clone or download the code from here: https://github.com/scarolan/azure-terraform-vault-workshop
2. Open a terminal and cd into the vault-azure-mysql-demo directory
3. Copy the settings in `terraform.tfvars.example` into a `terraform.tfvars` file. Set the prefix variable to your name.
4. Run `terraform plan` and then `terraform apply`
5. Go get some coffee. It takes roughly 8-10 minutes to provision this environment on Azure.
6. When the setup is done, follow the steps listed in the Terraform output.