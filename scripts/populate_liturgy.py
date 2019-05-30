#!/usr/local/bin/python
# -*- coding: utf-8 -*-
from rtfw import *
from bs4 import BeautifulSoup
import re
import urllib2
import sqlite3 as lite
import unidecode
import unicodedata

def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])

def strip_all(txt):
    txt = re.sub(' +', ' ', txt).strip()
    txt = re.sub(r'^\s*$\n', '', txt, flags=re.MULTILINE)
    txt = re.sub(r'^ +', '', txt, flags=re.MULTILINE)
    return txt

page = urllib2.urlopen("https://azbyka.ru/library/bozhestvennaja-liturgija.shtml").read()
soup = BeautifulSoup(page, "html.parser")

#for br in soup.find_all("br"):
#    br.replace_with("\n")

with lite.connect("liturgy.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS content")
    cur.execute("DROP TABLE IF EXISTS comments")

    cur.execute("CREATE TABLE content(section INT,row INT, author TEXT, text TEXT)")
    cur.execute("CREATE TABLE comments(id INT, section INT,row INT, text TEXT)")

    section = 1
    comment_id = 1

    while True:
        h = soup.find("td", {"id": "header%d" % section})
        if h == None:
            break

        [s.extract() for s in h.findAll("span", {"class": "arrow"})]

        title = remove_accents(h.getText().strip())

        print "\"%s\"," % title

        num = 1
        for row in soup.findAll("tr", {"id": "header%d" % section}):
            data = row.find_all("td")

            if len(data) < 2:
                continue

            content = data[1]

            if len(data) == 3:
                comment = data[2]
                rowspan = 1 if not comment.has_key("rowspan") else int(comment["rowspan"])

                txt = strip_all(comment.getText())

                if txt:
                    cur.execute("INSERT INTO comments VALUES(%d, %d, %d, \"%s\")" %
                        (comment_id, section, num+rowspan-1, txt))
                    comment_id += 1

            author = data[0].getText().strip()

            mist = content.find("span", {"class": "mist"})
            mistery = content.find("p", {"class": "mistery"})

            if mist != None and mistery != None:
                mist_head = mistery.find("span", {"class": "mist_head"})
                if mist_head != None:
                    mist_head_text = strip_all(mist_head.getText())
                    mistery.find("span", {"class": "mist_head"}).replaceWith("%s\n" % (mist_head_text))

                [s.extract() for s in mist.findAll("span", {"class": "arrow"})]
                mist_text = strip_all(mist.getText())

                content.find("span", {"class": "mist"}).replaceWith("%s comment_%d" % (mist_text, comment_id))

                cur.execute("INSERT INTO comments VALUES(%d, %d, %d, \"%s\")" %
                        (comment_id, 0, 0, strip_all(mistery.getText())))

                comment_id += 1

            [s.extract() for s in content.findAll("p", {"class": "mistery"})]

            txt = strip_all(content.getText())

            cur.execute("INSERT INTO content VALUES(%d, %d, \"%s\", \"%s\")" % (section, num, author, txt))
            num += 1

        section += 1
