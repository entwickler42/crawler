package ITB::Crawler::AGACrawler;

require 'crawler.pl';

@ISA = qw( ITB::Crawler);

use HTML::Form;
use HTML::Entities;

use Data::Dumper;
use strict;

use constant AGA_BASE_URL 
	=> 'https://jobboerse2.arbeitsagentur.de';
use constant AGA_SEARCH_URL 
	=> AGA_BASE_URL . '/vam/vamController/SchnellsucheAS/anzeigeSchnellsuche';
use constant AGA_SEARCH_TEXT => 'berufsbezeichnung';
use constant AGA_CHECK_RADIUS => 'umkreisSuche';
use constant AGA_RADIUS => 'kmUmkreisSuche';
use constant AGA_AGE => 'angebotsalter';
use constant AGA_AREA_CODE => 'plz';

sub new{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
}

sub save_to_file{
	my ($self, $filename, $rsp) = @_;

	open(FILE, '>', $filename);
	printf(FILE "%s",$rsp->as_string);
	printf(FILE "\n<hr><br>\n%s",$rsp->request->uri);
	close(FILE);
}

sub extract_hrefs_detail{
	my ($self, $hrefs, $html) = @_;

	$html = decode_entities($html);
	push(@$hrefs, $html =~ /<a href="([^".]+anzeigeDetails[^".]+)/gsi);
}

sub search{
	my ($self, $pattern, %param_in) = @_;
	my (%param, @hrefs);
	my $rsp = $self->get(AGA_SEARCH_URL);
	my @forms = HTML::Form->parse($rsp);

	die sprintf("unable to fetch search url: %s\n",$rsp->status_line)
		unless $rsp->is_success;

	@param{keys %param_in} = values %param_in;

	if($param{'KM'}){
		$forms[1]->value(AGA_RADIUS, $param{'KM'});
		$forms[1]->value(AGA_CHECK_RADIUS, '1');
	}
	$forms[1]->value(AGA_AGE, $param{'AGE'}) if $param{'AGE'};
	$forms[1]->value(AGA_AREA_CODE, $param{'PLZ'}) if $param{'PLZ'};
	$forms[1]->value(AGA_SEARCH_TEXT, $pattern);

	my $req = $forms[1]->click();
		
	$rsp = $self->request($req);
	$self->extract_hrefs_detail(\@hrefs, $rsp->as_string);

	while($rsp->as_string =~ /<a href="([^".]+)[^>.]+title="Zur n/si){
		my $url = decode_entities(AGA_BASE_URL . $1);
		$rsp = $self->get($url);
		$self->extract_hrefs_detail(\@hrefs, $rsp->as_string);
	}

	if($rsp->as_string =~ /<a href="([^".]+)[^>.]+title="Zur l/si){
		my $url = decode_entities(AGA_BASE_URL . $1);
		$rsp = $self->get($url);
		$self->extract_hrefs_detail(\@hrefs, $rsp->as_string);
	}

	for my $href (@hrefs){
		my $url = decode_entities(AGA_BASE_URL . $href);
		$rsp = $self->get($url);
		printf("%s\n",$url);
		$self->save_to_file('detail.html', $rsp);
		$_ = decode_entities($rsp->as_string);
		if(/(<table id="stellendetailansicht_kontaktdaten_table_id".+?<\/table>)/si){
			printf("%s\n----------\n",$1);
		}
		last;
	}

	return \@hrefs;
}

1;
