# Put configuration parameters here.
#
# $Id: WebConfig.pm 35644 2016-05-13 17:41:48Z klchu $
#
package WebConfig;
require Exporter;
@ISA    = qw( Exporter );
@EXPORT = qw( getEnv );

use WebConfigCommon;
use strict;

sub getEnv {
    my $e = WebConfigCommon::common();

    # TODO - Companion systems url
    $e->{domain_name}  = "img.jgi.doe.gov";
    $e->{http}         = "https://";
    $e->{top_base_url} = $e->{http} . $e->{domain_name} . "/";

    my $urlTag = "mer";
    $e->{urlTag} = $urlTag;
    my $dbTag = $e->{dbTag};    #my $dbTag = "img_core_v400"; # my $dbTag = $e->{ dbTag };

    $e->{base_url} = $e->{http} . $e->{domain_name} . "/$urlTag";
    $e->{arch}     = "x86_64-linux";

    #
    # DO NOT update base_dir base_dir_stage cgi_url cgi_dir cgi_dir_stage
    # - ken
    #
    #my $webfsVhostDir  = '/webfs/projectdirs/microbial/img/public-web/vhosts/';
    my $webfsVhostDir  = '/global/homes/w/wwwimg/apache/content/vhosts/';
    my $apacheVhostDir = '/global/homes/w/wwwimg/apache/content/vhosts/';
    $e->{top_base_dir}   = $apacheVhostDir . $e->{domain_name} . "/htdocs/";
    $e->{base_dir}       = $apacheVhostDir . $e->{domain_name} . "/htdocs/$urlTag";
    $e->{base_dir_stage} = $webfsVhostDir . $e->{domain_name} . "/htdocs/$urlTag";
    $e->{cgi_url}        = $e->{http} . $e->{domain_name} . "/cgi-bin/$urlTag";
    $e->{cgi_dir}        = $apacheVhostDir . $e->{domain_name} . "/cgi-bin/$urlTag";
    $e->{cgi_dir_stage}  = $webfsVhostDir . $e->{domain_name} . "/cgi-bin/$urlTag";

    $e->{main_cgi}  = "main.cgi";
    $e->{inner_cgi} = "inner.cgi";

    my $log_dir = "/webfs/scratch/img/logs";
    $e->{log_dir}      = $log_dir;
    $e->{web_log_file} = "$log_dir/" . $e->{domain_name} . $dbTag . "_" . $urlTag . ".log";
    $e->{err_log_file} = "$log_dir/" . $e->{domain_name} . $dbTag . "_" . $urlTag . ".err.log";

    $e->{cgi_tmp_dir} = "/webfs/scratch/img/opt_img_shared/temp/" . $e->{domain_name} . "_" . $urlTag;
    $e->{ifs_tmp_dir} = $e->{ifs_tmp_dir} . "/" . $urlTag;

    # optional precomputed homologs server with -m 0 output
    $e->{img_lid_blastdb} = "${dbTag}_lid";

    # IMG long ID (<gene_oid>_<taxon>_<aa_seq_length>)
    # BLAST database.
    $e->{img_iso_blastdb} = "${dbTag}_iso";

    # IMG long ID (<gene_oid>_<taxon>_<aa_seq_length>)
    # Isolate BLAST database.
    $e->{img_rna_blastdb} = "${dbTag}_rna.fna";

    # IMG long ID (<gene_oid>_<taxon>_<aa_seq_length>_<geneSymbol>)
    # Meta RNA BLAST database.
    $e->{img_meta_rna_blastdb} = "metag_rna.fna";

    # IMG long ID (<taxon>.a:<gene_oid>_<aa_seq_length>)
    # BLAST database.
    $e->{ncbi_blast_server_url} = $e->{cgi_url} . "/ncbiBlastServer.cgi";

    # Client web server to NCBI BLAST.

    $e->{vista_url_map_file} = $e->{cgi_dir} . "/vista.tab.txt";
    $e->{vista_sets_file}    = $e->{cgi_dir} . "/vista.sets.txt";

    $e->{otf_phyloProfiler_method} = "usearch";

    # On the fly usearch

    $e->{include_metagenomes} = 1;

    # Include metagenome configuration.

    $e->{enable_workspace} = 1;
    $e->{img_group_share}  = 1;

    # kog is for 3.4 not 3.3
    $e->{include_kog}      = 1;
    $e->{include_bbh_lite} = 0;    # Include BBH lite files.

    $e->{img_internal} = 0;

    # Add internal for IMG/I.

    # added cassette bbh selection to the ui
    $e->{enable_cassette}         = 1;    # new for 3.4
    $e->{include_cassette_bbh}    = 0;
    $e->{include_cassette_pfam}   = 1;    # used by profiler for now - ken
    $e->{enable_cassette_fastbit} = 1;

    $e->{img_geba} = 1;

    # show GEBA genomes and stats

    $e->{img_er} = 1;

    # IMG/ER isolate specific features.

    $e->{include_ht_homologs} = 1;

    # Mark horizontal transfers in gene page homologs.
    $e->{include_ht_stats} = 2;

    # Show horizontal transfers in genome details page.

    $e->{show_myimg_login} = 1;

    # Show login for MyIMG.

    $e->{show_mygene} = 1;

    # Show mygene setup.

    $e->{show_mgdist_v2} = 1;

    # Show version 2 of metagenome distribution.

    $e->{user_restricted_site} = 1;

    # Restrict site requiring individual permissions.

    # not for 3.3
    $e->{snp_enabled} = 0;    # SNP

    # mpw - ken
    $e->{mpw_pathway} = 1;

    $e->{oracle_config}             = $e->{oracle_config_dir} . "web.$dbTag.config";
    $e->{img_er_oracle_config}      = $e->{oracle_config_dir} . "web.$dbTag.config";
    $e->{img_gold_oracle_config}    = $e->{oracle_config_dir} . "web.imgsg_dev.config";
    $e->{img_i_taxon_oracle_config} = $e->{oracle_config_dir} . "web.img_i_taxon.config";
    $e->{myimg_job}      = 1;
    $e->{myimg_jobs_dir} = $e->{web_data_dir} . "/myimg.jobs";

    # Results of job submissions

    $e->{all_faa_blastdb} = $e->{web_data_dir} . "/all.faa.blastdbs/all_$dbTag";
    $e->{all_fna_blastdb} = $e->{web_data_dir} . "/all.fna.blastdbs/all_$dbTag";

    # Name of all protein and nucleic acid BLAST databases.
    # Need to customize for subset.

    $e->{phyloProfile_file} = $e->{web_data_dir} . "/phyloProfile.$dbTag.txt";

    # Phylogenetic profile file.

    $e->{include_taxon_phyloProfiler} = 1;

    # Phylo profiler at taxon level.

    $e->{taxon_stats_dir} = $e->{web_data_dir} . "/taxon.stats.$dbTag";

    ##################
    $e->{bin_dir}          = $e->{cgi_dir} . "/bin/" . $e->{arch};
    $e->{bl2seq_bin}       = $e->{bin_dir} . "/bl2seq";
    $e->{fastacmd_bin}     = $e->{bin_dir} . "/fastacmd";
    $e->{formatdb_bin}     = $e->{bin_dir} . "/formatdb";
    $e->{megablast_bin}    = $e->{bin_dir} . "/megablast";
    $e->{clustalw_bin}     = $e->{bin_dir} . "/clustalw";
    $e->{snpCount_bin}     = $e->{bin_dir} . "/snpCount";
    $e->{grep_bin}         = $e->{bin_dir} . "/grep";
    $e->{findHit_bin}      = $e->{bin_dir} . "/findHit";
    #$e->{mview_bin}        = $e->{bin_dir} . "/mview";
    $e->{phyloSim_bin}     = $e->{bin_dir} . "/phyloSim";
    $e->{wsimHomologs_bin} = $e->{bin_dir} . "/wsimHomologs";
    $e->{cluster_bin}      = $e->{bin_dir} . "/cluster";
    #$e->{ma_bin}           = $e->{bin_dir} . "/ma";
    $e->{raxml_bin}        = $e->{bin_dir} . "/raxml";

    $e->{tmp_url}                = $e->{base_url} . "/tmp";
    $e->{tmp_dir}                = $e->{base_dir} . "/tmp";
    $e->{small_color_array_file} = $e->{cgi_dir} . "/color_array.txt";
    $e->{large_color_array_file} = $e->{cgi_dir} . "/rgb.scrambled.txt";
    $e->{dark_color_array_file}  = $e->{cgi_dir} . "/dark_color.txt";
    $e->{green2red_array_file}   = $e->{cgi_dir} . "/green2red_array.txt";

    $e->{verbose} = -1;

    # General verbosity level. 0 - very little, 1 - normal,
    #   >1 more verbose.
    # -1 to turn off webLog - ken

    $e->{show_sql_verbosity_level} = 2;

    # Minimum verbosity level before SQL is logged.
    # Set to 2 or above to avoid getting most SQL queries logged,
    # for e.g., in production systems.

    ## Charting parameters

    # location of the runchart.sh script
    # IF blank "" the charting feature will be DISABLED
    $e->{chart_exe} = $e->{cgi_dir} . "/bin/runchart.sh";

    # chart script logging feature - used only of debugging
    # best to leave it blank "" or "/dev/null"
    $e->{chart_log} = "";

    # new for 3.2
    # decorator.sh
    #
    $e->{decorator_exe} = $e->{cgi_dir} . "/bin/decorator.sh";

    # location of jar files
    $e->{decorator_lib} = $e->{base_dir};

    # decorator script logging feature - used only of debugging
    # best to leave it blank "" or "/dev/null"
    $e->{decorator_log} = "";

    # new for 3.1 cgi caching
    # enable cgi cache 0 to disable
    $e->{cgi_cache_enable} = 1;

    # location of cache directory - this should be a unique directory
    # for each web site
    $e->{cgi_cache_dir} = $e->{cgi_tmp_dir} . "/CGI_Cache";

    # cache expire time in seconds 1 hour = 60 * 60
    # should be less the purge tmp and cgi_tmp times
    $e->{cgi_cache_default_expires_in} = 3600;

    # max cache size in bytes 20 MB
    # changed max cache to 1 GB - ken
    $e->{cgi_cache_size} = 1000 * 1024 * 1024;

    # for 3.3 test to see if we can cache blast output for public sites
    # for it to work both cgi_cache_enable must be 1
    #     AND cgi_blast_cache_enable = 1
    # this should help during the workshops - Ken
    $e->{cgi_blast_cache_enable} = 1;

    # ssl enable - only for er and mer on merced - new for v3.3 - ken
    #
    # see https_cgi_url
    $e->{ssl_enabled} = 1;

    # new for 3.3 only for img system: mer and er and server merced. Its not for spock
    # because spock has no ssl cert. - Ken
    #
    # see ssl_enabled
    $e->{https_cgi_url} = "https://" . $e->{domain_name} . "/cgi-bin/$urlTag/" . $e->{main_cgi};

    # new for 3.3 - ken
    # if blank it will run the old way as in 3.2
    $e->{blast_wrapper_script} = $e->{cgi_dir} . "/bin/blastwrapper.sh";

    # new for 3.3 - ken
    $e->{dblock_file} = $e->{dbLock_dir} . $dbTag;

    # to put a special message in the message area below the menu
    # leave it blank to display no message
    $e->{message} = "";

    # caliban sso
    # if null do not use sso
    #
    # for stage web farm MUST change url to .jgi-psf.org
    #
    $e->{sso_enabled}     = 1;
    $e->{sso_domain}      = ".jgi.doe.gov";
    $e->{sso_url}         = "https://signon" . $e->{sso_domain};
    $e->{sso_cookie_name} = "jgi_return";
    $e->{sso_session_cookie_name} = "jgi_session";    # cookie that stores the caliban session id is has the format of "/api/sessions/30a6fa0dc58d3708"
    $e->{sso_api_url} = $e->{sso_url} . "/api/sessions/";    # "https://signon.jgi-psf.org/api/sessions/"; # session id from cookie jgi_session
    $e->{sso_user_info_url} = $e->{sso_url} . '/api/users/';

    # My bins
    $e->{enable_mybin}    = 0;
    $e->{mybin_blast_dir} = $e->{workspace_dir} . "/blast_mer";

    # MER-FS
    $e->{mer_data_dir} = "/global/dna/projectdirs/microbial/img_web_data_merfs";
    $e->{in_file}      = "in_file";
    ## use new taxon function count tables for MER-FS
    $e->{new_func_count} = 1;

    $e->{rnaseq} = 1;    # only er - ken

    # find function static pages
    #    $e->{cog_data_file}     = $e->{ webfs_data_dir } ."hmp/img_mer_cog.txt";
    #    $e->{kog_data_file}     = $e->{ webfs_data_dir } ."hmp/img_mer_kog.txt";
    #    $e->{pfam_data_file}    = $e->{ webfs_data_dir } ."hmp/img_mer_pfam.txt";
    #    $e->{tigrfam_data_file} = $e->{ webfs_data_dir } ."hmp/img_mer_tigrfam.txt";
    #    $e->{enzyme_data_file}  = $e->{ webfs_data_dir } ."hmp/img_mer_enzymes.txt";
    $e->{figfams_data_file} = $e->{webfs_data_dir} . "hmp/img_mer_figfams.txt";
    $e->{tc_data_file}      = $e->{webfs_data_dir} . "hmp/img_mer_tc.txt";

    # domain_stats_file
    $e->{domain_stats_file} = $e->{webfs_data_dir} . "ui/prod/domain_stats_mer_v400.txt";

    WebConfigCommon::postFix($e);
    return $e;
}

1;
