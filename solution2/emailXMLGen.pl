#!/usr/bin/perl

=head1 DESCRIPTION

Author:  Antonio A Eggermont
Date:    12/22/2012

emailXMLGen.pl - A simple XML generator script

To run this program:

    1. Make the location of perl in your system is correct in the script's shebang
    2. Change execute permissions to this script: 
           chmod a+x emailXMLGen.pl
    3. Then simply run ./emailXMLGen.pl

=cut


use strict;
use warnings;
use XML::Writer;
use IO;
use File::Basename qw( dirname );
use Cwd qw( abs_path );


my $emailList      = dirname(abs_path($0)) . "/emails.csv";             # Path to the emails lists data source
my $industryLookup = dirname(abs_path($0)) . "/industry_lookup.csv";    # Path to the industry associations data source
my $xmldoc         = dirname(abs_path($0)) . "/merged.xml";

sub lookupIndusAssoc{
    # Looks up for matching records in industry_lookup.csv file with
    # associated people email's address domains
    # ARGS: $email: Email address in processing 
    # RETURNS: Associated industry with person's email address DNS

    my $email = shift;
    my ($userame, $domain) = split(/@/, $email);

    open( FILEIN, "<:encoding(UTF-8)", $industryLookup)
        or die " cannot open file: $!";  

    while(<FILEIN>){
        next if ( $_ =~ m/Domain,Industry/ );
        my @indLookup = split(/,/, $_);

        if ($indLookup[0] =~ m/$domain/){
            $indLookup[1] =~ s/[\r\n]/ /g;
            return $indLookup[1];
	    }
    }

    return undef;
}


sub generateXMLDoc{
    # Generates an XML document based on data in %addressbook hash
    # ARGS:  \%addressbook: Reference address for %addressbook
    # RETURNS: None

    my $ref = shift;           # Referece address for %addressbook
    my %refAddr = %{$ref};

    my $doc = new IO::File(">$xmldoc");
    my $xmlObj = XML::Writer->new(OUTPUT => $doc, DATA_MODE => 1, DATA_INDENT => 4);
   
    $xmlObj->xmlDecl("UTF-8"); 
    $xmlObj->startTag("items");  

    foreach my $who ( keys %{refAddr} ) {
        $xmlObj->startTag("item");

        $xmlObj->startTag("name");
        $xmlObj->characters($who);
        $xmlObj->endTag("name");

        $xmlObj->startTag("email");
        $xmlObj->characters($refAddr{$who}{email});
        $xmlObj->endTag("email");

        $xmlObj->startTag("score");
        $xmlObj->characters($refAddr{$who}{score});  
        $xmlObj->endTag("score");

        if (defined $refAddr{$who}{industry}){
            $xmlObj->startTag("industry");
            $xmlObj->characters($refAddr{$who}{industry});  
            $xmlObj->endTag("industry");
        }

        $xmlObj->endTag("item");
    }
 
    $xmlObj->endTag("items");
    $xmlObj->end();   

}


#########################################################
#
#           Main program starts here  
#
#########################################################


my %addressbook;    # Holds a collection of records for people in emails.csv
my @record;         # Place holder to iterate over each record 

open(MYFILE, "<:encoding(UTF-8)", $emailList )
        or die "cannot open < $emailList : $!";

    while (<MYFILE>) {
        next if ( $_ =~ m/First Name/);
        $_ =~ s/\x0D//g;

        my @rec =  split(/,/, $_ );
        my $assoc = lookupIndusAssoc($rec[1]);
        $rec[2] =~ s/[\r\n]/ /g;
 
        $addressbook{$rec[0]} = {
            email    => $rec[1],
            score    => $rec[2],
            industry => $assoc
        };
    }

close(MYFILE)
        || warn "close failed: $!";



generateXMLDoc(\%addressbook);

print "XML file processed: ", $xmldoc, "\n";

