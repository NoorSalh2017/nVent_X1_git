VR(39) = 1
VR(65) = 550
VR(120) = VR(31) ' Store Y1 Enable
VR(121) = VR(32) ' Store Y2 Enable

VR(90) = 0 ' Reset voice commands
VR(91) = -1

VR(16) = 0 ' Reset pause
VR(17) = 0 ' Reset stop button

IF (VR(120) = 1) THEN

    BASE(1)
    SERVO = 1
    WDOG = 1
    OP(12,1)
    BASE(4)
    SERVO = 1
    WDOG = 1
    OP(14,1)

ENDIF
IF (VR(121) = 1) THEN
    BASE(2)
    SERVO = 1
    WDOG = 1
    OP(13,1)
    BASE(5)
    SERVO = 1
    WDOG = 1
    OP(15,1)
ENDIF

'VR(40) = 1 ' set plotting variable to plotting
'RUN "enableys",9
RUN "pause",12

VR(81) = 0 'Set Section Load Trigger to 0

VR(110) = 0
VR(111) = 0

IF (VR(120) = 1) OR(VR(34) = 1) THEN
    BASE(0,1)
ELSE
    BASE(0,2)
ENDIF


OP(31,1)

'Reset Z
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

OP(19,0)
OP(20,0)
OP(27,0)
OP(28,0)

'reset erroneous connect statements
BASE(2)
CANCEL
CANCEL


IF (VR(120) = 1) OR(VR(34) = 1) THEN
    BASE(0,1)
ELSEIF (VR(121) = 1) THEN
    BASE(0,2)
ENDIF

'vr(82) = 0 'Test setting

VR(80) = 0 'section to start in
WA(250)
VR(81) = 1 ' Load section
WA(250)
WAIT UNTIL (VR(81) = 0)

PRINT #7, "Loaded: ", VR(80)

VR(76) = 0 ' Loop exit variable, exits the program and stops

'Global loop to continue to process until exit is requested
WHILE VR(76) = 0

    VR(66) = 0 ' Internal 50 Line Count Loop Reset


    'Internal 50 line count loop
    WHILE ((VR(66) < 50) AND (VR(76) = 0) )

       IF (VR(66) = 0) THEN
           VR(80) = VR(80)+1
           WA(250)
           VR(81) = 1
           PRINT #7, "Loaded: ", VR(80)
       ELSEIF (VR(66) = 26) THEN
           WAIT UNTIL (VR(81) = 0)
           VR(80) = VR(80)+1
           WA(250)
           VR(81) = 1
           PRINT #7, "Loaded: ", VR(80)
       ENDIF

       WAIT UNTIL VR(16) = 0 'Wait until we are not in pause mode

       'Set X & Y Varibles for processing
       VR(71) = VR( (VR(65)+(VR(66)*9)+1) ) + VR( (VR(65)+(VR(66)*9)+2) )/10000
       VR(72) = VR( (VR(65)+(VR(66)*9)+3) ) + VR( (VR(65)+(VR(66)*9)+4) )/10000
       VR(73) = VR( (VR(65)+(VR(66)*9)+5) ) + VR( (VR(65)+(VR(66)*9)+6) )/10000
       VR(74) = VR( (VR(65)+(VR(66)*9)+7) ) + VR( (VR(65)+(VR(66)*9)+8) )/10000

       VR(71) = VR(71)+(VR(126)+(VR(127)/10000))
       VR(72) = VR(72)+(VR(128)+(VR(129)/10000))
       VR(73) = VR(73)+(VR(126)+(VR(127)/10000))
       VR(74) = VR(74)+(VR(128)+(VR(129)/10000))
       PRINT #7, "Line: ", VR(66)


       ' Filters jobs that are not loaded
       IF (VR( VR(65)+(VR(66)*9) ) = -1) THEN

           VR(76) = 2 ' Sets exit variable to 2 to say voice when not loaded

       ' Else if this is a line
       ELSEIF (VR( (VR(65)+(VR(66)*9)) ) = 0) THEN


           'If it's the starting position goto mat start position
           IF ((VR(80) = 1) AND (VR(66) = 0)) THEN
                ACCEL = 5
                DECEL = 5
                SPEED = 25
                VR(91) = 6 'Moving to start position
                VR(90) = 1
                WA(2000)
                WAIT UNTIL VR(16) = 0

                ' If this is a double job then setup connections
                IF (VR(34) = 1) THEN

                    ' If the heads are triggering eachother's proxy
                    IF (IN(5) = 0) THEN
                         IF ((MPOS AXIS(1) - 5) > 0) THEN
                              BASE(1)
                              SPEED = 10
                              ACCEL = 10
                              DECEL = 10

                              MOVE(-5)
                              WAIT IDLE
                        ELSE
                              BASE(2)
                              SPEED = 10
                              ACCEL = 10
                              DECEL = 10
                              MOVE(5)
                              WAIT IDLE
                        ENDIF

                    ENDIF
                    BASE(0,1,2)
                    MOVEABS(VR(71),VR(72),VR(72)+(VR(41)+VR(42)/10000))
                    WAIT IDLE
                    BASE(2)
                    CONNECT(1,1)
                    BASE(4,5)
                    SPEED = 90
                    ACCEL = 90
                    DECEL = 90
                    ' Move both Z's to universal position
                    MOVEABS(0,0)
                    WAIT IDLE
                    BASE(0,1)
                ELSE ' this is not a double job
        IF (VR(120) = 1) THEN ' YA Job

                    BASE(2)
                    IF (MPOS < 276) THEN
                        SPEED = 10
                        ACCEL = 10
                        DECEL = 10
                        SERVO = 1
                        OP(13,1)
                        MOVEABS(276.67)
                        WAIT IDLE
                        OP(13,0)
                    ENDIF
                    BASE(0,1)

         ELSE 'YB Job

                    BASE(1)
                    IF (MPOS > 0) THEN
                        SPEED = 10
                        ACCEL = 10
                        DECEL = 10
                        SERVO = 1
                        OP(12,1)
                        MOVEABS(0)
                        WAIT IDLE
                        OP(12,0)
                    ENDIF

                    BASE(0,2)

        ENDIF
                    MOVEABS(VR(71),VR(72)) ' Move to start position
                ENDIF' End if it's not a double job
                'start calculating Z start angle
                VR(56) = (VR(73))-(VR(71)) 'X Dir
                VR(57) = (VR(74))-(VR(72)) 'Y Dir
                PRINT #6, "XChange: ", VR(56), "YChange: ",VR(57)

                IF (VR(56) = 0) OR (VR(57) = 0) THEN

                    IF (VR(56) = 0) THEN
                        IF (VR(57) < 0) THEN
                           'Move to -90 Degrees
                            VR(55) = -90
                        ELSE
                            'Move to 90 Degrees
                            VR(55) = 90
                        ENDIF
                    ELSE 'IF (xdir = 0) THEN
                        IF (VR(56) < 0) THEN
                           'Move To 180 Degrees
                            VR(55) = 180
                        ELSE
                            'Move to 0 Degrees
                            VR(55) = 0
                        ENDIF
                    ENDIF 'IF (xdir = 0) THEN
                ELSE ' IF (VR(56) = 0) OR (VR(57) = 0) THEN

                'Get the current vector in radians
                VR(55) = ATAN2(INT(VR(57)),INT(VR(56)))
                'Convert from radians to degrees
                VR(55) = (VR(55)*57.295645530939648586707410236822)

               'Adjusts the degrees to be between 0 and 360; atan < 0 when x < 0
               IF (VR(56) >0 AND VR(57) >0) THEN
                    VR(55) = VR(55)
               ELSEIF (VR(56) <0 AND VR(57) >0) THEN
                    VR(55) = VR(55) + 180
               ELSEIF (VR(56) <0 AND VR(57) <0) THEN
                    VR(55) = VR(55) + 360
               ELSEIF (VR(56) >0 AND VR(57) <0) THEN
                    VR(55) = VR(55) + 180
               ENDIF

           ENDIF ' IF (VR(56) = 0) OR (VR(57) = 0) THEN

           PRINT #6,"Start Angle: ", VR(55)
           WAIT IDLE

           'If it is in testing mode tell us so
           IF(VR(82) = 1) THEN
                VR(91) = 10
                VR(90) = 1
                WA(1500)
           ENDIF

  ' If this is a double job then
     IF (VR(34) = 1) THEN
           BASE(4,5)
           SPEED = 120
           ACCEL = 100
           DECEL = 100

           'change to start angle
           MOVEABS(VR(55),VR(55))
           WAIT IDLE

    ELSE
        IF (VR(120) = 1) THEN
           BASE(4)
           SPEED = 90
           ACCEL = 100
           DECEL = 100

           'change to start angle
           MOVEABS(VR(55))
           WAIT IDLE
        ELSEIF (VR(121) = 1) THEN
           BASE(5)
           SPEED = 90
           ACCEL = 100
           DECEL = 100

           'change to start angle
           MOVEABS(VR(55))
           WAIT IDLE
        ENDIF
    ENDIF

           WAIT UNTIL PROC_STATUS PROC(14) = 0
           RUN "zthetamonitor",14

IF (VR(120) = 1) OR(VR(34) = 1) THEN
    BASE(0,1)
ELSEIF (VR(121) = 1) THEN
    BASE(0,2)
ENDIF

           WAIT UNTIL (VR(16) = 0)
           ACCEL = 25
           DECEL = 25
           SPEED = 10

           PRINT #6, "Please Press Pause to drop head"
           VR(40) = 1 'skip voices
           VR(16) = 1 'set to paused
           VR(91) = 2
           VR(90) = 1
           WA(250)

           WAIT UNTIL (VR(16) = 0)
    ' If it is a double job drop both heads
    IF (VR(34) = 1) THEN
            ' If this is in plot mode then
            IF (VR(82) = 0) THEN
               OP(20,1)
               OP(28,1)
               WAIT UNTIL ((IN(18) AND NOT IN(17)) AND (IN(26) AND NOT IN(25)))
               OP(21,1)
               OP(29,1)
               WA(2000)
           ENDIF

    ELSE
           IF (VR(82) = 0) THEN
IF (VR(120) = 1) THEN
               OP(20,1)
               WAIT UNTIL (IN(18) AND NOT IN(17))
               OP(21,1)

ELSEIF (VR(121) = 1) THEN
               OP(28,1)
               WAIT UNTIL (IN(26) AND NOT IN(25))
               OP(29,1)
ENDIF
           WA(2000)

           ENDIF
    ENDIF
           VR(91) = 3 'starting Job
           VR(90) = 1
           WA(1000)


       ENDIF '           IF ((VR(80) = 1) AND (VR(66) = 0)) THEN

       WAIT UNTIL VR(16) = 0
       IF ((VR(80) = 1) AND (VR(66) = 0)) THEN
            VR(110) = TIME
           PRINT #6, "Start Time: ", VR(110)
       ENDIF

       'End initial setup of mat if it is the first element
       'Proceed with processing the line

       VR(87) = ABS(VR(71)-VR(73))
       VR(88) = ABS(VR(72)-VR(74))
       VR(87) = VR(87)*VR(87)
       VR(88) = VR(88)*VR(88)

       VR(75) = SQR(VR(87)+VR(88))

       PRINT #7,"LX:",VR(71),"Y:",VR(72),"XEnd:",VR(73),"YEnd:",VR(74),VR(75)

       IF (VR(75) > 20) THEN
           PRINT #7, "Long Vector"

            WAIT UNTIL SPEED AXIS(0) <> 0
          SPEED = 39
           ACCEL = 4
           DECEL = 20
       ELSE
           PRINT #7, "Short Vector"
            WAIT UNTIL SPEED AXIS(0) <> 0
           SPEED = 13
           ACCEL = 4
           DECEL = 20
       ENDIF 'IF (VR(75) > 20) THEN


       'Assumes we are at the proper start position and commands end position
       MOVEABS(VR(73),VR(74))

       IF (VR(75) > 20) THEN
           WAIT UNTIL REMAIN > 0
           VR(78) = REMAIN
           ' if the last arc was within the specified degrees then change the
           ' accel point and accel speed for the faster portion to prevent
           ' elements in mat from ripping up when they have no length holding
           ' them down
           IF ((VR(89) > 75) AND (VR(89) < 100)) THEN
              WAIT UNTIL (((VR(78)-REMAIN) > 15) OR REMAIN = 0)
              ACCEL= 12
           ELSE
              WAIT UNTIL (((VR(78)-REMAIN) > 10) OR REMAIN = 0)
              ACCEL= 25
           ENDIF
       ENDIF 'IF (VR(75) > 20) THEN

       VR(83) = VR(73)
       VR(84) = VR(74)

       ' Else this is an arc
       ELSE

           ' Do generic arc calculations

 'Routine to find next Line for ending X and Y on arc
           VR(79) = VR(66)+1

            'if loop is on 50 then it may return a 0, thinking it's a line
            ' it is not, so set it to the begining
           IF (VR(79) >= 50) THEN
                VR(79) = 0
            ENDIF

'           WHILE (VR( (VR(65)+(VR(79)*9)) ) <> 0)
               'assumes that the mat will never end with an arc
               'otherwise it will loop indefinatly
 '              IF (VR(79) >= 49) THEN
  '                 VR(79) = 0
      '         ELSE
   '                VR(79) = VR(79) + 1
     '          ENDIF
    '       WEND


            'Overwrite default variables for arc
            'Get End X and Y (Vector)
    VR(73) = VR( (VR(65)+(VR(79)*9)+1) ) + VR( (VR(65)+(VR(79)*9)+2) )/10000
    VR(74) = VR( (VR(65)+(VR(79)*9)+3) ) + VR( (VR(65)+(VR(79)*9)+4) )/10000

           WAIT IDLE

    VR(73) = VR(73) + (VR(126)+(VR(127)/10000))
    VR(74) = VR(74) + (VR(128)+(VR(129)/10000))

           'Storing the net Chord values
           VR(85) = VR(73)-VR(83)
           VR(86) = VR(74)-VR(84)
       VR(77) = SQR(ABS(VR(85)*VR(85))+ABS(VR(86)*VR(86)))

'Gets the radius of the arc
       VR(87) = ABS(VR(71)-VR(73))
       VR(88) = ABS(VR(72)-VR(74))
       VR(87) = VR(87)*VR(87)
       VR(88) = VR(88)*VR(88)

       VR(75) = SQR(VR(87)+VR(88))


    'set arc degrees
        VR(89) = (2* (ASIN(VR(77)/(2*VR(75)))*(180/3.14) ) )
           ACCEL = 3 '2
           DECEL = 2.5
        WAIT UNTIL SPEED AXIS(0) <> 0
           SPEED = 3

           'End generic caluclations

           'If this is a Counter Clocwise arc
           IF (VR( (VR(65)+(VR(66)*9)) ) = 2) THEN
               WAIT UNTIL VR(16) = 0
               PRINT #7,"C: ",VR(85),VR(86),VR(71)-VR(83),VR(72)-VR(84),VR(89)
               MOVECIRC(VR(85),VR(86),(VR(71)-VR(83)),(VR(72)-VR(84)),1)

           ELSEIF (VR( (VR(65)+(VR(66)*9)) ) = 1) THEN
               WAIT UNTIL VR(16) = 0
                PRINT #7,"CC: ",VR(85),VR(86),VR(71)-VR(83),VR(72)-VR(84),VR(89)

               MOVECIRC(VR(85),VR(86),(VR(71)-VR(83)),(VR(72)-VR(84)),0)
           ENDIF '           IF (VR( (VR(65)+(VR(66)*9)) ) = 2) THEN
         '  IF this is a double mat

       ENDIF '       IF (VR( VR(65)+(VR(66)*9) ) = -1) THEN
       WAIT IDLE

       VR(66) = VR(66) + 1

       IF (VR(66) > 49) THEN
           VR(66) = 0
       ENDIF
       WA(200)

       'Processes post movement to exit loop more efficiently
       IF ((VR( VR(65)+(VR(66)*9) ) = -1) AND (VR(76) = 0)) THEN
            VR(76) = 1
       ENDIF


    WEND 'WHILE ((VR(66) < 50) AND (VR(76) = 0) )



WEND ' WHILE VR(76) = 0

WAIT IDLE
' set speed for end move
ACCEL = 5
        DECEL = 5
WAIT UNTIL SPEED AXIS(0) <> 0
        SPEED = 10
' set speed for end move
  VR(80) = VR(80)+1
    WA(250)
    VR(81) = 1
    PRINT #7, "Loaded: ", VR(80)
 '   WAIT UNTIL (VR(81) = 0)

    ' If it is a double job drop both heads
    IF (VR(34) = 1) THEN
      OP(21,0)
     OP(20,0)
     OP(29,0)
     OP(28,0)
    WA(250)
    OP(19,1)
    OP(27,1)
    WAIT UNTIL ((NOT IN(18) AND IN(17)) AND (NOT IN(26) AND IN(25)))
    OP(19,0)
    OP(27,0)

    ELSE
    'raise a single Y
    IF (VR(120) = 1) THEN
        OP(21,0)
        OP(20,0)
        WA(250)
        OP(19,1)
        WAIT UNTIL (NOT IN(18) AND IN(17))
        OP(19,0)
    ELSEIF (VR(121) = 1) THEN
        OP(29,0)
        OP(28,0)
        WA(250)
        OP(27,1)
        WAIT UNTIL (NOT IN(26) AND IN(25))
        OP(27,0)
    ENDIF
ENDIF ' If not a double job

MERGE = OFF
STOP "zthetamonitor"

IF (VR(120) = 1) THEN
    BASE(0,1)
ELSEIF (VR(121) = 1) THEN
    BASE(0,2)
ENDIF
WAIT IDLE
VR(111) = TIME
PRINT #6, "End Time: ", VR(111)


    'No Job Loaded
    IF (VR(76) = 2) THEN
        VR(91) = 9
        VR(90) = 1
    ELSE


    '    PRINT #6, "Please press Pause to move out of the way"

'        VR(40) = 1 ' Skip Paused Voice
 '       VR(16) = 1

        VR(91) = 4
        VR(90) = 1

        WAIT UNTIL (VR(16) = 0)
        WA(1000)

        WAIT UNTIL (VR(90) = 0)
ACCEL = 5
        DECEL = 5
        SPEED = 10
        VR(91) = 50
        VR(90) = 1

    ' If it is a double job rais both heads
    IF (VR(34) = 1) THEN
        BASE(2)
        CANCEL
        CANCEL
'        BASE(0,1,2)
 '       MOVEABS(VR(43),VR(44),276.67)
 '       WAIT IDLE

        BASE(0,1)
    ELSE

        ' Move out of way
'        MOVEABS(VR(43),VR(44))
    ENDIF
        WAIT IDLE

'    IF (VR(34) = 1) THEN
'        BASE(4,5)
 '       SPEED = 90
 '       ACCEL = 100
  '      DECEL = 100
   '     MOVEABS(-90,-90)
  '      BASE(4)
  '  ELSE
  '      BASE(4)
  '      SPEED = 90
  '      ACCEL = 100
   '     DECEL = 100
   '     MOVEABS(-90)

'    ENDIF
    ENDIF
WAIT IDLE
STOP "pause"
'WAIT UNTIL PROC_STATUS PROC(9) = 0
' Disable Y's
        BASE(1)

        OP(12,0)
        SERVO = 0

        BASE(4)
        OP(14,0)
        SERVO = 0


        BASE(2)
        OP(13,0)
        SERVO = 0

        BASE(5)
        OP(15,0)
        SERVO = 0
VR(16) = 0 ' Reset pause
VR(17) = 0 ' Reset stop
WA(1000)
VR(39) = 0
OP(31,0)
VR(118) = 0 'we Are not moving
'VR(40) = 0 'Set plotting variable to not plotting


