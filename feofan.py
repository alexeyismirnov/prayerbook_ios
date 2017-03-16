#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup
from unicodedata import name

pat = re.compile(r'\s+', re.UNICODE)

with lite.connect("./feofan.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS thoughts")
    cur.execute("CREATE TABLE thoughts(id TEXT, descr TEXT)")

    for num in range(1,30):
      page = urllib2.urlopen("https://azbyka.ru/otechnik/Feofan_Zatvornik/mysli-na-kazhdyj-den-goda-po-tserkovnym-chtenijam-iz-slova-bozhija/%d" % num).read()

      soup = BeautifulSoup(page, "html.parser")

      h2 = soup.find("h2")
      pericope = h2.getText().strip().replace("(", "").replace(")","")
      id = pat.sub('',pericope).replace(';','')

      print pericope

      descr = h2.find_next_sibling('div').getText()
      descr = pat.sub(' ', descr).strip()

      cur.execute("INSERT INTO thoughts VALUES(\"%s\", \"%s\")" % (id, descr))

    #  print descr
