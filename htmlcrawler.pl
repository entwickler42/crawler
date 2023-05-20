package ITB::Crawler::HTMLCrawler;

require 'crawler.pl';

@ISA = qw( ITB::Crawler );

use HTTP::Request;
use strict;

sub get_forms{
	my ($self, $url) = @_;
	my $req = HTTP::Request->new('GET',$url) or die $@;
	my $rsp = $self->request($req) or die $@;	
	my @forms = $rsp->as_string =~ /<form.+?\/form>/igs;
	my @data;

	for my $f (@forms){
		my %cf;
		my @inputs;

		$f =~ /action="(?<action>.+?)"/is;
		$cf{'action'} = $+{'action'}; 
		$f =~ /method="(?<method>.+?)"/is;
		$cf{'method'} = $+{'method'}; 
		@inputs = $f =~ /<input.+?>/isg;
		
		$cf{'inputs'} = [];
		for my $i (@inputs){
			my ($name,$type,$value);

			$i =~ /type="(?<type>.+?)"/is;
			$type = $+{'type'};
			$i =~ /name="(?<name>.+?)"/is;
			$name = $+{'name'};
			$i =~ /value="(?<value>.+?)"/is;
			$value = $+{'value'} ? $+{'value'} : '';

			push(@{$cf{'inputs'}},{name=>$name, type=>$type, value=>$value});
		}
		push(@data, \%cf );
	}

	return @data;
}

1;
