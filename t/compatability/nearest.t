use strict;
use warnings;

use Test::More tests => 13;
use Text::Fuzzy::PP;

my @list = ('fourty','fxxr','fourth','fuor','');

#transposition testing
my $tf_trans = Text::Fuzzy::PP->new('four',trans => 1);
is($tf_trans->nearest(\@list ), 3, 'test nearest with trans => 1');
$tf_trans->transpositions_ok(0);
is($tf_trans->nearest(\@list ), 1, 'test nearest with transposition_ok(0)');
$tf_trans = Text::Fuzzy::PP->new('four',trans => 0);
is($tf_trans->nearest(\@list ), 1, 'test nearest with trans => 0');
$tf_trans->transpositions_ok(1);
is($tf_trans->nearest(\@list ), 3, 'test nearest with transposition_ok(1)');

#no_exact testing
push @list, 'four';
my $tf_exact = Text::Fuzzy::PP->new('four',no_exact => 1);
is($tf_exact->nearest(\@list ), 1, 'test nearest with no_exact => 1');
$tf_exact->no_exact(0);
is($tf_exact->nearest(\@list ), 5, 'test nearest with no_exact(0)');
$tf_exact = Text::Fuzzy::PP->new('four',no_exact => 0);
is($tf_exact->nearest(\@list ), 5, 'test nearest with no_exact => 0');
$tf_exact->no_exact(1);
is($tf_exact->nearest(\@list ), 1, 'test nearest with no_exact(1)');
pop @list;

#max_distance testing
my $tf_max = Text::Fuzzy::PP->new('..',max => 1);
is($tf_max->nearest(\@list ), undef, 'test nearest with max => 1');
$tf_max->set_max_distance(0);
is($tf_max->nearest(\@list ), 1, 'test nearest with set_max_distance(0)');
$tf_max = Text::Fuzzy::PP->new('..',max => 0);
is($tf_max->nearest(\@list ), 1, 'test nearest with max => 0');
$tf_max->set_max_distance(1);
is($tf_max->nearest(\@list ), undef, 'test nearest with set_max_distance(1)');


#Test some utf8
use utf8;
my $tf_utf8 = Text::Fuzzy::PP->new('ⓕⓞⓤⓡ',trans => 1);
my @list_utf8 = ('ⓕⓤⓞⓡ','ⓕⓞⓤⓡⓣⓗ','ⓕⓧⓧⓡ','');
is($tf_utf8->nearest(\@list_utf8), 1, 'test nearest with transposition (utf8)');
