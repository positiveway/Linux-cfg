#!/usr/bin/env bash

sudo apt-get update --fix-missing
sudo apt-get install -f
sudo apt-get update
sudo dpkg --configure -a
sudo apt-get clean
sudo apt-get update
