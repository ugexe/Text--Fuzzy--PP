package Text::Fuzzy::PP;
use strict;
use warnings;
use utf8;
require Exporter;

our @ISA = qw(Exporter); 
our @EXPORT = qw/distance_edits/;
our $VERSION   = '0.01';

# Get away with some XS for speed if available...
local $@;
eval { require List::Util; };
unless ($@) {
    *min = \&List::Util::min;
}
else {
    *min = \&_min;
}
 
sub new {
    my $class  = shift;
    my $source = shift;
    my %args   = @_;
    
    my $self  = {
        source               => $source,
        #Workaround because Text::Fuzzy last_distance is a method, not a value
        _last_distance       => undef,
        length               => length($source),
        no_exact             => defined($args{'no_exact'}) ? delete($args{'no_exact'}) : 0,
        trans                => defined($args{'trans'})    ? delete($args{'trans'})    : 0,
        max_distance         => defined($args{'max'})      ? delete($args{'max'})      :-1,
    };

    bless( $self, $class );

    return $self;
}

sub unicode_length {
    my $self = shift;
    return length $self->{source};
}

sub last_distance {
    my $self = shift;
    return $self->{_last_distance};    
}

sub set_max_distance {
    my ($self,$max) = @_;
    # set_max_distance() with no args = no max
    $max = -1 if (!defined $max);
    $self->{max_distance} = $max if ($max >= -1);
}

sub get_max_distance {
    my $self = shift;
    return ($self->{max_distance} == -1)?undef:$self->{max_distance};
}

sub transpositions_ok {
    my ($self,$onoff) = @_;
    $self->{trans} = $onoff if ($onoff == 0 || $onoff == 1);
}

sub no_exact {
    my ($self,$onoff) = @_;
    $self->{no_exact} = $onoff if ($onoff == 0 || $onoff == 1);
}

sub distance {
    my ($self,$target,$max) = @_;

    if($self->{source} eq $target) {
        return $self->{no_exact}?undef:0;
    }

    # $max overrides our objects max_distance
    # allows nearest() to change he max_distance dynamically for speed
    $max = defined($max)?$max:$self->{max_distance};

    my $target_length = length($target);

    return ($self->{length}?$self->{length}:$target_length) 
        if(!$target_length || !$self->{length});

    # pass the string lengths to keep from calling length() again later
    if( $self->{trans} ) {
        my $score = _damerau($self->{source},$self->{length},$target,$target_length,$max);
        return ($score > 0)?$score:undef;
    }
    else {
        my $score = _levenshtein($self->{source},$self->{length},$target,$target_length,$max);
        return ($score > 0)?$score:undef;
    }
}

sub nearest {
    my ($self,$words) = @_;

    if ( ref $words eq ref [] ) {
        my $max = $self->{max_distance};
        my $best_index = undef;

        for ( 0 .. $#{ $words } ) {
            my $d = $self->distance($words->[$_], $max);

            if( !defined($d) ) {
                # no_exact => 1 match or $d > $max
            }
            elsif( $max == -1 || $d < $max ) {  
                # better match found
                $self->{_last_distance} = $max = $d;
                $best_index = $_;
            }
        }

        return $best_index;
    }
}

1;

sub _levenshtein {
    my ($source,$source_length,$target,$target_length,$max_distance) = @_;

    my @scores;;
    my ($i,$j,$large_value);

    if ($max_distance >= 0) {
        $large_value = $max_distance + 1;
    }
    else {
        if ($target_length > $source_length) {
            $large_value = $target_length;
        }
        else {
            $large_value = $source_length;
        }
    }

    for ($j = 0; $j <= $target_length; $j++) {
        $scores[0][$j] = $j;
    }

    for ($i = 1; $i <= $source_length; $i++) {
        my ($col_min,$next,$prev);
        my $c1    = substr($source,$i-1,1);
        my $min_j = 1;
        my $max_j = $target_length;

        if ($max_distance >= 0) {
            if ($i > $max_distance) {
                $min_j = $i - $max_distance;
            }
            if ($target_length > $max_distance + $i) {
                $max_j = $max_distance + $i;
            }
        }

        $col_min = $large_value;
        $next = $i % 2;

        if ($next == 1) {
            $prev = 0;
        }
        else {
            $prev = 1;
        }

        $scores[$next][0] = $i;

        for ($j = 1; $j <= $target_length; $j++) {
            if ($j < $min_j || $j > $max_j) {
                $scores[$next][$j] = $large_value;
            }
            else {
                my $c2 = substr($target,$j-1,1);

                if ($c1 eq $c2) {
                    $scores[$next][$j] = $scores[$prev][$j-1];
                }
                else {
                    my $delete     = $scores[$prev][$j] + 1;#[% delete_cost %];
                    my $insert     = $scores[$next][$j-1] + 1;#[% insert_cost %];
                    my $substitute = $scores[$prev][$j-1] + 1;#[% substitute_cost %];
                    my $minimum    = $delete;

                    if ($insert < $minimum) {
                        $minimum = $insert;
                    }
                    if ($substitute < $minimum) {
                        $minimum = $substitute;
                    }
                    $scores[$next][$j] = $minimum;
                }
            }

            if ($scores[$next][$j] < $col_min) {
                $col_min = $scores[$next][$j];
            }
        }

        if ($max_distance >= 0) {
            if ($col_min > $max_distance) {
                return -1;
            }
        }
    }

    return $scores[$source_length % 2][$target_length];
}

sub _damerau {
    my ($source,$source_length,$target,$target_length,$max_distance) = @_;
    
    my $lengths_max = $source_length + $target_length;
    my ($swap_count,$swap_score,$target_char_count,$source_index,$target_index);          
    my $dictionary_count = {};    #create dictionary to keep character count
    my @scores;              

    # init values outside of work loops
    $scores[0][0] = $scores[1][0] = $scores[0][1] = $lengths_max;
    $scores[1][1] = 0;

    # Work Loops
    foreach $source_index ( 1 .. $source_length ) {
        $swap_count = 0;
        $dictionary_count->{ substr( $source, $source_index - 1, 1 ) } = 0;
        $scores[ $source_index + 1 ][1] = $source_index;
        $scores[ $source_index + 1 ][0] = $lengths_max;

        foreach $target_index ( 1 .. $target_length ) {
            if ( $source_index == 1 ) {
                $dictionary_count->{ substr( $target, $target_index - 1, 1 ) } = 0;
                $scores[1][ $target_index + 1 ] = $target_index;
                $scores[0][ $target_index + 1 ] = $lengths_max;
            }

            $target_char_count =
              $dictionary_count->{ substr( $target, $target_index - 1, 1 ) };
	        $swap_score = $scores[$target_char_count][$swap_count] +
                  ( $source_index - $target_char_count - 1 ) + 1 +
                  ( $target_index - $swap_count - 1 );

            if (
                substr( $source, $source_index - 1, 1 ) ne
                substr( $target, $target_index - 1, 1 ) )
            {
                $scores[ $source_index + 1 ][ $target_index + 1 ] = min(
                    $scores[$source_index][$target_index]+1,
                    $scores[ $source_index + 1 ][$target_index]+1,
                    $scores[$source_index][ $target_index + 1 ]+1,
                    $swap_score
                );
            }
            else {
                $swap_count = $target_index;

                $scores[ $source_index + 1 ][ $target_index + 1 ] = min(
                  $scores[$source_index][$target_index], $swap_score
                );
            }
        }

        # This is where the $max_distance check goes ideally, but it doesn't pass tests
        #if ( $max_distance != -1 && $max_distance < $scores[ $source_index + 1 ][ $target_length + 1 ] )
        #{
        #    return -1;
        #}

        $dictionary_count->{ substr( $source, $source_index - 1, 1 ) } =
          $source_index;
    }

    return -1 if ($max_distance != -1 && $scores[ $source_length + 1 ][ $target_length + 1 ] > $max_distance);
    return $scores[ $source_length + 1 ][ $target_length + 1 ];	
}

sub _min {
    my $min = shift;
    return $min if not @_;

    my $next = shift;
    unshift @_, $min < $next ? $min : $next;
    goto &_min;
}

__END__

