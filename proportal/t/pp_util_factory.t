#!/usr/bin/env perl

BEGIN {
	use File::Spec::Functions qw( rel2abs catdir );
	use File::Basename qw( dirname basename );
	my $dir = dirname( rel2abs( $0 ) );
	while ( 'webUI' ne basename( $dir ) ) {
		$dir = dirname( $dir );
	}
	our @dir_arr = map { catdir( $dir, $_ ) } qw( webui.cgi proportal/lib proportal/t/lib );
}
use lib @dir_arr;
use IMG::Util::Import 'Test';

use IMG::Util::Factory;
use ProPortal::Util::Factory;

my $c = IMG::Util::Factory::create( 'IMG::Util::Import' );
isa_ok $c, 'IMG::Util::Import';

my $l = ProPortal::Util::Factory::create_pp_component( 'model', 'filter', { id => 'test', type => 'slider', label => 'test filter' });
isa_ok $l, 'ProPortal::Model::Filter';
ok( $l->type eq 'slider' && $l->label eq 'test filter', "checking component values" );

like(
	exception { my $x = IMG::Util::Factory::create('A::Made::Up::Class', { args => 'here' } ); },
	qr{Unable to load class A::Made::Up::Class:},
	'Failure to create nonsense class'
);

like(
    exception { my $l = ProPortal::Util::Factory::create_pp_component( unknown => 'stuff' ) },
    qr{Unable to load class ProPortal::Unknown::Stuff:},
    'Failure to load nonexistent class',
);

done_testing;
