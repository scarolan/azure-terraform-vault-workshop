##############################################################################
# Outputs File
#
# Expose the outputs you want your users to see after a successful 
# `terraform apply` or `terraform output` command. You can add your own text 
# and include any data from the state file. Outputs are sorted alphabetically;
# use an underscore _ to move things to the bottom. In this example we're 
# providing instructions to the user on how to connect to their own custom 
# demo environment.

output "_Vault_Server_URL" {
  value = "http://${azurerm_public_ip.vault-pip.fqdn}:8200"
}

output "_MySQL_Server_FQDN" {
  value = "${azurerm_mysql_server.mysql.fqdn}"
}

output "Demo Instructions" {
  value = <<SHELLCOMMANDS

##############################################################################
# Azure Vault MySQL Database Demo Setup

# Step 1: Connect to your Azure Virtual Machine
# Linux and Mac users, open a terminal and run:
ssh ${var.admin_username}@${azurerm_public_ip.vault-pip.fqdn}

# Windows Users:
# Download PuTTY: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
# Open PuTTY and copy your hostname into the Host Name field. Use the admin
# username and password you configured to log in.

# Step 2: Run these commands on the remote VM:
vault login root
getPasswords
vault read database/creds/my-role
curl -H 'X-Vault-Token: root' -X GET 'http://127.0.0.1:8200/v1/database/creds/my-role' | jq .
getPasswords
vault lease revoke -prefix database/creds/my-role
getPasswords

# Optional: Fetch database credentials from your laptop using Powershell or Bash
# PowerShell
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Vault-Token","root")
Invoke-RestMethod 'http://${azurerm_public_ip.vault-pip.fqdn}:8200/v1/database/creds/my-role' -Headers $headers

# Bash
curl -H 'X-Vault-Token: root' -X GET 'http://${azurerm_public_ip.vault-pip.fqdn}:8200/v1/database/creds/my-role' 
SHELLCOMMANDS
}
