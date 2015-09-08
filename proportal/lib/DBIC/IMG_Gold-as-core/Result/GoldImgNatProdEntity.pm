use utf8;
package DbSchema::IMG_Core::Result::GoldImgNatProdEntity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DbSchema::IMG_Core::Result::GoldImgNatProdEntity

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DbSchema>

=cut

use base 'DbSchema';

=head1 TABLE: C<GOLD_IMG_NAT_PROD_ENTITY>

=cut

__PACKAGE__->table("GOLD_IMG_NAT_PROD_ENTITY");

=head1 ACCESSORS

=head2 gold_np_id

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: 126

=head2 np_id

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: 126

=head2 project_oid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 img_oid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 bio_cluster_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 evidence

  data_type: 'varchar2'
  default_value: 'Experimental'
  is_nullable: 0
  size: 20

=head2 activity

  data_type: 'varchar2'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "gold_np_id",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => 126,
  },
  "np_id",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => 126,
  },
  "project_oid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "img_oid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "bio_cluster_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "evidence",
  {
    data_type => "varchar2",
    default_value => "Experimental",
    is_nullable => 0,
    size => 20,
  },
  "activity",
  { data_type => "varchar2", is_nullable => 1, size => 128 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gold_np_id>

=back

=cut

__PACKAGE__->set_primary_key("gold_np_id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-06-23 13:17:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:txuBPU6Bpi06bEzTytWiNg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;