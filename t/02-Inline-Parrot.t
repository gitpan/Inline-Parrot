# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Inline-Parrot.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
# use Inline::Files;
use Inline Parrot;
ok(1); # If we made it this far, we're ok.

#########################

# $Inline::Parrot::parrot->debug( 1 );

_hello();

  _hello();

    _hello();

print "# done \n";

1;

__END__
__Parrot__

.pcc_sub _hello   
    print "ok # Hello world\n"
    .pcc_begin_return
    .pcc_end_return
.end

