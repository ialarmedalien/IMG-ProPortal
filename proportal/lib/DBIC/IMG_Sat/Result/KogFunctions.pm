use utf8;
package DBIC::IMG_Sat::Result::KogFunctions;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Sat::Result::KogFunctions

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<KOG_FUNCTIONS>

=cut

__PACKAGE__->table("KOG_FUNCTIONS");

=head1 ACCESSORS

=head2 kog_id

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 functions

  data_type: 'varchar2'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "kog_id",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "functions",
  { data_type => "varchar2", is_nullable => 1, size => 10 },
);

=head1 RELATIONS

=head2 kog

Type: belongs_to

Related object: L<DBIC::IMG_Sat::Result::Kog>

=cut

__PACKAGE__->belongs_to(
  "kog",
  "DBIC::IMG_Sat::Result::Kog",
  { kog_id => "kog_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-10 22:41:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hOPuURxCHTERlk7XARv03A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;