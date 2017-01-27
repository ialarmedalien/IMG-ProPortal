package ProPortal::Controller::Clade;

use IMG::Util::Import 'Class'; #'MooRole';

use Template::Plugin::JSON::Escape;

extends 'ProPortal::Controller::Filtered';

with 'IMG::Util::Text';

# has 'controller_args' => (
# 	is => 'lazy',
# 	default => sub {
# 		return {
# #			class => 'ProPortal::Controller::Filtered',
# 			page_id => 'proportal/clade',
# 			tmpl => 'pages/proportal/clade.tt',
# 			tmpl_includes => {
# 				tt_scripts => qw( clade ),
# 				tt_styles  => qw( clade ),
# 			},
# 			filters => {
# 				subset => 'coccus'
# 			},
# 			valid_filters => {
# 				subset => {
# 					enum => [ qw( prochlor synech coccus ) ],
# 				}
# 			},
# 		};
# 	}
# );


has '+page_id' => (
	default => 'proportal/clade'
);

# has '+tmpl' => (
# 	default => 'pages/proportal/clade.tt',
# );
#
has '+tmpl_includes' => (
	default => sub {
		return {
			tt_scripts => qw( clade ),
			tt_styles  => qw( clade ),
		};
	}
);

has '+filters' => (
	default => sub {
		return { subset => 'coccus' };
	}
);

has '+valid_filters' => (
	default => sub {
		return {
			subset => {
				enum => [ qw( prochlor synech coccus ) ]
			}
		};
	}
);

=head3 render

Requires JSON plugin for rendering data set

=cut

my $render_sub = sub {
	my $self = shift;

#	say 'self: ' . Dumper $self;

	# get all distinct clade names
	my $clades = $self->_core->run_query({
		query => 'distinct_clade',
		filters => { subset => 'coccus' }
	});

#	say 'Clades: ' . Dumper $clades;

	my $data;
	my $clade_h;

	for my $c ( @$clades ) {
		$data->{ $c->{genus} }{ $c->{generic_clade} } = {
			id => 'clade_' . $self->make_text_web_safe( $c->{generic_clade} ),
			label => $c->{generic_clade},
			genus => $c->{genus},
			genomes => [],
		};
		$clade_h->{ $c->{generic_clade} }++;
	}

	my $res = $self->get_data();

	for my $r (@$res) {
		# collect genomes by the generic clade name
		push @{$data->{ $r->{genus} }{ $r->{generic_clade} }{genomes}}, $r;
	}

	return { results => {
		js => { data => $data, clade_arr => [ sort keys %$clade_h ] }
	} };

};

my $get_data_sub = sub {
#sub get_data {
	my $self = shift;
	my $res = $self->_core->run_query({
		query => 'clade',
		filters => $self->filters,
	});

#	return $res;
#	only required for badly-populated dbs
	return [ grep { $_->{clade} =~ /\w/ } @$res ];
#}
};

sub _render {
	return $render_sub->( @_ );
}

sub get_data {
	return $get_data_sub->( @_ );
}

1;

