#!/usr/bin/env python

"""
Author:  Antonio A Eggermont
Date:    12/22/2012

emailListGen.py - A simple XML generator script

To run this program:

    1. Change execute permissions to this script:
           chmod a+x emailListGen.py
    2. Then simply run ./emailListGen.py

"""

import os
import sys
import csv
import re
from xml.dom.minidom import Document


# Get fully qualified links for CSV source files
EMAILLIST = os.path.join(os.path.realpath(os.path.dirname(__file__)), 'emails.csv')
INDLOOKUP = os.path.join(os.path.realpath(os.path.dirname(__file__)), 'industry_lookup.csv')
XMLDOC    = os.path.join(os.path.realpath(os.path.dirname(__file__)), 'merged.xml')

addressbook = []  # Global container to hold person records

class Person:

    def __init__(self, name, email, score):

        self.name        = name
        self.attributes = dict([('email', email),
                                ('score', score),
                                ('association', None)])

    def addAssociation(self, association ):
        self.attributes['association'] = association

    def getName(self):
        return self.name

    def getEmail(self):
        return self.attributes['email']

    def getAttributes(self):
        return self.attributes

    def printMember(self):
        return [self.name ,
                self.attributes]


def load_data():
    """ Loads data from both email list and industry lookup csv source files  """

    try:
        for record in csv.reader(open(EMAILLIST), delimiter=','):
            if re.search(record[0], "First Name"): continue
            addressbook.append(Person( record[0] , record[1], record[2] ))

    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        raise


def process_data():
    """ Associates DNS portion of person's email address with industry look up sources
        and adds such association to the dictornary if present  """

    for member in addressbook:
        indAssoc = industry_lookup(member.getEmail())

        if indAssoc is not None:
            member.addAssociation(indAssoc)




def generate_xml_doc():
    """ Generates an XML tree document from records stored in addressbook dictionary  """

    doc = Document()
    root = doc.createElement('items')
    doc.appendChild(root)

    for member in addressbook:
        mainItem = doc.createElement('item')
        root.appendChild(mainItem)

        main = doc.createElement('name')
        mainItem.appendChild(main)
        text = doc.createTextNode(member.getName())
        main.appendChild(text)

        for itemKey, itemValue in member.getAttributes().iteritems():
            if str(itemKey) == "association" and str(itemValue) == "None": continue

            main = doc.createElement(str(itemKey))
            mainItem.appendChild(main)
            text = doc.createTextNode(str(itemValue))
            main.appendChild(text)


    # Lets do some clean up in the xml doc for pretty printing
    text_re = re.compile('>\n\s+([^<>\s].*?)\n\s+</', re.DOTALL)
    prettyXml = text_re.sub('>\g<1></', doc.toprettyxml(indent="    ",  encoding= 'utf-8'))

    try:
        with open(XMLDOC, "w") as fh:
            fh.write(prettyXml)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        raise
    finally:
        fh.close()



def industry_lookup(emailRecord):
    """ Does a look up in the industry association records to find out whether a match 
        is present with email's DNS portion  """

    parts = emailRecord.split(u'@')
    domain_part = parts[-1]

    try:
        for row in csv.reader(open(INDLOOKUP), delimiter=','):
            #if re.search(row[0], "Domain"): continue
            if re.match(domain_part, row[0]): return row[1]

    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        raise

    return None



if __name__ == "__main__":
    """   Program starts here  """

    load_data()
    process_data()
    generate_xml_doc()

    print "Processed XML File: %s" % (XMLDOC)
