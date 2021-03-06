use utf8;
package DBIC::IMG_Core::Result::DtBc2ec;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Core::Result::DtBc2ec

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<DT_BC2EC>

=cut

__PACKAGE__->table("DT_BC2EC");

=head1 ACCESSORS

=head2 taxon_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 cluster_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 gene_id

  data_type: 'varchar2'
  is_nullable: 1
  size: 50

=head2 ec_number

  data_type: 'varchar2'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "taxon_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "cluster_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "gene_id",
  { data_type => "varchar2", is_nullable => 1, size => 50 },
  "ec_number",
  { data_type => "varchar2", is_nullable => 1, size => 50 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:04:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:flvapM+gRIWOA9USdr5Z5A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
