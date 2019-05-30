#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = 39
num_chapters = 4

with lite.connect("./%s.sqlite" % book) as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for chapter in range(1, num_chapters+1):
        page = urllib2.urlopen("https://www.bibleonline.ru/bible/rus/%d/%d/" % (book,chapter)).read()
        soup = BeautifulSoup(page, "html.parser")

        div = soup.find(id="biblecont")

        for li in div.find_all("li"):
            verse =  li['value']

            print "%d:%d" % ( int(chapter), int(verse))
            print li.getText()

            cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), li.getText()))
