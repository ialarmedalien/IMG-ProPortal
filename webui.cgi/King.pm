############################################################################
# King.pm - 3D applet for PCA, PCoA, NMDR, etc.
#     -- anna 6/25/2012
# $Id: King.pm 36881 2017-03-28 18:53:21Z aratner $
############################################################################
package King;
 
use strict; 
use CGI qw( :standard );
use WebConfig; 
use WebUtil; 

my $env = getEnv(); 
my $main_cgi = $env->{ main_cgi }; 
 
sub plotFile { 
    my ($inputKingFile, $set2scafs_href, $isSet) = @_;
    $isSet = 0 if !$isSet;
    my $plot_data = getPlotDataJSON($inputKingFile, $set2scafs_href, $isSet);
    printChart3D($plot_data, $isSet);
} 

# writes the input jsondata file
sub getPlotDataJSON {
    my ($inputKingFile, $set2scafs_href, $isSet) = @_;
    $set2scafs_href = 0 if !$isSet;

    my $header;
    my $xlabel;
    my $ylabel;
    my $zlabel;

    my %s2set; # anna: need a map of scaffold_oid:set
    my $scafSets;

    if ($set2scafs_href) {
	$scafSets = "\"sets\": [";
        foreach my $x (keys %$set2scafs_href) {
	    $scafSets .= "\"$x\",";

            my $scafs_ref = $set2scafs_href->{$x};
            foreach my $scaf_oid (@$scafs_ref) {
		# same scaffold maybe in more than one set
		if (exists $s2set{$scaf_oid}) {
		    $s2set{$scaf_oid} .= ",$x";
		} else {
		    $s2set{$scaf_oid} = $x;
		}
            }
        }
	chop $scafSets;
	$scafSets .= "]";
    }

    my $scaffolds = "\"data\": [";

    my $max_pc1 = -1000000000;
    my $max_pc2 = -1000000000; 
    my $max_pc3 = -1000000000;
    my $min_pc1 = 1000000000;
    my $min_pc2 = 1000000000; 
    my $min_pc3 = 1000000000; 
 
    # inputKingFile is generated by plotScaffolds.R for Kmer:
    my $rfh = newReadFileHandle( $inputKingFile, "king-plotFile" );
    my $count = 0;

    while( my $s = $rfh->getline() ) {
        chomp $s;
        $count++;

        if ($count == 1) {
            $header = $s;
        } elsif ($count == 2) {
            $xlabel = $s;
        } elsif ($count == 3) {
            $ylabel = $s;
        } elsif ($count == 4) {
            $zlabel = $s;
        }

        next if ($count < 5);
        my( $id, $range, $lineage, $pc1, $pc2, $pc3, $connect ) = split( /\t/, $s );
        my ($start, $end) = split("-", $range);
        my $length = $end + 30000; 
        my $url_fragm =
	    "&start_coord=$start&end_coord=$end"
	  . "&seq_length=$length&scaffold_oid=";

        $min_pc1 = $min_pc1 < $pc1 ? $min_pc1 : $pc1;
        $min_pc2 = $min_pc2 < $pc2 ? $min_pc2 : $pc2;
        $min_pc3 = $min_pc3 < $pc3 ? $min_pc3 : $pc3;
        $max_pc1 = $max_pc1 > $pc1 ? $max_pc1 : $pc1;
        $max_pc2 = $max_pc2 > $pc2 ? $max_pc2 : $pc2;
        $max_pc3 = $max_pc3 > $pc3 ? $max_pc3 : $pc3;

        my ($domain, $phylum) = split(":", $lineage);
        my $d = substr( $domain, 0, 1 );

	my $points .= "$pc1,$pc2,$pc3";
	#my $ptLabel = "\"[$lineage]"." $range\"";
	my $ptLabel = "\"[$lineage]\"";
	$scaffolds .= 
	     "{\"id\": \"$id\","
	    . "\"url_fragm\":\"$url_fragm\","
	    . "\"range\":\"$range\","
	    . "\"coords\": [$points],"
	    . "\"label\": $ptLabel";

        my $set = "";
        if ($set2scafs_href) {
            my @sids = split("-", $id);
            # metagenome taxon_oid data_type scaffold
            my $scfid = join(" ", @sids);
            $set = $s2set{ $scfid };
	    my @sets = split(",", $s2set{ $scfid });
	    if (scalar @sets > 1) {

	    }
	    $scaffolds .= ",\"set\": \"$set\"";
        }
	$scaffolds .= "},";
    }
    close $rfh; 

    print "<h2>$header</h2>";

    chop $scaffolds;
    $scaffolds .= " ]";

    my $pc1lbl = "PC1";
    if ($xlabel ne "") {
        $pc1lbl = $xlabel;
    }
    my $pc2lbl = "PC2";
    if ($ylabel ne "") {
        $pc2lbl = $ylabel;
    }
    my $pc3lbl = "PC3";
    if ($zlabel ne "") {
        $pc3lbl = $zlabel;
    }

    my $cart_url = "$main_cgi?section=ScaffoldCart&page=addToScaffoldCart&scaffolds=";
    my $cartlink = "\"cart_url\": \"$cart_url\"";

    my $set_url = "$main_cgi?section=WorkspaceScafSet&page=showDetail&folder=scaffold&filename=";
    my $setlink = "\"set_url\": \"$set_url\"";

    my $item_url = "$main_cgi?section=ScaffoldGraph&color=cog";
    my $itemlink = "\"item_url\": \"$item_url\"";

    my $maxes = "\"maxes\": [ $max_pc1,$max_pc2,$max_pc3 ]";
    my $mins = "\"mins\": [ $min_pc1,$min_pc2,$min_pc3 ]";
    my $axesLabels = "\"axesLabels\": [ \"$pc1lbl\",\"$pc2lbl\",\"$pc3lbl\" ]";

    my $jsondata = "{".$cartlink.",".$itemlink.",".$setlink.",".$maxes.",".$mins.",".$axesLabels;
    $jsondata .= ",".$scafSets if $isSet;
    $jsondata .= ",".$scaffolds;
    $jsondata .= "}";

    return $jsondata;
}

sub printChart3D {
    my( $pca_data, $isSet ) = @_;
    print qq{
      <script src='/js/d3.min.js'></script>
      <script src='/js/highcharts.js'></script>
      <script src='/js/highcharts-3d.js'></script>
      <script src='/js/highcharts-export.js'></script>
      <script src='/js/jquery-2.0.3.min.js'></script>
      <script src='/js/chart3d.js'></script>
      <div id="chart3d" style="height: 450px; width: 800px;"></div>
      <script>
          window.onload = drawChart3D("chart3d", $pca_data, $isSet);
      </script>
    };
    print "<br/>"; # for reset button
    my $url = "http://www.highcharts.com/"; 
    print "<p>This chart is generated using ".alink($url, "Highcharts")."<br/>";
}


1;

