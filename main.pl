#!/usr/bin/perl -w

use strict;
use Data::Dumper;

require 'agacrawler.pl';

my $crawler = ITB::Crawler::AGACrawler->new();
my $hrefs = $crawler->search('softwareentwickler');
