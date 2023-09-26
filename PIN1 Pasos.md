# PIN1 PASO A PASO

## 1- Instalar Linux desde ISO en VirtualBox (u otro sistema de virtuales on-premise o cloud)

* [ubuntu-23.04-live-server-amd64.iso](https://releases.ubuntu.com/lunar/ubuntu-23.04-live-server-amd64.iso)


## 2- apt update & apt upgrade
```
sudo su
apt update & apt upgrade
```


## 3- Instalar Docker:

Agregamos la GPG key oficial de Docker:
```
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
```

Agregamos el repositorio a las fuentes de Apt:
```
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
```

Instalamos Docker
```
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Testeamos Docker: 
```
sudo docker run hello-world
```

Instalamos java
```
apt install openjdk-17-jdk openjdk-17-jre
```


## 4- Lanzar contenedor de Jenkins custom

```
docker run -dit -p 8080:8080 --network=bridge -v /var/run/docker.sock:/var/run/docker.sock --name jenkins-curso docker.io/mguazzardo/pipe-seg
```

Corremos lo siguiente para saber la ip del contenedor y el gateway
```
docker inspect jenkins-curso
```


## 5- Credenciales Agente Jenkins en Docker

Ir a la consola donde tenemos docker.
Ejecutar lo siguiente:

```
sudo su
mkdir /home/jenkins
addgroup jenkins
useradd -d /home/jenkins -g jenkins jenkins
passwd jenkins
chown jenkins /home/jenkins
exit
```

### Agregamos nuestro usuario y el de jenkins al grupo de docker:
```
usermod -aG docker $USER
usermod -aG docker jenkins
```

Ejecutamos este comando y copiamos el id del contenedor:
```
docker ps -a
```
En mi caso es fa2ea7bdf845, o bien lo accedemos por el nombre el cual es en este caso "jenkins-curso"

Ahora nos conectamos a la consola del jenkins que corre en el docker engine:
```
docker exec -it fa2 bash
```
o bien
```
docker exec -it jenkins-curso bash
```

y ejecutamos estos comandos:
```
mkdir /home/jenkins
addgroup jenkins
useradd -d /home/jenkins -g jenkins jenkins
passwd jenkins
chown jenkins /home/jenkins
```

Y ahora generamos las keys (para conectar el agente docker al Jenkins):
```
su - jenkins
ssh-keygen -t ed25519
```

Enviamos la key al servidor de Docker Engine:
```
ssh-copy-id -i ~/.ssh/id_ed25519 jenkins@172.17.0.1
```

Leemos las keys para agregarlas luego a Jenkins:
```
cat /home/jenkins/.ssh/id_ed25519
cat /home/jenkins/.ssh/id_ed25519.pub
```

Testeamos la conexion (y además se agrega en "know hosts"):
```
ssh jenkins@172.17.0.1
exit
```

Vamos a Jenkins:
Ir a Administrar Jenkins -> Manage credentials -> click en "(global)", que está al medio de la pantalla.
Luego en "+ Add Credentials"
En "Kind" seleccionamos "SSH Username with private key"
En scope lo dejamos como está: "Global (Jenkins, nodes, items....)
En ID escribimos "jenkins_local"
En "Username" escribimos el usuario "jenkins"
En "Private Key" pegamos la key "PRIVADA" que obtuvimos anteriormente (la que creamos para conectar el agente docker al Jenkins)


## 6- Credenciales Git en Servidor de Docker

Si estábamos en la consola del contenedor de Jenkins, salimos con exit 2 veces, asi nos quedamos en la consola del servidor que corre Docker Engine.
Basicamente vamos a repetir los pasos de la key pero crearemos una RSA.

```
su - jenkins
cd /home/jenkins
ssh-keygen -t rsa
```

Enviamos la key al contenedor de Jenkins:
```
ssh-copy-id -i ~/.ssh/id_rsa jenkins@172.17.0.2
```

Leemos las keys para agregarlas luego a Jenkins (KEY PRIVADA) y a GitHub (KEY PUBLICA):
```
cat /home/jenkins/.ssh/id_rsa
cat /home/jenkins/.ssh/id_rsa.pub
```

Testeamos la conexion (y además se agrega en "know hosts", la de github fallará hasta que configuremos la key pública en github.com):
```
ssh jenkins@172.17.0.1
exit
ssh git@github.com
exit
```

Repetimos lo último, pero ahora que ya no estamos logueados como usuario de linux "jenkins", sino que estamos con nuestro usuario propio, así lo agrega a "know hosts":
```
ssh git@github.com
```

Repetimos estos paso en el contenedor de Jenkins (diferenciar las keys de cada caso):
```
docker exec -it jenkins-curso bash
su - jenkins
cd /home/jenkins
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa jenkins@172.17.0.2
cat /home/jenkins/.ssh/id_rsa
cat /home/jenkins/.ssh/id_rsa.pub
```

Testeamos la conexion (y además se agrega en "know hosts", la de github fallará hasta que configuremos la key pública en github.com):
```
ssh git@github.com
exit
```
Repetimos lo último, pero ahora que ya no estamos logueados como usuario de linux "jenkins", sino que estamos con nuestro usuario propio, así lo agrega a "know hosts":
```
ssh git@github.com
```

Vamos a Jenkins:
Ir a Administrar Jenkins -> Manage credentials -> click en "(global)", que está al medio de la pantalla.
Luego en "+ Add Credentials"
En "Kind" seleccionamos "SSH Username with private key"
En scope lo dejamos como está: "Global (Jenkins, nodes, items....)
En ID escribimos "github_agentdocker_pin1"
En "Description" ponemos "Github Agent Docker PIN1"
En "Username" escribimos el usuario "jenkins"
En "Private Key" pegamos la key RSA "PRIVADA" que obtuvimos anteriormente (la que creamos para en el servidor donde corre el Docker Engine)

Ahora repetimos estos pasos pero para las keys RSA del contenedor de Jenkins, hacemos click en "+ Add Credentials"
En "Kind" seleccionamos "SSH Username with private key"
En scope lo dejamos como está: "Global (Jenkins, nodes, items....)
En ID escribimos "github_jenkinscontainer_pin1".
En "Description" ponemos "Github Jenkins Container PIN1"
En "Username" escribimos el usuario "jenkins"
En "Private Key" pegamos la key RSA "PRIVADA" que obtuvimos anteriormente (la que creamos en el contenedor de Jenkins)

Ahora vamos al repositorio del PIN1 que le hicimos fork, en la solapa "Settings" (URL: [https://github.com/<user_github>/PIN1/settings/](https://github.com/<user_github>/PIN1/settings/)), luego a "Deploy keys".
Hacemos click en el boton "Add deploy key", y en "Title" ponemos "github_agentdocker_pin1" y en "Key" ponemos la key RSA "PUBLICA" (del servidor donde corre el Docker Engine), le damos click a "Add key".
Repetimos los pasos, hacemos click en el boton "Add deploy key", y en "Title" ponemos "github_jenkinscontainer_pin1" y en "Key" ponemos la key RSA "PUBLICA" (del contenedor de Jenkins), le damos click a "Add key".


## 7- Jenkins: Configurar Agente Jenkins al Docker Engine, conexion y credenciales con Github 

Ir a Administrar Jenkins -> Administrar Nodos -> Nuevo nodo
Ponerle nombre "Docker Engine Agent" y tildar la opción "Permanent Agent", darle click al botón "Create"
Ingresar nombre, descripción, en "Number of executors poner 5", en "Directorio raiz remoto" poner "/home/jenkins" , etiquetas (opcional) poner "docker".
En "Usar" seleccionar "Utilizar este nodo tanto como sea posible"
En "Modo de ejecución" seleccionar "Arrancar agentes remotos en máquinas Unix vía SSH"
En Nombre de máquina" poner la ip, en mi caso es 172.17.0.1 (que es la ip que se comunica con el docker engine, no va la ip de la interfaz de la virtual, por ejemplo en mi caso 192.168.20.25)
En Credentials seleccionar las creadas para tal fin, en mi caso "jenkins (en x64-VM02)" que son las del servidor donde corre el host de Jenkins.
En "Host Key Verification Strategy" seleccionar "Non verifying Verification Strategy".
En "Disponibilidad" seleccionar "Keep this agent online as much as possible".
Y darle click en "Guardar".

Tambien debemos modificar el nodo "principal", y le cambiamos dentro el "Número de ejecutores" a "0" (cero), para utilizar únicamente el agente del servidor del Docker Engine.


## 8- Jenkins: Crear el pipeline

Dentro del Jenkins, hacemos click en "+ Nuevo Tarea", ponemos nombre por ejemplo pin1, seleccionamos "Pipeline", y le damos click en "OK".
Ahora podemos poner una descripción. 
Tildamos la opción "Descartar build antiguos", y dentro de este emn "Strategy" queda seleccionado "Log Rotation", en "Cantidad de días para mantener los builds" ponemos "5", y en "Número máximo de ejecuciones para guardar" ponemos "5".
Tildamos "Do not allow concurrent builds" y dentro tildamos "Abort previous builds".

Vamos más abajo hasta "Pipeline", y en "Definition" seleccionamos "Pipeline script from SCM", dentro de esto, en "SCM" seleccionamos "Git", en "Repository URL" pegamos la direccion SSH de nuevo repo de PIN1 que le hicimos fork, esta direccion la obtenemos del boton verde "Clone", solapa SSH, ingresamos la direccion similar a esta: git@github.com:gsmx64/PIN1.git.
Seleccionamos en "Credentials" la de nombre "git" (cre cvreamos previamente).
Más abajo verificamos que en "Script Path" esté bien escrito "Jenkinsfile", que para este repo esta bien sin especificar el path, si el archivo Jenkinsfile está en otra carpeta debería agregarse la ruta completa dentro del repositorio hasta el mismo Jenkinsfile. Aquí tambien podríamos cambiar el Jenkinsfile por el Jenkinsfile.seg

En la consola del servidor del Docker Engine, cerramos la sesion de jenkins por si quedó abierta:
```
su -s jenkins
```

Y corremos el pipeline.


## 9- Luego de correr el pipeline y que nos tire error...
Hacer clone del repositorio del PIN1 al que le hicimos fork:

```
git clone https://github.com/gsmx64/PIN1.git
```

Abrimos con un editor de texto el archivo Jenkinsfile, en el mismo vemos que la línea 15 están demás esos comandos (y que no existe esa carpeta), los borramos.
Y cambiamos en las líneas 29 y 30 donde dice: "127.0.0.1", por la ip de nuestro Docker Engine en la interfaz que se ve con el contenedor de Jenkins, quedando en mi caso: 172.17.0.1

Ahora realizamos el commit al repositorio:
```
git add .
git commit -m "Fixed Jenkins file"
git push
```

---------------------

## VER para mejora
* PIN - agregar moka en job jenkins
* se puede hacer script automatizado
* se puede hacer documentado en video



