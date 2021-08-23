#!/bin/bash
# bash $dir/mount_devices.sh
sudo echo ""
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

} &> /dev/null
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
} &> /dev/null
echo -ne 'Creating Builder files and adding devices [##########             ](45%)\r'
sleep 1
{
  # echo Adding device 1...
  sudo swift-ring-builder account.builder add r1z3-127.0.0.3:6002/d3 100
  sudo swift-ring-builder container.builder add r1z3-127.0.0.3:6001/d3 100
  sudo swift-ring-builder object.builder add r1z3-127.0.0.3:6000/d3 100
  sudo swift-ring-builder object-1.builder add r1z3-127.0.0.3:6000/d3 100
  sudo swift-ring-builder object-2.builder add r1z3-127.0.0.3:6000/d3 100
} &> /dev/null
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
} &> /dev/null
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
} &> /dev/null
echo -ne 'Rebalance Builders and Create Logger [#######################](100%)\r'
echo -ne '\n'

echo "Setup is done. you can start the proxy server"
sleep 1
echo "CHANGE ACCOUNT, CONTAINER AND OBJECT SERVER IPS BEFORE PROCEEDING WITH AUTHENTICATION"
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

sudo rm temp.txt
sudo reboot
