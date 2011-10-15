# -*- coding: utf-8 -*-
import sys
import re
from datetime import datetime, timedelta
from time import strptime

"""
下記のような文字列を標準入力から読み込み
[{'td': 29.0, 'time': '2011-10-15 20:35', 'title': 'hogjkdsm'}
{'td': 90.0, 'time': '2011-10-15 21:4', 'title': 'kj'}
{'td': None, 'time': '2011-10-15 22:34', 'title': 'AU'}]
のようなリストを作る


*** hogjkdsm[2011-10-15 20:35]
kmdskajf
duba
*** JKJD
*** kj[2011-10-15 21:4]
kj[2011-10-15 22:00]
**
*** AU[2011-10-15 22:34]
"""

def minutes_timedelta(dt_tuple):
    """datetimeオブジェクトのタプルを受け取ってその時間の差分を返す
    param: dt_tuple TUPLE
    return: minutes FLOAT
    """
    delta = dt_tuple[1] - dt_tuple[0]
    return delta.seconds / 60.0

def timedelta_list(dt_list):
    """datetimeオブジェクトのリストを受け取ってその時間の差分のリストを返す
    param: dt_list [DATETIME]
    return: minutes [FLOAT]
    """
    return [minutes_timedelta(dt_tpl)
            for dt_tpl in zip(dt_list, dt_list[1:])]

def str2datatime(time_str):
    """日時の文字列をdatetimeオブジェクトにして返す
    param: time_str STR
    return: dt DATETIME
    """
    year, month, day, hour, minutes = strptime(time_str, '%Y-%m-%d %H:%M')[0:5]
    return datetime(year, month, day, hour, minutes)


def caputure_title_time(lines):
    _logs = []
    p = re.compile('^\*{3}\s+(.*)\[(\d{4}\-\d{1,2}\-\d{1,2}\s\d{1,2}:\d{1,2})]')
    for line in lines:
        m = p.search(line)
        if not m: continue
        _logs.append({'title': m.group(1), 'time': m.group(2)})
    # print _logs
    return _logs

_logs = caputure_title_time(sys.stdin)
dt_list = [str2datatime(l['time']) for l in _logs]
timedelta_list = timedelta_list(dt_list)
timedelta_list.append(None)
logs = [{'title': l['title'], 'time': l['time'], 'td': td}
         for l, td in zip(_logs, timedelta_list)]

for l in logs:
    print l
