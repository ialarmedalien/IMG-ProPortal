use utf8;
package DBIC::IMG_Core::Result::GeneLipoPeptide;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Core::Result::GeneLipoPeptide

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<GENE_LIPO_PEPTIDES>

=cut

__PACKAGE__->table("GENE_LIPO_PEPTIDES");

=head1 ACCESSORS

=head2 gene_oid

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: [16,0]

=head2 predict_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 30

=head2 feature_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 30

=head2 start_coord

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,0]

=head2 end_coord

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,0]

=head2 score

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,5]

=head2 seq_context

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "gene_oid",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "predict_type",
  { data_type => "varchar2", is_nullable => 1, size => 30 },
  "feature_type",
  { data_type => "varchar2", is_nullable => 1, size => 30 },
  "start_coord",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "end_coord",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "score",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 5],
  },
  "seq_context",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:04:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FanH8YAYJH4zkB/0H8bhCw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;