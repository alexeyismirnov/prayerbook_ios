#!/usr/local/bin/python
# -*- coding: utf-8 -*-
from rtfw import *
from bs4 import BeautifulSoup
import re
import urllib2

def MakeExample1():
    doc = Document()
    ss = doc.StyleSheet
    section = Section()
    doc.Sections.append(section)

    #    text can be added directly to the section
    #    a paragraph object is create as needed
    section.append('Example 1')

    #    blank paragraphs are just empty strings
    section.append('')

    tps = TextPropertySet(colour=ss.Colours.Red)

    p = Paragraph()
    p.append(
        'It is also possible to provide overrides for element of a style. ',
        'For example I can change just the font ',
        TEXT('italic', italic=True), ' or ',
        TEXT('typeface', font=ss.Fonts.Impact), '.')

    p.append('This next word should be in ', Text('RED', tps))
    section.append(p)

    return doc

def OpenFile(name):
    return open('%s.rtf' % name, 'w')

# DR = Renderer()
# doc1 = MakeExample1()
# DR.Write(doc1, OpenFile('1'))

page = urllib2.urlopen("https://azbyka.ru/library/bozhestvennaja-liturgija.shtml").read()
soup = BeautifulSoup(page, "html.parser")

for br in soup.find_all("br"):
    br.replace_with("\n")

num = 1
while True:
    h = soup.find("td", {"id": "header%d" % num})
    if h == None:
        break

    [s.extract() for s in h.findAll("span", {"class": "arrow"})]

    print "\n" + h.getText().strip() + "\n"

    for row in soup.findAll("tr", {"id": "header%d" % num}):
        data = row.find_all("td")

        if len(data) < 2:
            continue

        author = data[0]
        content = data[1]

        print author.getText().strip()

        [s.extract() for s in content.findAll("p", {"class": "mistery"})]
        [s.extract() for s in content.findAll("span", {"class": "arrow"})]

        txt = re.sub(' +', ' ', content.getText()).strip()
        txt = re.sub(r'^\s*$\n', '', txt, flags=re.MULTILINE)
        txt = re.sub(r'^ +', '', txt, flags=re.MULTILINE)

        print txt

    num += 1


# for table in soup.find_all("table", {"class": "table"}):
