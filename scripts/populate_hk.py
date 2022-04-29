#!/usr/bin/python
# -*- coding: utf-8 -*-
import sqlite3 as lite
import urllib2
import re
from bs4 import BeautifulSoup

import sys
reload(sys)
sys.setdefaultencoding("utf-8")

book = 84
num_chapters = 22

with lite.connect("./%s.sqlite" % book) as con:

    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for chapter in range(1, num_chapters+1):
        page = urllib2.urlopen("http://www.sbofmhk.org/pub/body/cpray/c1_online_bible/sbbible/sbofm_bible_content.php?book=%d&chapter=%d" % (book,chapter)).read()
        soup = BeautifulSoup(page, "html.parser")

        for tr in soup.find_all("tr"):
            children = tr.find_all("td", recursive=False)

            if len(children) != 3 or len(children[0].getText()) == 0:
                continue

            m = re.search("(\d+):(\d+)", children[0].getText())
            if m is None:
                continue

            # print children[0].getText()

            #chapter = 1
            #verse = children[0].getText().split(":")[0]
            chapter,verse = children[0].getText().split(":")

            verse = verse.split("-")[0]
            verse = verse.split(",")[0]
            verse = verse.split("、")[0]
            verse = re.sub(r'[a-z]+', '', verse)

            print "%d:%d" % ( int(chapter), int(verse))
            print children[1].getText()

            cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), children[1].getText()))
