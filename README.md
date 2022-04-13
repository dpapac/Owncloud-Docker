# Owncloud-Docker
Internship at Owncloud learning Docker 

# Commands
```
docker build -t tocc:x.y -f buildocc .
docker run -it -p 8080:80 -p 6363:6379 -p 3333:3306 -p 543:443 tocc:x.y 
firefox http://127.0.0.1:8080
```

