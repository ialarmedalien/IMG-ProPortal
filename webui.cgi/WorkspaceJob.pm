###########################################################################
# WorkspaceJob.pm
###########################################################################
package WorkspaceJob;


use strict;
use Archive::Zip;
use CGI qw( :standard);
use Data::Dumper;
use DBI;
use POSIX qw(ceil floor);
use File::Path;
use File::Copy;
use ChartUtil;
use InnerTable;
use WebConfig;
use WebUtil;
use GenomeListFilter;
use MetaUtil;
use HashUtil;
use BerkeleyDB;
use MetaGeneTable;
use TabHTML;
use Workspace;
use WorkspaceUtil;
use PhyloTreeMgr;

$| = 1;

my $section               = "WorkspaceJob";
my $env                   = getEnv();
my $main_cgi              = $env->{main_cgi};
my $section_cgi           = "$main_cgi?section=$section";
my $verbose               = $env->{verbose};
my $base_dir              = $env->{base_dir};
my $base_url              = $env->{base_url};
my $user_restricted_site  = $env->{user_restricted_site};
my $include_metagenomes   = $env->{include_metagenomes};
my $img_internal          = $env->{img_internal};
my $img_er                = $env->{img_er};
my $img_ken               = $env->{img_ken};
my $tmp_dir               = $env->{tmp_dir};
my $tmp_url               = $env->{tmp_url};
my $workspace_dir         = $env->{workspace_dir};
my $workspace_sandbox_dir = $env->{workspace_sandbox_dir};
my $public_nologin_site   = $env->{public_nologin_site};

my $cog_base_url       = $env->{cog_base_url};
my $pfam_base_url      = $env->{pfam_base_url};
my $tigrfam_base_url   = $env->{tigrfam_base_url};
my $enzyme_base_url    = $env->{enzyme_base_url};
my $kegg_orthology_url = $env->{kegg_orthology_url};

my $mer_data_dir      = $env->{mer_data_dir};
my $taxon_lin_fna_dir = $env->{taxon_lin_fna_dir};
my $cgi_tmp_dir       = $env->{cgi_tmp_dir};

my $essential_gene = $env->{essential_gene};
my $top_base_url = $env->{top_base_url};
my $preferences_url    = "$main_cgi?section=MyIMG&form=preferences";
my $maxGeneListResults = 1000;
if ( getSessionParam("maxGeneListResults") ne "" ) {
    $maxGeneListResults = getSessionParam("maxGeneListResults");
}

my $enable_workspace = $env->{enable_workspace};
my $in_file          = $env->{in_file};

my $merfs_timeout_mins = $env->{merfs_timeout_mins};
if ( !$merfs_timeout_mins ) {
    $merfs_timeout_mins = 60;
}

# user's sub folder names
my $GENOME_FOLDER = "genome";
my $SCAF_FOLDER   = "scaffold";
my $GENE_FOLDER   = "gene";
my $FUNC_FOLDER   = "function";
my $RULE_FOLDER   = "rule";
my $JOB_FOLDER    = "job";

my $filename_size      = 25;
my $filename_len       = 60;
my $max_profile_select = 50;
my $maxProfileOccurIds = 100;

my $nvl          = getNvl();
my $unknown      = "Unknown";
my $unclassified = 'unclassified';

my $ownerFilesetDelim = "|";
my $ownerFilesetDelim_message = "::::";

sub getPageTitle {
    return 'Workspace';
}

sub getAppHeaderData {
    my ($self) = @_;

    my @a = ();
    my $header = param("header");
    if ( WebUtil::paramMatch("wpload") ) {              ##use 'wpload' since param 'uploadFile' interferes 'load'
        # no header
    } elsif ( $header eq "" && WebUtil::paramMatch("noHeader") eq "" ) {
        @a = ("AnaCart", '', '', '', '', 'IMGWorkspaceUserGuide.pdf' );
    }
    return @a;
}

sub dispatch {
    my ( $self, $numTaxon ) = @_;
    return if ( !$enable_workspace );
    return if ( !$user_restricted_site );

    my $page = param("page");

    my $sid = getContactOid();
    return if ( $sid == 0 ||  $sid < 1 || $sid eq '901');

    Workspace::initialize();
    
    if ( !$page && paramMatch("wpload") ) {
        $page = "load";
    }

    #    elsif (!$page && paramMatch("delete")) {
    #        $page = "delete";
    #    }

    if ( $page eq "view" ) {
        Workspace::viewFile();
    } elsif ( $page eq "delete" ) {
        Workspace::deleteFile();
    } elsif ( $page eq "load" ) {
        Workspace::readFile();
    } elsif ( $page eq "showJobDetail"
        || paramMatch("showJobDetail") )
    {
        showJobDetail();
    } elsif ( $page eq "showJobResultList"
        || paramMatch("showJobResultList") )
    {
        showJobResultList();
    } elsif ( $page eq "confirmDelete"
        || paramMatch("confirmDelete") )
    {
        printConfirmDelete();
    } elsif ( $page eq "deleteResult"
        || paramMatch("deleteResult") )
    {
        deleteResult();
    } elsif ( $page eq "downloadResult"
        || paramMatch("downloadResult") )
    {
        downloadResult();
    } elsif ( $page eq "saveSelectedJobFunctions"
        || paramMatch("saveSelectedJobFunctions") )
    {
        saveSelectedJobFunctions();
    } elsif ( $page eq "saveSelectedJobFuncGenes"
        || paramMatch("saveSelectedJobFuncGenes") )
    {
        saveSelectedJobFuncGenes();
    } else {
        printJobMainForm();
    }
}

############################################################################
# printJobMainForm
############################################################################
sub printJobMainForm {
    my ($text) = @_;

    my $folder = $JOB_FOLDER;

    my $sid = getContactOid();
    Workspace::inspectWorkspaceUsage( $sid, 1 );

    #my $super_user_flag = getSuperUser();
    #if ( $super_user_flag ne 'Yes' ) {
    #    return;
    #}
    #my $jgi_user = Workspace::getIsJgiUser($sid);

    opendir( DIR, "$workspace_dir/$sid/$folder" )
      or WebUtil::webDie("failed to open folder list");
    my @files = readdir(DIR);
    closedir(DIR);

    print "<h1>Computation Jobs</h1>";

    print qq{
        <script type="text/javascript" src="$top_base_url/js/Workspace.js" >
        </script>
    };

    print $text;

    printMainForm();

    my $job_dir = "$workspace_dir/$sid/job";
    if ( !( -e $job_dir ) ) {
        return;
    }

    my $it = new InnerTable( 1, "cateCog$$", "cateCog", 1 );
    $it->addColSpec("Select");
    $it->addColSpec( "Name",       "char asc", "left" );
    $it->addColSpec( "Type",       "char asc", "left" );
    $it->addColSpec( "Start Time", "char asc", "left" );
    $it->addColSpec( "Parameters", "char asc", "left" );
    $it->addColSpec( "File Size",  "char asc", "left" );
    $it->addColSpec( "End Time",   "char asc", "left" );
    $it->addColSpec( "Status",     "char asc", "left" );
    my $sd = $it->getSdDelim();

    opendir( DIR, $job_dir )
      or WebUtil::webDie("failed to read files");
    my @files = readdir(DIR);
    closedir(DIR);

    my $count = 0;
    foreach my $x ( sort @files ) {
        # remove files "."  ".." "~$"
        next if ( $x eq "." || $x eq ".." || $x =~ /~$/ );

        my $job_file_dir = "$job_dir/$x";
        my $fname = "$job_file_dir/info.txt";

        my $r = $sd . "<input type='checkbox' name='job_id' value='$x' " . "  /> \t";
        $r .= $x . $sd . $x . "\t";

        my $p2      = "";
        my $st_time = "";
        if ( -e $fname ) {
            my $fh = newReadFileHandle($fname);
            while ( my $line = $fh->getline() ) {
                chomp $line;
                if ( $line =~ /^--/ ) {
                    $p2 .= $line . " ";
                    next;
                }
                $r .= $line . $sd . $line . "\t"; # type col and start time col
            }
            close $fh;

            $r .= $p2 . $sd . $p2 . "\t"; # parameters
        } else {
            $it->addRow($r);
            next;
        }

        my $size = Workspace::getDirSize($job_file_dir);
        my $display_size = WorkspaceUtil::getDisplaySize($size);
        $r .= $display_size . $sd . $display_size . "\t";

        # error?
        $fname = "$job_file_dir/error.txt";
        if ( -e $fname ) {
            my $fh         = newReadFileHandle($fname);
            my $error_code = $fh->getline();
            chomp $error_code;
            my $line = $fh->getline();
            chomp $line;
            $r .= $line . $sd . $line . "\t"; # end time
            $r .= "error ($error_code)" . $sd . "error ($error_code)" . "\t";
            close $fh;
        } else {
            $fname = "$job_file_dir/done.txt";
            if ( -e $fname ) {
                my $fh   = newReadFileHandle($fname);
                my $line = $fh->getline();
                chomp $line;
                $r .= $line . $sd . $line . "\t";
                my $url = $section_cgi . "&page=showJobDetail&job_name=$x";
                $r .= "completed" . $sd . alink( $url, "completed" ) . "\t";
                close $fh;
            } else {
                $fname = "$job_file_dir/profile.txt";
                if ( -e $fname ) {
                    my $url = $section_cgi . "&page=showJobDetail&job_name=$x";
                    $r .= "-" . $sd . "-" . "\t";
                    $r .= "processing" . $sd . alink( $url, "processing" ) . "\t";
                } else {
                    $r .= "-" . $sd . "-" . "\t";
                    $r .= "waiting" . $sd . "waiting" . "\t";
                }
            }
        }
        $it->addRow($r);
        $count++;
    }

    $it->printOuterTable(1);

    print "<p>\n";
    print submit(
        -name  => "_section_WorkspaceJob_confirmDelete",
        -value => "Delete",
        -class => "smdefbutton"
    );
    print nbsp(1);
    print submit(
        -name  => "_section_WorkspaceJob_downloadResult",
        -value => "Download",
        -class => "smdefbutton"
    );

    print end_form();
}

###############################################################################
# showJobDetail
###############################################################################
sub showJobDetail {

    printMainForm();

    my $job_name = param('job_name');
    WebUtil::checkFileName($job_name);
    # this also untaints the name
    $job_name = WebUtil::validFileName($job_name);
    print "<h1>Computation Job: $job_name</h1>\n";
    print hiddenVar( 'job_name', $job_name );

    my $sid = getContactOid();
    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";
    my $res = newReadFileHandle("$job_file_dir/info.txt");

    my $lineno = 0;
    my $job_type;
    my @set_names;
    my $datatype;
    my $dtype;
    my $functype;
    my $share_func_set_name;
    my $use_blast_db = '';
    my $evalue = '';
    my $blast_program = '';
    while ( my $line = $res->getline() ) {
        chomp $line;
        if ( $lineno == 0 ) {
            $job_type = $line;
            print "<p>Job Type: $job_type<br/>";
        } else {
            my ( $tag, $val ) = split( / /, $line, 2 );
            if ( $tag eq "--genome" ) {
                @set_names = split( /\,/, $val );
            } elsif ( $tag eq "--gene" ) {
                @set_names = split( /\,/, $val );
            } elsif ( $tag eq "--scaffold" ) {
                @set_names = split( /\,/, $val );
            } elsif ( $tag eq "--function" ) {
                if (   $job_type eq 'Genome Function Profile' ) {
                    $share_func_set_name = $val;
                }
                else {
                    @set_names = split( /\,/, $val );                
                }           
            } elsif ( $tag eq "--functype" ) {
                $functype = $val;
            } elsif ( $tag eq "--datatype" ) {
                $datatype = $val;
            } elsif ( $tag eq "--dtype" ) {
                $dtype = $val;
            } elsif($tag eq "--use_blast_db" ) {
                $use_blast_db = $val;
            } elsif($tag eq '--evalue') {
                $evalue = $val;
            } elsif($tag eq '--blast_program') {
                $blast_program = $val;
            }
            print "$line<br/>\n";
        }
        $lineno++;
    }
    close $res;

    print hiddenVar( "job_type", $job_type );
    print hiddenVar( "datatype", $datatype );
    print hiddenVar( "dtype", $dtype );

    for my $set_name (@set_names) {
        if ( $job_type =~ /^Genome/ ) {
            print hiddenVar( 'genome_set', $set_name );
        } elsif ( $job_type =~ /^Gene/ ) {
            print hiddenVar( 'gene_set', $set_name );
        } elsif ( $job_type =~ /^Scaffold/ ) {
            print hiddenVar( 'scaf_set', $set_name );
        } elsif ( $job_type =~ /^Function/ ) {
            print hiddenVar( 'func_set', $set_name );
        }
    }

    # status
    my $done_fname = "$job_file_dir/done.txt";
    if ( -e $done_fname ) {
        print "<p><font color='green'>Status: Completed</font><br/>\n";
    } else {
        print "<p><font color='orange'>Status: Processing (Note: Only partial result is displayed.)</font><br/>\n";
    }

    if ( $job_type eq 'Genome Function Profile' )
    {
        showGenomeFuncProfileJobDetail( $sid, $job_name, $job_type, $functype, $share_func_set_name, \@set_names, $datatype );
    } elsif ( $job_type eq 'Gene Function Profile'
        || $job_type eq 'Scaffold Function Profile' )
    {
        showFuncProfileJobDetail( $sid, $job_name, $job_type, \@set_names, $datatype );
    } elsif ( $job_type eq 'Scaffold Histogram' ) {
        showHistogramJobDetail( $sid, $job_name, \@set_names, $datatype, $dtype );
    } elsif ( $job_type eq 'Scaffold Kmer' ) {
        showKmerJobDetail( $sid, $job_name, \@set_names, $datatype, $dtype );
    } elsif ( $job_type eq 'Scaffold Phylo Distribution' ) {
        showPhyloDistJobDetail( $sid, $job_name, \@set_names, $datatype );
    } elsif ( $job_type eq 'Genome Pairwise ANI' ) {
        showPairwiseANIJobDetail( $sid, $job_name, \@set_names, $datatype );
    } elsif ( $job_type eq 'Genome Blast' ) {
        showGenomeBlastDetail( $sid, $job_name, \@set_names, $datatype, $dtype );
    } elsif ( $job_type eq 'Function Scaffold Search' ) {
        showFunctionScaffoldSearchDetail( $sid, $job_name, \@set_names, $datatype );
    } elsif ( $job_type eq 'Genome Save Function Gene' 
        || $job_type eq 'Gene Save Function Gene' 
        || $job_type eq 'Scaffold Save Function Gene' ) {
        showSaveFuncGeneDetail( $sid, $job_name, \@set_names, $datatype );
    } elsif ($job_type eq 'Sequence blast') {
        require WorkspaceBlast;
        WorkspaceBlast::printResults($job_name, $use_blast_db, $evalue, $blast_program);
    }

    print end_form();
}

###############################################################################
# showGenomeFuncProfileJobDetail
###############################################################################
sub showGenomeFuncProfileJobDetail {
    my ( $sid, $job_name, $job_type, $functype, $share_func_set_name, $set_names_ref, $data_type ) = @_;

    my $dbh = dbLogin();

    my $hide_zero = 1;
    my $setTxtExist = 0;
    my %ownerSetName2shareSetName;
    my %set2taxons_h;
    my %dbTaxons;
    my %fileTaxons;

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";
    
    if ( -e "$job_file_dir/set.txt" ) {
        $setTxtExist = 1;
        my $res0 = newReadFileHandle("$job_file_dir/set.txt");
        while ( my $line = $res0->getline() ) {
            chomp $line;
            if ( $line =~ /\-\-set/ ) {
                my ( $tag, $set_name, @oids ) = split( /\t/, $line );
                if ( $tag && $tag eq '--set' ) {
                    my ( $owner, $x ) = WorkspaceUtil::splitOwnerFileset( $sid, $set_name, $ownerFilesetDelim_message );
                    my $fileset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
                    my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
                    $ownerSetName2shareSetName{$fileset_name} = $share_set_name;
                    $set2taxons_h{$fileset_name} = \@oids; 
                }
            }
            elsif ( $line =~ /\-\-db_taxons/ ) {
                my ( $tag, @oids ) = split( /\t/, $line );
                if ( $tag && $tag eq '--db_taxons' ) {
                    WebUtil::arrayRef2HashRef( \@oids, \%dbTaxons, 1 );
                }
            }
            elsif ( $line =~ /\-\-file_taxons/ ) {
                my ( $tag, @oids ) = split( /\t/, $line );
                if ( $tag && $tag eq '--file_taxons' ) {
                    WebUtil::arrayRef2HashRef( \@oids, \%fileTaxons, 1 );
                }
            }
        }
        close $res0;
        #print "showGenomeFuncProfileJobDetail() set2taxons_h: <br/>\n";
        #print Dumper(\%set2taxons_h);
        #print "<br/>\n";
    }

    my %funcId2taxonOrset2cnt_h;
    my $total_cnt = 0;

    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        my ( $setOrtaxon_name, $func_id, $cnt ) = split( /\t/, $line );
        my ( $owner, $x ) = WorkspaceUtil::splitOwnerFileset( $sid, $setOrtaxon_name, $ownerFilesetDelim_message );
        my $fileset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
        if ( !$setTxtExist ) {
            my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
            $ownerSetName2shareSetName{$fileset_name} = $share_set_name;            
        }

        if ( $funcId2taxonOrset2cnt_h{$func_id} ) {
            my $h2_ref = $funcId2taxonOrset2cnt_h{$func_id};
            $h2_ref->{$fileset_name} = $cnt;
        } else {
            my %h2;
            $h2{$fileset_name} = $cnt;
            $funcId2taxonOrset2cnt_h{$func_id} = \%h2;
        }
        $total_cnt += $cnt;
    }
    close $res;

    my $folder = $GENOME_FOLDER;
    my $isSet = 1;

    my $dbh = dbLogin();
    my @func_ids = keys %funcId2taxonOrset2cnt_h;
    my %func_names = QueryUtil::fetchFuncIdAndName( $dbh, \@func_ids );
    my @all_files = keys %ownerSetName2shareSetName;
    my $cntLinkBase = $section_cgi 
        . "&page=showJobResultList&job_name=$job_name&job_type=$job_type";

    require WorkspaceGenomeSet;
    WorkspaceGenomeSet::printGenomeFuncProfileTable($dbh, $sid, $isSet, $folder, 
        $functype, $share_func_set_name, \@func_ids, \%func_names,
        \@all_files, '', '', $data_type, \%ownerSetName2shareSetName,
        \%set2taxons_h, \%dbTaxons, \%fileTaxons, \%funcId2taxonOrset2cnt_h, 
        $total_cnt, $cntLinkBase);

}


###############################################################################
# showFuncProfileJobDetail
###############################################################################
sub showFuncProfileJobDetail {
    my ( $sid, $job_name, $job_type, $set_names_ref, $datatype ) = @_;

    my $dbh = dbLogin();

    my $hide_zero = 1;
    my %func_name_h;
    my %h;
    my %shareSetName2ownerSetName;

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        my ( $set_name, $func_id, $cnt ) = split( /\t/, $line );
        my ( $owner, $x ) = WorkspaceUtil::splitOwnerFileset( $sid, $set_name, $ownerFilesetDelim_message );
        my $fileset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
        my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
        $shareSetName2ownerSetName{$share_set_name} = $fileset_name;

        if ( $h{$func_id} ) {
            my $h2_ref = $h{$func_id};
            $h2_ref->{$share_set_name} = $cnt;
        } else {
            my %h2;
            $h2{$share_set_name} = $cnt;
            $h{$func_id}   = \%h2;
        }
    }
    close $res;

    my $row_cnt = 0;
    my $it = new InnerTable( 1, "profile$$", "profile", 1 );
    $it->addColSpec("Select");
    $it->addColSpec( "Function ID",   "char asc", "left" );
    $it->addColSpec( "Function Name", "char asc", "left" );
    for my $set_name (@$set_names_ref) {
        $it->addColSpec( $set_name, "number asc", "right" );
    }
    my $sd = $it->getSdDelim();

    for my $func_id ( keys %h ) {
        my $r = $sd . "<input type='checkbox' name='func_id' value='$func_id' " . "  /> \t";
        $r .= $func_id . $sd . $func_id . "\t";

        my $func_name = "";
        if ( $func_name_h{$func_id} ) {
            $func_name = $func_name_h{$func_id};
        } else {
            my $func_type = "";

            if ( $func_id =~ /^COG/ ) {
                $func_type = "COG";
            } elsif ( $func_id =~ /^pfam/ ) {
                $func_type = "pfam";
            } elsif ( $func_id =~ /^TIGR/ ) {
                $func_type = "TIGRfam";
            } elsif ( $func_id =~ /^EC/ ) {
                $func_type = "Enzymes";
            } elsif ( $func_id =~ /^KO/ ) {
                $func_type = "KO";
            }

            if ($func_type) {
                my %h2 = QueryUtil::getFuncTypeNames($dbh, $func_type);
                for my $k2 ( keys %h2 ) {
                    $func_name_h{$k2} = $h2{$k2};
                }
            }

            if ( $func_name_h{$func_id} ) {
                $func_name = $func_name_h{$func_id};
            } else {
                $func_name = Workspace::getMetaFuncName($func_id);
                $func_name_h{$func_id} = $func_name;
            }
        }
        $r .= $func_name . $sd . $func_name . "\t";

        my $total = 0;
        for my $set_name (@$set_names_ref) {
            my $combo_id = "$func_id,$set_name";

            my $h2  = $h{$func_id};
            my $cnt = '-';

            if ($h2) {
                if ( defined( $h2->{$set_name} ) ) {
                    $cnt = $h2->{$set_name};

                    if ( !$cnt ) {
                        $cnt = 0;
                    }
                }
            }

            if ( $cnt eq "-" ) {
                $r .= "-" . $sd . "-" . "\t";
            } elsif ($cnt) {
                my $url = $section_cgi . "&page=showJobResultList&job_name=$job_name" 
                  . "&job_type=$job_type&func_id=$func_id";
                my $fileset_name = $shareSetName2ownerSetName{$set_name};
                $url .= "&input_file=$fileset_name";
#                if ( $job_type =~ /Genome/ ) {
#                    $url .= "&genome_set=$fileset_name";
#                } elsif ( $job_type =~ /Gene/ ) {
#                    $url .= "&gene_set=$fileset_name";
#                } else {
#                    $url .= "&scaffold_set=$fileset_name";
#                }
                $url .= "&data_type=$datatype" if ($datatype);
                $r .= $cnt . $sd . alink( $url, $cnt ) . "\t";
                $total += $cnt;
            } else {
                $r .= "0" . $sd . "0" . "\t";
            }
        }

        if ( !$hide_zero || $total ) {
            $it->addRow($r);
            $row_cnt++;
        }
    }

    if ($row_cnt) {
        $it->printOuterTable(1);
        WebUtil::printButtonFooter();

        printSaveSelectedFuncGeneToWorkspace( "_section_WorkspaceJob_saveSelectedJobFunctions",
            "_section_WorkspaceJob_saveSelectedJobFuncGenes" );
    } else {
        print "<p><b>No Result.</b>\n";
    }

}

###############################################################################
# showHistogramJobDetail
###############################################################################
sub showHistogramJobDetail {
    my ( $sid, $job_name, $set_names_ref, $datatype, $h_type ) = @_;

    Workspace::printJS();
        
    my $title;
    if ( $h_type eq 'seq_length' ) {
        $title = "Sequence Length";
    }
    elsif ( $h_type eq 'gc_percent' ) {
        $title = "GC Content";
    }
    elsif ( $h_type eq 'read_depth' ) {
        $title = "Read Depth";
    }
    else {
        $h_type = 'gene_count';
        $title = "Gene Count";
    }

    #print "<h1>Scaffold Set $title Histogram</h1>\n";
    #print "<p>Histogram is based on <u>all</u> genes in each scaffold set.\n";
    print hiddenVar( "isSet", 1 );

    my $dbh = dbLogin();

    my %scafset2scafs;
    my %scafset2shareSetName;
    my %valid_scafs_h;
    my %scaf2val;
    my @recs;
    my $min;
    my $max;
        
    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );

        if ( $line =~ /\-\-scafset/ ) {
            my ( $tag, $scafset_name, @scaffolds ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scafset' ) {
                my ( $owner, $x ) = WorkspaceUtil::splitAndValidateOwnerFileset( $sid, $scafset_name, $ownerFilesetDelim_message, $SCAF_FOLDER );
                $scafset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
                $scafset2scafs{$scafset_name} = \@scaffolds; 
                my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
                $scafset2shareSetName{$scafset_name} = $share_set_name;
            }
        }
        elsif ( $line =~ /\-\-validscafs/ ) {
            my ( $tag, $scaf ) = split( /\t/, $line );
            if ( $tag && $tag eq '--validscafs' ) {
                $valid_scafs_h{$scaf} = 1; 
            }
        }
        elsif ( $line =~ /\-\-scaf2val/ ) {
            my ( $tag, $scaf, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scaf2val' ) {
                $scaf2val{$scaf} = $val; 
            }
        }
        elsif ( $line =~ /\-\-recs/ ) {
            my ( $tag, @recs0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--recs' ) {
                @recs = @recs0;
            }
        }
        elsif ( $line =~ /\-\-min/ ) {
            my ( $tag, $min0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--min' ) {
                $min = $min0;
            }
        }
        elsif ( $line =~ /\-\-max/ ) {
            my ( $tag, $max0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--max' ) {
                $max = $max0;
            }
        }
    }
    close $res;

    if ( scalar(@recs) > 0 ) {
        HistogramUtil::drawScafSetHistogram( $h_type, \@recs, $min, $max, 
            \%valid_scafs_h, \%scaf2val, $datatype, \%scafset2scafs, \%scafset2shareSetName );
    }

}

###############################################################################
# showKmerJobDetail
###############################################################################
sub showKmerJobDetail {
    my ( $sid, $job_name, $set_names_ref, $datatype, $outputPrefix ) = @_;

    Workspace::printJS();
        
    print "<h1>Kmer Frequency Analysis</h1>\n";

    my $scaf_set_names = join( ',', @$set_names_ref );
    print "<p>Scaffold Set(s): $scaf_set_names<br/>\n";

    require Kmer;
    if ( $outputPrefix ) {
        my $text = Kmer::getKmerSettingDisplay( $outputPrefix );
        print "Kmer Settings: $text<br/>\n";
    }
    print "</p>";

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";
    opendir( DIR, $job_file_dir )
      or WebUtil::webDie("failed to read $job_file_dir files");
    my @files = readdir(DIR);
    closedir(DIR);

    for my $x (@files) {
        #print "showKmerJobDetail() x=$x<br/>\n";
        if ( $x =~ /\.html/  ) {
            my $resFrom = newReadFileHandle("$job_file_dir/$x");
            my $resTo = newWriteFileHandle("$tmp_dir/$x");
            while ( my $line = $resFrom->getline() ) {
                $line =~ s/__pngurl__/$tmp_url/g;
                print $resTo $line;
            }
            close $resFrom;
            close $resTo;
            #print "showKmerJobDetail() copied and changed $resFrom to $resTo<br/>\n";
        }
        elsif ( $x =~ /\.kin/ || $x =~ /\.png/ || $x =~ /\.tbl/ ) {
            $x = sanitizeVar($x);
            my $fromFilePath = "$job_file_dir/$x";
            my $toFilePath = "$tmp_dir/$x";
            copy($fromFilePath, $toFilePath) || die ("Cannot copy file '$fromFilePath': $?");
            #print "showKmerJobDetail() copied $fromFilePath to $toFilePath<br/>\n";
        }
    }

    my $dbh = dbLogin();

    my %scafset2scafs;
    my %scafset2shareSetName;
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );

        if ( $line =~ /\-\-scafset/ ) {
            my ( $tag, $scafset_name, @scaffolds ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scafset' ) {
                my ( $owner, $x ) = WorkspaceUtil::splitAndValidateOwnerFileset( $sid, $scafset_name, $ownerFilesetDelim_message, $SCAF_FOLDER );
                $scafset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
                $scafset2scafs{$scafset_name} = \@scaffolds; 
                my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
                $scafset2shareSetName{$scafset_name} = $share_set_name;
            }
        }
    }
    close $res;

    Kmer::printPage($outputPrefix, \%scafset2scafs, \%scafset2shareSetName, 1);
        
}

###############################################################################
# showPhyloDistJobDetail
###############################################################################
sub showPhyloDistJobDetail {
    my ( $sid, $job_name, $set_names_ref, $data_type ) = @_;

    my %scafset2scafs;     
    my %scaffolds_h;
    my %genomeHitStats_h;
    my %stats30_h;
    my %stats60_h;
    my %stats90_h;
    my $totalGeneCount = 0;
    my $totalCopyCount = 0;
    my $remainCount30  = 0;
    my $remainCount60  = 0;
    my $remainCount90  = 0;
    my $remainCopy30   = 0;
    my $remainCopy60   = 0;
    my $remainCopy90   = 0;
    
    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );
        

        if ( $line =~ /\-\-scafset/ ) {
            my ( $tag, $scafset_name, @scaffolds ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scafset' ) {
                $scafset2scafs{$scafset_name} = \@scaffolds; 
            }
        }
        elsif ( $line =~ /\-\-scaffold/ ) {
            my ( $tag, $scaffold, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scaffold' ) {
                $scaffolds_h{$scaffold} = $val; 
            }
        }
        elsif ( $line =~ /\-\-genomeHitStats/ ) {
            #print "showPhyloDistJobDetail() genomeHitStats line=$line<br/>\n";
            my ( $tag, @keyval ) = split( /\t/, $line );
            if ( $tag && $tag eq '--genomeHitStats' ) {
                #print "showPhyloDistJobDetail() genomeHitStats 0 keyval=@keyval<br/>\n";
                my $val = pop @keyval;
                #print "showPhyloDistJobDetail() genomeHitStats 1 keyval=@keyval<br/>\n";
                my $key = join("\t", @keyval);                
                $genomeHitStats_h{$key} = $val; 
            }
        }
        elsif ( $line =~ /\-\-stats30/ ) {
            my ( $tag, @keyval ) = split( /\t/, $line );
            if ( $tag && $tag eq '--stats30' ) {
                my $cnt3 = pop @keyval;
                my $cnt2 = pop @keyval;
                my $cnt1 = pop @keyval;
                my $key = join("\t", @keyval);      
                $stats30_h{$key} = "$cnt1\t$cnt2\t$cnt3";
            }
        }
        elsif ( $line =~ /\-\-stats60/ ) {
            my ( $tag, @keyval ) = split( /\t/, $line );
            if ( $tag && $tag eq '--stats60' ) {
                my $cnt3 = pop @keyval;
                my $cnt2 = pop @keyval;
                my $cnt1 = pop @keyval;
                my $key = join("\t", @keyval);      
                $stats60_h{$key} = "$cnt1\t$cnt2\t$cnt3";
            }
        }
        elsif ( $line =~ /\-\-stats90/ ) {
            my ( $tag, @keyval ) = split( /\t/, $line );
            if ( $tag && $tag eq '--stats90' ) {
                my $cnt3 = pop @keyval;
                my $cnt2 = pop @keyval;
                my $cnt1 = pop @keyval;
                my $key = join("\t", @keyval);      
                $stats90_h{$key} = "$cnt1\t$cnt2\t$cnt3";
            }
        }
        elsif ( $line =~ /TotalGeneCount/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'TotalGeneCount' ) {
                $totalGeneCount = $val;
            }
        }
        elsif ( $line =~ /TotalCopyCount/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'TotalCopyCount' ) {
                $totalCopyCount = $val;
            }
        }
        elsif ( $line =~ /remainCount30/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCount30' ) {
                $remainCount30 = $val;
            }
        }
        elsif ( $line =~ /remainCount60/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCount60' ) {
                $remainCount60 = $val;
            }
        }
        elsif ( $line =~ /remainCount90/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCount90' ) {
                $remainCount90 = $val;
            }
        }
        elsif ( $line =~ /remainCopy30/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCopy30' ) {
                $remainCopy30 = $val;
            }
        }
        elsif ( $line =~ /remainCopy60/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCopy60' ) {
                $remainCopy60 = $val;
            }
        }
        elsif ( $line =~ /remainCopy90/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq 'remainCopy90' ) {
                $remainCopy90 = $val;
            }
        }
    }
    close $res;
    #print "showPhyloDistJobDetail() genomeHitStats:<br/>\n";
    #print Dumper(\%genomeHitStats_h) . "<br/>\n";
    #print "showPhyloDistJobDetail() stats30:<br/>\n";
    #print Dumper(\%stats30_h) . "<br/>\n";

    my %orgCount_h;
    my $res1 = newReadFileHandle("$workspace_dir/$sid/job/$job_name/orgcount.txt");
    while ( my $line = $res1->getline() ) {
        chomp $line;
        next if ( ! $line );

        my ( @keyval ) = split( /\t/, $line );
        my $val = pop @keyval;
        my $key = join("\t", @keyval);                
        $orgCount_h{$key} = $val; 

    }
    close $res1;
    #print "showPhyloDistJobDetail() orgCount:<br/>\n";
    #print Dumper(\%orgCount_h) . "<br/>\n";

    require WorkspaceScafSet;
    WorkspaceScafSet::viewScafPhyloDistWithoutMainForm( 1, 0, $data_type,
        \%scaffolds_h, \%orgCount_h, \%genomeHitStats_h, 
        \%stats30_h, \%stats60_h, \%stats90_h, 
        $totalGeneCount, $totalCopyCount, 
        $remainCount30, $remainCount60, $remainCount90, 
        $remainCopy30, $remainCopy60, $remainCopy90, $job_name );

}

###############################################################################
# showGenomeBlastDetail
###############################################################################
sub showGenomeBlastDetail {
    my ( $sid, $job_name, $set_names_ref, $data_type, $blastProgram ) = @_;

    my %genomeset2genomes;
    my $evalue;
    my $isDnaSearch;
    my $nRecs;
    my $blastFile;

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );
        #print "showGenomeBlastDetail() line=$line<br/>\n";

        if ( $line =~ /\-\-genomeset/ ) {
            my ( $tag, $genomeset_name, @genomes ) = split( /\t/, $line );
            if ( $tag && $tag eq '--genomeset' ) {
                $genomeset2genomes{$genomeset_name} = \@genomes; 
            }
        }
        elsif ( $line =~ /\-\-evalue/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--evalue' ) {
                $evalue = $val; 
            }
        }
        elsif ( $line =~ /\-\-isDnaSearch/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--isDnaSearch' ) {
                $isDnaSearch = $val; 
            }
        }
        elsif ( $line =~ /\-\-nRecs/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--nRecs' ) {
                $nRecs = $val; 
            }
        }
        elsif ( $line =~ /\-\-blast/ ) {
            my ( $tag, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--blast' ) {
                $blastFile = $val; 
            }
        }
    }
    close $res;

    require WorkspaceGenomeSet;
    WorkspaceGenomeSet::printGenomeBlastJob(1, \%genomeset2genomes, $blastProgram, $evalue, $isDnaSearch, $nRecs, $blastFile);
        
}

###############################################################################
# showPairwiseANIJobDetail
###############################################################################
sub showPairwiseANIJobDetail {
    my ( $sid, $job_name, $set_names_ref, $data_type ) = @_;

    my %genomeset2genomes;
    my $msg;
    my %taxon2name;
    my @dataRecs;
    my %precomputed;

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );

        if ( $line =~ /\-\-genomeset/ ) {
            my ( $tag, $genomeset_name, @genomes ) = split( /\t/, $line );
            if ( $tag && $tag eq '--genomeset' ) {
                $genomeset2genomes{$genomeset_name} = \@genomes; 
            }
        }
        elsif ( $line =~ /\-\-message/ ) {
            my ( $tag, $message ) = split( /\t/, $line );
            if ( $tag && $tag eq '--message' ) {
                $msg = $message; 
            }
        }
        elsif ( $line =~ /\-\-taxonname/ ) {
            my ( $tag, $taxon, $name ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxonname' ) {
                $taxon2name{$taxon} = $name; 
            }
        }
        elsif ( $line =~ /\-\-recs/ ) {
            my ( $tag, @rec0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--recs' ) {
                my $rec = join("\t", @rec0);
                push(@dataRecs, $rec);
            }
        }
        elsif ( $line =~ /\-\-precomputed/ ) {
            my ( $tag, $label, $val ) = split( /\t/, $line );
            if ( $tag && $tag eq '--precomputed' ) {
                $precomputed{$label} = $val; 
            }
        }
    }
    close $res;

    require ANI;
    ANI::printPairwiseTable(\%taxon2name, \@dataRecs, \%precomputed, $msg);
        
}

###############################################################################
# showFunctionScaffoldSearchDetail
###############################################################################
sub showFunctionScaffoldSearchDetail {
    my ( $sid, $job_name, $set_names_ref, $datatype ) = @_;

    my $dbh = dbLogin();

    my %set2funcs;
    my %set2shareSetName;
    my @selected_funcs;
    my @taxon_oids;
    my %func_names;
    my %taxon2name_h;
    my %taxon_in_file_h;
    my %taxon_db_h;
    my %dbScaf2name_h;
    my %taxon_scaffolds_h;
    my %scaf_func2genes_h;
    my $truncated_cols;
        
    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );

        if ( $line =~ /\-\-funcset/ ) {
            my ( $tag, $funcset_name, @funcs ) = split( /\t/, $line );
            if ( $tag && $tag eq '--funcset' ) {
                my ( $owner, $x ) = WorkspaceUtil::splitAndValidateOwnerFileset( $sid, $funcset_name, $ownerFilesetDelim_message, $FUNC_FOLDER );
                $funcset_name = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim, $sid );
                $set2funcs{$funcset_name} = \@funcs; 
                my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
                $set2shareSetName{$funcset_name} = $share_set_name;
            }
        }
        elsif ( $line =~ /\-\-selected_funcs/ ) {
            my ( $tag, @funcs ) = split( /\t/, $line );
            if ( $tag && $tag eq '--selected_funcs' ) {
                @selected_funcs = @funcs;
            }
        }
        elsif ( $line =~ /\-\-taxon_oids/ ) {
            my ( $tag, @taxons ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxon_oids' ) {
                @taxon_oids = @taxons;
            }
        }
        elsif ( $line =~ /\-\-func_names/ ) {
            my ( $tag, $func, $name ) = split( /\t/, $line );
            if ( $tag && $tag eq '--func_names' ) {
                $func_names{$func} = $name; 
            }
        }
        elsif ( $line =~ /\-\-taxon2name_h/ ) {
            my ( $tag, $taxon, $name ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxon2name_h' ) {
                $taxon2name_h{$taxon} = $name; 
            }
        }
        elsif ( $line =~ /\-\-taxon_in_file/ ) {
            my ( $tag, $taxon ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxon_in_file' ) {
                $taxon_in_file_h{$taxon} = 1; 
            }
        }
        elsif ( $line =~ /\-\-taxon_db_h/ ) {
            my ( $tag, $taxon ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxon_db_h' ) {
                $taxon_db_h{$taxon} = 1; 
            }
        }
        elsif ( $line =~ /\-\-dbScaf2name_h/ ) {
            my ( $tag, $dbScaf, $name ) = split( /\t/, $line );
            if ( $tag && $tag eq '--dbScaf2name_h' ) {
                $dbScaf2name_h{$dbScaf} = $name; 
            }
        }
        elsif ( $line =~ /\-\-taxon_scaffolds_h/ ) {
            my ( $tag, $taxons, @scafs ) = split( /\t/, $line );
            if ( $tag && $tag eq '--taxon_scaffolds_h' ) {
                my %scaf_h;
                for my $scaf (@scafs) {
                    if ( $scaf ) {
                        $scaf_h{$scaf} = 1;                        
                    }
                }
                $taxon_scaffolds_h{$taxons} = \%scaf_h; 
            }
        }
        elsif ( $line =~ /\-\-scaf_func2genes_h/ ) {
            my ( $tag, $scaf, $func, @genes ) = split( /\t/, $line );
            if ( $tag && $tag eq '--scaf_func2genes_h' ) {
                my %genes_h;
                for my $gene (@genes) {
                    if ( $gene ) {
                        $genes_h{$gene} = 1;                        
                    }
                }
                my $func2genes_href = $scaf_func2genes_h{$scaf};
                if ( $func2genes_href ) {
                    $func2genes_href->{$func} = \%genes_h;
                }
                else {
                    my %func2genes_h;
                    $func2genes_h{$func} = \%genes_h;
                    $scaf_func2genes_h{$scaf} = \%func2genes_h;                    
                }
            }
        }
        elsif ( $line =~ /\-\-truncated_cols/ ) {
            my ( $tag, $truncated_cols0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--truncated_cols' ) {
                $truncated_cols = $truncated_cols0; 
            }
        }

    }

    require WorkspaceFuncSet;
    WorkspaceFuncSet::printFuncScaffoldSearch( $sid, \%set2funcs,
        \@selected_funcs, $datatype, \@taxon_oids, 
        \%func_names, \%taxon2name_h, \%taxon_in_file_h, \%taxon_db_h, 
        \%dbScaf2name_h, \%taxon_scaffolds_h, \%scaf_func2genes_h, 
        $truncated_cols );

}

###############################################################################
# showFunctionScaffoldSearchDetail
###############################################################################
sub showSaveFuncGeneDetail {
    my ( $sid, $job_name, $set_names_ref, $datatype ) = @_;

    my $fname;
    my $total_saved;
        
    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";    
    my $res = newReadFileHandle("$job_file_dir/profile.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        next if ( ! $line );

        if ( $line =~ /\-\-fname/ ) {
            my ( $tag, $fname0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--fname' ) {
                $fname = $fname0; 
            }
        }

        if ( $line =~ /\-\-total_saved/ ) {
            my ( $tag, $total_saved0 ) = split( /\t/, $line );
            if ( $tag && $tag eq '--total_saved' ) {
                $total_saved = $total_saved0; 
            }
        }

    }

    my $text = qq{
        <p>
        $total_saved genes saved to file <b>$fname</b><br/>
        <font color=red>If you don't see the saved file, please wait for the system update.</font>
        </p>
    };

    Workspace::folderList( $GENE_FOLDER, $text );

}


###############################################################################
# printSaveSelectedFuncGeneToWorkspace
###############################################################################
sub printSaveSelectedFuncGeneToWorkspace {
    my ( $func_button_action, $gene_button_action ) = @_;

    my $contact_oid = getContactOid();
    return if ( !$contact_oid );

    # workspace
    if ( $user_restricted_site && !$public_nologin_site ) {
        print "<h2>Save to My Workspace</h2>";
        print qq{
            <p>
            Save selected functions or genes of selected functions to
            <a href="$main_cgi?section=Workspace">My Workspace</a>.
            <br/>
            (<i>Special characters in file name will be removed and spaces converted to _ </i>)
            <br/>
        };

        print "<p>\n";
        print qq{
            File name:<br/><input type="text" size="$filename_size" 
            maxLength="$filename_len" name="workspacefilename"
            title='All special characters will be removed and spaces converted to _ '
            />
        };

        print "<br/>";

        print qq{
            <script type="text/javascript" src="$top_base_url/js/Workspace.js" >
            </script>
        };

        my $name = "_section_Workspace_saveFunctionCart";
        if ($func_button_action) {
            $name = $func_button_action;
        }
        print submit(
            -name    => $name,
            -value   => "Save Selected Function to Workspace",
            -class   => "lgbutton",
            -onClick => "return checkSelectedAndFilled('workspacefilename', 'func_id');"
        );

        print nbsp(1);
        $name = "_section_Workspace_saveFuncGenes";
        if ($gene_button_action) {
            $name = $gene_button_action;
        }
        print submit(
            -name    => $name,
            -value   => "Save Genes of Selected Function to Workspace",
            -class   => "lgbutton",
            -onClick => "return checkSelectedAndFilled('workspacefilename', 'func_id');"
        );

        print "</p>\n";
    }
}

################################################################################
# saveSelectedJobFuncFunctions
################################################################################
sub saveSelectedJobFunctions {
    my $sid = getContactOid();
    return if !$sid;

    Workspace::inspectWorkspaceUsage( $sid );

    my @func_ids = param('func_id');
    if ( scalar(@func_ids) == 0 ) {
        WebUtil::webError("Please select one or more functions");
        return;
    }

    my $folder = $FUNC_FOLDER;

    my $filename = param("workspacefilename");
    $filename =~ s/\W+/_/g;
    #print "filename: $filename<br/>\n";
    if ( !$filename ) {
        WebUtil::webError("Please enter a workspace file name.");
        return;
    }

    # check filename
    # valid chars
    WebUtil::checkFileName($filename);

    # this also untaints the name
    $filename = WebUtil::validFileName($filename);

    # check if filename already exist
    if ( -e "$workspace_dir/$sid/$folder/$filename" ) {
        WebUtil::webError("File name $filename already exists. Please enter a new file name.");
        return;
    }

    my $res = newWriteFileHandle("$workspace_dir/$sid/$folder/$filename");
    my $total = 0;
    for my $func_id (@func_ids) {
        print $res $func_id . "\n";
        $total++;
    }
    close $res;

    my $text = qq{
        <p>
        $total functions saved to file <b>$filename</b>
        </p>
    };

    Workspace::folderList( $folder, $text );
}

################################################################################
# saveSelectedJobFuncGenes
################################################################################
sub saveSelectedJobFuncGenes {
    my $sid = getContactOid();
    return if !$sid;

    Workspace::inspectWorkspaceUsage( $sid );

    my @func_ids = param('func_id');
    if ( scalar(@func_ids) == 0 ) {
        WebUtil::webError("Please select one or more functions");
        return;
    }
    my %func_h;
    for my $func_id (@func_ids) {
        $func_h{$func_id} = 1;
    }

    my @gene_sets = param('gene_set');
    my $job_name  = param('job_name');

    my $folder = $GENE_FOLDER;

    my $filename = param("workspacefilename");
    $filename =~ s/\W+/_/g;
    #print "filename: $filename<br/>\n";
    if ( !$filename ) {
        WebUtil::webError("Please enter a workspace file name.");
        return;
    }

    # check filename
    # valid chars
    WebUtil::checkFileName($filename);

    # this also untaints the name
    $filename = WebUtil::validFileName($filename);

    # check if filename already exist
    if ( -e "$workspace_dir/$sid/$folder/$filename" ) {
        WebUtil::webError("File name $filename already exists. Please enter a new file name.");
        return;
    }

    my $job_file_dir = "$workspace_dir/$sid/job/$job_name";
    if ( !( -e "$job_file_dir/list.txt" ) ) {
        WebUtil::webError("No result.");
        return;
    }
    my $res = newWriteFileHandle("$workspace_dir/$sid/$folder/$filename");

    my $fh = newReadFileHandle("$job_file_dir/list.txt");
    my $total = 0;
    while ( my $line = $fh->getline() ) {
        chomp $line;
        my ( $set2, $func_id2, $gene_id, $gene_name ) = split( /\t/, $line );
        if ( $func_h{$func_id2} ) {
            print $res $gene_id . "\n";
            $total++;
        }
    }
    close $fh;

    close $res;

    my $text = qq{
        <p>
        $total genes saved to file <b>$filename</b>
        </p>
    };

    Workspace::folderList( $folder, $text );
}

###############################################################################
# showJobResultList
###############################################################################
sub showJobResultList {

    printMainForm();

    my $job_name = param('job_name');
    my $func_id  = param('func_id');
    my $job_type = param('job_type');
    my $input_file = param('input_file');
    my $data_type = param('data_type');

    my $set_name_title;
    my $taxon_oid;
    if ( $job_type =~ /Genome/ ) {
        $set_name_title = 'Genome';
        $taxon_oid = param('taxon_oid');
    } elsif ( $job_type =~ /Gene/ ) {
        $set_name_title = 'Gene';
    } else {
        $set_name_title = 'Scaffold';
    }

    my $dbh = dbLogin();
    my $sid = getContactOid();

    print "<h1>$job_type: $job_name</h1>\n";

    print "<p>";
    my ( $owner, $x ) = WorkspaceUtil::splitOwnerFileset( $sid, $input_file, $ownerFilesetDelim );
    my $set_name_message = WorkspaceUtil::getOwnerFilesetName( $owner, $x, $ownerFilesetDelim_message, $sid );
    my $share_set_name = WorkspaceUtil::fetchShareSetName( $dbh, $owner, $x, $sid );
    print "$set_name_title Set: $share_set_name<br/>\n";
    print hiddenVar( 'input_file', $input_file );
    if ( $taxon_oid ) {
        print "Genome: $taxon_oid<br/>\n";
        print hiddenVar( 'taxon_oid', $taxon_oid );        
    }

    HtmlUtil::printMetaDataTypeSelection( $data_type, 2 );
    print hiddenVar( 'data_type', $data_type ) if ($data_type);
    my $func_name = Workspace::getMetaFuncName($func_id);
    print "Function $func_id: " . $func_name . "<br/>\n";
    print hiddenVar( 'func_id', $func_id );

    print "</p>";

    WebUtil::checkFileName($job_name);

    # this also untaints the name
    $job_name = WebUtil::validFileName($job_name);

    my $select_id_name = "gene_oid";

    my $it = new InnerTable( 1, "profile_gene$$", "profile_gene", 1 );
    $it->addColSpec("Select");
    $it->addColSpec( "Gene ID",   "char asc", "left" );
    $it->addColSpec( "Gene Name", "char asc", "left" );
    $it->addColSpec( "Genome", "char asc", "left" );
    my $sd = $it->getSdDelim();

    my $dbh = dbLogin();
    my %taxon2name_h;

    my $gene_count = 0;
    my %done;
    
    my $res = newReadFileHandle("$workspace_dir/$sid/job/$job_name/list.txt");
    while ( my $line = $res->getline() ) {
        chomp $line;
        my ( $set2, $func_id2, $gene_id, $gene_name, $t_oid, $data_type, @junk ) 
            = split( /\t/, $line );

        if ( $set_name_message && $set_name_message ne $set2 ) {
            next;
        }
        if ( $taxon_oid && $taxon_oid ne $t_oid ) {
            next;
        }
        if ( $func_id && $func_id ne $func_id2 ) {
            next;
        }
        if ( $done{$line} ) {
            next;
        }
        $done{$line} = 1;

        my $taxon_name;
        if ( $t_oid ) {
            $taxon_name = $taxon2name_h{$t_oid};
            if ( ! $taxon_name ) {
                $taxon_name = QueryUtil::fetchSingleTaxonName( $dbh, $t_oid );
                # save taxon display name to prevent repeat retrieving
                $taxon2name_h{$t_oid} = $taxon_name;            
            }            
        }

        my $r = $sd . "<input type='checkbox' name='$select_id_name' value='$gene_id' " . "  /> \t";

        my $url;
        my $display_id;
        my $t_url;
        if ( isInt($gene_id) ) {
            $display_id = $gene_id;
            $url        = "$main_cgi?section=GeneDetail";
            $url .= "&page=geneDetail&gene_oid=$gene_id";
            $t_url = "$main_cgi?section=TaxonDetail";
            $t_url .= "&page=taxonDetail&taxon_oid=$t_oid";
        } else {
            my ( $t2, $d2, $g2 ) = split( / /, $gene_id );
            $display_id = $g2;
            $url        = "$main_cgi?section=MetaGeneDetail";
            $url .= "&page=metaGeneDetail&taxon_oid=$t2" 
                . "&data_type=$d2&gene_oid=$g2";
            $t_url = "$main_cgi?section=MetaDetail";
            $t_url .= "&page=metaDetail&taxon_oid=$t_oid";
            
            $taxon_name = HtmlUtil::appendMetaTaxonNameWithDataType( $taxon_name, $data_type );
        }
        $r .= $gene_id . $sd . alink( $url, $display_id ) . "\t";
        $r .= $gene_name . $sd . $gene_name . "\t";
        
        if ( $taxon_name ) {
            $r .= $taxon_name . $sd . alink( $t_url, $taxon_name ) . "\t";            
        }
        else {
            $r .= $sd . "\t";
        }

        $it->addRow($r);
        $gene_count++;
    }
    close $res;

    WebUtil::printGeneCartFooter() if ( $gene_count > 10 );
    $it->printOuterTable(1);
    WebUtil::printGeneCartFooter();

    if ( $gene_count > 0 ) {
        print "<br/>\n";
        #MetaGeneTable::printMetaGeneTableSelect();
        #WorkspaceUtil::printSaveGeneToWorkspace_withAllGeneCart($select_id_name);
        WorkspaceUtil::printSaveAndExpandTabsForGenes( $select_id_name );
    }

    printStatusLine( "$gene_count gene(s) loaded", 2 );
    print end_form();
}

###############################################################################
# printConfirmDelete
###############################################################################
sub printConfirmDelete {
    my $sid = getContactOid();
    if ( blankStr($sid) ) {
        WebUtil::webError("Your login has expired.");
        return;
    }

    my @job_ids = param('job_id');

    printMainForm();
    print "<h1>Confirm Deletion</h1>\n";
    for my $job_id (@job_ids) {
        print hiddenVar( 'job_id', $job_id );
    }

    print "<h5>The following result(s) will be deleted:</h5>\n";
    print "<ul>\n";
    for my $job_id (@job_ids) {
        print "<li>$job_id</li>\n";
    }
    print "</ul>\n";

    print submit(
        -name  => "_section_WorkspaceJob_deleteResult",
        -value => "Delete",
        -class => "smdefbutton"
    );
    print nbsp(1);
    print submit(
        -name  => "_section_WorkspaceJob_showMain",
        -value => "Cancel",
        -class => "smbutton"
    );

    print end_form();
}

###############################################################################
# deleteResult
###############################################################################
sub deleteResult {
    
    my $sid = getContactOid();
    if ( blankStr($sid) ) {
        WebUtil::webError("Your login has expired.");
        return;
    }

    $sid = sanitizeInt($sid);

    my @job_ids = param('job_id');
    for my $job_id (@job_ids) {
        if ( !$job_id ) {
            next;
        }

        $job_id = MetaUtil::sanitizeGeneId3($job_id);
        my $job_file_dir = "$workspace_dir/$sid/job/$job_id";
        #print "deleteResult() job_file_dir=$job_file_dir<br/>\n";
        my $job_sandbox_file_dir = "$workspace_sandbox_dir/$sid/job/$job_id";
        
        if ( -e $job_file_dir ) {    
            opendir( DIR, "$job_file_dir" )
              or WebUtil::webDie("failed to read files");
            my @files = readdir(DIR);
            closedir(DIR);
            #print "deleteResult() job files=@files<br/>\n";

            for my $x (@files) {
                next if ( $x eq "." || $x eq ".." );
                $x = MetaUtil::sanitizeGeneId3($x);
    
                my $fname = "$job_file_dir/$x";
                unlink $fname;
    
                # delete sandbox version too - ken
                my $fname = "$job_sandbox_file_dir/$x";
                unlink $fname;
            }
        }

        rmdir $job_file_dir;
                
        # delete sandbox version too - ken
        rmdir $job_sandbox_file_dir;
    
    }    # end for job_id

    printJobMainForm();
}

###############################################################################
# downloadResult
###############################################################################
sub downloadResult {
    
    my $sid = getContactOid();
    if ( blankStr($sid) ) {
        WebUtil::webError("Your login has expired.");
        return;
    }

    $sid = sanitizeInt($sid);
    my $user = getUserName();
    $user = 'public' if ( $user eq "" );
    my $userjob = "$user/job";

    printMainForm();
    print "<h1>Download Job</h1>\n";
    print "<p>Please click the link to download the compressed file.</p>";

    require GenerateArtemisFile;

    my @job_ids = param('job_id');
    for my $job_id (@job_ids) {
        if ( !$job_id ) {
            next;
        }

        $job_id = MetaUtil::sanitizeGeneId3($job_id);
        my $job_file_dir = "$workspace_dir/$sid/job/$job_id";
        #print "downloadResult() job_file_dir=$job_file_dir<br/>\n";
        if ( -e $job_file_dir ) {    
            opendir( DIR, "$job_file_dir" )
              or WebUtil::webDie("failed to read files");
            my @files = readdir(DIR);
            closedir(DIR);
            #print "downloadResult() job files=@files<br/>\n";

            my $exFileName .= "\L${job_id}_" . lc( getSysDate() ) . ".zip";
            my ( $zippedFilePath, $zippedFileUrl ) = GenerateArtemisFile::compressFiles( $userjob, $exFileName, $job_file_dir, \@files );
            #print "downloadResult() zippedFilePath=$zippedFilePath<br/>\n";
            #print "downloadResult() zippedFileUrl=$zippedFileUrl<br/>\n";
            print "job: " . alink( $zippedFileUrl, $job_id );
            print "<br/><br/>\n";
        }

    }    # end for job_id

    print end_form();

}

sub downloadResult2 {
    
    my $sid = getContactOid();
    if ( blankStr($sid) ) {
        WebUtil::webError("Your login has expired.");
        return;
    }

    $sid = sanitizeInt($sid);
    my $user = getUserName();
    $user = 'public' if ( $user eq "" );
    my $userjob = "$user/job";

    require GenerateArtemisFile;

    my @job_ids = param('job_id');
    for my $job_id (@job_ids) {
        if ( !$job_id ) {
            next;
        }

        $job_id = MetaUtil::sanitizeGeneId3($job_id);
        my $job_file_dir = "$workspace_dir/$sid/job/$job_id";
        print "downloadResult() job_file_dir=$job_file_dir<br/>\n";

        if ( -e $job_file_dir ) {
            my $exFileName .= "\L${job_id}_" . lc( getSysDate() ) . ".zip";
            #print "Content-type: application/octet-stream\n";
            #print "Content-Disposition: attachment;filename=$exFileName\n";
            #print "\n";

            opendir( DIR, $job_file_dir )
              or WebUtil::webDie("failed to read files");
            my @files = grep(!/^\.\.?/, readdir(Dir));
            print "downloadResult() job 0 files=@files<br/>\n";
            closedir(DIR);
            print "downloadResult() job 1 files=@files<br/>\n";

            my ( $zippedFilePath, $zippedFileUrl ) = GenerateArtemisFile::compressFiles( $userjob, $job_file_dir, \@files, $exFileName );
            print "downloadResult() zippedFilePath=$zippedFilePath<br/>\n";
            print "downloadResult() zippedFileUrl=$zippedFileUrl<br/>\n";
        }
    }    # end for job_id

    #printJobMainForm();
}


###############################################################################
# getExistingJobSets
###############################################################################
sub getExistingJobSets {

    my @genomeFuncJobs;
    my @genomeBlastJobs;
    my @genomePairwiseANIJobs;
    my @geneFuncJobs;
    my @scafFuncJobs;
    my @scafHistJobs;
    my @scafKmerJobs;
    my @scafPhyloJobs;
    my @funcScafSearchJobs;
    my @genomeSaveFuncGeneJobs;
    my @geneSaveFuncGeneJobs;
    my @scafSaveFuncGeneJobs;
    
    my $sid = getContactOid();
    my $job_dir = "$workspace_dir/$sid/job";
    opendir( DIR, $job_dir );
    my @files = readdir(DIR);
    closedir(DIR);
    
    for my $x (@files) {
        if ( $x eq "." || $x eq ".." || $x =~ /~$/ ) {
            next;
        }

        my $job_info_file = "$job_dir/$x/info.txt";
        if ( -e $job_info_file ) {
            my $res = newReadFileHandle($job_info_file);
            while ( my $line = $res->getline() ) {
                chomp $line;
                my $job_type = $line;
                if ( $job_type eq 'Genome Function Profile' ) {
                    push(@genomeFuncJobs, $x);
                } elsif ( $job_type eq 'Genome Blast' ) {
                    push(@genomeBlastJobs, $x);
                } elsif ( $job_type eq 'Genome Pairwise ANI' ) {
                    push(@genomePairwiseANIJobs, $x);
                } elsif ( $job_type eq 'Gene Function Profile' ) {
                    push(@geneFuncJobs, $x);
                } elsif ( $job_type eq 'Scaffold Function Profile' ) {
                    push(@scafFuncJobs, $x);
                } elsif ( $job_type eq 'Scaffold Histogram' ) {
                    push(@scafHistJobs, $x);
                } elsif ( $job_type eq 'Scaffold Kmer' ) {
                    push(@scafKmerJobs, $x);
                } elsif ( $job_type eq 'Scaffold Phylo Distribution' ) {
                    push(@scafPhyloJobs, $x);
                } elsif ( $job_type eq 'Function Scaffold Search' ) {
                    push(@funcScafSearchJobs, $x);
                } elsif ( $job_type eq 'Genome Save Function Gene' ) {
                    push(@genomeSaveFuncGeneJobs, $x);
                } elsif ( $job_type eq 'Gene Save Function Gene' ) {
                    push(@geneSaveFuncGeneJobs, $x);
                } elsif ( $job_type eq 'Scaffold Save Function Gene' ) {
                    push(@scafSaveFuncGeneJobs, $x);
                }
                last;
            }
            close $res;
        }
    }
    
    return (\@genomeFuncJobs, \@genomeBlastJobs, \@genomePairwiseANIJobs, \@geneFuncJobs, 
        \@scafFuncJobs, \@scafHistJobs, \@scafKmerJobs, \@scafPhyloJobs, \@funcScafSearchJobs,
        \@genomeSaveFuncGeneJobs, \@geneSaveFuncGeneJobs, \@scafSaveFuncGeneJobs);
}


1;
