# Journalbeat
* Office [Docs](https://www.elastic.co/guide/en/beats/journalbeat/current/index.html)
> Lightweight shipper for journal logs
>
> NOTE: This beat is experimental

## Install
* Download [Journalbeat](https://www.elastic.co/downloads/past-releases/journalbeat-7-6-2). As of now, the beats version is `7.6.2`
* Create directories for certificates and copy
```
$ sudo mkdir /etc/ssl/beats
## Copy .pem files to beats directory which were generated while configuring elasticsearch
$ ls /etc/ssl/beats
elasticsearch-ca.pem  letsencryptauthorityx3.pem
```

* Verify [journalbeat](./journalbeat.yml)  and copy to `/etc/journalbeat/`
```
$ ls /etc/journalbeat
fields.yml  journalbeat.reference.yml  journalbeat.yml  journalbeat.yml_backup

### If require, test config

$ journalbeat test config                                                                                                                             :(
sudo heartbeat test config
Config OK
```

* Start the daemon
```
$ sudo systemctl enable journalbeat
$ sudo systemctl start journalbeat
```