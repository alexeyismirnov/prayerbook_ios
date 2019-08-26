#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
from bs4 import BeautifulSoup

num_ps = 1

def getText(kafisma, cur):
    global num_ps

    soup = BeautifulSoup(open("../../psaltir_ios7/psaltir_ios7/kafisma%d.html" % (kafisma)), "html.parser")
    body = soup.find('body')
    [s.extract() for s in body.findAll("sup")]

    psalm = body.findChildren()[0]

    while psalm:
        print(psalm.getText().encode('utf-8'))
        psalm = psalm.find_next_sibling()

        content = ""
        while psalm != None and psalm.name == 'p':
         content += psalm.getText()
         psalm = psalm.find_next_sibling()

        content = content.strip()
        content = re.sub(r'SLAVA\d', u'荣光赞词\n', content, flags=re.MULTILINE)

        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(kafisma), num_ps, content))
        num_ps += 1

        print(content.encode('utf-8'))


with lite.connect("./ps_cn.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for k in range(20):
        getText(k+1,cur)
