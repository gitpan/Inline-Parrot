package Inline::Parrot;

use 5.00503;
use strict;

use Inline::Parrot::parrot;
require Inline;
use Carp;
use File::Spec;

use vars qw( $VERSION @ISA $parrot );
@ISA = qw( Inline );

BEGIN {
    $VERSION = '0.0802';
    $parrot = Inline::Parrot::parrot->new(
        # parrot_file_name => 'parrot',
        # parrot_interpreter_file_name => 'parrot-interp.pir',
        parrot_options => [],
        debug => 0,
    );
}

sub register {
    return {
        language => 'Parrot',
        aliases => ['parrot', 'pir'],
        type => 'interpreted',
        suffix => 'pir',
       };
}

sub usage_config { 
}

sub usage_config_bar { 
}

sub validate {
}

sub build {
    my $o = shift;
    my $code = $o->{API}{code};
    my $pattern = $o->{ILSM}{PATTERN};

    my $path = File::Spec->catdir(
        $o->{API}{install_lib},'auto',$o->{API}{modpname});
    my $obj = $o->{API}{location};
    $o->mkpath($path) unless -d $path;

    # my Parrot interpreter doesn't like blank lines
    $code =~ s/^\n/ \n/sg;
    $code =~ s/\n\n/\n \n/sg;

    # warn "saving code [ $code ] into file [ $obj ] \n";

    open PARROT_OBJ, "> $obj"
      or croak "Can't open $obj for output\n$!";
    print PARROT_OBJ $code;
    close \*PARROT_OBJ;
}

my @sub_name;
my %sub_param;
my %sub_prototyped;

sub load {
    my $o = shift;
    my $obj = $o->{API}{location};
    open PARROT_OBJ, "< $obj"
      or croak "Can't open $obj for output\n$!";
    my @code = <PARROT_OBJ>;
    close \*PARROT_OBJ;

    my $package = $o->{API}{pkg};
    
    # warn "Loaded [\n@code ]\n";
    # warn "Package $package\n";

    # --- parser ---
    # Look for ".pcc_sub" / ".param"
    my $sub_name = "";
    for ( @code )
    {
        if ( m/^\s*\.pcc_sub\s+(\w+)/ )
        {
             # prototyped == must use the parameter list  XXX
             # non_prototyped == use @_  XXX

             push @sub_name, $1;                
             $sub_name = $1;
             $sub_prototyped{ $sub_name } = m/\bprototyped\b/  ? "prototyped" : "non_prototyped";
            $sub_param{ $sub_name } = [];
        }
        
        if ( m/^\s*\.param\s+(\w+)\s+(\w+)/ )
        {
             push @{ $sub_param{ $sub_name } }, { type => $1, name => $2 };
        }                
    }
    
    # send the code to the Parrot compiler
    my ( $status, $error ) = $parrot->compile( join '' => @code );
    
    # print "Compiled $sub_name status: $status -- $error \n";
    my $inline_package = __PACKAGE__;
    
    for my $sub_name ( @sub_name )
    {
        my $perl_accessor = '

package '.$package.' ;
sub     '.$sub_name.'      {
    # warn "start parrot sub '.$sub_name.' \n";

    my $param = '.$inline_package.'::_setup_parrot_parameters( "'.$sub_name.'", @_ );

    my $cmd =
        ".pcc_sub _start_sub_'.$sub_name.'\n" .
        "  \$P1 = P1\n" .

        "  .local pmc sub\n" .
             $param .
        "    .pcc_call sub\n" .
        "  .pcc_end\n" .

        # don\'t mess with the return values
        # "  .pcc_begin_return\n" .
        # "  .pcc_end_return\n" .

        "  P1 = \$P1\n" .
        ".end\n" ;

    # print "cmd [ \n$cmd ] \n";
    my ( $status, $error ) = $Inline::Parrot::parrot->compile_and_run( $cmd );

    # print "parrot returned status [ $status -- $error ]\n";

    my ( $stdout, $return ) = $status =~ 
        m/\$\$start\$\$\n(.*)\n\$\$ret\$\$\n(.*)\$\$end\$\$/s;
    print $stdout if $stdout;
    # print STDOUT "Return: $return\n";
    my @return = split /\n/s , $return;

    # XXX
    my $prototyped = shift @return;
    my $int_count = shift @return;
    my $string_count = shift @return;
    my $pmc_count = shift @return;
    my $float_count = shift @return;

    # my @int_return = splice @return => 0, $int_count-1;
    # my @string_return = splice @return => 0, $string_count-1;
    # XXX

    # print "Return list: @return \n";
    # warn "end parrot sub '.$sub_name.' \n";
    return $return[0] unless $#return;
    return @return;
}
    ';

        # warn "Cmd [ $perl_accessor ]\n";
        eval $perl_accessor;
        croak "Unable to load Parrot module $sub_name:\n$@" if $@;
    }
}

sub info {
}

sub _setup_parrot_parameters {
    # print "Param list: @_ \n";

    my $sub_name = shift;
    # @_ = ( "test", 1233 );

    # return "" unless @_;

    my @param = @{ $sub_param{ $sub_name } };

    #    print "setting Sub $sub_name  $sub_prototyped{ $sub_name } \n";
    #    for my $param ( @param )
    #    {
    #        print "    $param->{name} is $param->{type} \n";
    #    }

    # TODO: add code for accepting arrays, hashes, references, callbacks
    
    my $param = "";
    my $param_count = scalar @_;
    
    $param .= "  find_global sub, \"$sub_name\" \n";

    # $param .= '
    #    defined I1, sub
    #    print "Defined "
    #    print I1
    #    print "\n"
    # ';

    for ( 0 .. $#_ ) 
    {
        my $def = $param[$_];
        my $val = $_[$_];
        if ( $def )
        {
            $param .= "  .local $def->{type} $def->{name}\n";
            $param .= "  $def->{name} = \"$val\"\n";
        }
        else
        {
            $param .= "  .local string var$_\n" . 
                      "  set  var$_, \"$val\"\n";
        }
    }

    $param .= "  .pcc_begin $sub_prototyped{ $sub_name } \n";
    for ( 0 .. $#_ ) 
    {
        my $def = $param[$_];
        my $val = $_[$_];
        if ( $def )
        {
            $param .= "    .arg $def->{name}\n";
        }
        else
        {
            $param .= "    .arg var$_\n";  
        }
    }
    
    # print "Param \n$param \n";
    return $param;
}

1;

__END__

# setting up a PMC

.sub _x
  new P0, .PerlString
  set P0, "aaa"
  end
.end

# sub types

.sub _x non_prototyped / prototyped

.pcc_sub _sub prototyped
    .param int a
    .param int b
    .local int c
    c = a + b
    .pcc_begin_return
    .return c            # what's c type ?
    .pcc_end_return
.end

.pcc_sub _sub non_prototyped
    .param int a
    print a
    ... 

=head1 NAME

Inline::Parrot - Inline Parrot code in Perl5

=head1 SYNOPSIS

  use Inline::Parrot;
  print "Start Perl\n";
  _hello();
  print "End Perl\n";

  __END__
  __Parrot__

  .pcc_sub _hello   
      print "Hello world\n"
      invoke P1 
  .end

=head1 DESCRIPTION

The Inline::Parrot module allows you to put Parrot source code directly 
"inline" in a Perl script or module.

=head1 CALLING CONVENTIONS

Perl parameters are passed as specified in the Parrot Calling Conventions.

L<http://www.parrotcode.org/docs/pdd/pdd03_calling_conventions.html>

=head1 GLOBAL VARIABLES

* C<$Inline::Parrot::parrot>

A Parrot interpreter object. 

See L<Inline::Parrot::parrot> for the available methods.

=head1 SEE ALSO

L<Inline> - the Inline module

L<http://www.parrotcode.org> - Parrot docs

L<Inline::Parrot::parrot> - a Parrot process class

L<http://www.perlmonks.org/?node_id=396890> - initial module idea

A. Randal, D. Sugalsky, L. Tötsch. 
I<Perl6 and Parrot Essentials>. 
2nd Edition.
O'Reilly, 2004.
ISBN 0-596-00747-X.

=head1 AUTHOR

Flavio S. Glock, E<lt>fglock@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Flavio S. Glock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut

