#!/usr/bin/python
import re
import pprint as p
import sqlite3 as lite

bookname = "jude"

with open("./%s.txt" % bookname, 'r') as content_file, lite.connect("./%s.sqlite" % bookname) as con:
    content = content_file.read()
    content = ' '.join(content.split())
    
    cur = con.cursor() 

    cur.execute("DROP TABLE IF EXISTS scripture")
    cur.execute("CREATE TABLE scripture(chapter INT,verse INT, text TEXT)")

    chapter = 1
    verse = 1
    while True:
        
        pattern = ".*%d:%d (.*) %d:%d " % (chapter, verse, chapter, verse+1)
        print "%d:%d" % (chapter, verse)
        old_chapter = chapter
        old_verse = verse
                
        obj = re.match(pattern, content)
        if not obj:

            pattern = ".*%d:%d (.*) %d:%d " % (chapter, verse, chapter+1, 1)
            obj = re.match(pattern, content)
            if not obj:
                break

            else:
                chapter += 1
                verse = 1
                
        else:
            verse += 1

        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (old_chapter, old_verse, obj.group(1)))  
        p.pprint(obj.group(1))
        
    
    pattern = ".*%d:%d (.*)" % (chapter, verse)
    obj = re.match(pattern, content)
    if obj:
        cur.execute("INSERT INTO scripture VALUES(%d, %d, \"%s\")" % (chapter, verse, obj.group(1)))  
        p.pprint(obj.group(1))
        
