#!/usr/bin/python
import re
import pprint as p
import sqlite3 as lite

# http://www.gutenberg.org/cache/epub/10/pg10.txt

bookname = "mal"

with open("./%s_en.txt" % bookname, 'r') as content_file, lite.connect("./%s_en.sqlite" % bookname) as con:
    content = content_file.read()
    content = ' '.join(content.split())

    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    pattern = "(\d+):(\d+) (.*?)(?=\d+:\d+|$)"

    for (chapter, verse, txt) in re.findall(pattern, content):
        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (int(chapter), int(verse), txt))
