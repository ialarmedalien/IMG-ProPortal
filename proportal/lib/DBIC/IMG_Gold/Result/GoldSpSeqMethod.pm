use utf8;
package DBIC::IMG_Gold::Result::GoldSpSeqMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::GoldSpSeqMethod

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<GOLD_SP_SEQ_METHOD>

=cut

__PACKAGE__->table("GOLD_SP_SEQ_METHOD");

=head1 ACCESSORS

=head2 gold_id

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 0
  size: 50

=head2 seq_method

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "gold_id",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 0, size => 50 },
  "seq_method",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 RELATIONS

=head2 gold

Type: belongs_to

Related object: L<DBIC::IMG_Gold::Result::GoldSequencingProject>

=cut

__PACKAGE__->belongs_to(
  "gold",
  "DBIC::IMG_Gold::Result::GoldSequencingProject",
  { gold_id => "gold_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:03:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o/te0Bc/1yp40SQmuEbDuw
# These lines were loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/GoldSpSeqMethod.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package DBIC::IMG_Gold::Result::GoldSpSeqMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::GoldSpSeqMethod

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<GOLD_SP_SEQ_METHOD>

=cut

__PACKAGE__->table("GOLD_SP_SEQ_METHOD");

=head1 ACCESSORS

=head2 gold_id

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 0
  size: 50

=head2 seq_method

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "gold_id",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 0, size => 50 },
  "seq_method",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 RELATIONS

=head2 gold

Type: belongs_to

Related object: L<DBIC::IMG_Gold::Result::GoldSequencingProject>

=cut

__PACKAGE__->belongs_to(
  "gold",
  "DBIC::IMG_Gold::Result::GoldSequencingProject",
  { gold_id => "gold_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-18 13:47:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ACJpkqjLplsa+T/CQ+bkQA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/GoldSpSeqMethod.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
