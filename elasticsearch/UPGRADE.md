_[Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html)_
# Rolling Upgrade Elasticsearch

> A rolling upgrade allows an Elasticsearch cluster to be upgraded one node at a time so upgrading does not interrupt service 

As of now, the current latest version of elasticsearch is `v7.7.1`. Below procedure is for rolling upgrade from `7.6.2`=>`7.7.1`.

## 1. Divide the cluster into 2 groups
* a. Non master-eligible nodes
  * carbon-2
  * carbon-3
* b. Master-eligible nodes
  * carbon-1

Upgrade order (Important!)
1. Non master eligible nodes
2. Master eligible nodes

#### NOTE: Newer nodes can always join a cluster with an older master, BUT older nodes cannot always join a cluster with a newer master

## 2. Prepare for upgrade
Below points taken from [official docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html) which are recomended
1. Check the deprecation log to see if you are using any deprecated features and update your code accordingly.(While checking this step, I found some histogram deprecation logs. But I performed upgrade anyways!)
2. Review the breaking changes and make any necessary changes to your code and configuration for version 7.7.1. 
3. If you use any plugins, make sure there is a version of each plugin that is compatible with Elasticsearch version 7.7.1. 
4. Test the upgrade in an isolated environment before upgrading your production cluster.
5. Back up your data by taking a snapshot


## 3. Disable shard allocation
When the node is down, elasticsearch try to replicate the shards on that node to other nodes in the cluster which involves lot of I/O. Since the node will be down for short time, it is recommended disable allocation with below settings
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
```
## 4. Upgrade Elasticsearch
##### NOTE: Follow the upgrade order like mentioned above.
_*Perform below operation on each node by node and group by group._

Since in our cluster, the elasticsearch package installed from APT repository, we can upgrade package from APT repository like below
```
$ sudo systemctl stop elasticsearch.service

$ sudo apt-get update
$ sudo apt-get install --only-upgrade elasticsearch
$ sudo systemctl start elasticsearch
$ sudo systemctl status elasticsearch
```
Check logs if it required

Before upgrading to next node, wait for the cluster to finish shard allocation.You can check progress by below API(Important!)
```
GET _cat/health?v
```

##### NOTE: In case, the ip routes are disappeared which happened in one node while install package, follow below steps
Take routing table reference from other nodes and add routes accordingly. 
```
ip link set eth1 down
ip addr add 10.29.103.10/24 dev eth1
ip route add 10.48.0.0/16 via 10.29.103.1
ip link set eth1 up
```

## 5. Upgrade any plugins
*This step was not performed, since there were no plugins installed

Use the `elasticsearch-plugin` script to install the upgraded version of each installed Elasticsearch plugi
## 6. Re-enable shard allocation
Verify all nodes are joined in the cluster
```
GET _cat/nodes
```
Reenable shard allocation
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
```

Once all nodes are upgraded, verify the version and health
```
GET /_cat/health?v
GET /_cat/nodes?h=ip,name,version&v
```

NOTE: Once cluster is upgraded and all nodes joined, it will take some for shard reallocation. 







