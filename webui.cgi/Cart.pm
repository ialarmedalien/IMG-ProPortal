############################################################################
# img-act web services package, using xml.cgi xml.pl
# $Id: Cart.pm 36954 2017-04-17 19:34:04Z klchu $
############################################################################
package Cart;

use strict;
use CGI qw( :standard );
use Data::Dumper;
use DBI;
use WebConfig;
use WebUtil;
use TaxonDetailUtil;

$| = 1;

my $section = "Cart";
my $env      = getEnv();
my $main_cgi = $env->{main_cgi};
my $verbose  = $env->{verbose};
my $base_url = $env->{base_url};
my $YUI      = $env->{yui_dir_28};

sub getPageTitle {
    return 'My Cart';
}

sub getAppHeaderData {
    my ($self) = @_;
    my @a = ('AnaCart');
    return @a;
}

sub printWebPageHeader {
    my($self) = @_;
    
}


############################################################################
# dispatch - Dispatch loop.
############################################################################
sub dispatch {
    my ( $self, $numTaxon ) = @_;

    my $page = param("page");
    if ( $page eq "addNeighborhood" ) {
        print header( -type => "text/html" );
        addNeighborhood();
    } elsif ( $page eq "removeNeighborhood" ) {
        print header( -type => "text/html" );
        removeNeighborhood();
    } elsif ( $page eq "addGeneCart" ) {
        print header( -type => "text/html" );
        addGeneCart();
    } elsif ( $page eq "removeGeneCart" ) {
        print header( -type => "text/html" );
        removeGeneCart();
    } elsif ( $page eq "genelist" ) {
        printGeneList();
    } elsif ( $page eq "clearneigh" ) {
        clearNeighborhood();
    } elsif ( $page eq "cleargene" ) {
        clearGene();
    }  elsif($page eq "refresh") {
        printTracker();
    } elsif($page eq 'clearAllCarts') {
    	print header( -type => "text/html" );
    	clearAllCarts();
    }
}


sub clearAllCarts {
	require GenomeCart;
	GenomeCart::clearAll();
	
    require ScaffoldCart;
    ScaffoldCart::clearAll();

    require FuncCartStor;
    FuncCartStor::clearAll();

    require GeneCartStor;
    GeneCartStor::clearAll();
	
	if($env->{abc}) {
		require WorkspaceBcSet;
		WorkspaceBcSet::deleteBufferFile();
	}
	
	print "0";
}

sub clearNeighborhood {
    my %hash;
    setSessionParam( "neighborhood", \%hash );
    printTracker();
}

sub clearGene {
    my %hash;;
    setSessionParam( "mygenecart", \%hash );
    printTracker();
}

sub printGeneList {
    my $href = getSessionParam("mygenecart");
    my $size = keys %$href if ( $href ne "" );
    if ( $size > 0 ) {
        my @a;
	my @b;
        foreach my $id ( keys %$href ) {
	    if (isInt($id)) {
		push( @a, $id );
	    } else {
		push( @b, $id );
	    }
        }

	my $dbh = dbLogin();
	use HtmlUtil;
	HtmlUtil::printGeneListHtmlTable
	    ( "Gene Ortholog Neighborhoods - Selected Genes",
	      "", $dbh, \@a, \@b );
    } else {
        WebUtil::webError("You have not selected any genes.");
    }
}

sub getGeneCartSize {
    my $size = 0;
    my $href = getSessionParam("mygenecart");
    $size = keys %$href if ( $href ne "" );
    return $size;
}

sub removeGeneCart {
    my $gene_oid = param("gene_oid");
    my $href = getSessionParam("mygenecart");

    delete $href->{$gene_oid};
    setSessionParam( "mygenecart", $href );
    printTracker();
}

sub addGeneCart {
    my $gene_oid = param("gene_oid");
    my $href = getSessionParam("mygenecart");
    $href->{$gene_oid} = $gene_oid;

    setSessionParam( "mygenecart", $href );
    printTracker();
}

sub getNeighborhoodSize {
    my $size = 0;
    my $href = getSessionParam("neighborhood");
    $size = keys %$href if ( $href ne "" );
    return $size;
}

sub removeNeighborhood {
    my $gene_oid = param("gene_oid");
    my $href = getSessionParam("neighborhood");

    delete $href->{$gene_oid};
    setSessionParam( "neighborhood", $href );
    printTracker();
}

sub addNeighborhood {
    my $gene_oid = param("gene_oid");
    my $href = getSessionParam("neighborhood");
    $href->{$gene_oid} = $gene_oid;

    setSessionParam( "neighborhood", $href );
    printTracker();
}

sub printTracker {
    my $size  = getNeighborhoodSize();
    my $size2 = getGeneCartSize();
    print qq{
        <p>
        <u>Selected</u>: Neighborhoods = $size &nbsp;&nbsp; Genes = $size2
        </p>
    };
}

1;
