############################################################################
# web services package using xml.cgi xml.pl
# $Id: Check.pm 36954 2017-04-17 19:34:04Z klchu $
############################################################################
package Check;
my $section = "Check";

use strict;
use CGI qw( :standard );
use Data::Dumper;
use DBI;
use WebConfig;
use WebUtil;

$| = 1;

my $env      = getEnv();
my $main_cgi = $env->{main_cgi};
my $verbose  = $env->{verbose};
my $base_url = $env->{base_url};

sub printWebPageHeader {
    my($self) = @_;
    print header( -type => "text/html" );
}

sub dispatch {
    my $page = param("page");
    if ( $page eq "protein" ) {
         # ncbi_protein_seq_accid=NP_665742
        checkprotein();
    }
}

sub checkprotein {
    my $id = param("ncbi_protein_seq_accid");

    my $sql = qq{
        select gene_oid
        from gene
        where protein_seq_accid = ?
     };

    my $dbh = dbLogin();
    my $cur = execSql( $dbh, $sql, $verbose, $id );
    my ( $gene_oid ) =   $cur->fetchrow();
    $cur->finish();
    #$dbh->disconnect();

    if($gene_oid ne "") {
        print "$gene_oid";
    } else {
        print "0";
    }

}

1;
