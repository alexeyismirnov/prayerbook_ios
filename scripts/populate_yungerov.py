#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sqlite3 as lite
import urllib2
from bs4 import BeautifulSoup
import requests
import unicodedata

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
        result = txt.getText().replace('\"', '\'')

        cur.execute("INSERT INTO comments VALUES(%d, \"%s\")" % (id, result))

        return id

    response = requests.get('https://azbyka.ru/otechnik/Pavel_Yungerov/psaltir-proroka-davida-v-russkom-perevode-p-jungerova/%d' % (psalm+1))
    page = response.content

    soup = BeautifulSoup(page, "html.parser")

    h = soup.find("h1")
    div = h.find_next_sibling("div")

    verse = 0

    for content in div.find_all("p", {"class":"txt"}):
        [s.extract() for s in content.findAll("a", {"class": "zam_link"})]

        [s.replaceWith(" comment_%d" % (getComment(s))) for s in content.findAll("a")]

        # print content.getText()
        result = content.getText().replace('\"', '\'')
        cur.execute("INSERT INTO content_yu VALUES(%d, %d, \"%s\")" % (psalm, verse, result))

        verse += 1


def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])

def getContentCs(cur, psalm):
    response = requests.get('https://azbyka.org/biblia/?Ps.%d&c' % psalm)
    page = response.content

    soup = BeautifulSoup(page, "html.parser")

    for div in soup.find_all("div", {"data-lang":"c"}):
        verse =  div['data-line']

        txt = remove_accents(' '.join(div.getText().split())).encode('utf-8')
        txt = re.sub(r'{[^}]+}', '', txt, flags=re.MULTILINE)

        # print txt

        cur.execute("INSERT INTO content_cs VALUES(%d, %d, \"%s\")" % (psalm, int(verse), txt))


with lite.connect("yungerov.sqlite") as con:
    cur = con.cursor()

    cur.execute("DROP TABLE IF EXISTS content_yu")
    cur.execute("DROP TABLE IF EXISTS comments")

    cur.execute("CREATE TABLE content_yu(psalm INT, verse INT, text TEXT)")
    cur.execute("CREATE TABLE comments(id INT, text TEXT)")

    cur.execute("DROP TABLE IF EXISTS content_cs")
    cur.execute("CREATE TABLE content_cs(psalm INT, verse INT, text TEXT)")

    # getSections(cur)

    for ps in range(151):
        print(ps)
        getContentYu(cur, ps+1)
        getContentCs(cur, ps+1)
