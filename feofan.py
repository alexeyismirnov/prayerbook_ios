#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup
from unicodedata import name

pat = re.compile(r'\s+', re.UNICODE)

def feofan(cur, num, id=""):
    page = urllib2.urlopen("https://azbyka.ru/otechnik/Feofan_Zatvornik/mysli-na-kazhdyj-den-goda-po-tserkovnym-chtenijam-iz-slova-bozhija/%d" % num).read()
    soup = BeautifulSoup(page, "html.parser")

    [s.extract() for s in soup('sup')]

    h2 = soup.find("h2")

    if h2 is not None:
        pericope = h2.getText().strip().replace("(", "").replace(")","")
        id = pat.sub('',pericope).replace(';','')
        descr = h2.find_next_sibling('div').getText().replace("\"", "")

    else:
        id = num
        h1 = soup.find("h1")
        descr = h1.find_next_sibling('div').getText()

    descr = pat.sub(' ', descr).strip()

    print num , id
    # print descr

    cur.execute("INSERT INTO thoughts VALUES(\"%s\", \"%s\")" % (id, descr))


with lite.connect("./feofan.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS thoughts")
    cur.execute("CREATE TABLE thoughts(id TEXT, descr TEXT)")

    for num in range(1,354):
        feofan(cur, num)
