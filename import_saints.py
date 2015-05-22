#!/usr/bin/python
import re
import pprint as p
import sqlite3 as lite

month="05"

with open("./saints_%s.txt" % month, 'r') as f, lite.connect("./saints_%s.sqlite" % month) as con:

    content = f.read().splitlines()

    cur = con.cursor()
    cur.execute("DROP TABLE IF EXISTS saints")
    cur.execute("CREATE TABLE saints(day INT,typikon INT, name TEXT)")

    day = "01"
    for line in content:
        if len(line) == 0:
            continue

        print line

        if re.search(r'[^0-9]', line):
            groups = re.match("(\*+|\++)?\s*(.*)", line) 

            typikon_signs = { '*': 1, '**': 2, '***': 3, '+': 4, '++': 5, '+++': 6 }

            typikon = 0 if groups.group(1) is None else typikon_signs[groups.group(1)]
            cur.execute("INSERT INTO saints VALUES(%d, %d, \"%s\")" % (int(day), int(typikon), groups.group(2)))
        else:
            day = line

