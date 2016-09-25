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
 pyinstall
fi
#如果没有就执行安装pip3 python3 bs4的程序

#对所需文件夹判断是否存在，如果不存在则创建文件夹
#将python和bash文件分别存放，便于管理
if [ ! -d "python" ]; then
  mkdir python
fi

if [ ! -d "bash" ]; then
  mkdir bash
fi
#

#所需配置文件是否存在，如果不存在则从服务器上获取

if [ ! -f "head.py" ]; then
  wget https://raw.githubusercontent.com/godzlalala/tfspocsign/master/head.py
fi

if [ ! -f "foot.py" ]; then
  wget https://raw.githubusercontent.com/godzlalala/tfspocsign/master/foot.py
fi
#

#生成签到使用的python文件
read -p '输入名字: ' Name;
read -p '输入学号: ' user;
read -p '输入密码: ' passwd;
cp head.py temp.py
echo '
            username ='"'$user'"'
            userpw ='"'$passwd'"'
' >> temp.py

cat temp.py foot.py >> /root/python/$user.py
#生成完毕

#修改系统时区，保证签到计划在正确的时间执行
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 5 9 1 1 tzselect <<EOF
5
9
1
1
EOF

sleep 2
hwclock -w
date
echo '请确认以下时间为正确时间，如果不正确，请手动修改。'
#


#创建用于执行py脚本的bash文件，执行之后删除cookies并将结果写入rs.log，脚本名以名字命名。
echo '
#!/bin/bash
echo "'*****************$Name 签到开始*************************'" >> rs.log
re=`'python3 /root/python/$user.py'`
rm -rf cookie.txt
echo "$re" >> /root/rs.log
echo "'*****************$Name 签到结束*************************'" >> rs.log
' >> /root/bash/$Name.bash
chmod 777 /root/bash/$Name.bash
rm -rf temp.py  
#创建之后赋予777权限并删除临时文件




#添加bash计划任务。每日定时执行
read -p '请输入执行时间（分）： ' m;
read -p '请输入执行时间（时）： ' h;
echo $m $h '* * *' /root/bash/$Name.bash >> /var/spool/cron/crontabs/root
service cron restart
#计划任务添加完毕

echo '签到完成之后，结果会在root目录下的rs.log文件里面，请及时查看'


function pyinstall(){
  apt-get install python3 python3-pip -y
  ln -s /usr/bin/pip-3.2 /usr/bin/pip3
  pip3 install bs4
  echo '
  因为各个系统环境的不同，安装不一定成功，请检查是否安装成功
  如果不成功，请手动安装python3 pip3 以及bs4依赖
  '


}

