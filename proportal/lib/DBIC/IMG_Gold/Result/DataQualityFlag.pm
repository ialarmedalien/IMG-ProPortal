use utf8;
package DBIC::IMG_Gold::Result::DataQualityFlag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::DataQualityFlag

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<DATA_QUALITY_FLAGS>

=cut

__PACKAGE__->table("DATA_QUALITY_FLAGS");

=head1 ACCESSORS

=head2 data_quality_id

  data_type: 'numeric'
  is_auto_increment: 1
  is_nullable: 0
  original: {data_type => "number"}
  sequence: 'data_quality_pk_seq'
  size: 126

=head2 project_oid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 flag

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "data_quality_id",
  {
    data_type => "numeric",
    is_auto_increment => 1,
    is_nullable => 0,
    original => { data_type => "number" },
    sequence => "data_quality_pk_seq",
    size => 126,
  },
  "project_oid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "flag",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</data_quality_id>

=back

=cut

__PACKAGE__->set_primary_key("data_quality_id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:03:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X5Kanf2zadzJAdjDwV8tbg
# These lines were loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/DataQualityFlag.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package DBIC::IMG_Gold::Result::DataQualityFlag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::DataQualityFlag

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<DATA_QUALITY_FLAGS>

=cut

__PACKAGE__->table("DATA_QUALITY_FLAGS");

=head1 ACCESSORS

=head2 data_quality_id

  data_type: 'numeric'
  is_auto_increment: 1
  is_nullable: 0
  original: {data_type => "number"}
  sequence: 'data_quality_pk_seq'
  size: 126

=head2 project_oid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 flag

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "data_quality_id",
  {
    data_type => "numeric",
    is_auto_increment => 1,
    is_nullable => 0,
    original => { data_type => "number" },
    sequence => "data_quality_pk_seq",
    size => 126,
  },
  "project_oid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "flag",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</data_quality_id>

=back

=cut

__PACKAGE__->set_primary_key("data_quality_id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-18 13:47:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YTjHjN/dsRgK1nyGh2d56Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/DataQualityFlag.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
