#!/usr/bin/env perl

use FindBin qw/ $Bin /;
use lib ( "$Bin/..", "$Bin/../../proportal/lib", "$Bin/lib" );
use IMG::Util::Base 'Test';

plan tests => 1;

BEGIN {
    use_ok( 'IMaGene' ) || print "Bail out!\n";
}

diag( "Testing IMaGene, Perl $], $^X" );
