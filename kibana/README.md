_* [Office docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/elasticsearch-intro.html)_
## Kibana Installation
_*NOTE: The elasticsearch should be up and running before you start kibana installation procedure_
##### Install via `apt-get` from [here](https://www.elastic.co/downloads/kibana)
* As of today the kibana version is `7.6.2`
```
$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
$ sudo apt-get install apt-transport-https
$ echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
$ sudo apt-get update && sudo apt-get install kibana
```

### Configure Kibana
Refer `kibana.yml` configuration file in current directory and modify accordingly
* Specify `kibana` credentials in `kibana.yml` which were generated while configuration elasticsearch security 

### Configure Security
* [Reference doc](https://www.elastic.co/blog/x-pack-security-for-elasticsearch-with-lets-encrypt-certificates)

#### HTTPS Configuration with Let's Encrypt certificates

* Download certbot and generate certificate
```
$ wget https://dl.eff.org/certbot-auto
$ chmod 755 certbot-auto
$ ./certbot-auto certonly
```

* Copy certificates to kibana config directory and change permission
```
$ mkdir /etc/kibana/ssl
$ cp -pr /etc/letsencrypt/archive/data.example.com /etc/kibana/ssl/
$ chmod 750 /etc/kibana/ssl/data.example.com
$ chmod 640 /etc/kibana/ssl/data.example.com/*
$ chown -R root:kibana /etc/kibana/ssl/data.example.com
```
Add below config to `kibana.yml` to enable HTTPS
```
server.ssl.enabled: true
server.ssl.certificate: /etc/kibana/ssl/elk-staging.yourdomain.com/cert1.pem
server.ssl.key: /etc/kibana/ssl/elk-staging.yourdomain.com/privkey1.pem
```

#### SSL Config for Kibana to Communicate Elasticsearch
* Copy `elasticsearch-ca.pem`(This the pem file that you were generated while configuring elasticsearch security) to `/etc/kibana/ca/` 
```
$ mkdir /etc/kibana/ca/
$ ls /etc/kibana/ca/elasticsearch-ca.pem
```
Add below config to `kibana.yml`
```
elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/ca/elasticsearch-ca.pem" ]
```