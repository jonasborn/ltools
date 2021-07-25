# ltools

Nothing special, just a set of linux tools

# Tools
## l
Shortcut for **ls**
Usage:
``` bash
l
```
## deploy

Shortcut for scp using sshpass
Usage:
``` bash
deploy <SOURCE_PATH> <TARGET_SERVER> <TARGET_PATH> <USERNAME> <PASSWORD>
```

## webs
Create a temporary webserver under specified port serving the specified directory
Usage:
``` bash
webs <dir> <port> | webs <port>
```

## raf
Create a random file with specified size and name or size and hash as name
Usage:
``` bash
raf <SIZE>
```
Size example:
1M, 1MiB, 123KB, 5GB

## Installation
``` bash
curl -s "https://github.com/jonasborn/ltools/blob/master/ltools.sh?raw=true" | bash
```
