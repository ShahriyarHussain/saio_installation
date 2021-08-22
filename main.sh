#!/bin/bash

if [ `cat temp.txt | tail -1` == "reboot" ]
then
  bash part2.sh
else bash part1.sh
fi
