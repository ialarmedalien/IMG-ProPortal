############################################################################
#	IMG::App::DispatchCore.pm
#
#	Core dispatcher code
#
#	$Id: DispatchCore.pm 34176 2015-09-03 19:41:14Z aireland $
############################################################################
package IMG::App::DispatchCore;

use IMG::Util::Base;

use Class::Load ':all';

=head3 prepare_dispatch_coderef

Load the module and prepare a coderef for dispatch

@param  arg_h   with keys
          module    - module to load
          sub       - function to execute

@return  $to_do  coderef to execute

=cut

sub prepare_dispatch_coderef {
	my $arg_h = shift;

	my $module = $arg_h->{module} || croak "No module defined!";
	my $sub = $arg_h->{sub} || croak "No sub defined!";

	my ($ok, $err) = try_load_class( $module );
	$ok or croak "Unable to load class " . $module . ": $err";

	# make sure that we can run the sub:
	if ( ! $module->can( $sub ) ) {
		croak "$module does not have $sub implemented!";
	}

#	warn "Loaded module OK!";

	my $to_do;
	if (! ref $sub ) {
		warn "Setting to_do to " . $module .'::' . $sub;
		$to_do = \&{ $module .'::' . $sub };
	}
	else {
		$to_do = $sub;
	}

	return $to_do;

}

=cut
sub paramMatch {

	my $req = shift;
	my $p = shift;

	carp "running paramMatch: p: $p";

	for my $k ( keys %{$req->params} ) {
		return $k if $k =~ /$p/;
	}
	return undef;

}

sub is_valid_module {
	my $m = shift;
	my $valid = valid_modules();
	for (@$valid) {
		# untaint
		return $_ if $_ eq $m;
	}
	return 0;
}

sub valid_modules {
	return [];
}
=cut

1;
