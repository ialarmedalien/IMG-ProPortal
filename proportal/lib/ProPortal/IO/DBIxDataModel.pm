package ProPortal::IO::DBIxDataModel;

use IMG::Util::Import 'MooRole';

use Time::HiRes;
use IMG::Model::UnitConverter;

use DBIx::DataModel;

use DataModel::IMG_Core;
use DataModel::IMG_Gold;

requires 'schema', 'choke';

with 'ProPortal::IO::DBIxDataModelQueryLib';

has 't0' => (
	is => 'lazy',
);

sub _build_t0 {
	my $self = shift;
	return Time::HiRes::gettimeofday;
}

has 'query_library' => (
	is => 'lazy',
	default => sub {
		my $self = shift;
		my $ql = ProPortal::IO::DBIxDataModelQueryLibrary->new( _core => $self );
		return $ql;
	}
);


=head3 run_query

Run a database query

If there is no database handle set, takes care of doing the login first

This is a thin wrapper around DBIx::DataModel; see that module for
specifics on how to write specific SQL.

https://metacpan.org/pod/DBIx::DataModel

The queries themselves are in ProPortal::IO::DBIxDataModelQueryLib

@param $args    hashref with keys

    query     the name of the query to be run
              (i.e. the name of the method in this package)

    filters       (optional) hashref of standardised filters,
                  e.g. implemented by ProPortalFilters

    check_results (optional) run check_results on the db results
                  specify params for check_results as hashref, i.e.

                  check_results => {
                  	param => 'taxon_oid',
                  	query => [ 123, 456, 789 ],
                  	subject => 'taxon_oids'
                  }

    -where     the query parameter(s), e.g.
               { taxon_oid => [ 123, 456, 789 ] }

    -return_as    (optional) return the statement object in a specific
                  format, e.g. result_as => 'flat_arrayref'
                  see DBIx::DataModel for options

	TODO: count results, return paged results

@return $output - returns $statement->all unless return_as is specified

=cut

sub run_query {
	my $self = shift;

	# set the timer
	$self->t0;

	my $args;
	if ( @_ && 1 < scalar( @_ ) ) {
		$args = { @_ } ;
	}
	else {
		$args = shift;
	}

	#	query is the name of the method to run
	#	args->{params} will contain filter params

	# get the query as a statement
	my $stt = $self->get_query( $args );

	return unless defined $stt;
#	log_debug { 'statement status: ' . $stt->status };

	if ( $args->{check_results} ) {
		return $self->check_results({
			results => $stt->all,
			%{$args->{check_results}}
		});
	}

	## is this stuff even used any more?!
	my @valid_result_as = ( qw( rows firstrow hashref sth sql subquery statement
		flat_arrayref fast_statement ) );

#	log_debug { 'result as: ' . Dumper $args->{result_as} };
#	log_debug { 'statement is a ' . $stt };

	if ( $args->{result_as} && 'html' ne $args->{result_as} ) {
		return $stt->refine( -result_as => 'statement' );
	}
	elsif ( $args->{-result_as} ) {
		return $stt->refine( -result_as => $args->{-result_as} );
	}

#	log_debug { 'statement: ' . Dumper $stt };

	return $stt->all;

}


=head2 check_results

Make sure that we got all the results we were hoping for!

@param $args    hashref with keys

	param    - parameter of the result objects to examine
	query    - arrayref containing the original query
	results  - arrayref of results (from run_query or elsewhere)
	subject  - human-readable string representing param
	           (for the error message)

@return     dies on failure with an error message

=cut

sub check_results {
	my $self = shift;
	my $args = shift;

	for ( qw( param query results subject ) ) {
		if ( ! defined $args->{$_} ) {
			$self->choke({
				err => 'missing',
				subject => 'check_results parameter "' . $_ . '"'
			});
		}
	}

	if ( ! scalar @{$args->{results}} ) {
		$self->choke({
			err => 'no_results',
			subject => $args->{subject}
		});
	}
	my $results = $args->{results};
	my %all;

	@all{ @{$args->{ query } } } = ( 1 ) x scalar @{ $args->{query} };

	for ( @$results ) {
		delete $all{ $_->{ $args->{param} } };
	}

	if ( keys %all ) {
		$self->choke({
			err => 'missing_results',
			subject => $args->{subject},
			ids => [ keys %all ]
		});
	}
	return $results;
}

1;
