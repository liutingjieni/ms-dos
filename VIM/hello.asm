TA SEGMENT
    BUF DB 'HELLO WORLD!  THIS IS MY FIRST ASM FILE! $'
    DATA ENDS

    CODE SEGMENT
        ASSUME  CS:CODE,DS:DATA
        START:STARTMOV AX,DATA
            MOV DS,AX
                LEA DX,BUF
                    MOV AH,09
                        INT 21H
                            MOV AH,4CH
                                INT 21H
                                CODE ENDS
                                END START

