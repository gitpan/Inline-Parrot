#!perl -w

use strict;
use Module::Build;

# some code from Inline::Octave

my $parrot;
# check if Parrot interpreter was specified on cmd line
foreach (@ARGV) {
   if (/^PARROT=(.+)/) {
      $parrot= $1;
      $_= "";
   }
}   

unless ( defined $parrot )
{
    # retrieve current configuration
    eval " use Inline::Parrot::parrot; ";
    $parrot = $Inline::Parrot::parrot::parrot_interpreter_bin || "parrot";
    # clear "used only once" warning
    $Inline::Parrot::parrot::parrot_interpreter_bin =
        $Inline::Parrot::parrot::parrot_interpreter_bin;

    my $version = `$parrot -V`;
    my $parrot_validated = 1 
        if $version && $version =~ /parrot version (\d+\.\d+\.\d+)/is;
    my $parrot_version = $1;

    if ($parrot_validated) {
        print "Found parrot: [$parrot] (version $parrot_version)\n";
        $parrot = Module::Build->prompt ( "Please enter new path to Parrot executable " .
                      "or <RETURN> to accept:", $parrot );
    }
    else 
    {
        print "Unable to find parrot at: [$parrot]\n";
        $parrot = Module::Build->prompt ( "Please enter new path to Parrot executable:" );
    }
}

   print "\nFixing module parrot.pm for parrot path...\n" ;
   open(PARROT, "<lib/Inline/Parrot/parrot.pm") 
       or die "Can't open parrot.pm for reading" ;
   my @lines = <PARROT> ;
   close(PARROT) ;

   open(PARROT, ">lib/Inline/Parrot/parrot.pm") 
       or die "Can't open parrot.pm for writing" ;
   foreach my $line (@lines) {
      $line =~ 
         s{(\$parrot_interpreter_bin\s*=\s*)'.+?'(;\s*#\s*_EDITLINE_MARKER_)}
          {$1\'$parrot\'$2};
      print PARROT $line ;
   }
   close(PARROT) ;


Module::Build->new
    ( module_name => 'Inline::Parrot',
      author      => 'Flavio S. Glock <fglock@cpan.org>',
      license     => 'perl',
      requires    => { 'Inline' => 0 },
      # sign        => 1,
      # create_makefile_pl => 'passthrough',
      pm_files    => { 'lib/Inline/Parrot/parrot-interp.pir' => 
	               'lib/Inline/Parrot/parrot-interp.pir' },
    )->create_build_script;
