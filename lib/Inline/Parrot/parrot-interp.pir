
.macro print_int( I )
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
    saveall
    $S11 = .P
    length $I9, $S11
    print $I9
    print "\n" 
    # $S11 = _encode__( $S11 )
    print  $S11
    print  "\n"
    restoreall
    dec    I3
.endm

.macro print_float( N )
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

    # send a newline, just in case - to keep our STDOUT tidy
    print "\n"

    #----------
    # tell the result to STDOUT
    #----------
    print "$$ret$$\n"

    # TODO - show result

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

    # TODO - non-prototyped return

    # return integers

    unless I1, INT_END
    .print_int( S5 )
    unless I1, INT_END
    .print_int( S6 )
    unless I1, INT_END
    .print_int( S7 )
    unless I1, INT_END
    .print_int( S8 )
    unless I1, INT_END
    .print_int( S9 )
    unless I1, INT_END
    .print_int( S10 )
    unless I1, INT_END
    .print_int( S11 )
    unless I1, INT_END
    .print_int( S12 )
    unless I1, INT_END
    .print_int( S13 )
    unless I1, INT_END
    .print_int( S14 )
    unless I1, INT_END
    .print_int( S15 )

INT_END:

    # return strings

    unless I2, STRING_END 
    .print_str( S5 )
    unless I2, STRING_END 
    .print_str( S6 )
    unless I2, STRING_END 
    .print_str( S7 )
    unless I2, STRING_END 
    .print_str( S8 )
    unless I2, STRING_END 
    .print_str( S9 )
    unless I2, STRING_END 
    .print_str( S10 )
    unless I2, STRING_END 
    .print_str( S11 )
    unless I2, STRING_END 
    .print_str( S12 )
    unless I2, STRING_END 
    .print_str( S13 )
    unless I2, STRING_END 
    .print_str( S14 )
    unless I2, STRING_END 
    .print_str( S15 )

STRING_END:

    # return pmcs
    # TODO: check if they are printable   XXX

    unless I3, PMC_END 
    .print_pmc( P5 )
    unless I3, PMC_END 
    .print_pmc( P6 )
    unless I3, PMC_END 
    .print_pmc( P7 )
    unless I3, PMC_END 
    .print_pmc( P8 )
    unless I3, PMC_END 
    .print_pmc( P9 )
    unless I3, PMC_END 
    .print_pmc( P10 )
    unless I3, PMC_END 
    .print_pmc( P11 )
    unless I3, PMC_END 
    .print_pmc( P12 )
    unless I3, PMC_END 
    .print_pmc( P13 )
    unless I3, PMC_END 
    .print_pmc( P14 )
    unless I3, PMC_END 
    .print_pmc( P15 )

PMC_END:

    # return real numbers

    unless I4, FLOAT_END
    .print_float( N5 )
    unless I4, FLOAT_END
    .print_float( N6 )
    unless I4, FLOAT_END
    .print_float( N7 )
    unless I4, FLOAT_END
    .print_float( N8 )
    unless I4, FLOAT_END
    .print_float( N9 )
    unless I4, FLOAT_END
    .print_float( N10 )
    unless I4, FLOAT_END
    .print_float( N11 )
    unless I4, FLOAT_END
    .print_float( N12 )
    unless I4, FLOAT_END
    .print_float( N13 )
    unless I4, FLOAT_END
    .print_float( N14 )
    unless I4, FLOAT_END
    .print_float( N15 )

FLOAT_END:

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

