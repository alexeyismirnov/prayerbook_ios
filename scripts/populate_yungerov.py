#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup
import requests

def getSections(cur):
    cur.execute("DROP TABLE IF EXISTS sections")
    cur.execute("DROP TABLE IF EXISTS content")

    cur.execute("CREATE TABLE sections(id INT,title TEXT)")
    cur.execute("CREATE TABLE content(section INT, item INT, title TEXT)")

    response = requests.get('https://православный-молитвослов.рф/usopshim/ps_3/index.html')
    page = response.content

    soup = BeautifulSoup(page, "html.parser")
    section = 0

    for h in soup.find_all("strong"):
        kaf_title =  h.getText()

        if u'Кафизма' not in kaf_title:
            continue

        print kaf_title

        p = h.find_next_sibling("em")
        psalms = p.getText()
        ps_list = re.findall(r'\d+', psalms)

        cur.execute("INSERT INTO sections VALUES(%d, \"%s\")" % (int(section), kaf_title))

        item = 0
        for ps in ps_list:
            cur.execute("INSERT INTO content VALUES(%d, %d, \"%s\")" % (int(section), int(item), "Псалом %d" % int(ps)))

            item += 1

        section += 1


with lite.connect("yungerov.sqlite") as con:
    cur = con.cursor()

    getSections(cur)
