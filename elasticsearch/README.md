# Configuration Overview for Productions
* Recommended to use `.deb` or `.rpm` package to install instead of install from `.tar`
## Elasticsearch Configuration
[Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html)
Mainly 3 configuration files

```
elasticsearch.yml - Elasticsearch config
jvm.options       - Elasticsearch JVM settings config
log4j2.properties - Elasticsearch logging config
```

Environment Variables
* `export` the ES_PATH_CONF
* `etc/default/elasticsearch` (Sourced environment variables from. Recommended)


## Important Elasticsearch Configuration
[Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html)
* Before going to production, it is recommended go through be blow elasticsearch configs. Refer `backups` directory for configuration  

| Configuration      | Description                                 | Configuration Reference                               |
|--------------------|---------------------------------------------|-------------------------------------------------------|
| Path settings      | Log and data config                         | Refer [here](sample_config/elasticsearch.yml#40)  |
| Cluster name       | Cluster name                                | Refer [here](sample_config/elasticsearch.yml#17)  |
| Node name          | Node name                                   | Refer [here](sample_config/elasticsearch.yml#23)  |
| Network host       | IP address that elasticsearch bind on       | Refer [here](sample_config/elasticsearch.yml#59)                                                      |
| Discovery settings | Cluster discovery and initial master config | Refer [here](sample_config/elasticsearch.yml#72) |
| Heap size          | JVM heap memory configuration               | Recommended heap size should be half of system memory. Make sure min and max heap memory same value. Refer [here](sample_config/jvm.options#22) |
| Heap dump path     | Heap dump location path config              | Default config is sufficient. Refer [here](sample_config/jvm.options#61) |
| GC logging         | Garbage collection logging configuration    | Default config is sufficient. Refer [here](sample_config/jvm.options#66) |
| Temp directory     | Configure private temporary directory that Elasticsearch uses is excluded from periodic cleanup |                                                       |

## Important System Configuration
[Offical Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html)
* Before going to production, it is recommended go through be blow system configs

| Configuration                               | Description                                                                                                                                                                                                                                                                 | Remark |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| Disable swapping                            | Disable swapping to prevent JVM heap or even its executable pages being swapped out to disk                                                                                                                                                                                 |        |
| File descriptors                            | Increase file descriptors for the user running Elasticsearch                                                                                                                                                                                                                |        |
| Virtual memory                              | Increase mmap counts to prevent memory exceptions.                                                                                                                                                                                                                          |        |
| DNS cache settings                          | Overide JVM DNS positive/negetive cache settings (Leave default value)                                                                                                                                                                                                      |        |
| Temporary directory not mounted with noexec | As the native library is mapped into the JVM virtual address space as executable, the underlying mount point of the location that this code is extracted to must not be mounted with noexec as this prevents the JVM process from being able to map this code as executable |        |

## Bootstrap Checks
[Offical Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/bootstrap-checks.html)

Once you configured above configuration, elasticsearch performs some checks during bootstrap to verify configuration. If Elasticsearch is in development mode, any bootstrap checks that fail appear as warnings in the Elasticsearch log. If Elasticsearch is in production mode, any bootstrap checks(below) that fail will cause Elasticsearch to refuse to start.

Below are the boostrap checks.(In case, elasticsearch failed to start, below is the check list to verify)

| Check Name                            | Description                                                                                                                          |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| Heap size check                       | Enforces to start the JVM with the initial heap size equal to the maximum heap size to avoid these resize pauses                         |
| File descriptor checks               | Enforces elasticsearch have good number of file descriptor                                                                            |                                                                
| Memory lock check                    | Enforces JVM heap memory lock to avoid swapping pages to disk. |
| Maximum number of theard pool checks | Enforces Elasticsearch process has the rights to create enough threads under normal use. |                                                                |
| Max file size check                  | Enforces that the Elasticsearch process can create max file size is unlimited|
| Max size virtual memory check        | Enforces that the Elasticsearch process has unlimited address space |
| Max map count check                  | Enforces that the kernel allows a process to have at least 262,144 memory-mapped areas |
| Client JVM check                     | Enforces that the Elasticsearch start with the server JVM. Refer [doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/_client_jvm_check.html) |
| Use serial collector check           | Enforces that the Elasticsearch is not configured to run with the "serial collector" type JVM |
| System call filter check             | Enforces system call filters are enabled which is an ability to execute system calls related to forking against arbitrary code execution attacks on Elasticsearch |
| OnError and OnOutOfMemoryError check | Enforces JVM has options related to OnError or OnOutOfMemoryError enabled |
| Early-access check                   | Enforces to start Elasticsearch on a release build of the JVM. Nor early-access snapshots of upcoming releases which are not suitable for production |
| G1GC check                           | Checks versions of the HotSpot JVM, Refer [docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/_g1gc_check.html) |
| All permission check                 | Enforces security policy used during bootstrap does not grant the `java.security.AllPermission` to Elasticsearch |
| Discovery config check               | Enforces discovery is not running with the default configuration |

## Docker Container Labeling
Useful to filter logs, events, etc at logstash and also at kibana dashboard
```
com.yourdomain.container.type:
"heartbeat"
"metricbeat"
"filebeat"
"application"

com.yourdomain.container.app.version: "1.2"

com.yourdomain.container.environment:
"stagging"
"production"

com.yourdomain.container.name:
"auditlog-1"
"odoo-1"
```

## Index Life Cycle Management

### Definitions
* [Index Life Cycle Actions](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/ilm-actions.html)
* [Index Roll Over Concept](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/index-rollover.html)
* [Index Aliasing - Stackoverflow](https://stackoverflow.com/questions/48907041/what-are-aliases-in-elasticsearch-for)
* [Other elasticsearch terminologies - Stackoverflow](https://stackoverflow.com/questions/61748087/elasticsearch-ilm-terminologies-and-concepts)
