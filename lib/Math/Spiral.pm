package Math::Spiral;

use strict;
use warnings;

use Math::Trig qw(pi);

# perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' lib/Math/Spiral.pm  > README.md

=head1 NAME

Math::Spiral - Perl extension to return an endless stream of X, Y offset coordinates which represent a spiral shape

=head1 SYNOPSIS

    #!/usr/bin/perl -w

    use Math::Spiral;

    my $s = new Math::Spiral();
    my($xo,$yo)=$s->Next();


    # perl -MMath::Spiral -e '$s=new Math::Spiral(); foreach(0..9) { ($xo,$yo)=$s->Next(); $chart[2+$xo][2+$yo]=$_; } foreach $y (0..4){foreach $x(0..4){if(defined($chart[$x][$y])){print $chart[$x][$y]} else {print " ";} } print "\n"}'

=head1 DESCRIPTION

This module outputs an infinte sequence of coordinate offsets, which you can use to plot things in a spiral shape.
The numbers return "clockwise"; negate one if you want to go anti-clockwise instead.

It is useful for charting things where you need to concentrate something around the center of the chart.

=head2 EXAMPLE

    #!/usr/bin/perl -w

    use Math::Spiral;

    my $s = new Math::Spiral();

    foreach(0..9) {
      ($xo,$yo)=$s->Next();	# Returns a sequnce like (0,0) (1,0) (1,1) (0,1) (-1,1) (-1,0) (-1,-1) (0,-1) (1,-1) (2,-1) ... etc
      $chart[2+$xo][2+$yo]=$_;
    }

    foreach $y (0..4) {
      foreach $x(0..4) {
        if(defined($chart[$x][$y])) { 
          print $chart[$x][$y] 
        } else {
          print " ";
        }
      }
      print "\n"
    }

=head3 Prints

 6789
 501 
 432 

=head2 EXAMPLE

    use Math::Trig qw(cot);
    use Math::Spiral;

    my $s = Math::Spiral->new(
      a=>1, b=>1.5, t_inc=>0.03,
      t_cb => sub { # Logarithmic
        my $self = shift;
        return $self->{a} * exp($self->{t} * cot($self->{b}));
      },
    );

    foreach(0..9) {
      ($xo,$yo)=$s->NextEq();	# Returns a sequnce like (0,0) (1,0) (2.0021, 0.0096), etc.
      # Now add as a point to a growing plot, for instance.
    }

=head2 EXPORT

None by default.

=head2 new

Usage is

    my $s = new Math::Spiral();


=head2 Next

Returns the next x and y offsets (note that these start at 0,0 and will go negative to circle around this origin)

Usage is

    my($xo,$yo)=$s->Next();
    # Returns a sequnce like (0,0) (1,0) (1,1) (0,1) (-1,1) (-1,0) (-1,-1) (0,-1) (1,-1) (2,-1) ... etc (i.e. the x,y coordinates for a spiral)

=head2 NextEq

Returns the next x and y points given the polar equation for a spiral.

The relevant arguments are B<t> (theta), B<t_inc> (the increment), and
B<t_cb> (the theta callback).  B<t> is an interally computed value.
But the others can be given in the constructor.

The callback method is for defining a differnent kind of spiral.  The
example above shows how to set this to compute the coordinates of a
logarithmic spiral.

This method is handy for plotting the points of a spiral drawing.  The
spacing between points is entirely given by the polar equation and
consists of floating point numbers.

Default: Archimedean

=cut

require Exporter;

our @ISA = qw(Exporter);
our($VERSION)='1.01';
our($UntarError) = '';

our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );


sub new {
  my $class = shift;
  my %args = @_;
  my $this={};
  foreach(qw(a b t_inc t_cb)){ $this->{$_}=$args{$_} }
  foreach(qw(x xmin y ydir ymin t)){ $this->{$_}=0; }
  foreach(qw(xdir xmax ymax t_inc)){ $this->{$_}||=1; }
  # my($x,$xdir,$xmax,$xmin) = (0,1,1,0);
  # my($y,$ydir,$ymax,$ymin) = (0,0,1,0);
  bless $this,$class;
  return $this;
} # new



sub Next {
  my $this = shift;

  my @ret=($this->{x},$this->{y});

  $this->{x}+=$this->{xdir};
  $this->{y}+=$this->{ydir};

  if(     ($this->{x}>=$this->{xmax})&&($this->{xdir})) {
    $this->{xmin}=-$this->{xmax}; $this->{xdir}=0; $this->{ydir}=1;
  } elsif(($this->{x}<=$this->{xmin})&&($this->{xdir})) {
    $this->{xmax}=-$this->{xmin}+1; $this->{xdir}=0; $this->{ydir}=-1;
  } elsif(($this->{y}>=$this->{ymax})&&($this->{ydir})) {
    $this->{ymin}=-$this->{ymax}; $this->{xdir}=-1; $this->{ydir}=0; 
  } elsif(($this->{y}<=$this->{ymin})&&($this->{ydir})) {
    $this->{ymax}=-$this->{ymin}+1; $this->{xdir}=1; $this->{ydir}=0;
  }

  return @ret;
} # Next

# testing # perl -MMath::Spiral -e '$s=new Math::Spiral(); foreach(0..25) { ($xo,$yo)=$s->Next(); $chart[3+$xo][3+$yo]=$_; } foreach $y (0..6){foreach $x(0..6){if(defined($chart[$x][$y])){print chr(97+$chart[$x][$y])} else {print " ";} } print "\n"}'


sub NextEq {
  my $this = shift;

  my @ret=($this->{x},$this->{y});

  my $r = $this->{t_cb}
    ? $this->{t_cb}->($this)
    : $this->{a} + $this->{b} * $this->{t}; # Archimedean default

  $this->{x} += $r * cos($this->{t} / pi);
  $this->{y} += $r * sin($this->{t} / pi);

  $this->{t} += $this->{t_inc};

  return @ret;
} # NextEq


1;

__END__

=head1 SEE ALSO

The F<eg/svg_spiral_eq.pl> example program and the F<t/Math-Spiral.t> tests

L<https://en.wikipedia.org/wiki/Archimedean_spiral>

L<https://en.wikipedia.org/wiki/Logarithmic_spiral>

=head1 AUTHOR

This module was written by Chris Drake F<cdrake@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019 Chris Drake. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
