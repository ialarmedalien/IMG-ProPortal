package IMG::Util::FileAppender;

use IMG::Util::Import 'MooRole';
use IMG::Util::File qw( :all );
use Text::CSV_XS;

with 'IMG::App::Role::ErrorMessages';

# the columns required in the header of the tabular file
has 'cols_reqd' => (
	is => 'rwp',
	builder => 1
);

sub _build_cols_reqd {
	shift->choke({
		err => 'missing',
		subject => 'required input file columns'
	});
}

# what information we want to pull out of the tabular file to run the query
# should be a coderef
has 'index_by' => (
	is => 'lazy',
#	builder => 1
);

sub _build_index_by {
	my $self = shift;
	my $cols = $self->cols_reqd;
	if ( 1 == scalar @$cols ) {
		# single column
		my $sub = sub {
			return shift->{ $cols->[0] };
		};
	}
	else {
		my $sub = sub {
			my $h = shift;
			return join "\0", map { $h->{$_} // "" } @$cols;
		};
	}
}

# arguments for Text::CSV_XS->new()
has 'csv_args' => (
	is => 'rwp',
	builder => 1,
	isa => HashRef
);

sub _build_csv_args {
	return {
		binary => 1
	};
}

# CSV reader
has 'csv_obj' => (
	is => 'lazy'
);

sub _build_csv_obj {
	my $self = shift;
	return Text::CSV_XS->new ({
		%{$self->csv_args},
		auto_diag => 2,
	});
}

# the input file
has 'csv_input_file' => (
	is => 'rwp',
	builder => 1
);

# no way to build the input file from scratch => die
sub _build_csv_input_file {
	shift->choke({
		err => 'missing',
		subject => 'CSV input file'
	});
}

has 'csv_input_fh' => (
	is => 'lazy',
);

sub _build_csv_input_fh {
	my $self = shift;
	open my $fh, "<", $self->csv_input_file or $self->choke({
		err => 'not_readable', subject => $self->csv_input_file, msg => $!
	});
	return $fh;
}


# the output file
has 'csv_output_file' => (
	is => 'rwp',
	builder => 1
);

# no way to build the output file from scratch => die
sub _build_csv_output_file {
	shift->choke({
		err => 'missing',
		subject => 'CSV output file'
	});
}

# array of headers from the input file
# generated by the role
has 'headers' => (
	is => 'rwp',
	predicate => 1,
	builder => 1,
#	lazy => 1
);

sub _build_headers {
	my $self = shift;

	# get the columns and infile now in case there's a problem
	my $cols = $self->cols_reqd;
	my $inf = $self->csv_input_fh;

	local $@;
	my @hdr = eval { $self->csv_obj->header( $inf ) };
	# die if there is an error parsing the header
	if ( $@ ) {
		say 'found $@';
#
# 		say Dumper $self->csv_obj->error_diag();
# 		say Dumper $@;
#
		$self->choke({
			err => 'module_err',
			subject => 'Text::CSV_XS',
			msg => "" . $self->csv_obj->error_diag()
		});
	}

	# make sure we have all the cols we need
	my %all_cols = map { $_ => 1 } @hdr;
	my @missing;
	for ( @$cols ) {
		push @missing, $_ if ! $all_cols{$_};
	}
	if ( @missing ) {
		$self->choke({
			err => 'not_found_in_file',
			subject => 'column header(s) ' . join(', ',
			#	map { '"' . $_ . '"' }
				sort @missing),
			file => $self->csv_input_file
		});
	}

	# otherwise, we can set the headers!
	return \@hdr;
}

# the lines in the existing file
# generated by the role
has 'lines' => (
	is => 'rwp',
);

# index to the lines
# generated by the role
has 'line_index' => (
	is => 'rwp'
);

# headers for the output file
has 'output_headers' => (
	is => 'rwp'
);

=head3

Extract the data that we need to run the query

=cut

sub extract {
	my $self = shift;

	my %row = ();
	my $ids;
	$self->csv_obj->bind_columns( \@row{ @{$self->headers} } );
	my $line_no = 0;
	my $line_ix = { by_ix => {} };
	while ( $self->csv_obj->getline( $self->csv_input_fh ) ) {
		my %temp = ();
		@temp{ keys %row } = values %row;
		my $ix = $self->index_by->( {%row} );

		if ( exists $line_ix->{by_ix}{ $ix } ) {
			push @{$line_ix->{by_ix}{ $ix }}, $line_no;
		}
		else {
			$line_ix->{by_ix}{ $ix } = [ $line_no ];
		}

		push @{$line_ix->{line_data_arr}}, \%temp;
		$line_ix->{by_line_no}{ $line_no } = $ix;
		$line_no++;
	}
	$self->_set_lines( $line_ix->{line_data_arr} );
	$self->_set_line_index( { by_line_no => $line_ix->{by_line_no}, by_ix => $line_ix->{by_ix} } );
	return [ keys %{$line_ix->{by_ix}} ];
}

=head3 reintegrate

Combine the new results with the previous data, ready for printing! Updates $self->lines with the updated data

@param	$args hashref with keys

	data => {
		hashref of data to integrate with the existing data set in $self->lines
		keys are the index
	}

	OR

	data_arr => {
		array of hashrefs of data (e.g. from database query)
	}


@return	arrayref of data hashes


=cut

sub reintegrate {
	my $self = shift;
	my $args = shift;
	if ( ! $args->{data} && ! $args->{data_arr} ) {
		$self->choke({
			err => 'missing',
			subject => 'data'
		});
	}

	my $lines = $self->lines;

	if ( $args->{data} ) {
		# this data is indexed by $self->index_by. Combine hashes!
		for my $k ( keys %{$args->{data}} ) {
			if ( ! $self->line_index->{by_ix}{ $k } ) {
				# this should not happen!
				warn 'Incorrect data: ' . $k ;
				next;
			}
			# find all lines and merge in this data
			for my $l ( @{$self->line_index->{by_ix}{$k}} ) {
				$lines->[$l] = { %{$lines->[$l]}, %{$args->{data}{$k}} };
			}
		}
	}
	elsif ( $args->{data_arr} ) {
		# arrayref of hashrefs. Need to run $self->index_by on each hashref
		for my $item ( @{$args->{data_arr}} ) {
			my $ix = $self->index_by->( $item );
			if ( ! $self->line_index->{by_ix}{ $ix } ) {
				# this should not happen!
				warn 'Incorrect data: ' . $ix ;
				next;
			}
			# find all lines and merge in this data
			for my $l ( @{$self->line_index->{by_ix}{$ix}} ) {
				$lines->[$l] = { %{$lines->[$l]}, %$item };
			}
		}
	}

	$self->_set_lines( $lines );
	return $lines;
}

=head3

Reintegrate the results with the data we've gathered and print to $self->output_file

@param	$args hashref with keys

	data => { }   # data to integrate into the existing data set

@return

=cut

sub expel {
	my $self = shift;
	my $args = shift;
	my $rslts = $self->reintegrate( $args );

	# write out the file
	IMG::Util::File::write_csv({
		csv_obj  => $self->csv_obj,
		file     => $self->csv_output_file,
		cols     => [ @{$self->output_headers} ],
		data_arr => $rslts
	});

}

1;

=pod

=encoding UTF-8

=head1 NAME

IMG::Util::FileAppender

This module is used by applications which pull in a tabular data file and add columns to that file.

Arguments:

	csv_input_file => $infile    # input CSV/TSV file

	csv_args => { sep => "\t" }  # arguments for parsing input file with Text::CSV_XS

	cols_reqd => [ 'taxon_oid' ] # arrayref of cols in the input file that denote unique entities

	csv_output_file => $outfile  # output file

	data_arr => [ arrayref of hashrefs ]    # data to merge into the input data
	OR
	data => { hashrefs of data, keyed by $self->index_by }



=cut

