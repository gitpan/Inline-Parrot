#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use Inline Parrot;
ok(1); # If we made it this far, we're ok.    #'

#########################

# $Inline::Parrot::parrot->debug( 1 );

_hello( 5 );

  _hello( 7 );

    _hello( 9 );

print "# done \n";

1;

__END__
__Parrot__

.pcc_sub _hello   
    .param int s
    print "ok # Value is "
    print s
    print "\n"
   
    .pcc_begin_return
    .pcc_end_return
.end

