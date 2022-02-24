_[Office Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/elasticsearch-intro.html)_
# Elasticsearch Installation Steps
## Index
* [JDK Installation](#JDK Installation)
* [Elasticsearch Installation](#Elasticsearch Installation)
* [Kibana Installation](#Kibana Installation)

## Hardware Requirement
_[Offical Docs](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html)_

| Resource | Minimum | Recommended |
|----------|---------|------------|
| Memory   | 16 GB   | 64 GB      |
| CPU      | 8 Cores | 16         |
| Disk     | Depends | Depends    |

## JDK Installation
* Pick JVM compatibility version with elasticsearch from [here](https://www.elastic.co/support/matrix#matrix_jvm)
* Install OpenJDK from [here](https://openjdk.java.net/install/index.html)
Download and install JDK 11 (Another guide [here](https://jdk.java.net/java-se-ri/11))
```
$ apt-get install openjdk-11-jdk -y
$ java -version
openjdk version "11.0.6" 2020-01-14
OpenJDK Runtime Environment (build 11.0.6+10-post-Ubuntu-1ubuntu118.04.1)
OpenJDK 64-Bit Server VM (build 11.0.6+10-post-Ubuntu-1ubuntu118.04.1, mixed mode, sharing)
```

## Elasticsearch Installation
* Download latest elasticsearch from [here](https://www.elastic.co/downloads/elasticsearch) (As of today the latest version is `7.6.2`)
* Recommended to download/install package via `.dep` or `PPA` which postscripts creates user, groups and adds under systemd

##### Install via `apt-get` from [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/deb.html#deb-repo)

```
$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
$ sudo apt-get install apt-transport-https
$ echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
$ sudo apt-get update && sudo apt-get install elasticsearch
```

_***DON'T START elasticsearch DAEMON YET!!! We need to configure**_

### System Configuration
[Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html)

* Create `data` directory(This `data` directory you have to specify in elasticsearch config)
```
$ mkdir /var/data/elasticsearch
$ chown -R elasticsearch:elasticsearch /var/data/elasticsearch
```

* Disable swapping
```
$ sudo swapoff -a

## *** Perminent Config ***
## Comment out any lines that contain the word 'swap' in '/etc/fstab'
```

* Increase mmap count
```
$ sudo sysctl -w vm.max_map_count=262144

## *** Perminent Config ***
## update the vm.max_map_count setting in /etc/sysctl.conf
```

* Increase file descriptors for elasticseach user
```
$ sudo su
# ulimit -n 65535

## *** Perminent Config ***
## echo 'elasticsearch  -  nofile  65535'| sudo tee /etc/security/limits.conf
## Ubuntu ignores the limits.conf file for processes started by init.d. To enable the limits.conf file, edit /etc/pam.d/su and uncomment the following line
## # session    required   pam_limits.so
```
Systems which uses systemd limits need to be specified via systemd
```
$ sudo systemctl edit elasticsearch
## Above command opens editor to override the config. Add below setting in it
[Service]
LimitMEMLOCK=infinity
```

* Increase number of threads count for elasticsearch user
```
$ sudo su
# ulimit -u 4096

## *** Perminent Config ***
## echo 'elasticsearch  -  nproc  4096'| sudo tee /etc/security/limits.conf
## Ubuntu ignores the limits.conf file for processes started by init.d. To enable the limits.conf file, edit /etc/pam.d/su and uncomment the following line
## # session    required   pam_limits.so
```


### JVM Configuration
Elasticsearch needs more heap memory. Change the JVM heap memory accordingly, please be noted that more heap means more garbage collection i.e more CPU utilization

Change max and min heap in `/etc/elasticsearch/jvm.options` like below (Currently we are setting 15GB for heap)
```
...
-Xms15g
-Xmx15g
...
```
* Go through other JVM config or logging config if required

**NOTE: Make sure min and max heap memories are same value to avoid bootstrap check failures**
### Elasticsearch Configuration
[Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html)
* If you install elasticsearch via `apt-get` or `.dep file, the config files are located in `/etc/elasticsearch/` directory
* Refer `elasticsearch.yml` configuration in `config_sample` directory specify nodes and copy configurations to nodes accordingly 

Once everything is ready, start `elasticsearch` daemon in all nodes
```
$ sudo systemctl enable elasticsearch
$ sudo systemctl start elasticsearch
```
If everything is ok, you should get responses like below
```
$ curl -XGET 10.29.103.18:9200
{
  "name" : "carbon-1",
  "cluster_name" : "carbon",
  "cluster_uuid" : "zpoOdANFSXujgNMplMz1fQ",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

$ curl -XGET 10.29.103.18:9200/_cat/nodes
10.29.103.18 7 74  5 0.07 0.91 1.95 dilm * carbon-1
10.29.103.10 2 87 25 0.08 1.08 1.68 dil  - carbon-3
10.29.103.16 5 76 25 0.18 1.13 1.75 dil  - carbon-2
``` 
### Configure Security
* Starting from versions 6.8.0 and 7.1.0, security comes in basic. Read update blog [here](https://www.elastic.co/blog/security-for-elasticsearch-is-now-free)
* Watch [Getting Started with Free Elasticsearch Security Features](https://www.youtube.com/watch?v=nMh1HWWe6B4)


#### Configure transport layer SSL for node communication
*  There is tool `elasticsearch-certutil` which comes with elasticsearch installation. Depends on requirement generate keys
   * `csr` to get certificate signing request and sign it with CA
   * `cert` to get self signed cerificates
   * `ca` to get certificate authority
   * `http` for certificates fot HTTP
```
$ cd /usr/share/elasticsearch/bin
$ ./elasticsearch-certutil --help
Simplifies certificate creation for use with the Elastic Stack

Commands
--------
csr - generate certificate signing requests
cert - generate X.509 certificates and keys
ca - generate a new local certificate authority
http - generate a new certificate (or certificate request) for the Elasticsearch HTTP interface

Non-option arguments:
command

Option             Description
------             -----------
-E <KeyValuePair>  Configure a setting
-h, --help         Show help
-s, --silent       Show minimal output
-v, --verbose      Show verbose output

```
Generating [`.p12`](https://en.wikipedia.org/wiki/PKCS_12) and copy the file to every node
```
./elasticsearch-certutil cert
...
Please enter the desired output file [elastic-certificates.p12]:/etc/elasticsearch/elastic-certificates.p12
...
```

* Enable SSL and  specify `.p12` file location in config like below in every node in  `elasticsearch.yml`
```
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /etc/elasticsearch/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /etc/elasticsearch/elastic-certificates.p12
```

Restart `elasticsearch` daemon in all nodes
```
$ sudo systemctl restart elasticsearch
```

#### Generate Passwords
* Login into master node and run below commands
```
$ cd /usr/share/elasticsearch
$ sudo bin/elasticsearch-setup-passwords auto
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,kibana_system,logstash_system,beats_system,remote_monitoring_user.
The passwords will be randomly generated and printed to the console.
Please confirm that you would like to continue [y/N]y

Changed password for user apm_system
PASSWORD apm_system = xxxxxxxxxxxxxx

Changed password for user kibana
PASSWORD kibana = xxxxxxxxxxxxxx

Changed password for user logstash_system
PASSWORD logstash_system = xxxxxxxxxxxxxx

Changed password for user beats_system
PASSWORD beats_system = xxxxxxxxxxxxxx

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = xxxxxxxxxxxxxx

Changed password for user elastic
PASSWORD elastic = xxxxxxxxxxxxxx
```
Copy those credentials and store it safe. 
* The `elastic` user is cluster admin user
* The `kibana` user is for kibana to authenticate with elasticsearch 

#### Configure HTTPS for REST API
* Generate certificates(Below is the process to generate certificates. Everything )
```
$ cd /usr/share/elasticsearch
$ sudo bin/elasticsearch-certutil http

## Elasticsearch HTTP Certificate Utility

The 'http' command guides you through the process of generating certificates
for use on the HTTP (Rest) interface for Elasticsearch.

This tool will ask you a number of questions in order to generate the right
set of files for your needs.

## Do you wish to generate a Certificate Signing Request (CSR)?

A CSR is used when you want your certificate to be created by an existing
Certificate Authority (CA) that you do not control (that is, you don't have
access to the keys for that CA).

If you are in a corporate environment with a central security team, then you
may have an existing Corporate CA that can generate your certificate for you.
Infrastructure within your organisation may already be configured to trust this
CA, so it may be easier for clients to connect to Elasticsearch if you use a
CSR and send that request to the team that controls your CA.

If you choose not to generate a CSR, this tool will generate a new certificate
for you. That certificate will be signed by a CA under your control. This is a
quick and easy way to secure your cluster with TLS, but you will need to
configure all your clients to trust that custom CA.
Generate a CSR? [y/N]n

## Do you have an existing Certificate Authority (CA) key-pair that you wish to use to sign your certificate?

If you have an existing CA certificate and key, then you can use that CA to
sign your new http certificate. This allows you to use the same CA across
multiple Elasticsearch clusters which can make it easier to configure clients,
and may be easier for you to manage.

If you do not have an existing CA, one will be generated for you.

Use an existing CA? [y/N]n
A new Certificate Authority will be generated for you

## CA Generation Options

The generated certificate authority will have the following configuration values.
These values have been selected based on secure defaults.
You should not need to change these values unless you have specific requirements.

Subject DN: CN=Elasticsearch HTTP CA
Validity: 5y
Key Size: 2048

Do you wish to change any of these options? [y/N]n

## CA password

We recommend that you protect your CA private key with a strong password.
If your key does not have a password (or the password can be easily guessed)
then anyone who gets a copy of the key file will be able to generate new certificates
and impersonate your Elasticsearch cluster.

IT IS IMPORTANT THAT YOU REMEMBER THIS PASSWORD AND KEEP IT SECURE

CA password:  [<ENTER> for none]

## How long should your certificates be valid?

Every certificate has an expiry date. When the expiry date is reached clients
will stop trusting your certificate and TLS connections will fail.

Best practice suggests that you should either:
(a) set this to a short duration (90 - 120 days) and have automatic processes
to generate a new certificate before the old one expires, or
(b) set it to a longer duration (3 - 5 years) and then perform a manual update
a few months before it expires.

You may enter the validity period in years (e.g. 3Y), months (e.g. 18M), or days (e.g. 90D)

For how long should your certificate be valid? [5y] 5Y

## Do you wish to generate one certificate per node?

If you have multiple nodes in your cluster, then you may choose to generate a
separate certificate for each of these nodes. Each certificate will have its
own private key, and will be issued for a specific hostname or IP address.

Alternatively, you may wish to generate a single certificate that is valid
You entered the following hostnames.

 - elk-staging.mydomain.com

Is this correct [Y/n]y

## Which IP addresses will be used to connect to your nodes?

If your clients will ever connect to your nodes by numeric IP address, then you
can list these as valid IP "Subject Alternative Name" (SAN) fields in your
certificate.

If you do not have fixed IP addresses, or not wish to support direct IP access
to your cluster then you can just press <ENTER> to skip this step.
across all the hostnames or addresses in your cluster.

If all of your nodes will be accessed through a single domain
(e.g. node01.es.example.com, node02.es.example.com, etc) then you may find it
simpler to generate one certificate with a wildcard hostname (*.es.example.com)
and use that across all of your nodes.

However, if you do not have a common domain name, and you expect to add
additional nodes to your cluster in the future, then you should generate a
certificate per node so that you can more easily generate new certificates when
you provision new nodes.

Generate a certificate per node? [y/N]n

## Which hostnames will be used to connect to your nodes?

These hostnames will be added as "DNS" names in the "Subject Alternative Name"
(SAN) field in your certificate.

You should list every hostname and variant that people will use to connect to
your cluster over http.
Do not list IP addresses here, you will be asked to enter them later.

If you wish to use a wildcard certificate (for example *.es.example.com) you
can enter that here.

Enter all the hostnames that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

elk-staging.mydomain.com
Enter all the IP addresses that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

85.xx.xx.xx
85.xx.xx.xx
85.xx.xx.xx

You entered the following IP addresses.

 - 85.xx.xx.xx
 - 85.xx.xx.xx
 - 85.xx.xx.xx

Is this correct [Y/n]y

## Other certificate options
The generated certificate will have the following additional configuration
values. These values have been selected based on a combination of the
information you have provided above and secure defaults. You should not need to
change these values unless you have specific requirements.

Key Name: elk.mydomain.com
Subject DN: CN=elk, DC=mydomain, DC=org
Key Size: 2048

Do you wish to change any of these options? [y/N]n

## What password do you want for your private key(s)?

Your private key(s) will be stored in a PKCS#12 keystore file named "http.p12".
This type of keystore is always password protected, but it is possible to use a
blank password.

If you wish to use a blank password, simply press <enter> at the prompt below.
Provide a password for the "http.p12" file:  [<ENTER> for none]

## Where should we save the generated files?

A number of files will be generated including your private key(s),
public certificate(s), and sample configuration options for Elastic Stack products.

These files will be included in a single zip archive.

What filename should be used for the output zip file? [/usr/share/elasticsearch/elasticsearch-ssl-http.zip]
./elasticsearch-certutil http  6.38s user 0.47s system 6% cpu 1:38.49 total
```
The zip file `/usr/share/elasticsearch/elasticsearch-ssl-http.zip` contains below files
```
$ unzip elasticsearch-ssl-http.zip
$ tree .
.
├── ca
├── README.txt
└── ca.p12
├── elasticsearch
├── README.txt
├── http.p12
└── sample-elasticsearch.yml
└── kibana
    ├── README.txt
    ├── elasticsearch-ca.pem
    └── sample-kibana.yml
```

Create new directory `/etc/elasticsearch/http_ssl` and copy `http.p12` to all server

Add below config to `/etc/elasticsearchelasticsearch.yml` to enable http ssl like below

```
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: "/etc/elasticsearch/http_ssl/http.p12"
```


#### HTTPS configurations for HTTP clients

##### Kibana
Create `/etc/kibana/ca` and copy `elasticsearch-ca.pem` to kibana server

Add below config to `kibana.yml` to enable HTTPS communication between elasticsearch and kibana
```
elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/ca/elasticsearch-ca.pem" ]
```

##### Beats
* Use same `.pem` file to enable HTTPS communication between beats and elasticsearch(sample snippet below)

```
output.elasticsearch:
  hosts: ['https://elk-staging.mydomain.com:9201']
  username: admin
  password: 123123123
  ssl:
    certificate_authorities: ["/etc/elasticsearch-ca.pem"]

setup.dashboards:
  enabled: true

setup.kibana:
  host: "https://elk-staging.mydomain.com:5691"
  ssl:
    certificate_authorities: ["/etc/letsencryptauthorityx3.pem"]
```

## Alerting
The official Elasticsearch "Basic" version doesn't include alerting. Below are the 2 opensource plugin available for elasticsearch

### 1. Opendistro Elasticsearch Alerting
_*IMPORTANT NOTE: Opendistro Alerting IS NOT compatible with X-Pack Security, for more information refer this [issue](https://github.com/opendistro-for-elasticsearch/alerting/issues/3). If the x-pack is already enabled, DO NOT install this plugin, won't work!. In order to install this plugin, disable x-pack security and install opendistro security_

Pick Opendistro alerting standalone plugin version compatibility [here](https://opendistro.github.io/for-elasticsearch-docs/docs/install/plugins/)

* Login into master node and install necessary plugins and alerting plugin like below
```
## Go elasticseatch bin directory
$ cd /usr/share/elasticsearch/
## Install Job Scheduler plugin
$ sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-job-scheduler/opendistro-job-scheduler-1.8.0.0.zip
## Install Alerting plugin
$ sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-alerting/opendistro_alerting-1.8.0.0.zip
## Restart Elasticsearch
$ sudo systemctl restart elasticsearch
``` 
 
### 2. Elastalert 
Check [elastalert](../elastalert) for installation instructions.


## Stack Monitoring
* Offical [Docs](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/configuring-metricbeat.html)
* Kibana [Docs](https://www.elastic.co/guide/en/kibana/current/monitoring-metricbeat.html)

Elasticsearch can monitor itself, enable stack monitoring using REST API like below
```
PUT _cluster/settings
{
  "persistent": {
    "xpack.monitoring.collection.enabled": true
  }
}
```

We can also monitor with `metricbeat`, this method is useful especially want to monitor multiple clusters. Please refer metricbeat `elasticsearch-xpack` module config