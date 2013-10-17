#!/usr/bin/env perl

use strict;
use warnings;

#$ENV{DBIC_TRACE} = 1;
#$ENV{DBIC_TRACE_PROFILE} = 'console';

use Test::More;    # tests => ?;

use Rhymenocerous;
my $r = Rhymenocerous->new();

foreach (
	'Roses are red, violets are blue,',    #
	'I am typing here.',                   #
	'This is my sentence.',                #
	'Happy valentines day to you!',        #
  )
{
	do_rhyme($_);
}

sub do_rhyme {
	my $str = shift;
	diag $str;
	diag $r->gen_rhyme($str);
}

done_testing();

