use utf8;
package DBIC::IMG_Gold::Result::GoldSequencingProject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::GoldSequencingProject

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<GOLD_SEQUENCING_PROJECT>

=cut

__PACKAGE__->table("GOLD_SEQUENCING_PROJECT");

=head1 ACCESSORS

=head2 gold_id

  data_type: 'varchar2'
  is_nullable: 0
  size: 50

=head2 display_name

  data_type: 'varchar2'
  is_nullable: 0
  size: 1000

=head2 strain

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 phylogeny

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 ncbi_taxon_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 domain

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_kingdom

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_phylum

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_class

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_order

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_family

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_genus

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_species

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 clade

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 isolation

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 oxygen_req

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 cell_shape

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 motility

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sporulation

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 temp_range

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 salinity

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 comments

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 seq_status

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 img_taxon_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 add_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 mod_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 modified_by

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 contact_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 iso_country

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 date_collected

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 geo_location

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 latitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 longitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 altitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 gram_stain

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_gender

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_ncbi_taxid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 biotic_rel

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 hmp_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 locus_tag

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 funding_program

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 type_strain

  data_type: 'varchar2'
  is_nullable: 1
  size: 10

=head2 ecosystem

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_category

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_subtype

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 specific_ecosystem

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 sample_body_site

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 sample_body_subsite

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 mrn

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 visit_num

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 replicate_num

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 pmo_project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 cultured

  data_type: 'varchar2'
  is_nullable: 1
  size: 16

=head2 uncultured_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 culture_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 bioproject_accession

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 biosample_accession

  data_type: 'varchar2'
  is_nullable: 1
  size: 128

=head2 its_spid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 pi_email

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pi_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 legacy_project_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 40

=head2 seq_quality

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 depth

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_strategy

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pm_email

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pm_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ecotype

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 longhurst_code

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 longhurst_description

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 project_status

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_quality

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_depth

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 genus

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 species

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 proport_ocean

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 proport_isolation

  data_type: 'varchar2'
  is_nullable: 1
  size: 512

=head2 proport_station

  data_type: 'varchar2'
  is_nullable: 1
  size: 512

=head2 proport_woa_temperature

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 proport_woa_salinity

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 proport_woa_dissolved_oxygen

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 proport_woa_silicate

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 proport_woa_phosphate

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 proport_woa_nitrate

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: [16,3]

=head2 viral_group

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 viral_subgroup

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 gpts_proposal_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 its_proposal_id

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 sample_collect_temp

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pressure

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 chlorophyll_concentration

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 oxygen_concentration

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 salinity_concentration

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 nitrate_concentration

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ph

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "gold_id",
  { data_type => "varchar2", is_nullable => 0, size => 50 },
  "display_name",
  { data_type => "varchar2", is_nullable => 0, size => 1000 },
  "strain",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "phylogeny",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "ncbi_taxon_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "domain",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_kingdom",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_phylum",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_class",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_order",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_family",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_genus",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_species",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "clade",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "isolation",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "oxygen_req",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "cell_shape",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "motility",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sporulation",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "temp_range",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "salinity",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "comments",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "seq_status",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "img_taxon_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "add_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "mod_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "modified_by",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "contact_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "iso_country",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "date_collected",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "geo_location",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "latitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "longitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "altitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "gram_stain",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_gender",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_ncbi_taxid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "biotic_rel",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "hmp_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "locus_tag",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "funding_program",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "type_strain",
  { data_type => "varchar2", is_nullable => 1, size => 10 },
  "ecosystem",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_category",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_type",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_subtype",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "specific_ecosystem",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "sample_body_site",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "sample_body_subsite",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "mrn",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "visit_num",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "replicate_num",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "pmo_project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "cultured",
  { data_type => "varchar2", is_nullable => 1, size => 16 },
  "uncultured_type",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "culture_type",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "bioproject_accession",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "biosample_accession",
  { data_type => "varchar2", is_nullable => 1, size => 128 },
  "its_spid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "pi_email",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pi_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "legacy_project_type",
  { data_type => "varchar2", is_nullable => 1, size => 40 },
  "seq_quality",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "depth",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_strategy",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pm_email",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pm_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ecotype",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "longhurst_code",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "longhurst_description",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "project_status",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_quality",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_depth",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "genus",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "species",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "proport_ocean",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "proport_isolation",
  { data_type => "varchar2", is_nullable => 1, size => 512 },
  "proport_station",
  { data_type => "varchar2", is_nullable => 1, size => 512 },
  "proport_woa_temperature",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "proport_woa_salinity",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "proport_woa_dissolved_oxygen",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "proport_woa_silicate",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "proport_woa_phosphate",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "proport_woa_nitrate",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => [16, 3],
  },
  "viral_group",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "viral_subgroup",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "gpts_proposal_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "its_proposal_id",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "sample_collect_temp",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pressure",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "chlorophyll_concentration",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "oxygen_concentration",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "salinity_concentration",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "nitrate_concentration",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ph",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gold_id>

=back

=cut

__PACKAGE__->set_primary_key("gold_id");

=head1 RELATIONS

=head2 gold_sp_cell_arrangements

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpCellArrangement>

=cut

__PACKAGE__->has_many(
  "gold_sp_cell_arrangements",
  "DBIC::IMG_Gold::Result::GoldSpCellArrangement",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_collaborators

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpCollaborator>

=cut

__PACKAGE__->has_many(
  "gold_sp_collaborators",
  "DBIC::IMG_Gold::Result::GoldSpCollaborator",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_diseases

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpDisease>

=cut

__PACKAGE__->has_many(
  "gold_sp_diseases",
  "DBIC::IMG_Gold::Result::GoldSpDisease",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_energy_sources

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpEnergySource>

=cut

__PACKAGE__->has_many(
  "gold_sp_energy_sources",
  "DBIC::IMG_Gold::Result::GoldSpEnergySource",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_genome_publications

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpGenomePublication>

=cut

__PACKAGE__->has_many(
  "gold_sp_genome_publications",
  "DBIC::IMG_Gold::Result::GoldSpGenomePublication",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_habitats

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpHabitat>

=cut

__PACKAGE__->has_many(
  "gold_sp_habitats",
  "DBIC::IMG_Gold::Result::GoldSpHabitat",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_metabolisms

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpMetabolism>

=cut

__PACKAGE__->has_many(
  "gold_sp_metabolisms",
  "DBIC::IMG_Gold::Result::GoldSpMetabolism",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_phenotypes

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpPhenotype>

=cut

__PACKAGE__->has_many(
  "gold_sp_phenotypes",
  "DBIC::IMG_Gold::Result::GoldSpPhenotype",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_relevances

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpRelevance>

=cut

__PACKAGE__->has_many(
  "gold_sp_relevances",
  "DBIC::IMG_Gold::Result::GoldSpRelevance",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_seq_centers

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpSeqCenter>

=cut

__PACKAGE__->has_many(
  "gold_sp_seq_centers",
  "DBIC::IMG_Gold::Result::GoldSpSeqCenter",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_seq_methods

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpSeqMethod>

=cut

__PACKAGE__->has_many(
  "gold_sp_seq_methods",
  "DBIC::IMG_Gold::Result::GoldSpSeqMethod",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_study_gold_ids

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpStudyGoldId>

=cut

__PACKAGE__->has_many(
  "gold_sp_study_gold_ids",
  "DBIC::IMG_Gold::Result::GoldSpStudyGoldId",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-20 15:03:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XxWlayiAib9gE07UsA0MhA
# These lines were loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/GoldSequencingProject.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package DBIC::IMG_Gold::Result::GoldSequencingProject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DBIC::IMG_Gold::Result::GoldSequencingProject

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<DBIC::Schema>

=cut

use base 'DBIC::Schema';

=head1 TABLE: C<GOLD_SEQUENCING_PROJECT>

=cut

__PACKAGE__->table("GOLD_SEQUENCING_PROJECT");

=head1 ACCESSORS

=head2 gold_id

  data_type: 'varchar2'
  is_nullable: 0
  size: 50

=head2 display_name

  data_type: 'varchar2'
  is_nullable: 0
  size: 1000

=head2 strain

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 phylogeny

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 ncbi_taxon_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 domain

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_kingdom

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_phylum

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_class

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_order

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_family

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_genus

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_species

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 clade

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ncbi_project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 isolation

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 oxygen_req

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 cell_shape

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 motility

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sporulation

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 temp_range

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 salinity

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 comments

  data_type: 'varchar2'
  is_nullable: 1
  size: 4000

=head2 seq_status

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 img_taxon_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 add_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 mod_date

  data_type: 'datetime'
  is_nullable: 1
  original: {data_type => "date"}

=head2 modified_by

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 contact_oid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 iso_country

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 date_collected

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 geo_location

  data_type: 'varchar2'
  is_nullable: 1
  size: 1000

=head2 latitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 longitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 altitude

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 gram_stain

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_gender

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 host_ncbi_taxid

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 biotic_rel

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 hmp_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 locus_tag

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 funding_program

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 type_strain

  data_type: 'varchar2'
  is_nullable: 1
  size: 10

=head2 ecosystem

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_category

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 ecosystem_subtype

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 specific_ecosystem

  data_type: 'varchar2'
  is_nullable: 1
  size: 256

=head2 sample_body_site

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 sample_body_subsite

  data_type: 'varchar2'
  is_nullable: 1
  size: 500

=head2 mrn

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 visit_num

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 replicate_num

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 pmo_project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 project_id

  data_type: 'integer'
  is_nullable: 1
  original: {data_type => "number",size => [38,0]}

=head2 cultured

  data_type: 'varchar2'
  is_nullable: 1
  size: 16

=head2 uncultured_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 culture_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 bioproject_accession

  data_type: 'varchar2'
  is_nullable: 1
  size: 64

=head2 biosample_accession

  data_type: 'varchar2'
  is_nullable: 1
  size: 128

=head2 its_spid

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=head2 pi_email

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pi_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 legacy_project_type

  data_type: 'varchar2'
  is_nullable: 1
  size: 40

=head2 seq_quality

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 depth

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_strategy

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pm_email

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 pm_name

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 ecotype

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 longhurst_code

  data_type: 'varchar2'
  is_nullable: 1
  size: 80

=head2 longhurst_description

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 project_status

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_quality

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=head2 sequencing_depth

  data_type: 'varchar2'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "gold_id",
  { data_type => "varchar2", is_nullable => 0, size => 50 },
  "display_name",
  { data_type => "varchar2", is_nullable => 0, size => 1000 },
  "strain",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "phylogeny",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "ncbi_taxon_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "domain",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_kingdom",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_phylum",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_class",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_order",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_family",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_genus",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_species",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "clade",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ncbi_project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "isolation",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "oxygen_req",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "cell_shape",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "motility",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sporulation",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "temp_range",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "salinity",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "comments",
  { data_type => "varchar2", is_nullable => 1, size => 4000 },
  "seq_status",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "img_taxon_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "add_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "mod_date",
  {
    data_type   => "datetime",
    is_nullable => 1,
    original    => { data_type => "date" },
  },
  "modified_by",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "contact_oid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "iso_country",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "date_collected",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "geo_location",
  { data_type => "varchar2", is_nullable => 1, size => 1000 },
  "latitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "longitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "altitude",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "gram_stain",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_gender",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "host_ncbi_taxid",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "biotic_rel",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "hmp_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "locus_tag",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "funding_program",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "type_strain",
  { data_type => "varchar2", is_nullable => 1, size => 10 },
  "ecosystem",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_category",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_type",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "ecosystem_subtype",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "specific_ecosystem",
  { data_type => "varchar2", is_nullable => 1, size => 256 },
  "sample_body_site",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "sample_body_subsite",
  { data_type => "varchar2", is_nullable => 1, size => 500 },
  "mrn",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "visit_num",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "replicate_num",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "pmo_project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "project_id",
  {
    data_type   => "integer",
    is_nullable => 1,
    original    => { data_type => "number", size => [38, 0] },
  },
  "cultured",
  { data_type => "varchar2", is_nullable => 1, size => 16 },
  "uncultured_type",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "culture_type",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "bioproject_accession",
  { data_type => "varchar2", is_nullable => 1, size => 64 },
  "biosample_accession",
  { data_type => "varchar2", is_nullable => 1, size => 128 },
  "its_spid",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
  "pi_email",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pi_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "legacy_project_type",
  { data_type => "varchar2", is_nullable => 1, size => 40 },
  "seq_quality",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "depth",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_strategy",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pm_email",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "pm_name",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "ecotype",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "longhurst_code",
  { data_type => "varchar2", is_nullable => 1, size => 80 },
  "longhurst_description",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "project_status",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_quality",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
  "sequencing_depth",
  { data_type => "varchar2", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gold_id>

=back

=cut

__PACKAGE__->set_primary_key("gold_id");

=head1 RELATIONS

=head2 gold_sp_cell_arrangements

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpCellArrangement>

=cut

__PACKAGE__->has_many(
  "gold_sp_cell_arrangements",
  "DBIC::IMG_Gold::Result::GoldSpCellArrangement",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_collaborators

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpCollaborator>

=cut

__PACKAGE__->has_many(
  "gold_sp_collaborators",
  "DBIC::IMG_Gold::Result::GoldSpCollaborator",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_diseases

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpDisease>

=cut

__PACKAGE__->has_many(
  "gold_sp_diseases",
  "DBIC::IMG_Gold::Result::GoldSpDisease",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_energy_sources

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpEnergySource>

=cut

__PACKAGE__->has_many(
  "gold_sp_energy_sources",
  "DBIC::IMG_Gold::Result::GoldSpEnergySource",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_genome_publications

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpGenomePublication>

=cut

__PACKAGE__->has_many(
  "gold_sp_genome_publications",
  "DBIC::IMG_Gold::Result::GoldSpGenomePublication",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_habitats

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpHabitat>

=cut

__PACKAGE__->has_many(
  "gold_sp_habitats",
  "DBIC::IMG_Gold::Result::GoldSpHabitat",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_metabolisms

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpMetabolism>

=cut

__PACKAGE__->has_many(
  "gold_sp_metabolisms",
  "DBIC::IMG_Gold::Result::GoldSpMetabolism",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_phenotypes

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpPhenotype>

=cut

__PACKAGE__->has_many(
  "gold_sp_phenotypes",
  "DBIC::IMG_Gold::Result::GoldSpPhenotype",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_relevances

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpRelevance>

=cut

__PACKAGE__->has_many(
  "gold_sp_relevances",
  "DBIC::IMG_Gold::Result::GoldSpRelevance",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_seq_centers

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpSeqCenter>

=cut

__PACKAGE__->has_many(
  "gold_sp_seq_centers",
  "DBIC::IMG_Gold::Result::GoldSpSeqCenter",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_seq_methods

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpSeqMethod>

=cut

__PACKAGE__->has_many(
  "gold_sp_seq_methods",
  "DBIC::IMG_Gold::Result::GoldSpSeqMethod",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gold_sp_study_gold_ids

Type: has_many

Related object: L<DBIC::IMG_Gold::Result::GoldSpStudyGoldId>

=cut

__PACKAGE__->has_many(
  "gold_sp_study_gold_ids",
  "DBIC::IMG_Gold::Result::GoldSpStudyGoldId",
  { "foreign.gold_id" => "self.gold_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-18 13:47:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0C5h5ntmPcvma4FqPyuQsw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/global/homes/a/aireland/webUI/proportal/lib/DBIC/IMG_Gold/Result/GoldSequencingProject.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
