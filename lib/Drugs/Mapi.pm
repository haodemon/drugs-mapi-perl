package Drugs::Mapi;

our $VERSION = '0.02';

use strict;
use warnings;

use Moose;
use Memoize;

use JSON;
use LWP::UserAgent;
use URI::Escape;

has 'api_base_url' => (is => 'ro', default => 'https://mapi-us.iterar.co/api');
has 'api_key'      => (is => 'ro', isa => 'Str');
has 'attempts'     => (is => 'rw', default => 3);

has '_mapi'        => (is => 'rw', isa => 'LWP::UserAgent', lazy_build => 1);
has '_memoize'     => (is => 'ro', default => 1);


sub BUILD {
	my $self = shift;

	if ($self->_memoize) {
		memoize($_) for qw/get_drugs get_dosages get_ingredients/;
	}
}

sub _build__mapi {
	my $self = shift;

	my $ua = LWP::UserAgent->new(agent => __PACKAGE__);
	
	$ua->default_header(Authorization => $self->api_key) 
		if $self->api_key;

	return $ua;
}

=item get_drugs

 Takes a string ($drug) as an argument and returns drugs matched (think autocompletion)

=cut

sub get_drugs {
	my ($self, $drug) = @_;

	return wantarray ? () : [] unless length($drug);

	my $autocomplete_url = join '/', $self->api_base_url, 'autocomplete';
	my $res = $self->_get(
		$self->_form_url(
			url   => $autocomplete_url,
			query => $drug,
		)
	);

	return 
		wantarray ? @{$res->{suggestions}} : $res->{suggestions};
}

=item get_dosages

 Returns drugs dosages in MG

=cut

sub get_dosages {
	my ($self, $drug) = @_;

	return wantarray ? () : [] unless length($drug);

	my $dosage_url = join '/', $self->api_base_url, $drug, 'doses.json';
	my $res = $self->_get(
		$self->_form_url(url => $dosage_url)
	);

	return
		wantarray ? @$res : $res;
}

=item get_ingredients

 Returns drugs ingredients

=cut

sub get_ingredients {
	my ($self, $drug) = @_;

	return wantarray ? () : [] unless length($drug);

	my $ingredients_url = join '/', $self->api_base_url, $drug, 'substances.json';
	my $res = $self->_get(
		$self->_form_url(url => $ingredients_url)
	);

	return
		wantarray ? @$res : $res;
}

=item _get

 Fires GET request to the API

=cut

sub _get {
	my ($self, $url) = @_;

	my $ua    = $self->_mapi;
	my $tries = $self->attempts;
	my $error;

	while($tries--) {
		my $response = $ua->get($url =~ s|^https://|http://|gr);  # https is not supported
		my $content  = $response->decoded_content();

		if (!$response->is_success) {
			$error = $content;
			warn("Unsuccessful request to Mapi API: ($tries attempts left): $content");
			next;
		}

		my $data = eval {
			JSON->new()->utf8(1)->decode($content);
		};

		next if $error = $@;
		next if $error = $data->{error};

		return $data;
	}

	die "No attempts left while querying Mapi API: $error";
}

=item _form_url()

 Forms URL and escapes special characters

=cut

sub _form_url {
	my ($self, %opts) = @_;

	my $query_string;
	for (qw/delimeter maxResults pageToken prefix query/) {
		$query_string->{$_} = $opts{$_} if $opts{$_};
	}

	if ($query_string && keys %{$query_string}) {
		my @query_string;
		
		while (my ($key, $value) = each %{$query_string}) {
			push @query_string, join('=', uri_escape($key), uri_escape($value));
		}

		$opts{url} = join('?', $opts{url}, join('&', @query_string));
	}

	return $opts{url};
}


no warnings 'once';
*autocomplete = \&get_drugs;

1;

__END__

=head1 Drugs::Mapi

Drugs::Mapi - Perl client module to work with 'http://mapi-us.iterar.co/' drugs api

=head1 SYNOPSIS

  use Drugs::Mapi;

  my $drugs = Drugs::Mapi->new();

  $drugs->get_drugs('Ibuprofen')        # [ 'Ibuprofen', 'Ibuprofen and diphenhydramine citrate', <...> ]
  $drugs->get_dosages('Aspirin')        # [ '25MG', '200MG', '325MG' ]
  $drugs->get_ingredients('Propecia');  # [ 'Finasteride' ]


=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

https://mapi-us.iterar.co/

=head1 AUTHOR

Alfred Suleymanov, E<lt>haodemon@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Alfred Suleymanov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
