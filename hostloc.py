#!/usr/bin/env python
# -*- coding: UTF-8 -*-

from urllib import request
from http import cookiejar
import time

account_dict = {
    '0': {'username': 'xxxxx', 'password': 'xxxxx'},
    '1': {'username': 'yyyyy', 'password': 'yyyyy'},
    '2': {'username': 'zzzzz', 'password': 'zzzzz'},
}


def Login(URL, UserData):
    __cookies = ''
    __cookie = cookiejar.CookieJar()
    __handler = request.HTTPCookieProcessor(__cookie)
    __req = request.Request(URL, data=str(UserData).encode('utf-8'))
    request.build_opener(__handler).open(__req)
    for cookie in __cookie:
        __cookies += cookie.name + '=' + cookie.value + ';'
    return __cookies


def GetPage(URL, Header_Cookies):
    __Header = {'Cookie': str(Header_Cookies)}
    __req = request.Request(URL, headers=__Header)
    return request.urlopen(__req).read().decode('utf-8')


def GetCredit(username, password):
    Login_URL = 'https://www.hostloc.com/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1'
    My_Home = 'https://www.hostloc.com/home.php?mod=spacecp&inajax=1'

    user_data = 'username=' + str(username) + '&' + 'password=' + str(password)
    My_Cookies = Login(Login_URL, user_data)

    if '<td>' + str(username) + '</td>' not in GetPage(My_Home, My_Cookies):
        isLogin = False
        print('[%s] Login Fail!' % username)
    else:
        isLogin = True
        print('[%s] Login Success!' % username)

    if isLogin:
        for __x in range(25397, 25410):
            __url = 'https://www.hostloc.com/space-uid-{}.html'.format(__x)
            time.sleep( 10 )
            GetPage(__url, My_Cookies)

if __name__ == '__main__':
    for __i in range(0, len(account_dict)):
        GetCredit(account_dict[str(__i)]['username'], account_dict[str(__i)]['password'])
