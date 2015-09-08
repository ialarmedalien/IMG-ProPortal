use utf8;
package DbSchema::IMG_Core::Result::EnvSampleJgiUrl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DbSchema::IMG_Core::Result::EnvSampleJgiUrl

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DbSchema>

=cut

use base 'DbSchema';

=head1 TABLE: C<ENV_SAMPLE_JGI_URL>

=cut

__PACKAGE__->table("ENV_SAMPLE_JGI_URL");

=head1 ACCESSORS

=head2 sample_oid

  data_type: 'integer'
  is_nullable: 0
  original: {data_type => "number",size => [38,0]}

=head2 db_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 db_id

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 url

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=cut

__PACKAGE__->add_columns(
  "sample_oid",
  {
    data_type   => "integer",
    is_nullable => 0,
    original    => { data_type => "number", size => [38, 0] },
  },
  "db_name",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "db_id",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "url",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-06-23 13:17:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F5MeGLzE3iHE+thCa8D68w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;