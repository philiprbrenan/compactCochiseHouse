#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/ -I/home/phil/perl/cpan/GitHubCrud/lib/
#-------------------------------------------------------------------------------
# Push CompactCochiseHouse to GitHub
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2026
#-------------------------------------------------------------------------------
use v5.38;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use GitHub::Crud qw(:all);

my $home    = q(/home/phil/personal/sierraVista/floorPlan/);                                                            # Local files
my $repo    = q(compactCochiseHouse);                                                                                   # Repo
my $user    = q(philiprbrenan);                                                                                         # User
my $shaFile = fpe $home, q(sha);                                                                                        # Sh256 file sums for each known file to detect changes
my $wf      = q(.github/workflows/main.yml);                                                                            # Work flow on Ubuntu - compile and test
my @ext     = qw(pl svg);                                                                                               # Extensions of files to upload to github

say STDERR timeStamp,  " push to github $repo";

my @files = searchDirectoryTreesForMatchingFiles($home, @ext);                                                          # Files to upload

if (!@files)                                                                                                            # No new files
 {say "Everything up to date";
  exit;
 }

if (1)                                                                                                                  # Upload via github crud
 {for my $s(@files)                                                                                                     # Upload each selected file
   {my $c = readFile $s;
       $c = expandWellKnownWordsAsUrlsInMdFormat $c if $s =~ m(README);

    my $t = swapFilePrefix $s, $home;                                                                                   # File on github
    my $w = writeFileUsingSavedToken($user, $repo, $t, $c);                                                             # Write file into github
    lll "$w  $t";
   }
 }

my $d = dateTimeStamp;
my $y = <<"END";
# Test $d

name: $repo

on:
  push:
    paths:
      - '**/main.yml'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout\@v6

    - name: Install Perl packages
      run: |
        sudo cpan install Data::Table::Text Data::Dump Svg::Simple

    - name: Perl
      run: |
        perl floorPlan.pl
END
my $f = writeFileUsingSavedToken $user, $repo, $wf, $y;                                                               # Upload workflow
lll "$f  Ubuntu work flow for $repo";
