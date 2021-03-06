#!/usr/bin/env perl

my @dir_arr;
BEGIN {
	use File::Spec::Functions qw( rel2abs catdir );
	use File::Basename qw( dirname basename );
	my $dir = dirname( rel2abs( $0 ) );
	while ( 'webUI' ne basename( $dir ) ) {
		$dir = dirname( $dir );
	}
	@dir_arr = map { catdir( $dir, $_ ) } qw( proportal/lib );
}

use lib @dir_arr;
use IMG::Util::Import 'LogErr';
use Dancer2;
use ProPortal::App::PhyloViewerPageGenerator;
use Getopt::Long;
use Carp::Always;

my $args = {};
GetOptions(
	$args,
	"outfile|o=s",
	"gene_taxon_file|g=s",
#	"gene_taxon_format|s",
	"metadata|m=s",
#	"metadata_format|s",
	"newick|n=s",
	"test|t"         # flag for test mode
) or script_die( 255, [ "Error in command line arguments" ] );

eval {

	ProPortal::App::PhyloViewerPageGenerator->new(
		dancer_config => config,
		args => $args,
		controller => 'ProPortal::Controller::PhyloViewer::Results'
	)->run();

};

script_die( 255, [ $@ ] ) if $@;

exit(0);

