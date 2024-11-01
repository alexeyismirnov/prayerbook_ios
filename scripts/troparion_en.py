#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import re
from urllib.request import Request, urlopen
import sqlite3 as lite
from datetime import timedelta, date
from functools import reduce

def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)


def get_troparion(cur, date):
    url = "https://www.oca.org/saints/troparia/%s" % (date.strftime("%Y/%m/%d"))
    print(url)

    req = Request(
        url=url, headers={'User-Agent': 'Mozilla/5.0'}
    )

    page = urlopen(req).read()
    soup = BeautifulSoup(page, "html.parser")

    main_col = soup.find("div", {"id": "main-col"})

    for s in main_col.select('em'):
        s.extract()
        
    for s in main_col.select('br'):
        s.extract()
        
        
    for s in main_col.select('sup'):
        s.extract()
        
    for saint in main_col.findAll("h2"):
        saint_name = saint.getText()

        trop = saint.parent
        while (trop := trop.find_next_sibling("article")) is not None:
            if trop.find("h3", recursive=False) is None:
                break
            
            trop_title = trop.find("h3").getText()
            trop_text = trop.find("p").getText()
            
            title_split = trop_title.split("—")
            title = title_split[0].strip()
            title_full = "%s of %s" % (title, saint_name)
            glas = title_split[1].strip()
            text = trop_text.strip()
            
            cur.execute("INSERT INTO tropari VALUES(?, ?, ?, ?, ?)" , (date.day, date.month, title_full, glas, text))
            
            #print(title_full)
            #print(glas)
            #print(text)
                

start_date = date(2024, 10, 1)
end_date = date(2024, 10, 31)

with lite.connect("./troparion_en.sqlite") as con:
    cur = con.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS tropari(day INT, month INT, title TEXT, glas TEXT, content TEXT)")

    for cur_date in daterange(start_date, end_date):
        get_troparion(cur, cur_date)
