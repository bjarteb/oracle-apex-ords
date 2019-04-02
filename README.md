# oracle-apex-ords

## Download software from otn.oracle.com (you need a login account)

https://www.oracle.com/database/technologies/appdev/apex.html
http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html

### Download list

- Oracle Database Express Edition 18c (XE)
- Oracle Application Express (APEX)
- Oracle REST Data Services (ORDS)
- Oracle Java JRE Server (ServerJRE)


```bash
mkdir downloads
```

## Set environment

```bash
DATABASE_VERSION=18.4.0
APEX_VERSION=19.1
ORDS_VERSION=18.4.0.354.1002
ORDS_PORT=8888
```

## Unpack software

```bash
# create folders for the three components (ORACLE DATABASE, APEX, ORDS)
mkdir apex oradata ords
# oracle user inside container needs to have access to this folder
chmod 777 oradata
```

## unpack APEX in the background (it takes a while)

```bash
mkdir ./apex/${APEX_VERSION} || true
unzip ./downloads/apex_${APEX_VERSION}.zip -d ./apex/${APEX_VERSION} &
```

## Build Oracle Database image

### oracle database. Let's build on Gerald Venzl work...
```bash
git clone https://github.com/oracle/docker-images.git
```
### copy in binary
```bash
cp ./downloads/oracle-database-xe-18c-1.0-1.x86_64.rpm \
   ./docker-images/OracleDatabase/SingleInstance/dockerfiles/${DATABASE_VERSION}
cd ./docker-images/OracleDatabase/SingleInstance/dockerfiles/
```
### build the image. This is going to take a while... (10 minutes)
```bash
./buildDockerImage.sh -v ${DATABASE_VERSION} -x
```

## Build serverjre image

Note! We will first have to build the `oracle/serverjre:8` image before we can build the ORDS image!

[Download Server JRE 8](http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html) `.tar.gz` file and drop it inside folder `java-8`.
```bash
cp ./downloads/server-jre-8u202-linux-x64.tar.gz ./OracleJava/java-8
```
# build the image
```bash
cd java-8
docker build -t oracle/serverjre:8 .
```
## Build the ORDS image (based on the oracle/serverjre:8 image)

```bash
cd OracleRestDataServices/dockerfiles
cp ./downloads/ords-${ORDS_VERSION}.zip . 
```
### build image (-i ignore checksum)
```bash
./buildDockerImage.sh -i
```

### do we have our images ready?
```bash
docker image ls | grep -E 'oracle\/database|oraclelinux|oracle\/restdataservices|oracle\/serverjre'

oracle/restdataservices                             18.4.0              49c6a8970304        About an hour ago   391MB
oracle/serverjre                                    8                   93bf34de0c2e        3 days ago          269MB
oracle/database                                     18.4.0-xe           40c73fce6868        2 weeks ago         8.57GB
oraclelinux                                         7-slim              c3d869388183        2 months ago        117MB
```

## Oracle Database

### create database. It will take a while...
```bash
docker-compose up database
# Ctrl+C to stop the database after "DATABASE IS READY TO USE"
```
### now start the database in detached mode
```bash
docker-compose up -d database
```
### make sure health is fine. if not, perform a restart: "docker-compose restart database"
```bash
docker-compose ps
```

### test login to the CDB from your host client
```bash
sqlplus system/oracle@localhost:1521/XE
```
### test login to the PDB from your host client
```bash
sqlplus system/oracle@localhost:1521/XEPDB1
```

## Install APEX in pluggable database XEPDB1

```bash
cd ./apex/${APEX_VERSION}/apex
sqlplus "sys/oracle@localhost:1521/XEPDB1 as sysdba" @./../../../install_apex.sql
cd ./../../../
```

## Configure ORDS

### create the configuration folder for given ORDS version
```bash
mkdir -p ./ords/ords-${ORDS_VERSION}/config
```

### start application
```bash
docker-compose up -d app
```

## VIOLA! Point your browser to: http://localhost:8888/ords
## Workspace: INTERNAL, Username: ADMIN, Password: Welcome1

```bash
open http://localhost:8888/ords
```

## Cleanup

```bash
docker-compose down -v
rm -rf ./oradata/*
rm -rf ./ords/ords-${ORDS_VERSION}
```
