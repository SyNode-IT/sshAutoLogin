# sshAutoLogin

**It can make your ssh login simply as well as efficiently on Mac or LInux.**

On a Mac or Linux system, we frequently use a remote ssh login server per terminal.
This often ends up in a headache from typing repetitive command lines.
Damn ~ this is a waste of time!
I improved the shell proposed by alicefeng which saves a lot of time...

___

ssha Tool Characteristics
- Scalability configuration
- Automatic interaction login
- Support password and SecretKeyFile method
- Support Mac and Linux
- Saving time

___

- **Easy to use**

> help info
~~~shell
➜  ~ ssha -h
USAGE:
ssha [-h] [-l] [-c] [-d] [-s <server alias>]
~~~

> see server list
~~~shell
➜  ~ ssha -l
Index	Description		Port	Host		Username	Password|SecretKeyFile
┌────────────────────────────────────────────────────────────────────────┐
│0       alicfengPC              127.0.0.1       22      alic    pwdalic │
└────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────┐
│1       us.samego.com           47.68.88.88     22      alic    u.know.pwd      │
└────────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────┐
│2       hk.samego.com           120.88.88.86    22      alic    u.know.pwd      │
└────────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│3       vpn.samego.com          68.120.80.86    22      alic    /home/alic/.ssha/key/vpn.samego.com.key │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
~~~

> create a new server
~~~shell
➜  ~ ssha -c
Description		
Port	
Host		
Username	
Password|SecretKeyFile
~~~

> delete a server
~~~shell
➜  ~ ssha -d
Which server do you want to delete ?
~~~

> login sameone server
~~~
➜  ~ ssha -s 0
┌────────────────────────────────────────┐
│alic logging into the alicfengPC  server│
└────────────────────────────────────────┘
spawn ssh -p 22 alic@127.0.0.1
alic@127.0.0.1's password: 
Welcome to elementary OS 0.4.1 Loki (GNU/Linux 4.13.0-32-generic x86_64)

Last login: Sat Aug 11 16:44:46 2018 from 127.0.0.1
➜  ~ 
successfully logined 【alicfengPC】
➜  ~ 
~~~

___

- **Simply to install**

> Universal (MacOS - Debian - Ubuntu - Mint - CentOS - Fedora - OpenSuse- RedHat)
~~~shell
/bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/Gui-Gos/sshAutoLogin/master/Universal.sh)"
~~~
___

- **Scalability configuration**
> example server info configure file
~~~ini
Index=0
Name=hostname
Host=IP | domain
Port=22
User=alic
PasswordOrKey=password
~~~

> default configure dir
~~~shell
~/.ssha/
~~~

> configure dir tree
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


