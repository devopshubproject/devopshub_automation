PHASE 3
====================================================
Create a python script that exposes an endpoint http://localhost:8080/healthy     
Create a docker image with the previous python script and publish it on docker hub
Update the pipeline to start the VM with 2 docker containers (tutum and the new python
script)
the new endpoint /healthy must be accessible from outside the VM