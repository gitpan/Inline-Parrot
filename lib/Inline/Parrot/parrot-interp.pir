
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

    # TODO - use "Indirect PMC register set" - setx_ind   XXX

    # TODO - non-prototyped return

    # return integers

    unless I1, INT_END 
    print  I5
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I6
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I7
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I8
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I9
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I10
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I11
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I12
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I13
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I14
    print  "\n"
    dec    I1


    unless I1, INT_END 
    print  I15
    print  "\n"
    dec    I1

INT_END:

    # return strings

    unless I2, STRING_END 
    print  S5
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S6
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S7
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S8
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S9
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S10
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S11
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S12
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S13
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S14
    print  "\n"
    dec    I2


    unless I2, STRING_END 
    print  S15
    print  "\n"
    dec    I2

STRING_END:

    # return pmcs
    # TODO: check if they are printable   XXX

    unless I3, PMC_END 
    print  P5
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P6
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P7
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P8
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P9
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P10
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P11
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P12
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P13
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P14
    print  "\n"
    dec    I3


    unless I3, PMC_END 
    print  P15
    print  "\n"
    dec    I3

PMC_END:

    # TODO: float results   XXX

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
