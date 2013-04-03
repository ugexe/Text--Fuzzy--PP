use lib 'lib';

use Text::Fuzzy::PP;

my @list = ('fourtyx','fxxr','fourth','fuor','');

my $tf = Text::Fuzzy::PP->new('four');
print $tf->nearest(\@list ) . "\n";