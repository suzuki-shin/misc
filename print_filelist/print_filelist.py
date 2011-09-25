# -*- coding: utf-8 -*-
import os
import filelist_conf

fh = open(filelist_conf.target_dir + filelist_conf.filename, 'w')
for root, dirs, files in os.walk(filelist_conf.target_dir):
 for file in files:
   if '.svn' in root:
     continue
   fh.write(os.path.join(root, file) + "\n")
fh.close()
