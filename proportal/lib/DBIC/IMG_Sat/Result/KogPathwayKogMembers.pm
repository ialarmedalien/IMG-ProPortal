use utf8;
package DBIC::IMG_Sat::Result::KogPathwayKogMembers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Sat::Result::KogPathwayKogMembers

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<KOG_PATHWAY_KOG_MEMBERS>

=cut

__PACKAGE__->table("KOG_PATHWAY_KOG_MEMBERS");

=head1 ACCESSORS

=head2 kog_pathway_oid

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "number"}
  size: [16,0]

=head2 kog_members

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "kog_pathway_oid",
  {
    data_type => "numeric",
    is_foreign_key => 1,
    is_nullable => 0,
    original => { data_type => "number" },
    size => [16, 0],
  },
  "kog_members",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 1, size => 20 },
);

=head1 RELATIONS

=head2 kog_member

Type: belongs_to

Related object: L<DBIC::IMG_Sat::Result::Kog>

=cut

__PACKAGE__->belongs_to(
  "kog_member",
  "DBIC::IMG_Sat::Result::Kog",
  { kog_id => "kog_members" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 kog_pathway_oid

Type: belongs_to

Related object: L<DBIC::IMG_Sat::Result::KogPathway>

=cut

__PACKAGE__->belongs_to(
  "kog_pathway_oid",
  "DBIC::IMG_Sat::Result::KogPathway",
  { kog_pathway_oid => "kog_pathway_oid" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-10 22:41:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TiZKw11WiY4CsFSNiRrBgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
