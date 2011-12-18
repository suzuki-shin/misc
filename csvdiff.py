# -*- coding: utf-8 -*-
import sys
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

def diff_csv(csvfile1, csvfile2):
 data1 = csvfile2list(csvfile1)
 data2 = csvfile2list(csvfile2)
 for l1, l2 in zip(data1, data2):
   if len(l1) != len(l2):
     print "### csv line num not equal %(len1)d, %(len2)d" % {'len1': len(l1), 'len2': len(l2)}
   headers = l1.keys()
   for key in headers:
     if not l1[key] == l2[key]:
       print "### %(e0)s not equal %(e1)s" % {'e0':l1[key], 'e1':l2[key]}

try:
 diff_csv(sys.argv[1], sys.argv[2])
except Exception, inst:
 print type(inst)     # 例外インスタンス
 print inst.args      # .args に記憶されている引数
 print inst           # __str__ で引数を直接出力できる
 exit

if __name__ == "__main__":
 import doctest
 doctest.testmod()
