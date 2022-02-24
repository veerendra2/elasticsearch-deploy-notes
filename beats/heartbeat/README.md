# Hearbeat
* Office [Docs](https://www.elastic.co/guide/en/beats/heartbeat/current/index.html)
## Install
* Download [Heartbeat](https://www.elastic.co/downloads/past-releases/heartbeat-7-6-2). As of now, the beats version is `7.6.2`

* Create directories for certificates
```
$ sudo mkdir /etc/ssl/beats
## Copy .pem files to beats directory which were generated while configuring elasticsearch
$ ls /etc/ssl/beats
elasticsearch-ca.pem  letsencryptauthorityx3.pem
```

* Verify config and copy to `/etc/heartbeat/`
  * [heartbeat](heartbeat.yml) config for internal
  * [hearbeat](./heartbeat.yml) config for heatbeat agent deploy externally
```
$ ls /etc/heartbeat
fields.yml  heartbeat.reference.yml  heartbeat.yml  monitors.d

### If require, test config

$ heartbeat test config                                                                                                                             :(
sudo heartbeat test config
Config OK
```

* Start the daemon
```
$ sudo systemctl enable heartbeat-elastic
$ sudo systemctl start heartbeat-elastic
```