#!/usr/bin/env perl

use strict;
use warnings;

use Tags::HTML::Pager::Utils qw(pages_num);

# Input informations.
my $items = 123;
my $images_on_page = 20;

# Compute.
my $pages = pages_num($items, $images_on_page);

# Print out.
print "Images on page: $images_on_page\n";
print "Items count: $items\n";
print "Number of pages: $pages\n";

# Output:
# Images on page: 20
# Items count: 123
# Number of pages: 7 