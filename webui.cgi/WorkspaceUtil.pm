############################################################################
# WorkspaceUtil.pm
# $Id: WorkspaceUtil.pm 36998 2017-04-26 21:19:12Z klchu $
############################################################################
package WorkspaceUtil;

use strict;
use CGI qw( :standard );
use System::Command;
use Data::Dumper;
use DBI;
use WebConfig;
use WebUtil;
use InnerTable;
use DataEntryUtil;

$| = 1;

my $env      = getEnv();
my $main_cgi = $env->{main_cgi};
my $verbose  = $env->{verbose};
my $base_dir = $env->{base_dir};
my $base_url = $env->{base_url};
my $cgi_url  = $env->{cgi_url};
my $YUI      = $env->{yui_dir_28};
my $in_file  = $env->{in_file};
my $user_restricted_site = $env->{user_restricted_site};
my $public_nologin_site  = $env->{public_nologin_site};
my $enable_genomelistJson = $env->{enable_genomelistJson};
my $enable_workspace = $env->{enable_workspace};
my $workspace_dir        = $env->{workspace_dir};
my $img_group_share = $env->{img_group_share};
my $include_metagenomes  = $env->{include_metagenomes};
my $top_base_url = $env->{top_base_url};
my $img_ken              = $env->{img_ken};
my $preferences_url    = "$main_cgi?section=MyIMG&form=preferences";

my $GENOME_FOLDER = "genome";
my $GENE_FOLDER   = "gene";
my $SCAF_FOLDER   = "scaffold";
my $FUNC_FOLDER   = "function";
my $BC_FOLDER     = "bc";
my $RULE_FOLDER   = "rule";
my @subfolders = ( $GENOME_FOLDER, $GENE_FOLDER, $SCAF_FOLDER, $FUNC_FOLDER, $BC_FOLDER );

my $max_workspace_view = 20000;

my $filename_size      = 25;
my $filename_len       = 60;

my $ownerFilesetDelim = "|";
my $ownerFilesetDelim_FromFormat = "____";
my $ownerFilesetDelim_message = "::::";


#
# out of 3 queues (directory) find the smallest one
# - ken
#
sub getQueueDir {
    # $e->{workspace_messageSystem_dir} = '/global/projectb/sandbox/IMG_web/messageSystem/';
    my $message_dir = $env->{workspace_messageSystem_dir};
    
    # server gpint205, gpint204, gpint212
    # queue size
    my %servers =('gpint205' => 0, 'gpint204' => 0, 'gpint212' => 0);
    foreach my $server (keys %servers) {
        my $queue_dir = $message_dir . $server . '/QUEUE/';
        my @files = WebUtil::dirList($queue_dir);
        $servers{$server} = $#files + 1;
    }
    
    # TEST
    #%servers =('gpint205' => 24, 'gpint204' => 20, 'gpint212' => 51);
    
    # default is gpint205 ???
    my @sorted = sort { $servers{$a} <=> $servers{$b} } keys %servers;
    my $key = $sorted[0]; # this gpintXX has the samllest queue size
    
    print qq{
<br>
@sorted 
<br>
$message_dir  $key  /QUEUE/;
    } if ($img_ken);
    
    return  $message_dir . $key . '/QUEUE/';
}

############################################################################
# getMaxWorkspaceView
############################################################################
sub getMaxWorkspaceView {
    
    return $max_workspace_view;
}

sub printMaxNumMsg {
    my ( $type ) = @_;
        
    print "<p>\n";
    print "Only a maximum of $max_workspace_view $type can be displayed.\n";
    print "</p>\n";
}

# get number of lines in file
# number of oids
# wc
# line count
#
sub getFileLineCount {
    my($workspace_dir, $sid, $folder, $file) = @_;
    
    my $cnt = 0;
    my $filePath = "$workspace_dir/$sid/$folder/$file";
    if ($filePath =~ /^(.*)$/) { $filePath = $1; } # untaint
     
    # the original way
#    open( FH, $filePath ) or WebUtil::webError("File size - file error $file");
#    while (<FH>) {
#        $cnt++ if ( !/^\s+?$/ && /[a-zA-Z0-9]+/ );
#    }
#    close FH;
#    return $cnt;    
    
    # http://docstore.mik.ua/orelly/perl/cookbook/ch08_03.htm
    # Here's the fastest solution, assuming your line terminator really is "\n" :
    my $count = 0;
    open( FILE, $filePath ) or WebUtil::webError("File size - file error $file");
    $count += tr/\n/\n/ while sysread(FILE, $_, 2 ** 16);
    close FILE;
    return $count;  
    
    # the best but `` does not work with -T
    #my $lines;
    #$lines = `/usr/bin/wc -l $filePath`;
    #chomp $lines;    
    #return $lines;
    #
    # so try this
#    my $cfh = WebUtil::newCmdFileHandle( "/usr/bin/wc -l $filePath" );
#    my $s = $cfh->getline();
#    chomp $s;
#    close $cfh;
#    my ($cnt, $junk) = split(/\s+/, $s);
#    return $cnt;
}

############################################################################
# printShareMainTable - prints the set table for main form
#                       (with share option)
############################################################################
sub printShareMainTableNoFooter {
    my ( $section, $workspace_dir, $sid, $folder, $files_aref, 
        $groupSharingDisplay, $grpCnt, $staticOnly ) = @_;

    my $section_cgi = "$main_cgi?section=$section";

    my $what = ucfirst( lc($folder) );
    my $whats = $what . "s";

    my $it;
    if ( $staticOnly ) {
        $it = new StaticInnerTable();        
    }
    else {
        $it = new InnerTable( 1, "ShareMainTable$$", "ShareMainTable", 1 );        
    }
    my $sd = $it->getSdDelim();
    $it->addColSpec( "Select" );
    $it->addColSpec( "File Name", "asc",  "left",  "", "", "wrap" );
    $it->addColSpec( "Number of $whats<br>(click the link to each individual set)",
			 "desc", "right", "", "", "wrap" );
    $it->addColSpec( "File Size", "", "right", "", "", "wrap" );
    if ( ($groupSharingDisplay && $groupSharingDisplay ne 'No') 
        || ( $grpCnt && $grpCnt > 0) ) {
        $it->addColSpec( "Owner", "asc",  "left",  "", "", "wrap" );
        $it->addColSpec( "Shared with Group", "asc",  "left",  "", "", "wrap" );        
    }

    my $set_cnt = 0;
    my %names_h;

    ## print my own first
    if ( scalar(@$files_aref) > 0 ) {
        my %share_h;
        if ( $grpCnt && $grpCnt > 0 ) {
            %share_h = getShareToGroups($folder);
        }
        
        foreach my $x ( @$files_aref ) {
        	next if ( $x eq "." || $x eq ".." || $x =~ /~$/ );
        	my $escX = WebUtil::massageToUrl2($x);
            $names_h{$x} = $x;
        
        	# get number of lines in file
        	my $cnt = getFileLineCount($workspace_dir, $sid, $folder, $x);
            my $filePath = "$workspace_dir/$sid/$folder/$x";        
        
        	my $row =
        	    $sd . "<input type='checkbox' name='filename' value='$escX'/>\t";
        	$row .= $x . $sd . $x . "\t";

            #my $cnt2 = $cnt;
            #if ( $cnt2 || $folder eq 'rule' ) {
            #    $cnt2 =
            #    "<a href='$section_cgi&page=showDetail"
            #    . "&filename=$escX&folder=$folder'>$cnt2</a>";
            #}
            if ( !$cnt || $cnt <= 0 ) {
                $row .= $cnt . $sd . $cnt . "\t";                
            }
            else {
                my $cnt_url;
                if ( $cnt || $folder eq 'rule' ) {
                    $cnt_url = "$section_cgi&page=showDetail&filename=$escX&folder=$folder";
                }        
                $row .= $cnt . $sd . alink( $cnt_url, $cnt ) . "\t";                
            }
    
            my $size = WebUtil::fileSize($filePath);
            my $display_size = getDisplaySize($size);
            $row .= $size . $sd . $display_size . "\t";
    
            if ( $grpCnt && $grpCnt > 0 ) {
                $row .= "me" . $sd . "me" . "\t";
            
                my $grp_str = "";
                my @groups = split(/\t/, $share_h{$escX});
                for my $g1 ( @groups ) {
                    my ($g_id, $g_name) = split(/\,/, $g1, 2);
                    my $g_url = "$main_cgi?section=ImgGroup" .
                    "&page=showGroupDetail&group_id=" . $g_id;
                    if ( $grp_str ) {
                        $grp_str .= ", " . alink($g_url, $g_name);
                    }
                    else {
                        $grp_str = alink($g_url, $g_name);
                    }
                }
                if ( ! $grp_str ) {
                    $grp_str = "-";
                }
                $row .= $grp_str . $sd . $grp_str . "\t";
            }
                    
        	$it->addRow($row);
        	$set_cnt++;
        }
    }
    
    ## show share
    if ( $groupSharingDisplay && $groupSharingDisplay ne 'No' ) {
        my %share_from_h = getShareFromGroups($folder, '', $groupSharingDisplay);
        for my $k (keys %share_from_h) {
            my ($c_oid, $data_set_name) = splitOwnerFileset( $sid, $k );
            my ($g_id, $g_name, $c_name) = split(/\t/, $share_from_h{$k});
        
            my $escX = WebUtil::massageToUrl2($data_set_name);        
            if ( ! $escX ) {
                next;
            }
            $names_h{$k} = $data_set_name . " (owner: $c_name)";
        
            my $row =
                $sd . "<input type='checkbox' name='share_filename' value='$c_oid|$escX'/>\t";
            $row .= $data_set_name . "\t";
        
            # get number of lines in file
            my $cnt = getFileLineCount($workspace_dir, $c_oid, $folder, $data_set_name);
            my $filePath = "$workspace_dir/$c_oid/$folder/$data_set_name";
        
            #my $cnt2 = $cnt;
            #if ($cnt2) {
            #    $cnt2 =
            #    "<a href='$section_cgi&page=showDetail"
            #    . "&owner=$c_oid"
            #    . "&filename=$escX&folder=$folder'>$cnt2</a>";
            #}
            #$row .= $cnt2 . "\t";
            my $cnt_url;
            if ( $cnt || $folder eq 'rule' ) {
                $cnt_url = "$section_cgi&page=showDetail&owner=$c_oid&filename=$escX&folder=$folder";
            }        
            $row .= $cnt . $sd . alink( $cnt_url, $cnt ) . "\t";
    
            my $size = WebUtil::fileSize($filePath);
            my $display_size = getDisplaySize($size);
            $row .= $size . $sd . $display_size . "\t";
    
            $row .= $c_name . $sd . $c_name . "\t";
        
            my $g_url = "$main_cgi?section=ImgGroup" .
                "&page=showGroupDetail&group_id=" . $g_id;
            $row .= $g_name . $sd . alink($g_url, $g_name) . "\t";
        
            $it->addRow($row);
            $set_cnt++;
        }
    }

    if ( $set_cnt ) {
    	$it->printOuterTable(1);
    }
    else {
    	print "<h5>No workspace $folder sets.</h5>\n";
    }

    return ($set_cnt, \%names_h);
}

############################################################################
# printShareMainTable - prints the set table for main form
#                       (with share option)
############################################################################
sub printShareMsg {
    my ( $groupSharingDisplay ) = @_;

    my $s;
    if ( $groupSharingDisplay && $groupSharingDisplay ne 'No' ) {
        if ( $groupSharingDisplay eq 'All' ) {
            $s = "Set(s) shared from all groups are displayed.\n"; 
        }
        else {
            $s = "Set(s) shared from group $groupSharingDisplay are displayed.\n";             
        }
    }
    else {
        $s = "Group sharing is not displayed.\n";        
    }
    $s .= " Please go to " . alink( $preferences_url, "Preferences" ) 
        . " to change the sharing display options.\n";
    print "<p>$s</p>";
}

#####################################################################
# printShareMainTable: set main table with share
#####################################################################
sub printShareMainTable {
    my ( $section, $workspace_dir, $sid, $folder, $files_ref, $groupSharingDisplay ) = @_;

    my ($set_cnt, $names_href);
    
    if ( scalar(@$files_ref) > 0 ) {
        my $what = ucfirst( lc($folder) );
        if (scalar(@$files_ref) > 10) {
            printSetMainTableButtons( $section, $folder, $what );
        }

        if ( $groupSharingDisplay && $groupSharingDisplay ne 'No' ) {
            my $grpCnt = getContactImgGroupCnt();
            ($set_cnt, $names_href) = printShareMainTableNoFooter( $section, $workspace_dir, $sid, $folder, $files_ref, $groupSharingDisplay, $grpCnt );
            if ( $grpCnt && $grpCnt > 0 ) {
                print "<p><b>(Note: You can only share or delete your own datasets.)</b><br/>\n";
                printGroupShareButtons( $section, $folder );
                print "<p>\n";
            }
        }
        else {
            ($set_cnt, $names_href) = printShareMainTableNoFooter( $section, $workspace_dir, $sid, $folder, $files_ref );
        }

        printSetMainTableButtons( $section, $folder, $what );
    }
    
    return $names_href;
}

#####################################################################
# printGroupShareButtons
#####################################################################
sub printGroupShareButtons {
    my ( $section, $folder ) = @_;

    my %group_h = getContactImgGroups();

    print "<p>IMG Group:\n";
    print nbsp(1); 
    print "<select name='group_share' class='img' size='1'>\n";
    for my $k (keys %group_h) {
    	print "  <option value='$k'>" . $group_h{$k} .
    	    "</option>\n";
    }
    print "</select>\n";
    print nbsp(2); 

    print submit(
    	-name    => "_section_Workspace_addSharing",
    	-value   => "Share Selected Set(s) with Group",
    	-class   => 'medbutton',
    	-onClick => "return checkSets('$folder');"
	);
    print nbsp(4);
    print submit(
        -name    => "_section_Workspace_removeSharing",
        -value   => 'Remove Sharing of Selected Set(s)',
        -class   => 'medbutton'
        -onClick => "return checkSets('$folder');"
    );
}

#####################################################################
# printSetMainTableButtons
#####################################################################
sub printSetMainTableButtons {
    my ( $section, $folder, $what ) = @_;

    ## Amy: limit the folder type, because I am adding rule sets
    if ( $folder eq $GENE_FOLDER 
        || $folder eq $FUNC_FOLDER 
        || $folder eq $SCAF_FOLDER 
        || $folder eq $GENOME_FOLDER 
        || $folder eq $BC_FOLDER) {
    	 print submit(
    	     -name    => "_section_Workspace_wpload_noHeader",
    	     -value   => "Add Selected to $what Cart",
    	     -class   => 'meddefbutton',
    	     -onClick => "return checkSetsIncludingShare('$folder');"
    	     );
    	 print nbsp(1);
    }
    WebUtil::printButtonFooterInLine();
    print nbsp(1);
    print submit(
        -name    => "_section_" . $section . "_delete",
        -value   => 'Remove Selected',
        -class   => 'medbutton',
        -onClick => "return confirmDelete('$folder');"
    );
}

############################################################################
# printSaveAndExpandTabsForGenes
############################################################################
sub printSaveAndExpandTabsForGenes {
    my ( $select_id_name, $saveSelectedName, $saveAllName, $notToSaveSelected, $notToSaveAll ) = @_;

    TabHTML::printTabAPILinks("profilegenelistTab");
    my @tabIndex;
    my @tabNames;
    if ($user_restricted_site) {
        @tabIndex = ( "#profilegenelisttab1", "#profilegenelisttab2" );
        @tabNames = ( "Save", "Expand Display" );
    }
    else {
        @tabIndex = ( "#profilegenelisttab1" );
        @tabNames = ( "Expand Display" );
    }
    TabHTML::printTabDiv( "profilegenelistTab", \@tabIndex, \@tabNames );

    if ($user_restricted_site) {
        # add to gene cart
        print "<div id='profilegenelisttab1'>";

    	if ( !$notToSaveSelected && !$saveSelectedName ) {
    	    $saveSelectedName = "_section_Workspace_saveGeneCart";
    	}
        
    	if ( !$notToSaveAll && !$saveAllName ) {
    	    $saveAllName = "_section_Workspace_saveAllGeneCart";
    	}

        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            $saveSelectedName, 
            $saveAllName, 
            '', '', '',
            $select_id_name 
        );

        print "</div>\n";

        print "<div id='profilegenelisttab2'>";
    }
    else {
        print "<div id='profilegenelisttab1'>";
    }
    MetaGeneTable::printMetaGeneTableSelect();
    print "</div>\n";
    TabHTML::printTabDivEnd();
}

############################################################################
# printSelectedInfo - print selected information 
############################################################################
sub printSelectedInfo {
    my ( $what, @selected ) = @_;

    if (scalar(@selected) <= 10) {
        print "Selected $what" . "(s): <i>@selected</i><br/>\n";
    }
    else {
        print "Selected $what count: <i>" . scalar(@selected) . "</i><br/>\n";        
    }
    print "<br/>\n";

}

############################################################################
# printSelectedInfo2 - print selected information 
#                      (including share)
############################################################################
sub printSelectedInfo2 {
    my ( $dbh, $what, @selected ) = @_;

    my $sid = getContactOid();
    if (scalar(@selected) <= 10) {
        print "Selected $what" . "(s): ";
    	printShareSetName( $dbh, $sid, @selected );
    	print "<br/>\n";
    }
    else {
        print "Selected $what count: <i>" . scalar(@selected) . "</i><br/>\n";        
    }
    print "<br/>\n";

}


############################################################
# getShareSetName: data set name with owner
############################################################
sub getShareSetName {
    my ( $dbh, $s2, $sid ) = @_;

    my ( $c_oid, $name ) = splitOwnerFileset( $sid, $s2 );    
    my $new_str = fetchShareSetName( $dbh, $c_oid, $name, $sid );

    return $new_str;
}

############################################################
# fetchShareSetName: data set name with owner stripped
############################################################
sub fetchShareSetName {
    my ( $dbh, $c_oid, $name, $sid, $fromFormat ) = @_;

    my $new_str;
    if ( WebUtil::isInt($c_oid) && $c_oid != $sid ) {
        #print "fetchShareSetName() owner=$c_oid, name=$name, sid=$sid<br/>\n";
        my $owner_name = getOwnerName( $dbh, $c_oid );
        if ( $fromFormat ) {
            $owner_name =~ s/\W+/_/g;
            $new_str = $name . $ownerFilesetDelim_FromFormat . $owner_name;
        }
        else {
            $new_str = "$name (owner: $owner_name)";
        }
    }
    else {
        $new_str = $name;        
    }

    return $new_str;
}


#############################################################################
# getShareSetNames
#############################################################################
sub getShareSetNames {
    my ( $dbh, $sid, $isSet, $all_files_ref, $fileFullname ) = @_;

    my %ownerSetName2shareSetName;
    if ($isSet) {
        # genome sets
        for my $x2 (@$all_files_ref) { 
            my ($owner, $x) = splitOwnerFileset( $sid, $x2 ); 
            my $share_set_name = fetchShareSetName( $dbh, $owner, $x, $sid );
            $ownerSetName2shareSetName{$x2} = $share_set_name;
        }
    }
    else {
        if ( $fileFullname ) {
            my ($owner, $x) = splitOwnerFileset( $sid, $fileFullname ); 
            my $share_set_name = fetchShareSetName( $dbh, $owner, $x, $sid );
            $ownerSetName2shareSetName{$fileFullname} = $share_set_name;            
        }
    }

    return (\%ownerSetName2shareSetName);
}

############################################################
# fetchShareSetName: data set name with owner stripped
############################################################
sub getOwnerName {
    my ( $dbh, $c_oid ) = @_;

    return DataEntryUtil::db_findVal($dbh, 'contact', 
        'contact_oid', $c_oid, 'name', '');
}


############################################################
# printShareSetName: print data set name with owner
############################################################
sub printShareSetName {
    my ( $dbh, $sid, @all_names ) = @_;

    my $i = 0;
    for my $s2 ( @all_names ) {
    	if ( $i ) {
    	    print ", ";
    	}

        my ($c_oid, $name) = splitOwnerFileset( $sid, $s2 );
    	if ( ! $name || ! isInt($c_oid) ) {
    	    print "<i>$s2</i>";
    	}
    	else {
            if ( $c_oid == $sid ) {
                print "<i>$name</i>";
            }
            else {
                my $owner_name = getOwnerName( $dbh, $c_oid );
        	    print "<i>$name</i> (owner: $owner_name)";
        	}
    	}
    
    	$i++;
    }
}

############################################################################
# printDisplayTableButtons 
############################################################################
sub printDisplayTableButtons {
    my ($addSpecialExportButton) = @_;

    WebUtil::printButtonFooter();
#    print "<input type='button' name='selectAll' value='Select All' "
#      . "onClick='selectAllCheckBoxes(1)' class='smbutton' />\n";
#    print nbsp(1);
#    print "<input type='button' name='clearAll' value='Clear All' "
#      . "onClick='selectAllCheckBoxes(0)' class='smbutton' />\n";

}

############################################################################
# catalogOids
############################################################################
sub catalogOids {
    my ( @oids ) = @_;

    my %oids_hash;
    my @db_oids = ();
    my @fs_oids = ();
    my @displayIds = ();
    for my $oid (@oids) {
        if ( $oids_hash{$oid} ) {
            #duplicates
            next;
        }

        my $displayId = 0;
        my @v = split( / /, $oid );
        if ( scalar(@v) == 1 ) {
            if ( isInt( $v[0] ) ) {
                # integer database id
        	    $displayId = $v[0];
        	    push (@db_oids, $v[0] );
                $oids_hash{$oid} = 1;
            }
        }
        else {
            if ( scalar(@v) >= 3 ) {
                $displayId = $v[2];
        	    push (@fs_oids, $oid );
                $oids_hash{$oid} = 2;
            }
        }
        push (@displayIds, $displayId);
        #print "$oid<br/>\n";
    }
    #print "db_oids: @db_oids<br/>\n";
    #print "fs_oids: @fs_oids<br/>\n";

    return (\@displayIds, \@db_oids, \@fs_oids);
}

sub catalogOidsFromFile {
    my ($workspace_dir, $sid, $folder, @input_files) = @_;

    my %oids_hash;
    my @db_oids = ();
    my @fs_oids = ();
    my @displayIds = ();
    for my $input_file (@input_files) {
        my ( $owner, $x ) = splitAndValidateOwnerFileset( $sid, $input_file, $ownerFilesetDelim, $folder );
        open( FH, "$workspace_dir/$owner/$folder/$x" )
            or WebUtil::webError("File size - file error $input_file");

        while ( my $line = <FH> ) {
            chomp($line);
            if ( $oids_hash{$line} ) {
                # duplicates
                next;
            }

            my $displayId = 0;
            my @v = split( / /, $line );
            if ( scalar(@v) == 1 ) {
                if ( isInt( $v[0] ) ) {
                    # integer database id
            	    $displayId = $v[0];
            	    push (@db_oids, $v[0] );
                    $oids_hash{$line} = 1;
                }
            }
            else {
                if ( scalar(@v) >= 3 ) {
                    $displayId = $v[2];
            	    push (@fs_oids, $line );
                    $oids_hash{$line} = 2;
                }
            }
            push (@displayIds, $displayId);
            #print "$oid<br/>\n";
        }

        close FH;
    }
    #print "db_oids: @db_oids<br/>\n";
    #print "fs_oids: @fs_oids<br/>\n";
    
    return (\@displayIds, \@db_oids, \@fs_oids);
}

sub catalogOidsFromFile2 {
    my ($sid, $workspace_dir, $folder, @input_files) = @_;

    my %oids_hash;
    my @db_oids = ();
    my @fs_oids = ();
    my @displayIds = ();
    for my $name2 (@input_files) {
    	my ($c_oid, $input_file) = splitOwnerFileset( $sid, $name2 );
    	if ( ! $c_oid || ! $input_file ) {
    	    next;
    	}

        open( FH, "$workspace_dir/$c_oid/$folder/$input_file" )
            or WebUtil::webError("File size - file error $input_file");

        while ( my $line = <FH> ) {
            chomp($line);
            if ( $oids_hash{$line} ) {
                # duplicates
                next;
            }

            my $displayId = 0;
            my @v = split( / /, $line );
            if ( scalar(@v) == 1 ) {
                if ( isInt( $v[0] ) ) {
                    # integer database id
            	    $displayId = $v[0];
            	    push (@db_oids, $v[0] );
                    $oids_hash{$line} = 1;
                }
            }
            else {
                if ( scalar(@v) >= 3 ) {
                    $displayId = $v[2];
            	    push (@fs_oids, $line );
                    $oids_hash{$line} = 2;
                }
            }
            push (@displayIds, $displayId);
            #print "$oid<br/>\n";
        }

        close FH;
    }
    #print "db_oids: @db_oids<br/>\n";
    #print "fs_oids: @fs_oids<br/>\n";
    
    return (\@displayIds, \@db_oids, \@fs_oids);
}

sub getOidsFromFile {
    my ($workspace_dir, $sid, $folder, @input_files) = @_;

    my $dbh = dbLogin();

    my %file2oids;
    my %file2owner;
    for my $input_file (@input_files) {
        my ( $owner, $x ) = splitAndValidateOwnerFileset( $sid, $input_file, $ownerFilesetDelim, $folder );
        my $share_set_name = fetchShareSetName( $dbh, $owner, $x, $sid, 1 );
        $file2owner{$share_set_name} = $owner;

        open( FH, "$workspace_dir/$owner/$folder/$x" )
            or WebUtil::webError("File size - file error $input_file");
        while ( my $line = <FH> ) {
            #print "line: $line<br/>\n";
            chomp($line);
            my $oids_ref = $file2oids{$share_set_name};
            if ( $oids_ref ) {
                push(@$oids_ref, $line);
            }
            else {
                my @oids = ($line);
                $file2oids{$share_set_name} = \@oids;
            }
        }

        close FH;
    }
    
    return (\%file2oids, \%file2owner);
}

sub printSaveSelectedGenomeToWorkspace {
    my ( $saveSelectedName ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genomes</b> to",
            "$saveSelectedName", 
            '', '', '', '', '', '', 1
        );
    }
}

sub printSaveGenomeToWorkspace {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genomes</b> to",
            "_section_Workspace_saveGenomeCart", 
            '', '', '', '', 
            $select_id_name
        );
    }
}

sub printSaveGenomeToWorkspace_withAllBrowserGenomeList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genomes</b> to",
            "_section_Workspace_saveGenomeCart", 
            "_section_Workspace_saveAllBrowserGenomeList",
            '', '', '', 
            $select_id_name
        );
    }
}

sub printSaveGeneSetGenomesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genomes of selected gene set(s)</b> to", 
            "_section_Workspace_saveGeneSetGenomesAlternative", 
            '', 
            "Save Genomes of Selected Gene Sets", 
            '', 
            $GENOME_FOLDER,
            $select_id_name,
            '', 
            1             
        );
    }
}

sub printSaveGeneGenomesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genomes of selected genes</b> to", 
            "_section_Workspace_saveGeneGenomesAlternative", 
            '', 
            "Save Genomes of Selected Genes", 
            '', 
            $GENOME_FOLDER, 
            "$select_id_name"
        );
    }
}

sub printSaveScaffoldSetGenomesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genomes of selected scaffold set(s)</b> to", 
            "_section_Workspace_saveScaffoldSetGenomesAlternative", 
            '', 
            "Save Genomes of Selected Scaffold Sets", 
            '', 
            $GENOME_FOLDER, 
            $select_id_name,
            '', 
            1             
        );
    }
}

sub printSaveScaffoldGenomesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genomes of selected scaffolds</b> to", 
            "_section_Workspace_saveScaffoldGenomesAlternative", 
            '', 
            "Save Genomes of Selected Scaffolds", 
            '', 
            $GENOME_FOLDER, 
            $select_id_name
        );
    }
}

sub printSaveFunctionToWorkspace {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected functions</b> to",
            "_section_Workspace_saveFunctionCart", 
            '', '', '', '', 
            $select_id_name
        );
    }   
}

sub printSaveGeneToWorkspace {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart", 
            '', '', '', '', 
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace2 {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart2", 
            '', '', '', '', 
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllTaxonFuncGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllTaxonFuncGenes", 
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllTaxonRnaGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllTaxonRnaGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllGeneCart {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllGeneCart", 
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllGeneFuncList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllGeneFuncList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllCDSGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllCDSGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllRnaGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllRnaGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllGeneProdList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllGeneProdList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllGeneWithoutFuncList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllGeneWithoutFuncList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllNoEnzymeWithKOGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllNoEnzymeWithKOGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllKeggCategoryGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllKeggCategoryGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllKeggPathwayGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllKeggPathwayGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllNonKeggGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllNonKeggGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllNonKoGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllNonKoGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllNonMetacycGeneList {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllNonMetacycGeneList",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllCKogCatGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllCKogCatGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllPfamCatGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllPfamCatGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllTIGRfamCatGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllTIGRfamCatGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllImgTermCatGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllImgTermCatGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllClusterGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllClusterGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllCassetteGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllCassetteGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllCassetteOccurrenceGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllCassetteOccurrenceGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllFusedGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllFusedGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllSignalGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllSignalGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllTransmembraneGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllTransmembraneGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllBiosyntheticGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllBiosyntheticGenes",
            '', '', '',
            $select_id_name
        );
    }
}


sub printSaveGeneToWorkspace_withAllMetaHits {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllMetaHits", 
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllDbScafGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllDbScafGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneToWorkspace_withAllMetaScafGenes {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected or all genes</b> to",
            "_section_Workspace_saveGeneCart",
            "_section_Workspace_saveAllMetaScafGenes",
            '', '', '',
            $select_id_name
        );
    }
}

sub printSaveScaffoldSetGenesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genes of selected scaffold set(s)</b> to", 
            "_section_Workspace_saveScaffoldSetGenesAlternative", 
            '', 
            "Save Genes of Selected Scaffold Sets", 
            '', 
            $GENE_FOLDER, 
            $select_id_name,
            '', 
            1             
        );
    }
}

sub printSaveScaffoldGenesAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all genes of selected scaffolds</b> to", 
            "_section_Workspace_saveScaffoldGenesAlternative", 
            '', 
            "Save Genes of Selected Scaffolds", 
            '', 
            $GENE_FOLDER, 
            $select_id_name
        );
    }
}

sub printSaveScaffoldToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected scaffolds</b> to",
            "_section_Workspace_saveScaffoldCart", 
            '', '', '', '',
            $select_id_name
        );
    }
}

sub printSaveScaffoldDistToWorkspace {
    my ( $select_id_name, $selectFieldParamName ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected scaffolds</b> to",
            "_section_Workspace_saveScaffoldDistToWorkspace",
            '', '', '', '',
            $select_id_name, $selectFieldParamName
        );
    }
}

sub printSaveScaffoldLengthRangeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected scaffolds</b> to",
            "_section_Workspace_saveScaffoldLengthRange",
            '', '', '', '',
            $select_id_name
        );
    }
}

sub printSaveGeneSetScaffoldsAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all scaffolds of selected gene set(s)</b> to", 
            "_section_Workspace_saveGeneSetScaffoldsAlternative", 
            '', 
            "Save Scaffolds of Selected Gene Sets", 
            '', 
            $SCAF_FOLDER,
            $select_id_name,
            '',
            1
        );
    }
}

sub printSaveGeneScaffoldsAlternativeToWorkspace {
    my ( $select_id_name ) = @_;

    # save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>all scaffolds of selected genes</b> to", 
            "_section_Workspace_saveGeneScaffoldsAlternative", 
            '', 
            "Save Scaffolds of Selected Genes", 
            '', 
            $SCAF_FOLDER, 
            "$select_id_name"
        );
    }
}


#############################################################################
# printCartSaveToWorkspace -
#              used in carts to print html code to save to workspace
#
# saveSelectedName: save selected only
# saveAllName: save all (including the ones that got truncated in UI)
#############################################################################
sub printCartSaveToWorkspace {
    my ( $text, $saveSelectedName, $saveAllName, $saveSelectButtonName,
        $saveAllButtonName, $alterNameFolder, $selectFieldName, $selectFieldParamName,
        $isFromWorkspace )
      = @_;
      
    my $contact_oid = getContactOid();
    return if ( !$contact_oid );

    if (   $enable_workspace
        && $user_restricted_site
        && !$public_nologin_site )
    {

        my $folder = '';
        if ( $saveSelectedName eq "_section_Workspace_saveGenomeCart" 
        || $saveSelectedName eq "_section_Workspace_saveGenomeSetCreation" ) {
            $folder = $GENOME_FOLDER;
        }
        elsif ($saveSelectedName eq "_section_Workspace_saveGeneCart"
            || $saveSelectedName eq "_section_Workspace_saveGeneCart2" )
        {
            $folder = $GENE_FOLDER;
        }
        elsif ( $saveSelectedName eq "_section_Workspace_saveFunctionCart" ) {
            $folder = $FUNC_FOLDER;
        }
        elsif ($saveSelectedName eq "_section_Workspace_saveScaffoldCart"
            || $saveSelectedName eq "_section_Workspace_saveScaffoldDistToWorkspace"
            || $saveSelectedName eq
            "_section_Workspace_saveScaffoldLengthRange" )
        {
            $folder = $SCAF_FOLDER;
        }
        elsif ($saveSelectedName eq "_section_Workspace_saveBcCart" )
        {
            $folder = $BC_FOLDER;
        }

        if ($alterNameFolder) {
            $folder = $alterNameFolder;
        }

        my $what = '';
        if ($folder) {
            if ( $folder eq $BC_FOLDER ) {
                $what = uc($folder) . 's ';                
            }
            else {
                $what = ucfirst( lc($folder) ) . 's ';                
            }
        }

        my $workspacefilename = 'workspacefilename';
        if ($alterNameFolder) {
            $workspacefilename .= '_' . $alterNameFolder;
        }

        if ( !$isFromWorkspace ) {
            print qq{
                <script type="text/javascript" src="$top_base_url/js/Workspace.js" >
                </script>
            };            
        }

        my $workspace =
          "<a href=\"$main_cgi?section=Workspace\">My Workspace</a>";
        print "<h2>Save " . $what . "to My Workspace</h2>";
        printHint(
            "Even though you can save large amount of data into workspace, many profile functions will timeout for extremely large workspace datasets"
        );
        print "<p>";
        print "$text $workspace.<br/>";
        print "(<i>Special characters in file name will be removed "
          . "and spaces converted to _ </i>)";
        print "<br/><br/>";

        if ($saveAllName) {
            print
                "<b>Note:</b> Save all will also save items not displayed in the UI.<br/><br/>\n";
        }

        my $radioBtnGrp;
        if ($folder) {
            my $wsSaveMode         = 'ws_save_mode';
            my $workspacefilename  = 'workspacefilename';
            my $selectedwsfilename = 'selectedwsfilename';
            if ($alterNameFolder) {
                $wsSaveMode         .= '_' . $alterNameFolder;
                $workspacefilename  .= '_' . $alterNameFolder;
                $selectedwsfilename .= '_' . $alterNameFolder;
            }
            $radioBtnGrp = $wsSaveMode;    # Used for onClick in Submit button
            print "<input type='radio' name='$wsSaveMode' value='save' checked />\n";

            print "Save to File name:" . nbsp(1);
            print "<input id='workspace' type='text' "
              . "name='$workspacefilename' "
              . "size='$filename_size' maxLength='$filename_len' "
              . "title='All special characters will be removed "
              . "and spaces converted to _' /><br/>";

            my $sid = getContactOid();
            opendir( DIR, "$workspace_dir/$sid/$folder" );
            my @files = readdir(DIR);
            closedir(DIR);

            my @existing_sets = ();
            for my $x (@files) {
                if ( $x eq "." || $x eq ".." || $x =~ /~$/ ) {
                    next;
                }
                push @existing_sets, ($x);
            }
            if ( scalar(@existing_sets) > 0 ) {
                print
                  "<input type='radio' name='$wsSaveMode' value='append' />\n";
                print "Append to the following $folder set: <br/>\n";
                print
                  "<input type='radio' name='$wsSaveMode' value='replace' />\n";
                print "Replacing the following $folder set: <br/>\n";
                print nbsp(5);
                print "<select name='$selectedwsfilename'>\n";
                
                my @sorted_existing_sets = sort @existing_sets;
                for my $x (@sorted_existing_sets) {
                    print "<option value='$x'>$x</option>\n";
                }
                print "</select>\n";
            }
        }
        else {
            print "File name:<br/>\n";
            print "<input id='workspace' type='text' "
              . "name='$workspacefilename' "
              . "size='$filename_size' maxLength='$filename_len' "
              . "title='All special characters will be removed "
              . "and spaces converted to _' />";
        }

        print "<br/>";
        if ($saveSelectedName) {
            if ( ! $saveSelectButtonName ) {
                $saveSelectButtonName = "Save Selected to Workspace";
            }
            if ($selectFieldName) {
                if ($selectFieldParamName) {
                    print submit(
                        -name    => $saveSelectedName,
                        -value   => $saveSelectButtonName,
                        -class   => "medbutton",
                        -onClick => "return setParamAndCheckSelectedAndFileName('$workspacefilename', '$radioBtnGrp', '$selectFieldName', '$selectFieldParamName');"
                    );                    
                }
                else {
                    print submit(
                        -name    => $saveSelectedName,
                        -value   => $saveSelectButtonName,
                        -class   => "medbutton",
                        -onClick => "return checkSelectedAndFileName('$workspacefilename', '$radioBtnGrp', '$selectFieldName');"
                    );                    
                }
            }
            else {
                if ( $saveSelectedName eq "_section_Workspace_saveGenomeSetCreation" ) {
                    print submit(
                        -name    => $saveSelectedName,
                        -value   => $saveSelectButtonName,
                        -class   => "medbutton",
                        -onClick => "return myValidationBeforeSubmit1('$workspacefilename', '$radioBtnGrp', 'selectedGenome1', '1', '', '');"
                    );                    
                }
                else {
                    print submit(
                        -name    => $saveSelectedName,
                        -value   => $saveSelectButtonName,
                        -class   => "medbutton",
                        -onClick => "return checkFileName('$workspacefilename', '$radioBtnGrp');"
                    );                    
                }
            }
        }

        if ($saveAllName) {
            if ($saveSelectedName) {
                print nbsp(1);
            }
            if ( ! $saveAllButtonName ) {
                $saveAllButtonName = "Save All to Workspace";
            }
            print submit(
                -name    => $saveAllName,
                -value   => $saveAllButtonName,
                -class   => "medbutton",
                -onClick => "return checkFileName('$workspacefilename', '$radioBtnGrp');"
            );
        }
        print "</p>\n";
    }
}

#############################################################################
# printFuncGeneSaveToWorkspace
#############################################################################
sub printFuncGeneSaveToWorkspace {
    my ( $folder, $isSet ) = @_;
    
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
        print submit(
            -name    => $name,
            -value   => "Save Selected Function to Workspace",
            -class   => "lgbutton",
            -onClick =>
              "return checkSelectedAndFilled('workspacefilename', 'func_id');"
        );

        print nbsp(1);
        if ( $folder && !$isSet ) {
            if ( $folder eq $GENOME_FOLDER ) {
                $name = "_section_Workspace_saveSelectedGenomeFuncGenes";
            }
            elsif ( $folder eq $SCAF_FOLDER ) {
                $name = "_section_Workspace_saveSelectedScaffoldFuncGenes";
            }
            else {
                $name = "_section_Workspace_saveFuncGenes";
            }
        }
        else {
            $name = "_section_Workspace_saveFuncGenes";
        }
        print submit(
            -name    => $name,
            -value   => "Save Genes of Selected Function to Workspace",
            -class   => "lgbutton",
            -onClick =>
              "return checkSelectedAndFilled('workspacefilename', 'func_id');"
        );

        print "</p>\n";
    }
}

#############################################################################
# printExtFuncGeneSaveToWorkspace
#############################################################################
sub printExtFuncGeneSaveToWorkspace {
    my ( $saveSelectedName, $saveAllName ) = @_;
    my $contact_oid = getContactOid();
    return if ( !$contact_oid );

    # workspace
    if ( $user_restricted_site && !$public_nologin_site ) {
        print "<h2>Save to My Workspace</h2>";
        print qq{
            <p>
            Save selected genes of selected functions to
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
        my $name = "_section_Workspace_saveExtFuncGenes";
        print submit(
            -name  => $name,
            -value => "Save Genes of Selected Function to Workspace",
            -class   => "lgbutton",
            -onClick =>
              "return checkSelectedAndFilled('workspacefilename', 'func_id');"
        );

        print "</p>\n";
    }
}

##################################################################
# printSaveBcToWorkspace
##################################################################
sub printSaveBcToWorkspace {
    my ( $select_id_name ) = @_;

    ## save to workspace
    if ($user_restricted_site) {
        printCartSaveToWorkspace(
            "Save <b>selected BC IDs</b> to",
            "_section_Workspace_saveBcCart", 
            '', '', '', '', 
            $select_id_name
        );
    }
}



##################################################################
# getContactImgGroupCnt: get group counts
##################################################################
sub getContactImgGroupCnt {
    my $cnt = 0;

    if ( ! $img_group_share ) {
    	return 0;
    }

    my $contact_oid = WebUtil::getContactOid();
    if ( ! $contact_oid ) {
    	return $cnt;
    }

    my $dbh = dbLogin();
    my $sql = qq{
        select cig.img_group 
        from contact_img_groups cig 
        where cig.contact_oid = ? 
    };
    my $cur = execSql( $dbh, $sql, $verbose, $contact_oid );
    for (;;) { 
        my ( $group_id ) = $cur->fetchrow();
        last if ! $group_id; 
    	$cnt++;
    } 
    $cur->finish();

    return $cnt;
}


##################################################################
# getContactImgGroups: get all IMG groups for contact
##################################################################
sub getContactImgGroups {
    my %group_h;

    my $contact_oid = WebUtil::getContactOid();
    if ( ! $contact_oid ) {
    	return %group_h;
    }

    my $sql = qq{
        select g.group_id, g.group_name 
        from img_group g, contact_img_groups cig 
        where cig.contact_oid = ? 
        and g.group_id = cig.img_group
    };

    my $dbh = dbLogin();
    my $cur = execSql( $dbh, $sql, $verbose, $contact_oid );
    for (;;) { 
        my ( $group_id, $group_name ) = $cur->fetchrow();
        last if ! $group_id;
 
        $group_h{$group_id} = $group_name; 
    } 
    $cur->finish();

    return %group_h;
}

sub getContactImgGroupsOptions {

    my %group_h = getContactImgGroups();
    my @group_names = values %group_h;
    my @workspaceSharingVals = ();
    push(@workspaceSharingVals, 'No');
    push(@workspaceSharingVals, 'All');
    push(@workspaceSharingVals, @group_names);

    return (\@workspaceSharingVals);
}

######################################################################
# getShareToGroups: workspace set shared to groups
#
# return hash:
#    key = data set name
#    value = group1_id,group1_name \t group2_id,group2_name \t ...
######################################################################
sub getShareToGroups {
    my ($ws_type) = @_;

    my %share_h;

    my $contact_oid = WebUtil::getContactOid();
    if ( ! $contact_oid || ! $ws_type || ! $img_group_share ) {
    	return %share_h;
    }

    my $sql = qq{
        select g.group_id, g.group_name, w.data_set_name 
        from img_group g, contact_workspace_group w 
        where w.contact_oid = ? 
        and w.data_set_type = ? 
        and w.group_id = g.group_id 
    };
    my @bindList = ( $contact_oid, $ws_type );

    my $dbh = dbLogin();
    my $cur = execSql( $dbh, $sql, $verbose, @bindList );
    for (;;) { 
        my ( $group_id, $group_name, $data_set_name ) = $cur->fetchrow();
        last if ! $group_id;

    	if ( $share_h{$data_set_name} ) {
    	    $share_h{$data_set_name} .= "\t" . $group_id . "," . $group_name;
    	}
    	else {
    	    $share_h{$data_set_name} = $group_id . "," . $group_name;
    	}
    } 
    $cur->finish();

    return %share_h;
}


##################################################################
# getShareFromGroups: workspace set shared from groups
#
# return hash:
#    key: contact_oid | data_set_name
#    value: group_id \t group_name \t contact_name
##################################################################
sub getShareFromGroups {
    my ($ws_type, $dataset_name, $groupSharingDisplay, $delim) = @_;

    my %share_h;

    my $contact_oid = WebUtil::getContactOid();
    if ( ! $contact_oid || ! $ws_type || ! $img_group_share ) {
	   return %share_h;
    }

    my @bindList = ( $contact_oid, $ws_type );

    my $datasetNameClause;
    if ( $dataset_name ) {
        $datasetNameClause = " and w.data_set_name = ? ";
        push(@bindList, $dataset_name);
    }

    my $groupSharingClause;
    if ( $groupSharingDisplay && $groupSharingDisplay ne 'No' && $groupSharingDisplay ne 'All') {
        $groupSharingClause = " and g.group_name = ? ";
        push(@bindList, $groupSharingDisplay);
    }

    my $sql = qq{
        select g.group_id, g.group_name, w.data_set_name,
             c.contact_oid, c.name
        from img_group g, 
           contact_img_groups cig,
           contact_workspace_group w,
           contact c
        where cig.contact_oid = ? 
        and cig.img_group = g.group_id
        and w.data_set_type = ?
        and w.group_id = g.group_id
        and w.contact_oid = c.contact_oid
        $datasetNameClause
        $groupSharingClause
    };

    my $dbh = dbLogin();
    my $cur = execSql( $dbh, $sql, $verbose, @bindList );
    for (;;) { 
        my ( $group_id, $group_name, $data_set_name, $c_oid, $c_name )
	    = $cur->fetchrow();
        last if ! $group_id;

    	if ( $c_oid == $contact_oid ) {
    	    # my own
    	    next;
    	}

        $delim = $ownerFilesetDelim  if ( !$delim  );
    	my $key = $c_oid . $delim . $data_set_name;
    	$share_h{$key} = $group_id . "\t" . $group_name . "\t" . $c_name;
    } 
    $cur->finish();

    return %share_h;
}

sub splitOwnerFileset {
    my ( $sid, $ownerFileset, $delim ) = @_;

    my $owner = $sid;
    my $file_set_name = $ownerFileset;

    my ( $owner_id, $set_name );
    if ( $delim && $delim eq $ownerFilesetDelim_message ) {
        ( $owner_id, $set_name ) = split( /\:\:\:\:/, $ownerFileset, 2 );
    } 
    else {
        ( $owner_id, $set_name ) = split( /\|/, $ownerFileset, 2 );        
    }
    if ( $owner_id && WebUtil::isInt($owner_id) && $set_name ) { 
        $owner = $owner_id; 
        $file_set_name = $set_name; 
    } 

    return ( $owner, $file_set_name );
}

sub validateOwnerFileset {
    my ( $sid, $owner, $file_set_name, $delim, $folder ) = @_;

    if ( $owner && $owner != $sid ) { 
        $delim = $ownerFilesetDelim  if ( !$delim  );
        ## check permission
        my $k = $owner . $delim . $file_set_name;
        my %share_h = getShareFromGroups($folder, $file_set_name, '', $delim);
        if ( ! $share_h{$k} ) {
            WebUtil::webError("No permission to access $k");
            return; 
        }
    } 

}

sub splitAndValidateOwnerFileset {
    my ( $sid, $ownerFileset, $delim, $folder ) = @_;

    my ( $owner, $file_set_name ) = splitOwnerFileset( $sid, $ownerFileset, $delim );
    validateOwnerFileset( $sid, $owner, $file_set_name, $delim, $folder );

    return ( $owner, $file_set_name );
}

sub getOwnerFilesetName {
    my ( $owner_id, $set_name, $delim, $sid ) = @_;

    my $file_set_name;
    if ( $sid && $owner_id == $sid ) {
        $file_set_name = $set_name;
    }
    else {
        $file_set_name = getOwnerFilesetFullName( $owner_id, $set_name, $delim );
    }

    return ( $file_set_name );
}

sub getOwnerFilesetFullName {
    my ( $owner_id, $set_name, $delim ) = @_;

    my $full_name = $set_name;
    if ( $owner_id && WebUtil::isInt($owner_id) ) {
        $delim = $ownerFilesetDelim  if ( !$delim  );
        $full_name = $owner_id . $delim . $set_name;            
    }

    return ( $full_name );
}

sub getAllInputFiles {
    my ($sid, $toPrintHidden) = @_;

    my @all_files = (); 
    my @filenames = param('filename'); 
    for my $filename (@filenames) { 
        WebUtil::checkFileName($filename);
        $filename = WebUtil::validFileName($filename); 
        #push @all_files, ( $sid . $ownerFilesetDelim . $filename );
        push @all_files, ( $filename );
        print hiddenVar( "input_file", $filename ) if ( $toPrintHidden );
    } 
    my @share_filenames = param('share_filename');
    for my $ownerFilename (@share_filenames) {
        my ($c_oid, $filename) = splitOwnerFileset( '', $ownerFilename );
        if ( ! $c_oid || ! WebUtil::isInt($c_oid) || ! $filename ) {
            next;
        }
        WebUtil::checkFileName($filename);
        $filename = WebUtil::validFileName($filename); 
        my $ownerFilename_new = $c_oid . $ownerFilesetDelim . $filename;
        push @all_files, ( $ownerFilename_new ); 
        print hiddenVar( "share_input_file", $ownerFilename_new ) if ( $toPrintHidden );
    }

    return (@all_files);
}

###############################################################################
# printGenomeListForm
###############################################################################
sub printGenomeListForm {
    my ($numTaxon, $maxSelected, $noMetagenome) = @_;
    $maxSelected = -1 if $maxSelected eq "";

    my $hideViruses = getSessionParam("hideViruses");
    $hideViruses = ($hideViruses eq "" || $hideViruses eq "Yes") ? 0 : 1;
    my $hidePlasmids = getSessionParam("hidePlasmids");
    $hidePlasmids = ($hidePlasmids eq "" || $hidePlasmids eq "Yes") ? 0 : 1;
    my $hideGFragment = getSessionParam("hideGFragment");
    $hideGFragment = ($hideGFragment eq "" || $hideGFragment eq "Yes") ? 0 : 1;

    if ( $enable_genomelistJson ) {
        my $template = HTML::Template->new( filename => "$base_dir/genomeHeaderJson.html" );
        $template->param( base_url => $base_url );
        $template->param( YUI      => $YUI );
        print $template->output;
    }

    my $xml_cgi = $cgi_url . '/xml.cgi';
    my $template = HTML::Template->new
        ( filename => "$base_dir/genomeJsonOneDiv.html" );

    $template->param( isolate      => 1 );
    $template->param( gfr          => $hideGFragment );
    $template->param( pla          => $hidePlasmids );
    $template->param( vir          => $hideViruses );
    $template->param( isolate      => 1 );
    $template->param( all          => 1 );
    $template->param( cart         => 1 );
    $template->param( xml_cgi      => $xml_cgi );
    $template->param( prefix       => '' );
    $template->param( maxSelected1 => $maxSelected );

    if ( $include_metagenomes && !$noMetagenome ) {
        #$template->param( selectedGenome1Title => '' );
        $template->param( include_metagenomes => 1 );
        #$template->param( selectedAssembled1  => 1 );
    }

    my $s = "";
    $template->param( mySubmitButton => $s );
    print $template->output;

    GenomeListJSON::showGenomeCart($numTaxon);
}

sub getDisplaySize {
    my ( $size ) = @_;

    my ($quot, $rem);
    my $cnt = 0;
    while ( $size >= 1024 ) {
        $cnt++;
        ($quot, $rem) = getQuotRem( $size );
        $size = $quot;
        
        if ( $cnt >= 8 ) {
            last;
        }
    }

    my $remainder;
    $remainder = '.' . $rem if ( $rem );
    
    my @units = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
    my $unit = $units[$cnt];
    my $display_size = $size . $remainder . ' ' . $unit;
    
    return $display_size;
}

sub getQuotRem {
    my ( $size ) = @_;

    my $rem = $size % 1024;
    my $quot = ($size - $rem) / 1024;
    
    return ($quot, $rem);
}


1;
