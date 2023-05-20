package ITB::Crawler::GoogleCrawler;

use URI::Escape;
use HTTP::Request;

require 'crawler.pl';

@ISA = qw( ITB::Crawler );

my $google_num = 100;
my $google_url = 'http://www.google.com/search?q=%s&num=%i&start=%i';

sub search
{
	my ($self,$pattern,$end,$start) = @_;
	my ($req, $rsp);
	my @result = ();
	my @links;

	$start = 0 unless $start;
	$end = 100 unless $end;

	while($start < $end){
		$req = HTTP::Request->new('GET',
			sprintf($google_url, uri_escape($pattern),$google_num, $start)
			) or die $@;
		$rsp = $self->request($req) or die $@;
		push(@links, grep(/class=l/,$rsp->as_string =~ /<a.+?\/a>/gs));
		$start += $google_num;
		last unless $rsp->as_string =~ /.+start=$start.+/;
	}

	for my $l (@links){
		if( $l =~ /href="(.+)".+?>(.+)<\/a>/ ){
			my ($url,$desc) = ($1, $2);
			$desc =~ s/<em>//gi;
			$desc =~ s/<\/em>//gi;
			push @result, { url => $url, desc => $desc };
		}
	}

	return @result;
}

1;
