#!/bin/bash

sudo yum install yum-utils -y
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo yum install gh -y
gh --version
