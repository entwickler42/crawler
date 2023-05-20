package ITB::Crawler;

use LWP::UserAgent;

@ISA = qw( LWP::UserAgent );

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	$self->max_redirect(30);
	$self->timeout(30);
	$self->cookie_jar( {} );
	$self->agent('Mozilla/5.0');
	$self->requests_redirectable([ 'HEAD', 'GET', 'POST' ]);

	return $self;
}

1;
