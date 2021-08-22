#!/bin/bash

sudo echo ""
sudo touch log_files.log
sudo chmod 777 log_files.log

echo -ne 'Updating Files and installing dependencies [##                     ](5%)\r'
sleep 1
{
  sudo apt update
} &> log_files.log
echo -ne 'Updating Files and installing dependencies [#####                  ](18%)\r'
sleep 1
{
  sudo apt install curl gcc memcached rsync sqlite3 xfsprogs git-core libffi-dev python3-setuptools liberasurecode-dev libssl-dev
} &> log_files.log
echo -ne 'Updating Files and installing dependencies [##########             ](67%)\r'
sleep 1
{
  sudo apt install python3-coverage python3-dev python3-nose python3-xattr python3-eventlet python3-greenlet python3-pastedeploy python3-netifaces python3-pip python3-dnspython python3-mock
} &> log_files.log
echo -ne 'Updating Files and installing dependencies [#######################](100%)\r'
echo -ne '\n'

echo -ne 'Cloning Files & Installing requirements [##                     ](2%)\r'
sleep 1

{
  cd /opt
  sudo git clone https://github.com/openstack/python-swiftclient.git
} &> log_files.log
echo -ne 'Cloning Files & Installing requirements [###                    ](5%)\r'
sleep 1
{
  cd /opt/python-swiftclient; sudo pip3 install -r requirements.txt; python3 setup.py install; cd-
  sudo git clone https://github.com/openstack/swift.git
}&> log_files.log
echo -ne 'Cloning Files & Installing requirements [######                 ](25%)\r'
sleep 3
cd /opt/swift; sudo pip3 install -r requirements.txt; sudo python3 setup.py install; cd -
} &> log_files.log
echo -ne 'Cloning Files & Installing requirements [#######################](100%)\r'
echo -ne '\n'

echo -ne 'Copying .conf files [####                   ](8%)\r'
sleep 1
echo -ne 'Copying .conf files [######                 ](32%)\r'
sleep 1
{
sudo mkdir -p /etc/swift
cd /opt/swift/etc
sudo cp /opt/swift/etcaccount-server.conf-sample /etc/swift/account-server.conf
sudo cp /opt/swift/etccontainer-server.conf-sample /etc/swift/container-server.conf
sudo cp /opt/swift/etcobject-server.conf-sample /etc/swift/object-server.conf
sudo cp /opt/swift/etcproxy-server.conf-sample /etc/swift/proxy-server.conf
sudo cp /opt/swift/etcdrive-audit.conf-sample /etc/swift/drive-audit.conf
sudo cp /opt/swift/etcswift.conf-sample /etc/swift/swift.conf
} &> log_files.log
echo -ne 'Copying .conf files [#######################](100%)\r'
echo -ne '\n'

echo -ne 'Mounting Drives and Creating Startup script [#                      ](1%)\r'
sleep 1

{
  sudo mkfs.xfs -f -L d1 /dev/vda
  sudo mkfs.xfs -f -L d2 /dev/vdb
  sudo mkfs.xfs -f -L d3 /dev/vdc

  sudo mkdir -p /srv/node/d1
  sudo mkdir -p /srv/node/d2
  sudo mkdir -p /srv/node/d3
} &> log_files.log
echo -ne 'Mounting Drives and Creating Startup script [########               ](42%)\r'
sleep 1
{
  sudo useradd swift
  sudo chown -R swift:swift /srv/node

  sudo cp /opt/saio_installer/mount_devices.sh /opt/swift/bin/mount_devices.sh
  sudo cp /opt/saio_installer/start_swift.service /etc/systemd/system/start_swift.service
  sudo chmod +x /opt/swift/bin/mount_devices.sh

  sudo systemctl start start_swift.service
  sudo systemctl enable start_swift.service
  sudo systemctl restart start_swift.service
} &> log_files.log
echo -ne 'Mounting Drives and Creating Startup script [#######################](100%)\r'
echo -ne '\n'

echo "Device Needs Reboot to continue further"
echo -ne './r'
sleep 3

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

sudo touch temp.txt && sudo echo "reboot" >> temp.txt
sudo reboot
