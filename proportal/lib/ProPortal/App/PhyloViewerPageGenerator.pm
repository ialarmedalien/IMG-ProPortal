{
	package ScriptAppArgs;
	use IMG::Util::Import 'Class';
	use Getopt::Long qw( GetOptionsFromArray );
	with 'IMG::App::Role::ErrorMessages';
	use IMG::Util::File;

	has 'gene_taxon_file' => (
		is => 'ro',
		isa => sub {
			if ( ! -r $_[0] ) {
				die 'gene taxon file ' . $_[0] .
				( -e $_[0]
					? ' is not readable'
					: ' does not exist' );
			}
		}
	);

	has 'newick' => (
		is => 'ro',
		isa => sub {
			if ( ! -r $_[0] ) {
				die 'Newick file ' . $_[0] .
				( -e $_[0]
					? ' is not readable'
					: ' does not exist' );
			}
		}
	);

	has 'metadata' => (
		is => 'ro',
		isa => sub {
			if ( ! -r $_[0] ) {
				die 'Metadata file ' . $_[0] .
				( -e $_[0]
					? ' is not readable'
					: ' does not exist' );
			}
		}
	);

	has 'outfile' => (
		is => 'ro',
		required => 1,
		coerce => sub {
			open my $fh, ">", $_[0] or die err({
				err => 'not_writable',
				subject => $_[0],
				msg => $!
			});
			return $fh;
		}
	);

	has 'test' => (
		is => 'ro',
		isa => Bool
	);

	1;
}

package ProPortal::App::PhyloViewerPageGenerator;

use IMG::Util::Import 'Class';
use ScriptAppArgs;
extends 'IMG::App';
with qw(
	IMG::App::Role::Controller
	ProPortal::IO::DBIxDataModel
	ProPortal::Controller::PhyloViewer::Pipeline
	IMG::Util::ScriptApp
);

sub run {
	my $self = shift;

	my $rslts = $self->controller->render( $self->args );
	log_debug { 'Done rendering!' };

	$rslts->{settings} = $self->config;
	$rslts->{page_wrapper} = 'layouts/contents_only.tt';
	$rslts = $self->get_tmpl_vars({ output => $rslts });

	print { $self->args->outfile } $self->render_template({
		tmpl_args => {
			%{$self->config->{engines}{template}{template_toolkit}},
			INCLUDE_PATH => $self->config->{views}
		},
		tmpl_data => $rslts,
		tmpl => 'pages/proportal/phylo_viewer/results.tt'
	});

}

1;
