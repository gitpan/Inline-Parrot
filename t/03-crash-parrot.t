#########################

use strict;
use Test::More;
BEGIN { plan tests => 4 };
use Inline::Parrot::parrot;
ok(1, "use" ); 

#########################

# These tests should make Parrot die "cleanly"

##########################
# "Syntax Error" tests

{
    my $p = Inline::Parrot::parrot->new(
        parrot_file_name => 'parrot',
        parrot_interpreter_file_name => 'parrot-interp.pir',
        parrot_options => [],
        debug => 0,
    );
    isa_ok( $p, 'Inline::Parrot::parrot', "create process,");

    ###################
    # print "Test: Syntax Error\n";
    eval {
        my ($output, $error) = $p->compile_and_run( <<'PARROT' );
.sub _x2
            error
            print "parrot error\n"
            invoke P1
            end
.end
PARROT
        # print "output:\n$output \n";
        # print "error:  $error \n";
    };

    # print "# Error: $@\n" if $@;

    # print STDERR "# Error code: $@ \n";

    ok( 1, "syntax error doesn't make it hang" );

    ###################
    # print "Test: Syntax Error, compile only\n";
    eval {
        my ($output, $error) = $p->compile( <<'PARROT' );
.sub _x2
            error
            print "parrot error\n"
            invoke P1
            end
.end
PARROT
        # print "output:\n$output \n";
        # print "error:  $error \n";
    };

    # print "# Error: $@\n" if $@;

    ok( 1, "a second syntax error doesn't make it hang" );    

    # print "done.\n";
}

1;

