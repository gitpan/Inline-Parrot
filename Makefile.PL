#!perl -w

use strict;
use ExtUtils::MakeMaker;

# some code from Inline::Octave

my $octave;
# check if Parrot interpreter was specified on cmd line
foreach (@ARGV) {
   if (/^PARROT=(.+)/) {
      $octave= $1;
      $_= "";
   }
}   

unless ( defined $octave )
{
    # retrieve current configuration
    eval " use Inline::Parrot::parrot; ";
    $octave = $Inline::Parrot::parrot::parrot_interpreter_bin || "parrot";
    # clear "used only once" warning
    $Inline::Parrot::parrot::parrot_interpreter_bin =
        $Inline::Parrot::parrot::parrot_interpreter_bin;

    my $version = `$octave -V`;
    my $octave_validated = 1 
        if $version && $version =~ /parrot version (\d+\.\d+\.\d+)/is;
    my $octave_version = $1;

    if ($octave_validated) {
        print "Found parrot: [$octave] (version $octave_version)\n";
        $octave = prompt ( "Please enter new path to Parrot executable " .
                      "or <RETURN> to accept:", $octave );
    }
    else 
    {
        print "Unable to find parrot at: [$octave]\n";
        $octave = prompt ( "Please enter new path to Parrot executable:" );
    }
}

   print "\nFixing module parrot.pm for parrot path...\n" ;
   open(OCTAVE, "<lib/Inline/Parrot/parrot.pm") 
       or die "Can't open parrot.pm for reading" ;
   my @lines = <OCTAVE> ;
   close(OCTAVE) ;

   open(OCTAVE, ">lib/Inline/Parrot/parrot.pm") 
       or die "Can't open parrot.pm for writing" ;
   foreach my $line (@lines) {
      $line =~ 
         s{(\$parrot_interpreter_bin\s*=\s*)'.+?'(;\s*#\s*_EDITLINE_MARKER_)}
          {$1\'$octave\'$2};
      print OCTAVE $line ;
   }
   close(OCTAVE) ;


WriteMakefile(
    NAME              => 'Inline::Parrot',
    VERSION_FROM      => 'lib/Inline/Parrot.pm',
    PREREQ_PM         => { 'Inline' => 0 }, 
    ABSTRACT_FROM     => 'lib/Inline/Parrot.pm', 
    AUTHOR            => 'Flavio S. Glock <fglock@>',
);
