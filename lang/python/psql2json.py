# -*- coding: utf-8 -*-
"""
psqlのテーブル表示を標準入力から受け取り、JSONにして出力する
"""

import sys
import json

def psql2list(input):
  data = []
  d = {}
  for l in input:
    if l.startswith('-') or len(l) is 0:
      if len(d) is not 0: data.append(d)
      d = {}
    else:
      try:
        (k, v) = [x.strip() for x in l.split('|')]
        d[k] = v
      except:
        pass
  if len(d) is not 0: data.append(d)

  return data

print json.dumps(psql2list(sys.stdin))
