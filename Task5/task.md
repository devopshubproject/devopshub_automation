PHASE 5
====================================================
Create an azure keyvault instance
Create a third repository and a third pipeline
the repo will have a file called certificates.txt which contains a list of items such as:
CN=prod.company.ch,OU=IT,O=Company AG,L=Zurich,ST=Zurich,C=CH
CN=test.company.ch,OU=IT,O=Company AG,L=Zurich,ST=Zurich,C=CH
The pipeline uses and it will generate the certificates with let's encrypt
The resulting 4 certificate files (prod.company.ch.crt | prod.company.ch.key |
test.company.ch.crt | test.company.ch.key) will be stored in the azure keyvault instance as
"secrets"