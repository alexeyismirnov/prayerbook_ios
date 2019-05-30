#!/usr/bin/python
import sys
import re
import os
import pprint as p
import sqlite3 as lite

if len(sys.argv) != 2:
    print "Usage: %s filename" % sys.argv[0]
    sys.exit(0)

basename = os.path.splitext(sys.argv[1])[0]

with open(sys.argv[1], 'r') as f, lite.connect(basename + ".sqlite") as con:

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

