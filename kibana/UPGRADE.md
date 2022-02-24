# Upgrade Kibana
* [Official docs](https://www.elastic.co/guide/en/kibana/current/upgrade.html) - Please go through official docs first

As of now, the current latest version of kibana is `v7.7.1`. Below is the procedure for upgrade from `7.6.2`=>`7.7.1`.

1. Upgrade
```
$ sudo systemctl stop kibana
$ sudo apt-get install --upgrade-only kibana
$ sudo systemctl start kibana
```
NOTE: Kibana install will take some, especially while "Unpacking" package. So, please be patient

