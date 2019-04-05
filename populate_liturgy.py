#!/usr/local/bin/python
# -*- coding: utf-8 -*-
from rtfw import *
from bs4 import BeautifulSoup
import re
import urllib2
import sqlite3 as lite

page = urllib2.urlopen("https://azbyka.ru/library/bozhestvennaja-liturgija.shtml").read()
soup = BeautifulSoup(page, "html.parser")

for br in soup.find_all("br"):
    br.replace_with("\n")

with lite.connect("liturgy.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS content")
    cur.execute("CREATE TABLE content(section INT,row INT, author TEXT, text TEXT)")

    section = 1
    while True:
        h = soup.find("td", {"id": "header%d" % section})
        if h == None:
            break

        [s.extract() for s in h.findAll("span", {"class": "arrow"})]

        print "\"%s\"," % h.getText().strip()

        num = 1
        for row in soup.findAll("tr", {"id": "header%d" % section}):
            data = row.find_all("td")

            if len(data) < 2:
                continue

            content = data[1]

#            if len(data) == 3:
#                comment = data[2]
#                if comment.has_key("rowspan"):
#                    print(comment["rowspan"])
#                    print comment.getText()

            author = data[0].getText().strip()

            [s.extract() for s in content.findAll("p", {"class": "mistery"})]
            [s.extract() for s in content.findAll("span", {"class": "arrow"})]

            txt = re.sub(' +', ' ', content.getText()).strip()
            txt = re.sub(r'^\s*$\n', '', txt, flags=re.MULTILINE)
            txt = re.sub(r'^ +', '', txt, flags=re.MULTILINE)

            cur.execute("INSERT INTO content VALUES(%d, %d, \"%s\", \"%s\")" % (section, num, author, txt))
            num += 1

        section += 1
