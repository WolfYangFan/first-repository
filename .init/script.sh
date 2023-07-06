#!/bin/bash

set -e

# Start creating work folders
mkdir ~/work 
cat << EOF > ~/README
您正在使用 HackPig520 提供的免费 Linux 服务器，基于 Github Actions
---
你可以创建、修改、删除文件，运行可执行文件或者使用各种CLI
想要测试网速？键入以下命令
 $ speedtest
想要编译源代码？系统预装了 Java Python Golang 语言工具，可开箱即用！
想要持续连接服务器？创建空文件 '/tmp/hackpig520' 以禁用 5 分钟免费时长限制
---
Using it for harmful purposes is extremely forbidden.
Our team & company is not responsible for its’ usages and consequences.
EOF

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
      echo Active exit!
      exit 0
  fi
done
