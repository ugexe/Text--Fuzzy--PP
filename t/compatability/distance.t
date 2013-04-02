use strict;
use warnings;

use Test::More tests => 18;
use Text::Fuzzy::PP;

#defaults testing
my $tf_default = Text::Fuzzy::PP->new('four');
is( $tf_default->distance('fuor'), 2, 'test distance() defaults');

#transposition testing
my $tf_trans = Text::Fuzzy::PP->new('four',trans => 1);
is( $tf_trans->distance('fuor'), 1, 'test distance() trans => 1');
$tf_trans->transpositions_ok(0);
is( $tf_trans->distance('fuor'), 2, 'test distance() transpositions_ok(0)');
$tf_trans = Text::Fuzzy::PP->new('four',trans => 0);
is( $tf_trans->distance('fuor'), 1, 'test distance() trans => 0');
$tf_trans->transpositions_ok(1);
is( $tf_trans->distance('fuor'), 1, 'test distance() transpositions_ok(1)');

#no_exact testing
my $tf_exact = Text::Fuzzy::PP->new('four',no_exact => 1);
is( $tf_exact->distance('four'), undef, 'test distance() no_exact => 1');
$tf_exact->no_exact(0);
is( $tf_exact->distance('four'), 0, 'test distance() no_exact(0)');
$tf_exact = Text::Fuzzy::PP->new('four',no_exact => 0);
is( $tf_exact->distance('four'), undef, 'test distance() no_exact => 0');
$tf_exact->no_exact(1);
is( $tf_exact->distance('four'), 0, 'test distance() no_exact(1)');

#max_distance testing
my $tf_max = Text::Fuzzy::PP->new('four',max => 1);
is($tf_max->distance('fuor'), undef, 'test distance with max => 1');
$tf_max->set_max_distance();
is($tf_max->distance('fuor'), 2, 'test nearest with set_max_distance()');
$tf_max = Text::Fuzzy::PP->new('four',max => undef);
is($tf_max->distance('fuor'), 2, 'test nearest with max => undef');
$tf_max->set_max_distance(1);
is($tf_max->distance('fuor'), undef, 'test nearest with set_max_distance(1)');

#Test some utf8
use utf8;
my $tf_utf8 = Text::Fuzzy::PP->new('ⓕⓞⓤⓡ',trans => 1);
is( $tf_utf8->distance('ⓕⓞⓤⓡ'),   0, 'test distance() trans => 1 matching (utf8)');
is( $tf_utf8->distance('ⓕⓞⓡ'),    1, 'test distance() trans => 1 insertion (utf8)');
is( $tf_utf8->distance('ⓕⓞⓤⓡⓣⓗ'), 2, 'test distance() trans => 1 deletion (utf8)');
is( $tf_utf8->distance('ⓕⓤⓞⓡ'),   1, 'test distance() trans => 1 transposition (utf8)');
is( $tf_utf8->distance('ⓕⓧⓧⓡ'),   2, 'test distance() trans => 1 substitution (utf8)');

