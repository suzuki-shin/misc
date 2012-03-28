# -*- coding: utf-8 -*-

# [os.walk] ディレクトリ以下のファイルを再帰的にファイルに吐き出す
import os
target_dir = '/Users/ent-imac/projects/settlement.rd/'
for root, dirs, files in os.walk(target_dir):
  for file in files:
    if '.svn' in root:
      continue
    print os.path.join(root, file)

# [open write close] ファイル書き込み
fh = open('/tmp/hoge', w)               # w:書き込み、a:追記、r:読み込み
fh.write('fugafuga')
fh.close()

# [sys.stdin] 標準入力読み込み
import sys
for line in sys.stdin:
  print line

# [codecs] 標準入出力(sys.stdin, sys.stdout)で用いる文字コードを指定するには(euc_jpで標準入力から読み込みshift_jisで標準出力に出力)
import sys
import codecs
sys.stdin  = codecs.getreader('euc_jp')(sys.stdin)
sys.stdout = codecs.getwriter('shift_jis')(sys.stdout)
for line in sys.stdin: print line,

# tupleのlistと二引数関数を渡すと、それを作用させたリストを返す関数
def apply_tuple_list(fn, tpl_list):
  """tupleのlistと二引数関数を渡すと、それを作用させたリストを返す関数"""
  return [fn(t[0], t[1]) for t in tpl_list]
# 実行例
# >>> apply_tuple_list(lambda x, y: x + y, [(1,2),(1,3),(5,70)])
# [3, 4, 75]

# [datetime time strptime timedelta]
from datetime import datetime
from time import strptime
def get_delta_minutes(time_str0, time_str1):
  """2011-10-12 12:34のような日時の文字列を二つ受け取り、その差分を分で返す"""
  dt0 = datetime(*strptime(time_str0, "%Y-%m-%d %H:%M")[0:5])
  dt1 = datetime(*strptime(time_str1, "%Y-%m-%d %H:%M")[0:5])
  delta = dt1 - dt0
  return delta.seconds / 60.0

# [format unicode]
print "|%(timedelta)s|%(title)s|" % {'timedelta':l['timedelta'], u'title':l['title'], 'time':l['time']}

# [tuple dict zip 内包表記]
# csvファイルを読み込んで、そのデータをヘッダーをキーにしたdictにする
cols = ['sl.status', 'sl.type', 'sl.settlement_type', 'sl.openid']
result = [dict(zip(cols, l.split(','))) for l in file(outputfile)]

# [os.path.getmtime]指定したファイルの更新日時を取得
import os
import time
def get_modified_datetime(path, format_ = '%Y-%m-%d %X'):
  return time.strftime(format_, (time.localtime(os.path.getmtime(path))))

def catfile_at(date, path):
  for root, dirs, files in os.walk(path):
    for f in files:
      fpath = os.path.join(root, f)
      if get_modified_datetime(fpath, '%Y-%m-%d') != date:
        next
      for l in file(
        print l.decode('shift-jis')

# [csv]
import csv
def csvfile2list(csvfile):
  """convert csv file to dictionary
  """
  headers, data, dic = [], [], {}
  for i, line in enumerate(csv.reader(file(csvfile))):
    if i is 0: headers = line
    else:
      for j, col in enumerate(line):
        dic[headers[j]] = col
    data.append(dic)
  return data

# [subprocess] shellコマンド等実行
import subprocess
subprocess.call(['ls', '-l'])

# [requests] urlをGET/POST (ref http://coreblog.org/ats/python-http-module-request)
import requests
r = requests.get('http://www.example.com/')
print r.content
r = requests.post('http://www.example.com/register', {'param1':'foo', 'param2': 'bar'})
print r.content
