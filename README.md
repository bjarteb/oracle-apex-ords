# oracle-apex-ords

## Download software from otn.oracle.com (you need a login account)

https://www.oracle.com/database/technologies/appdev/apex.html

```bash
mkdir downloads
```

## Set environment

```bash
DATABASE_VERSION=18.4.0
APEX_VERSION=18.2
ORDS_VERSION=18.4.0.354.1002
ORDS_PORT=8080
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
unzip ~/docker/oracle-apex-ords/downloads/apex_${APEX_VERSION}.zip -d ~/docker/oracle-apex-ords/apex/${APEX_VERSION} &
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

## Build Apache Tomcat image

### build the ords container with the recipe from Martin D Souza
```bash
cd ords
git clone https://github.com/martindsouza/docker-ords.git .
```
### copy in the ords.war file
```bash
unzip ../downloads/ords-${ORDS_VERSION}.zip -d ./docker-ords/ords.war
cd docker-ords
```
### now build!
```bash
docker build -t ords:${ORDS_VERSION} .
```

### do we have our images ready?
```bash
docker image ls | grep -E 'oracle|ords'
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

### OnOff. Generate ORDS configuration
```bash
docker-compose up create-ords-config
# Ctrl+C after the log says "Started"
```
### start application (Tomcat configured with ORDS)
```bash
docker-compose up -d app
```

## VIOLA! Point your browser to: http://localhost:8080/ords
## Workspace: INTERNAL, Username: ADMIN, Password: Welcome1

```bash
open http://localhost:8080/ords
```

## Cleanup

```bash
docker-compose down -v
rm -rf ./oradata/*
rm -rf ./ords/ords-${ORDS_VERSION}
```
