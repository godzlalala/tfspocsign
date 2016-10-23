#!/bin/sh
echo '
	************************************************************
	*****                                                  *****
	*****            本脚本只在debian上通过测试            *****
	*****        本脚本只适用于root用户的VPS 独服使用      *****
	*****                                                  *****
	************************************************************
                                            
										
											-Powered by GodZ
'



apt-get update

#判断是否有python3
if [ ! -d "/etc/python3" ]; then
  apt-get install python3 python3-pip -y
  ln -s /usr/bin/pip-3.2 /usr/bin/pip3
  pip3 install bs4
  echo '因为各个系统环境的不同，安装不一定成功
  请检查是否安装成功如果不成功，请手动安装python3 pip3 以及bs4依赖'
fi

#如果没有就执行安装pip3 python3 bs4

#对所需文件夹判断是否存在，如果不存在则创建文件夹
#将python和bash文件分别存放，便于管理
if [ ! -d "python" ]; then
  mkdir python
fi

if [ ! -d "bash" ]; then
  mkdir bash
fi

if [ ! -d "cookies" ]; then
  mkdir cookies
fi
#

#所需配置文件是否存在，如果不存在则从服务器上获取

if [ ! -f "head.py" ]; then
  wget --no-check-certificate https://raw.githubusercontent.com/godzlalala/tfspocsign/master/head.py
fi

if [ ! -f "foot.py" ]; then
  wget --no-check-certificate https://raw.githubusercontent.com/godzlalala/tfspocsign/master/foot.py
fi
#

#修改系统时区，保证签到计划在正确的时间执行
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
tzselect <<EOF
5
9
1
1
EOF
sleep 2
hwclock -w
date
echo '请确认以下时间为正确时间，如果不正确，请手动修改。'
sleep 5
#

wget --no-check-certificate https://raw.githubusercontent.com/godzlalala/tfspocsign/master/add
chmod +x add
./add
