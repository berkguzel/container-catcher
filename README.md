# container-catcher
script for deleting containers by day, hours

# USAGE

1. `git clone https://github.com/berkguzel/container-catcher.git`
1. `sh ~/your path/catch-container.sh --status= --time `


```
sh catch-container.sh --status=exited --time=1d

sh catch-container.sh --status=running --time=3h
```

# WARNING

Script is taking the time with `docker inspect` command therefore be sure your date is matching with containers date.