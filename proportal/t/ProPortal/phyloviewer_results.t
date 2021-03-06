my $dir;
my @dir_arr;

BEGIN {
	$ENV{'DANCER_ENVIRONMENT'} = 'testing';
	use File::Spec::Functions qw( rel2abs catdir );
	use File::Basename qw( dirname basename );
	$dir = dirname( rel2abs( $0 ) );
	while ( 'webUI' ne basename( $dir ) ) {
		$dir = dirname( $dir );
	}
	@dir_arr = map { catdir( $dir, $_ ) } qw( webui.cgi proportal/lib proportal/t/lib );
}

use lib @dir_arr;
use IMG::Util::Import 'Test';
use Dancer2;
use ProPortal::Controller::PhyloViewer::Results;
use Test::MockModule;
use IO::String;
use Bio::TreeIO;

my $got = [
  {
    children => [
      {
        cumul_len => "0.06292",
        length => "0.06292",
        name => "2607817870"
      },
      {
        children => [
          {
            children => [
              {
                cumul_len => "0.05948",
                length => "0.00904",
                name => 637686994
              },
              {
                cumul_len => "0.05921",
                length => "0.00877",
                name => "2607361738"
              }
            ],
            cumul_len => "0.05044",
            length => "0.00237"
          },
          {
            children => [
              {
                cumul_len => "0.06224",
                length => 0,
                name => "2607811795"
              },
              {
                cumul_len => "0.06224",
                length => 0,
                name => "2624154139"
              }
            ],
            cumul_len => "0.06224",
            length => "0.01417"
          }
        ],
        cumul_len => "0.04807",
        length => "0.04807"
      }
    ],
    cumul_len => 0,
    length => 0
  }
];

my $small_pruned = [
  {
    children => [
      {
        cumul_len => "0.06292",
        length => "0.06292",
        name => "2607817870"
      },
      {
        children => [
          {
            children => [
              {
                cumul_len => "0.05948",
                length => "0.00904",
                name => 637686994
              },
              {
                cumul_len => "0.05921",
                length => "0.00877",
                name => "2607361738"
              }
            ],
            cumul_len => "0.05044",
            length => "0.00237"
          },
          {
			cumul_len => "0.06224",
			length => "0.01417",
			children => [
			  {
				cumul_len => "0.06224",
				length => 0,
				name => "2607811795",
			  },
			  {
				cumul_len => "0.06224",
				length => 0,
				name => "2624154139"
			  }
			]
		  }
        ],
        cumul_len => "0.04807",
        length => "0.04807"
      }
    ],
    cumul_len => 0,
    length => 0
  }
];

my $med_pruned = [
  {
    children => [
      {
        children => [
          {
            children => [
              {
                children => [
				  {
					cumul_len => "0.24914",
					length => 0,
					name => 640087144
				  },
				  {
					cumul_len => "0.24914",
					length => 0,
					name => "2608168136"
				  },
				  {
					cumul_len => "0.24914",
					length => 0,
					name => "2624151930"
				  },
                  {
                    cumul_len => "0.24914",
                    length => 0,
                    name => "2626314409"
                  }
                ],
                cumul_len => "0.24914",
                length => "0.0171"
              },
              {
                children => [
				  {
					cumul_len => "0.25609",
					length => 0,
					name => "2608213837"
				  },
				  {
					cumul_len => "0.25609",
					length => 0,
					name => "2608216457"
				  },
                  {
                    cumul_len => "0.25609",
                    length => 0,
                    name => "2608221109"
                  }
                ],
                cumul_len => "0.25609",
                length => "0.02405"
              }
            ],
            cumul_len => "0.23204",
            length => "0.1943"
          },
          {
            cumul_len => "0.18145",
            length => "0.14371",
            name => "2607807999"
          }
        ],
        cumul_len => "0.03774",
        length => "0.03774"
      },
      {
        children => [
		  {
			cumul_len => "0.15988",
			length => 0,
			name => "2607024285"
		  },
		  {
			cumul_len => "0.15988",
			length => 0,
			name => "2607027401"
		  },
          {
            cumul_len => "0.15988",
            length => 0,
            name => "2607028865"
          }
        ],
        cumul_len => "0.15988",
        length => "0.15988"
      }
    ],
    cumul_len => 0,
    length => 0
  }
];

is_deeply( ProPortal::Controller::PhyloViewer::Results::prune_tree_ds( $got ), $small_pruned, 'Checking manually-created pruned tree is the same as autogenerated tree' );



my $tree = parse_tree( small_branch() );

$tree->[0]{children} = ProPortal::Controller::PhyloViewer::Results::prune_tree_ds( $tree->[0]{children} );

is_deeply( $tree, $small_pruned, 'Checking data flow through make_tree_ds and prune_tree_ds' );

my $small_tree = parse_tree( small_branch(), 'make_pruned_tree_ds');
is_deeply( sort_tree( $small_tree ), sort_tree( $small_pruned ), 'Checking simultaneous parsing and pruning' );

my $med_tree = parse_tree( med_branch(), 'make_pruned_tree_ds' );

say 'Medium tree: ' . Dumper $med_tree;
$med_tree = sort_tree( $med_tree );

say 'Medium tree, sorted: ' . Dumper $med_tree;

is_deeply( sort_tree($med_tree), sort_tree($med_pruned), 'Checking medium tree is pruned correctly' );

sub parse_newick {

	my $str = IO::String->new( shift );
	return Bio::TreeIO->new(
		-format => 'newick',
		-fh => $str
	);
}

sub parse_tree {
	my $to_parse = shift;
	my $sub = shift || 'make_tree_ds';
	my $fn = \&{ 'ProPortal::Controller::PhyloViewer::Results::' . $sub };
	my $treeio = parse_newick( $to_parse );
	my $ds;
	my $max = 0;
	while( my $tree = $treeio->next_tree ) {
		push @$ds, {
			length => 0,
			cumul_len => 0,
			children => $fn->(
				root => $tree->get_root_node,
				node => $tree->get_root_node,
				tree => $tree,
				data => {},
				max => \$max
			),
		};
	}
	return $ds;
}

sub small_branch {

	return '( 2607817870:0.06292, ( ( 637686994:0.00904, 2607361738:0.00877) :0.00237, ( 2607811795:0.00000, 2624154139:0.00000) :0.01417) :0.04807) :0.11480';

}

sub med_branch {

	return '( ( ( ( ( ( 640087144:0.00000, 2608168136:0.00000) :0.00000, 2624151930:0.00000) :0.00000, 2626314409:0.00000) :0.01710, ( ( 2608213837:0.00000, 2608216457:0.00000) :0.00000, 2608221109:0.00000) :0.02405) :0.19430, 2607807999:0.14371) :0.03774, ( ( 2607024285:0.00000, 2607027401:0.00000) :0.00000, 2607028865:0.00000) :0.15988) :0.01777'; #) :0.06318) :0.04989';
}


sub full_newick {

	return '( ( ( ( ( ( ( ( 2553536569:0.04806, 2553547864:0.02318) :0.13790, ( ( 2607817870:0.06292, ( ( 637686994:0.00904, 2607361738:0.00877) :0.00237, ( 2607811795:0.00000, 2624154139:0.00000) :0.01417) :0.04807) :0.11480, ( ( ( ( ( ( 640087144:0.00000, 2608168136:0.00000) :0.00000, 2624151930:0.00000) :0.00000, 2626314409:0.00000) :0.01710, ( ( 2608213837:0.00000, 2608216457:0.00000) :0.00000, 2608221109:0.00000) :0.02405) :0.19430, 2607807999:0.14371) :0.03774, ( ( 2607024285:0.00000, 2607027401:0.00000) :0.00000, 2607028865:0.00000) :0.15988) :0.01777) :0.06318) :0.04989, ( ( 637449936:0.00000, 2608229857:0.00000) :0.07062, ( ( ( 640080686:0.00000, 2608172520:0.00000) :0.00000, 2624147685:0.00000) :0.00000, 2626316849:0.00000) :0.07352) :0.04076) :0.05631, ( ( ( 2607035406:0.00000, 2608232869:0.00000) :0.00000, 2608236697:0.00000) :0.05689, ( 2608211019:0.05840, 2608233838:0.03815) :0.00863) :0.00299) :0.01776, 2608227678:0.02635) :0.00949, 2608199767:0.02571) :0.00179, ( ( 640943573:0.00000, 2607816045:0.00000) :0.00474, ( ( 647673898:0.00000, 2608172107:0.00000) :0.00000, 2626399128:0.00000) :0.00675) :0.01606) :0.00164, ( ( 2607980288:0.04953, ( ( 2607031065:0.00000, 2608208874:0.00000) :0.00000, 2608217268:0.00000) :0.02254) :0.00228, 2607022457:0.01276) :0.00073, ( ( 640078650:0.00000, 2624149569:0.00000) :0.01460, ( ( 640160519:0.00000, 2607814158:0.00000) :0.00000, 2626312088:0.00000) :0.01298) :0.00794)';

}

sub sort_tree {
	my $branches = shift;

	for (@$branches) {
		if ($_->{children}) {
			$_->{children} = sort_tree($_->{children});
		}
	}

	return [ sort { $a->{cumul_len} <=> $b->{cumul_len} || $a->{name} <=> $b->{name} } @$branches ];
}


done_testing();
