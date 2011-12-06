#! /usr/bin/python

# This file reads txt files of blogs and puts them in the blog table (hopefully)
# author @mhb

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
__table = 'blogs' # REQUIRED: Not included in the db.json file

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

	blags = os.listdir(directory)
        #blags should be a 30k+ list of .txt files

	for blag in blags:
		print blag

                # open file

                # read first line
		# extract teamAbbr
                # maybe insert in a subtable based on this team identifier???

                # read Second line
                # extract year
                # extract month
		# extract day

                # read third line
                # extract article title

                # read fourth line
                # extract article text

                # read fifth line
                # extract comments, if any.
                # if there are, they are all on the same line, no matter how many there are.
                # if there are not, maybe insert NULL???


                try: #try to connect to db???
			# print __connect_string % __connect_params
			connection = psycopg2.connect(__connect_string() % __connect_params())
		except:
			print ("Connection to database failed")
			return None

                # I don't know what is going on anymore.

		cursor = connection.cursor()


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
		print "Usage: python blagload.py dir-with-txt"
	else:
		configured = configdb() # Add the database config
		if configured:
			print load(sys.argv[1])
		else:
			'Error  did not load'


