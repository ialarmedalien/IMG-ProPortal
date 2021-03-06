package ProPortal::Controller::Home;

use IMG::Util::Import 'Class'; #'MooRole';

extends 'ProPortal::Controller::Filtered';

has '+valid_filters' => (
	default => sub {
		return {
			pp_subset => {
				enum => [ qw( pro syn pro_phage syn_phage other other_phage pp_isolate ) ],
			}
		};
	}
);

has '+page_id' => (
	default => 'proportal'
);

has '+tmpl' => (
	default => 'pages/proportal/home.tt'
);

has '+page_wrapper' => (
	default => 'layouts/default_wide.tt'
);

=head3 stats



=cut

sub _render {
	my $self = shift;
	my $data;

	my $stats;

	# counts, grouped by proportal pp_subset
	$stats->{pp_subsets} = $self->_core->schema('img_core')->table('VwGoldTaxon')
		->select(
			-columns => [ 'pp_subset', 'count(taxon_oid)|count' ],
			-group_by => 'pp_subset',
			-where => {
				pp_subset => { '!=', undef },
			},
			-result_as => ['hashref' => 'pp_subset' ]
		);

	# counts, grouped by proportal pp_subset
	$stats->{dataset_type} = $self->_core->schema('img_core')->table('PpDataTypeView')
		->select(
			-columns => [ 'dataset_type', 'count(*)|count' ],
			-group_by => 'dataset_type',
			-where => {
				pp_subset => { '!=', undef },
			},
			-result_as => ['hashref' => 'dataset_type' ]
		);

	return { results => {
		stats => $stats
	} };
}

1;
