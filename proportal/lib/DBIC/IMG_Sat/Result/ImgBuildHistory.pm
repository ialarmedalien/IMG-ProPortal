use utf8;
package DBIC::IMG_Sat::Result::ImgBuildHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Sat::Result::ImgBuildHistory

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<IMG_BUILD_HISTORY>

=cut

__PACKAGE__->table("IMG_BUILD_HISTORY");

=head1 ACCESSORS

=head2 build_oid

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: [16,0]

=head2 build_number

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: [16,0]

=head2 build_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 release_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 img_version

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 seq_dir

  data_type: 'varchar2'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "build_oid",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "build_number",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "build_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "release_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "img_version",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "seq_dir",
  { data_type => "varchar2", is_nullable => 1, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</build_oid>

=back

=cut

__PACKAGE__->set_primary_key("build_oid");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-10 22:41:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:51Jdtw230M2YMApVQkyH9g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
