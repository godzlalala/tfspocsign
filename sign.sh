#!/bin/sh
echo '
	************************************************************
	*****   本脚本只在debian上通过测试 请自行安装python3   *****
	*****            请自行使用pip3安装bs4支持             *****
	*****         本脚本只适用于root用户的VPS使用          *****
	************************************************************
                                            
										
											-Powered by GodZ
'

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
  wget http://looooool-10019530.file.myqcloud.com/python/head.py
fi

if [ ! -f "foot.py" ]; then
  wget http://looooool-10019530.file.myqcloud.com/python/foot.py
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
echo 5 9 1 1 tzselect
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




