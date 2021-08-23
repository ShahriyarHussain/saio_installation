#!/bin/bash

sudo echo ""
dir=$(pwd)
sudo touch log_files.log
sudo chmod 777 $dir/log_files.log


echo -ne 'Updating Files and installing dependencies [##                     ](5%)\r'
sleep 1
{
  sudo apt update
} &>> $dir/log_files.log
echo -ne 'Updating Files and installing dependencies [#####                  ](18%)\r'
sleep 1
{
  sudo apt install curl gcc memcached rsync sqlite3 xfsprogs git-core libffi-dev python3-setuptools liberasurecode-dev libssl-dev -y
} &>> $dir/log_files.log
echo -ne 'Updating Files and installing dependencies [##########             ](67%)\r'
sleep 1
{
  sudo apt install python3-coverage python3-dev python3-nose python3-xattr python3-eventlet python3-greenlet python3-pastedeploy python3-netifaces python3-pip python3-dnspython python3-mock -y
} &>> $dir/log_files.log
echo -ne 'Updating Files and installing dependencies [#######################](100%)\r'
echo -ne '\n'
sleep 2

echo -ne 'Cloning Files & Installing requirements [##                     ](2%)\r'
sleep 1
{
  cd /opt/
  sudo git clone https://github.com/openstack/python-swiftclient.git
} &>> $dir/log_files.log
echo -ne 'Cloning Files & Installing requirements [###                    ](5%)\r'
sleep 1
{
  cd /opt/python-swiftclient; sudo pip3 install -r requirements.txt; python3 setup.py install; cd-
} &>> $dir/log_files.log
echo -ne 'Cloning Files & Installing requirements [#######                ](35%)\r'
sleep 1
{
  cd /opt/
  sudo git clone https://github.com/openstack/swift.git
} &>> $dir/log_files.log
echo -ne 'Cloning Files & Installing requirements [#########              ](65%)\r'
sleep 3
{
cd /opt/swift; sudo pip3 install -r requirements.txt; sudo python3 setup.py install; cd -
} &>> $dir/log_files.log
echo -ne 'Cloning Files & Installing requirements [#######################](100%)\r'
echo -ne '\n'
sleep 2

echo -ne 'Copying .conf files [####                   ](8%)\r'
sleep 1
echo -ne 'Copying .conf files [######                 ](32%)\r'
sleep 1
{
sudo mkdir -p /etc/swift
sudo cd /opt/swift/etc
sudo cp /opt/swift/etc/account-server.conf-sample /etc/swift/account-server.conf
sudo cp /opt/swift/etc/container-server.conf-sample /etc/swift/container-server.conf
sudo cp /opt/swift/etc/object-server.conf-sample /etc/swift/object-server.conf
sudo cp /opt/swift/etc/proxy-server.conf-sample /etc/swift/proxy-server.conf
sudo cp /opt/swift/etc/drive-audit.conf-sample /etc/swift/drive-audit.conf
sudo cp /opt/swift/etc/swift.conf-sample /etc/swift/swift.conf
} &>> $dir/log_files.log
echo -ne 'Copying .conf files [#######################](100%)\r'
echo -ne '\n'
sleep 2

echo -ne 'Mounting Drives and Creating Startup script [#                      ](1%)\r'
sleep 1

{
  sudo mkfs.xfs -f -L d1 /dev/sdb
  sudo mkfs.xfs -f -L d2 /dev/sdc
  sudo mkfs.xfs -f -L d3 /dev/sdd

  sudo mkdir -p /srv/node/d1
  sudo mkdir -p /srv/node/d2
  sudo mkdir -p /srv/node/d3
} &>> $dir/log_files.log
echo -ne 'Mounting Drives and Creating Startup script [########               ](42%)\r'
sleep 1


{
  sudo useradd swift
  sudo chown -R swift:swift /srv/node

  sudo cp $dir/mount_drives.sh /opt/swift/bin/mount_drives.sh
  sudo cp $dir/mount_drives.service /etc/systemd/system/mount_drives.service
  sudo chmod +x /opt/swift/bin/mount_drives.sh

  sudo systemctl restart mount_drives.service
  sudo systemctl enable mount_drives.service
  sudo systemctl start mount_drives.service
  bash $dir/mount_drives.sh

} &>> $dir/log_files.log

echo -ne 'Mounting Drives and Creating Startup script [#######################](100%)\r'
echo -ne '\n'
sleep 2


# sudo echo ""
echo "WARNING: ENTER VALUES APPROPRIATELY, THERE ARE NO ERROR CHECKINGS"
echo "Recommeded values are, part_power=3, replication=3, min_hour=1"
echo "Enter Partition Power:"
read part_power
echo "Enter Replication value:"
read replication
echo "Enter Min Hour"
read min_hour

echo -ne 'Creating Builder files and adding devices [##                     ](5%)\r'
sleep 1
{
  cd /etc/swift
  sudo swift-ring-builder account.builder create $part_power $replication $min_hour
  sudo swift-ring-builder container.builder create $part_power $replication $min_hour
  sudo swift-ring-builder object.builder create $part_power $replication $min_hour
  sudo swift-ring-builder object-1.builder create $part_power $replication $min_hour
  sudo swift-ring-builder object-2.builder create $part_power $replication $min_hour

} &>> $dir/log_files.log
echo -ne 'Creating Builder files and adding devices [####                   ](10%)\r'
sleep 1
{
  # echo Adding device 1...
  sudo swift-ring-builder account.builder add r1z1-127.0.0.1:6002/d1 100
  sudo swift-ring-builder container.builder add r1z1-127.0.0.1:6001/d1 100
  sudo swift-ring-builder object.builder add r1z1-127.0.0.1:6000/d1 100
  sudo swift-ring-builder object-1.builder add r1z1-127.0.0.1:6000/d1 100
  sudo swift-ring-builder object-2.builder add r1z1-127.0.0.1:6000/d1 100

  # echo Adding device 1...
  sudo swift-ring-builder account.builder add r1z2-127.0.0.2:6002/d2 100
  sudo swift-ring-builder container.builder add r1z2-127.0.0.2:6001/d2 100
  sudo swift-ring-builder object.builder add r1z2-127.0.0.2:6000/d2 100
  sudo swift-ring-builder object-1.builder add r1z2-127.0.0.2:6000/d2 100
  sudo swift-ring-builder object-2.builder add r1z2-127.0.0.2:6000/d2 100
} &>> $dir/log_files.log
echo -ne 'Creating Builder files and adding devices [##########             ](45%)\r'
sleep 1
{
  # echo Adding device 1...
  sudo swift-ring-builder account.builder add r1z3-127.0.0.3:6002/d3 100
  sudo swift-ring-builder container.builder add r1z3-127.0.0.3:6001/d3 100
  sudo swift-ring-builder object.builder add r1z3-127.0.0.3:6000/d3 100
  sudo swift-ring-builder object-1.builder add r1z3-127.0.0.3:6000/d3 100
  sudo swift-ring-builder object-2.builder add r1z3-127.0.0.3:6000/d3 100
} &>> $dir/log_files.log
echo -ne 'Creating Builder files and adding devices [#######################](100%)\r'
echo -ne '\n'


echo -ne 'Rebalance Builders and Create Logger [##                     ](5%)\r'
sleep 1
echo -ne 'Rebalance Builders and Create Logger [####                   ](10%)\r'
sleep 1
{
  cd /etc/swift
  sudo swift-ring-builder account.builder rebalance
  sudo swift-ring-builder container.builder rebalance
  sudo swift-ring-builder object.builder rebalance
  sudo swift-ring-builder object-1.builder rebalance
  sudo swift-ring-builder object-2.builder rebalance
} &>> $dir/log_files.log
echo -ne 'Rebalance Builders and Create Logger [######                 ](25%)\r'
sleep 1
{
  sudo bash -c 'echo local0.* /var/log/swift/all0.log > /etc/rsyslog.d/0-swift.conf'
  sudo bash -c 'echo local1.* /var/log/swift/all1.log > /etc/rsyslog.d/1-swift.conf'
  sudo bash -c 'echo local2.* /var/log/swift/all2.log > /etc/rsyslog.d/2-swift.conf'

  # cat /etc/rsyslog.d/0-swift.conf /etc/rsyslog.d/1-swift.conf /etc/rsyslog.d/2-swift.conf

  sudo mkdir /var/log/swift

  sudo chown -R syslog.adm /var/log/swift
  sudo chmod -R g+w /var/log/swift

  sudo systemctl restart rsyslog
  sudo systemctl enable rsyslog
} &>> $dir/log_files.log
echo -ne 'Rebalance Builders and Create Logger [#######################](100%)\r'
echo -ne '\n'

echo "Setup is done. you can start the proxy server after reboot"
sleep 1
echo "CHANGE ACCOUNT, CONTAINER AND OBJECT SERVER PORTS/IPS BEFORE PROCEEDING WITH AUTHENTICATION"
sleep 1
x=0
for n in {1..50}
do
  # echo $n
  if (( $x == 0 ))
  then
    echo -ne 'Finalizing Setup: | \r'
    sleep 0.2
    x=1
  elif (( $x == 1 ))
  then
    echo -ne 'Finalizing Setup: / \r'
    sleep 0.2
    x=2
  elif (( $x == 2 ))
  then
    echo -ne 'Finalizing Setup: _ \r'
    sleep 0.2
    x=3
  elif (( $x == 3 ))
  then
    echo -ne 'Finalizing Setup: \ \r'
    sleep 0.2
    x=0
  else
    echo -ne 'X \r'
    sleep 0.2
  fi
done
sudo chmod 755 $dir/log_files.log
for n in {1..20}
do
  # echo $n
  if (( $n % 2 == 0 ))
  then
    echo -ne '!!REBOOT IN PROGRESS!!\r'
    sleep 0.2
  else
    echo -ne '                       \r'
    sleep 0.2
  fi
done

sudo reboot
