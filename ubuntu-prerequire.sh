#!/bin/bash

wget http://10.38.13.197/ubuntu_wily_sgmii.tgz
tar xvf ubuntu_wily_sgmii.tgz -C ~/
cd ~/ubuntu_wily_sgmii
dpkg -i --force-all *.deb


