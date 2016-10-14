############################################################################
# TaxonTarDir.pm - Wrapper for reading genome pair files from either
#     direct taxon1-taxon2 file for from an aggregate taxon1 tar file.
#    The aggregate tar file reduces the number of inodes/files
#    in the file system.
#    This has later been modified to be an API for zip files also.
#    --es 02/14/11
# $Id: TaxonTarDir.pm 36260 2016-09-29 19:36:01Z klchu $
############################################################################
package TaxonTarDir;

use strict;
use CGI qw( :standard );
use WebConfig;
use WebUtil;
use Data::Dumper;
use Command;

my $env                      = getEnv();
my $avagz_batch_dir          = $env->{avagz_batch_dir};
my $myimg_job                = $env->{myimg_job};
my $myimg_jobs_dir           = $env->{myimg_jobs_dir};
my $genomePair_zfiles_dir    = $env->{genomePair_zfiles_dir};
my $otf_phyloProfiler_method = $env->{otf_phyloProfiler_method};
my $blastall_bin             = $env->{blastall_bin};
my $usearch_bin              = $env->{usearch_bin};
my $taxon_faa_dir            = $env->{taxon_faa_dir};
my $cgi_tmp_dir              = $env->{cgi_tmp_dir};
my $sandbox_blast_data_dir   = $env->{sandbox_blast_data_dir};

############################################################################
# getGenomePairData
############################################################################
sub getGenomePairData {
    my ( $taxon1, $taxon2, $outRows_aref, $silent ) = @_;
    my $verbose = 1 if !$silent;

    ## Untaint.
    $taxon1 =~ /([0-9]+)/;
    $taxon1 = $1;
    $taxon2 =~ /([0-9]+)/;
    $taxon2 = $1;

    my $archiveDir = $avagz_batch_dir;

    my $my_job_id = param("my_job_id");
    $my_job_id = sanitizeInt($my_job_id)
      if $my_job_id > 0;
    my $taxonDir = "$archiveDir/$taxon1";
    my $tarFile  = "$archiveDir/$taxon1.tar";

    my $myJobZipFile;
    if ( $myimg_job && $my_job_id > 0 ) {
        $myJobZipFile = "$myimg_jobs_dir/phyloProf/$my_job_id" . "/genomePair.zfiles/$taxon1.zip";
        webLog("Using myJobZipFile='$myJobZipFile'\n");
    }

    if ( $taxon2 eq "all" ) {
        if ( -e $tarFile ) {
            getTarFile( $tarFile, $outRows_aref );
        }
        if ( -e $taxonDir ) {
            my @files = dirList($taxonDir);
            for my $f (@files) {
                my $fpath = "$taxonDir/$f";
                getGzFile( $fpath, $outRows_aref );
            }
        }
    } elsif ( $otf_phyloProfiler_method eq "usearch" ) {

        # TODO if usearch on just do it - ken
        #print "<br/><b>doing usearch otf</b><br/>";
        my $genomePair = "$taxon1-$taxon2";
        getOtfHits( $genomePair, $outRows_aref, $verbose );
    } else {
        my $genomePair     = "$taxon1-$taxon2";
        my $extractFile    = "$taxon1/$genomePair.m8.txt.gz";
        my $genomePairFile = "$taxonDir/$genomePair.m8.txt.gz";
        my $zipFile        = "$genomePair_zfiles_dir/$taxon1.zip";
        $zipFile = $myJobZipFile if $myJobZipFile ne "";
        if ( $genomePair_zfiles_dir ne "" ) {
            if ( -e $zipFile ) {
                getZipFile( $zipFile, $genomePair, $outRows_aref );
            } else {
                $otf_phyloProfiler_method = "usearch"
                  if !$otf_phyloProfiler_method;
                getOtfHits( $genomePair, $outRows_aref, $verbose );
            }
        } elsif ( -e $genomePairFile ) {
            getGzFile( $genomePairFile, $outRows_aref );
        } elsif ( $otf_phyloProfiler_method ne "" ) {
            getOtfHits( $genomePair, $outRows_aref, $verbose );
        } else {
            getTarFile( $tarFile, $extractFile, $outRows_aref );
        }
    }
}

############################################################################
# getGzFile  - Get rows for taxon1-taxon2.m8.gz files.
############################################################################
sub getGzFile {
    my ( $inFile, $outRows_aref ) = @_;

    return if !-e $inFile;

    WebUtil::unsetEnvPath();

    my $cmd = "/bin/zcat $inFile";
    webLog("+ $cmd\n");
    my $rfh = newCmdFileHandle( $cmd, "getGzFile" );
    while ( my $s = $rfh->getline() ) {
        chomp $s;
        push( @$outRows_aref, $s );
    }
    close $rfh;

    WebUtil::resetEnvPath();
}

############################################################################
# getTarFile - Get data from taxon1.tar  file.
############################################################################
sub getTarFile {
    my ( $tarFile, $extractFile, $outRows_aref ) = @_;

    return if !-e $tarFile;

    if ( $extractFile eq "" ) {
        WebUtil::unsetEnvPath();
        my $cmd = "tar -f $tarFile -x -O | /bin/zcat";
        webLog("+ $cmd\n");
        my $rfh = newCmdFileHandle( $cmd, "getTarFile" );
        while ( my $s = $rfh->getline() ) {
            chomp $s;
            push( @$outRows_aref, $s );
        }
        close $rfh;
        WebUtil::resetEnvPath();
        return;
    }
    WebUtil::unsetEnvPath();
    my $cmd = "/bin/tar -f $tarFile -t";
    webLog("+ $cmd\n");
    my %files;
    my $rfh = newCmdFileHandle( $cmd, "getTarFile" );
    while ( my $s = $rfh->getline() ) {
        chomp $s;
        $files{$s}++;
    }
    close $rfh;
    if ( !$files{$extractFile} ) {
        WebUtil::unsetEnvPath();
        return;
    }
    my $n   = $files{$extractFile};
    my $cmd = "/bin/tar -f $tarFile -x $extractFile --occurrence=$n -O | /bin/zcat";
    my $rfh = newCmdFileHandle( $cmd, "getTarFile" );
    while ( my $s = $rfh->getline() ) {
        chomp $s;
        push( @$outRows_aref, $s );
    }
    close $rfh;
    WebUtil::resetEnvPath();
}

############################################################################
# getZipFile - Get data from taxon1.zip  file.
############################################################################
sub getZipFile {
    my ( $zipFile, $genomePair, $outRows_aref ) = @_;

    webLog("Reading '$zipFile':'$genomePair'\n");
    if ( !-e $zipFile ) {
        webLog("zip file '$zipFile' does not exist\n");
        return;
    }

    WebUtil::unsetEnvPath();
    my $count = 0;
    my $rfh = newUnzipFileHandle( $zipFile, $genomePair, "getZipFile" );
    while ( my $s = $rfh->getline() ) {
        chomp $s;
        $count++;
        push( @$outRows_aref, $s );
    }
    close $rfh;
    webLog("getZipFile: $count rows read\n");
    WebUtil::resetEnvPath();
}

############################################################################
# getOtfHits - Get "on the fly" hits.
############################################################################
sub getOtfHits {
    my ( $genomePair, $outRows_aref, $verbose ) = @_;

    my ( $taxon1, $taxon2 ) = split( /-/, $genomePair );
    $taxon1 = sanitizeInt($taxon1);
    $taxon2 = sanitizeInt($taxon2);

    my $taxon1Faa = "$taxon_faa_dir/$taxon1.faa";
    my $taxon2Faa = "$taxon_faa_dir/$taxon2.faa";

    my $taxon2Db = "$taxon_faa_dir/$taxon2.faa.blastdb/$taxon2";
    $taxon2Db = "$sandbox_blast_data_dir/$taxon2/$taxon2" . '.faa' if ( $sandbox_blast_data_dir ne '' );


    my $tmpFile = Command::createSessionDir();

    #my $tmpFile   = "$cgi_tmp_dir/$genomePair.$$.m8.txt";
    $tmpFile = "$tmpFile/$genomePair.$$.m8.txt";

    if(-e $tmpFile) {
        # Profiler -> single genes
        # this should not be possible for metagenomes?
        # I saw 4 commands exactly the same process ids, with different homologs in
        
       # bug the cart shows metagenoms
        

# wwwimg   28657 28321  0 06:38 ?        00:00:00 /usr/common/usg/languages/perl/5.16.0/bin/perl /global/u1/w/wwwimg/gpint501/apache/cgi-bin/runCmd/cmd.cgi
# wwwimg   28659 28657 99 06:38 ?        06:43:49 /global/dna/projectdirs/microbial/img/webui/bin/x86_64-linux/usearch64 --query /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006420/3300006420.a.faa --db /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006421/3300006421.a.faa --accel 0.8 --quiet --trunclabels --iddef 4 --evalue 1e-1 --blast6out /global/projectb/scratch/img/www-data/service/tmp/gpweb36_37_shared/mer/1931f5a5a98d627d861728a5e2414a4d/3300006420-3300006421.50808.m8.txt
# wwwimg   28807 28321  0 06:41 ?        00:00:00 /usr/common/usg/languages/perl/5.16.0/bin/perl /global/u1/w/wwwimg/gpint501/apache/cgi-bin/runCmd/cmd.cgi
# wwwimg   28809 28807 99 06:41 ?        06:40:50 /global/dna/projectdirs/microbial/img/webui/bin/x86_64-linux/usearch64 --query /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006420/3300006420.a.faa --db /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006465/3300006465.a.faa --accel 0.8 --quiet --trunclabels --iddef 4 --evalue 1e-1 --blast6out /global/projectb/scratch/img/www-data/service/tmp/gpweb36_37_shared/mer/1931f5a5a98d627d861728a5e2414a4d/3300006420-3300006465.50808.m8.txt
#        
#wwwimg   29039 28321  0 06:44 ?        00:00:00 /usr/common/usg/languages/perl/5.16.0/bin/perl /global/u1/w/wwwimg/gpint501/apache/cgi-bin/runCmd/cmd.cgi
#wwwimg   29041 29039 99 06:44 ?        06:37:51 /global/dna/projectdirs/microbial/img/webui/bin/x86_64-linux/usearch64 --query /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006420/3300006420.a.faa --db /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006466/3300006466.a.faa --accel 0.8 --quiet --trunclabels --iddef 4 --evalue 1e-1 --blast6out /global/projectb/scratch/img/www-data/service/tmp/gpweb36_37_shared/mer/1931f5a5a98d627d861728a5e2414a4d/3300006420-3300006466.50808.m8.txt
#
#wwwimg   29418 28321  0 06:47 ?        00:00:00 /usr/common/usg/languages/perl/5.16.0/bin/perl /global/u1/w/wwwimg/gpint501/apache/cgi-bin/runCmd/cmd.cgi
#wwwimg   29420 29418 99 06:47 ?        06:34:51 /global/dna/projectdirs/microbial/img/webui/bin/x86_64-linux/usearch64 --query /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006420/3300006420.a.faa --db /global/projectb/sandbox/IMG/web-data/sandbox.blast.data/3300006468/3300006468.a.faa --accel 0.8 --quiet --trunclabels --iddef 4 --evalue 1e-1 --blast6out /global/projectb/scratch/img/www-data/service/tmp/gpweb36_37_shared/mer/1931f5a5a98d627d861728a5e2414a4d/3300006420-3300006468.50808.m8.txt
        
        WebUtil::webLog("File already exists ========= $tmpFile \n");
        WebUtil::webError("You are already running a similar request!");
    } else {
        WebUtil::webLog("NEW temp File ========= $tmpFile \n");
    }


    my $cmd;
    if ( $otf_phyloProfiler_method eq "blastall" ) {
        ## New BLAST
        $cmd =
            "$blastall_bin/legacy_blast.pl blastall "
          . " -p blastp -i $taxon1Faa -d $taxon2Db "
          . " -e 1e-2 -m 8 -F 'm S' -o $tmpFile -a 16 "
          . " --path $blastall_bin ";

        # --path is needed although fullpath of legacy_blast.pl is
        # specified in the beginning of command! ---yjlin 03/12/2013
    } elsif ( $otf_phyloProfiler_method eq "usearch" ) {
        $cmd =
            "$usearch_bin --query $taxon1Faa --db $taxon2Faa "
          . "--accel 0.8 --quiet --trunclabels --iddef 4 "
          . "--evalue 1e-2 --blast6out $tmpFile";
    } else {
        webDie( "getOtfHits: unknown otf_phyloProfiler_method=" . "'$otf_phyloProfiler_method'\n" );
    }
    webLog("+ $cmd\n");

    my $dbh;
    if ($verbose) {
        $dbh = dbLogin();
        my $name = taxonOid2Name( $dbh, $taxon2 );
        my $m = $otf_phyloProfiler_method;
        print "Compute ($m) against <i>$name</i> ($taxon2) ...\n";
    }
    WebUtil::unsetEnvPath();

    my ( $cmdFile, $stdOutFilePath ) = Command::createCmdFile($cmd);
    Command::startDotThread();
    my $stdOutFile = Command::runCmdViaUrl( $cmdFile, $stdOutFilePath );
    if ( $stdOutFile == -1 ) {
        Command::killDotThread();
        webLog("getOtfHits: ERROR '$cmd' \n");
        webDie("$otf_phyloProfiler_method ERROR \n");
    }
    Command::killDotThread();

    my $count = 0;
    my $rfh = newReadFileHandle( $tmpFile, "getOtfHits" );
    while ( my $s = $rfh->getline() ) {
        chomp $s;
        $count++;
        push( @$outRows_aref, $s );
    }
    close $rfh;
    webLog("getOtfHits: $count rows read\n");
    WebUtil::resetEnvPath();
    unlink($tmpFile);
    if ($verbose) {
        print "($count hits).<br/>\n";
    }

    #$dbh->disconnect() if defined($dbh);
}

#################################################################################
# isSingleCell - Kludge to detect whether a genome is a single cell +BSJ 05/14/12
# no longer used
#################################################################################
sub isSingleCell {
    my ($taxon_oid) = @_;
    my $returnVal;

    my $zipFile = "$genomePair_zfiles_dir/$taxon_oid.zip";

    #print "TaxonTarDir::isSingleCell() zipFile: $zipFile<br/>\n";
    $returnVal = 1 if ( !-e $zipFile );

    return $returnVal;
}

1;
