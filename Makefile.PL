use 5.008_008; # for utf8, sorry legacy Perls
use strict;
use warnings; 
use ExtUtils::MakeMaker;

my $pm =   'lib/Text/Fuzzy/PP.pm';
my $repo = 'https://github.com/ugexe/Text--Fuzzy--PP';
my $bugs = 'https://github.com/ugexe/Text--Fuzzy--PP/issues';
 
WriteMakefile (  
    NAME => 'Text::Fuzzy::PP',
    VERSION_FROM => $pm, 
    ABSTRACT_FROM => $pm,
    AUTHOR => 'Nick Logan <ugexe@cpan.org>',
    LICENSE => 'perl',
    MIN_PERL_VERSION => '5.008008',
    BUILD_REQUIRES => {
	'Test::More'		=> '0.98_01',
    },
    META_MERGE => {
        resources => {
            repository => $repo, 
            bugtracker => $bugs,
        },
    },
);
