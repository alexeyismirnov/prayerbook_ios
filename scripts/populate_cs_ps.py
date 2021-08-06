#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup
from collections import OrderedDict

book = "Ps"
chapters = "143-150"
kafisma = 20

with lite.connect("./%s_cs.sqlite" % book.lower()) as con:
    cur = con.cursor()
    # cur.execute("DROP TABLE IF EXISTS scripture")
    # cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    page = urllib2.urlopen("https://azbyka.ru/biblia/?%s.%s&utfcs" % (book,chapters)).read()
    soup = BeautifulSoup(page, "html.parser")

    content = OrderedDict()

    for div in soup.find_all("div", {"data-lang":"utfcs"}):
        verse =  div['data-line']
        chapter = div['data-chapter']

        if int(verse) == 0:
            continue

        print "%d:%d" % ( int(chapter), int(verse))

        content.setdefault(chapter,[]).append(' '.join(div.getText().split()).encode('utf-8'))

    for key, value in content.items():
        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(kafisma), int(key), ' '.join(value)))
