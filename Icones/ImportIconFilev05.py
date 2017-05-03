#!/usr/lib/python
# -*- coding: utf-8 -*-

# Author : Luiz Sales
# Email  : luiz@lsales.biz
# Data   : 30/04/2017

# Altere as Variaves - URL, USR, PWS 

# Como Usar
# python ImportIconFile_v05.py <Arquivo Zip> <Prefix> 
# python ImportIconFile_v05.py    Wer.zip      W3R 

URL = "http:/seu-zabbix.com/"
USR = "Admin"
PWS = "zabbix"

import fnmatch
import os
import sys
import base64
import zipfile
import shutil
from  zabbix_api import *
 
zapi = ZabbixAPI(server= URL )
zapi.login( USR, PWS )

FILE = sys.argv[1]
PRE = sys.argv[2]
base = os.path.basename(os.path.normpath(FILE))

if not os.path.exists('/tmp/' + base):
    os.makedirs('/tmp/' + base )

zip_ref = zipfile.ZipFile(FILE, 'r')
zip_ref.extractall('/tmp/' + base )
zip_ref.close()

images = ['*.png', '*.jpg', '*.jpeg' ]
imgFilesA = []
imgFilesDir = '/tmp/' + base
for root, dirnames, filenames in os.walk(imgFilesDir):
    for extensions in images:
        for filename in fnmatch.filter(filenames, extensions):
            imgFilesA.append(os.path.join(root, filename))


for imgFile in imgFilesA:
	nomet = os.path.basename(os.path.normpath(imgFile))
	nome = ( PRE + '_' + nomet.replace('.png', ' ') )
	imgGet = zapi.image.get({ "output" : "extend", "filter" : { "name" : nome } })
	if imgGet:
		print "Image: " + nome + " already exists"
	else:
		with open(imgFile, "rb") as f:
			data = f.read()
			b64encode = data.encode("base64")
			print "Image: " + nome , 
			zapi.image.create({ "imagetype": 1, "name": nome, "image" : b64encode })
			print "created"

shutil.rmtree('/tmp/' + base )
