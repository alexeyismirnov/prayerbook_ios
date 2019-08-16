#!/usr/bin/python
import re
import pprint as p
import sqlite3 as lite
from bs4 import BeautifulSoup
import urllib2

def strip_all(txt):
    txt = re.sub('\s+', ' ', txt, flags=re.MULTILINE)
    txt = re.sub(r'^ +', '', txt, flags=re.MULTILINE)
    return txt

def getText(kafisma, cur):
    page = urllib2.urlopen("http://www.liturgy.io/orthodox-psalter?kathisma=%d&style=BLOCK&trans=KJV&psalt=DEF" % (kafisma)).read()
    soup = BeautifulSoup(page, "html.parser")

    for ps in soup.find_all("div", {"class": "blockReading"}):
        title = ps["readingfrom"]
        title = re.sub(r'.*?(\d+).*', r'\1', title)
        print(title)

        caption_el = ps.find("h3", {"class": "caption"})
        caption = caption_el.getText().strip()

        if "." in caption:
            caption = re.sub('\..*', '.', caption)
        else:
            caption = caption[:-1] + "."

        content_el = ps.find("div", {"class": "dropCap"})
        content = strip_all(content_el.getText())

        content = caption + " " + content

        sib2 = ps.find_next_sibling().find_next_sibling()
        if "Stasis" in sib2.getText().strip():
            content += "\n\nStasis:\n"

        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(kafisma), int(title), content))

with lite.connect("./ps_en.sqlite") as con:
    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    for k in range(20):
        getText(k+1,cur)
