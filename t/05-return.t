#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { plan tests => 6 };
use Inline Parrot;
ok(1); # If we made it this far, we're ok.   #'

#########################

# $Inline::Parrot::parrot->debug( 1 );

{
    my $result = _hello( 5 );
    is( $result, "done", "returns 1 value" );
}

{
    my ( $result1, $result2 ) = _hello_2( 7 );
    is( $result1, "done",  "returns 1st value" );
    is( $result2, "again", "returns 2nd value" );
}

{
    # my $test = "1 2 3 4 5 6 7 8 9 10 11";
    my $test = "1 2 3 4 5";
    my @result = _hello_3( split ( /\s+/, $test ) );
    is( scalar @result, 5,  "returns all values" );
    is( "@result", $test, "all values are ok" );
}

1;

__END__
__Parrot__
.pcc_sub _hello   
    .param string s
    # print "ok # Value is "
    # print s
    # print "\n"
    s = "done"
    .pcc_begin_return
    .return s
    .pcc_end_return
.end

.pcc_sub _hello_2   
    # print "ok # Value is "
    # print s
    # print "\n"

    .local string s1
    s1 = "done"
    .local string s2
    s2 = "again"
   
    .pcc_begin_return
    .return s1
    .return s2
    .pcc_end_return
.end

.pcc_sub _hello_3
    .param int i1
    .param int i2
    .param int i3
    .param int i4
    .param int i5

    .pcc_begin_return
    .return i1
    .return i2
    .return i3
    .return i4
    .return i5
    .pcc_end_return
.end

