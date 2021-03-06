use utf8;
package DBIC::IMG_Core::Result::BcType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Core::Result::BcType

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<BC_TYPE>

=cut

__PACKAGE__->table("BC_TYPE");

=head1 ACCESSORS

=head2 bc_code

  data_type: 'varchar2'
  is_nullable: 0
  size: 255

=head2 bc_desc

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=cut

__PACKAGE__->add_columns(
  "bc_code",
  { data_type => "varchar2", is_nullable => 0, size => 255 },
  "bc_desc",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:04:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YEVnjeQ06OutsytOPixLDg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
