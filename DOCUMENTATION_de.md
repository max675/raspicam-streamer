# Raspberry Pi Video Streaming

Author Information:

* (c) by max675, 2015
* https://github.com/max675/raspicam-streamer


# Überblick

**Verwendete Teile:** 

* Raspberry Pi Model B
* Raspberry Pi Camera
* Raspbian Image (https://www.raspbian.org/)
* Speicherkarte

**Ziel des Projektes:**

* Umbau des Raspberry Pi in eine Ethernet Streaming Kamera
* Streaming per RTP
* Stream abspielbar per VLC
* Latenzen reduzieren soweit möglich
* Automatischer Start des Streamings
* Statische IP-Adresse leicht einstellbar

**Woraus besteht dieses Projekt:**

Das Projekt besteht aus einer Reihe von Bash-Skripten, welche auf einem frisch installierten Raspbian-System einmalig ausgeführt werden. Diese konfigurieren das System automatisch für den Streaming-Betrieb. Im Laufe des Vorgangs werden weitere Debian-Packages und einige Spezialskripte auf dem System installiert.

**Was hat man am Ende installiert:**

* Benötigte Debian-Pakete (vim, vlc, daemon-tools, ...)
* Ein Skript `picam2.sh`, welches VLC mit den richtigen Parametern für das Streaming startet
* Ein daemon-tools Service für den Autostart von VLC
* bootconf-Skripte für die automatische Kopierung von Konfigurationsdateien von der Boot-Partition in die root-Partition (genau Beschreibung siehe eigener Abschnitt)

# Beschreibung des Inhaltes des Repository

| Datei / Ordner        | Beschreibung                                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------------------------------ |
| 00_pre-install.sh     | Führt die Vorkonfiguration des Systems durch (bevor die Installation durchgeführt wird)                      |
| 01_install.sh         | Installiert benötigte Skripte und Softwarepakete für Streaming und dessen Autostart                          |
| 02_inst_bootconf.sh   | Installiert und aktiviert die automatische Verarbeitung von Konfigurationsdateien auf /boot beim Systemstart |
| instfiles             | Ordner mit Skripten welche im System installiert werden                                                      |
| raspi-config-func.sh  | Hilfsfunktionen für RPI                                                                                      |

# Schritte Installation

Hinweise:

* DHCP /  Internetverbindung auf RPI unbedingt erforderlich.


Vorgehen:

1. Installation des Raspbian-Images auf der Speicherkarte
    * USB Kartenleser verwenden
    * Weitere Infos: https://www.raspberrypi.org/documentation/installation/installing-images/
    * Image auf Linux-Workstation mit `dd` auf die SD Karte schreiben
2. Bildschirm, Tastatur, LAN (mit DHCP Server) an Raspberry Pi anschließen und starten, dann einloggen (user=pi, pw=raspberry)
4. `ifconfig` ausführen und IP notieren
6. Git auf dem RPI installieren (`sudo apt-get install git`)
7. Dieses Repository auf den RPI clonen (`git clone url..bla`)
8. mit `cd` in den neuen Repository-Ordner wechseln
9. mit `chmod u+x` die Skript-Dateien `00_pre-install.sh`, `01_install.sh`, `02_inst_bootconf.sh` ausführbar machen
10. Pre-Install-Skript ausführen:  `sudo ./00_pre-install.sh`
    * Fragen zu deutschem Tastaurlayout beantworten
    * Fragen zu Ländereinstellungen (locales) beantworten 
11. Rebooten `sudo shutdown -r now`
12. Im Repo-Ordner das Install-Skript ausführen:  `sudo ./01_install.sh`
13. Rebooten `sudo shutdown -r now`
14. Optional für Bootconf-Funktion: Im Repo-Ordner das Bootconf-Skript ausführen:  `sudo ./02_inst_bootconf.sh`
15. Rebooten `sudo shutdown -r now`

Hinweise:

* Das Licht an der Kamera sollte nun leuchten.
* Die Kamera sollte nun erreichbar sein.
* Abschnitt "Hinweise Streaming-Client" beachten.

Weitere mögliche Schritte

* Man kann anschließend (vorher herunterfahren!) mit dem Speicherkartenleser an der Linux-Workstation ein Image von der Speicherkarte ziehen per `dd` und dieses auf weitere Speicherkarten schreiben. So lässt sich die Installation mit geringem Aufwand duplizieren.
* Wenn das Bootconf-Skript installiert wurde, kann man für jede Speicherkarte eine eigene statische IP vergeben, welche beim Systemstart angewendet wird. (Dazu siehe Bootconf-Abschnitt)

# Detail-Beschreibung der Installationsskripte

Was machen die einzelnen Skripte

## Skript 00_pre-install.sh 

* Tastaturlayout anpassen
* locales anpassen
* Timezone anpassen
* `sshd` aktivieren (braucht man für Fernwartung wenn die Kamera aufgehängt ist)
* Updates installieren
* `vim` installieren
* RPI Kamera aktivieren (Äquivalent zum Menüpunkt im raspi-config)

## Skript 01_install.sh

Verantwortlich für die Installation des Streaming-Dienstes.

* `vlc` installieren
* daemontools installieren (für Autostart)
* daemontools-Service für vlc anlegen
    * Service Konfig-Files gehen in Ordner `/etc/service/vlcd`
    * Installiert auch Datei `/etc/service/vlcd/picam2.sh` mit VLC-Parametern
    * Installiert neuen User vlcd unter dem vlc läuft
* UDEV Permissions für Kamera anpassen (damit normaler User Zugriff hat)
* Service starten

## Skript 02_inst_bootconf.sh

Verantwortlich für die optionale Installation des Bootconf-Skriptes/Systems.

* Abziehen der aktuellen `/etc/network/interfaces` in die `/boot` Partition
* Abziehen der aktuellen `/etc/service/vlcd/picam2.sh` in die `/boot` Partition
* Installieren des bootconf-Skriptes `copyconf` in `/etc/init.d/`
* Installieren des bootconf-Skriptes `managessh` in `/etc/init.d/`
* Aktivieren beider Skripte für die Ausführung beim Systemstart über `update-rc.d`

# Bootconf

Hier wird das eigens entwickelte, aber optionale Bootconf-System beschrieben. Man muss sich selber überlegen ob man das braucht. Es wird installiert über das Skript `02_inst_bootconf.sh`. Ggf. die Installation weglassen.

## Sinn von Bootconf

* Ermöglicht einfaches Ändern der Konfiguration auf der Speicherkarte, ohne dass man einen Ext3-Treiber auf dem Arbeitsrecher haben muss
* Man kann einfach die Speicherkarte in den Kartenleser einstecken, und die Konfig-Files bequem auf einer Fat32 Partion ändern, welche jeder PC öffnen kann, egal ob Windows oder Linux
* Die Konfigurationsdateien werden vor dem Systemstart von den Bootconf-Skripten automatisch von `/boot` in die ext3-Systempartition (in `/etc`) einkopiert, so dass die Änderungen angewendet werden
* **Bestehende Konfigurationsdateien** im System (in `/etc/')  **werden regelmäßig überschrieben**!



## Welche Konfig.Einstellungen kann man ändern?

Diese Dateien finden sich auf der Fat32 Boot Partition, wenn man die Speicherkarte mit dem Speicherkartenleser an einen PC anschließt. Die Dateien können mit einem Texteditor editiert werden.

| Datei       | Beim Start kopiert auf Zieldatei  | Einstellungen hier                                                                   |
| ----------- | --------------------------- | ------------------------------------------------------------------------------------ |
| interfaces  | /etc/network/interfaces     | statische IP-Adresse, Router, WLAN, DHCP (Standard-Linux-Format)                     |
| picam2.sh   | /etc/service/vlcd/picam2.sh | VLC Parameter, Port, RTSP, Auflösung, Video-Kamera-Mode                              |
| enable_ssh  | -                           | Ist die Datei existent, wird sshd aktiviert. Fehlt die Datei, wird sshd deaktiviert. |

## Hinweise zu Bootconf

Führt man Änderungen per ssh durch, anstatt wie vorgesehen über den Speicherkartenleser, ist zu beachten:

* Ist Bootconf installiert, dann werden per ssh durchgeführte Änderungen an den o.g. Ziel-Dateien logischerweise beim nächsten Systemstart plattgeschrieben!
* Möchte man dauerhafte Änderungen per ssh vornehmen, daran denken, die Dateien in `/boot` zu ändern und dann rebooten.

# Hinweise Streaming-Client

Kamera ist via RTSP Port 9000 erreichbar.

* Firewall auf RTSP-Client-Rechner abschalten! (Kameras in geschütztes LAN tun)
* Neueste VLC Version verwenden. (Mit einer alten Version ging es jedenfalls mal nicht.)
* Der Client-Rechner muss sehr leistungsstark sein, da die h264 Dekodierung rechenintensiv ist. (Der RPI macht Codierung in Hardware.)
* Per VLC-Parameter den Puffer auf dem Client-Rechner runterschrauben, da ansonsten das Video 30 Sekunden verzögert angezeigt wird.
* Die speziellen Einstellungen können in der VLC Playlist hinterlegt werden
* Die genauen vlc client commandline Parameter sind leider verloren gegangen, sonst würden die hier stehen.
