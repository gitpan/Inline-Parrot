
use Test::More;
BEGIN { plan tests => 6 };
use Inline Parrot;
ok(1); # If we made it this far, we're ok.   #'

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
    my @result = _overflow();
    is( "@result", 
        "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19", 
        "overflow return values" );
}

{
    my @result = _overflow_param( 
        qw( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 ) );
    is( "@result", 
        "1 10 11 12 13 19", 
        "overflow param values" );
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

.pcc_sub _overflow
    .pcc_begin_return
    .return 1
    .return 2
    .return 3
    .return 4
    .return 5
    .return 6
    .return 7
    .return 8
    .return 9
    .return 10
    .return 11
    .return 12
    .return 13
    .return 14
    .return 15
    .return 16
    .return 17
    .return 18
    .return 19
    .pcc_end_return
.end

.pcc_sub _overflow_param
    .param int a1
    .param int a2
    .param int a3
    .param int a4
    .param int a5
    .param int a6
    .param int a7
    .param int a8
    .param int a9
    .param int a10
    .param int a11
    .param int a12
    .param int a13
    .param int a14
    .param int a15
    .param int a16
    .param int a17
    .param int a18
    .param int a19

    .pcc_begin_return
    .return a1
    .return a10
    .return a11
    .return a12
    .return a13
    .return a19
    .pcc_end_return
.end

