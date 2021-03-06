package IMG::Views::ExternalLinks;

use IMG::Util::Import 'LogErr';

our (@ISA, @EXPORT_OK);

BEGIN {
	require Exporter;
	@ISA = qw( Exporter );
	@EXPORT_OK = qw( get_external_link );
}

use IMG::App::Role::ErrorMessages qw( err );

=pod

=head1 NAME

IMG::Views::ExternalLinks

=head2 SYNOPSIS

	use strict;
	use warnings;
	use IMG::Views::Links qw( get_ext_link );

	my $link = get_ext_link( 'pubmed', '91764817' );
	# $link is http://www.ncbi.nlm.nih.gov/pubmed/9174817

	my $sso_url = get_ext_link( 'sso_url' );
	# $sso_url is https://signon.jgi-psf.org

=head2 DESCRIPTION

This module manages external links; it can be used either directly, through the function get_external_link, or by loading IMG::Views::Links and using the function get_ext_link.

=cut

=head3 external_links

Library of external links

=cut

my $external_links = {

	'sso_api_url' => 'https://signon.jgi-psf.org/api/sessions/',
	'sso_url' => 'https://signon.jgi-psf.org',
	'sso_user_info_url' => 'https://signon.jgi-psf.org/api/users/',
	'blast_server_url' => 'https://img-worker.jgi-psf.org/cgi-bin/usearch/generic/hopsServer.cgi',
	'blastallm0_server_url' => 'https://img-worker.jgi-psf.org/cgi-bin/blast/generic/blastQueue.cgi',
	'img_er_submit_project_url' => 'https://img.jgi.doe.gov/cgi-bin/submit/main.cgi?section=ProjectInfo&page=displayProject&project_oid=',
	'img_er_submit_url' => 'https://img.jgi.doe.gov/cgi-bin/submit/main.cgi?section=ERSubmission&page=displaySubmission&submission_id=',
	'img_mer_submit_url' => 'https://img.jgi.doe.gov/cgi-bin/submit/main.cgi?section=MSubmission&page=displaySubmission&submission_id=',
	'img_submit_url' => 'https://img.jgi.doe.gov/submit',
	'ncbi_blast_server_url' => 'https://img-proportal-dev.jgi-psf.org/cgi-bin/ncbiBlastServer.cgi',
	'worker_base_url' => 'https://img-worker.jgi-psf.org',
	'gbrowse_base_url' => 'http://gpweb07.nersc.gov/',
	'gold_api_base_url' => 'https://gpweb08.nersc.gov:8443/',


	'aclame_base_url' => 'http://aclame.ulb.ac.be/perl/Aclame/Genomes/prot_view.cgi?mode=genome&id=',
	'artemis_url' => 'http://www.sanger.ac.uk/Software/Artemis/',
	'cmr_jcvi_ncbi_project_id_base_url' => 'http://cmr.jcvi.org/cgi-bin/CMR/ncbiProjectId2CMR.cgi?ncbi_project_id=',
	'doi' => 'http://dx.doi.org/',
	'ebi_iprscan_url' => 'http://www.ebi.ac.uk/Tools/pfa/iprscan/',
	'enzyme_base_url' => 'http://www.genome.jp/dbget-bin/www_bget?',
	'flybase_base_url' => 'http://flybase.bio.indiana.edu/reports/',
	'gcat_base_url' => 'http://darwin.nox.ac.uk/gsc/gcat/report/',
	'geneid_base_url' => 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=gene&cmd=Retrieve&dopt=full_report&list_uids=',
	'go_base_url' => 'http://www.ebi.ac.uk/ego/DisplayGoTerm?id=',
	'go_evidence_url' => 'http://www.geneontology.org/GO.evidence.shtml',

	'gold_base_url' => 'http://genomesonline.org/',
	'gold_base_url_analysis' => 'https://gold.jgi-psf.org/analysis_projects?id=',
	'gold_base_url_project' => 'https://gold.jgi-psf.org/projects?id=',
	'gold_base_url_study' => 'https://gold.jgi-psf.org/study?id=',

	'greengenes_base_url' => 'http://greengenes.lbl.gov/cgi-bin/show_one_record_v2.pl?prokMSA_id=',
	'greengenes_blast_url' => 'http://greengenes.lbl.gov/cgi-bin/nph-blast_interface.cgi',
	'hgnc_base_url' => 'http://www.gene.ucl.ac.uk/nomenclature/data/get_data.php?hgnc_id=',
	'ipr_base_url' => 'http://www.ebi.ac.uk/interpro/entry/',
	'ipr_base_url2' => 'http://supfam.cs.bris.ac.uk/SUPERFAMILY/cgi-bin/scop.cgi?ipid=',
	'ipr_base_url3' => 'http://prosite.expasy.org/',
	'ipr_base_url4' => 'http://smart.embl-heidelberg.de/smart/do_annotation.pl?ACC=',
	'jgi_project_qa_base_url' => 'http://cayman.jgi-psf.org/prod/data/QA/Reports/QD/',
	'kegg_module_url' =>    'http://www.genome.jp/dbget-bin/www_bget?md+',
	'kegg_orthology_url' => 'http://www.genome.jp/dbget-bin/www_bget?ko+',
	'kegg_reaction_url' =>  'http://www.genome.jp/dbget-bin/www_bget?rn+',
	'ko_base_url' =>        'http://www.genome.ad.jp/dbget-bin/www_bget?ko+',

	'metacyc_url' => 'http://biocyc.org/META/NEW-IMAGE?object=',
	'mgi_base_url' => 'http://www.informatics.jax.org/searches/accession_report.cgi?id=MGI:',


	'ncbi_bioproject' => 'http://www.ncbi.nlm.nih.gov/bioproject/',
	'ncbi_biosample' => 'http://www.ncbi.nlm.nih.gov/biosample/',
	'ncbi_taxon' => 'https://www.ncbi.nlm.nih.gov/taxonomy/',

	'ncbi_blast_url' => 'http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PAGE=Proteins&PROGRAM=blastp&BLAST_PROGRAMS=blastp&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on',
	'ncbi_entrez_base_url' => 'http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?val=',
	'ncbi_mapview_base_url' => 'http://www.ncbi.nlm.nih.gov/mapview/map_search.cgi?direct=on&idtype=gene&id=',
	'ncbi_project_id_base_url' => 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=genomeprj&cmd=Retrieve&dopt=Overview&list_uids=',




	'nice_prot_base_url' => 'http://www.uniprot.org/uniprot/',

	'pdb_base_url' => 'http://www.rcsb.org/pdb/explore.do?structureId=',
	'pdb_blast_url' => 'http://www.rcsb.org/pdb/search/searchSequence.do',

	'pfam_base_url' => 'http://pfam.sanger.ac.uk/family?acc=',
	'pfam_clan_base_url' => 'http://pfam.sanger.ac.uk/clan?acc=',
	'pirsf_base_url' => 'http://pir.georgetown.edu/cgi-bin/ipcSF?id=',

	'pubmed' => 'http://www.ncbi.nlm.nih.gov/pubmed/',
	'pubmed_base_url' => 'http://www.ncbi.nlm.nih.gov/entrez?db=PubMed&term=',

	'puma_base_url' => 'http://compbio.mcs.anl.gov/puma2/cgi-bin/search.cgi?protein_id_type=NCBI_GI&search=Search&search_type=protein_id&search_text=',
	'puma_redirect_base_url' => 'http://compbio.mcs.anl.gov/puma2/cgi-bin/puma2_url.cgi?gi=',
	'regtransbase_base_url' => 'http://regtransbase.lbl.gov/cgi-bin/regtransbase?page=geneinfo&protein_id=',
	'regtransbase_check_base_url' => 'http://regtransbase.lbl.gov/cgi-bin/regtransbase?page=check_gene_exp&protein_id=',
	'rfam_base_url' => 'http://rfam.sanger.ac.uk/family/',
	'rgd_base_url' => 'http://rgd.mcw.edu/tools/genes/genes_view.cgi?id=',
	'rna_server_url' => 'https://img-worker.jgi-psf.org/cgi-bin/blast/generic/rnaServer.cgi',
	'swiss_prot_base_url' => 'http://www.uniprot.org/uniprot/',
	'swissprot_source_url' => 'http://www.uniprot.org/uniprot/',
	'tair_base_url' => 'http://www.arabidopsis.org/servlets/TairObject?type=locus&name=',
	'taxonomy_base_url' => 'http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
	'tigrfam_base_url' => 'http://www.jcvi.org/cgi-bin/tigrfams/HmmReportPage.cgi?acc=',
	'unigene_base_url' => 'http://www.ncbi.nlm.nih.gov/UniGene/clust.cgi',
	'vimss_redirect_base_url' => 'http://www.microbesonline.org/cgi-bin/gi2vimss.cgi?gi=',
	'wormbase_base_url' => 'http://www.wormbase.org/db/gene/gene?name=',
	'zfin_base_url' => 'http://zfin.org/cgi-bin/webdriver?MIval=aa-markerview.apg&OID=',
	'uniprot_base_url' => 'http://uniprot.org/uniprot/'
};

# 	KEGG_ENZYME
# 	'http://www.genome.jp/dbget-bin/www_bget?'    => 'enzyme_base_url',
# 	KEGG_ORTHOLOGY
# 	'http://www.genome.jp/dbget-bin/www_bget?ko+' => 'kegg_orthology_url',
# 	KEGG_PATHWAY
# 	'http://www.genome.jp/dbget-bin/www_bget?path:ot00020' => 'kegg_pathway_url',
# 	KEGG_MODULE
# 	'http://www.genome.jp/dbget-bin/www_bget?md+' => 'kegg_module_url',
# 	KEGG_REACTION
# 	'http://www.genome.jp/dbget-bin/www_bget?rn+' => 'kegg_reaction_url',

$external_links->{KEGG_MODULE} = $external_links->{kegg_module_url};
$external_links->{KEGG_PATHWAY} = $external_links->{ko_base_url};
$external_links->{KO_TERM} = $external_links->{kegg_orthology_url};

$external_links->{GI} = $external_links->{ncbi_entrez_base_url};
$external_links->{GenBank} = $external_links->{ncbi_entrez_base_url};
$external_links->{NCBI} = $external_links->{ncbi_entrez_base_url};
$external_links->{GeneID} = $external_links->{geneid_base_url};

$external_links->{GreenGenes} = $external_links->{greengenes_base_url};

# if ( $is_big_euk eq "Yes" ) {
# 	my $url = "$ncbi_mapview_base_url$id";
# 	$s .= alink( $url, "MapView/$dbId" );
# 	$s .= "; ";
# }

$external_links->{GO} = $external_links->{enzyme_base_url};
$external_links->{EC} = $external_links->{enzyme_base_url};
$external_links->{TC} = 'http://www.tcdb.org/tcdb/index.php?tc=';
$external_links->{InterPro} = $external_links->{ipr_base_url};
$external_links->{SUPERFAMILY} = $external_links->{ipr_base_url2};
$external_links->{ProSiteProfiles} = $external_links->{ipr_base_url3};
$external_links->{SMART} = $external_links->{ipr_base_url4};
$external_links->{TAIR} = $external_links->{tair_base_url};
$external_links->{WormBase} = $external_links->{wormbase_base_url};
$external_links->{ZFIN} = $external_links->{zfin_base_url};
$external_links->{HGNC} = $external_links->{hgnc_base_url};
$external_links->{MGI} = $external_links->{mgi_base_url};
$external_links->{RGD} = $external_links->{rgd_base_url};
$external_links->{UniProt} = $external_links->{nice_prot_base_url};
$external_links->{UniProtKB} = $external_links->{uniprot_base_url};
$external_links->{'UniProt/TrEMBL'} = $external_links->{uniprot_base_url};
$external_links->{'UniProtKB/TrEMBL'} = $external_links->{uniprot_base_url};

$external_links->{'NCBI/RefSeq'} = 'http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?val=';

$external_links->{TIGRFam} = $external_links->{tigrfam_base_url};

$external_links->{SEED} = 'http://pseed.theseed.org/seedviewer.cgi?page=BrowseGenome&feature=';
$external_links->{UniGene} = sub {
	my ( $org, $id ) = split '.', shift;
	return $external_links->{ unigene_base_url }
		. '?ORG=' . $org . '&amp;CID=' . $id;
};

$external_links->{FLYBASE} = sub {
	return $external_links->{ flybase_base_url } . +shift . '.html';
};

=head3 get_external_link

Get an external link from the library

	my $link = IMG::Views::Links::get_external_link( 'pubmed', '81274414' );
	# $link = http://www.ncbi.nlm.nih.gov/pubmed/81274414

@param  $target - the name of the link in the hash above
@param  $id     - any other params (optional)

@return $link   - text string that forms the link

=cut

sub get_external_link {
	my $target = shift // die err({ err => 'missing', subject => 'link target' });

	die err({ err => 'not_found',
		subject => 'link target ' . ( $target || '' )
	}) unless defined $external_links->{$target};

	# simple string; append any arguments to it
	if ( ! ref $external_links->{$target} ) {
		return $external_links->{$target} . ( $_[0] || "" );
	}
	# otherwise, it's a coderef
	elsif ( ref $external_links eq 'CODE' ) {
		return $external_links->{$target}->( @_ );
	}
	return '';
}

1;
