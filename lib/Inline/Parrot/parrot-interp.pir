
=head1 NAME

parrot-interp.pir - a Parrot "interpreter"

=head1 DESCRIPTION

This program provides an interface between a Perl process
and the Parrot compiler/VM.

=head1 AUTHOR

Flavio S. Glock, E<lt>fglock@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Flavio S. Glock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut


.macro print_int( I )
    unless I1, INT_END
    saveall
    $S11 = .I
    length $I9, $S11
    print $I9
    print "\n"
    print  $S11
    print  "\n"
    restoreall
    dec    I1
.endm

.macro print_str( S )
    unless I2, STRING_END 
    saveall
    length $I9, .S
    print $I9
    print "\n" 
    # .S = _encode__( .S )
    print  .S
    print  "\n"
    restoreall
    dec    I2
.endm

.macro print_pmc( P )
    unless I3, PMC_END 
    saveall
    isnull .P, .$IS_NULL
    goto .$NOT_NULL
  .local $IS_NULL:
    print -1
    print "\n"
    goto .$END_LINE
  .local $NOT_NULL:
    $S11 = .P
    length $I9, $S11
    print $I9
    print "\n" 
    # $S11 = _encode__( $S11 )
    print  $S11
  .local $END_LINE:
    print  "\n"
    restoreall
    dec    I3
.endm

.macro print_float( N )
    unless I4, FLOAT_END
    saveall
    $S11 = .N
    length $I9, $S11
    print $I9
    print "\n"
    print  $S11
    print  "\n"
    restoreall
    dec    I4
.endm

# START_PARROT

.pcc_sub _parrot_interpreter__
    .local pmc compiler
    .local string code

    # print "starting parrot\n"

    compreg compiler, "PIR"   # "PASM1"

L1:

    #----------
    # get the header into $S8 
    # the header declares the name of the subroutine to be immediately run
    #----------
    $S8 = ""
L8:
    read $S0, 1
    if $S0 == "\r" goto L8
    # print S0
    if $S0 == "\n" goto L8_1
    $S8 = $S8 . $S0
    branch L8
L8_1:
    #print "Sub name ["
    #print $S8
    #print "]\n"

    #----------
    # get the source code 
    #----------
    code = ""  # stores the code to be compiled
L2:
    $S7 = ""  # current program line
L3:
    read $S0, 1
    if $S0 == "\r" goto L3
    $S7 = $S7 . $S0
    if $S0 != "\n" goto L3    
    code = code . $S7
    if $S7 != "\n" goto L2

    #----------
    # compile the source code from S5 to P0
    # a compile error will make it die
    #----------
    print "$$start$$\n"

    # newsub P20, .Exception_Handler, _handler
    # set_eh P20
    
    compile $P0, compiler, code

    # err S1
    # print "Compile error: "
    # print S1
    # print "\n"

    # write $P0

    #----------
    # call whatever was compiled in P0
    # the entry point is the subroutine whose name is stored in $S8
    # a runtime error will make it die, or loop forever
    #----------

    #print "parrot call "
    #print $S8
    #print "\n"

    find_global $P0, $S8

    #defined I1, $P0

    #print "Defined "
    #print I1
    #print "\n"

    .pcc_begin prototyped
      .pcc_call $P0
    .pcc_end

    # clear_eh 

    # err S1
    # print "Invoke error: "
    # print S1
    # print "\n"

    #----------
    # tell the result to STDOUT
    #----------

    # send a newline, just in case - to keep our STDOUT tidy
    print "\n"
    print "$$ret$$\n"

    # I0 contents:
    #    1 if the sub is being called with fully prototyped parameters,
    #          including P/I/S/N counts. 
    #    0 if all the parameters are jammed in P registers and the 
    #          overflow array, with a count of parameters passed in PMC registers
    #   -1 if the count registers aren't filled in.

    if I0 == -1 goto NO_RETURN
    if I0 ==  0 goto PMC_RETURN
    if I0 ==  1 goto PROTOTYPED_RETURN

NO_RETURN:
    print  1   # prototyped?
    print  "\n"
    print  0   # int count
    print  "\n"
    print  0   # string count
    print  "\n"
    print  0   # pmc count
    print  "\n"
    print  0   # float count
    print  "\n"
    goto END_RETURN

PMC_RETURN:
    print  1   # prototyped?
    print  "\n"
    print  0   # int count
    print  "\n"
    print  0   # string count
    print  "\n"
    print  I3   # pmc count
    print  "\n"
    print  0   # float count
    print  "\n"
    goto SHOW_PMC

PROTOTYPED_RETURN:
    print  I0   # prototyped?
    print  "\n"
    print  I1   # int count
    print  "\n"
    print  I2   # string count
    print  "\n"
    print  I3   # pmc count
    print  "\n"
    print  I4   # float count
    print  "\n"

    # return integers
    .print_int( I5 )
    .print_int( I6 )
    .print_int( I7 )
    .print_int( I8 )
    .print_int( I9 )
    .print_int( I10 )
    .print_int( I11 )
    .print_int( I12 )
    .print_int( I13 )
    .print_int( I14 )
    .print_int( I15 )
INT_END:

    # return strings
    .print_str( S5 )
    .print_str( S6 )
    .print_str( S7 )
    .print_str( S8 )
    .print_str( S9 )
    .print_str( S10 )
    .print_str( S11 )
    .print_str( S12 )
    .print_str( S13 )
    .print_str( S14 )
    .print_str( S15 )
STRING_END:

SHOW_PMC:
    # return pmcs
    # TODO: check if they are printable   XXX
    .print_pmc( P5 )
    .print_pmc( P6 )
    .print_pmc( P7 )
    .print_pmc( P8 )
    .print_pmc( P9 )
    .print_pmc( P10 )
    .print_pmc( P11 )
    .print_pmc( P12 )
    .print_pmc( P13 )
    .print_pmc( P14 )
    .print_pmc( P15 )
PMC_END:
    if I0 == 0 goto OVERFLOW_PMC

    # return real numbers
    .print_float( N5 )
    .print_float( N6 )
    .print_float( N7 )
    .print_float( N8 )
    .print_float( N9 )
    .print_float( N10 )
    .print_float( N11 )
    .print_float( N12 )
    .print_float( N13 )
    .print_float( N14 )
    .print_float( N15 )
FLOAT_END:

OVERFLOW_PMC:
    # show flattened P3 array
LOOP_PMC:
    exists $I0, P3[0]
    unless $I0 goto OVERFLOW_PMC_END
    shift $P1, P3
    saveall
    $S11 = $P1
    length $I9, $S11
    print $I9
    print "\n" 
    print  $S11
    print  "\n"
    restoreall
    goto LOOP_PMC
OVERFLOW_PMC_END:

END_RETURN:

    #----------
    # tell that everything is ok
    # loop forever - or until STDIN is closed
    #----------
    print "$$end$$\n"

    #popi

    branch L1

#_handler:
    ## Error handler
    # print "Exception\n"
    # invoke P1  # end of subroutine

.end

