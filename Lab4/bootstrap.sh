#!/bin/bash

apt-get update 
sudo apt-get install bind9 -y

cat <<EOF> named.conf.local
zone "hgallo.com" {
type master;
file "/etc/bind/zones/hgallo.com.db";
notify yes;
allow-transfer { localhost;192.168.0.102;};
also-notify { 192.168.0.102; };
};

zone "3.2.1.in-addr.arpa" {
type master;
file "/etc/bind/zones/rev.3.2.1.in-addr.arpa";
};
EOF

sudo mv named.conf.local /etc/bind/named.conf.local

sudo mkdir -p /etc/bind/zones

cat <<EOF> hgallo.com.db
; BIND data file for hgallo.com
;
\$TTL 14400
@    IN SOA ns1.hgallo.com. host.hgallo.com. (
       201802161902 ; Serial
       7200 ; Refresh
       120 ; Retry
       2419200 ; Expire
       604800 ; Default TTL
       );

       IN NS ns1.hgallo.com.
       IN NS ns2.hgallo.com.

       IN MX 10 mail.hgallo.com.
       IN A 192.168.0.101

ns1    IN A 192.168.0.101
ns2    IN A 192.168.0.102
mybox  IN A 192.168.56.109
www    IN CNAME hgallo.com.
mail   IN A 192.168.0.101
ftp    IN CNAME hgallo.com.

hgallo.com. IN TXT "v=spf1 ip4:192.168.0.101 a mx ~all"
mail        IN TXT "v=spf1 a -all"
EOF

sudo mv hgallo.com.db /etc/bind/zones/hgallo.com.db

cat <<EOF> rev.3.2.1.in-addr.arpa
@ IN SOA hgallo.com. host.hgallo.com. (
     2010081401;
     28800;
     604800;
     604800;
     86400 
);
 
IN NS ns1.hgallo.com.
IN PTR hgallo.com.
EOF

sudo mv rev.3.2.1.in-addr.arpa /etc/bind/zones/rev.3.2.1.in-addr.arpa

sudo chown -R root:bind /etc/bind

sudo  service apparmor stop
sudo  service apparmor teardown

/etc/init.d/bind9 start

