use utf8;
package DbSchema::IMG_Core::Result::StudyLoad;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DbSchema::IMG_Core::Result::StudyLoad

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DbSchema>

=cut

use base 'DbSchema';

=head1 TABLE: C<STUDY_LOAD>

=cut

__PACKAGE__->table("STUDY_LOAD");

=head1 ACCESSORS

=head2 new_study_id

  data_type: 'numeric'
  is_auto_increment: 1
  is_nullable: 0
  original: {data_type => "number"}
  sequence: 'load_study_pk_seq'
  size: 126

=head2 gold_study_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 study_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 3000

=head2 its_proposal_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 ncbi_project_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 add_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 mod_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 contact_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 last_mod_by

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 is_public

  data_type: 'varchar2'
  is_nullable: 1
  size: 24

=head2 gpts_proposal_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 project_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 active

  data_type: 'varchar2'
  default_value: 'Y'
  is_nullable: 0
  size: 3

=head2 legacy_gold_id

  data_type: 'varchar2'
  is_nullable: 1
  size: 9

=head2 bioproject_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 2000

=head2 gold_study_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 description

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 gold_id

  data_type: 'varchar2'
  is_nullable: 1
  size: 9

=head2 metagenomic

  data_type: 'varchar2'
  default_value: 'No'
  is_nullable: 0
  size: 20

=head2 study_type_id

  data_type: 'integer'
  default_value: 2
  is_nullable: 0
  original: {data_type => "number",size => [38,0]}

=cut

__PACKAGE__->add_columns(
  "new_study_id",
  {
    data_type => "numeric",
    is_auto_increment => 1,
    is_nullable => 0,
    original => { data_type => "number" },
    sequence => "load_study_pk_seq",
    size => 126,
  },
  "gold_study_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "study_name",
  { data_type => "varchar2", is_nullable => 1, size => 3000 },
  "its_proposal_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "ncbi_project_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "add_date",
  { data_type => "timestamp", is_nullable => 1 },
  "mod_date",
  { data_type => "timestamp", is_nullable => 1 },
  "contact_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "last_mod_by",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "is_public",
  { data_type => "varchar2", is_nullable => 1, size => 24 },
  "gpts_proposal_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "project_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "active",
  { data_type => "varchar2", default_value => "Y", is_nullable => 0, size => 3 },
  "legacy_gold_id",
  { data_type => "varchar2", is_nullable => 1, size => 9 },
  "bioproject_name",
  { data_type => "varchar2", is_nullable => 1, size => 2000 },
  "gold_study_name",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "description",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "gold_id",
  { data_type => "varchar2", is_nullable => 1, size => 9 },
  "metagenomic",
  {
    data_type => "varchar2",
    default_value => "No",
    is_nullable => 0,
    size => 20,
  },
  "study_type_id",
  {
    data_type     => "integer",
    default_value => 2,
    is_nullable   => 0,
    original      => { data_type => "number", size => [38, 0] },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</new_study_id>

=back

=cut

__PACKAGE__->set_primary_key("new_study_id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-06-23 13:17:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PJjU+l7yDT6W6xy0e7TT6A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
