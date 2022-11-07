# sshAutoLogin

**It can make your ssh login simply as well as efficiently on Mac or Linux.**
On a Mac or Linux system, we frequently use a remote ssh login server per terminal.
This often ends up in a headache from typing repetitive command lines.
Damn ~ this is a waste of time!
I improved the shell proposed by alicefeng which saves a lot of time...

___

> **ssha Tool Characteristics**
- Scalability configuration
- Automatic interaction login
- Support password and SecretKeyFile method
- Support Mac and Linux
- Saving time

___

> **Simply to install**
- Universal (MacOS - Debian - Ubuntu - Mint - CentOS - Fedora - OpenSuse- RedHat)
~~~shell
/bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/Gui-Gos/sshAutoLogin/master/Install.sh)"
~~~

___

> **Help info**
- SYSTEM:~ user$ ssha -h
~~~shell
USAGE:
ssha [-h] [-l] [-c] [-d] [-s <server number>]
~~~

> **Create a new server**
- SYSTEM:~ user$ ssha -c
~~~shell
Creating a new server:
Please type the 'Description' of this server:
kali
Please type the 'Hostname|IP' of this server:
172.160.1.99
Please type the 'Port' of this server:
22
Please type the 'Username' of this server:
user
Please type the 'Password|SecretKeyFile' of this server:
passwordofhell

Please check the following informations:
Name of server: kali 
Hostname or IP: 172.160.1.99 
Port: 22 
Username: user 
Password/Key (hidden):  

Informations is correct ?! (Y/N)
y

Congratulations the server 'kali' is well registered.
~~~

> **Delete a server**
- SYSTEM:~ user$ ssha -d
~~~shell
Index	Description	Host	Port	Username	Password|SecretKeyFile
┌────────────────────────────────────────────────────────────────┐
│0       localhost       127.0.0.1       22      root    password│
└────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────┐
│3       kali    172.160.1.99    22      user    cGFzc3dvcmRvZmhlbGw=│
└────────────────────────────────────────────────────────────────────┘

Which server do you want to delete ? (Enter the number)
3

You have selected the server 3. Do you really want to delete this server ? (Y/N)
y

'OK' Server number 3 is deleted
~~~

> **See server list**
- SYSTEM:~ user$ ssha -l
~~~shell
Index	Description		Host			Port	Username    Password|SecretKeyFile
┌────────────────────────────────────────────────────────────────────────────────┐
│0       localhost     127.0.0.1      	22      root        password             │
└────────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────┐
│1       debian  		192.168.1.50   	22      toto        cGFzc3dvcmQ=         │
└────────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────┐
│2       kali  			172.160.1.99   	22      tutu        cGFzc3dvcmRvZmhlbGw= │
└────────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│3       vpn.samego.com          68.120.80.86    22      alic    /home/alic/.ssha/key/vpn.samego.com.key │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
~~~

> **Connect to a server**
- SYSTEM:~ user$ ssha -s 2
~~~shell
┌────────────────────────────────────────┐
│user logging into the kali server       │
└────────────────────────────────────────┘
spawn ssh -p 22 user@172.160.1.99
user@172.160.1.99's password: 
Linux Kali 5.10.0-19-amd64 #1 SMP Debian 5.10.149-2 (2022-10-21) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri Nov  4 12:56:45 2022 from 172.160.1.10

successfully logined 【kali】
user@kali:~$ exit
déconnexion
Connection to 172.160.1.99 closed.
┌──────────────────────────────────────┐
│user logged out the kali server       │
└──────────────────────────────────────┘
~~~

___

> **Scalability configuration**
- example of a server configuration file
~~~ini
Index=0
Name=hostname
Host=IP | domain
Port=22
User=alic
PasswordOrKey=password
~~~

- default configure dir
~~~shell
~/.ssha/
~~~

- configure dir tree
~~~shell
➜  .ssha tree
.
├── 0_localhost.ini
├── 1_47.68.88.88.conf
├── 2_120.88.68.86.ini
└── 3_68.120.80.68.conf

0 directories, 4 files
~~~

___

~~~shell                                                                                                                                                    
 ▄▄▄▄▄▄▄▄               ██                                                       ▄▄                            ▄▄▄▄▄▄▄▄                      ▄▄▄▄     
 ██▀▀▀▀▀▀               ▀▀                                                       ██                            ▀▀▀██▀▀▀                      ▀▀██     
 ██        ██▄████▄   ████      ▄████▄   ▀██  ███            ▄▄█████▄  ▄▄█████▄  ██▄████▄   ▄█████▄               ██      ▄████▄    ▄████▄     ██     
 ███████   ██▀   ██     ██     ██▀  ▀██   ██▄ ██             ██▄▄▄▄ ▀  ██▄▄▄▄ ▀  ██▀   ██   ▀ ▄▄▄██               ██     ██▀  ▀██  ██▀  ▀██    ██     
 ██        ██    ██     ██     ██    ██    ████▀              ▀▀▀▀██▄   ▀▀▀▀██▄  ██    ██  ▄██▀▀▀██               ██     ██    ██  ██    ██    ██     
 ██▄▄▄▄▄▄  ██    ██     ██     ▀██▄▄██▀     ███              █▄▄▄▄▄██  █▄▄▄▄▄██  ██    ██  ██▄▄▄███               ██     ▀██▄▄██▀  ▀██▄▄██▀    ██▄▄▄  
 ▀▀▀▀▀▀▀▀  ▀▀    ▀▀     ██       ▀▀▀▀       ██                ▀▀▀▀▀▀    ▀▀▀▀▀▀   ▀▀    ▀▀   ▀▀▀▀ ▀▀               ▀▀       ▀▀▀▀      ▀▀▀▀       ▀▀▀▀  
                     ████▀                ███                                                                                                         
~~~
