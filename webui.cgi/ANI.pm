# $Id: ANI.pm 37112 2017-05-29 22:03:14Z aratner $
package ANI;
use strict;
use CGI qw(:standard);
use Data::Dumper;
use DBI;
use HTML::Template;
use Number::Format;
use Date::Format;
use Storable;
use InnerTable;
use TaxonSearchUtil;
use GenomeList;
use MetaUtil;
use MerFsUtil;
use OracleUtil;
use WebConfig;
use WebUtil;
use GenomeListJSON;
use JSON;
use GraphViz;
use HtmlUtil;
use Command;

$| = 1;

my $section                  = "ANI";
my $env                      = getEnv();
my $main_cgi                 = $env->{main_cgi};
my $section_cgi              = "$main_cgi?section=ANI";
my $verbose                  = $env->{verbose};
my $show_sql_verbosity_level = $env->{show_sql_verbosity_level};
my $base_url                 = $env->{base_url};
my $top_base_url             = $env->{top_base_url};
my $domain_name              = $env->{domain_name};
my $img_submit_url           = $env->{img_submit_url};
my $base_dir                 = $env->{base_dir};
my $ani_stats_dir            = $env->{bcnp_stats_dir};
my $cgi_url                  = $env->{cgi_url};
my $xml_cgi                  = $cgi_url . '/xml.cgi';
my $cgi_dir                  = $env->{cgi_dir};
my $cgi_tmp_dir              = $env->{cgi_tmp_dir};
my $tmp_dir                  = $env->{tmp_dir};
my $tmp_url                  = $env->{tmp_url};
my $YUI                      = $env->{yui_dir_28};
my $include_metagenomes      = $env->{include_metagenomes};

my $max_pairwise = 100;
my $img_ken = $env->{img_ken};

sub getPageTitle {
    return 'ANI';
}

sub getAppHeaderData {
    my ($self) = @_;
    my $page = param('page');
    my $js = '';

    if ($page eq "pairwise") {
        require GenomeListJSON;
        my $template = HTML::Template->new(filename => "$base_dir/genomeHeaderJson.html");
        $template->param(base_url => $base_url);
        $template->param(YUI      => $YUI);
        $js = $template->output;
    } elsif ($page eq "overview") {
        my $template = HTML::Template->new(filename => "$base_dir/meshTreeHeader.html");
        $template->param(base_url => $base_url);
        $template->param(YUI      => $YUI);
        $js = $template->output;
    }

    my @a = ( "CompareGenomes", '', '', $js, '', "ANI.pdf" );
    return @a;
}

sub printWebPageHeader {
    my($self) = @_;
    my $page = param('page');
    if ( $page eq "selectFiles" ) {

        # xml header
        print header( -type => "text/xml" );
    } else {
        print header( -type => "application/json", -expires => '-1d' );
    }
}

sub dispatch {
    my ($self, $numTaxon) = @_;
    my $page = param("page");

    if ($page eq "overview") {
        HtmlUtil::cgiCacheInitialize($section, '', '', 1);
        HtmlUtil::cgiCacheStart() or return;
        printOverview();
        HtmlUtil::cgiCacheStop();
    } elsif ($page eq "pairwise") {
        printPairwise($numTaxon);
    } elsif ($page eq "doPairwise") {
        HtmlUtil::cgiCacheInitialize($section, '', '', 1);
        HtmlUtil::cgiCacheStart() or return;
	doPairwise();
        HtmlUtil::cgiCacheStop();        
    } elsif ($page eq "doQuickPairwise" || paramMatch("doQuickPairwise") ne "") {
        HtmlUtil::cgiCacheInitialize($section, '', '', 1);
        HtmlUtil::cgiCacheStart() or return;        
        doQuickPairwise();
        HtmlUtil::cgiCacheStop();
    } elsif ($page eq "doSameSpeciesPlot") {
        printSameSpeciesPairwiseForm();	# new UI 
    } elsif ($page eq "doPairwiseWithUpload") {
        HtmlUtil::cgiCacheInitialize($section, '', '', 1);
        HtmlUtil::cgiCacheStart() or return;
        doPairwiseWithUpload();
        HtmlUtil::cgiCacheStop();
    } elsif ($page eq "plotSameSpeciesPairwise" || paramMatch("plotSameSpeciesPairwise") ne "") {
        plotSameSpeciesPairwise();
    } elsif ($page eq "sameSpeciesPairwise") {
        printSameSpeciesPairwiseForm();	# new UI 
    } elsif ($page eq "cliques") {
        printAllCliques(1);
    } elsif ($page eq "species") {
        printAllSpeciesInfo(1);
    } elsif ($page eq "speciesForGenomeForClique") {
        printSpeciesForGenomeForClique();
    } elsif ($page eq "genomesInSpecies") {
        printGenomesInSpecies();
    } elsif ($page eq "genomesForClique") {
        printGenomesForClique();
    } elsif ($page eq "infoForGenome") {
        printCliqueInfoForGenome();
    } elsif ($page eq "genomesForGenusSpecies") {
        printGenomesForGenusSpecies();
    } elsif ($page eq "cliquesForGenusSpecies") {
        printCliquesForGenusSpecies();
    } elsif ($page eq "infoForGenusSpecies") {
        printInfoForGenusSpecies();
    } elsif ($page eq "cliqueDetails") {
        printCliqueDetails();
    } elsif ($page eq "advancedSearch") {
        printAdvancedSearchForm($numTaxon, 1);
    } elsif ($page eq "selectFiles" ||
	     paramMatch("selectFiles") ne "") {
        selectFiles();
    } else {
# 		require ANI::Home;
# 		ANI::Home::dispatch();
        printLandingPage();
    }
}

sub printLandingPage {
    HtmlUtil::cgiCacheInitialize($section);
    HtmlUtil::cgiCacheStart() or return;

    if ($env->{img_ken_localhost}) {
        $ani_stats_dir = "/tmp/";
    }
    my $filename = $ani_stats_dir . 'anistats-2.stor';
    my $href = retrieve($filename);
    my $touchFileTime = fileAtime($filename);
    $touchFileTime = Date::Format::time2str("%a %b %e %Y", $touchFileTime);

    # more stats
    my $filename2 = $ani_stats_dir . 'anistats-3.stor';
    my $href2 = retrieve($filename2);
    

    my $template = HTML::Template->new(filename => "$base_dir/aniLanding.html");
    $template->param(xcount => Number::Format::format_number($href->{xcount}));
    $template->param(ycount => Number::Format::format_number($href->{ycount}));
    $template->param(zcount => Number::Format::format_number($href->{zcount}));
    $template->param(acount => Number::Format::format_number($href->{acount}));
    $template->param(bcount => Number::Format::format_number($href->{bcount}));
    $template->param(ccount => Number::Format::format_number($href->{ccount}));
    $template->param(dcount => Number::Format::format_number($href->{dcount}));
    $template->param(ecount => Number::Format::format_number($href->{ecount}));


    $template->param(unique_species_names => Number::Format::format_number($href2->{unique_species_names}));
    $template->param(clique_cnt => Number::Format::format_number($href2->{clique}));
    $template->param(clique_group_cnt => Number::Format::format_number($href2->{'clique-group'}));
    $template->param(singleton_cnt => Number::Format::format_number($href2->{singleton}));

    $template->param(strain_clique_cnt => Number::Format::format_number($href2->{'strain_clique'}));
    $template->param(strain_clique_group_cnt => Number::Format::format_number($href2->{'strain_clique-group'}));
    $template->param(strain_singleton_cnt => Number::Format::format_number($href2->{'strain_singleton'}));


    $template->param(date     => $touchFileTime);
    $template->param(base_url => $base_url);

    print $template->output;
    HtmlUtil::cgiCacheStop();
}

sub printOverview {
    WebUtil::printHeaderWithInfo
	("ANI Cliques", "", "", "ANI Cliques Info", 0, "ANI.pdf");

    require TabHTML;
    TabHTML::printTabAPILinks("cliquesTab");

    my @tabIndex = ("#allcliquetab1", "#allcliquetab2", "#allcliquetab3", "#allcliquetab4");
    my @tabNames = ("All Cliques", "by Species", "by Taxonomy", "Clique Groups");
    TabHTML::printTabDiv("cliquesTab", \@tabIndex, \@tabNames);

    print "<div id='allcliquetab1'>";
    my ($cliq_cnt, $groups_href) = printAllCliques();
    print "</div>";    # end allcliquetab1
    print "<div id='allcliquetab2'>";
    my $spc_cnt = printAllSpeciesInfo();
    print "</div>";    # end allcliquetab2
    print "<div id='allcliquetab3'>";
    printTaxonomyInfo();
    print "</div>";    # end allcliquetab3
    print "<div id='allcliquetab4'>";
    drawCliqueGroups($groups_href);
    print "</div>";    # end allcliquetab4

    TabHTML::printTabDivEnd();
    printStatusLine("$cliq_cnt cliques and $spc_cnt species loaded", 2);
}

sub drawCliqueGroups {
    my ($groups_href, $isdetail) = @_;
    my %groups = %$groups_href;
    $isdetail = 0 if $isdetail eq "";

    my @keys = sort { $groups{$a} <=> $groups{$b} } keys(%groups);
    my @vals = @groups{@keys};

    my $hint = "Click on a clique group to get detailed information about that group.<br/>" if !$isdetail;
    $hint .= "Any two genomes in a clique group will be connected by an edge in the graph if they have <br/>an ANI >= 96.5 and an AF >= 0.6.";
    printHint($hint);
    print "<br/>";

    my $dbh = dbLogin();

    # print groups:
    print "<p style='width: 1020px; border: 1px solid #99ccff; '>" if !$isdetail;
    foreach my $clq (@keys) {
        my $count = $groups{$clq};
        my $zoom = 1;
        $zoom = 2 if $isdetail;

        next if $count >= 32;

        # for each clique group, query for genomes and af ani data
        my $sql = qq{
            select distinct acm.MEMBERS
            from ANI_CLIQUE_MEMBERS acm
            where acm.CLIQUE_ID = ?
            order by acm.MEMBERS
        };
        my $cur = execSql($dbh, $sql, $verbose, $clq);
        my @oids;
        for ( ;; ) {
            my ($genome) = $cur->fetchrow();
            last if (!$genome);
            push @oids, $genome;
        }

        # if two genomes have an ANI>=96.5 and AF>=0.6
        # then the genomes will be connected by an edge in the graph
        my $tx_str = join(",", @oids);
        my $sql    = qq{
            select distinct tam.genome1, tam.genome2,
                   tam.final_ani, tam.final_fraction
            from taxon_ani_matrix tam
            where tam.genome1 in ($tx_str)
            and tam.genome2 in ($tx_str)
            and tam.ani1 >= 96.5
            and tam.ani2 >= 96.5
            and tam.final_ani >= 96.5
            and tam.fraction1 >= 0.6
            and tam.fraction2 >= 0.6
            and tam.final_fraction >= 0.6
        };
        my $cur = execSql($dbh, $sql, $verbose);
        my %pairs;
        for ( ;; ) {
            my ($genome1, $genome2, $ani, $af) = $cur->fetchrow();
            last if !$genome1;
            $pairs{ $genome1 . $genome2 } = 1;
        }
        $cur->finish();

        my $imageUrl = getImage($clq, $count, \@oids, \%pairs, $zoom, $isdetail);
        my $cliqueUrl = "$section_cgi&page=cliqueDetails&clique_id=$clq";
        print "<a href='$cliqueUrl' target='_blank'>" if !$isdetail;
        print "<img src='$imageUrl' title='$clq' border='0' />";
        print "</a>" if !$isdetail;
        print "&nbsp;&nbsp;";
    }
    print "</p>";
}

sub getImage {
    my ($clique_id, $count, $genomes_aref, $pairs_href, $zoom, $isdetail) = @_;
    $zoom = 1 if $zoom eq "";
    my @genomes = @$genomes_aref;
    my %pairs = %$pairs_href;

    # size it:
    my $size = 1;
    $size = 0.8 if ($count < 4);
    $size = $count * 0.1 if ($count > 10);
    $size = $size * $zoom;

    my $fs = 14;
    $fs = 14 * $size if $size > 1;
    $fs = 30 if $fs > 30;

    my $label = "<<TABLE border='0' cellborder='0'><TR><TD><font point-size='12'>$clique_id</font></TD></TR></TABLE>>";
    my $g = GraphViz->new( directed => 0,
			   layout   => 'circo',
			   width    => $size,
			   height   => $size,
			   
			   #graph    => { label     => $clique_id,
			   #		  scale     => '0.5,0.5!',
			   #		  fontsize  => $fs },
			   node => {
			       shape     => 'point',
			       fontsize  => '9',
			       color     => '#2F4F4F',
			       fillcolor => '#B0C4DE',
			       style     => 'filled' },
	                );

    if ($count < 32) {
        foreach my $tx1 (@genomes) {
            $g->add_node($tx1, label => '');

            foreach my $tx2 (@genomes) {
                next if $tx1 >= $tx2;
                if (exists $pairs{ $tx1 . $tx2 }) {
                    $g->add_edge($tx1 => $tx2, color => '#708090');
                } else {
                    $g->add_edge($tx1 => $tx2, color => 'none');
                }
            }
        }
    }

    #print $g->as_svg;

    my $tmpPngFile = "$tmp_dir/$$" . $clique_id . "-clq.png";
    my $tmpPngUrl  = "$tmp_url/$$" . $clique_id . "-clq.png";

    my $wfh = newWriteFileHandle($tmpPngFile, "clique_groups");
    binmode $wfh;
    print $wfh $g->as_png;
    close $wfh;

    return $tmpPngUrl;
}

sub printCliqueInfoForGenome {
    my ($taxon_oid) = @_;

    my $show_title = 0;
    if ($taxon_oid eq "") {
        $taxon_oid = param("taxon_oid");
        print "<h1>Average Nucleotide Identity (ANI)</h1>";
        $show_title = 1;
    }

    my $dbh = dbLogin();

    my ($anicnt, $cliqueIdTaxonCnt_href, $cliqueId2Type_href, 
	$cliqueId2GenusSpecies_href) = getInfoForGenome($dbh, $taxon_oid);
    return if $anicnt < 1;

    print "<b>Average Nucleotide Identity (ANI)</b>" if !$show_title;

    my ($domain, $phylum, $genus, $species, $ani_species) 
	= getGenusSpecies4Taxon($dbh, $taxon_oid);
    my $speciesCnt = getGenomesInSpeciesCnt($dbh, $taxon_oid);

    my $key = "$ani_species";
    my $dm = substr($domain, 0, 1);
    my $url1 = "$section_cgi&page=genomesForGenusSpecies&genus_species=$key&domain=$dm";
    my $link1 = alink($url1, $speciesCnt);

    print "<p><u>Species</u>: $key";
    print "<br/>Total genomes of this same species: $link1";
    print "<br/>This species is present in <u>$anicnt</u> cliques";

    my $hint = "Click on a clique ID to view genomes in that clique, as well as a list of similar cliques.";
    printHint($hint);
    print "</p>";

    my $it = new StaticInnerTable();
    my $sd = $it->getSdDelim();
    $it->addColSpec("Clique ID",            "asc", "right");
    $it->addColSpec("Clique Type",          "asc", "center");
    $it->addColSpec("Contributing Species", "asc", "left", '', '', '', (200));
    $it->addColSpec("Genome Count",         "asc", "right");

    foreach my $clique_id (sort { $a <=> $b } keys %$cliqueIdTaxonCnt_href) {
        my $species_href = $cliqueId2GenusSpecies_href->{$clique_id};
        my @tmp = sort keys %$species_href;
        my $species = join(", ", @tmp);

        my $row;
        my $cliqueUrl = "$section_cgi&page=cliqueDetails"
	    . "&clique_id=$clique_id";
        my $link = alink($cliqueUrl, $clique_id);
        $row .= $clique_id . $sd . $link . "\t";

        my $clique_type = $cliqueId2Type_href->{$clique_id};
        $row .= $clique_type . "\t";
        $row .= "$species" . "\t";

        my $contSpeciesUrl = "$section_cgi&page=speciesForGenomeForClique"
	    . "&taxon_oid=$taxon_oid&clique_id=$clique_id";
        my $cnt = $cliqueIdTaxonCnt_href->{$clique_id};
        my $urllink = alink($contSpeciesUrl, $cnt);
        $row .= $cnt . $sd . $urllink . "\t";

        $it->addRow($row);
    }
    $it->printOuterTable(1);
}

sub printPairwise {
    my ($numTaxon) = @_;

    my $note = "BBHs between a genome pair are computed as pairwise bidirectional best nSimScan hits of genes having 70% or more identity and at least 70% coverage of the shorter gene. You may either select genome(s) from IMG or you may upload a nucleotide sequence in FASTA format (using the <u>Upload File</u> button) to compute ANI to selected genome(s) in IMG";

    if ($include_metagenomes) {
        WebUtil::printHeaderWithInfo
            ("Pairwise ANI", $note,
	     "show description for this tool",
	     "Pairwise ANI Info", 1, "ANI.pdf");
    } else {
        WebUtil::printHeaderWithInfo
            ("Pairwise ANI", $note,
	     "show description for this tool",
	     "Pairwise ANI Info", 0, "ANI.pdf");
    }
    print "<p style='width: 680px;'>$note</p>\n";
    print "<script type='text/javascript' src='$top_base_url/js/checkSelection.js'></script>\n";

    #require TabHTML;
    #TabHTML::printTabAPILinks("pairwiseTab");

    #my @tabIndex = ("#pairwisetab1", "#pairwisetab2");
    #"#pairwisetab3"); #, "#pairwisetab4");
    #my @tabNames = ("Genome to Genome", "DNA Sequence to Genome");
    #"Advanced Search"); # "Same Species Pairwise");
    #TabHTML::printTabDiv("pairwiseTab", \@tabIndex, \@tabNames);

    #print "<div id='pairwisetab1'>";
    printAdvancedSearchForm($numTaxon);

    #printQuickSearch($numTaxon);
    #printCollapsableForm($numTaxon);
    #print "</div>"; # end pairwisetab1

    #print "<div id='pairwisetab2'>";
    #printUploadForm($numTaxon);
    #print "</div>"; # end pairwisetab2

    #print "<div id='pairwisetab3'>";
    #printAdvancedSearchForm($numTaxon);
    #print "</div>"; # end pairwisetab3

    #print "<div id='pairwisetab4'>";
    #printSameSpeciesPairwiseForm();
    #print "</div>"; # end pairwisetab4

    #TabHTML::printTabDivEnd();
}

sub printQuickSearch {
    my ($numTaxon) = @_;
    my $enable_autocomplete = $env->{enable_autocomplete};

    print start_form(-id      => "quicksearch_frm",
		     -name    => "mainForm",
		     -action  => "$main_cgi",
		     -enctype => "application/x-www-form-urlencoded",
		     -method  => "post");

    print "<p><font color='#003366'>"
	. "Please select 2 genomes:"
	. "</font>\n";

    if ($enable_autocomplete) {
        print qq{
            <input type="hidden" value="doPairwise" name="page">
            <input type="hidden" value="ANI" name="section">

            <div id="quicksearch" style="margin:0;width:270px;">
            <font style="color: black;"> Quick Genome 1 Search: </font>
            <br/>

            <div id="myAutoCompleteX" style="padding-bottom:2em;" >
            <input id="myInput1" type="text"
                   placeholder='<enter a genome name to search>' 
                   style="width: 250px; height: 20px;"
                   name="taxonTerm" size="12" maxlength="256">
            <div id="myContainer1"></div>
            </div>
            </div>
        };
        print nbsp(1);
        print qq{
            <div id="quicksearch" style="margin:0;width:270px">
            <font style="color: black;"> Quick Genome 2 Search: </font>
            <br/>

            <div id="myAutoCompleteX" style="padding-bottom:2em;" >
            <input id="myInput2" type="text" 
                   placeholder='<enter a genome name to search>' 
                   style="width: 250px; height: 20px;"
                   name="taxonTerm" size="12" maxlength="256">
            <div id="myContainer2"></div>
            </div>
            </div>
        };

        # get autocomplete url with private genomes:
        GenomeListJSON::printAutoComplete("myInput1", "myContainer1");
        print nbsp(1);
        GenomeListJSON::printAutoComplete("myInput2", "myContainer2");
    }

    print "<br/><br/><br/>";
    my $name = "_section_ANI_doPairwise";
    print submit(
        -name    => $name,
        -value   => "ANI",
        -class   => "medbutton",
        -onClick => "return validateTextItemSelection(2, \"quicksearch_frm\", \"taxonTerm\");"
   );

    print nbsp(1);
    print reset(-class => "smbutton");

    #    print nbsp(1);
    #    my $adv_url = "$section_cgi&page=advancedSearch";
    #    print alink($adv_url, "Advanced");
    print end_form();
}

sub printUploadForm {
    my ($numTaxon) = @_;

    my $text = "You may upload a nucleotide sequence in Fasta Format to compute ANI to a selected genome in IMG.";
    print "<p style='width: 950px;'>$text</p>\n";

    print start_form(-id     => "upload_frm",
		     -name   => "mainForm",
		     -action => "$main_cgi");
    print "<p>File to upload:<br/>";
    print "<input id='ani_fna_upload' type='file' multiple='' name='uploadFnaFile' size='45'/>";
    print "<br/>\n";

    print "<p><font color='#003366'>"
	. "Please select up to 100 genomes:"
	. "</font>\n";
    my $template = getSearchTemplate("$base_dir/genomeJson.html");
    $template->param(autocomplete => 1);
    $template->param(form_id => 'upload_frm');
    print $template->output;

    my $name = "_section_ANI_doPairwiseWithUpload";
    GenomeListJSON::printHiddenInputType($section, 'doPairwiseWithUpload');
    GenomeListJSON::printAutoComplete
	("myGenomeSearchInput" . "upload_frm", 
	 "myGenomeSearchContainer" . "upload_frm");
    GenomeListJSON::printMySubmitButton
	('go', $name, 'ANI', '', $section,
	 'doPairwiseWithUpload', 'meddefbutton', 'upload_frm');

    print nbsp(1);
    print reset(-class => "smbutton");
    print end_form();
    GenomeListJSON::showGenomeCart($numTaxon);
}

sub getSearchTemplate {
    my ($filename) = @_;

    my $hideViruses = getSessionParam("hideViruses");
    $hideViruses = ($hideViruses eq "" || $hideViruses eq "Yes") ? 0 : 1;
    my $hidePlasmids = getSessionParam("hidePlasmids");
    $hidePlasmids = ($hidePlasmids eq "" || $hidePlasmids eq "Yes") ? 0 : 1;
    my $hideGFragment = getSessionParam("hideGFragment");
    $hideGFragment = ($hideGFragment eq "" || $hideGFragment eq "Yes") ? 0 : 1;

    my $template = HTML::Template->new(filename => $filename);
    $template->param(gfr     => $hideGFragment);
    $template->param(pla     => $hidePlasmids);
    $template->param(vir     => $hideViruses);
    $template->param(isolate => 1);
    $template->param(all     => 0);
    $template->param(cart    => 1);
    $template->param(xml_cgi => $xml_cgi);
    $template->param(prefix  => '');
    #$template->param(from         => 'ANI');
    return $template;
}

sub printCollapsableForm {
    my ($numTaxon) = @_;
    print qq{
        <script type='text/javascript'
            src='$YUI/build/yahoo-dom-event/yahoo-dom-event.js'>
        </script>

        <script language='JavaScript' type='text/javascript'>
        function showForm(type) {
            if (type == 'nomyform') {
                document.getElementById('showmyform').style.display = 'none';
                document.getElementById('hidemyform').style.display = 'block';
            } else {
                document.getElementById('showmyform').style.display = 'block';
                document.getElementById('hidemyform').style.display = 'none';
            }
        }
        </script>
    };

    print "<div id='hidemyform' style='display: block;'>";
    print "<p><a href='#' onclick='showForm(\"myform\")' >Advanced Search</a>";
    print "</div>";

    print "<div id='showmyform' style='display: none;'>";
    print "<p><a href='#' onclick='showForm(\"nomyform\")' >Hide Advanced Search</a>";
    printAdvancedSearchForm($numTaxon);
    print "</div>";
}

sub selectFiles {
    my $workspace_dir = $env->{workspace_dir};
    my $folder = "genome";
    my $sid = getContactOid();
    opendir(DIR, "$workspace_dir/$sid/$folder")
      or WebUtil::webDie("failed to open folder list");
    my @files = readdir(DIR);
    closedir(DIR);

    my $name = "My Workspace - Genome Sets";
    my $script = "$top_base_url/js/Workspace.js";

    if (scalar @files == 0) {
        print '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        print qq {
            <response>
            <header>$name</header>
            <text>There are no genome sets in your workspace.</text>
            </response>
        };
        return;
    }

    print '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
    print qq {
        <response>
            <header>$name</header>
            <script>$script</script>
            <maptext><![CDATA[
    };

    print start_form(
        -name   => "dlgForm",
        -action => "$main_cgi",
   );

    WorkspaceUtil::printShareMainTableNoFooter("WorkspaceGenomeSet", $workspace_dir, $sid, $folder, \@files, '', 0, 1);
    print end_form();

    print qq {
            ]]></maptext>
            <text>Please select some genome sets:</text>
        </response>
    };
}

sub printAdvancedSearchForm {
    my ($numTaxon, $show_title) = @_;
    $show_title = 0 if $show_title eq "";
    print "<h1>Advanced Search - ANI Pairwise</h1>" if $show_title;

    print start_form(-id     => "advanced_frm",
		     -name   => "mainForm",
		     -action => "$main_cgi");
    print "<p><font color='#003366'>"
	. "Please select up to $max_pairwise genomes:"
	. "<br/><u>Note:</u> This limit is lower for private genomes that do not get precomputed for the computation is then <i>on demand</i>."
	. "</font>";

    my $template = getSearchTemplate("$base_dir/genomeJsonTwoDiv.html");
    $template->param(form_id              => 'advanced_frm');
    $template->param(autocomplete         => 1);
    $template->param(allow_same_item      => 1);
    $template->param(workspace            => 1); # to allow selection of genome sets
    $template->param(localfile1           => 1); # to allow selection of local file
    $template->param(maxSelected1         => $max_pairwise);
    $template->param(maxSelected2         => $max_pairwise);
    $template->param( from                 => 'isolate' );
    $template->param(selectedGenome1Title => 'Pairwise 1:');
    $template->param(selectedGenome2Title => 'Pairwise 2:');
    print "<script src='$top_base_url/js/imgDialog.js'></script>\n";

    my $s = "";
    $template->param(mySubmitButton => $s);
    print $template->output;

    my $name = "_section_ANI_doPairwise";
    GenomeListJSON::printHiddenInputType($section, 'doPairwise');
    GenomeListJSON::printAutoComplete
	("myGenomeSearchInput" . "advanced_frm",
	 "myGenomeSearchContainer" . "advanced_frm");
    my $button = GenomeListJSON::printMySubmitButtonXDiv
	('go', $name, 'ANI', '', $section, 'doPairwise', 'meddefbutton',
	 'selectedGenome1', 1, "selectedGenome2", 1, 'advanced_frm');

    print "<p>";
    print $button;

    #print nbsp(1);
    #print reset(-class => "smbutton");
    print end_form();
    GenomeListJSON::showGenomeCart($numTaxon);
}

sub loadFiles {
    my ($filenames_aref, $max) = @_;
    my $sid = getContactOid();
    my $folder = "genome";
    #checkFolder($folder);

    my $dbh = dbLogin();
    my %taxons_in_file = MerFsUtil::getTaxonsInFile($dbh);

    my @oids;
    my $workspace_dir = $env->{workspace_dir};
    foreach my $filename (@$filenames_aref) {
        WebUtil::checkFileName($filename);
        $filename = WebUtil::validFileName($filename);

        my $res = newReadFileHandle("$workspace_dir/$sid/$folder/$filename");
        while (my $id = $res->getline()) {
            chomp $id;
            $id = WebUtil::strTrim($id);
            next if ($id eq "");
            next if (!WebUtil::hasAlphanumericChar($id));
            next if ($taxons_in_file{$id}); # do not allow metagenomes at this time
            push(@oids, $id) if $max ne "" && scalar @oids < $max;
        }
        close $res;
    }

    return \@oids;
}

sub doPairwise {
    my ($oids1_ref, $oids2_ref, $msg, $isSet) = @_;

    my @oids1;
    if ($oids1_ref && scalar(@$oids1_ref) > 0) {
        @oids1 = @$oids1_ref;
    } else {
        @oids1 = param("selectedGenome1");
    }

    my @oids2;
    if ($oids2_ref && scalar(@$oids2_ref) > 0) {
        @oids2 = @$oids2_ref;
    } else {
        @oids2 = param("selectedGenome2");
    }

    my $dbh = dbLogin();
    my $sql = qq{
        select distinct tx.taxon_oid
        from taxon tx
        where tx.taxon_display_name = ?
    };

    my @tids1;
    my @filenames1;
    my @localfiles1;

    # for quick search by name where there maybe multiple genomes:
    foreach my $id (@oids1) {
        my ($a, $b) = split(":",      $id);
        my ($c, $d) = split("wfs:",   $id);    # workspace set
        my ($e, $f) = split("local:", $id);    # local file
        if ($a eq "" && $b ne "") {
            my $cur = execSql($dbh, $sql, $verbose, $b);
            my ($taxon_oid) = $cur->fetchrow();    # just get one
            push @tids1, $taxon_oid if $taxon_oid && $taxon_oid ne "";
            $cur->finish();
        } elsif ($c eq "" && $d ne "") {
            # workspace genome set:
            push @filenames1, $d;
        } elsif ($e eq "" && $f ne "") {
            # local file:
            push @localfiles1, $f;
        } else {
            push @tids1, $id;
        }
    }

    @oids1 = @tids1;
    if (scalar @filenames1 > 0) {
        my $idref = loadFiles(\@filenames1, $max_pairwise);
        push @oids1, @$idref;
    }
    my $nTaxons1 = @oids1;

    my @tids2;
    my @filenames2;
    foreach my $id (@oids2) {
        my ($a, $b) = split(":",    $id);
        my ($c, $d) = split("wfs:", $id);
        if ($a eq "" && $b ne "") {
            my $cur = execSql($dbh, $sql, $verbose, $b);
            my ($taxon_oid) = $cur->fetchrow();    # just get one
            push @tids2, $taxon_oid if $taxon_oid && $taxon_oid ne "";
            $cur->finish();
        } elsif ($c eq "" && $d ne "") {
            # workspace genome set:
            push @filenames2, $d;
        } else {
            push @tids2, $id;
        }
    }

    @oids2 = @tids2;
    if (scalar @filenames2 > 0) {
        my $idref = loadFiles(\@filenames2, $max_pairwise);
        push @oids2, @$idref;
    }
    my $nTaxons2 = @oids2;

    if ($nTaxons1 < 1 && $nTaxons2 < 1) {
        # from quick search using autocomplete:
        my @searchTerms = param("taxonTerm");
        if (scalar @searchTerms == 2) {
            WebUtil::webError("Cannot compare same genome.")
              if @searchTerms[0] eq @searchTerms[1];

            my $cur = execSql($dbh, $sql, $verbose, @searchTerms[0]);
            my ($taxon_oid) = $cur->fetchrow();    # just get one
            push @oids1, $taxon_oid if $taxon_oid && $taxon_oid ne "";

            my $cur = execSql($dbh, $sql, $verbose, @searchTerms[1]);
            my ($taxon_oid) = $cur->fetchrow();    # just get one
            push @oids2, $taxon_oid if $taxon_oid && $taxon_oid ne "";

            $nTaxons1 = @oids1;
            $nTaxons2 = @oids2;
        }
    }

    my $genomeLabel;
    if ($isSet) {
        $genomeLabel = "genome sets";
    } else {
        $genomeLabel = "genomes";
    }
    WebUtil::webError("Please select 2 valid $genomeLabel.")
	if ($nTaxons1 < 1 && (scalar @localfiles1 < 1)) || $nTaxons2 < 1;

    printStatusLine("Loading ...", 1);

    my @oids = (@oids1, @oids2);
    my $tx_str = OracleUtil::getNumberIdsInClause($dbh, @oids);
    my $sql = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name
        from taxon tx
        where tx.taxon_oid in ($tx_str)
    };
    my $cur = execSql($dbh, $sql, $verbose);
    my %taxon2name;
    for ( ;; ) {
        my ($taxon_oid, $taxon_name) = $cur->fetchrow();
        last if (!$taxon_oid);
        $taxon2name{$taxon_oid} = $taxon_name;
    }
    $cur->finish();
    OracleUtil::truncTable($dbh, "gtt_num_id")
	if ($tx_str =~ /gtt_num_id/i);

    my $hasGenome2Genome = 0;
    if ($nTaxons1 > 0 && $nTaxons2 > 0) {
        $hasGenome2Genome = 1;
        my ($dataRecs_aref, $precomputed_href) = computePairwiseANI($dbh, \@oids1, \@oids2);
        if (scalar @$dataRecs_aref < 1) {
            WebUtil::webError("Could not compute data for selected $genomeLabel.");
        }
        printPairwiseTable(\%taxon2name, $dataRecs_aref, $precomputed_href, $msg);
    }

    if ($nTaxons2 > 0 && scalar @localfiles1 > 0) {
        # upload the local files using file_upload input and @oids2... -anna
        my @dataRecsFiles;
        computePairwiseANIWithUpload(\@dataRecsFiles, \@oids2, "file_upload");
        printPairwiseWithUploadTable(\%taxon2name, \@dataRecsFiles, $hasGenome2Genome);
        # done local upload
    }

    printStatusLine("loaded", 2);
}

sub doQuickPairwise {
    # selected from "Genomes in Clique" tab of "Clique Details" page
    my $clique_id = param("clique_id");
    my @cids = param("taxon_filter_oid");
    WebUtil::webError("Please select 2 genomes for pairwise ANI.") if scalar @cids < 2;

    printStatusLine("Loading ...", 1);

    my $tx_str = join(",", @cids);
    my $dbh = dbLogin();
    my $sql = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name
        from taxon tx
        where tx.taxon_oid in ($tx_str)
    };
    my $cur = execSql($dbh, $sql, $verbose);
    my %taxon2name;
    for ( ;; ) {
        my ($taxon_oid, $taxon_name) = $cur->fetchrow();
        last if (!$taxon_oid);
        $taxon2name{$taxon_oid} = $taxon_name;
    }
    $cur->finish();

    my @oids1 = (@cids[0]);
    my @oids2 = (@cids[1]);
    ### ANNA - allow all pairs:
    #my ($dataRecs_aref, $precomputed_href) = computePairwiseANI($dbh, \@oids1, \@oids2);
    my ($dataRecs_aref, $precomputed_href) = computePairwiseANI($dbh, \@cids, \@cids);

    if (scalar @$dataRecs_aref < 1) {
        WebUtil::webError("Could not compute data for selected genomes.");
    }

    printPairwiseTable(\%taxon2name, $dataRecs_aref, $precomputed_href, "", $clique_id);
    my $rowcnt = scalar @$dataRecs_aref;
    printStatusLine("$rowcnt pairs loaded", 2);
}

sub printPairwiseTable {
    my ($taxon2name_href, $dataRecs_aref, $precomputed_href, $msg, $clique_id) = @_;

    my $description = "Pairwise ANI is ...";
    my $title       = "Pairwise ANI";

    WebUtil::printHeaderWithInfo
	($title, "", "",
	 "Pairwise ANI Info", 0, "ANI.pdf");
    
    if ($msg && $msg ne "") {
        print "<p style='width: 650px;'>";
        print $msg;
        print "</p>";
    }

    my $cliqueUrl = "$section_cgi&page=cliqueDetails&clique_id=$clique_id";
    my $cliqueLink = alink($cliqueUrl, $clique_id);
    print "<p><u>Clique ID</u>: $cliqueLink</p>" if ($clique_id && $clique_id ne "");

    my $it = new InnerTable(1, "anicliques$$", 'anicliques', 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Genome1 ID",    "asc", "right");
    $it->addColSpec("Genome1 Name",  "asc", "left");
    $it->addColSpec("Genome2 ID",    "asc", "right");
    $it->addColSpec("Genome2 Name",  "asc", "left");
    $it->addColSpec("ANI1->2",       "asc", "right");
    $it->addColSpec("ANI2->1",       "asc", "right");
    $it->addColSpec("AF1->2",        "asc", "right");
    $it->addColSpec("AF2->1",        "asc", "right");
    $it->addColSpec("Total BBH",     "asc", "right");
    $it->addColSpec("Precomputed ?", "asc", "left");

    my $taxon_url = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=";

    my $cnt = 0;
    foreach my $rec (@$dataRecs_aref) {
        my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt) = split("\t", $rec);

        my $taxon_name1 = $taxon2name_href->{$genome1};
        my $taxon_name2 = $taxon2name_href->{$genome2};
        my $taxon_link1 = alink($taxon_url . $genome1, $taxon_name1);
        my $taxon_link2 = alink($taxon_url . $genome2, $taxon_name2);

        my $row;
        $row .= $genome1 . $sd . $genome1 . "\t";
        $row .= $taxon_name1 . $sd . $taxon_link1 . "\t";
        $row .= $genome2 . $sd . $genome2 . "\t";
        $row .= $taxon_name2 . $sd . $taxon_link2 . "\t";

        $row .= $ani1 . "\t";
        $row .= $ani2 . "\t";

        $af1 = sprintf("%.3f", $af1) if $af1 ne "";
        $af2 = sprintf("%.3f", $af2) if $af2 ne "";
        $row .= $af1 . "\t";
        $row .= $af2 . "\t";

        $row .= $bbh_cnt . "\t";

        my $precomputed = "No";
        $precomputed = "Yes"
	    if exists $precomputed_href->{ $genome1 . "," . $genome2 };
        $row .= $precomputed . "\t";

        $it->addRow($row);
        $cnt++;
    }

    $it->printOuterTable(1) if $cnt > 0;
}

sub computePairwiseANI {
    my ($dbh, $oids1_aref, $oids2_aref) = @_;
    my @oids1 = @$oids1_aref;
    my @oids2 = @$oids2_aref;

    timeout( 60 * 20 );     # timeout in 20 mins (from main.pl)

    # data in taxon_ani_matrix is stored in 1 row
    # for both tx1->tx2 and tx2->tx1, so need to run
    # same query flipping genome1 and genome2
    my $tx_str2 = OracleUtil::getNumberIdsInClause($dbh, @oids2);
    my $sql = qq{
        select distinct tam.genome1, tam.genome2,
               tam.ani1, tam.ani2, tam.fraction1, tam.fraction2,
               tam.total_bbh
        from taxon_ani_matrix tam
        where tam.genome1 = ?
        and tam.genome2 in ($tx_str2)
    };

    my @dataRecs;
    my %precomputed;

    printStartWorkingDiv();
    print "<p>Querying for precomputed...<br>\n";

    foreach my $tx1 (@oids1) {
        my $cur = execSql($dbh, $sql, $verbose, $tx1);
        for ( ;; ) {
            my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt) = $cur->fetchrow();
            last if !$genome1;
	    next if $genome1 eq $genome2;
            next if exists $precomputed{ $genome1 . "," . $genome2 };
            next if exists $precomputed{ $genome2 . "," . $genome1 };

            my $rec = $genome1 . "\t" . $genome2 . "\t"
		. $ani1 . "\t" . $ani2 . "\t" . $af1 . "\t" . $af2 . "\t" . $bbh_cnt;
            push @dataRecs, $rec;
            $precomputed{ $genome1 . "," . $genome2 } = 1;
        }
        $cur->finish();
    }
    OracleUtil::truncTable($dbh, "gtt_num_id")
	if ($tx_str2 =~ /gtt_num_id/i);

    # now flip genome1 and genome2:
    my $tx_str1 = OracleUtil::getNumberIdsInClause($dbh, @oids1);
    my $sql = qq{
        select distinct tam.genome1, tam.genome2,
               tam.ani1, tam.ani2, tam.fraction1, tam.fraction2,
               tam.total_bbh
        from taxon_ani_matrix tam
        where tam.genome1 = ?
        and tam.genome2 in ($tx_str1)
    };

    foreach my $tx2 (@oids2) {
        my $cur = execSql($dbh, $sql, $verbose, $tx2);
        for ( ;; ) {
            my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt) = $cur->fetchrow();
            last if !$genome1;
	    next if $genome1 eq $genome2;
            next if exists $precomputed{ $genome1 . "," . $genome2 };
            next if exists $precomputed{ $genome2 . "," . $genome1 };

            # flip the values, too:
            my $rec = $genome2 . "\t" . $genome1 . "\t"
		. $ani2 . "\t" . $ani1 . "\t" . $af2 . "\t" . $af1 . "\t" . $bbh_cnt;
            push @dataRecs, $rec;
            $precomputed{ $genome2 . "," . $genome1 } = 1;
        }
        $cur->finish();
    }
    OracleUtil::truncTable($dbh, "gtt_num_id")
	if ($tx_str1 =~ /gtt_num_id/i);

    foreach my $tx1 (@oids1) {
        foreach my $tx2 (@oids2) {
	    next if $tx1 eq $tx2;
            next if exists $precomputed{ $tx1 . "," . $tx2 };
            next if exists $precomputed{ $tx2 . "," . $tx1 };
            print "<br/>Computing on demand $tx1 vs $tx2...<br>\n";

            $tx1 = checkPath($tx1);
            $tx2 = checkPath($tx2);

	    my $dir = "/global/projectb/scratch/img/www-data/service/tmp/ANI";
            my $tmp_out_file = "$dir/ANI_output_" . $tx1 . '-' . $tx2 . '-' . "$$.txt";
            my $work_dir = '/global/projectb/scratch/img/www-data/service/tmp/ANI'; # TODO ken cache test
            #my $tmp_out_file = "$tmp_dir/ANI_output_" . $tx1 . $tx2 . "$$.txt";
            #my $work_dir = "$cgi_tmp_dir/ani.work.$$.dir";
            #my $work_dir = '/webfs/scratch/img/ANI'; # TODO ken cache test

            WebUtil::unsetEnvPath();

            # TODO afther workshop move this to a common bin dir along with Evan's abc scripts
            my $cmd =
                "/global/homes/k/klchu/Dev/svn/webUI/webui.cgi/bin/calculateANI.img.pl "
                #"$cgi_dir/bin/calculateANI.img.pl "
              . "-taxon1    $tx1 "
              . "-taxon2    $tx2 "
              . "-directory $work_dir "
              . "-o         $tmp_out_file ";
            #my $perl_bin = $env->{perl_bin};
	    #my $st = runCmdNoExit("$perl_bin -I `pwd`  $cmd");
	    
	    my ( $cmdFile, $stdOutFilePath ) = Command::createCmdFile( $cmd, $work_dir );           
	    Command::startDotThread();
	    
	    my $stdOutFile = Command::runCmdViaUrl( $cmdFile, $stdOutFilePath );
	    if ( $stdOutFile == -1 ) {		
                Command::killDotThread();
                # close working div but do not clear the data
                printEndWorkingDiv( '', 1 );
                printStatusLine( "Error.", 2 );
                WebUtil::webExit(-1);
            }
            Command::killDotThread();
    
	    webLog("\ncalculateANI: + $cmd\n");
            WebUtil::resetEnvPath();

            if (!(-e $tmp_out_file)) {
                next;
            }
            my $rfh = newReadFileHandle($tmp_out_file, "calculateANI");
            my $count = 0;
            my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt);
            while (my $s = $rfh->getline()) {
                chomp $s;
                $count++;

		if ($count == 2) {
		    my ($genome1x,    $genome2x,    $size1,     $size2,     $csize,    $total_bbh, $valid_bbh,
			$genome1_bbh, $genome2_bbh, $bbh_size1, $bbh_size2, $aligned1, $aligned2,  $caligned,
			$ani1x,       $ani2x,       $af1x,      $af2x,      $cani,     $final_ani, $final_af)
			= split(/\t/, $s);
		    $genome1 = $genome1x;
		    $genome2 = $genome2x;
		    $ani1    = $ani1x;
		    $ani2    = $ani2x;
		    $af1     = $af1x;
		    $af2     = $af2x;
		    $bbh_cnt = $total_bbh;
		}
            }

            my $rec = $genome1 . "\t" . $genome2 . "\t"
		. $ani1 . "\t" . $ani2 . "\t" . $af1 . "\t" . $af2 . "\t" . $bbh_cnt;
            push @dataRecs, $rec;
        }
    }

    if ($img_ken) {
        printEndWorkingDiv('', 1);
    } else {
        printEndWorkingDiv();
    }

    return (\@dataRecs, \%precomputed);
}

sub doPairwiseWithUpload {
    my @oids = param("genomeFilterSelections");

    print "<h1>Pairwise ANI with Sequence Upload</h1>";

    my $dbh = dbLogin();
    my $sql = qq{
        select distinct tx.taxon_oid
        from taxon tx
        where tx.taxon_display_name = ?
    };

    my $txTerm = param("taxonTerm");    # from the autocomplete field
    if ($txTerm && $txTerm ne "") {
        my $cur = execSql($dbh, $sql, $verbose, $txTerm);
        my ($taxon_oid) = $cur->fetchrow();    # just get one
        push @oids, $taxon_oid if $taxon_oid && $taxon_oid ne "";
    }

    my $nTaxons0 = @oids;
    if ($nTaxons0 < 1) {
        WebUtil::webError("Please select up to 100 genomes.");
    }

    my $tx_str = join(",", @oids);
    my $sql    = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name
        from taxon tx
        where tx.taxon_oid in ($tx_str)
    };
    my $cur = execSql($dbh, $sql, $verbose);
    my %taxon2name;
    for ( ;; ) {
        my ($taxon_oid, $taxon_name) = $cur->fetchrow();
        last if (!$taxon_oid);
        $taxon2name{$taxon_oid} = $taxon_name;
    }

    my @dataRecs;
    my ($fh_aref) = computePairwiseANIWithUpload(\@dataRecs, \@oids, "uploadFnaFile");

    print "<p style='width: 650px;'>";
    print "<u>Uploaded Sequence(s)</u>: " . join(", ", @$fh_aref);
    print "</p>";

    if (scalar @dataRecs < 1) {
        WebUtil::webError("Could not compute data for selected genomes.");
    }

    printPairwiseWithUploadTable(\%taxon2name, \@dataRecs);
}

sub computePairwiseANIWithUpload {
    my ($dataRecs_aref, $oids_aref, $filename) = @_;
    my @oids = @$oids_aref;

    my ($fh_aref, $upload_files_aref) = uploadLocalFile($filename);

    printStartWorkingDiv("withupload");
    print "<p>Uploading...";

    my $idx = 0;
    foreach my $fh (@$fh_aref) {
        my $tmp_upload_file = @$upload_files_aref[$idx];
        $tmp_upload_file = checkPath($tmp_upload_file);
	close $fh; # close upload file handle

        foreach my $tx (@oids) {
            print "<br/>Computing on demand $fh vs $tx...";

            $tx = checkPath($tx);

            #my $dir = "/global/projectb/scratch/img/www-data/service/tmp/ANI";
            #my $tmp_out_file = "$dir/ANI_output_" . $idx . '-' . $tx . '-' . "$$.txt";
            #my $work_dir = '/global/projectb/scratch/img/www-data/service/tmp/ANI';
            my $tmp_out_file = "$tmp_dir/ANI_output_" . $idx . $tx . "$$.txt";
            my $work_dir = "$cgi_tmp_dir/ani.work.$$.dir";

            WebUtil::unsetEnvPath();

            my $cmd =
                #"/global/homes/k/klchu/Dev/svn/webUI/webui.cgi/bin/calculateANI.img.pl "
                "$cgi_dir/bin/calculateANI.img.pl "
              . "-seq1      $tmp_upload_file "
              . "-taxon2    $tx "
              . "-directory $work_dir "
              . "-o         $tmp_out_file ";
            my $perl_bin = $env->{perl_bin};
            my $st = runCmdNoExit("$perl_bin -I `pwd`  $cmd");

            #my ( $cmdFile, $stdOutFilePath ) = Command::createCmdFile( $cmd, $work_dir );
	    #Command::startDotThread();

            #my $stdOutFile = Command::runCmdViaUrl( $cmdFile, $stdOutFilePath );
            #if ( $stdOutFile == -1 ) {
                # close working div but do not clear the data
            #    printEndWorkingDiv( '', 1 );
	    #    Command::killDotThread();
            #    printStatusLine( "Error.", 2 );
	    #    WebUtil::webExit(-1);
            #}
	    #Command::killDotThread();

            webLog("\ncalculateANI with upload: + $cmd\n");
            WebUtil::resetEnvPath();

            if (!(-e $tmp_out_file)) {
                next;
            }
            my $rfh = newReadFileHandle($tmp_out_file, "calculateANI");
            my $count = 0;
            my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt);
            while (my $s = $rfh->getline()) {
                chomp $s;
                $count++;

		if ($count == 2) {
		    my ($genome1x,    $genome2x,    $size1,     $size2,     $csize,    $total_bbh, $valid_bbh,
			$genome1_bbh, $genome2_bbh, $bbh_size1, $bbh_size2, $aligned1, $aligned2,  $caligned,
			$ani1x,       $ani2x,       $af1x,      $af2x,      $cani,     $final_ani, $final_af)
			= split(/\t/, $s);
		    $genome1 = $genome1x;
		    $genome2 = $genome2x;
		    $ani1    = $ani1x;
		    $ani2    = $ani2x;
		    $af1     = $af1x;
		    $af2     = $af2x;
		    $bbh_cnt = $total_bbh;
		}
            }

            my $rec = $genome1 . "\t" . $genome2 . "\t"
		. $ani1 . "\t" . $ani2 . "\t" . $af1 . "\t" . $af2 . "\t" . $bbh_cnt;
            push @$dataRecs_aref, $rec;
        }
        $idx++;
    }

    printEndWorkingDiv("withupload");

    return $fh_aref;
}

sub printPairwiseWithUploadTable {
    my ($taxon2name_href, $dataRecs_aref, $notitle, $msg) = @_;

    if (!$notitle) {
        WebUtil::printHeaderWithInfo
	    ("Pairwise ANI", "", "",
	     "Pairwise ANI Info", 0, "ANI.pdf");

        if ($msg) {
            print "<p style='width: 650px;'>";
            print $msg;
            print "</p>";
        }
    }

    my $it = new InnerTable(1, "anipairwiseupload$$", 'anipairwiseupload', 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Sequence Name", "asc", "left");

    #$it->addColSpec("Genome1 Name", "asc", "left");
    $it->addColSpec("Genome2 ID",   "asc", "right");
    $it->addColSpec("Genome2 Name", "asc", "left");
    $it->addColSpec("ANI1->2",      "asc", "right");
    $it->addColSpec("ANI2->1",      "asc", "right");
    $it->addColSpec("AF1->2",       "asc", "right");
    $it->addColSpec("AF2->1",       "asc", "right");
    $it->addColSpec("Total BBH",    "asc", "right");

    my $taxon_url = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=";

    my $cnt = 0;
    foreach my $rec (@$dataRecs_aref) {
        my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $bbh_cnt) = split("\t", $rec);

        my $taxon_name2 = $taxon2name_href->{$genome2};
        my $taxon_link2 = alink($taxon_url . $genome2, $taxon_name2);

        my $row;
        $row .= $genome1 . $sd . $genome1 . "\t";
        $row .= $genome2 . $sd . $genome2 . "\t";
        $row .= $taxon_name2 . $sd . $taxon_link2 . "\t";

        $row .= $ani1 . "\t";
        $row .= $ani2 . "\t";

        $af1 = sprintf("%.3f", $af1) if $af1 ne "";
        $af2 = sprintf("%.3f", $af2) if $af2 ne "";
        $row .= $af1 . "\t";
        $row .= $af2 . "\t";

        $row .= $bbh_cnt . "\t";

        $it->addRow($row);
        $cnt++;
    }

    $it->printOuterTable(1) if $cnt > 0;
    printStatusLine("loaded", 2);
}

sub uploadLocalFile {
    my ($localfile) = @_;

    my @fhs = upload($localfile);
    my @myfhs = ();
    my @myupload_files = ();

    my $idx = 0;
    my $error = "";
    foreach my $fh (@fhs) {
        my $tmp_upload_file = "$tmp_dir/ANI_upload_" . $idx . "_$$.fna";
        my $tmp_upload_file = "$tmp_dir/$fh";
        my $wfh = newWriteFileHandle($tmp_upload_file, "uploadFNAFile");

        my $mimetype  = uploadInfo($fh);
        my $file_size = 0;
        my $seq;
        while (my $s = <$fh>) {
            $s =~ s/\r/\n/g;
            $file_size += length($s);
            print $wfh $s;

            next if $s =~ /^>/;
            $seq .= $s;
            my $seq1 = $s;

            # check if sequence is valid
            chomp $seq1;
            chomp $seq;
        }
        close $wfh;

        if ($file_size < 1) {
            $error .= "File $fh has no contents to upload. ";
        }
        if (!$seq !~ tr/acgtnACGTN//c) {
            $error .= "File $fh is not in a FASTA nucleotide format. ";
        }
        if ($seq !~ tr/acgtnACGTN//c && $file_size > 0) {
            push @myfhs, $fh;
            push @myupload_files, $tmp_upload_file;
        } else {
	    close $fh;
	}

        $idx++;
    }

    if (scalar @myfhs < 1) {
        WebUtil::webError($error);
    }

    return (\@myfhs, \@myupload_files);
}

sub printSameSpeciesPairwiseForm {
    WebUtil::printHeaderWithInfo
	("Same Species Pairwise", "", "",
	 "Same Species Pairwise Info", 0, "ANI.pdf");

    print "<p>";
    print "Please select no more than 100 species to analyze using pairwise ANI. ";
    print "<br/>Please note that it may not be possible to display the plot for species that have more than 200 genomes.";
    print "</p>";

    my $formid = "anibyspecies";
    print start_form(-id     => $formid."_frm",
		     -name   => "mainForm",
		     -action => "$main_cgi");

    print "<script type='text/javascript' src='$top_base_url/js/checkSelection.js'></script>\n";
    my $name = "_section_ANI_plotSameSpeciesPairwise";
    print submit(
        -name    => $name,
        -value   => "Plot Same Species Pairwise",
        -class   => "medbutton",
        -onClick => "return validateItemSelection(1, '', \"$formid\", \"genus_species\");"
    );
    print nbsp(1);

    print "<input type='button' name='clearAll' value='Clear All' "
	. "onClick='selectAllCheckBoxes(0)' class='smbutton' />\n";

    my $spc_cnt = printAllSpeciesInfo(0, 1);

    my $name = "_section_ANI_plotSameSpeciesPairwise";
    print submit(
        -name    => $name,
        -value   => "Plot Same Species Pairwise",
        -class   => "medbutton",
        -onClick => "return validateItemSelection(1, '', \"$formid\", \"genus_species\");"
    );

    print nbsp(1);
    print "<input type='button' name='clearAll' value='Clear All' "
	. "onClick='selectAllCheckBoxes(0)' class='smbutton' />\n";

    print end_form();
}

sub plotSameSpeciesPairwise {
    my $pt_type = param("samespecies");     # type of points: af-ani or final
    my @genus_species = param("genus_species");

    my $dbh = dbLogin();

    # for each genus-species, find all the genomes
    # and for each of the genomes, get the values ngenomes x ngenomes matrix

    my @samples;
    foreach my $genus_species (@genus_species) {
        my ($lineage_href, $taxons_aref, $tx2genus_aref) = getLineage($genus_species);
        my @taxonids = sort @$taxons_aref;
        my $nTaxons = scalar @taxonids;
        next if $nTaxons < 2;

        my $taxonClause1;
        my $taxonClause2;
        if (scalar(@taxonids) > 0) {
            #my $taxon_ids_str = OracleUtil::getNumberIdsInClause($dbh, @taxonids);
            my $taxon_ids_str = OracleUtil::getIdsInClauseForTwo($dbh, 'gtt_num_id', '', 1, \@taxonids);
            $taxonClause1 = " and tam.genome1 in ($taxon_ids_str) ";
            $taxonClause2 = " and tam.genome2 in ($taxon_ids_str) ";

            # replace the "select id from" with "select id, id from"
	    if ($taxon_ids_str =~ /gtt_num_id/i) {
		$taxonClause1 = " and (tam.genome1, tam.genome2) in ($taxon_ids_str) ";
		$taxonClause2 = "";
	    }
        }

        my $sql = qq{
            select distinct tam.genome1, tam.genome2,
                   tam.ani1, tam.ani2, tam.fraction1, tam.fraction2,
                   tam.final_ani, tam.final_fraction
            from taxon_ani_matrix tam
            where 1 = 1
            $taxonClause1
            $taxonClause2
        };
        my $cur = execSql($dbh, $sql, $verbose);
        for ( ;; ) {
            my ($genome1, $genome2, $ani1, $ani2, $af1, $af2, $fani, $ff) = $cur->fetchrow();
            last if !$genome1;

            $af1 = sprintf("%.3f", $af1) if $af1 ne "";
            $af2 = sprintf("%.3f", $af2) if $af2 ne "";
            $ff  = sprintf("%.3f", $ff)  if $ff  ne "";

            my %subhash;
	    $subhash{'id'}     = $genus_species;
	    $subhash{'name'}   = "Species";
	    $subhash{'desc'}   = $genome1." - ".$genome2;
            $subhash{'xdata'}  = $fani + 0;
            $subhash{'ydata'}  = $ff + 0;
	    $subhash{'genus1'} = $tx2genus_aref->{$genome1};
	    $subhash{'genus2'} = $tx2genus_aref->{$genome2};

            push @samples, \%subhash;
        }

        OracleUtil::truncTable($dbh, "gtt_num_id")
	    if ($taxonClause1 =~ /gtt_num_id/i);
        OracleUtil::truncTable($dbh, "gtt_num_id")
	    if ($taxonClause2 =~ /gtt_num_id/i);
    }

    my $data = encode_json(\@samples);
    my $div_id = "samespeciesplot";
    my $txurl = "$main_cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=";

    if ($include_metagenomes) {
        WebUtil::printHeaderWithInfo
            ("ANI Same Species Plot", "", "",
	     "ANI Same Species Plot Info", 1, "ANI.pdf");
    } else {
        WebUtil::printHeaderWithInfo
            ("ANI Same Species Plot", "", "",
	     "ANI Same Species Plot Info", 0, "ANI.pdf");
    }
    my $hint = "The plot can be repositioned using mouse-drag and zoomed using mouse-wheel.<br/>"
	. "Click on a dot for options to add component genomes to cart.";
    printHint($hint);

    # template for table dialog popup over the scatterplot:
    my $template = HTML::Template->new(filename => "$base_dir/sameSpeciesPairwise.html");
    $template->param(columns => "<th>Genome</th><th>Species</th><th>Genus</th>");
    $template->param(top_base_url => $top_base_url);
    print $template->output;

    # plot the data
    print qq{
      <link rel="stylesheet" type="text/css" href="$top_base_url/css/d3scatterplot.css" />
      <script src="$top_base_url/js/d3.min.js"></script>
      <div id="$div_id" class="$div_id"></div>
      <script src="$top_base_url/js/d3scatterplot.min.js"></script>
      <script>
          window.onload = drawScatterPlot
          ("$div_id", $data, 1, 0, 1, 0, "$txurl", "Final ANI", "Final AF");
      </script>

      <script>
      function addRow(table, data, selected_genomes) {
          console.log("calling ANI:addRow()");
          var genomes = data.desc.split(" - ");
          if (!(genomes[0] in selected_genomes)) {
	      table.row.add([genomes[0], genomes[0], data.id, data.genus1]).draw();
          }
          if (!(genomes[1] in selected_genomes)) {
	      table.row.add([genomes[1], genomes[1], data.id, data.genus2]).draw();
          }
          selected_genomes[genomes[0]] = 1;
          selected_genomes[genomes[1]] = 1;
      }
      </script>
    };
}

sub printAllCliques {
    my ($show_title) = @_;
    $show_title = 0 if $show_title eq "";
    print "<h1>Clique Browser</h1>" if $show_title;

    my $dbh = dbLogin();

    my $sql = qq{
        select distinct acm.CLIQUE_ID, ac.clique_type,
               ac.intra_clique_ani, ac.intra_clique_af,
               count(distinct tx.taxon_oid)
        from taxon tx, ANI_CLIQUE_MEMBERS acm, ANI_CLIQUE ac
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        and acm.CLIQUE_ID = ac.CLIQUE_ID
        group by acm.CLIQUE_ID, ac.clique_type, 
                 ac.intra_clique_ani, ac.intra_clique_af
    };
    my $cur = execSql($dbh, $sql, $verbose);

    my $it = new InnerTable(1, "anicliques$$", 'anicliques', 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Clique ID",            "asc", "right");
    $it->addColSpec("Clique Type",          "asc", "center");
    $it->addColSpec("Intra-Clique ANI",     "asc", "right");
    $it->addColSpec("Intra-Clique AF",      "asc", "right");
    $it->addColSpec("Contributing Species", "asc", "left", '', '', '', (200));
    $it->addColSpec("Genome Count",         "asc", "right");

    my $clique2GenusSpecies_href = getAllClique2GenusSpecies($dbh);
    my $clique_url = "$section_cgi&page=cliqueDetails&clique_id=";
    my $cnt = 0;
    my %clique_groups;
    for ( ;; ) {
        my ($clique_id, $clique_type, $intra_ani, $intra_af, $genome_cnt) = $cur->fetchrow();
        last if (!$clique_id);

        my $row;
        my $link = alink($clique_url . $clique_id, $clique_id);
        $row .= $clique_id . $sd . $link . "\t";
        $row .= $clique_type . "\t";
        $row .= $intra_ani . "\t";
        $intra_af = sprintf("%.3f", $intra_af) if $intra_af ne "";
        $row .= $intra_af . "\t";

        my $species_href = $clique2GenusSpecies_href->{$clique_id};
        my @tmp = sort keys %$species_href;
        my $species = join(", ", @tmp);
        $row .= $species . "\t";
        $row .= $genome_cnt . "\t";

        if ($clique_type eq "clique-group") {
            $clique_groups{$clique_id} = $genome_cnt;
        }

        $it->addRow($row);
        $cnt++;
    }
    $it->printOuterTable(1);
    printStatusLine("$cnt cliques loaded", 2);
    return ($cnt, \%clique_groups);
}

sub printAllSpeciesInfo {
    my ($show_title, $show_cb) = @_;
    $show_title = 0 if $show_title eq "";
    $show_cb = 0 if $show_cb eq "";
    print "<h1>Species Browser</h1>" if $show_title;

    my $precomputed = 1;
    my %genus_species2txs;
    my %genus_species2domain;
    my %genus_species2clqcnt;
    my %genus_species2types;

    my $filename = "aniStats_allSpeciesInfo-2.stor";
    my $file = $ani_stats_dir . $filename;

    if (-e $file) {
        my $state = retrieve($file);
        $precomputed = 0 if (!defined($state));

        my $genus_species2txs_href    = $state->{genus_species2txs};
        my $genus_species2domain_href = $state->{genus_species2domain};
        my $genus_species2clqcnt_href = $state->{genus_species2clqcnt};
        my $genus_species2types_href  = $state->{genus_species2types};

        %genus_species2txs    = %$genus_species2txs_href;
        %genus_species2domain = %$genus_species2domain_href;
        %genus_species2clqcnt = %$genus_species2clqcnt_href;
        %genus_species2types  = %$genus_species2types_href;

    } else {
        $precomputed = 0;
    }

    if (!$precomputed) {
        my $dbh = dbLogin();

        my $sql = qq{
            select distinct tx.taxon_oid, tx.domain, 
                   tx.phylum, tx.genus, tx.species, tx.ani_species
            from taxon tx, ANI_CLIQUE_MEMBERS acm
            where tx.obsolete_flag = 'No'
            and tx.taxon_oid = acm.MEMBERS
        };
        my $cur = execSql($dbh, $sql, $verbose);

        for ( ;; ) {
            my ($taxon_oid, $domain, $phylum, $genus,
		$species, $ani_species) = $cur->fetchrow();
            last if (!$taxon_oid);

	    my $key = "$ani_species";
            my $dm = substr($domain, 0, 1);
            if (!(exists $genus_species2txs{$key})) {
                $genus_species2txs{$key} = $taxon_oid;
            } else {
                $genus_species2txs{$key} .= "," . $taxon_oid;
            }
            $genus_species2domain{$key} = $dm;
        }
    }

    my $cnt = 0;
    my $txurl = "$section_cgi&page=genomesForGenusSpecies&genus_species=";
    my $cqurl = "$section_cgi&page=cliquesForGenusSpecies&genus_species=";

    my $it = new InnerTable(1, "anibyspecies$$", "anibyspecies", 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Select") if $show_cb;
    $it->addColSpec("Domain",                         "asc",  "left");
    $it->addColSpec("Species",                        "asc",  "left");
    $it->addColSpec("Number of Genomes",              "desc", "right");
    $it->addColSpec("Number of Cliques",              "desc", "right");
    $it->addColSpec("Represented<br/>Clique Type(s)", "asc",  "left");

    foreach my $item (sort keys %genus_species2txs) {
        my $row;
        $row = $sd . "<input type='checkbox' name='genus_species' "
	    . " value='$item' />\t" if $show_cb;

        my $domain = $genus_species2domain{$item};
        $row .= $domain . "\t";
	$row .= $item . "\t";

        my @txs = split(",", $genus_species2txs{$item});
        my $tx_cnt = scalar @txs;

	if ($show_cb && $tx_cnt < 2) {
	    next;
	}

        my $link = alink($txurl . WebUtil::massageToUrl2($item) . "&domain=$domain", $tx_cnt);
        my $link = alink($txurl . $item, $tx_cnt);
        $row .= $tx_cnt . $sd . $link . "\t";

        my $clique_cnt = 0;
        my $types_str;

        if (!$precomputed) {
            my ($cliques_href, $types_href) = cliquesForGenomes(\@txs);
            $clique_cnt = scalar keys %$cliques_href;
            my @types = sort keys %$types_href;
            $types_str = join(", ", @types);
        } else {
            $clique_cnt = $genus_species2clqcnt{$item};
            $types_str = $genus_species2types{$item};
        }

	if ($show_cb && $types_str eq "singleton") {
	    next;
	}

        my $link = alink($cqurl . $item, $clique_cnt);
        $row .= $clique_cnt . $sd . $link . "\t";
        $row .= $types_str . "\t";

        $it->addRow($row);
        $cnt++;
    }
    $it->printOuterTable(1);
    printStatusLine("$cnt species loaded", 2);
    return $cnt;
}

sub cliquesForGenomes {
    my ($taxons) = @_;

    my $dbh = dbLogin();
    my $taxonClause;
    if (scalar(@$taxons) > 0) {
        my $taxon_ids_str = OracleUtil::getNumberIdsInClause($dbh, @$taxons);
        $taxonClause = " and acm.members in ($taxon_ids_str) ";
    }

    my $sql = qq{
        select distinct acm.CLIQUE_ID, ac.clique_type
        from ANI_CLIQUE_MEMBERS acm, ANI_CLIQUE ac
        where acm.CLIQUE_ID = ac.CLIQUE_ID
        $taxonClause
    };
    my $cur = execSql($dbh, $sql, $verbose);
    my %clique2type;
    my %types;
    for ( ;; ) {
        my ($clique_id, $clique_type) = $cur->fetchrow();
        last if !$clique_id;
        $clique2type{$clique_id} = $clique_type;
        $types{$clique_type}     = 1;
    }

    OracleUtil::truncTable($dbh, "gtt_num_id")
	if ($taxonClause =~ /gtt_num_id/i);
    return (\%clique2type, \%types);
}

sub printTaxonomyInfo {
    my $hint = "The leaf nodes display <u>Genus Species</u> followed by the count of cliques for that genus-species";
    printHint($hint);
    print "<br/>";

    print qq{
    <table border="0">
    <tr>
      <td><b>Sequencing Status</b></td>
      <td><b>Domain</b></td>
    </tr>
    <tr>
      <td><select id="seqstatus" name="seqstatus">
          <option selected="selected" value="Finished">Finished</option>
          <option value="Permanent Draft">Permanent Draft</option>
          <option value="Draft">Draft</option>
          <option value="both">All Finished, Permanent Draft and Draft</option>
          </select>
      </td>
      <td><select id="domainfilter" name="domainfilter">
    };
    print qq{
           <option value="Archaea" selected="selected">Archaea</option>
           <option value="Bacteria">Bacteria</option>
           <option value="Eukaryota">Eukaryota</option>
        </select>
    };

    my $cbmode = 1;
    my $fn     = "javascript:showButtonClicked" . "('$base_url', '$xml_cgi', $cbmode, 'ani');";
    print qq{
        <input id='showButton' type="button" value='Show' onclick=\"$fn\" />
    };

    print qq{
      </td>
    </tr>
    </table>
    };

    printPhylogeneticTree($cbmode);

    print qq{
        <script type="text/javascript" >
        window.onload = function() {
            //window.alert("window.onload");
            showButtonClicked('$base_url', '$xml_cgi', $cbmode, 'ani');
        }
        </script>
    };
}

sub printPhylogeneticTree {
    my ($cbmode) = @_;

    my $cbYUIClass;
    if ($cbmode) {
        $cbYUIClass = "class='ygtv-checkbox'";
    }

    print qq{
        <div id="treediv1ANI"></div>
        <div id="treediv2ANI" $cbYUIClass></div>
        <script type="text/javascript">
        printEmptyPhylo('ani');
        </script>
    };
}

sub printGenomesForGenusSpecies {
    my ($genus_species, $seqstatus, $table_only) = @_;
    my $genus_species0 = param("genus_species");
    my $seqstatus0     = param("seqstatus");
    my $dm0            = param("domain");

    $table_only    = 0               if $table_only    eq "";
    $genus_species = $genus_species0 if $genus_species eq "";
    $seqstatus     = $seqstatus0     if $seqstatus     eq "";

    my $status_str = $seqstatus;
    $status_str = "All Finished, Permanent Draft and Draft"
	if $seqstatus && $seqstatus eq "both";

    my $dbh = dbLogin();

    my @binds;
    my $statusClause;
    if ($seqstatus && $seqstatus ne "both") {
        $statusClause = " and tx.seq_status = ? ";
        push @binds, $seqstatus;
    }

    my $sql = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name,
               tx.species, tx.ani_species, tx.domain, tx.phylum,
               tx.ir_class, tx.ir_order, tx.family, tx.genus, acm.CLIQUE_ID
        from taxon tx, ANI_CLIQUE_MEMBERS acm
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        $statusClause
        and tx.ani_species = ?
    };
    push @binds, $genus_species;
    my $cur = execSql($dbh, $sql, $verbose, @binds);

    my %taxon2name;
    my %tx2cliques;
    my %taxon2lineage;
    my %lineage_h;

    for ( ;; ) {
        my ($taxon_oid, $taxon_name, $species, $ani_species, $domain, $phylum,
	    $class, $order, $family, $genus, $clique_id) = $cur->fetchrow();
        last if (!$taxon_oid);

        if ($dm0 && $dm0 ne "") {
            my $dm = substr($domain, 0, 1);
            next if $dm ne $dm0;
        }

        push @{ $tx2cliques{$taxon_oid} }, $clique_id;
        $taxon2name{$taxon_oid} = $taxon_name;

        my $lineage = $domain . "\t" . $phylum . "\t" . $class . "\t"
	    . $order . "\t" . $family . "\t" . $genus;
        $taxon2lineage{$taxon_oid} = $lineage;
        $lineage_h{$lineage} = 1;
    }

    if (!$table_only) {
        print "<h1>Genomes for Species</h1>";
        print "<p><u>Genus Species</u>: $genus_species";
    }

    if (!$table_only && scalar keys %lineage_h == 1) {
        foreach my $item (keys %lineage_h) {
            my ($domain, $phylum, $class, $order, $family, $genus) = split("\t", $item);

            require TaxonDetail;
            my $lineage = TaxonDetail::lineageLink("domain", $domain) . ";";
            $lineage .= TaxonDetail::lineageLink("phylum",   $phylum) . "; ";
            $lineage .= TaxonDetail::lineageLink("ir_class", $class) . "; ";
            $lineage .= TaxonDetail::lineageLink("ir_order", $order) . "; ";
            $lineage .= TaxonDetail::lineageLink("family",   $family) . "; ";
            $lineage .= TaxonDetail::lineageLink("genus",    $genus) . "; ";
            chop $lineage;
            chop $lineage;

            print "<br/><u>Taxonomy</u>: $lineage";
        }
    }

    if (!$table_only) {
        print "<br/><u>Sequence Status</u>: $status_str" if $seqstatus;
        print "</p>";
    }

    my $it = new InnerTable(1, "tx4genusspecies$$", "tx4genusspecies", 3);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Select");
    $it->addColSpec("Genome ID",   "asc", "right");
    $it->addColSpec("Genome Name", "asc", "left");
    $it->addColSpec("Clique ID",   "asc", "right");
    if (scalar keys %lineage_h > 1) {
        $it->addColSpec("Domain", "asc", "left");
        $it->addColSpec("Phylum", "asc", "left");
        $it->addColSpec("Class",  "asc", "left");
        $it->addColSpec("Order",  "asc", "left");
        $it->addColSpec("Family", "asc", "left");
        $it->addColSpec("Genus",  "asc", "left");
    }

    foreach my $tx (keys %tx2cliques) {
        my @cliques    = @{ $tx2cliques{$tx} };
        my $clique_str = join(", ", @cliques);
        my $taxon_name = $taxon2name{$tx};

        my $taxon_url  = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=$tx";
        my $taxon_link = alink($taxon_url, $taxon_name);

        my $row;
        my $row = $sd . "<input type='checkbox' name='taxon_filter_oid' " . " value='$tx' />\t";
        $row .= $tx . $sd . $tx . "\t";
        $row .= $taxon_name . $sd . $taxon_link . "\t";

        my $cnt = 0;
        foreach my $clique_id (@cliques) {
            print ", " if ($cnt > 0);
            my $cliqueUrl = "$section_cgi&page=cliqueDetails&clique_id=$clique_id";
            my $link = alink($cliqueUrl, $clique_id);
            $row .= $clique_id . $sd . $link;
            $cnt++;
        }
        $row .= "\t";

        my $lineage = $taxon2lineage{$tx};
        my ($domain, $phylum, $class, $order, $family, $genus) = split("\t", $lineage);

        if (scalar keys %lineage_h > 1) {
            require TaxonDetail;
            $row .= $domain . $sd . $domain . "\t";
            $row .= $phylum . $sd . $phylum . "\t";
            $row .= $class . $sd . $class . "\t";
            $row .= $order . $sd . TaxonDetail::lineageLink("ir_order", $order) . "\t";
            $row .= $family . $sd . TaxonDetail::lineageLink("family", $family) . "\t";
            $row .= $genus . $sd . TaxonDetail::lineageLink("genus", $genus) . "\t";
        }

        $it->addRow($row);
    }

    my $size = scalar keys %taxon2name;
    printMainForm();
    TaxonSearchUtil::printButtonFooter("tx4genusspecies") if $size > 10;
    $it->printOuterTable(1);
    TaxonSearchUtil::printButtonFooter("tx4genusspecies");
    print end_form();

    printStatusLine("$size Loaded", 2);
}

sub printCliquesForGenusSpecies {
    my ($genus_species, $seqstatus, $table_only) = @_;
    my $genus_species0 = param("genus_species");
    my $seqstatus0 = param("seqstatus");

    $table_only    = 0               if $table_only    eq "";
    $genus_species = $genus_species0 if $genus_species eq "";
    $seqstatus     = $seqstatus0     if $seqstatus     eq "";

    my $status_str = $seqstatus;
    $status_str = "All Finished, Permanent Draft and Draft"
	if $seqstatus && $seqstatus eq "both";

    my $dbh = dbLogin();

    my @binds;
    my $statusClause;
    if ($seqstatus && $seqstatus ne "both") {
        $statusClause = " and tx.seq_status = ? ";
        push @binds, $seqstatus;
    }

    my $sql = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name,
               tx.species, tx.ani_species, tx.domain, tx.phylum,
               tx.ir_class, tx.ir_order, tx.family, tx.genus, acm.CLIQUE_ID
        from taxon tx, ANI_CLIQUE_MEMBERS acm
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        $statusClause
        and tx.ani_species = ?
    };
    push @binds, $genus_species;
    my $cur = execSql($dbh, $sql, $verbose, @binds);

    my %clique2txs;
    my %lineage_h;

    for ( ;; ) {
        my ($taxon_oid, $taxon_name, $species, $ani_species, $domain, $phylum,
	    $class, $order, $family, $genus, $clique_id) = $cur->fetchrow();
        last if (!$taxon_oid);

        $clique2txs{$clique_id}++;

        my $lineage = $domain . "\t" . $phylum . "\t" . $class . "\t"
	    . $order . "\t" . $family . "\t" . $genus;
        $lineage_h{$lineage} = 1;
    }

    if (!$table_only) {
        print "<h1>Cliques for Species</h1>";
        print "<p><u>Genus Species</u>: $genus_species";

        foreach my $item (keys %lineage_h) {
            my ($domain, $phylum, $class, $order, $family, $genus) = split("\t", $item);

            require TaxonDetail;
            my $lineage = TaxonDetail::lineageLink("domain", $domain) . ";";
            $lineage .= TaxonDetail::lineageLink("phylum",   $phylum) . "; ";
            $lineage .= TaxonDetail::lineageLink("ir_class", $class) . "; ";
            $lineage .= TaxonDetail::lineageLink("ir_order", $order) . "; ";
            $lineage .= TaxonDetail::lineageLink("family",   $family) . "; ";
            $lineage .= TaxonDetail::lineageLink("genus",    $genus) . "; ";
            chop $lineage;
            chop $lineage;

            print "<br/><u>Taxonomy</u>: $lineage";
        }

        print "<br/><u>Sequence Status</u>: $status_str" if $seqstatus;
        print "</p>";
    }

    my @cliques = keys %clique2txs;
    WebUtil::webError("Cannot find cliques for $genus_species") if scalar @cliques < 1;

    my $clique_str = join(",", @cliques);
    my $sql = qq{
        select distinct acm.CLIQUE_ID, ac.clique_type
        from ANI_CLIQUE_MEMBERS acm, ANI_CLIQUE ac
        where acm.CLIQUE_ID = ac.CLIQUE_ID
        and acm.CLIQUE_ID in ($clique_str)
    };
    my $cur = execSql($dbh, $sql, $verbose);

    my $it = new InnerTable(1, "cliques4species$$", 'cliques4species', 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Clique ID", "asc", "right");
    $it->addColSpec("Clique Type", "asc", "center");
    $it->addColSpec("Genome Count<br/><i>$genus_species</i> <u>only</u>", "asc", "right");

    my $clique_url = "$section_cgi&page=cliqueDetails&clique_id=";
    my $cnt = 0;
    for ( ;; ) {
        my ($clique_id, $clique_type) = $cur->fetchrow();
        last if (!$clique_id);

        my $row;
        my $link = alink($clique_url . $clique_id, $clique_id);
        $row .= $clique_id . $sd . $link . "\t";
        $row .= $clique_type . "\t";
        $row .= $clique2txs{$clique_id} . "\t";

        $it->addRow($row);
        $cnt++;
    }
    $it->printOuterTable(1);
    printStatusLine("$cnt cliques loaded", 2);
}

sub getLineage {
    my ($genus_species, $seqstatus) = @_;

    my $dbh = dbLogin();

    my @binds;
    my $statusClause;
    if ($seqstatus && $seqstatus ne "both") {
        $statusClause = " and tx.seq_status = ? ";
        push @binds, $seqstatus;
    }

    my $sql = qq{
        select distinct tx.taxon_oid, tx.taxon_display_name,
               tx.species, tx.ani_species, tx.domain, tx.phylum,
               tx.ir_class, tx.ir_order, tx.family, tx.genus
        from taxon tx, ANI_CLIQUE_MEMBERS acm
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        $statusClause
        and tx.ani_species = ?
    };
    push @binds, $genus_species;
    my $cur = execSql($dbh, $sql, $verbose, @binds);

    my %lineage_h;
    my %taxon2genus;
    my @taxons;
    for ( ;; ) {
        my ($taxon_oid, $taxon_name, $species, $ani_species, $domain, $phylum,
	    $class, $order, $family, $genus) = $cur->fetchrow();
        last if (!$taxon_oid);

        my $lineage = $domain . "\t" . $phylum . "\t" . $class . "\t"
	    . $order . "\t" . $family . "\t" . $genus;
        $lineage_h{$lineage} = 1;
	$taxon2genus{$taxon_oid} = $genus;
        push @taxons, $taxon_oid;
    }

    return \%lineage_h, \@taxons, \%taxon2genus;
}

sub printInfoForGenusSpecies {
    my $genus_species = param("genus_species");
    my $seqstatus     = param("seqstatus");

    my $status_str = $seqstatus;
    $status_str = "All Finished, Permanent Draft and Draft"
	if $seqstatus && $seqstatus eq "both";

    my ($lineage_href, $taxons_aref, $tx2genus_aref) = getLineage($genus_species, $seqstatus);

    print "<h1>Species Detail</h1>";
    print "<p><u>Genus Species</u>: $genus_species";

    foreach my $item (keys %$lineage_href) {
        my ($domain, $phylum, $class, $order, $family, $genus) = split("\t", $item);

        require TaxonDetail;
        my $lineage = TaxonDetail::lineageLink("domain", $domain) . ";";
        $lineage .= TaxonDetail::lineageLink("phylum",   $phylum) . "; ";
        $lineage .= TaxonDetail::lineageLink("ir_class", $class) . "; ";
        $lineage .= TaxonDetail::lineageLink("ir_order", $order) . "; ";
        $lineage .= TaxonDetail::lineageLink("family",   $family) . "; ";
        $lineage .= TaxonDetail::lineageLink("genus",    $genus) . "; ";
        chop $lineage;
        chop $lineage;

        print "<br/><u>Taxonomy</u>: $lineage";
    }

    print "<br/><u>Sequence Status</u>: $status_str" if $seqstatus;
    print "</p>";

    require TabHTML;
    TabHTML::printTabAPILinks("infogsTab");

    my @tabIndex = ("#infogstab1", "#infogstab2");
    my @tabNames = ("Cliques for Species", "Genomes for Species");
    TabHTML::printTabDiv("infogsTab", \@tabIndex, \@tabNames);

    print "<div id='infogstab1'>";
    printCliquesForGenusSpecies($genus_species, $seqstatus, 1);
    print "</div>";    # end infogstab1

    print "<div id='infogstab2'>";
    printGenomesForGenusSpecies($genus_species, $seqstatus, 1);
    print "</div>";    # end infogstab2

    TabHTML::printTabDivEnd();
}

sub printCliqueDetails {
    my $clique_id = param("clique_id");
    my $dbh = dbLogin();

    my $sql = qq{
        select ac.clique_type, ac.intra_clique_ani, ac.intra_clique_af
        from ANI_CLIQUE ac
        where ac.CLIQUE_ID = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $clique_id);
    my ($clique_type, $intra_ani, $intra_af) = $cur->fetchrow();
    $intra_af = sprintf("%.3f", $intra_af) if $intra_af ne "";

    my $sql = qq{
        select tx.taxon_oid, tx.taxon_display_name,
               tx.domain, tx.phylum, tx.genus,
               tx.species, tx.ani_species
        from taxon tx, ANI_CLIQUE_MEMBERS acm
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        and acm.CLIQUE_ID = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $clique_id);

    my $nGenomes = 0;
    my %taxon2info;

    for ( ;; ) {
        my ($taxon_oid, $taxon_name, $domain, $phylum,
	    $genus, $species, $ani_species) = $cur->fetchrow();
        last if (!$taxon_oid);

        my $key = "$ani_species";
        my $dm = substr($domain, 0, 1);
        $taxon2info{$taxon_oid} = $dm . "\t" . $taxon_name . "\t" . $key;
        $nGenomes++;
    }

    print "<h1>Clique Details</h1>";
    print "<p><u>Clique ID</u>: $clique_id </p>";

    require TabHTML;
    TabHTML::printTabAPILinks("cliqueDetailsTab");

    my @tabIndex = ("#cliquetab0", "#cliquetab1", "#cliquetab2");
    my @tabNames = ("Overview", "Genomes in Clique", "Similar Cliques");

    if ($clique_type eq "clique-group" && $nGenomes < 32) {
        push @tabIndex, "#cliquetab3";
        push @tabNames, "Group";
    }

    TabHTML::printTabDiv("cliqueDetailsTab", \@tabIndex, \@tabNames);

    print "<div id='cliquetab0'>";
    print "<br/><table class='img' border='1'>\n";
    print "<tr class='highlight'>\n";
    print "<th class='subhead' align='center'>";
    print "<font color='darkblue'>\n";
    print "Clique Information</font></th>\n";
    print "<td class='img'>" . nbsp(1) . "</td>\n";
    print "</tr>\n";

    require GeneDetail;
    GeneDetail::printAttrRowRaw("Clique ID",        $clique_id);
    GeneDetail::printAttrRowRaw("Clique Type",      $clique_type);
    GeneDetail::printAttrRowRaw("Intra-Clique ANI", $intra_ani);
    GeneDetail::printAttrRowRaw("Intra-Clique AF",  $intra_af);
    GeneDetail::printAttrRowRaw("Total Genomes",    $nGenomes);
    print "</table>\n";
    print "</div>";

    print "<div id='cliquetab1'>";

    my $it = new InnerTable(1, "cliqdetails$$", "cliqdetails", 1);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Select");
    $it->addColSpec("Genome ID",   "asc", "right");
    $it->addColSpec("Genome Name", "asc", "left");
    $it->addColSpec("Species",     "asc", "left");
    $it->addColSpec("Domain",      "asc", "left");

    my $cnt = 0;
    my $url = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=";
    foreach my $taxon_oid (keys %taxon2info) {
        my $info = $taxon2info{$taxon_oid};
        my ($domain, $taxon_name, $species) = split("\t", $info);

        my $row = $sd . "<input type='checkbox' name='taxon_filter_oid' "
	    . " value='$taxon_oid' />\t";
        $row .= $taxon_oid . $sd . $taxon_oid . "\t";
        my $tmp = alink($url . $taxon_oid, $taxon_name);
        $row .= $tmp . $sd . $tmp . "\t";
        $row .= $species . $sd . $species . "\t";
        $row .= $domain . "\t";
        $it->addRow($row);
        $cnt++;

    }

    printMainForm();

    print hiddenVar("clique_id", $clique_id);
    print "<script type='text/javascript' src='$top_base_url/js/checkSelection.js'></script>\n";

    my $name = "_section_ANI_doQuickPairwise";
    if ($cnt > 10) {
        TaxonSearchUtil::printButtonFooter("cliqdetails");
        print nbsp(1);
        print submit(
            -name    => $name,
            -value   => "Pairwise ANI",
            -class   => "medbutton",
            -onClick => "return validateItemSelection(2, '', \"cliqdetails\", \"taxon_filter_oid\");"
       );
    }
    $it->printOuterTable(1);
    TaxonSearchUtil::printButtonFooter("cliqdetails");

    if ($cnt > 1) {
        print nbsp(1);
        print submit(
            -name    => $name,
            -value   => "Pairwise ANI",
            -class   => "medbutton",
            -onClick => "return validateItemSelection(2, '', \"cliqdetails\", \"taxon_filter_oid\");"
       );
    }

    print end_form();
    print "</div>";    # end cliquetab1

    print "<div id='cliquetab2'>";

    # inter-ani
    print "<p><u>Note</u>: Similar cliques have gANI >= 90 with the current clique.</p>";
    my $sql = qq{
        select aic.clique_id2, ac.clique_type, aic.avg_ani, aic.avg_af
        from ANI_INTER_CLIQUE aic, ANI_CLIQUE ac
        where aic.clique_id1 = ?
        and aic.clique_id2 = ac.clique_id
        and aic.avg_ani >= 90
        and aic.avg_af >= 0.1
    };
    my $cur = execSql($dbh, $sql, $verbose, $clique_id);

    my $it = new InnerTable(1, "clique_ani$$", 'clique_ani', 0);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Clique ID", "asc", "right");
    $it->addColSpec("Clique Type", "asc", "center");
    $it->addColSpec("Average Identity<br/>with Clique $clique_id", "asc", "right");
    $it->addColSpec("Average Gene Content Similarity<br/>with Clique $clique_id", "asc", "right");
    $it->addColSpec("Contributing Species", "asc", "left", '', '', '', (200));

    my $clique2GenusSpecies_href = getAllClique2GenusSpecies($dbh);
    my $clique_url = "$section_cgi&page=cliqueDetails&clique_id=";
    my $cnt2 = 0;

    for ( ;; ) {
        my ($clique_id2, $clique_type, $inter_ani, $inter_af) = $cur->fetchrow();
        last if (!$clique_id2);

        my $link = alink($clique_url . $clique_id2, $clique_id2);
        my $row = $clique_id2 . $sd . $link . "\t";
        $row .= $clique_type . "\t";
        $row .= $inter_ani . "\t";

        $inter_af = sprintf("%.3f", $inter_af) if $inter_af ne "";
        $row .= $inter_af . "\t";

        my $species_href = $clique2GenusSpecies_href->{$clique_id2};
        my @tmp = sort keys %$species_href;
        my $species = join(", ", @tmp);
        $row .= $species . "\t";

        $it->addRow($row);
        $cnt2++;
    }
    if ($cnt2 > 0) {
        $it->printOuterTable(1);
    } else {
        print "<p>No similar cliques found.</p>";
    }

    print "</div>";    # end cliquetab2

    if ($clique_type eq "clique-group" && $nGenomes < 32) {
        # draw the group for this clique:
        print "<div id='cliquetab3'>";
        my %clique_groups;
        $clique_groups{$clique_id} = $nGenomes;
        drawCliqueGroups(\%clique_groups, 1);
        print "</div>";    # end cliquetab3
    }

    TabHTML::printTabDivEnd();
    printStatusLine("$cnt members and $cnt2 inter-cliques with gANI > 90 loaded", 2);
}

sub printGenomesForClique {
    my $cliqueId = param("clique_id");
    my $dbh = dbLogin();

    my $sql = qq{
        select t.taxon_oid
        from taxon t, ANI_CLIQUE_MEMBERS acm
        where t.obsolete_flag = 'No'
        and t.taxon_oid = acm.MEMBERS
        and acm.CLIQUE_ID = ?
    };
    my @bind = ($cliqueId);

    my $cliqueUrl = "$section_cgi&page=genomesForClique&clique_id=$cliqueId";
    my $cliqueLink = alink($cliqueUrl, $cliqueId);
    my $note = "<p><u>Clique ID</u>: $cliqueLink</p>";
    GenomeList::printGenomesViaSql($dbh, $sql, "Clique Genome List", \@bind, "", $note);
}

#
# from taxon detail page Contributing Species count link
#
sub printSpeciesForGenomeForClique {
    my $cliqueId  = param("clique_id");
    my $taxon_oid = param("taxon_oid");

    my $dbh = dbLogin();

    my $sql = qq{
        select t.taxon_oid, t.genus, t.species, t.ani_species
        from ani_clique_members acm, taxon t
        where acm.members = t.taxon_oid
        and t.OBSOLETE_FLAG = 'No'
        and clique_id in
            (select clique_id 
              from ani_clique_members 
              where members = ?)
    };

    my %distinctSpecies;
    my $cur = execSql($dbh, $sql, $verbose, $taxon_oid);
    for ( ;; ) {
        my ($taxon_oid, $genus, $species, $ani_species) = $cur->fetchrow();
        last if (!$taxon_oid);

        my $key = "$ani_species";
        $distinctSpecies{$key} = 1;
    }

    my @genusKeys = keys %distinctSpecies;
    my $genusStr = OracleUtil::getFuncIdsInClause($dbh, @genusKeys);

    my $sql = qq{
        select t.taxon_oid
        from taxon t, ANI_CLIQUE_MEMBERS acm
        where t.obsolete_flag = 'No'
        and t.taxon_oid = acm.MEMBERS
        and acm.CLIQUE_ID = ?
        and t.ani_species in ($genusStr)
    };

    my @taxonIds;
    my $cur = execSql($dbh, $sql, $verbose, $cliqueId);
    for ( ;; ) {
        my ($id) = $cur->fetchrow();
        last if (!$id);
	push(@taxonIds, $id);
    }

    my $taxon_name = WebUtil::taxonOid2Name($dbh, $taxon_oid, 1);
    my $taxon_url  = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=$taxon_oid";
    my $taxon_link = alink($taxon_url, $taxon_name);
    my $cliqueUrl  = "$section_cgi&page=cliqueDetails&clique_id=$cliqueId";
    my $cliqueLink = alink($cliqueUrl, $cliqueId);
    my $note = "<p><u>Genome</u>: $taxon_link"
	     . "<br/><u>Clique ID</u>: $cliqueLink</p>";
    GenomeList::printGenomesViaList(\@taxonIds, "", "Contributing Species", "", "", $note);
}

sub getGenusSpecies4Taxon {
    my ($dbh, $taxon_oid) = @_;
    my $sql = qq{
        select domain, phylum, genus, species, ani_species
        from taxon where taxon_oid = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $taxon_oid);
    my ($domain, $phylum, $genus, $species, $ani_species) = $cur->fetchrow();
    return ($domain, $phylum, $genus, $species, $ani_species);
}

#
# from taxon detail page Genomes of this Species link
#
sub printGenomesInSpecies {
    my $taxon_oid = param('taxon_oid');

    printStatusLine("Loading...", 1);

    my $dbh = dbLogin();
    my ($domain, $phylum, $genus, $species, $ani_species)
	= getGenusSpecies4Taxon($dbh, $taxon_oid);

    my $key = "$ani_species";

    print "<h1>Genomes of Species</h1>";
    print "<p><u>Species</u>: $key </p>";

    my $sql = qq{
        select t.taxon_oid, t.taxon_display_name, acm.CLIQUE_ID
        from taxon t, ANI_CLIQUE_MEMBERS acm
        where t.obsolete_flag = 'No'
        and t.taxon_oid = acm.MEMBERS
        and t.domain = ?
        and t.ani_species = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $domain, $ani_species);

    my $it = new InnerTable(1, "ani$$", "ani", 1);
    my $sd = $it->getSdDelim();
    $it->addColSpec("Select");
    $it->addColSpec("Genome ID",          "asc", "right");
    $it->addColSpec("Genome Name",        "asc", "left");
    $it->addColSpec("Present in Cliques", "asc", "right");

    my $url = "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=";
    my $cnt = 0;
    for ( ;; ) {
        my ($taxon_oid, $taxon_display_name, $clq)
	    = $cur->fetchrow();
        last if !$taxon_oid;

	my $row = $sd . "<input type='checkbox' name='taxon_filter_oid' "
	    . " value='$taxon_oid' />\t";
	$row .= $taxon_oid . $sd . $taxon_oid . "\t";
	my $tmp = alink($url . $taxon_oid, $taxon_display_name);
	$row .= $tmp . $sd . $tmp . "\t";
	$row .= $clq . $sd . $clq . "\t";
	$it->addRow($row);
	$cnt++;
    }

    printMainForm();
    TaxonSearchUtil::printButtonFooter("ani") if $cnt > 10;
    $it->printOuterTable(1);
    TaxonSearchUtil::printButtonFooter("ani");
    print end_form();

    printStatusLine("$cnt loaded", 2);
}

sub getGenomesInSpeciesCnt {
    my ($dbh, $taxon_oid) = @_;

    my ($domain, $phylum, $genus, $species, $ani_species)
	= getGenusSpecies4Taxon($dbh, $taxon_oid);

    my $sql = qq{
        select count(distinct t.taxon_oid)
        from taxon t, ani_clique_members acm
        where t.obsolete_flag = 'No'
        and t.taxon_oid = acm.members
        and t.domain = ?
        and t.ani_species = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $domain, $ani_species);
    my ($cnt) = $cur->fetchrow();
    $cur->finish();
    return $cnt;
}

sub getAllClique2GenusSpecies {
    my ($dbh, $cliques) = @_;

    my $cliqClause = "";
    if ($cliques) {
	my $clique_str = join(",", @$cliques);
	$cliqClause = "and acm.CLIQUE_ID in ($clique_str)";
    }

    my $sql = qq{
        select acm.clique_id, t.taxon_oid, t.phylum,
               t.genus, t.species, t.ani_species
        from ani_clique_members acm, taxon t
        where acm.members = t.taxon_oid
        and t.OBSOLETE_FLAG = 'No'
        $cliqClause
    };
    my $cur = execSql($dbh, $sql, $verbose);
    my %clique2GenusSpecies;
    for ( ;; ) {
        my ($clique_id, $taxon_oid, $phylum, $genus,
	    $species, $ani_species) = $cur->fetchrow();
        last if (!$taxon_oid);

        my $key = "$ani_species";

        if (exists $clique2GenusSpecies{$clique_id}) {
            my $href = $clique2GenusSpecies{$clique_id};
            $href->{$key} = 1;
        } else {
            my %h = ($key => 1);
            $clique2GenusSpecies{$clique_id} = \%h;
        }
    }

    return \%clique2GenusSpecies;
}

sub getInfoForGenome {
    my ($dbh, $taxon_oid) = @_;

    # first get the clique ids (and type) for the genome:
    my $sql = qq{
        select acm.CLIQUE_ID, ac.clique_type
        from ani_clique ac, ani_clique_members acm, taxon t
        where acm.members = t.taxon_oid
        and ac.CLIQUE_ID = acm.CLIQUE_ID
        and t.OBSOLETE_FLAG = 'No'
        and t.taxon_oid = ?
    };
    my $cur = execSql($dbh, $sql, $verbose, $taxon_oid);

    my %cliqueId2Type;
    my @cliques;
    for ( ;; ) {
	my ($clique_id, $clique_type, $phylum) = $cur->fetchrow();
        last if (!$clique_id);

	push @cliques, $clique_id;
	$cliqueId2Type{$clique_id} = $clique_type;
    }
    my $total = scalar keys %cliqueId2Type;
    return 0 if !$total;

    my $clique_str = join(",", @cliques);
    my $sql = qq{
        select distinct acm.CLIQUE_ID, count(distinct tx.taxon_oid)
        from taxon tx, ANI_CLIQUE_MEMBERS acm
        where tx.obsolete_flag = 'No'
        and tx.taxon_oid = acm.MEMBERS
        and acm.CLIQUE_ID in ($clique_str)
        group by acm.CLIQUE_ID
    };
    my $cur = execSql($dbh, $sql, $verbose);

    my %cliqueId2TaxonCnt;
    for ( ;; ) {
        my ($clique_id, $genome_cnt) = $cur->fetchrow();
        last if (!$clique_id);
	$cliqueId2TaxonCnt{ $clique_id } = $genome_cnt;
    }

    my $clique2GenusSpecies_href = getAllClique2GenusSpecies($dbh, \@cliques);
    return ($total, \%cliqueId2TaxonCnt, \%cliqueId2Type, $clique2GenusSpecies_href);
}

sub getMaxPairwise {
    return $max_pairwise;
}

1;
