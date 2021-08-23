#!/bin/bash

mount -t xfs -o noatime,nodiratime,logbufs=8 -L d1 /srv/node/d1
mount -t xfs -o noatime,nodiratime,logbufs=8 -L d2 /srv/node/d2
mount -t xfs -o noatime,nodiratime,logbufs=8 -L d3 /srv/node/d3
