'''
Created on Sep 15, 2011

@author: Haruka
'''
import time
import lxml
from lxml import html
import urllib2
import re
import sys
import string

weekurl= "http://scores.espn.go.com/nfl/scoreboard?seasonYear={0}&seasonType={1}&weekNumber={2}"
gameurl = "http://scores.espn.go.com/nfl/playbyplay?gameId={0}&period=0"

gamesRE = re.compile('(\d{9})-gameLinks')
def valid_years(current_year):
    for year in xrange(2010, current_year+1):
        yield year
        
def season_type():
    for season in xrange(2, 4):
        yield season

def week_counter():
    # flags [regular, post, end]
    flags = [True, False, False]
    counter = 0
    while(not flags[-1]):
        last = 6 if flags[2] else 18    
        for week in xrange(1, last):
            yield week
        flags[counter] = False
        counter += 1
        flags[counter] = True        

def grab_games(page):
    games = []
    try:
        response = urllib2.urlopen(page)
        data = response.read()
        gameIDs = gamesRE.findall(data)
        for gameID in gameIDs:
            game = gameurl.format(gameID) 
            games.append(game)
    except:
        pass
    return games

def extract_plays(table):
    page = []
    for element in table.xpath('.//tr | .//thead'):
        if element.tag == 'thead':
            cell = element.xpath('.//h4')
            if len(cell) > 0:
                page.append([cell[0].text])
        elif element.tag == 'tr':
            line = []
            data_cells = element.xpath('.//td | .//td/span')
            for cell in data_cells:
                data = html.tostring(cell, pretty_print=True).replace('\n','')
                if string.find(data, '&#160') != -1:
                    line.append('_')
                elif cell.text != None :
                    line.append(cell.text)
            page.append(line)
    return page
                    
            

def scrape_game(page): 
    response = urllib2.urlopen(page)
    data = response.read()
    root = html.fromstring(data)
    title = root.xpath("//title")[0]
    title = title.text
    print title
    table= root.xpath("//div[@class=\"mod-content\"]/table")[0]
    playlist = extract_plays(table)
    print playlist
    

def batch_crawl():
    crawl_queue = []
    for year in valid_years(2011):
        for stype in season_type():
            for week_no in week_counter():
                crawl_queue.append(weekurl.format(year, stype, week_no))
    
    for week_page in crawl_queue:
        print week_page
        games = grab_games(week_page)
        for game in games:
            scrape_game(game) 
        time.sleep(2)
        
batch_crawl()





