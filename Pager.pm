package Tags::HTML::Pager;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['css_pager', 'flag_prev_next', 'flag_paginator',
		'num_paginator_pages', 'url_page_cb'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# CSS class.
	$self->{'css_pager'} = 'pager';

	# Flag for prev/next buttons..
	$self->{'flag_prev_next'} = 1;

	# Flag for paginator.
	$self->{'flag_paginator'} = 1;

	# Number of paginator buttons.
	$self->{'num_paginator_pages'} = 5;

	# URL of page.
	$self->{'url_page_cb'} = undef;

	# Process params.
	set_params($self, @{$object_params_ar});

	if (! defined $self->{'url_page_cb'}) {
		err "Missing 'url_page_cb' parameter.";
	}

	# Object.
	return $self;
}

sub _process {
	my ($self, $pages_hr) = @_;

	if (! $pages_hr) {
		err 'Pages data structure is missing.';
	}
	if (! exists $pages_hr->{'pages_num'}) {
		err "Missing 'pages_num' parameter in pages data structure.";
	}
	if (! exists $pages_hr->{'actual_page'}) {
		err "Missing 'actual_page' parameter in pages data structure.";
	}

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', $self->{'css_pager'}],
	);

	# Paginator
	if ($self->{'flag_paginator'}) {
		$self->{'tags'}->put(
			['b', 'p'],
			['a', 'class', $self->_css_class('paginator')],

			# TODO
			['e', 'p'],
		);
	}

	# Paging.
	if ($self->{'flag_prev_next'}) {
		my ($prev, $next);
		if ($pages_hr->{'pages_num'} > 1) {
			if ($pages_hr->{'actual_page'} > 1) {
				$prev = $pages_hr->{'actual_page'} - 1;
			}
			if ($pages_hr->{'actual_page'} < $pages_hr->{'pages_num'}) {
				$next = $pages_hr->{'actual_page'} + 1;
			}
		}
		
		$self->{'tags'}->put(
			['b', 'p'],

			# Previous page.
			$prev ? (
				['b', 'a'],
				['a', 'class', $self->_css_class('prev')],
				['a', 'href', $self->{'url_page_cb'}->($prev)],
				['d', decode_utf8('←')],
				['e', 'a'],
			) : (
				['b', 'span'],
				['a', 'class', $self->_css_class('prev-disabled')],
				['d', decode_utf8('←')],
				['e', 'span'],
			),

			# Next page.
			$next ? (
				['b', 'a'],
				['a', 'class', $self->_css_class('next')],
				['a', 'href', $self->{'url_page_cb'}->($next)],
				['d', decode_utf8('→')],
				['e', 'a'],
			) : (
				['b', 'span'],
				['a', 'class', $self->_css_class('next-disabled')],
				['d', decode_utf8('→')],
				['e', 'span'],
			),

			['e', 'p'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _css_class {
	my ($self, $suffix) = @_;

	my $class = '';
	if (defined $self->{'css_pager'}) {
		$class .= $self->{'css_pager'}.'-';
	}
	$class .= $suffix;

	return $class;
}

1;
