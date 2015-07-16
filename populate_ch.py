#!/usr/bin/python
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = 59
num_chapters = 21

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

            chapter,verse = children[0].getText().split(":")
            verse = verse.split("-")[0]
            print "%d:%d" % ( int(chapter), int(verse))
            print children[1].getText()

            cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), children[1].getText()))
