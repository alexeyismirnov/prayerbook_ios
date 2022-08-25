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


def getContentYu(cur, psalm):
    def getComment(comment):
        id = int(re.findall(r'\d+', comment['id'])[0])

        href = soup.find("a", {"id": "note%d" % id})
        txt = href.find_next_sibling("div", {"class": "note"}).find("p", {"class": "txt"})

        cur.execute("INSERT INTO comments VALUES(%d, \"%s\")" % (id, txt.getText()))

        return id

    cur.execute("DROP TABLE IF EXISTS content_yu")
    cur.execute("DROP TABLE IF EXISTS comments")

    cur.execute("CREATE TABLE content_yu(psalm INT, verse INT, text TEXT)")
    cur.execute("CREATE TABLE comments(id INT, text TEXT)")

    response = requests.get('https://azbyka.ru/otechnik/Pavel_Yungerov/psaltir-proroka-davida-v-russkom-perevode-p-jungerova/%d' % (psalm+1))
    page = response.content

    soup = BeautifulSoup(page, "html.parser")

    h = soup.find("h1")
    div = h.find_next_sibling("div")

    verse = 0

    for content in div.find_all("p", {"class":"txt"}):
        [s.replaceWith(" comment_%d" % (getComment(s))) for s in content.findAll("a")]

        print content.getText()
        cur.execute("INSERT INTO content_yu VALUES(%d, %d, \"%s\")" % (psalm, verse, content.getText()))

        verse += 1


def getContentCs(cur, psalm):
    cur.execute("DROP TABLE IF EXISTS content_cs")
    cur.execute("CREATE TABLE content_cs(psalm INT, verse INT, text TEXT)")

    response = requests.get('https://azbyka.org/biblia/?Ps.%d&c' % psalm)
    page = response.content

    soup = BeautifulSoup(page, "html.parser")

    for div in soup.find_all("div", {"data-lang":"c"}):
        verse =  div['data-line']

        txt = ' '.join(div.getText().split())
        print txt

        cur.execute("INSERT INTO content_cs VALUES(%d, %d, \"%s\")" % (psalm, int(verse), txt))


with lite.connect("yungerov.sqlite") as con:
    cur = con.cursor()

    # getSections(cur)
    # getContentYu(cur, 1)
    getContentCs(cur, 1)
