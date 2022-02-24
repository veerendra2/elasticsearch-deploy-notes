# Filebeat
* Offical [docs](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
> Forget using SSH when you have tens, hundreds, or even thousands of servers, virtual machines, and containers generating logs. Filebeat helps you keep the simple things simple by offering a lightweight way to forward and centralize logs and files.

## Install
* Download [Journalbeat](https://www.elastic.co/downloads/past-releases/filebeat-7-6-2). As of now, the version is `7.6.2`

* Create directories for certificates and copy
```
$ sudo mkdir /etc/ssl/beats
## Copy .pem files to beats directory which were generated while configuring elasticsearch
$ ls /etc/ssl/beats
elasticsearch-ca.pem  letsencryptauthorityx3.pem
```

* Verify [filebeat](./filebeat.yml)  and copy to `/etc/filebeat/`
```
$ ls /etc/filebeat
fields.yml  filebeat.reference.yml  filebeat.yml

### If require, test config

$ filebeat test config                                                                                                                             :(
sudo filebeat test config
Config OK
```

* Start the daemon
```
$ sudo systemctl enable filebeat
$ sudo systemctl start filebeat
```
 