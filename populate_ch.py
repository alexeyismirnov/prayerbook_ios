#!/usr/bin/python
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = 56
chapter = 1

page = urllib2.urlopen("http://www.sbofmhk.org/schi2/sbofm_bible/sbofm_bible_content.php?book=%d&chapter=%d" % (book,chapter)).read()
soup = BeautifulSoup(page, "html.parser")

with lite.connect("./%s.sqlite" % book) as con:

    cur = con.cursor()

    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for tr in soup.find_all("tr"):
        children = tr.find_all("td", recursive=False)
        if len(children) != 3:
            continue

        chapter,verse = children[0].getText().split(":")
        print "%d:%d" % ( int(chapter), int(verse))
        print children[1].getText()

        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), children[1].getText()))
