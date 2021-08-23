# OpenStack Swift All In One Installer

**[**OpenStack Swift**](https://github.com/openstack/swift) is a distributed object storage system designed to scale from a single machine to thousands of servers. Swift is optimized for multi-tenancy and high concurrency.**

This repository contains Swift All In One Installer script. It is an unofficial installer, openstack swift does not have any affiliation/supervision over this. It was originally forked from the repository: https://github.com/o-julfikar/cloud and then heavily modified from the original to allow functionality of running on wide variety of systems. It is rigorously tested on **Ubuntu 20.04 LTS** using **python3**. Expected to work on both **Ubuntu 18.04 LTS** and **Ubuntu 21.04**

## Installation Procedure
1. Clone the repository
2. If your VM has SATA Drives, run `git checkout sda`
3. If you don't know the drives, run `ls /sys/block`. If you see `vda,vdb,vdc....` then no need to checkout. If you see `sda,sdb,sdc....` then checkout.
4. Switch to repo folder using `cd`. i.e `cd saio_installation`
5. Run the `main.sh` with admin permission file. i.e.: `sudo bash main.sh`
