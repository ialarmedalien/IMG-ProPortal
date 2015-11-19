package IMG::App::Role::DbConnection;

use IMG::Util::Base 'MooRole';
use IMG::Util::DBIxConnector;
use IMG::Util::Timed qw( time_this );

=pod

=encoding UTF-8

=head1 NAME

IMG::App::Role::DbConnection - Role for creating database connections

Database connections use DBIx::Connector; to use the DB handle, call $conn->dbh

=head2 SYNOPSIS

in IMG::App::Demo:

	package IMG::App::Demo;

	use IMG::Util::Base 'Class';
	extends 'IMG::App::Core';
	with 'IMG::App::Role::DbConnection';

	1;

in a script:

	use IMG::App::Demo;

	my $app = IMG::App::Demo->new( config => $conf_h );

	# returns a DBIx::Connector object
	my $conn = $app->db_conn('my_test_db');

	my $results = $app->dbh('my_test_db')->selectall_arrayref('SELECT * FROM table');

=head3 Config format

Add database connection details to the config in the following format:

	$conf_h = {
		db => {
			db_name => {
				driver =>   'Oracle',
				database => 'my_test_db',
				user =>     'admin',
				password => 'pass',
				dbi_params => {
					RaiseError => 1,
					FetchHashKeyName => 'NAME_lc',
				},
			},
			db_two  => {
				driver =>   'SQLite',
				database => 'test.db',
				dbi_params => {
					RaiseError => 1,
				}
			}
		}
	};

=cut

has 'db_connection_h' => (
	is => 'rw',
	isa => Map[ Str, Object ],
	lazy => 1,
	builder => 1,
	predicate => 1,
	clearer => 1,
	writer => 'set_db_connection_h',
);

requires 'config';

sub _build_db_connection_h {
	my $self = shift;
	if ( @_ && 1 < scalar @_ ) {
		return { @_ };
	}
	return +shift || {}
}

=head3 db_conn

Get a database connection; if the connection is not present, it will be created.

@param  $h  name of the connection

@return $connection
        dies if a parameter is missing or the connection cannot be created

=cut

sub db_conn {
	my $self = shift;
	my $h = shift || die "Specify a connection to return";
	return $self->db_connection_h->{$h} if $self->has_db_connection_h && $self->db_connection_h->{$h};
	return $self->create_db_conn( $h );
}

=head3 dbh

Get a database handle; if the connection is not present, it will be created.

@param  $h  name of the db connection

@return $dbh
        dies if a parameter is missing or the connection cannot be created

=cut

sub dbh {
	my $self = shift;
	my $h = shift || die "Specify a database to return a handle for";
	return $self->db_connection_h->{$h}->dbh if $self->has_db_connection_h && $self->db_connection_h->{$h};
	return $self->create_db_conn( $h )->dbh;
}

=head3 db_conn_no_create

Get an existing database connection

@param  $h  name of the connection

@return $connection
        undef if the connection does not exist
        dies if a parameter was not provided

=cut

sub db_conn_no_create {
	my $self = shift;
	my $h = shift || die "Specify a connection to return";
	return undef unless $self->has_db_connection_h;
	return $self->db_connection_h->{$h} || undef;
}


=head3 connection_for_schema

Given a schema (img_core or img_gold), get a connection to it

@param  $schema

@return $db_connection
        dies if there is no configuration data or the connection cannot be created

=cut

sub connection_for_schema {
	my $self = shift;
	my $schema = shift || die 'No schema specified';

	if ( ! $self->has_config || ! $self->config->{schema} || ! $self->config->{schema}{$schema} || ! $self->config->{schema}{$schema}{db} ) {
		die "No configuration data found for $schema";
	}

	# get the connection for this schema
	return $self->db_conn( $self->config->{schema}{$schema}{db} );
}



=head3 set_db_conn

Add a connection to the database connection hash

Will overwrite existing connections of the same name

@param   $dbh_name   name for the connection
@param   $dbh        the connection itself

@return  $self
         dies if a parameter is not provided or the name / connection are wrong

=cut

sub set_db_conn {
	my $self = shift;
	my ($dbh_name, $dbh) = (shift, shift);
	die "No name supplied for dbh" if ! $dbh_name;
	die "No database handle supplied" if ! $dbh;

	# this will die if the $dbh or $dbh_name are not of the correct type!
	$self->set_db_connection_h({ %{$self->db_connection_h || {} }, $dbh_name => $dbh });
	return $self;
}

=head3 create_db_conn

Create a database connection; also sets it in db_connection_h

@param  $h   name of the connection to create

@return $conn  db connection on success
        dies if parameters are not specified


=cut

sub create_db_conn {
	my $self = shift;
	my $h = shift || die "Specify a connection to create";

	# find the config and load it
	if (! $self->has_config || ! $self->config->{db} || ! $self->config->{db}{$h}) {
		die "No db conf found for $h";
	}

    # set the timeout
    my $to = $self->config->{db_connect_timeout} // 30;

    # TODO: make sure that db_connect_timeout is numeric!

	local $@;
    my $conn = time_this( $to,
        \&IMG::Util::DBIxConnector::get_dbix_connector,
        $self->config->{db}{$h}
    );
	if ( $@ ) {
		if ( $@ =~ /DB connection error/ ) {
			warn $@;
			return undef;
		}
		elsif ( $@ =~ /timeout/ ) {
		    die 'Timed out while attempting to connect to database ' . $h;
		}
		else {
			# programmer problem
			die $@;
		}
	}
	$self->set_db_conn( $h, $conn );
	return $conn;
=uses of 'around'
	my $orig = shift;
    my $self = shift;
    $orig->($self, reverse @_);

# OR
	my $orig = shift;
	do_something( $orig->(@_) );
=cut

}

1;
