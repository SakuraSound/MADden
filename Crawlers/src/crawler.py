'''
Created on Oct 4, 2011

@author: Joir-dan on Hanabi
'''

import urllib2
import re
import lxml, lxml.html as html
import time
import os
from os import path
from datetime import date

class info_base():
    def __init__(self, year):
        self.year = year
    
    def change_year(self, year):
        self.year = year
        self.__init__(year)

class cbs_info(info_base): 
    def __init__(self, year):
        info_base.__init__(self, year)
        self.pbp_base = "http://www.cbssports.com/nfl/gametracker/playbyplay/{0}"
        self.recap_base = "http://www.cbssports.com/nfl/gametracker/recap/{0}"
        self.custscore_base = "http://www.cbssports.com/nfl/scoreboard/{0}/{1}"
        self.score_base = "http://www.cbssports.com/nfl/scoreboard/"
    
    def get_custom_board(self):
        return self.__current_week
    
class espn_info(info_base):
    def __init__(self, year):
        info_base.__init__(self, year)
        self.__blog_base = "http://espn.go.com/blog/{0}/index/_/count/{1}"
        

def folder_check(fpath, year):
    folder = "{0}/{1}".format(fpath, year)
    if not ( path.exists(folder) or path.isdir(folder)): # If the path doesn't exist and isn't a directory
        os.mkdir(folder)
    
def printlist(printlist, filename):
    with open(filename, 'w') as printfile:
        for line in printlist:
            print >>printfile, line

def cbs_recap_scrape(cbs_obj, game):
    response = urllib2.urlopen(cbs_obj.recap_base.format(game))
    root = html.fromstring(response.read())
    story_div = root.xpath("//div[@class = 'story-body']/*")
    recap = []
    for paragraph in story_div:
        ret = " ".join(re.sub("<.*?>", "", html.tostring(paragraph)).split())
        print ret
        recap.append(ret)
    return recap


def cbs_playbyplay_drive(row):
    #print html.tostring(row)
    ret =  re.search("(?<=<b>)[\w\s\.():\-,&#;]+" , html.tostring(row)).group(0).replace("&#160;", "")
    print ret
    return ret
    
def cbs_playbyplay_team(row):
    ret = ": ".join(["Possession Change", cbs_playbyplay_drive(row)])
    print ret
    return ret

def cbs_playbyplay_kick(row):
    rowstring =  html.tostring(row)
    #print rowstring
    emph = ">"
    if re.match("<b>", rowstring): # Someone scored on this play
        emph = "<b>"
    elif re.match("<i>", rowstring): # There was a penalty on the play
        emph = "<i>"
    ret = re.search("(?<={0})[\w\s\.():\-,]+".format(emph), rowstring)
    ret = "Preparing for Kickoff" if ret == None else ret.group(0)
    print ret
    return ret if emph == ">" else ": ".join(["SCORE PLAY", ret]) if emph =="<b>" else ": ".join(["PENALTY", ret])

def cbs_playbyplay_play(row):
    #print html.tostring(row)
    cells = row.xpath("td")
    emph = ">"
    txt = []
    for cell in cells:
        celltxt = html.tostring(cell)
        if re.match("<b>" ,celltxt):
            emph = "<b>"
        elif re.match("<i>", celltxt):
            emph = "<i>"
        ret = re.search("(?<={0})[\w\s\.():\-,\[\]&;*]+".format(emph), html.tostring(cell)).group(0)
        txt.append(ret if emph == ">" else ": ".join(["SCORE PLAY", ret]) if emph == "<b>" else ": ".join(["PENALTY", ret]))
    ret = " -> ".join(txt)
    ret = ret.replace("&", "END OF GAME")
    print ret
    return ret



def cbs_playbyplay_scrape(cbs_obj, game):
    options = {"drive": cbs_playbyplay_drive, "home": cbs_playbyplay_team, "away": cbs_playbyplay_team
               ,"kick": cbs_playbyplay_kick, "play":cbs_playbyplay_play}
    response = urllib2.urlopen(cbs_obj.pbp_base.format(game))
    root = html.fromstring(response.read())
    table = root.xpath("//table[@class='data']/*")
    plays = []
    for row in table:
        plays.append(options[row.attrib["id"]](row))
    return plays



def cbs_week_crawl(cbs_obj, week, year = False):
    if not year:
        response = urllib2.urlopen(cbs_obj.score_base + week) 
    else:
        response = urllib2.urlopen(cbs_obj.custscorebase.format(cbs_obj.year, week))
    games = re.findall("recap/(NFL_[0-9]{8}_[A-Z]{2,3}@[A-Z]{2,3})", response.read())
    for game in games:
        plays = cbs_playbyplay_scrape(cbs_obj, game)
        folder_check("NFL/gamepbps", str(cbs_obj.year))
        printlist(plays, "NFL/gamepbps/{0}/{1}.txt".format(cbs_obj.year, game))
        recap = cbs_recap_scrape(cbs_obj, game)
        folder_check("NFL/recaps", str(cbs_obj.year))
        printlist(recap, "NFL/recaps/{0}/{1}.txt".format(cbs_obj.year, game))
        time.sleep(.5)
    time.sleep(.5)

def cbs_crawl_all(cbs_obj, year = False):
    if not year:
        response = urllib2.urlopen(cbs_obj.score_base)
        weeks = re.findall("/nfl/scoreboard/([\w/]+)\"", response.read())
        weeks.extend(["week"+str(x) for x in range(18, 23)])
    else:
        print "url", cbs_obj.custscore_base.format(cbs_obj.year, "")
        response = urllib2.urlopen(cbs_obj.custscore_base.format(cbs_obj.year, ""))
        raw_input("Press Enter to continue execution")
        weeks = re.findall("/nfl/scoreboard//([\w/]+)\"", response.read())
        weeks = ["/".join([str(cbs_obj.year), x]) for x in weeks]
        weeks.extend(["/".join([str(cbs_obj.year), "week"+str(x)]) for x in range(18, 23)])
    print weeks
    raw_input("Press Enter to continue execution")
    for week in weeks:
        cbs_week_crawl(cbs_obj, week)

def cbs_crawl(cbs_obj, year = False, isPreseason = False, week = None ):
    if not year: # We are trying to extract everything for the current year
        if week == None:
            cbs_crawl_all(cbs_obj)
        else:
            format_one = "{0}{1}".format("preseason/" if isPreseason else "", "week"+week)
            cbs_week_crawl(cbs_obj, format_one, True)
    else:
        if week == None:
            cbs_crawl_all(cbs_obj, True)
        else:
            format_one = "{0}{1}".format("preseason/" if isPreseason else "", "week"+week)
            cbs_week_crawl(cbs_obj, format_one, True)

def cbs_menu():
    year = raw_input("What year do we want to scrape? (Simply press enter for current year) >>")
    yFlag = False
    if year == "":
        today = date.today()
        print today.month
        raw_input("Press enter to continue")
        year = today.year if today.month >= 8 else today.year - 1
    else:
        year = int(year)
        yFlag = True
    cbs_obj = cbs_info(year)
    week = raw_input("What week are you interested in (integer)? If you want to crawl all, just press ENTER >>")
    if week == "":
        cbs_crawl(cbs_obj, yFlag)
    else:
        week = int(week)
        isPreseason = raw_input("Is this during the preseason? (t/f)>>").lower() == "t"
        cbs_crawl(cbs_obj, yFlag, isPreseason, week)
       
def espn_menu():
    pass

def __main__():
    print "NFL Data crawler"
    options = {"1": cbs_menu, "2": espn_menu}
    choice = raw_input("Enter 1 for CBS data, 2 for ESPN data >>")
    options[choice]()
    
__main__()    