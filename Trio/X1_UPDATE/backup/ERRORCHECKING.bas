'Program: ErrorChecking
'Purpose: Checks and processes errors and critical inputs\variables
'Result: Errors are properly processed and diagnosed
'History: Created 08/28/06
'         Updated 02/21/07 - Added Estop Portions

VR(114) = 0 'estop voice latch

error_check_start:
'Cover Estop

IF ((IN(34) = 0) AND (VR(114) = 0)) THEN
    VR(91) = 30
    VR(90) = 1
    VR(114) = 1

            STOP "pause"
            STOP "startup"
            STOP "zthetamonitor"
            STOP "homing"
            STOP "enableys"
            STOP "dolights"
            STOP "parsedb2"

    RAPIDSTOP
    RAPIDSTOP
    RAPIDSTOP
    RAPIDSTOP
    RAPIDSTOP

    VR(16) = 0
    VR(17) = 0

    OP(12,0)
    OP(13,0)
    OP(14,0)
    OP(15,0)

    BASE(0)
    WDOG = 0
    SERVO = 0

    BASE(1)
    SERVO = 0

    BASE(2)
    SERVO = 0

    BASE(4)
    SERVO = 0

    BASE(5)
    SERVO = 0

        OP(21,0) 'Turn off cooling air
        OP(29,0)

        VR(39) = 0

        OP(31,0)

        VR(118) = 0 ' we are not moving

ELSE
    IF (IN(34) = 1) THEN VR(114) = 0
ENDIF



IF (MOTION_ERROR <> 0) THEN
    BASE(0) ' X Axis
    VR(10) = AXISSTATUS

    BASE(1) ' Y1 Axis
    VR(11) = AXISSTATUS

    BASE(2) ' Y2 Axis
    VR(12) = AXISSTATUS

    BASE(3) ' Y1Z Axis
    VR(13) = AXISSTATUS

    BASE(4) ' Y2Z Axis
    VR(14) = AXISSTATUS
BASE(ERROR_AXIS)
VR(94) = AXISSTATUS
IF((VR(94) AND 2) > 0 OR (VR(94) AND 3) > 0 OR (VR(94) AND 8) > 0)THEN
        PRINT "in estop"
            VR(15) = 1 ' Set Global Error Variable (A shutdown variable)
            STOP "pause"
            STOP "startup"
            STOP "zthetamonitor"
            STOP "homing"
            STOP "enableys"
            STOP "dolights"
            STOP "parsedb2"
            OP(31,0)
            OP(12,0)
            OP(13,0)
            OP(14,0)
            OP(15,0)


            BASE(3)
        IF (MTYPE = 21) THEN
            CANCEL
            CANCEL
        ENDIF

        BASE(0,1)
        RAPIDSTOP
        RAPIDSTOP

        SPEED = 20
        ACCEL = 10
        DECEL = 10

        OP(21,0) 'Turn off cooling air
        OP(29,0)

        IF (VR(34) = 1) THEN
          BASE(4)
            CANCEL
            CANCEL
            BASE(5)
            CANCEL
            CANCEL


        ELSE
           BASE(4)
         CANCEL
          CANCEL
          SPEED = 90
          ACCEL = 100
            DECEL = 100
            MOVEABS(-90)
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



  OP(31,0)
            VR(91) = 16
        VR(90) = 1

            VR(118) = 0
        WAIT UNTIL VR(15) = 0


ENDIF ' double job

VR(16) = 0
VR(17) = 0

ELSE' Error on bits 2,3 or 7
 VR(10) = 0
VR(11) = 0
VR(12) = 0
VR(13) = 0
VR(14) = 0


VR(15) = 0 ' Reset Global Error Indicator
ENDIF ' Motion_Error
'Check positioning for possible collisions

'if the machine is active

'VR(27) = MPOS AXIS(0)

'VR(28) = DPOS AXIS(0)

VR(102) = MPOS AXIS(0)
VR(103) = MPOS AXIS(1)
VR(104) = MPOS AXIS(2)
VR(105) = MPOS AXIS(4)
VR(106) = MPOS AXIS(5)


'check for collision possbility between X's


'check Y variables for possible collisions

'If the ACTUAL distance between Y1 and Y2 is less than the allowable distance
'then stop the movement to prevent collision
'IF (ABS(MPOS AXIS(1) - MPOS AXIS(2)) < VR(26)) THEN

'    VR(17) = 1
'    VR(16) = 1
    'Cancel the current job
'ELSE

    'If distance between X's is under the allowable distance then
'    IF (ABS(VR(27)- VR(29)) < VR(25)) THEN

        'Cancel the current job
'        VR(17) = 1
'        VR(16) = 1
'    ENDIF


'ENDIF




'End check positioning for possible collisions





'IF (VR(15)) THEN ' IF there is an error somewhere

'    VR(16) = 1 ' pause the machine
'    VR(17) = 1 ' STOP "THE" "MACHINE"
    'Initiate nice shutdown
'ENDIF

'Pause routine
'IF (VR(16)) THEN
'Store speeds for resume
'VR(18) = SPEED AXIS(0) 'Store X Speed
'VR(19) = SPEED AXIS(1) 'Store Y Speed
'vR(20) = SPEED AXIS(3) 'Store Z Speed

'BASE(0,1,2,3,4)
'SPEED = 0
'adjust accel of X for resume (prevents it from ripping wire?)
'accel = 3 axis(0)

'Machine speed is now = 0, effectivly pauses routines until speed is restored
'ELSE

'If the stored speeds are not cleared then it must have just been unpaused
'IF ((VR(18) <> -1) AND (VR(19) <> -1) AND (VR(20) <> -1)) THEN
 '   SPEED AXIS(0) = VR(18) 'Restore pre-pause X Speed
  '  SPEED AXIS(1) = VR(19) 'Restore pre-pause Y1 Speed
  '  SPEED AXIS(2) = VR(19) 'Restore pre-pause Y2 Speed
   ' SPEED AXIS(3) = VR(20) 'Restore pre-pause Y1Z Speed
    'SPEED AXIS(3) = VR(20) 'Restore pre-pause Y2Z Speed

'    VR(18) = VR(19) = VR(20) = -1 'Reset Speed Storage for routines to work
'ENDIF


'ENDIF ' End If (VR(16)) - If Paused


'IF (VR(17)) THEN ' If Stopped
'Requires pause to be hit, prevents accidental hits.
'IF (VR(16)) THEN
'BASE(0,1,2,3,4)
'WAIT IDLE 'waits until movement has stopped on the machine

'Cancel all programs/routines

'Cancel buffered movements
'BASE(0,1,2,3,4)
'CANCEL
'CANCEL
'CANCEL
'RAPIDSTOP

'Reset I/O If Needed

'Clear Stored Speeds because of pause/reinitialize
'VR(18) = VR(19) = VR(20) = -1

'Reset stop and pause to allow vehicle movement
'Pause will be enabled when next mat is loaded
'VR(16) = 0 ' Unpause
'VR(17) = 0 ' Unstop

'ENDIF ' If (vr(16)

'ELSE
'    PRINT "Vehicle is not paused, unable to stop..."
'ENDIF ' If (Vr(17)) - If Stopped











WA(1000)

GOTO error_check_start

end_error_check:


