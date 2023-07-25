#!/bin/bash

set -e
# Return to home folder
cd ~
# Start creating data folders
mkdir ~/data
bash ~/readme.sh && rm -rf ~/readme.sh
# Install tmate on macOS or Ubuntu
echo Setting up tmate...
if [ -x "$(command -v brew)" ]; then
  brew install tmate > /tmp/brew.log
  sudo rm -rf ~/.ssh/id_rsa
fi
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get install -y tmate openssh-client > /tmp/apt-get.log
  sudo rm -rf ~/.ssh/id_rsa
fi

# Generate ssh key if needed
[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# Run deamonized tmate
echo Running tmate...
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready

# Print connection info
echo -e '\e[1;32m________________________________________________________________________________\e[m'
echo
echo Tmate.io Version:
tmate -V
echo To connect to this session copy-and-paste the following into a terminal:
tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
echo To connect to this session copy-and-paste the following into a browser:
tmate -S /tmp/tmate.sock display -p '#{tmate_web}'
echo After connecting you can run 'touch /tmp/hackpig520' to disable the 5m timeout
echo -e '\e[1;32m________________________________________________________________________________\e[m'

# Wait for connection to close or timeout in 15 min
timeout=$((5*60))
while [ -S /tmp/tmate.sock ]; do
  sleep 5
  timeout=$(($timeout-5))
  echo -e '\e[1;32m-----------------------------\e[m'
  echo To connect to this session copy-and-paste the following into a terminal:
  tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
  echo After connecting you can run 'touch /tmp/hackpig520' to disable the 5m timeout
  echo -e '\e[1;32m-----------------------------\e[m'

  if [ ! -f /tmp/hackpig520 ]; then
    if (( timeout < 0 )); then
      echo Waiting on tmate connection timed out!
      exit 0
    fi
  fi

  if [ -f /tmp/stop ]; then
      echo User requested to exit!
      exit 0
  fi
done
