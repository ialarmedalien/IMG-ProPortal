use utf8;
package DBIC::IMG_Sat::Result::BiocycPathwaySuperPwys;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Sat::Result::BiocycPathwaySuperPwys

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<BIOCYC_PATHWAY_SUPER_PWYS>

=cut

__PACKAGE__->table("BIOCYC_PATHWAY_SUPER_PWYS");

=head1 ACCESSORS

=head2 unique_id

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 super_pwys

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "unique_id",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "super_pwys",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 1, size => 255 },
);

=head1 RELATIONS

=head2 super_pwy

Type: belongs_to

Related object: L<DBIC::IMG_Sat::Result::BiocycPathway>

=cut

__PACKAGE__->belongs_to(
  "super_pwy",
  "DBIC::IMG_Sat::Result::BiocycPathway",
  { unique_id => "super_pwys" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 unique

Type: belongs_to

Related object: L<DBIC::IMG_Sat::Result::BiocycPathway>

=cut

__PACKAGE__->belongs_to(
  "unique",
  "DBIC::IMG_Sat::Result::BiocycPathway",
  { unique_id => "unique_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-10 22:41:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5h6UC4g0G67XvcgUUIQG2A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
