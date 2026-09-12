#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/ -I/home/phil/perl/cpan/SvgSimple/lib/ -I/home/phil/perl/cpan/Math-Intersection-Circle-Line/lib
#-------------------------------------------------------------------------------
# Floor plan using Svg - all dimensions are in feet
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2025
#-------------------------------------------------------------------------------
use v5.38;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use Svg::Simple;
use utf8;

my %d = (stroke_width=>1, fill=>"none", stroke=>"darkblue");                                                            # Default options
my %f = (font_family=>"Verdana", font_size=>"1", font_weight=>"bold", font_style=>"normal");                           # Font for text

my $x = 0; my $w = 0; my $W = 48;
my $y = 0; my $h = 0; my $H = 24;
my $T = 1/2;                                                                                                            # Thickness of the walls
my $C =   6;                                                                                                            # Convenient length
my $G =  12;                                                                                                            # Great room / bedrooms

my $s = Svg::Simple::new(grid=>12);

$x = 0; $w = 0; $h = $G; $y = $H - $h; $d{stroke_width}=0.3; $d{height}=$h;

room($s, %d, x=>($x+=$w), y=> $y, width=>($w = 2*$C),               stroke=>"lightblue", text=>"Bed2");                 # Bed 2
room($s, %d, x=>($x+=$w), y=> $y, width=>($w = $W-4*$C),            stroke=>"grey",      text=>"Living");               # Living room
room($s, %d, x=>($x+=$w), y=> $y, width=>($w = 2*$C),               stroke=>"pink",      text=>"Bed1");                 # Bed 1

$x = 0; $w = 0; $h = $y;                       $d{height}=$h;
room($s, %d, x=>($x+=$w), y=>0,   width=>($w = $C),                 stroke=>"cyan",      text=>"Bath2");                # Bath 2
room($s, %d, x=>($x+=$w), y=>0,   width=>($w = $W-3*$C),            stroke=>"yellow",    text=>"Kitchen");              # Kitchen
room($s, %d, x=>($x+=$w), y=>0,   width=>($w = $C),                 stroke=>"orange",    text=>"Laundry");              # Laundry/Mechanical
room($s, %d, x=>($x+=$w), y=>0,   width=>($w = $C),                 stroke=>"violet",    text=>"Bath1");                # Bath 1
room($s, %d, x=> 0-$T,    y=>-$T, width=> $W+2*$T, height=>$H+2*$T, stroke_width=>1);                                   # Outline

bath($s, x=>$T,    y=>$T); toilet($s, x=>$T,    y=>$T + $C, 𝗱=>-90); basin($s, x=>$T,    y=>$T + 3/2*$C, 𝗱=>-90);       # Bathroom 2
bath($s, x=>$W-$C, y=>$T); toilet($s, x=>$W-$C, y=>$T + $C, 𝗱=>-90); basin($s, x=>$W-$C, y=>$T + 3/2*$C, 𝗱=>-90);       # Bathroom 1

counter($s, x=>3*$C, y=>$C);                                                                                           # Counter in kitchen

queenBed($s, x=>$C/2,      y=>$H-$C-2);                                                                                 # Queen bed
queenBed($s, x=>$W-$C*3/2, y=>$H-$C-2);                                                                                 # Queen bed
sofa2   ($s, x=>$W/2+$C/2, y=>$H/2+$C, 𝗱=>180);                                                                         # Two set sofa in living room

doorLU($s, x=>$W,      y=>$H-$G);                                                                                       # Bed 1 to bath 1
doorLU($s, x=>$C,      y=>$H-$G);                                                                                       # Bed 2 to bath 2
doorLL($s, x=>2*$C,    y=>$H-$G);                                                                                       # Living to bed 2
doorRR($s, x=>$W-2*$C, y=>$H-$G);                                                                                       # Living to bed 1
doorLR($s, x=>$W-2*$C, y=>$H-$G);                                                                                       # Kitchen to utility room

doorRD($s, x=>3/2*$C,    y=>0);                                                                                       # Kitchen to utility room
doorLD($s, x=>5/2*$C,  y=>0);                                                                                       # Kitchen to utility room


$s->line(x1=>2*$C, y1=>$H-$G, x2=>$W-2*$C, y2=>$H-$G, stroke_width=>$T, fill=>"none", stroke=>"white");

owf "plan.svg", $s->print;

sub room($s, %p)
 {my $x  = $p{x     } // confess "Required";
  my $y  = $p{y     } // confess "Required";
  my $w  = $p{width } // confess "Required";
  my $h  = $p{height} // confess "Required";
  my $t  = $p{text  };
  my $sw = $p{sw    } // 0.1;

  $s->rect(%p);                                                                                                         # Border of room
  $s->text(%f, x=>$x+$w/2-length($t)/2, y=>$y+$h/2, cdata=>$t) if $t;                                                      # Name of room
 }

sub counter($s, %p)
 {my $x  = $p{x };
  my $y  = $p{y };
  my $w  = $p{w } // $C*1.5;
  my $h  = $p{h } // $C*5/12;
  my $sw = $p{sw} // 0.1;
  my $𝗱  = $p{𝗱}  // 0;

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->rect(width=>$w, height=>$h, fill=>"none", stroke=>"darkgreen", stroke_width=>$sw);
   });
 }

sub queenBed($s, %p)
 {my $x  = $p{x}  // 0;
  my $y  = $p{y}  // 0;
  my $w  = $p{w}  // 5;
  my $h  = $p{h}  // $C + 8/12;
  my $sw = $p{sw} // 0.1;
  my $𝗱  = $p{𝗱}  // 0;

  my %d = (height=>1.0, rx=>0.15, fill=>"none", stroke=>"black", stroke_width=>$sw);

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->rect(%d, x=>0,         y=>0,        width=>$w, height=>$h, stroke=>"darkred");                                  # Mattress
    $s->rect(%d, x=>0.25,      y=>-1.25+$h, width=>$w/2-0.35);                                                          # Pillows
    $s->rect(%d, x=>$w/2+0.10, y=>-1.25+$h, width=>$w/2-0.35);
   });
 }

sub bath($s, %p)
 {my $x  = $p{x };
  my $y  = $p{y };
  my $w  = $p{w } // 5;
  my $h  = $p{h } // 2.5;
  my $bw = $p{bw} // 0.2;
  my $sw = $p{sw} // 0.1;

  $s->rect(x=>$x, y=>$y, width=>$w, height=>$h, rx=>4, fill=>"none", stroke=>"black", stroke_width=>$sw);

  $s->rect(
    x      => $x+1*$bw,
    y      => $y+1*$bw,
    width  => $w-2*$bw,
    height => $h-2*$bw,
    rx     => $bw,
    fill   => "none",
    stroke => "black",
    stroke_width=>$sw,
   );
 }

sub sofa2($s, %p)
 {my $x = $p{x};
  my $y = $p{y};
  my $w = $p{w} // $C;
  my $d = $p{d} // $C/2;
  my $𝗱 = $p{𝗱} // 0;
  my %d = (stroke_width=>0.1, fill=>"none", stroke=>"darkblue");

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->rect(%d, x=>0,         y=>0,      width=>$w,      height=>$d,    rx=>0.15);                                     # Overall sofa
    $s->rect(%d, x=>0,         y=>$d-0.6, width=>$w,      height=>0.6,   rx=>0.15);                                     # Back
    $s->rect(%d, x=>0.15,      y=>0.15,   width=>$w/2-.2, height=>$d-.9, rx=>0.15);                                     # Two seat cushions
    $s->rect(%d, x=>$w/2+0.05, y=>0.15,   width=>$w/2-.2, height=>$d-.9, rx=>0.15);

    $s->rect(%d, x=>0,         y=>0,      width=>0.3,     height=>$d,    rx=>0.12);                                     # Arms
    $s->rect(%d, x=>0+$w-0.3,  y=>0,      width=>0.3,     height=>$d,    rx=>0.12);
   });
 }

sub toilet($s, %p)
 {my $x = $p{x};
  my $y = $p{y};
  my $w = $p{width}  // 2.3;
  my $h = $p{height} // 2.3;
  my $𝗱 = $p{𝗱}      // 0;

  my %d = (stroke_width=>0.1, fill=>"none", stroke=>"darkgreen");

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->rect(%d, x=>0.15*$w, y=>0.25*$h, width=>0.70*$w, height=>0.65*$h, rx=>0.30*$w);                                 # Toilet bowl
    $s->rect(%d, x=>0.25*$w, y=>0,       width=>0.50*$w, height=>0.30*$h, rx=>0.08*$w);                                 # Cistern
   });
 }

sub basin($s, %p)
 {my $x = $p{x};
  my $y = $p{y};

  my $w = $p{width}  // 2.0;
  my $d = $p{depth}  // 1.75;
  my $𝗱 = $p{𝗱}      // 0;
  my %d = (stroke_width=>0.1, fill=>"none", stroke=>"darkorange");

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->rect   (%d, x=>0, y=>0,  width=>$w, height=>$d, rx=>0.1                 );                                      # Counter
    $s->ellipse(%d, cx=>$w/2, cy=>$d/2,                 rx=>$w*0.35, ry=>$d*0.35);                                      # Basin
    $s->ellipse(%d, cx=>$w/2, cy=>$d/2,                 rx=>   0.05, ry=>   0.05);                                      # Drain
   });
 }

sub doorRU($s, %p)
 {my $x = $p{x};
  my $y = $p{y};
  my $𝗱 = $p{𝗱} // 0;

  my $w = $C/2;
  my $q = $w / sqrt(2.0);
  my %d = (stroke=>"black", fill=>"none", stroke_width=>0.1);
  my %D = (stroke=>"grey",  fill=>"none", stroke_width=>0.4);

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->line   (%D, x1=>0.0, y1=>0.0, x2=>$w, y2=>0.0);                                                                 # Door leaf
    $s->line   (%d, x1=>0.0, y1=>0.0, x2=>$w, y2=>0.0);
    my $d = $s->arcPath(10, $w, 0, $q, -$q, 0, -$w);                                                                    # Swing arc
    $s->path(%D, d=>$d);
    $s->path(%d, d=>$d);
   });
 }

sub doorRD($s, %p)
 {my $x = $p{x};
  my $y = $p{y};
  my $𝗱 = $p{𝗱} // 0;

  my $w = $C/2;
  my $q = $w / sqrt(2.0);
  my %d = (stroke=>"black", fill=>"none", stroke_width=>0.1);
  my %D = (stroke=>"grey",  fill=>"none", stroke_width=>0.4);

  $s->g(transform=>"translate($x, $y),rotate($𝗱)", sub=>sub
   {$s->line   (%D, x1=>0.0, y1=>0.0, x2=>$w, y2=>0.0);                                                                 # Door leaf
    $s->line   (%d, x1=>0.0, y1=>0.0, x2=>$w, y2=>0.0);

    my $d = $s->arcPath(10, $w, 0, $q, $q, 0, $w);                                                                      # Swing arc
    $s->path(%D, d=>$d);
    $s->path(%d, d=>$d);
   });
 }

sub doorLD($s, %p) {doorRU($s, %p, 𝗱=>180);}
sub doorLU($s, %p) {doorRD($s, %p, 𝗱=>180);}
sub doorLL($s, %p) {doorRD($s, %p, 𝗱=>90);}
sub doorRR($s, %p) {doorRU($s, %p, 𝗱=>90);}
sub doorRL($s, %p) {doorRU($s, %p, 𝗱=>270);}
sub doorLR($s, %p) {doorRD($s, %p, 𝗱=>270);}
