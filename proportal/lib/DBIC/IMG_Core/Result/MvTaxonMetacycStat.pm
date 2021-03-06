use utf8;
package DBIC::IMG_Core::Result::MvTaxonMetacycStat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Core::Result::MvTaxonMetacycStat

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<MV_TAXON_METACYC_STAT>

=cut

__PACKAGE__->table("MV_TAXON_METACYC_STAT");

=head1 ACCESSORS

=head2 taxon_oid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,0]

=head2 pwy_id

  data_type: 'varchar2'
  is_nullable: 0
  size: 255

=head2 pathway_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 gene_count

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=cut

__PACKAGE__->add_columns(
  "taxon_oid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "pwy_id",
  { data_type => "varchar2", is_nullable => 0, size => 255 },
  "pathway_name",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "gene_count",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:04:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bj+ORl0T0K2xp5QWDVuk1g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
