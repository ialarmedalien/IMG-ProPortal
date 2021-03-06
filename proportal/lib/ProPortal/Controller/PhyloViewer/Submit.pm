package ProPortal::Controller::PhyloViewer::Submit;

use IMG::Util::Import 'MooRole';

has 'controller_args' => (
	is => 'lazy',
	default => sub {
		return {
			class => 'ProPortal::Controller::Base',
			tmpl => 'pages/proportal/phylo_viewer/query.tt',
			tmpl_includes => {
#				tt_scripts => qw( data_type )
			}
		};
	}
);

with qw( ProPortal::Controller::PhyloViewer::DemoData ProPortal::Controller::PhyloViewer::Schema ProPortal::Controller::PhyloViewer::Pipeline );

=head3 render

Validate the PhyloViewer form and set up the workflow

=cut

sub _render {
	my $self = shift;
	my $params = shift;

	$self->validate( $params );

	my $q_id = $self->init_pipeline( $params );

	return { results => {
		query_id => $q_id
	} };
}

=head3 validate

Ensure our query parameters are correct;

=cut

sub validate {
	my $self = shift;
	my $params = shift;

	die 'To be implemented!';

	# validate the parameters
	my $validator = JSON::Validator->new;

	$validator->schema( $self->get_query_schema );

	my @errors = $validator->validate( $params );

	if ( @errors ) {

		die @errors;

	}
}


1;
