#! /usr/bin/python

# This file reads JSON tweet files line by line to insert the tweets into the
# tweet table
# author @cegme

import codecs
import datetime
import json
import os
import psycopg2
import string
import re
import sys

#from datetime import datetime

__host = ''
__db = 'madlibdb'
__port = '5432'
__pwd = ''
__user = ''
__table = 'nflrecap' # REQUIRED: Not included in the db.json file

def configdb():
	global __host
	global __db
	global __port
	global __pwd
	global __user
	try:
		d = json.load(open('db.json'))
		__host = d['host']
		__db = d['db']
		__port = d['port']
		__pwd = d['pwd']
		__user = d['user']
		return True
	except:
		print 'Error in your db.json file. Because it is in the local directory',
		print ', you use double quotes.'
		print 'Exiting...'
		sys.exit()

def __connect_string():
	return "dbname='%(db)s' user='%(user)s' host='%(server)s'\
	password='%(pwd)s' port='%(port)s'"

def __connect_params():
	return {'server': __host,\
			'user': __user,\
			'pwd': __pwd,\
			'port': __port,\
			'db': __db\
		}

def __querya():
	return """INSERT INTO %(table)s \
	(gamedate, team1, team2, fileloc, recap) \
	VALUES """ % {'table': __table}

def __queryb():
	return """ (%(gamedate)s, %(team1)s, %(team2)s, %(fileloc)s, %(recap)s) """ 


def load(directory):
	
	years = os.listdir(directory)

	# Check that these are all digits
	#assert(all([string.digits.find(y)!=-1 for y in year for year in years ]))
	
	p = re.compile(r"""NFL_(\w{8})_(\w{2,3})@(\w{2,3}).txt""")

	for year in years:
		print year
		
		cwd = "%s%s%s" % (directory, os.sep, year)

		# Get each file in the directory
		games = [x for x in os.walk(cwd)][0][2]

		for gamefilename in games:
			
			m = p.match(gamefilename) # Will group into a triple (day, team1, team2)

			date = m.group(1) # Get the full date

			# extract month
			month = date[4:6]	

			# extract day
			day = date[6:8]

			# extract team1
			team1 = m.group(2)	

			# extract team2
			team2 = m.group(3)	
	
			# Process game files	add rows
			gamefile = "%s%s%s" % (cwd, os.sep, gamefilename)
			print gamefile
			f = codecs.open(gamefile, "r", "utf-8") # The file name is a param
			
			try:
				# print __connect_string % __connect_params
				connection = psycopg2.connect(__connect_string() % __connect_params())
			except:
				print ("Connection to database failed")
				return None

			cursor = connection.cursor()

			plays = [] # Each of these lines wil contain play values to be inserted

			# Read each json string line by line	
			for line in f.xreadlines(): 
				# print "LINE:", line

				# We skip blank lines
				if not line or line.strip() == '':
					continue
				
				# print year, month, day
				the_date = datetime.date(int(year), int(month), int(day))
				print gamefile
				play = { 'gamedate': the_date,
						'team1': team1,
						'team2': team2,
						'fileloc': "%s%s%s" % (year, os.sep, gamefilename),
						'recap': line
						}
				plays.extend([play]) # Add this play to the list of values
				
			if len(plays): # if it is not empty
					
				# Create the query
				q = "%s %s;" % (__querya(), __queryb())
				# Perform the insertion across all the vectors
				try:
					cursor.executemany(q, plays)
					connection.commit()
				except psycopg2.IntegrityError, e:
					cursor = connection.cursor()
					connection.rollback()
					print "ERROR:", e, j['id'], j['text']
					continue
					
			f.close()
	connection.close()


if __name__ == '__main__':
	if len(sys.argv) <= 1 or not os.path.exists(sys.argv[1]):
		print "Usage: python nflrecap_load.py ~/scratch/recaps"
		print "The file must not end with a separator"
		print "A db.json file must exist in the local path"
	else:
		configured = configdb() # Add the database config 
		if configured:
			print load(sys.argv[1])
		else:
			'Error  did not load'


