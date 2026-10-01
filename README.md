
# 🎪 SSH Auto Login
![ssha -s 2](https://github.com/o-GuGus/sshAutoLogin/blob/master/images/ssha%20-s%202.jpg)

>The 'ssha' tool is a handy tool to quickly connect to a remote server via SSH without having to enter your password each time. It stores your server credentials in a secure configuration file on your local computer and uses them to automatically connect to the remote server.

## ✨ Features
- Create a new server
- Delete a server
- See server list
- Connect to a server

## 🔭 Tech Stack
- Bash
- Support Mac and Linux

## 🏃‍♀️ How to use
1. Install the binary
``` bash
/bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/o-GuGus/sshAutoLogin/master/install.sh)"
```

2. Create a server
``` bash
ssha -c
```

3.  See your server list
``` bash
ssha -l
```

3. Connect to your selected server
``` bash
ssha -s 1
```

## 🐕‍🦺 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
