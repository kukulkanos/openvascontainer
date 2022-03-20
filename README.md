# openvascontainer
Openvas Dockerfile
Loaded in 20220320 but created a looong ago, perhaps is buggy right now.
Also you have to provide the downloadables because the purpose of this Dockerfile is to use your own version of the container, totally trustable.

Or if you don't want to waste time you can try:

docker run --name=openvas -d -ti -p 9443:9443 m4ch1n3s/openvas20
Wait for 10 minutes or 15 to get up to date, and then change the password
docker exec -ti openvas gvmd --user=admin --new-password=new_password

and go trow https://ip:9443
