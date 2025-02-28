# Documentazione Dockerfile per Cross-Compilazione

---

## Usage
Place yourself in the folder containing the docker-compose.yml (this repository root directory).

Run:
```SRC_PATH=<mmr-kria-drive-path> docker compose run --rm mmr-cross-compile-container```

Set `mmr-kria-drive-path` to the relative or absolute path of the `mmr-kria-drive` source code.

Once inside the container, run `rosdep install --from-paths src --rosdistro humble --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"` to install additional dependencies.

È stato creato un Dockerfile (il quale crea un immagine docker) per lanciare un container di questa immagine per cross-compilare i nodi ROS2.

---

## Motivazione

Utilizziamo questo container perché quando compiliamo un nodo ROS2 dal nostro pc, per poi sostituilro all’ interno del file system della kria, questo nodo sarà compilato per l’architettura del pc utilizzato (es. x86), mentre vogliamo che il nodo sia compilato per arm64 (o aarch64).

## Dockerfile

```docker
FROM arm64v8/ubuntu:22.04
RUN apt update && apt install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN apt install -y software-properties-common
RUN add-apt-repository universe
RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update
RUN apt install -y python3-flake8-docstrings 
RUN apt install -y python3-pip 
RUN apt install -y python3-pytest-cov 
RUN DEBIAN_FRONTEND=noninteractive apt install -y ros-dev-tools
RUN apt install -y ros-humble-ament-cmake
RUN apt install -y ros-humble-rclcpp
RUN apt install -y ros-humble-geometry-msgs
RUN apt install -y ros-humble-std-msgs
RUN apt install -y ros-humble-can-msgs
RUN rosdep init
RUN rosdep update --rosdistro humble
COPY mmr-kria-drive/ /home
RUN rosdep install --from-paths /home/src --rosdistro humble --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"
RUN apt install ros-humble-sensor-msgs

```

Il Dockerfile contiene nella prima riga l’immagine di partenza, ovvero ubuntu 22.04 per arm64, e successivamente esegue (tramite “RUN”) tutti i comandi shell necessari all’installazione di ROS2, che possono essere trovati sulla documentazione ufficiale di ROS2 humble, con alcune differenze.

Punti importanti 

- **DEBIAN_FRONTEND=noninteractive**: quando si installa il pacchetto ros-dev-tools, viene richiesto di inserire la timezone. Questa variabile permette bypassare questo stallo
- **rosdep install && COPY**: Prima di lanciare rosdep install, il quale installerà tutte le dipendenze delle librerie utilizzate all’interno dei nostro nodi ros, bisogna dagli il workspace da cui appunto reperire queste dipendenze. La copy porta all’interno di immagine questo workspace, quindi bisogna mettere come primo argomento della copy la cartella nel quale sono contenuti i nodi ros di cui risolvere le dipendenze.
- **ros-humble-***: tutti i pacchetti ros-humble-* sono le librerie utilizzate all’interno dei nodi ros2, in particolare in “canbus_bridge” e “canopen_bridge” al momento della scrittura di questa documentazione. Se compilando questi nodi viene generato un errore riguardate un pacchetto mancante, prima provare a fare il source delle variabili di ambiente (source ./install/setupt.bash && source /opt/ros/humble/setup.bash), se l’errore persiste allora installa il pacchetto richiesto a mano.

> **Suggerimento**: esegui “apt search <nome del pacchetto>” e scarica quello che ha questa formattazione “ros-humble-<nome del pacchetto>”
>

## Manual Procedure
If u are not willing to use the compose-based proceudre, u can always opt for the manual procedure which involves build and interactive execution of the image.

### Creazione Immagine

```bash
docker build -t mmr-cross-compile <path> --platform=linux/arm64/v8
```

- **nome immagine**: è il nome che vogliamo dare all’immagine che creerà il container per la corss-compilazione
- **path** : è il path alla CARTELLA che contiene il Dockerfile

### Creazione Container

```bash
 docker run --platform=linux/arm64/v8 --rm -it --volume=<mmr-kria-drive-path>:/home/mmr-kria-drive <nome immagine> 

```

- **platform**: chiaramente specifica l’architettura di riferimento
- **volume**: bisogna inserire il percorso alla cartella contenente i nodi ros2 da compilare, poi dopo “:”, mettiamo la cartella di destinazione nel container sul quale verrà montato il volume

> **ATTENZIONE**: i cambiamenti che vengo effettuati sul container nella cartella /home saranno effettuati anche all’ interno del filesystem che lancia il container, quindi in questo caso nella cartella mmr-kria-drive
> 

 

## Prima di compilare

Prima di compilare il nodo ricordarsi di fare il source delle variabili di ambiente:

```bash
source ./install/setup.bash && source /opt/ros/humble/setup.bash
```
