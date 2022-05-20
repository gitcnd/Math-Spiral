# NAME

Math::Spiral - Perl extension to return an endless stream of X, Y offset coordinates which represent a spiral shape

# SYNOPSIS

    use Math::Spiral;

    my $s = Math::Spiral->new();
    my($xo,$yo)=$s->Next();

    $s = Math::Spiral->new();
    ($xo,$yo)=$s->NextEq();

    # perl -MMath::Spiral -e '$s=Math::Spiral->new(); foreach(0..9) { ($xo,$yo)=$s->Next(); $chart[2+$xo][2+$yo]=$_; } foreach $y (0..4){foreach $x(0..4){if(defined($chart[$x][$y])){print $chart[$x][$y]} else {print " ";} } print "\n"}'

# DESCRIPTION

This module outputs an infinte sequence of coordinate offsets, which you can use to plot things in a spiral shape.
The numbers return "clockwise"; negate one if you want to go anti-clockwise instead.

It is useful for charting things where you need to concentrate something around the center of the chart.

## EXAMPLE

    use Math::Spiral;

    my $s = Math::Spiral->new();

    foreach(0..9) {
      ($xo,$yo)=$s->Next();     # Returns a sequence like (0,0) (1,0) (1,1) (0,1) (-1,1) (-1,0) (-1,-1) (0,-1) (1,-1) (2,-1) ... etc
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

### Prints

    6789
    501 
    432 

## EXAMPLE

    my $s = Math::Spiral->new(
      a=>1, b=>1.5, t_inc=>0.3,
      t_cb => sub { # Logarithmic
        my $self = shift;
        return $self->{a} * exp($self->{t} * cot($self->{b}));
      },
    );

    foreach(0..9) {
      ($xo,$yo)=$s->NextEq();	# Returns a sequence like (0,0) (1,0) (2.0168, 0.0974), etc.
      # Now add as a point to a growing plot, for instance.
    }

## EXPORT

None by default.

# Methods

## new

Return a new C<Math::Spiral> object.

Optional arguments for computation of NextEq() coordinates and their
defaults:

    a: 1
    b: 1
    t_inc: 1
    t_cb: undef

Usage is

    my $s = Math::Spiral->new(%arguments);

## Next

Returns the next x and y offsets (note that these start at 0,0 and will go negative to circle around this origin)

Usage is

    my($xo,$yo)=$s->Next();
    # Returns a sequence like (0,0) (1,0) (1,1) (0,1) (-1,1) (-1,0) (-1,-1) (0,-1) (1,-1) (2,-1) ... etc (i.e. the x,y coordinates for a spiral)

## NextEq

Returns the next x and y points given the polar equation for a spiral.

The relevant arguments are the constants B<a> and B<b>, B<t> (theta),
B<t_inc> (the increment), and B<t_cb> (the theta callback).  B<t> is
an interally computed value.  But the others can be given in the
constructor.

The callback method is for defining a differnent kind of spiral.  The
example above shows how to set this to compute the coordinates of a
logarithmic spiral.

This method is handy for plotting the points of a spiral drawing.  The
spacing between points is entirely given by the polar equation and
consists of floating point numbers.

Default: Archimedean

Usage is

    my($xo,$yo)=$s->NextEq();
    # Returns a sequence like (0,0) (1,0) (2.0021, 0.0096), etc.

## SEE ALSO

The eg/svg_spiral_eq.pl example program and the t/Math-Spiral.t tests

https://en.wikipedia.org/wiki/Archimedean_spiral

https://en.wikipedia.org/wiki/Logarithmic_spiral

# AUTHOR

This module was written by Chris Drake `cdrake@cpan.org`

# COPYRIGHT AND LICENSE

Copyright (c) 2019 Chris Drake. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.
