
use strict;
use Test::More;
BEGIN { plan tests => 7 };
use Inline::Parrot::parrot;
ok(1, "use" ); 

#########################

{
    my $p = Inline::Parrot::parrot->new( 
        debug => 0,
    );
    isa_ok( $p, 'Inline::Parrot::parrot', "create process,");

    {

    # Test: hello world
    my $output = $p->compile_and_run( <<'    PARROT' );
_x0
.pcc_sub _x0
  print "parrot ok\n"
  .pcc_begin_return
  .pcc_end_return
.end
    PARROT
    like ( $output, qr/parrot ok/, 'prints to stdout' );
    }

    {
    ###################
    # "Test: compile only\n";
    my $output = $p->compile( <<'    PARROT' );
.pcc_sub _x0_1
  print "parrot ok\n"
  .pcc_begin_return
  .pcc_end_return
.end
    PARROT
    like ( $output, qr/\$\$compile\$\$/s, 'compile only' );
    # print "output:\n$output \n";
    }

    {
    ###################
    # print "Test: compile only, again\n";
    my $output = $p->compile( <<'    PARROT' );
.pcc_sub _x0_2
  print "parrot ok\n"
  .pcc_begin_return
  .pcc_end_return
.end
    PARROT
    like ( $output, qr/\$\$compile\$\$/s, 'compile only, again' );
    #print "output:\n$output \n";
    }

    {
    ###################
    # print "Test: single line\n";
    my $output = $p->compile_and_run( 
           "_x1\n.sub _x1\n print \"parrot ok\\n\" \n" .
           " invoke P1\n end\n.end" );
    like ( $output, qr/parrot ok/s, 'single-line code, prints to stdout' );
    # print "output:\n$output \n";
    }

    {
    ###################
    # print "Test: Call\n";
    my $output = $p->compile_and_run( <<'    PARROT' );
_x4
.pcc_sub _x4
  print "parrot call\n"
  find_global $P0, "_x0"
  defined $I1, $P0

  print "Defined "
  print $I1
  print "\n"

  .pcc_begin non_prototyped
    .pcc_call $P0
  .pcc_end

  .pcc_begin_return
  .pcc_end_return
.end
    PARROT
    like ( $output, qr/parrot ok/s, 'calls a previously defined sub' );
    # print "output:\n$output \n";
    }

}

__END__
