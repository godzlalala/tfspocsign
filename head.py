# -*- coding: utf-8 -*-
import urllib
import binascii
import json
import random
import string
import ssl
import http
import http.cookiejar
import re
import time
import os
import bs4
import io
import sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')
from bs4 import BeautifulSoup
from urllib.parse import urljoin
ssl.create_default_context = 'ssl._create_unverified_context'
class urphelper:
    def __init__(self):
        self.dbgmode = False
        self.url_base = 'http://spoc.tfswufe.edu.cn/'
        self.url_urpbase = 'http://urp.tf-swufe.net:8080/'
        self.url_signinHost = urljoin(self.url_base, '/XueGong/signin/index')
        self.url_signin = urljoin(self.url_base, '/XueGong/Signin/Signin')
        self.url_SigninRecordList = urljoin(self.url_base, '/XueGong/Signin/SigninRecordList')
        self.url_code = urljoin(self.url_urpbase , '/cas/code/code.jsp')
        self.url_login = urljoin(self.url_urpbase , '/cas/login?service=http://spoc.tfswufe.edu.cn/Home/Login')
        self.url_logout = urljoin(self.url_urpbase , '/cas/logout?service=http://spoc.tfswufe.edu.cn/Home/exitlogin')
        self.url_validationCode = urljoin(self.url_urpbase , '/cas/code/validationCode.jsp')
        self.name = ''
        self.note = ''
        self.cookie = http.cookiejar.MozillaCookieJar('/root/cookies/cookie.txt')
        self.cookie.clear()
        self.hcp = urllib.request.HTTPCookieProcessor(self.cookie)
        self.opener = urllib.request.build_opener(self.hcp)
        self.hcp.cookiejar.clear()
        self.opener.addheaders = [('User-agent', 'Mozilla/5.0')]
    def saveCookie(self):
        self.cookie.save(ignore_discard=True, ignore_expires=True)
        pass
    def loadCookie(self):
        try:
            self.cookie.load(ignore_discard=True, ignore_expires=True)
        except Exception as ex:
            self.saveCookie()
            pass
    def refetchSession(self):
        self.cookie.clear()
        self.hcp.cookiejar.clear()
        self.httpget(self.url_base)
    def fetchCode(self):
        return self.httpget(self.url_code).read()
    def validationCode(self,code='1234'):
        return json.loads(self.httpget(self.url_validationCode,get = {'code' : code}).read().decode())
    def login(self,username,password,code='1234',lt='e1s1'):
        post_form = {   
                    'username':username,
                    'password':password,
                    'code':code,##unused
                    'lt':lt,##unused
                    '_eventId':'submit',
        }
        print('[Log in] usr:%s ' % username,)
        login_resp = self.httpget(self.url_login ,post = post_form)
    def signin(self,signinTaskId):
        print('[Sign in] signinTaskId:%s' % signinTaskId)
        resp = self.httpget(self.url_signin, post = {'signinTaskId':signinTaskId})
        ##status
        ##signinway
        ##address
        ##ipaddress
        return json.loads(resp.read().decode())
    def getName(self):
        resp = self.httpget(self.url_base)
        self.name = re.search(r'<span class="username">(.*?)</span>', resp.read().decode(), re.IGNORECASE).group(1)
        return self.name
    def getNote(self):
        resp = self.httpget(self.url_signinHost)
        htm = re.search(r'<div class="note note-.*?">([\s\S]*?)</div>', resp.read().decode(), re.IGNORECASE).group(1)        
        self.note = BeautifulSoup(htm,"html.parser").text

        return self.note.encode("gbk","replace").decode("gbk")
    def getSigninRecordList(self,pageIndex=1):
        SigninRecordList = ''

        resp = self.httpget(self.url_SigninRecordList, get = {'pageIndex':str(pageIndex)})
        SigninRecordList = BeautifulSoup(resp.read().decode(),"html.parser").text
        
        return SigninRecordList
    def getSigninTaskId(self):
        try :
            resp = self.httpget(self.url_signinHost)
            signintaskid = re.search(r'signintaskid="(.*?)"', resp.read().decode(), re.IGNORECASE).group(1)    
        except :
            signintaskid = '无法获取'
        return signintaskid
    def logout(self):
        print('[Log out]')
        resp = self.httpget(self.url_logout)
    def isLoginPass(self):
        resp = self.httpget(self.url_base)
        return resp.url == self.url_base
    def httpget(self,url,get={},post={}):
        
        if get != {}:
            url = urljoin(url,'?' + urllib.parse.urlencode(get))
        if post == {}:
            resp = self.opener.open(urllib.request.Request(url))
        else:
            resp = self.opener.open(urllib.request.Request(url,urllib.parse.urlencode(post).encode()))

        if self.dbgmode == True:
            try:
                if os.path.exists('urphelper_dbg') == False:
                    os.mkdir('urphelper_dbg')
                fp = open('./urphelper_dbg/' + str(int(time.time())) + '.htm' ,'wb')
                fp.write(('<!-- url:' + url + ' -->\n').encode())
                fp.close()
            except:
                pass
        return resp



def foobar(userid):
    url = 'http://portal.tf-swufe.net/PassWord/getPass.jsp'
    hcp = urllib.request.HTTPCookieProcessor()
    hcp.cookiejar.clear()
    opener = urllib.request.build_opener(hcp)
    resp = opener.open(urllib.request.Request(url,urllib.parse.urlencode({'userid':userid}).encode()))
    htm_doc = resp.read().decode(encoding = 'gbk')

    userMail = re.search(r'userMail=(.*?);', htm_doc, re.IGNORECASE).group(1)
    return userMail


def foo():
    try:
        urp = urphelper()
        urp.dbgmode = False
        urp.loadCookie()

        if urp.isLoginPass() == False:
            print('[Session Failure] 重新登陆')
            urp.refetchSession()

