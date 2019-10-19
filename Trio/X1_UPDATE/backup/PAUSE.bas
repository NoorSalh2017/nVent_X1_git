VR(16) = 0
VR(40) = 0 'set to 1 to skip resume voice

VR(118) = 1 'we Are moving

WHILE 1 = 1


VR(23) = 0

' One giant or statement - Conditions for entering Pause loop
IF (MTYPE AXIS(0) <> 0) THEN VR(23) = 1
IF (MTYPE AXIS(1) <> 0) THEN VR(23) = 1
IF (MTYPE AXIS(2) <> 0) THEN VR(23) = 1
IF (MTYPE AXIS(4) <> 0) THEN VR(23) = 1
IF (MTYPE AXIS(5) <> 0) THEN VR(23) = 1
IF (VR(23) OR VR(16) OR VR(17)) THEN ' if there is movement on any axis or in pa
VR(23) = 0
IF ((IN(32) = 1) AND (VR(16) = 0)) THEN VR(23) = 4
IF ((IN(33) = 1) AND (VR(16) = 0)) THEN VR(23) = 5

IF ((IN(3) = 0) AND( VR(16) =0))THEN VR(23) = 2
IF ((IN(4) = 0) AND( VR(16) =0))THEN VR(23) = 3
IF (VR(16) = 1) THEN VR(23) = 1
IF (IN(23) = 1) THEN VR(23) = 1
IF (VR(17) = 1) THEN VR(23) = 1
ENDIF
'end giant OR statement

IF (VR(23) <> 0) THEN
    WAIT UNTIL ((MTYPE AXIS(0) <> 4)AND(MTYPE AXIS(1)<>4)AND(MTYPE AXIS(2)<>4))
  '  WAIT UNTIL (VR(81) = 0)
    IF (VR(40) = 0) THEN
            IF (VR(23) = 2) THEN
                VR(91) = 12
            ELSEIF (VR(23) = 3) THEN
                VR(91) = 11
            ELSEIF (VR(23) = 4) THEN
                VR(91) = 19 ' Swapped for x2 18
            ELSEIF (VR(23) = 5) THEN
                VR(91) = 18 ' Swapped for x2 19

            ELSE
                VR(91) = 0 'Vehcile Paused
            ENDIF
            VR(90) = 1
    ENDIF
    VR(16) = 1
    IF (VR(17) <> 1) THEN
        VR(18) = SPEED AXIS(0)
        VR(19) = SPEED AXIS(1)
        VR(20) = SPEED AXIS(2)
        VR(21) = SPEED AXIS(4)
        VR(22) = SPEED AXIS(5)
        VR(24) = DECEL AXIS(0)
        DECEL AXIS(0) = 175
        SPEED AXIS(0) = 0
        SPEED AXIS(1) = 0
        SPEED AXIS(2) = 0
        SPEED AXIS(4) = 0
        SPEED AXIS(5) = 0
        OP(35,1)
       'enters routine and in23 is still high so makes sure it switches off
        IF (PROC_STATUS PROC(4) = 0) THEN RUN "dolights",4
        WAIT UNTIL (IN(23) = 0)

'If it was a proximity laser then pause for atleast 5 seconds
IF (VR(23) = 2) OR (VR(23) = 3) THEN
 WA(5000)
ENDIF
        'Wait until pause is pressed again or stop is pressed
WAIT UNTIL (((IN(23)=1)OR(VR(16)=0))AND((IN(3)=1)AND(IN(4)=1)))OR(VR(17)=1)
    OP(35,0)
    ENDIF 'If it is stoped skip the speed storing proecdure
    'If stopped
    IF(VR(17) = 1) THEN
        VR(91) = 5
        VR(90) = 1
        STOP "parsedb2"
        STOP "homing"
        BASE(3)
        ' If connected
        IF (MTYPE = 21) THEN
            CANCEL
            CANCEL
        ENDIF

        BASE(0,1)
        RAPIDSTOP
        RAPIDSTOP
        CANCEL
        CANCEL
        CANCEL
        SPEED = 20
        ACCEL = 10
        DECEL = 10

        OP(21,0) 'Turn off cooling air
        OP(29,0)

        STOP "zthetamonitor"
        'If the head is not in the up position
        IF (IN(17) <> 1) THEN
            OP(20,0)
            OP(19,1)
            'add time delay for errors
            WAIT UNTIL (IN(17) AND NOT IN(18))
            OP(19,0)
        ENDIF

        'If the head is not in the up position
        IF (IN(25) <> 1) THEN
            OP(28,0)
            OP(27,1)
            'add time delay for errors
            WAIT UNTIL (IN(25) AND NOT IN(26))
            OP(27,0)
        ENDIF
' If it was a double job
        IF (VR(34) = 1) THEN
        BASE(4)
        CANCEL
        CANCEL
        BASE(5)
        CANCEL
        CANCEL

        BASE(4,5)
        SPEED = 90
        ACCEL = 100
        DECEL = 100
        MOVEABS(-90,-90)


        ELSE ' Else it was not a double job
        IF (VR(120) = 1) THEN ' If Y1 enabled
        BASE(5)
        CANCEL
        CANCEL
        SPEED = 90
        ACCEL = 100
        DECEL = 100
        MOVEABS(-90)
        ENDIF
        IF (VR(121) = 1) THEN ' If Y2 Enabled
        BASE(4)
        CANCEL
        CANCEL
        SPEED = 90
        ACCEL = 100
        DECEL = 100
        MOVEABS(-90)
        ENDIF

        WAIT IDLE
        ENDIF

        ' if y's are enabled
        BASE(1)
        OP(12,0)
        SERVO = 0
        BASE(2)
        OP(13,0)
        SERVO = 0
BASE(4)
        OP(14,0)

        SERVO = 0
        BASE(5)
        OP(15,0)

        SERVO = 0

        VR(39) = 0
        VR(16) = 0
        STOP "dolights"
        OP(31,0)
        VR(118) = 0 'we Are not moving
        STOP "pause"
    ELSE

    VR(16) = 0

    IF(VR(40) = 0) THEN
     VR(91) = 1 'Vehcile Resuming
     VR(90) = 1
    ELSE
        VR(40) = 0
    ENDIF
    SPEED AXIS(0) = VR(18)
    SPEED AXIS(1) = VR(19)
    SPEED AXIS(2) = VR(20)
    SPEED AXIS(4) = VR(21)
    SPEED AXIS(5) = VR(22)

    DECEL AXIS(0) = VR(24)

    ENDIF 'if not stopped
    'prevents routine from reentering on first if statement when button is held
    IF (IN(23) = 1) THEN
        WA(750)
    ENDIF
'    WAIT UNTIL (IN(23) = 0)

ENDIF



WEND
