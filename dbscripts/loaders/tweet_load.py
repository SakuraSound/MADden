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
import sys

from datetime import datetime

__host = ''
__db = 'madlibdb'
__port = '5432'
__pwd = ''
__user = ''
__table = 'tweets' # REQUIRE: Not included in the db.json file

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
		#__table = d['table']
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
(id, id_str, twuser, twuser_id_str, user_profile_image, \
created_at, twtext, twtextvector) VALUES """ % {'table' : __table}

def __queryb():
	return """ (%(id)s, %(id_str)s, %(twuser)s,\
%(twuser_id_str)s, %(user_profile_image)s, %(created_at)s,\
%(twtext)s, to_tsvector(%(twtextvector)s) ) """


def load(jsonfile):
	f = codecs.open(jsonfile, "r", "utf-8") # The file name is a param
	
	try:
		# print __connect_string % __connect_params
		connection = psycopg2.connect(__connect_string() % __connect_params())
	except:
		print ("Connection to database failed")
		return None

	cursor = connection.cursor()

	count = 1

	# Read each json string line by line	
	for line in f.xreadlines():
		
		# Turn the line into json format
		j = None
		try:
			j = json.loads(line, 'utf-8')
		except ValueError, e:
			continue

		# Don't insert null text
		if "text" not in j or not j["text"]:
			continue
	
		# Don't insert if the tweet contains non-english chars
		for w in j["text"]:
			if not (w >= '\u0000' and w <= '\u03E1' or\
							w >= '\u1E00' and w <= '\u27FF'):
				continue

		# Change the 'created_at' field into an actual datetime
		if 'created_at' in j and j['created_at']:
			created_at = datetime.strptime (j['created_at'], "%a %b %d %H:%M:%S +0000 %Y")
			j['created_at'] = created_at

		# Build query parameters
		d = {}
		d['id'] = j['id']
		d['id_str'] = j['id_str']
		d['twuser'] = j['user']['name']
		d['twuser_id_str'] = j['user']['id_str']
		d['user_profile_image'] = j['user']['profile_image_url_https']
		d['created_at'] = j['created_at']
		d['twtext'] = j['text']	
		d['twtextvector'] = j['text']	

		#print d['id']
		#print d['id_str']
		#print d['twuser']
		#print d['twuser_id_str']
		#print d['user_profile_image']
		#print d['created_at']
		#print d['twtext']
		
		# Perform the insertion
		q = "%s %s;" % (__querya(), __queryb())
		#print q % 
		#pairs = zip(d.keys(), d.values())
		#pirint pairs
		try:
			cursor.execute(q, d)
			connection.commit()
		except psycopg2.IntegrityError, e:
			cursor = connection.cursor()
			connection.rollback()
			print "ERROR:", e, j['id'], j['text']
			continue

		if count % 1000 == 0 or count == 1:
			print count, '|',
		count += 1

	f.close()


if __name__ == '__main__':
	import pdb
	#pdb.set_trace()
	if len(sys.argv) <= 1 or not os.path.isfile(sys.argv[1]):
		print "Usage: python tweet_load.py <file.json>"
		print "The file must not end with a separator"
		print "A db.json file must exist in the local path"
	else:
		configured = configdb() # Add the database stuff 
		if configured:
			print load(sys.argv[1])
		else:
			print 'Error did not load'

