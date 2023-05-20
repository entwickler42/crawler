#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use Data::Dumper;

require 'googlecrawler.pl';

sub HELP_MESSAGE{
	print("USAGE: gds.pl [-u KEY[;...n]] [-s SITE[;...n]] [-k KEYWORD] [-p PROXY]\n");
}

# script start
HELP_MESSAGE() and exit unless @ARGV;
my (%opts, $search);

$opts{'u'} = '';
$opts{'s'} = '';
$opts{'k'} = '';
$opts{'t'} = '';

getopts('u:s:k:t:p:', \%opts)
	or die "can't get command line arguments";

# add search keywords
$search = $opts{'k'} . ' ';
# add inurl keywords
for (split(/;/,$opts{'u'})){
	$search .= "+inurl:$_ "
}
# add site keywords
for (split(/;/,$opts{'s'})){
	$search .= "+site:$_ "
} 
# add intitle keywords
for (split(/;/,$opts{'t'})){
	$search .= "+intitle:$_ "
}
# initialize user agent
my $cr = ITB::Crawler::GoogleCrawler->new();
$cr->proxy(['http', 'https', 'ftp'], $opts{'p'}) if $opts{'p'};
# query google
for($cr->search($search)){
	print	$$_{'url'} . "\n";
}
