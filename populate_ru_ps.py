#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup

book = 19

def getText(kafisma, cur):
    page = urllib2.urlopen("http://www.orthodox-books.info/literature/psaltir/na-russkom-yazyke/kafizma-%d.html" % (kafisma)).read()
    soup = BeautifulSoup(page, "html.parser")

    for h in soup.find_all("h4"):
        ps_title =  h.getText()

        if u'Псалом' not in ps_title:
            continue

        print ps_title
        ps_num =int(re.findall(r'\d+', ps_title)[0])

        p = h.find_next_sibling("p")
        if p == None:
            p = h.parent.find_next_sibling("p")

        content = ''
        while p.name == 'p':
            [s.extract() for s in p('span')]
            content += p.getText().strip() + ' '
            p = p.find_next_sibling()

        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(kafisma), int(ps_num), content))


with lite.connect("./%s.sqlite" % book) as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for k in range(20):
        getText(k+1,cur)
