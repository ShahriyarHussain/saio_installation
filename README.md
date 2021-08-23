# OpenStack Swift All In One Installer

This repository contains Swift All In One Installer script. It rigorously tested on **Ubuntu 20.04 LTS** using **python3**. Expected to work on both **Ubuntu 18.04 LTS** and **Ubuntu 21.04**

## Installation Procedure
1. Clone the repository
2. If your VM has SATA Drives, run `git checkout sda`
3. If you don't know the drives, run `ls /sys/block`. If you see `vda,vdb,vdc....` then no need to check. If you see `sda,sdb,sdc....` then checkout.
4. Switch to repo folder using `cd`. i.e `cd saio_installation`
5. Run the `main.sh` with admin permission file. i.e.: `sudo bash main.sh`
