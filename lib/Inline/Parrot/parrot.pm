
package Inline::Parrot::parrot;

use strict;
use IPC::Open3 ();   # don't import open3
use IO::File;

use constant SELECT_TIMEOUT => 0.05;

use vars qw( $parrot_interpreter_bin );

# --- The following line is edited by the Makefile.PL script
$parrot_interpreter_bin = 'parrot'; # _EDITLINE_MARKER_

# --- TODO
#
# - separate compile() and run()
# - load_bytecode / load_code ... (?)
# - save_bytecode (?)
#
#

# --- DOCUMENTATION ON INTERNALS 

# object variables:
#   parrot_file_name   "parrot" filename. example: "/usr/bin/parrot"
#   @parrot_options    "parrot" command line options. example: qw( -d -t )
#   parrot_pid         Parrot process number
#   write_fh           file handle to write into Parrot STDIN
#   read_fh            file handle to read from Parrot STDOUT
#   error_fh           file handle to read from Parrot STDERR
#   is_open            is Parrot running
#   debug              be verbose

# the return value from compile_and_run() contains:
#   $$start$$
#   whatever was written to stdout
#
#   $$ret$$
#   to be defined
#   $$end$$
# but if a string was written to stdout without \n at the end:
#   $$start$$
#   whatever was written to stdout
#   $$ret$$
#   to be defined
#   $$end$$
# but if there was a compilation error:
#   $$start$$
# after an error, the interpreter is closed.
# If there is an attempt to use it again:
#   (dies)
#   can't print at (module name) line 237, <GEN1> line 50.

# the return value from compile() contains:
#   $$start$$
#   $$compile$$
#   $$ret$$
#   to be defined
#   $$end$$
# but if there was a compilation error:
#   $$start$$

# --- END DOCUMENTATION ON INTERNALS 


sub get_interpreter_code {
    my $path  = $INC{"Inline/Parrot/parrot.pm"};
    $path =~ s/parrot.pm/parrot-interp.pir/;
    return $path;
}

sub open { 
    my $self = shift;
    warn ref($self) . "->open\n" if $self->{debug};
    return if $self->{is_open};
    my $cmd = join ( ' ', 
        $self->{parrot_file_name},
        @{ $self->{parrot_options} },
        $self->{parrot_interpreter_file_name},
    ); 
    warn "    Command line: $cmd\n" if $self->{debug};
    $self->{write_fh} = new IO::File;
    $self->{read_fh}  = new IO::File;
    $self->{parrot_pid} = IPC::Open3::open3(
        $self->{write_fh}, 
        $self->{read_fh}, 
        $self->{read_fh},
       
        $self->{parrot_file_name},
        @{ $self->{parrot_options} },
        $self->{parrot_interpreter_file_name},
    );
    unless ($self->{parrot_pid}) {
        die "can't fork: $!";
    }
    warn "pid ".$self->{parrot_pid} if $self->{debug};
    $self->{is_open} = 1;
    return $self;
}

sub debug {
    warn ref($_[0]) . "->debug\n" if $_[1];
    die "not a class method" unless ref($_[0]);
    $_[0]->{debug} = $_[1];
    return $_[0];
}

sub compile {
    my $self = shift;
    my $code = shift;
    warn ref($self) . "->compile\n" if $self->{debug};

    my $header = '_just__compile__'          . "\n" . 
                 '.pcc_sub _just__compile__' . "\n" . 
                 '  print "$$compile$$\n"'   . "\n" . 
                 '  .pcc_begin_return'       . "\n" .
                 '  .pcc_end_return'         . "\n" .
                 '.end'                      . "\n" ;

    return $self->compile_and_run( $header . $code );
}

sub compile_and_run {
    my $self = shift;
    my $code = shift;
    my $data = shift;
    warn ref($self) . "->compile_and_run\n" if $self->{debug};
    die "parrot is not running" 
        unless $self->{is_open};

    $code =~ s/^\n+//sg;
    # my Parrot interpreter doesn't like blank lines
    $code =~ s/\n(?=\n)/\n /g;

    #my @header = split( /\s+/, $code );
    #my $sub_name = $header[1];

    #warn "Sub name $sub_name\n" if $self->{debug};
    #$code = $sub_name . "\n" . $code;

    $code = $code . "\n" unless $code =~ m/\n$/s;
    $code = $code . "\n";

    if ( $self->{debug} )
    {
        my $c = $code;
        # $c =~ s/\n/]\n/sg;
        warn "--- Invoke-start ---\n" . $c . "---- Invoke-end ----\n";
    }

    $self->{write_fh}->print( $code ) 
        or die "can't talk to Parrot process: $@";

    if ( defined $data )
    {
        $self->{write_fh}->print( $data ) 
            or die "can't talk to Parrot process: $@";
    }

    $self->{read_fh}->blocking(0);
    my $read = "";
    my $retry = 10;
    my $r = "";
    my $start_count = 0;
    while( $retry-- ) {
        $r = $self->{read_fh}->getline || "";
        # print "[$r]";
        $start_count++ if $r =~ m/\$\$start\$\$/s;
        last if $start_count > 2;
        select ( undef, undef, undef, SELECT_TIMEOUT ) unless $r;  # || $e;
        $retry++ if $r;  # || $e;
        $read .= $r;
        last if $r =~ m/\$\$end\$\$/s;
    }
    warn "Read: $read \n" 
        if $self->{debug};
    $self->close 
        unless ( $read =~ m/\$\$ret\$\$/s );
    return $read; 
}

sub close {
    my $self = shift;
    warn ref($self) . "->close\n" if $self->{debug};    
    return unless $self->{is_open};

    # tell Parrot to exit
##  my ($output, $error) = $self->compile_and_run( <<'PARROT' );
## .sub _x0
##        exit 0
## .end
## PARROT
##  warn "  ($output, $error) - exit \n" if $self->{debug};

    warn "closing handles\n" if $self->{debug};
    $self->{write_fh}->close;    # || die "bad pipe: $! $?";
    $self->{read_fh}->close;     # || die "bad pipe: $! $?";
    warn "wait pid\n" if $self->{debug};
    kill 9, $self->{parrot_pid};
    waitpid $self->{parrot_pid}, 0
        unless $^O =~ /win/i; # blocks I/O
    warn " closing => is_open = 0 \n"  if $self->{debug};
    $self->{is_open} = 0;
    return $self;
}

sub DESTROY {
    warn ref($_[0]) . "->DESTROY\n" if $_[0]->{debug};
    kill 9, $_[0]->{parrot_pid} if ref($_[0]);
    ## $_[0]->close;
}

sub new {
    my $class = shift;
    my %param = @_;
    my $self = bless {}, $class;
    $self->{parrot_file_name} = 
        $param{parrot_file_name} || 
        $parrot_interpreter_bin;
    $self->{parrot_interpreter_file_name} = 
        $param{parrot_interpreter_file_name} || 
        get_interpreter_code();
    $self->{parrot_options} =   $param{parrot_options} || [];
    die "parrot_options must be an array"
        unless ref( $self->{parrot_options} ) eq "ARRAY";
    $self->{is_open} = 0;
    $self->{debug} = 0;
    $self->debug( $param{debug} ) if $param{debug};
    $self->open();
    return $self;
}

1;

__END__


=head1 NAME

Inline::Parrot::parrot - a Parrot process

=head1 SYNOPSIS

    use Inline::Parrot::parrot;

    my $p = Inline::Parrot::parrot->new(
        parrot_file_name => 'parrot',
        parrot_interpreter_file_name => 'parrot-interp.pir',
        parrot_options => [],
        debug => 0,
    );

    my $output = $p->compile_and_run( <<'PARROT' );
  .pcc_sub _x0
            print "parrot ok\n"
            invoke P1
            end
  .end
  PARROT
    print "output:\n" . $output . "\n";

=head1 DESCRIPTION

This module provides an object-oriented, low-level interface to a Parrot process.

The API is a bit unstable.

=head1 METHODS

* new

Creates an Inline::Parrot::parrot object.

Default parameters:

  parrot_file_name => 'parrot',
  parrot_interpreter_file_name => 'parrot-interp.pir',
  parrot_options => [],
  debug => 0,
  
The default C<parrot_file_name> is determined at installation time by C<Makefile.PL>.

* compile( $string )

  my $status = $parrot->compile( $code );

Compiles the code, and leave the result in the Parrot process memory.

Returns a status string.
The string format definition is not stable - see the source code for details.

* compile_and_run( $string )

  my $status = $parrot->compile_and_run( $code );

Compiles the code, and leave the result in the Parrot process memory.
The first subroutine in the code is called.

The string format definition is not stable - see the source code for details.

Perl parameters are passed as specified in the Parrot Calling Conventions:
L<http://www.parrotcode.org/docs/pdd/pdd03_calling_conventions.html>

The first subroutine in the code is called using the sequence:

  find_global P0, "_subroutine_name"
  invokecc

Subroutines should return using code like this:

  invoke P1

or:

  .local string s
  s = "Goodbye"
  .pcc_begin_return
  .return s
  .pcc_end_return

* open

Starts the Parrot process.

C<open> is called automatically by C<new>.

If a process is already open, the command is ignored.

If a process cannot be open, the program dies.

* close

Closes the Parrot process.

If there is no open process, the command is ignored.

* debug

Controls the emission of debugging messages.

C<debug(1)> starts, C<debug(0)> stops. 

The contents of the messages is not stable.

* get_interpreter_code

Returns the location of the Parrot interpreter. This is a string like 
C<~/lib/Inline/Parrot/parrot-interpreter.pir>.

This is a class method.


=head1 SEE ALSO

L<Inline>

L<Inline::Parrot>

L<http://www.parrotcode.org>

=head1 AUTHOR

Flavio S. Glock, E<lt>fglock@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Flavio S. Glock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

