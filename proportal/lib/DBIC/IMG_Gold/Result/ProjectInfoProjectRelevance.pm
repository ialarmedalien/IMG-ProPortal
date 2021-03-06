use utf8;
package DBIC::IMG_Gold::Result::ProjectInfoProjectRelevance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::ProjectInfoProjectRelevance

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<PROJECT_INFO_PROJECT_RELEVANCE>

=cut

__PACKAGE__->table("PROJECT_INFO_PROJECT_RELEVANCE");

=head1 ACCESSORS

=head2 project_oid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "number",size => [38,0]}

=head2 project_relevance

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "project_oid",
  {
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
    original       => { data_type => "number", size => [38, 0] },
  },
  "project_relevance",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 RELATIONS

=head2 project_oid

Type: belongs_to

Related object: L<DBIC::IMG_Gold::Result::ProjectInfo>

=cut

__PACKAGE__->belongs_to(
  "project_oid",
  "DBIC::IMG_Gold::Result::ProjectInfo",
  { project_oid => "project_oid" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:03:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G31b0P0QtvMNRhSVqoRvDQ
# These lines were loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/ProjectInfoProjectRelevance.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package DBIC::IMG_Gold::Result::ProjectInfoProjectRelevance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::ProjectInfoProjectRelevance

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<PROJECT_INFO_PROJECT_RELEVANCE>

=cut

__PACKAGE__->table("PROJECT_INFO_PROJECT_RELEVANCE");

=head1 ACCESSORS

=head2 project_oid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "number",size => [38,0]}

=head2 project_relevance

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "project_oid",
  {
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
    original       => { data_type => "number", size => [38, 0] },
  },
  "project_relevance",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 RELATIONS

=head2 project_oid

Type: belongs_to

Related object: L<DBIC::IMG_Gold::Result::ProjectInfo>

=cut

__PACKAGE__->belongs_to(
  "project_oid",
  "DBIC::IMG_Gold::Result::ProjectInfo",
  { project_oid => "project_oid" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-18 13:47:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JMYUVwt4K+EEHBFjylpihA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/ProjectInfoProjectRelevance.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
