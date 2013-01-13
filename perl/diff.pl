#!/usr/bin/env perl

use strict;
use Getopt::Long;
#use File::Find;
use Data::Dumper;
use Digest::MD5;
use File::Finder;

my $sourcedir;
my $targetdir;
my $verbose = '';
my $res = '';
my $help = '';
my $key;
my $value;

my $sourcefiles = {};
my $targetfiles = {};

sub help {
  print "Help !!\n";
  exit
}

sub print_hash {
  print "---> print_hash start\n" if $verbose;
  my $hash = shift;
  if (ref($hash) != "HASH") { die "bad arg!" }
  print "$hash\n" if $verbose;
  print Dumper( $hash ) if $verbose;
  #while ( my ($key, $value) = each($hash)) {
  #      print "$key => $value\n";
  #  }
  print "---> print_hash end\n" if $verbose;
}

sub populate_hash {
 print "---> populate_hash start\n" if $verbose;
 my $dir =  shift;
 print "start dir: $dir\n" if $verbose;
 my $hash = {};
 #$files->{ 'key1' } = 'value1';
 #find({ preprocess => sub {grep { $_ !~ /\.AppleDouble/ } @_},
 #       wanted => \&do_files,}, $dir); 
 my $prune_dotdir = File::Finder->type('d')->name('.[tk]*')->prune;
 my $prune_kalle = File::Finder->type('d')->name('.k*')->prune;
 #my @files =  File::Finder->type('f')->not->name('.*')->in($dir);
 my @files =  $prune_dotdir->or->type('f')->not->name('.*')->in($dir);
 #print join(",",@files),"\n" if $verbose;
 foreach ( @files ){
   my $file = $_;
   open (my $fh, '<', $file) or die "Can't open '$file': $!";
   binmode ($fh);
   my $md5=Digest::MD5->new->addfile($fh)->hexdigest;
   close ($fh);
   $hash->{ $md5 } = $file;
   #print "$md5 $file\n" if $verbose;
 }
 print "---> populate_hash end\n" if $verbose;
 
 return $hash; 
}

sub do_files {
 print "---> do_files start\n" if $verbose;
 my $file = $_;
 return if -d $file;
 print "$File::Find::name\n" if $verbose;
 open (my $fh, '<', $file) or die "Can't open '$file': $!";
 binmode ($fh);
 my $md5=Digest::MD5->new->addfile($fh)->hexdigest;
 close ($fh);
 print "$md5 $file\n" if $verbose;
 #$files->{ $md5 } = $File::Find::name;
 print "---> do_files end\n" if $verbose;
}
die unless GetOptions ("sourcedir=s" => \$sourcedir,
                   "targetdir=s"   => \$targetdir,
		   "verbose"  => \$verbose ,
		   "help" => \$help);


help() if $help;
help() unless $sourcedir;
help() unless $targetdir;
print "sourcedir = $sourcedir\n" if $verbose;
print "targetdir = $targetdir\n" if $verbose;

$sourcefiles = populate_hash ($sourcedir);
print_hash ($sourcefiles) if $verbose;
$targetfiles = populate_hash ($targetdir);
print_hash ($targetfiles) if $verbose;

print "Checking for missing files in $targetdir \n";
while ( ($key, $value) = each(%$sourcefiles) ) {
  print $value," is missing in ", $targetdir, "\n" unless exists $targetfiles->{$key};
}

print "\nChecking for missing files in $sourcedir \n";
while ( ($key, $value) = each(%$targetfiles) ) {
  print $value," is missing in ", $sourcedir, "\n" unless exists $sourcefiles->{$key};
}
