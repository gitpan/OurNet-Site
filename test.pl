#!/usr/bin/perl -w
use strict;
use Test;
use vars qw/%sites %found/;

# use a BEGIN block so we print our plan before MyModule is loaded

BEGIN {
    %sites = map {
        (substr($_, rindex($_, '/') + 1) => $_)
    } map {
        glob("$_/OurNet/Site/*.tt2")
    } @INC;

    plan tests => (scalar keys %sites) * 2;
}

use OurNet::Query;

my ($query, $hits) = ('autrijus', 10);

while (my ($site, $file) = each %sites) {
    # Generate a new Query object
    ok(my $query = OurNet::Query->new($query, $hits, $file));

    # Perform a query
    my $found = $query->begin(\&callback, 30); # Timeout after 30 seconds

    ok($found);
}

sub callback {
    local $^W;

    my %entry = @_;
    my $entry = \%entry;

    unless ($found{$entry{url}}++) {
	print "[$entry->{title}]\n=> $entry->{url}\n\n";
    }
}

