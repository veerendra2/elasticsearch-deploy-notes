# Postgresql Metrics

## Activity Dataset
```
postgresql.activity.application_name
postgresql.activity.backend_start
postgresql.activity.client.address
postgresql.activity.client.hostname
postgresql.activity.database.name
postgresql.activity.pid	27,497
postgresql.activity.query
postgresql.activity.state
postgresql.activity.user.name


postgresql.activity.backend_start
postgresql.activity.client.address
postgresql.activity.client.hostname
postgresql.activity.client.port
postgresql.activity.database.name
postgresql.activity.database.oid
postgresql.activity.pid
postgresql.activity.query
postgresql.activity.query_start
postgresql.activity.state
postgresql.activity.state_change
postgresql.activity.user.id
postgresql.activity.user.name

metricset.name: activity
```


## Activity bgwriter
```
postgresql.bgwriter.buffers.allocated	2,134,126,671
postgresql.bgwriter.buffers.backend	24,581,067
postgresql.bgwriter.buffers.backend_fsync	0
postgresql.bgwriter.buffers.checkpoints	15,790,083
postgresql.bgwriter.buffers.clean	3,094,041
postgresql.bgwriter.buffers.clean_full	18,321
postgresql.bgwriter.checkpoints.requested	210
postgresql.bgwriter.checkpoints.scheduled	24,534
postgresql.bgwriter.checkpoints.times.sync.ms	4,722,208
postgresql.bgwriter.checkpoints.times.write.ms	264,170,496
postgresql.bgwriter.stats_reset	Jan 11, 2020 @ 22:09:19.743
```

## Activity database
```
postgresql.database.blocks.hit	52,114,919
postgresql.database.blocks.read	6,723
postgresql.database.blocks.time.read.ms	0
postgresql.database.blocks.time.write.ms	0
postgresql.database.conflicts	0
postgresql.database.deadlocks	0
postgresql.database.name
postgresql.database.number_of_backends	0
postgresql.database.oid	0
postgresql.database.rows.deleted	14,038
postgresql.database.rows.fetched	12,856,439
postgresql.database.rows.inserted	14,388
postgresql.database.rows.returned	55,326,723
postgresql.database.rows.updated	20
postgresql.database.stats_reset	Jan 11, 2020 @ 22:09:21.534
postgresql.database.temporary.bytes	0
postgresql.database.temporary.files	0
postgresql.database.transactions.commit	0
postgresql.database.transactions.rollback	0
```