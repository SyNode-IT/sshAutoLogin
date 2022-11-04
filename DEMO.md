- **HELP**

> SYSTEM:~ user$ ssha -h
~~~shell
USAGE:
ssha [-h] [-l] [-c] [-d] [-s <server number>]
~~~

___

- **CREATE**

> SYSTEM:~ user$ ssha -c
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

'OK' Added server kali to the list
~~~

___

- **DELETE**

> SYSTEM:~ user$ ssha -d
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

'OK' Delete server number 3
~~~

___

- **LIST**

> SYSTEM:~ user$ ssha -l
~~~shell
Index	Description		Host			Port	Username    Password|SecretKeyFile
┌────────────────────────────────────────────────────────────────────────────┐
│0       localhost     127.0.0.1      	22      root        password          │
└────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────┐
│1       debian  		192.168.1.50   	22      toto        cGFzc3dvcmQ=.     │
└────────────────────────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────────────────────────--┐
│2       kali  			172.160.1.99   	22      tutu        cGFzc3dvcmRvZmhlbGw=│
└────────────────────────────────────────────────────────────────────────────--┘
~~~

___

- **CONNECT**

> SYSTEM:~ user$ ssha -s 2
~~~shell
┌────────────────────────────────────────┐
│user logging into the kali server       │
└────────────────────────────────────────┘
spawn ssh -p 22 user@172.160.1.99
user@172.160.1.99's password: 
Linux surv 5.10.0-19-amd64 #1 SMP Debian 5.10.149-2 (2022-10-21) x86_64

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
