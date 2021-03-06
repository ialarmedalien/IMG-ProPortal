use utf8;
package DBIC::IMG_Sat::Result::BiocycClass;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Sat::Result::BiocycClass

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<BIOCYC_CLASS>

=cut

__PACKAGE__->table("BIOCYC_CLASS");

=head1 ACCESSORS

=head2 unique_id

  data_type: 'varchar2'
  is_nullable: 0
  size: 255

=head2 common_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 comments

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=cut

__PACKAGE__->add_columns(
  "unique_id",
  { data_type => "varchar2", is_nullable => 0, size => 255 },
  "common_name",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "comments",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
);

=head1 PRIMARY KEY

=over 4

=item * L</unique_id>

=back

=cut

__PACKAGE__->set_primary_key("unique_id");

=head1 RELATIONS

=head2 biocyc_class_parents_parents

Type: has_many

Related object: L<DBIC::IMG_Sat::Result::BiocycClassParents>

=cut

__PACKAGE__->has_many(
  "biocyc_class_parents_parents",
  "DBIC::IMG_Sat::Result::BiocycClassParents",
  { "foreign.parents" => "self.unique_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biocyc_class_parents_uniques

Type: has_many

Related object: L<DBIC::IMG_Sat::Result::BiocycClassParents>

=cut

__PACKAGE__->has_many(
  "biocyc_class_parents_uniques",
  "DBIC::IMG_Sat::Result::BiocycClassParents",
  { "foreign.unique_id" => "self.unique_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biocyc_class_synonyms

Type: has_many

Related object: L<DBIC::IMG_Sat::Result::BiocycClassSynonyms>

=cut

__PACKAGE__->has_many(
  "biocyc_class_synonyms",
  "DBIC::IMG_Sat::Result::BiocycClassSynonyms",
  { "foreign.unique_id" => "self.unique_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biocyc_class_types

Type: has_many

Related object: L<DBIC::IMG_Sat::Result::BiocycClassTypes>

=cut

__PACKAGE__->has_many(
  "biocyc_class_types",
  "DBIC::IMG_Sat::Result::BiocycClassTypes",
  { "foreign.unique_id" => "self.unique_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-10 22:41:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sn+MTzi8k4mm5hQ0s4ageQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
