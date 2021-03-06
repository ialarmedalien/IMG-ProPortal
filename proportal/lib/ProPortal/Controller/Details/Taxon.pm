package ProPortal::Controller::Details::Taxon;

use IMG::Util::Import 'Class'; #'MooRole';

extends 'ProPortal::Controller::Filtered';

has '+page_id' => (
	default => 'details/taxon'
);

has '+page_wrapper' => (
	default => 'layouts/default_wide.tt'
);

has '+filter_domains' => (
	default => sub {
		return [ qw( taxon_oid ) ];
	}
);

=head3 render

Details page for a taxon / metagenome

@param taxon_oid

=cut

sub _render {
	my $self = shift;
	return {
		results => {
			taxon => $self->get_data( @_ ),
		}
	};
}

sub get_data {
	my $self = shift;
	my $args = shift;

	if ( ! $args || ! $args->{taxon_oid} ) {
		$self->choke({
			err => 'missing',
			subject => 'taxon_oid'
		});
	}

	my $res = $self->_core->run_query({
		query => 'taxon_details',
		-where => $args
	});

	if ( scalar @$res != 1 ) {
		$self->choke({
			err => 'no_results',
			subject => 'IMG taxon ' . ( $args->{taxon_oid} || 'unspecified' )
		});
	}
	$res = $res->[0];

	my $extra_args = {
		scaffolds => { -columns => [ 'scaffold_oid', 'scaffold_name' ], -order_by => 'scaffold_oid' },
	};

	my $associated = [ qw(
		analysis_project
		gold_sp_cell_arrangements
		gold_sp_collaborators
		gold_sp_diseases
		gold_sp_energy_sources
		gold_sp_genome_publications
		gold_sp_habitats
		gold_sp_metabolisms
		gold_sp_phenotypes
		gold_sp_relevances
		gold_sp_seq_centers
		gold_sp_seq_methods
		gold_sp_study_gold_ids
		scaffolds
		taxon_ext_links
		taxon_stats
	)];
# 		goldanaproj

	for my $assoc ( @$associated ) {
		if ( $res->can( $assoc ) ) {
			$res->expand( $assoc, ( %{ $extra_args->{$assoc} || {} } ) );
		}
	}

	return $res;
}

sub examples {
	return [{
		url => '/details/taxon/$img_taxon_oid',
		desc => 'metadata for taxon <var>$img_taxon_oid</var>'
	},{
		url => '/details/taxon/640069325',
		desc => 'metadata for taxon IMG:640069325, <i>Prochlorococcus</i> sp. NATL1A'
	}];
}

1;
