load data into table overdrive.load_disk
insert
fields terminated by "|"
(
username,
hostname,
filesystem,
blocks_1k,
used,
available,
pct_used,
mounted_on
)
