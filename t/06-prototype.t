#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { plan tests => 4 };
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

1;

__END__
__Parrot__
.pcc_sub _hello   
    .param int a

    .local string s
    s = "done"
    .pcc_begin_return
    .return s
    .pcc_end_return
.end

.pcc_sub _hello_2   
    .local string s1
    s1 = "done"
    .local string s2
    s2 = "again"
    .pcc_begin_return
    .return s1
    .return s2
    .pcc_end_return
.end


