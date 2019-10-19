    'Program: MCommand
'Purpose: Processes a manual command waiting in the buffer
'Result: Manual Command is executed and buffer is reset
'History: Created 08/28/06
'           Modified 10/02/06 - Added start command & loop

'reset manual axis movement positions
'VR(97) = 0
'VR(98) = 0
VR(99) = 279.75 'Y2 Home
VR(100) = 0
VR(101) = 0
VR(95) = -1
VR(96) = -1
VR(91) = 0 ' Reset Voice Selection
VR(90) = 0 ' Reset Voice Trigger
VR(16) = 0 ' Reset Pause

VR(115) = 1 ' Trio Just Reset
VR(118) = 0 ' no movement
VR(39) = 0 ' reset currently plotting var
GLOBAL "dposx0",58
GLOBAL "dposy0",59
GLOBAL "xdir",56
GLOBAL "ydir",57
GLOBAL "dposx1",60
GLOBAL "dposy1",61
GLOBAL "txdir",67
GLOBAL "tydir",68
GLOBAL "newdeg",55
GLOBAL "olddeg",63

WA(500)

RUN "errorchecking",13

' This section should ONLY BE RUN ON STARTUP
' So we assume that we need to home because of logic loss
VR(5) = 0
VR(6) = 0
VR(7) = 0
VR(8) = 0
VR(9) = 0






WHILE 1 = 1
' If we are not moving and we are not plotting and remote is pressed
IF ((VR(118) <> 1) AND (VR(39) = 0) AND (IN(23) = 1)) THEN

' if we are homed then
IF (VR(5) = 2) AND (VR(6) = 2)AND(VR(7) = 2)AND(VR(8) = 2) AND (VR(9) = 2) THEN

       ' if it is a remote movement command
       IF (VR(123) = 1) THEN
     '   VR(96) = 2 ' Movement
      '  VR(95) = 1
         VR(91) = 70 ' Cycles through HMI to check axis status's
        VR(90) = 1
        VR(123) = 0 ' remove remote movement from buffer
       ELSEIF ((VR(125) = 1)) THEN' it is a remote job start if loaded job

        VR(91) = 75
        VR(90) = 1
        '  VR(96) = 1
      '  VR(95) = 1
       ENDIF
WAIT UNTIL IN(23) = 0
ELSE
    PRINT "Some axis not homed, will not allow remote start"
    VR(91) = 15
    VR(90) = 1
    WA(2000)
ENDIF

   ENDIF

    IF (VR(95) <> -1) THEN 'if the command has not been processed
        'VR(95) = 0 ' Set move command to processing level

    IF (VR(96) = -1) THEN ' If the buffer is initialized
        PRINT "Manual command not defined..."
    ELSE

        IF (VR(96) = 0) THEN
            'Reset Axis Errors

            'Turn off axes
            BASE(0)
            WDOG = 0
            SERVO = 0

            BASE(1)
            WDOG = 0
            SERVO = 0

            BASE(2)
            WDOG = 0
            SERVO = 0

            BASE(3)
            WDOG = 0
            SERVO = 0

            BASE(4)
            WDOG = 0
            SERVO = 0

            DATUM(0)

            BASE(0)
            SERVO = 1
            WDOG = 1

            BASE(1)
            SERVO = 1
            WDOG = 1

            BASE(2)
            SERVO = 1
            WDOG = 1

            BASE(3)
            SERVO = 1
            WDOG = 1

            BASE(4)
            SERVO = 1
            WDOG = 1

            'Re Enable Axes

        'Initiate Plot

        ELSEIF (VR(96) = 1) THEN
    IF( PROC_STATUS PROC(10) = 0) THEN
            VR(123) = 0 ' Remove remote movement command from buffer
        'start routine
            IF (IN(22) = 0) AND (VR(31) = 1) THEN
            VR(91) = 25
            VR(90) = 1

            ELSEIF (IN(30) = 0) AND (VR(32) = 1) THEN

            VR(91) = 26
            VR(90) = 1

            ELSE
                   RUN "parsedb2",10
                  WA(2000)

            ENDIF

        ENDIF
        'Initiate manual movement
        ELSEIF (VR(96) = 2) THEN
'VR(97) = 0
'VR(98) = 0
'VR(99) = 282 'Y2 Home
'VR(100) = 0
'VR(101) = 0
    BASE(0)
      IF (WDOG = 0) THEN
                RUN "startup",2
                WA(2000)
            ENDIF
VR(118) = 1 ' we are moving
IF (NOT IN(17)) THEN
OP(20,0)
OP(19,1)
WAIT UNTIL IN(17)
OP(19,0)
ENDIF

IF (NOT IN(25)) THEN
OP(28,0)
OP(27,1)
WAIT UNTIL IN(25)
OP(27,0)
ENDIF


        IF (IN(12) = 0) THEN
            RUN "enableys",9
        ENDIF
        OP(31,1)
        ' if Y1 Enabled
        IF (VR(31) = 1) THEN
              WAIT UNTIL (IN(12))
        ENDIF
        IF (VR(32) = 1) THEN
              WAIT UNTIL (IN(13))
        ENDIF
        WAIT UNTIL(PROC_STATUS PROC(12) = 0)

        VR(40) = 1 ' No voice latch
        VR(91) = 7 ' HMI Command
        VR(90) = 1 ' HMI Command

 WA(5000)
         RUN "pause",12

        IF ((VR(31) = 1) AND (VR(32) = 1)) THEN
            BASE(0,1,2)
        SPEED = 20
        ACCEL = 10
        DECEL = 10

        ' calculates relative movement based on an integer rather than float
        MOVE(VR(97) - INT(VR(102)),VR(98)-INT(VR(103)) ,VR(99)- INT(VR(104)))

        ELSEIF (VR(31) = 1) THEN
            BASE(0,1)
        SPEED = 20
        ACCEL = 10
        DECEL = 10
        MOVE(VR(97) - INT(VR(102)),VR(98)-INT(VR(103)))

'            MOVEABS(VR(97),VR(98))

        ELSEIF (VR(32) = 1) THEN
            BASE(0,2)
        SPEED = 20
        ACCEL = 10
        DECEL = 10
        MOVE(VR(97) - INT(VR(102)),VR(99)- INT(VR(104)))

'             MOVEABS(VR(97),VR(99))

        'X Only MOvement
        ELSEIF ((VR(31) = 0) AND (VR(32) = 0)) THEN
            BASE(0)
            SPEED = 20
            ACCEL = 10
            DECEL = 10
            MOVE(VR(97) - INT(VR(102)))
        ENDIF


'        IF ((350 > VR(97) >= 0) AND (270 > VR(98) >= 0)) THEN

    '    ENDIF
            WAIT IDLE
            ' if homes are triggered on Y's
            IF (IN(10) OR IN(7)) THEN
                IF (IN(10)) THEN
                    BASE(2)
                    SPEED = 5
                    ACCEL = 5
                    DECEL = 5
                    MOVEABS(276.67)
                    WAIT IDLE
                ENDIF
                IF (IN(7)) THEN
                    BASE(1)
                    SPEED = 5
                    ACCEL = 5
                    DECEL = 5
                    MOVEABS(0)
                    WAIT IDLE
                ENDIF
            ENDIF
            STOP "pause"

            WAIT UNTIL(PROC_STATUS PROC(9) = 0)
            RUN "enableys",9
            OP(31,0)
        IF (VR(15) = 0) THEN
            VR(91) = 8
            VR(90) = 1
    ENDIF
        VR(40) = 0
            VR(118) = 0 'we Are not moving
    ELSEIF (VR(96) = 3) THEN ' Gluepot Head A
        IF (IN(22) = 1) THEN

            OP(22,0)
        ELSE
            OP(22,1)
        ENDIF
    ELSEIF (VR(96) = 4) THEN ' Gluepot Head B
        IF (IN(30) = 1) THEN

            OP(30,0)
        ELSE
            OP(30,1)
        ENDIF

    ELSEIF (VR(96) = 5) THEN ' Raise / Lower Head A
        IF (IN(18) = 1) THEN ' If head A is confirmed down
            OP(21,0) ' Turn Off Air
            OP(20,0) ' Turn off Down Solenoid
            OP(19,1) ' Turn On Up Solenoid
            WAIT UNTIL (IN(17) = 1)
            OP(19,0)
        ELSE
            OP(19,0)
            OP(20,1)
            WAIT UNTIL (IN(18) = 1)
           OP(21,1)
'            OP(20,0)
        ENDIF
    ELSEIF (VR(96) = 6) THEN ' Raise / Lower Head B
        IF (IN(26) = 1) THEN ' If head B is confirmed down
            OP(28,0)
            OP(29,0)
            OP(27,1)
            WAIT UNTIL (IN(25) = 1)

            OP(27,0)
        ELSE
            OP(27,0)
            OP(28,1)
            WAIT UNTIL (IN(26) = 1)
           OP(29,1)

        ENDIF
       ELSEIF (VR(96) = 7) THEN ' Run Y Enable Program
            RUN "enableys",9
        ELSEIF (VR(96) = 8) THEN ' Run Y Enable Program
            IF (WDOG = 0) THEN
                RUN "startup",2
                WA(2000)
            ENDIF
            RUN "homing",3
            BASE(0)
            WA(1000)
            WAIT IDLE
            BASE(1)

            WA(1000)
            WAIT IDLE
            BASE(2)
            WA(1000)

            WAIT IDLE
            BASE(3)
            WA(1000)

            WAIT IDLE
            WA(1000)
            BASE(4)
            WAIT IDLE
            WA(1000)
            BASE(5)
            WAIT IDLE
 ELSEIF (VR(96) = 9) THEN ' Raise / Lower Head A w/o Air
        IF (IN(18) = 1) THEN ' If head A is confirmed down
            OP(21,0) ' Turn Off Air
            OP(20,0) ' Turn off Down Solenoid
            OP(19,1) ' Turn On Up Solenoid
            WAIT UNTIL (IN(17) = 1)
            OP(19,0)
        ELSE
            OP(19,0)
            OP(20,1)
            WAIT UNTIL (IN(18) = 1)
            ' OP(21,1)
'            OP(20,0)
        ENDIF
    ELSEIF (VR(96) = 10) THEN ' Raise / Lower Head B w/o Air
        IF (IN(26) = 1) THEN ' If head B is confirmed down
            OP(28,0)
            OP(29,0)
            OP(27,1)
            WAIT UNTIL (IN(25) = 1)

            OP(27,0)
        ELSE
            OP(27,0)
            OP(28,1)
            WAIT UNTIL (IN(26) = 1)
    '           OP(29,1)

        ENDIF
  ELSEIF (VR(96) = 11) THEN ' Toggle head A cooling nosels
       IF (IN(21)) THEN
        OP(21,0)
       ELSE
        OP(21,1)
       ENDIF
     ELSEIF (VR(96) = 12) THEN ' Toggle head B cooling nosels
       IF (IN(29)) THEN
        OP(29,0)
       ELSE
        OP(29,1)
       ENDIF
  ELSEIF (VR(96) = 13) THEN ' Toggle side lights
       IF (IN(31)) THEN
        OP(31,0)
       ELSE
        OP(31,1)
       ENDIF
ELSEIF (VR(96) = 14) THEN ' Reset Controller
    EX ' Reset the controller to a default state

ELSEIF (VR(96) = 15) THEN ' Clear axis status error
    BASE(0)
    DATUM(0)
    IF (MOTION_ERROR = 0) THEN

        RUN "startup",2
        WA(2000)
 VR(91) = 17
        VR(90) = 1
        VR(15) = 0
    ENDIF
       ENDIF 'case

    'Reset manual command variables
    VR(95) = -1
    VR(96) = -1
ENDIF
ENDIF

WEND
