#!/usr/local/bin/python
# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import re
import urllib2
import sqlite3 as lite
from datetime import timedelta, date

def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)

def get_troparion(cur, date):
    url = "https://days.pravoslavie.ru/Days/%s.html" % (date.strftime("%Y%m%d"))
    print(url)

    newdate = date + timedelta(13)

    page = urllib2.urlopen(url).read()
    soup = BeautifulSoup(page, "html.parser")

    for trop in soup.findAll("div", {"class": "trop" }):
        trop_title = trop.find("div", {"class": "trop_title" })
        trop_glas = trop.find("div", {"class": "trop_glas" })
        trop_text = trop.find("div", {"class": "trop_text" })

        glas = trop_glas.getText() if trop_glas != None else ""

        cur.execute("INSERT INTO tropari VALUES(%d, %d, \"%s\",  \"%s\",  \"%s\")" %
            (newdate.day, newdate.month, trop_title.getText(), glas, trop_text.getText()))

start_date = date(2019, 3, 1)
end_date = date(2019, 4, 1)

with lite.connect("./troparion.sqlite") as con:
    cur = con.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS tropari(day INT, month INT, title TEXT, glas TEXT, content TEXT)")

    for cur_date in daterange(start_date, end_date):
        get_troparion(cur, cur_date)
