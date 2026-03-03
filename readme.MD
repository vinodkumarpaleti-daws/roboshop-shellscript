## This Repo contains roboshop project built by shell script.

**You have to follow the order while use the command to create the instances using shell scripting**
```agsl
sh roboshop.sh mongodb catalogue redis user cart mysql shipping rabbitmq payment frontend
```
**After installing the application in the server below commands helps to check the application or installation status**
```agsl
netstat -lntp // check the port status
```
```agsl
curl http://localhost:8080/health   //check the application health
```