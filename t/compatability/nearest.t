use strict;
use warnings;

use Test::More tests => 14;
use Text::Fuzzy::PP;

my @list = ('fourty','fxxr','fourth','fuor','');

#defaults testing
my $tf_default = Text::Fuzzy::PP->new('four');
is($list[$tf_default->nearest(\@list )], 'fxxr', 'test nearest defaults');

#transposition testing
my $tf_trans = Text::Fuzzy::PP->new('four',trans => 1);
is($list[$tf_trans->nearest(\@list )], 'fuor', 'test nearest with trans => 1');
$tf_trans->transpositions_ok(0);
is($list[$tf_trans->nearest(\@list )], 'fxxr', 'test nearest with transposition_ok(0)');
$tf_trans->transpositions_ok(1);
$tf_trans = Text::Fuzzy::PP->new('four',trans => 0);
is($list[$tf_trans->nearest(\@list )], 'fxxr', 'test nearest with trans => 0');
$tf_trans->transpositions_ok(1);
is($list[$tf_trans->nearest(\@list )], 'fuor', 'test nearest with transposition_ok(1)');

#no_exact testing
push @list, 'four';
my $tf_exact = Text::Fuzzy::PP->new('four',no_exact => 1);
is($list[$tf_exact->nearest(\@list )], 'fxxr', 'test nearest with no_exact => 1');
$tf_exact->no_exact(0);
is($list[$tf_exact->nearest(\@list )], 'four', 'test nearest with no_exact(0)');
$tf_exact->no_exact(1);
$tf_exact = Text::Fuzzy::PP->new('four',no_exact => 0);
is($list[$tf_exact->nearest(\@list )], 'four', 'test nearest with no_exact => 0');
$tf_exact->no_exact(1);
is($list[$tf_exact->nearest(\@list )], 'fxxr', 'test nearest with no_exact(1)');
pop @list;

#max_distance testing
my $tf_max = Text::Fuzzy::PP->new('..',max => 1);
is($list[$tf_max->nearest(\@list )], undef, 'test nearest with max => 1');
$tf_max->set_max_distance();
is($list[$tf_max->nearest(\@list )], 'fxxr', 'test nearest with set_max_distance()');
$tf_max->set_max_distance(1);
$tf_max = Text::Fuzzy::PP->new('..',max => undef);
is($list[$tf_max->nearest(\@list )], 'fxxr', 'test nearest with max => undef');
$tf_max->set_max_distance(1);
is($list[$tf_max->nearest(\@list )], undef, 'test nearest with set_max_distance(1)');


#Test some utf8
use utf8;
my $tf_utf8 = Text::Fuzzy::PP->new('ⓕⓞⓤⓡ',trans => 1);
my @list_utf8 = ('ⓕⓤⓞⓡ','ⓕⓞⓤⓡⓣⓗ','ⓕⓧⓧⓡ','');
is($list_utf8[$tf_utf8->nearest(\@list_utf8)], 'ⓕⓤⓞⓡ', 'test nearest with transposition (utf8)');
