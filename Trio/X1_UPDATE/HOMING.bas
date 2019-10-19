'Program: homing
'Purpose: Executes homing routines on all axes
'Result: Axes are homed, fault is displayed if there was an error
'ChangeLog:
'Aug 25, 2006:
'Routine Created, Not Tested
'
'VR(0) = 0 ' X Axis Home Enable
'vR(1) = 0 ' Y1 Axis Home Enable
'VR(2) = 0 ' Y2 Axis Home Enable
'VR(3) = 1 ' Y1Z Axis Home Enable
'VR(4) = 0 ' Y2Z Axis Home Enable
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
IF (VR(0) = 1) THEN

WAIT UNTIL(PROC_STATUS PROC(12) = 0)
RUN "pause",12
RUN "dolights",4

PRINT "X Axis Homing Enabled, Starting Homing..."
BASE(0) ' XAxis Homing

SPEED = 5
ACCEL = 15
DECEL = 40
FASTDEC = 40

REVERSE

do_reverse_x:
IF (IN(1) = 0) AND (IN(2) = 0) THEN
    CANCEL
    CANCEL
    VR(5) = 3 ' reverse limit triggered and home wasn't
    GOTO print_result_x
ELSE
    IF (IN(2) = 1) THEN ' home was triggered
        CANCEL
        CANCEL
        CANCEL
        SPEED = 1
        WA(1000)
        FORWARD
        WAIT UNTIL (IN(2) = 0)
        CANCEL
        CANCEL

        VR(5) = 2
        GOTO print_result_x
    ENDIF
ENDIF
GOTO do_reverse_x ' Complete the loop.. will only exit if home or reverse is hit


print_result_x:
IF (VR(5) = 3) THEN
    PRINT "No Home Prox Found For X"
    CANCEL
    CANCEL
    GOTO exit
ELSE
    IF (VR(5) = 2) THEN
    WAIT IDLE
    DEFPOS(0)
    VR(102) = MPOS AXIS(0)
    FS_LIMIT = 432
    RS_LIMIT = -1
    WA(500)


    VR(91) = 20
    VR(90)= 1
    PRINT "X Gantry Homed"
    SPEED = 20
    ACCEL = 30
    DECEL = 30
    ENDIF
ENDIF

OP(31,0)

ELSE ' Homing Is Disabled
    PRINT "X Axis Homing Is Disabled, Processing Next Axis..."
ENDIF ' Vr(0) = 1
'end of X Homing Routine

'Begin Y1 Homing Routine

IF (VR(1) = 1) THEN
    PRINT "Y1 Axis Homing Enabled, Starting Homing..."
RUN "dolights"

BASE(1) ' YAxis Homing
RS_LIMIT = -999999
SPEED = 5
ACCEL = 10
DECEL = 10
FASTDEC = 50
SERVO = 1
OP(12,1)


REVERSE

do_reverse_y1:
IF ((IN(6) = 0) AND (IN(7) = 0)) THEN
    CANCEL
    CANCEL
    VR(6) = 3 ' reverse limit triggered
    GOTO print_result_y1
ELSE
    IF (IN(7) = 1) THEN ' home was triggered
        CANCEL
        CANCEL
        SPEED = .5
        WA(1000)
        FORWARD
        WAIT UNTIL (IN(7) = 0)
        CANCEL
        CANCEL
        VR(6) = 2
        GOTO print_result_y1
    ENDIF
ENDIF
GOTO do_reverse_y1 ' Complete the loop.. will only exit if home or reverse is hi


print_result_y1:
IF (VR(6) = 3) THEN
    PRINT "No Home Prox Found For Y1"
    CANCEL
    CANCEL
    GOTO exit
ELSE
    IF (VR(6) = 2) THEN
    WAIT IDLE
    DEFPOS(0)
    VR(103) = MPOS AXIS(1)
    RS_LIMIT = -1
    FS_LIMIT = 259
    PRINT "Y1 Homed"
    OP(19,1)
    VR(92) = TIME
    WAIT UNTIL ((IN(17) = 1) OR ((TIME-VR(92)) > 60))
    OP(19,0)
    IF (IN(17) = 0) THEN
        PRINT "Issues Raising Y1 Plotter Head..."
        GOTO exit
    ELSE
        PRINT "Y1 Plotter Head Raised..."
    ENDIF
    ENDIF
ENDIF
OP(12,0)
OP(31,0)
SERVO = 0


ELSE ' Y1 Homing Is Disabled
    PRINT "Y1 Axis Homing Is Disabled, Processing Next Axis..."
ENDIF ' Vr(1) = 1
'end of Y1 Homing Routine


'begin Y2 Homing Routine

IF (VR(2) = 1) THEN
    PRINT "Y2 Axis Homing Enabled, Starting Homing..."

RUN "dolights"
BASE(2) ' YAxis Homing
SPEED = 5
ACCEL = 10
DECEL = 10
FASTDEC = 50
SERVO = 1
OP(13,1)
FORWARD

do_reverse_y2:
IF ((IN(8) = 0) AND (IN(10) = 0)) THEN
    CANCEL
    CANCEL
    VR(7) = 3 ' forward limit triggered
    GOTO print_result_y2
ELSE
    IF (IN(10) = 1) THEN ' home was triggered
        CANCEL
        CANCEL
        SPEED = .5
        WA(1000)
        REVERSE
        WAIT UNTIL (IN(10) = 0)
        CANCEL
        CANCEL
        VR(7) = 2
        GOTO print_result_y2
    ENDIF
ENDIF
GOTO do_reverse_y2 ' Complete the loop.. will only exit if home or reverse is hi


print_result_y2:
IF (VR(7) = 3) THEN
    PRINT "No Home Prox Found For Y2"
    CANCEL
    CANCEL
    GOTO exit
ELSE
    IF (VR(7) = 2) THEN
    WAIT IDLE
    DEFPOS(276.67)
VR(104) = MPOS AXIS(2)

    RS_LIMIT = 23
    FS_LIMIT = 289
    PRINT "Y2 Homed"
SPEED = 5
    OP(27,1)
    VR(92) = TIME
    WAIT UNTIL ((IN(25) = 1) OR ((TIME-VR(92)) > 60))
    OP(27,0)
    IF (IN(25) = 0) THEN
        PRINT "Issues Raising Y2 Plotter Head..."
        GOTO exit
    ELSE
        PRINT "Y2 Plotter Head Raised..."
    ENDIF


    ENDIF
ENDIF
OP(31,0)
OP(13,0)
SERVO = 0

ELSE ' Y2 Homing Is Disabled
    PRINT "Y2 Axis Homing Is Disabled, Processing Next Axis..."
ENDIF ' Vr(7) = 1
'end of Y2 Homing Routine

' start Y1Z Homing Routine

IF (VR(3) = 1) THEN
   PRINT "Y1Z Axis Homing Enabled, Starting Homing..."


BASE(4) ' Y1ZAxis Homing
RUN "dolights"
SPEED = 40
ACCEL = 400
DECEL = 2000
FASTDEC = 2000
SERVO = 1
OP(14,1)
VR(8) = MPOS

FORWARD

do_forward_z1:
IF ((VR(8) - MPOS) > 720) THEN
    CANCEL
    CANCEL
    ' If the head has rotated 2 times and hasn't found the prox
    VR(8) = 3
    GOTO print_result_z1
ELSE
    IF (IN(16) = 1) THEN
        CANCEL
        CANCEL
        WAIT IDLE
        WA(1000)
        SPEED = 1
        REVERSE
        WAIT UNTIL IN(16) = 0
        CANCEL
        CANCEL
        WAIT IDLE
        WA(1000)
        SPEED = 40
        MOVE(-175) 'move to offset for 0 position
        WAIT IDLE
        DEFPOS(0)
VR(105) = MPOS AXIS(4)
        VR(8) = 2
        GOTO print_result_z1
    ENDIF
ENDIF
GOTO do_forward_z1

print_result_z1:
IF (VR(8) = 3) THEN
    PRINT "No home prox found for Y1Z"
    GOTO exit
ELSE
IF (VR(8) = 2) THEN
    PRINT "Y1Z Axis Homed"
ENDIF
OP(14,0)
SERVO = 0
OP(31,0)
ENDIF

ELSE
    PRINT "Y1Z Axis Homing Is Disabled, Processing Next Axis..."
ENDIF 'if (vr(3) = 1)

' End Y1Z Homing Routine

' Start Y2Z Homing Routine

IF (VR(4) = 1) THEN
   PRINT "Y2Z Axis Homing Enabled, Starting Homing..."


BASE(5) ' Y1ZAxis Homing
RUN "dolights",4
P_GAIN = 70
D_GAIN = 625 '700
SPEED = 40
ACCEL = 400
DECEL = 2000
FASTDEC = 2000
SERVO = 1
OP(15,1)
VR(9) = MPOS

FORWARD

do_forward_z2:
IF ((VR(9) - MPOS) > 720) THEN
    CANCEL
    CANCEL
    ' If the head has rotated 2 times and hasn't found the prox
    VR(9) = 3
    GOTO print_result_z2
ELSE
    IF (IN(24) = 1) THEN

        CANCEL
        CANCEL
        WAIT IDLE
        WA(1000)
        SPEED = 1
        REVERSE
        WAIT UNTIL IN(24) = 0
        CANCEL
        CANCEL
        WAIT IDLE
        WA(1000)
        SPEED = 40
        MOVE(-165.5) 'move to offset for 0 position
        WAIT IDLE
        DEFPOS(0)
VR(106) = MPOS AXIS(5)


        VR(9) = 2



        GOTO print_result_z2
    ENDIF
ENDIF
GOTO do_forward_z2

print_result_z2:
IF (VR(9) = 3) THEN
    PRINT "No home prox found for Y2Z"
    GOTO exit
ELSE
IF (VR(9) = 2) THEN
    PRINT "Y2Z Axis Homed"
    OP(15,0)
    SERVO = 0
    OP(31,0)
    GOTO no_errors
ENDIF

ENDIF


ELSE
    PRINT "Y2Z Axis Homing Is Disabled, No Axes Left..."
    GOTO no_errors
ENDIF 'if (vr(3) = 1)

'end Y2Z Homing Routine


exit: 'used if an error in homing has occured
    PRINT "An Error Has Occured While Homing..."

no_errors:
    PRINT "Homing Routine Complete..."

STOP "pause"
VR(118) = 0 'we Are not moving
VR(118) = 0 'we Are not moving
