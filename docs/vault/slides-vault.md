name: Azure-Terraform-Vault-Workshop
class: center,middle,title-slide
count: false
![:scale 80%](images/tfaz.png)
.titletext[
Azure Vault Workshop]
Modern Security With Vault

???

Welcome to the beginner's guide to Vault on Azure. 


---

name: Introductions
Introductions
-------------------------

.contents[
* Your Name
* Job Title
* Automation Experience
* Favorite Text Editor
]

???
Use this slide to introduce yourself, give a little bit of your background story, then go around the room and have all your participants introduce themselves.

The favorite text editor question is a good ice breaker, but perhaps more importantly it gives you an immediate gauge of how technical your users are.  

**There are no wrong answers to this question. Unless you say Notepad. Friends don't let friends write code in Notepad.**

**If you don't have a favorite text editor, that's okay! We've brought prebuilt cloud workstations that have Visual Studio Code already preinstalled. VSC is a free programmer's text editor for Microsoft, and it has great Terraform support. Most of this workshop will be simply copying and pasting code, so if you're not a developer don't fret. Terraform is easy to learn and fun to work with.**

---
name: Table-of-Contents
class: center,middle
Table of Contents
=========================

.contents[

0. Vault Overview
1. Our Vault Server
1. Interacting with Vault (CLI, browser, API)
1. Authorization in Vault: Policies
1. Authenticating to Vault: Auth Methods
1. Secret Management: Secret Engines
1. Example Engine One: Protecting Databases
1. Example Engine Two: Encryption as a Service
1. Vault Enterprise -- Extending Vault across the organization
]

---

name: Vault-Overview
Vault Overview
-------------------------


###Vault is a __BIG__ topic!  

This is meant as an overview.  For detailed descriptions or instructions please see the docs, API guide, or learning site:
* https://www.vaultproject.io/docs/
* https://www.vaultproject.io/api/
* https://learn.hashicorp.com/vault/


---

name: Securing-Apps
Application Security
-------------------------


### Traditional Model
Traditional security models were built upon the idea of perimeter based security.  There would be a firewall, and inside that firewall it was assumed one was safe.  Resources such as databases were mostly static.  As such rules were based upon IP address, credentials were baked into source code or kept in a static file on disk.

* IP Address based rules
* Hardcoded credentials with problems such as:
  * Shared service accounts for apps and users
  * Difficult to rotate, decommission, and determine who has access
  * Revoking compromised credentials could break 


---

name: Securing-Apps-Vault
How Vault Secures Applications
-------------------------


###Idenity Based Model
Vault was designed to address the security needs of modern applications.  It differs from the traditional approach by using:

* Identity based rules allowing security to strecth across network perimeters
* Dyanmic, short lived credentials that are rotated frequently
* Indivual accounts to maintain provenance (tie action back to entity)
* Easily invalidate credentials or entities

---


name: Chapter-1
class: center,middle
.section[
Chapter 1  
Our Vault Server
]

---

name: Our-Vault-Server
Connecting To Our Vault Server
-------------------------


During the Terraform Workshop we deployed a Vault server.  Let's connect to it now.  First, let us retrieve the address from Terraform by inspecting the output:
```powershell
PS C:\...> terraform output Vault_Server_url
http://ehron.centralus.cloudapp.azure.com:8200
```

Use a web browser to connect to the address that is returned.

---

name: Our-Vault-Server-2
Connecting To Our Vault Server (Continued)
-------------------------

We deployed a pre-configured Vault server.  That means we have already:
* Initialized the server (vault init)
  * This creates the master key used to encrypt storage
* Unsealed it
  * Vault protects the master key using a process called "unsealing"
  * One can unseal using Shamir's Secret Sharing, or auto unseal mechanisms
  * For production we strongly recommend integrating Vault with an HSM or cloud key management service like Azure Key Vault
* Retrieved the initial root token
  * When a Vault server first starts it prints the root token
  * The root token is a super user in Vault
  * In production it should be used for initial config and then destroyed
  * A root token can be regenerated at a later date if needed



---


name: Chapter-2
class: center,middle
.section[
Chapter 2
Interacting with Vault
]

---

Log in using the token "root":
IMG_PLACEHOLDER

Once logged in feel free to click around.  Nothing other than the default settings are currently present.

---

name: Our-Vault-Server-3
Connecting To Our Vault Server (Continued)
-------------------------

We can also access our Vault server from the command line.  Vault is preinstalled on your lab machine.  First, we need to tell the Vault client where the Vault server is:
```powershell
PS C:\...> $Env:VAULT_ADDR="http://<YOUR_NAME>.<REGION>.cloudapp.azure.com:8200"
PS C:\...> vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.0.1
Cluster Name    vault-cluster-4a47af87
Cluster ID      532155d5-892d-5320-80ee-297ee94bd114
HA Enabled      false
```
---

name: Our-Vault-Server-4
Authenticating To Our Vault Server
-------------------------

Let us log in.   We need to authenticate on the command line just as we did in the web UI:
```powershell
PS C:\...> vault login
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       7iLORuL3pxfPFj5hbetn1Yhs
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

---

name: Our-Vault-Server-5
API Call To Our Vault Server
-------------------------

Finally, we can make API calls to the Vault server.  One could use something like curl or Invoke-WebRequest.  We will use Postman.  Open the Postman app and create a new request:

.center[![:scale 50%](images/postman_api.png)]

---



