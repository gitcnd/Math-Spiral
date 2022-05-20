# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl IO-Uncompress-Untar.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Math::Trig qw(cot);
use Test::More;

BEGIN { use_ok('Math::Spiral') };

# testing Next: perl -MMath::Spiral -e '$c=new Math::Spiral(); for(my $i=0;$i<5;$i++) { print "$i\t( " . join(", ",$c->Next()) . " )\n"; }'  # correct= ['204,81,81', '127,51,51', '81,204,204', '51,127,127', '142,204,81']

subtest 'Next' => sub {
  my $s=new Math::Spiral();
  my $t='';

  foreach(0..9) { my ($xo,$yo)=$s->Next(); $t .= "($xo,$yo) "; }

  ok($t eq '(0,0) (1,0) (1,1) (0,1) (-1,1) (-1,0) (-1,-1) (0,-1) (1,-1) (2,-1) ', "Next OK");
};

subtest 'Next Equation' => sub {
  my $s=Math::Spiral->new(a=>1, b=>1);
  my $t=[];

  foreach(0..9) { my ($xo,$yo)=$s->NextEq(); push @$t, [$xo,$yo]; }

  is_deeply($t->[0], [0,0], 'NextEq OK');
  is_deeply($t->[1], [1,0], 'NextEq OK');
  is(sprintf('%.1f', $t->[9][0]), -5.7, 'NextEq OK');
  is(sprintf('%.1f', $t->[9][1]), 34.4, 'NextEq OK');
};

subtest 'Next Equation with callback' => sub {
  my $s=Math::Spiral->new(
    a=>1, b=>1,
    t_cb => sub { # Logarithmic
      my $self = shift;
      return $self->{a} * exp($self->{t} * cot($self->{b}));
    },
  );
  my $t=[];

  foreach(0..9) { my ($xo,$yo)=$s->NextEq(); push @$t, [$xo,$yo]; }

  is_deeply($t->[0], [0,0], 'NextEq OK');
  is_deeply($t->[1], [1,0], 'NextEq OK');
  is(sprintf('%.1f', $t->[9][0]), -198.3, 'NextEq OK');
  is(sprintf('%.1f', $t->[9][1]), 256.3, 'NextEq OK');
};

done_testing();
