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
		['css_colors', 'css_pager', 'flag_prev_next', 'flag_paginator',
		'url_page_cb'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# CSS colors.
	$self->{'css_colors'} = {
		'actual_background' => 'black',
		'actual_color' => 'white',
		'border' => 'black',
		'hover_background' => 'black',
		'hover_color' => 'white',
		'other_background' => undef,
		'other_color' => 'black',
	},

	# CSS class.
	$self->{'css_pager'} = 'pager';

	# Flag for prev/next buttons..
	$self->{'flag_prev_next'} = 1;

	# Flag for paginator.
	$self->{'flag_paginator'} = 1;

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
		);
		my $buttons_from = 1;
		my $buttons_to = $pages_hr->{'pages_num'};
		if ($pages_hr->{'actual_page'} > 4 && $pages_hr->{'pages_num'} > 7) {
			$self->{'tags'}->put(
				['b', 'a'],
				['a', 'href', $self->{'url_page_cb'}->(1)],
				['d', 1],
				['e', 'a'],

				['b', 'span'],
				['d', decode_utf8('…')],
				['e', 'span'],
			);
			if ($pages_hr->{'actual_page'} < $pages_hr->{'pages_num'} - 3) {
				$buttons_from = $pages_hr->{'actual_page'} - 1;
			} else {
				$buttons_from = $pages_hr->{'pages_num'} - 4;
			}
		}
		if ($pages_hr->{'actual_page'} < $pages_hr->{'pages_num'} - 3
			&& $pages_hr->{'pages_num'} > 7) {

			if ($pages_hr->{'actual_page'} > 4) {
				$buttons_to = $pages_hr->{'actual_page'} + 1;
			} else {
				$buttons_to = 5;
			}
		}
		foreach my $button_num ($buttons_from .. $buttons_to) {
			if ($pages_hr->{'actual_page'} eq $button_num) {
				$self->{'tags'}->put(
					['b', 'strong'],
					['a', 'class', $self->_css_class('paginator-selected')],
					['d', $button_num],
					['e', 'strong'],
				);
			} else {
				$self->{'tags'}->put(
					['b', 'a'],
					['a', 'href', $self->{'url_page_cb'}->($button_num)],
					['d', $button_num],
					['e', 'a'],
				);
			}
		}
		if ($pages_hr->{'actual_page'} < $pages_hr->{'pages_num'} - 3 && $pages_hr->{'pages_num'} > 7) {
			$self->{'tags'}->put(
				['b', 'span'],
				['d', decode_utf8('…')],
				['e', 'span'],

				['b', 'a'],
				['a', 'href', $self->{'url_page_cb'}->($pages_hr->{'pages_num'})],
				['d', $pages_hr->{'pages_num'}],
				['e', 'a'],
			);
		}
		$self->{'tags'}->put(
			['e', 'p'],
		);
	}

	# Paging.
	if ($self->{'flag_prev_next'} && $pages_hr->{'pages_num'} > 1) {
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
			['a', 'class', $self->_css_class('prev_next')],

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

sub _process_css {
	my $self = shift;

	$self->{'css'}->put(
		['s', '.'.$self->{'css_pager'}.' a'],
		['d', 'text-decoration', 'none'],
		['e'],

		['s', '.'.$self->_css_class('paginator')],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'justify-content', 'center'],
		['d', 'padding-left', '130px'],
		['d', 'padding-right', '130px'],
		['d', 'float', 'both'],
		['e'],

		['s', '.'.$self->_css_class('prev_next')],
		['d', 'display', 'flex'],
		['e'],

		['s', '.'.$self->_css_class('paginator').' a'],
		['s', '.'.$self->_css_class('paginator').' strong'],
		['s', '.'.$self->_css_class('paginator').' span'],
		['s', '.'.$self->_css_class('next')],
		['s', '.'.$self->_css_class('next-disabled')],
		['s', '.'.$self->_css_class('prev')],
		['s', '.'.$self->_css_class('prev-disabled')],
		['d', 'display', 'flex'],
		['d', 'height', '55px'],
		['d', 'width', '55px'],
		['d', 'justify-content', 'center'],
		['d', 'align-items', 'center'],
		['d', 'border', '1px solid '.$self->{'css_colors'}->{'border'}],
		['d', 'margin-left', '-1px'],
		['e'],


		['s', '.'.$self->_css_class('prev')],
		['s', '.'.$self->_css_class('next')],
		['d', 'display', 'inline-flex'],
		['d', 'align-items', 'center'],
		['d', 'justify-content', 'center'],
		['e'],

		['s', '.'.$self->_css_class('paginator').' a:hover'],
		['s', '.'.$self->_css_class('prev_next').' a:hover'],
		$self->_css_colors_optional('hover_color', 'color'),
		$self->_css_colors_optional('hover_background', 'background-color'),
		['e'],

		['s', '.'.$self->_css_class('paginator').' a'],
		$self->_css_colors_optional('other_color', 'color'),
		$self->_css_colors_optional('other_background', 'background-color'),
		['e'],

		['s', '.'.$self->_css_class('paginator-selected')],
		['d', 'background-color', $self->{'css_colors'}->{'actual_background'}],
		['d', 'color', $self->{'css_colors'}->{'actual_color'}],
		['e'],
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

sub _css_colors_optional {
	my ($self, $css_color, $css_key) = @_;

	return defined $self->{'css_colors'}->{$css_color}
		? (['d', $css_key, $self->{'css_colors'}->{$css_color}])
		: ();
}

1;
