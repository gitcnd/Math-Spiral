#!/usr/bin/env perl
use strict;
use warnings;

# This is a full example of an SVG spiral plot.
# Usage: perl eg/svg_spiral_eq.pl > spiral.svg
# To render Archimedes or logarithmic spirals, please see the source
# code comments below!

use Math::Spiral;
use Math::Trig qw(cot);
use SVG qw(title);

my $A    = shift // 1;
my $B    = shift // 1.5;
my $incr = shift || 0.3; # 1 for Archimedes, 0.3 for logarithmic
my $max  = shift || 150;
my $size = shift || 500;
my $line = shift || 'black';
my $fill = shift || 'black';

my $center = $size / 2;

my $svg = SVG->new(
    width  => $size,
    height => $size,
);
$svg->title()->cdata('Spiral');

my $style = $svg->group(
    id    => 'style-group',
    style => {
        stroke => $line,
        fill   => $fill,
    },
);

my $spiral = Math::Spiral->new(
    a     => $A,
    b     => $B,
    t_inc => $incr,
    t_cb  => sub { # Logarithmic. Comment-out for Archimedes
      my $self = shift;
      return $self->{a} * exp($self->{t} * cot($self->{b}));
    },
);

my $last_point = [0, 0];

for (1 .. $max) {
    my ($x, $y) = $spiral->NextEq;

    my $id = $x . '_' . $y;

    $style->line(
        id => $id . '-line',
        x1 => $center + $last_point->[0],
        y1 => $center + $last_point->[1],
        x2 => $center + $x,
        y2 => $center + $y,
    );

    $style->circle(
        id => $id . '-point',
        cx => $center + $x,
        cy => $center + $y,
        r  => 1,
    );

    $last_point = [$x, $y];
}

print $svg->xmlify;
