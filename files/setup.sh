#!/bin/sh
# Configures the Vault server for a database secrets demo

# cd /tmp
sudo apt-get -y update > /dev/null 2>&1
sudo apt install -y unzip mariadb-client jq > /dev/null 2>&1
# sudo apt install -y mariadb-client
# sudo apt install -y jq
wget https://releases.hashicorp.com/vault/0.10.1/vault_0.10.1_linux_amd64.zip
sudo unzip vault_0.10.1_linux_amd64.zip -d /usr/local/bin/

# Fire up the Vault!
# nohup vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200 &

# Set Vault up as a systemd service
echo "Installing systemd service for Vault..."
sudo bash -c "cat >/etc/systemd/system/vault.service" << 'EOF'
[Unit]
Description=Hashicorp Vault
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/local/bin/vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200
Restart=on-failure # or always, on-abort, etc

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start vault

# Configure our MySQL database
git clone https://github.com/datacharmer/test_db
cd test_db
mysql -umysqladmin@${MYSQL_HOST} -pEverything-is-bananas-010101 -h${MYSQL_HOST}.mysql.database.azure.com --ssl < employees.sql
mysql -umysqladmin@${MYSQL_HOST} -pEverything-is-bananas-010101 -h${MYSQL_HOST}.mysql.database.azure.com --ssl <<EOF
CREATE USER 'vaultadmin'@'%' IDENTIFIED BY 'vaultpw';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Configure the Vault database secrets backend
vault login root
vault audit enable file file_path=/${HOME}/vault.log
vault secrets enable database

vault write database/config/my-mysql-database \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(${MYSQL_HOST}.mysql.database.azure.com:3306)/" \
  allowed_roles="my-role" username="vaultadmin@${MYSQL_HOST}" password="vaultpw"

vault write database/roles/my-role \
  db_name=my-mysql-database \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" default_ttl="1h" max_ttl="24h"

# Create an alias for fetching MySQL passwords, set up some env vars.
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ${HOME}/.bashrc
echo "export MYSQL_HOST=${MYSQL_HOST}" >> ${HOME}/.bashrc
echo "alias getPasswords=\"mysql -umysqladmin@${MYSQL_HOST} -pEverything-is-bananas-010101 -h${MYSQL_HOST}.mysql.database.azure.com --ssl -e 'select user from mysql.user'\"" >> ${HOME}/.bashrc
echo "Your demo is now ready."