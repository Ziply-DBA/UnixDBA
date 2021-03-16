set pages 0 feedback off echo off lines 650
col servicetype for A55
col DBMS for A80
col hostuser for A220
col fqdn for A120
col accounttype for a45
break on accounttype nodup on servicetype nodup on DBMS nodup on hostuser nodup on fqdn nodup
spool inventory.lst
select rpad('##',2+2*2) || u.username || ':' || rpad('##',2+2*3) || 'children:' as accounttype,
 rpad('##',2+2*4) || u.username || '_' || s.service_type || ':'  || rpad('##',2+2*5) || 'children:' servicetype,
 rpad('##',2+2*6) || u.username || '_' || s.server_brand || ':'  || rpad('##',2+2*7) || 'hosts:' dbms,
 rpad('##',2+2*8) || h.hostname || ':' fqdn
from host h
inner join hostuser u on h.host_id=u.host_id
left join service s on h.host_id=s.host_id
where u.username ='khh8615'
and h.os_type='UNIX'
and s.service_type not like '%?'
order by 1,2,3,4
/
select rpad('##',2+2*2) ||'app_account:' || rpad('##',2+2*3) || 'children:' as accounttype,
 rpad('##',2+2*4) || s.service_type  || ':' || rpad('##',2+2*5) || 'children:' servicetype,
 rpad('##',2+2*6) || s.server_brand  || ':' || rpad('##',2+2*7) || 'children:' dbms,
 rpad('##',2+2*8) || s.server_brand  || '_' || s.host_username || ':' || rpad('##',2+2*9) || 'vars:' || rpad('##',2+2*10) || 'ansible_user: ' || s.host_username || rpad('##',2+2*9) || 'hosts:' hostuser,
 rpad('##',2+2*10) || h.hostname || nvl2(h.domain,'.' || h.domain, '') || ':' fqdn
from service s
inner join hostuser u on u.host_id=s.host_id and s.host_username=u.username
inner join host h on h.host_id=s.host_id
where u.comments like '%SSH%'
and s.service_type not like '%?'
and h.os_type='UNIX'
order by 1,2,3,4,5
/
spool off
