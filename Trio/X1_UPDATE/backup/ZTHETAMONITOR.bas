IF (VR(34) = 1) THEN
    BASE(5)
    P_GAIN = 70 '60
    D_GAIN = 625 '650
    BASE(4)
    P_GAIN = 70
    D_GAIN = 750
    BASE(4,5)
ELSEIF (VR(120) = 1) THEN
    BASE(4)
    P_GAIN = 70
    D_GAIN= 700'30 ' 16 ' 12
ELSEIF (VR(121) = 1) THEN
     BASE(5)
    P_GAIN = 70 '60'30
    D_GAIN = 625 '650'750
ENDIF


SPEED = 150'400
ACCEL = 32000'2500
DECEL = 32000'2500

newdeg = 0
olddeg = 0
MERGE=ON
dposx0 = 0
dposy0 = 0
dposx1 = 0
dposy1 = 0
txdir = 0
tydir = 0
VR(62) = 0
VR(64) = 3.5 '4.25 '3.5
'VR(35) = ACCEL ' VR(35) in use
VR(69) = .005


WHILE 1 = 1
'IF(VP_SPEED AXIS(0)>0.05 OR VP_SPEED AXIS(1)>0.05 ORVP_SPEED AXIS(2)>0.05) THE

IF (VR(34) = 1) THEN
    BASE(4,5)

ELSEIF (VR(120) = 1) THEN
    BASE(4)

ELSEIF (VR(121) = 1) THEN
     BASE(5)

ENDIF
    IF ((VR( (VR(65)+(VR(66)*9)) ) = 0) )THEN

        IF (VR(75) < 1) THEN
            SPEED = 150
        ELSEIF (VR(75) < 2) THEN
            SPEED = 75
        ELSEIF (VR(75) < 4) THEN
            SPEED = 22.5
        ELSEIF (VR(75) < 10) THEN
            SPEED = 30

        ELSE
            SPEED = 120
        ENDIF

    ELSE ' it is an arc
        IF (VR(89) = 0) THEN
            SPEED = 270'120
        ELSEIF (VR(89) < 50) THEN
            SPEED = 75'55
        ELSEIF (VR(89) < 80) THEN
            SPEED = 95'85
        ELSEIF(VR(89) < 170) THEN
            SPEED = 180' 150
        ELSE
            SPEED = 175'140
        ENDIF



    ENDIF

   'Code to retrieve and store DPOS to obtain the vector of X & Y
    dposx0 = DPOS AXIS(0)
    IF (VR(121) = 1) THEN
        dposy0 = DPOS AXIS(2)

    ELSE
        dposy0 = DPOS AXIS(1)
    ENDIF
    xdir = dposx0 - dposx1
    ydir = dposy0 - dposy1
    dposx1 = dposx0
    dposy1 = dposy0
    'End X & Y vector code


    'Dead band code, prevents ZTheta from moving when niether axis is moving
IF(VP_SPEED AXIS(0)>.04 OR VP_SPEED AXIS(1)>.04 OR VP_SPEED AXIS(2)>.04) THEN
'    IF ((MTYPE AXIS(0)) <> 0) OR ((MTYPE AXIS(1)) <> 0) THEN

        'Store x and y directions for usage in equations
        txdir = xdir
        tydir = ydir

        'Removes minor changes in x and y relativly making a smoother vector
        txdir = txdir * 1000
        tydir = tydir * 1000
        'End vector smoothing code



        IF (xdir = 0) OR (ydir = 0) THEN

            IF (xdir = 0) THEN
                IF (ydir < 0) THEN
                    newdeg = 270

                ELSE
                    IF (ydir > 0) THEN
                        newdeg = 90
                    ENDIF
                ENDIF

            ELSE
                IF (ydir = 0) THEN
                    IF (xdir < 0) THEN
                       newdeg = 180
                    ELSEIF (xdir > 0) THEN
                        newdeg = 0
                    ENDIF
                ENDIF
            ENDIF

   '         PRINT #6,newdeg



        ELSE

            'Get the current vector in radians
            newdeg = ATAN2(INT(tydir),INT(txdir))
            'Convert from radians to degrees
            newdeg = (newdeg*57.295645530939648586707410236822)

            'Adjusts the degrees to be between 0 and 360; atan < 0 when x < 0
'            IF newdeg < 0 THEN
'                newdeg = 180+(180-ABS(newdeg))
'            ENDIF

            IF (xpos >0 AND ypos >0) THEN
                newdeg = newdeg
            ELSEIF (xpos <0 AND ypos >0) THEN
                newdeg = newdeg + 180
            ELSEIF (xpos <0 AND ypos <0) THEN
                newdeg = newdeg + 360
            ELSEIF (xpos >0 AND ypos <0) THEN
                newdeg = newdeg + 180
            ENDIF



          '  PRINT #6, "X: ", xdir, "Y: ", ydir, "Rel:", chgdeg, "new: ", newdeg
           ' PRINT #6, "DPos: ", MPOS

        ENDIF ' End error corrction code

     'Formula for moving the shortest distance, less than 180 degrees

    IF((olddeg - (newdeg + VR(62)*360)) > 180) THEN
          VR(62) = VR(62) + 1
    ELSEIF ((olddeg - (newdeg + VR(62)*360)) < -180) THEN
          VR(62) = VR(62) - 1
    ENDIF

    IF (ABS(xdir) > VR(69)) OR (ABS(ydir) > VR(69)) THEN
        'IF ((ABS((newdeg + (VR(62) *360))-olddeg) >10)) THEN
     '       PRINT #6,"new:",(newdeg + (VR(62) *360))
           CANCEL

        IF (VR(34) = 1) THEN
            BASE(4,5)
            MOVEABS(newdeg + (VR(62) *360),newdeg + (VR(62) *360))

       ELSEIF (VR(120) = 1) THEN
           MOVEABS(newdeg + (VR(62) *360)) AXIS(4) 'Move relative degrees

       ELSEIF (VR(121) = 1) THEN
            MOVEABS(newdeg + (VR(62) *360)) AXIS(5) 'Move relative degrees

         ENDIF
            WAIT IDLE
    ENDIF


IF (VR(120) = 1) THEN
     olddeg = DPOS AXIS(4)

ELSEIF (VR(121) = 1) THEN

    olddeg = DPOS AXIS(5)
ENDIF
ENDIF ' End dead band code

WA(VR(64)) 'Wait 15 milliseconds to get net change in x & y




'ENDIF
WEND 'while 1=1
'MERGE=OFF



