#!/bin/bash

## variables:
#$DOMAIN
#$SERVER
#$PREFIX
#$USER
#$PORT
#sentinel port

        read -ep "Enter domain: " DOMAIN
#        read -ep "Enter server: " SERVER
        read -ep "Enter user: " USER
        read -ep "Enter CMS: " CMS


#prefix="echo {$SERVER} | cut -d '.' -f1"


SERVER=$HOSTNAME
PREFIX=$(echo $SERVER | cut -d '-' -f1)
PORT=$(grep port /etc/redis-sentinel.d/$USER/sentinel.conf | awk '{print $2}')

echo -e "Domain: $DOMAIN "
echo -e "Hostname: $SERVER "
echo -e "Server prefix: $PREFIX "
echo -e "USER: $USER "
echo -e "CMS: $CMS "

echo -e "

1> Update ansible group_vars file:

file: inventories/nexcess/group_vars/${PREFIX}_prod
(may be $PREFIX adjust accordingly)

remove the following for lsync and redis-replica/sentinel
(note <LABEL> and <DIR> and <FLIE> will change depending on setup, adjust according)


    - name: $USER
      sentinel:
        port: 5001
      domains:
        - name: $DOMAIN
          label: <LABEL>
          max_memory: 4096
          port: 6385


  - user: $USER
    domains:
      - name: $DOMAIN
        cms: $CMS
        symlinks:
          - /<DIR>
          - /<FILE>


Save and and submit and merge.

2> disable services for lsync (should be done, but double check)

https://waypoint.liquidweb.com:8443/pages/viewpage.action?pageId=63212906

fs1:


systemctl disable --now lsyncd-$DOMAIN.service


2.1> remove service files:

/etc/systemd/system/lsyncd-$DOMAIN.service


2.2> reload daemon:

systemctl daemon-reload


2.3> remove the config files:


/etc/lsyncd-$DOMAIN.conf
/etc/lsyncd-$DOMAIN.conf


2.4> Files/account/domains are already removed, so disable local DocRoot:

me esg-ansible.us-midwest-1.nxcli.net

ansible-playbook $PREFIX_prod local-docroot -t disable



2.5> remove local directories on the nodes: (confirm before running the following)

log into each node: $PREFIX-node1, $PREFIX-node2, $PREFIX-node3

rm -r /local/$USER/$DOMAIN

may need to remore $USER if not nested, but confirm


rm -r /local/$USER

2.6> Enable docRoot:

from : esg-ansible.us-midwest-1.nxcli.net

ansible-playbook $PREFIX_prod local-docroot -t enable


3> remove Redis:

https://waypoint.liquidweb.com:8443/pages/viewpage.action?pageId=63212861

ansible should have been updated in the initial update in step 1

3.1> log into the server needing the instance removed: 9can be combined with step 3.2 to avoid back and forth into the servers



nodes: 1-3 (if standard naming applied)

Wordpress
nkredis remove redis-multi-$USER.$DOMAIN-object-replica.service

or Magento
nkredis remove redis-multi-$USER.$DOMAIN-cache-replica.service

fs1: (if standard naming applied)

Wordpress:
nkredis remove redis-multi-$USER.$DOMAIN-object-master.service

or Magento:
nkredis remove redis-multi-$USER.$DOMAIN-cache-replica.service

lb1: (if standard naming applied)

Wordpress:
nkredis remove redis-multi-$USER.$DOMAIN-object-master-backup.service

or Magento:
nkredis remove redis-multi-$USER.$DOMAIN-cache-master-backup.service

3.2> Reset failed (can be combined with step 3.1 when you are on the servers



nodes : 1-3 (if standard naming applied)

Wordpress:
systemctl reset-failed redis-multi-$USER.$DOMAIN-object-replica.service

Magento:
systemctl reset-failed redis-multi-$USER.$DOMAIN-cache-replica.service

fs1:

Wordpress:
systemctl reset-failed redis-multi-$USER.$DOMAIN-object-master.service

Magento:
systemctl reset-failed redis-multi-$USER.$DOMAIN-object-replica.service


3.3> find Sentinel IP and port:

Sample sentinel connection:
head -n2 /etc/redis-sentinel.d/<USER>/sentinel.conf
bind 172.17.106.140
port 5001

Port for removal:

echo -e $PORT


3.4> remove Sentinel instance from fs1 and node1 and lb1



redis-cli -h $PREFIX-node1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object
redis-cli -h $PREFIX-fs1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object
redis-cli -h $PREFIX-lb1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object


redis-cli -h $PREFIX-node1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object
redis-cli -h $PREFIX-fs1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object
redis-cli -h $PREFIX-lb1-int -p $SENTINEL_PORT SENTINEL REMOVE $DOMAIN-object
3.5>edit host files on each server of the cluster

change the following entries:



from:
/etc/hosts

172.17.106.140 $PREFIX-fs1-int $PREFIX-ha.monex.com-object $PREFIX-ha.$DOMAIN-object $PREFIX-ha.$DOMAIN-object $PREFIX-ha.mobilemonex.com-object

to

172.17.106.140 $PREFIX-fs1-int $PREFIX-ha.monex.com-object $PREFIX-ha.$DOMAIN-object $PREFIX-ha.mobilemonex.com-object
 $PREFIX-ha.$DOMAIN-object and $PREFIX-ha.$DOMAIN-object removed


"