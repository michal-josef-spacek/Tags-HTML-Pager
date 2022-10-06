#!/usr/bin/env perl

use strict;
use warnings;

use Tags::HTML::Pager::Utils qw(pages_num);

# Input informations.
my $images_count = 123;
my $images_on_page = 20;

# Compute.
my $pages_num = pages_num($images_count, $images_on_page);

# Print out.
print "Images count: $images_count\n";
print "Images on page: $images_on_page\n";
print "Number of pages: $pages_num\n";

# Output:
# Images count: 123
# Images on page: 20
# Number of pages: 7 