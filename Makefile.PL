#!perl -w

use 5.00503;
use strict;
use ExtUtils::MakeMaker;

my $octave;

# try to retrieve the current configuration

    eval " use Inline::Parrot::parrot; ";
    $octave = $Inline::Parrot::parrot::parrot_interpreter_bin || "parrot";

    # clear "used only once" warning
    $Inline::Parrot::parrot::parrot_interpreter_bin = 
        $Inline::Parrot::parrot::parrot_interpreter_bin;

# The following code was reused from Andy Adler's Inline::Octave

# Find parrot

my $octave_validated= 0;

# check if interpreter was specified on cmd line
foreach (@ARGV) {
   if (/^PARROT=(.+)/) {
      $octave= $1;
      $octave_validated= 1;
      $_= "";
   }
}   

while (not $octave_validated) {
   $octave_validated= 1 if `$octave -V` =~ /parrot version (\d+\.\d+\.\d+)/s;
   my $octave_version= $1;

   if ($octave_validated) {
      print "Found parrot:[$octave] (version $octave_version)\n";
      print "Enter new executable path or <RETURN> to accept: ";
   }
   else 
   {
      print "Unable to find parrot at:[$octave]\n";
      print "Please enter new path to executable: " ;

   }
   
   chomp( my $inp= <STDIN> );
   if ($inp) {
      $octave_validated= 0;
      $octave= $inp;
   }
}

#
# Rewrite parrot.pm 
#
   print "\nFixing parrot.pm for parrot path...\n" ;
   open(OCTAVE, "<lib/Inline/Parrot/parrot.pm") 
       or die "Can't open parrot.pm for reading" ;
   my @lines = <OCTAVE> ;
   close(OCTAVE) ;

   open(OCTAVE, ">lib/Inline/Parrot/parrot.pm") 
       or die "Can't open Octave.pm for writing" ;
   foreach my $line (@lines) {
      $line =~ 
         s{(\$parrot_interpreter_bin\s*=\s*)'.+?'(;\s*#\s*_EDITLINE_MARKER_)}
          {$1\'$octave\'$2};
      print OCTAVE $line ;
   }
   close(OCTAVE) ;


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Inline::Parrot',
    VERSION_FROM      => 'lib/Inline/Parrot.pm', # finds $VERSION
    PREREQ_PM         => { 'Inline' => 0 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Inline/Parrot.pm', # retrieve abstract from module
       AUTHOR         => 'Flavio S. Glock <fglock@>') : ()),
);
