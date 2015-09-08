use utf8;
package DbSchema::IMG_Core::Result::CvCommunity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DbSchema::IMG_Core::Result::CvCommunity

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DbSchema>

=cut

use base 'DbSchema';

=head1 TABLE: C<CV_COMMUNITY>

=cut

__PACKAGE__->table("CV_COMMUNITY");

=head1 ACCESSORS

=head2 cv_term

  data_type: 'varchar2'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "cv_term",
  { data_type => "varchar2", is_nullable => 1, size => 50 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<pk_cv_community_cv_term>

=over 4

=item * L</cv_term>

=back

=cut

__PACKAGE__->add_unique_constraint("pk_cv_community_cv_term", ["cv_term"]);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-06-23 13:17:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/wGtY3m2b2NXiJcPWM62Dw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;