


IF (VR(31) = 1) THEN
IF (IN(12) = 0) THEN
    BASE(1)
    SERVO = 1
    OP(12,1)
    BASE(4)
    SERVO = 1
    OP(14,1)
ELSE
    BASE(1)
    OP(12,0)
    SERVO = 0
    BASE(4)
    OP(14,0)
    SERVO = 0

ENDIF
ENDIF


IF (VR(32) = 1) THEN
IF (IN(13) = 0) THEN
    BASE(2)
    SERVO = 1
    OP(13,1)
    BASE(5)
    SERVO = 1
    OP(15,1)
ELSE
    BASE(2)
    OP(13,0)
    SERVO = 0
    BASE(5)
    OP(15,0)
    SERVO = 0
ENDIF
ENDIF

