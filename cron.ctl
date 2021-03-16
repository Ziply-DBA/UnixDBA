load data into table overdrive.load_cron
insert
fields terminated by "|"
(
username,
hostname,
cron_min,
cron_hour,
cron_dom,
cron_mon,
cron_dow,
cron_cmd
)
