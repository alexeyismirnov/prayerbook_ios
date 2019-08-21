#!/usr/bin/python
import re
import sqlite3 as lite

# https://days.pravoslavie.ru/Bible/Index.htm#V
# https://pomog.org/bible_en/34_daniel.htm

chapter = 14

with open("./dan_14en.txt", 'r') as content_file, lite.connect("./dan_en.sqlite") as con:
    content = content_file.read()
    content = ' '.join(content.split())

    cur = con.cursor()

    pattern = "(\d+) (.*?)(?=\d+|$)"

    for (verse, txt) in re.findall(pattern, content):
        # txt = txt.replace("\"", "'")
        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), txt))
