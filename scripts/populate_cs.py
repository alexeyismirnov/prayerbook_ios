#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = "Apok"
num_chapters = 22

with lite.connect("./%s_cs.sqlite" % book.lower()) as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for chapter in range(1, num_chapters+1):
        page = urllib2.urlopen("https://azbyka.ru/biblia/?%s.%d&utfcs" % (book,chapter)).read()
        soup = BeautifulSoup(page, "html.parser")

        for div in soup.find_all("div", {"data-lang":"utfcs"}):
            verse =  div['data-line']

            print "%d:%d" % ( int(chapter), int(verse))

            content = ' '.join(div.getText().split()).encode('utf-8')
            print content

            cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), content))
