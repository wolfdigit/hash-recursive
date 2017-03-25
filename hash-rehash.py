#!/usr/bin/env python

import sys
import os
import subprocess
import locale
locale.setlocale(locale.LC_COLLATE, 'zh_TW.UTF-8')

if len(sys.argv)<2:
	sys.stderr.write("no argument input!")
	exit()

totalLine = []

def flushTotalLines(d):
	for i in range(d+1):
		if totalLine[i].strip()!='':
			print totalLine[i]
		sys.stdout.flush()
		totalLine[i] = ''

def check(curr, d):
	while len(totalLine)<d+1:
		totalLine.append('')
	retv = ('', 0)
	if os.path.isdir(curr):
		if not curr.endswith('/'):
			curr = curr+'/'
		totalSize = 0
		totalLine[d] = ''
		entrys = [f for f in os.listdir(curr) if not f.startswith('.')]
		#entrys.sort(key=lambda x: x.strip())
		entrys.sort(key=locale.strxfrm)
		for entry in entrys:
			(l,s) = check(os.path.join(curr,entry), d+1)
			totalSize = totalSize + s
			if totalSize>=4294967296L:
				if totalLine[d].strip()!='':
					flushTotalLines(d)
				if l.strip()!='':
					print l
					sys.stdout.flush()
			else:
				if totalLine[d].strip()!='':
					if l.strip()!='':
						totalLine[d] = totalLine[d]+'\n'+l
					else:
						totalLine[d] = totalLine[d]
				else:
					totalLine[d] = l
		if totalLine[d].strip()!='':
			#sys.stderr.write("["+totalLine[d]+"]"+'\n')
			p = subprocess.Popen("md5sum -b | awk '{ print $1 }'", stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
			md5 = p.communicate(input=totalLine[d]+'\n')[0].strip()
			retv = (md5+'\t'+str(totalSize)+'\t'+curr, totalSize)
		else:
			retv = ('', totalSize)
	else:
		size = os.path.getsize(curr)
		if size<10485760:
			md5 = subprocess.check_output('md5sum -b "'+curr+'" | awk \'{ print $1 }\'', shell=True).strip()
		else:
			md5 = subprocess.check_output('pv -c -N "'+curr+'" "'+curr+'" | md5sum -b | awk \'{ print $1 }\'', shell=True).strip()
		retv = (md5+'\t'+str(size)+'\t'+curr, size)
	return retv

curr = sys.argv[1]
print check(curr, 0)[0]
