#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { plan tests => 8 };
use Inline Parrot;
ok(1); # If we made it this far, we're ok.   #'

#########################

# $Inline::Parrot::parrot->debug( 1 );

{
    my $result = _hello( "done\n" . chr(0) . chr(10) . chr(13) . '\\' . '"' . chr(255) );
    is( $result, 
        "done\n" . chr(0) . chr(10) . chr(13) . chr(92) . '"' . chr(255), 
        "returns 1 value" );
}

{
    my ( $result1, $result2 ) = _hello_2( 7 );
    is( $result1, 
        "done\n" . chr(0) . chr(10) . '\\' . '"' . chr(255),
        "returns 1st value" );
    is( $result2, "again\n", "returns 2nd value" );
}

{
    my $test = "1 2 3 4 5 6 7 8 9 10 11";
    my @result = _hello_3( split ( /\s+/, $test ) );
    is( scalar @result, 11,  "returns all values" );
    is( "@result", $test, "all values are ok" );
}

{
    my $s1 = "done\n\n\n\n\n";
    my $s2 = "\n\n\n\n\nagain\n";
    my ( $result1, $result2 ) = _hello_4( $s1, $s2 );
    is( $result1, 
        $s2,
        "returns 1st value" );
    is( $result2, $s1, "returns 2nd value" );
}

1;

__END__
__Parrot__
.pcc_sub _hello   
    .param string s1

    # print "data ["
    # print s1
    # print "]\n"

    .pcc_begin_return
    .return s1
    .pcc_end_return

    .local string s2
    s2 = s1
    print s1
    .pcc_begin_return
    .return s2
    .pcc_end_return
.end

.pcc_sub _hello_2   
    .local string s1
    s1 = "done\n"

    $I1 = 0
    chr $S1, $I1
    concat s1, $S1
 
    $I1 = 10
    chr $S1, $I1
    concat s1, $S1
 
    $I1 = 92
    chr $S1, $I1
    concat s1, $S1
 
    $I1 = 34
    chr $S1, $I1
    concat s1, $S1
 
    $I1 = 255
    chr $S1, $I1
    concat s1, $S1
 
    .local string s2
    s2 = "again\n"
    .pcc_begin_return
    .return s1
    .return s2
    .pcc_end_return
.end

.pcc_sub _hello_3
    # returns all values
    invoke P1
.end

.pcc_sub _hello_4
    .param string s1
    .param string s2

    .local string ss1
    .local string ss2
    ss1 = s1
    ss2 = s2

    .pcc_begin_return
    .return ss2
    .return ss1
    .pcc_end_return
.end

