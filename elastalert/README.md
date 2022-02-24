# Elastalert
* Official [docs](https://github.com/Yelp/elastalert)
* Project Repo [link](https://github.com/Yelp/elastalert)

Elastalert is developed by Yelp written in python, queries docs in elasticsearch and send alerts depends on the rules.

Since Elastalert is not part of Elasticsearch plugin, we can install it where ever we want to.

## Installation
```
$ sudo apt-get install python3-pip
$ sudo pip3 install elastalert
$ sudo pip3 install -U PyYAML
$ mkdir -p /opt/elastalert/rules
## Copy alert rules yaml files and config file to /opt/elastalert and /opt/elastalert/rules accordingly from this repo 
```
* Recommended to create index in elasticsearch for elastalert to store metadata
```
$ elastalert-create-index
Elastic Version: 7.7.0
Reading Elastic 6 index mappings:
Reading index mapping 'es_mappings/6/silence.json'
Reading index mapping 'es_mappings/6/elastalert_status.json'
Reading index mapping 'es_mappings/6/elastalert.json'
Reading index mapping 'es_mappings/6/past_elastalert.json'
Reading index mapping 'es_mappings/6/elastalert_error.json'

New index elastalert_status created
Done!
```
* Test rules in case if it is needed
```
$ elastalert-test-rule --config /opt/elastalert/config.yaml /opt/elastalert/rules/heartbeat_checks.yml
```
#### Postfix Gmail SMTP
In oder to use Gmail as SMTP, you need to enable 2-Factor authentication and generate app password
* First configure 2-Factor Authentication at [google accounts security](https://myaccount.google.com/security)
* Generate app passwords at [app password generation](https://security.google.com/settings/security/apppasswords)
  * Click Select app and choose Other (custom name) from the dropdown. Enter “Postfix” and click Generate.

![Image1](https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu/postfix-gmail-app-password.png)

* Copy App Password

![Image2](https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu/postfix-gmail-generated-app-password.png)

* Install Postfix package
```
sudo apt-get -y install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
```
  * While postfix package install, it will prompt for configuration, default options/configs are sufficient i.e don't have to change anything
  
* Add below config in `/etc/postfix/main.cf`
```
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CApath = /etc/ssl/certs
smtpd_tls_CApath = /etc/ssl/certs
smtp_use_tls = yes
```
* Add email and app password in `/etc/postfix/sasl_passwd`
```
[smtp.gmail.com]:587    xxxxx@yourdomain.de:xxx xxxxx xxxxx xxxxx
```
* Start daemon
```
sudo chmod 400 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl restart postfix
```
* Test it
```
echo "Testing" | mail -s "Test Email" soap@gmail.com
sudo postqueue -p
```
## Daemonize the Elastalert
We will use supervisord to run ElastAlert.
* Install supervisord
```
$ sudo pip3 install supervisord
```
* Review [supervisor config](./supervisord.conf) and copy
```
$ ls /etc/supervisord.conf                                                                                 :(
/etc/supervisord.conf
```
* Enable and start the deamon
```
root@s-root-odoo03 ~ # supervisorctl
supervisor> add elastalert
supervisor> start elastalert
supervisor> exit
```