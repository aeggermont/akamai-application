akamai-application
==================

Solutions for application code test for Antonio A Eggermont.

Requirements
============

Generate an xml file (merged.xml) from data contained in emails.csv and industry_lookup.csv.
Process each line of emails.csv. For each line, add a node to the xml file. If the email address domain is present in 
industry_lookup.csv then include the industry in the xml node. Assume you can come up with what you feel is the best 
xml structure for the data. Assume all files are in the same directory. If you are able, go ahead and write this in 
both perl and python. When you send me the scripts, please include an explanation of which language you would have 
written this in and why, if you were given the choice.

Solutions
=========

Solution 1 ( located in directory solution1 ):
---------------------------------------------

XML generator written in Python

* Python script:     emailXMLGen.py 
* CSV source files:  emails.csv
                   industry_lookup.csv
* Archive file:      AntonioEggermont-PythonSolution.tar


To run the program:

    1. Change execute permissions to this script:
         chmod a+x emailListGen.py
    2. Then simply run ./emailListGen.py


Solution 2 ( located in directory solution2 ):
---------------------------------------------

XML generator written in Perl

* Perl script:       emailXMLGen.pl
* CSV source files:  emails.csv
                     industry_lookup.csv
* Archive file:      AntonioEggermont-PerlSolution.tar

To run the program:

    1. Make the location of perl in your system is correct in the script's shebang
    2. Change execute permissions to this script:
           chmod a+x emailXMLGen.pl
    3. Then simply run ./emailXMLGen.pl


Notes
=====

Given my current experience and exposure in the industry, I would have written this in Java  or Python depending 
on the size of the datasets being consumed and produced.  However this choice will be driven by the  size of datasets 
being consumed and produced and whether this implementation would result into a modern RESTful Web service interface. 
In the case of Java, since it is a compiled language more further optimization can be applied in terms of REGEX, 
data processing, and data servicing via containers such as Tomcat and Servlets. Python also has a highly optimized 
REGEX engine that allows for compilation of REGEX in advance to speed up pattern matching operations. 
In addition, Python is a more general purpose object oriented language and emphasis on writing clean code which 
helps to maintain big and complex programs.  In terms of building back-end service side end-points for XML-rpc based 
responses, this implementation could have been improved by the use of generators to decrease I/O in memory and employed 
a framework such as Tornado framework implementing the JSON-RPM and the XML-RPC specifications.


