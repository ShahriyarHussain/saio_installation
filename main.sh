#!/bin/bash

if [ `cat temp.txt | tail -1` == "reboot" ]
then
  sudo bash part2.sh
else sudo bash part1.sh
fi
