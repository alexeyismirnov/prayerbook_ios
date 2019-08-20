#!/usr/bin/python
import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = 53
num_chapters = 3

with lite.connect("./%s.sqlite" % book) as con:

    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for chapter in range(1, num_chapters+1):
        page = urllib2.urlopen("http://www.sbofmhk.org/schi2/sbofm_bible/sbofm_bible_content.php?book=%d&chapter=%d" % (book,chapter)).read()
        soup = BeautifulSoup(page, "html.parser")

        for tr in soup.find_all("tr"):
            children = tr.find_all("td", recursive=False)
            if len(children) != 3 or len(children[0].getText()) == 0:
                continue

            pos = children[0].getText()

            if re.match(r'\d+:\d+', pos):
                chapter,verse = pos.split(":")
                verse = re.findall(r'\d+', verse)[0]
            elif re.match(r'\d+', pos):
                verse = re.findall(r'\d+', pos)[0]
            else:
                continue

            print "%d:%d" % ( int(chapter), int(verse))
            print children[1].getText().encode('utf-8')

            cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), children[1].getText()))
