use utf8;
package DBIC::IMG_Core::Result::DtFuncsOb;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Core::Result::DtFuncsOb

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<DT_FUNCS_OBS>

=cut

__PACKAGE__->table("DT_FUNCS_OBS");

=head1 ACCESSORS

=head2 func_db

  data_type: 'varchar2'
  is_nullable: 1
  size: 20

=head2 func_id

  data_type: 'varchar2'
  is_nullable: 1
  size: 100

=head2 func_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "func_db",
  { data_type => "varchar2", is_nullable => 1, size => 20 },
  "func_id",
  { data_type => "varchar2", is_nullable => 1, size => 100 },
  "func_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:04:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KStd62iqC9Izc+5dmyUqFw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
