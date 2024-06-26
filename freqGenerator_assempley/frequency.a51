KEYPAD_PORT EQU P1
	ADC EQU P2
C1  BIT P1.0
C2  BIT P1.1
C3  BIT P1.2
C4  BIT P1.3
RO4 BIT P1.4
RO3 BIT P1.5
RO2 BIT P1.6
RO1 BIT P1.7
LCD_PORT EQU P0
Rs BIT P3.0
E BIT P3.1

ORG 00H
MOV KEYPAD_PORT,#0FFH           


MOV TMOD,#2H
MOV TH0,#0

HERE:                
LCALL LCD_INIT
;MOV A,#0C0H   
;LCALL LCD_COMMAND
MOV DPTR,#TRIANGLE
FREQ:
MOV R0,#12
LOOP:
MOV A,R0
MOVC A,@A+DPTR
MOV ADC,A
SETB TR0
H:JNB TF0,H
CLR TF0
CLR TR0
DJNZ R0,LOOP
SJMP FREQ


READ_KEY:
CHECK_1:                                        
CLR RO1
CLR RO2
CLR RO3
CLR RO4

MOV A,KEYPAD_PORT
ANL A,#0FH
CJNE A,#0FH,CHECK_1                               
CHECK_2:                                       
ACALL DELAY                                     
MOV A,KEYPAD_PORT
ANL A,#0FH
CJNE A,#0FH,CHECK_ROW
SJMP CHECK_1                                   
CHECK_ROW:                                      
CLR RO1
SETB RO2
SETB RO3
SETB RO4
MOV A,KEYPAD_PORT
CJNE A,#01111111B,ROW_1
SETB RO1
CLR RO2
SETB RO3
SETB RO4
MOV A,KEYPAD_PORT
CJNE A,#10111111B,ROW_2
SETB RO1
SETB RO2
CLR RO3
SETB RO4
MOV A,KEYPAD_PORT
CJNE A,#11011111B,ROW_3
SETB RO1
SETB RO2
SETB RO3
CLR RO4
MOV A,KEYPAD_PORT
CJNE A,#11101111B,ROW_4
LJMP CHECK_1
ROW_1:                                          
MOV DPTR,#ROW1
SJMP FIND
ROW_2:
MOV DPTR,#ROW2
SJMP FIND
ROW_3:
MOV DPTR,#ROW3
SJMP FIND
ROW_4:
MOV DPTR,#ROW4
SJMP FIND
FIND: 
MOV R2,#4                                       ;FIND IN WHICH COLUMN THE PRESSED BUTTON IS
RRC A
JNC MATCH
INC DPTR
DJNZ R2, FIND
SJMP READ_KEY
MATCH:                                         
CLR A
MOVC A,@A+DPTR
CJNE A,#'C',PPO
LCALL LCD_INIT
LJMP HERE                                      
PPO:                                          
RET
ERROR:                                         
LCALL LCD_INIT
MOV DPTR,#ERR
AGAIN_2:
CLR A
MOVC A,@A+DPTR
JZ HOO
LCALL LCD_DATA
INC DPTR
SJMP AGAIN_2
HOO:
LCALL READ_KEY 
LJMP HERE						


LCD_INIT:
MOV A,#38H                                     
ACALL LCD_COMMAND
MOV A,#0EH                                     
ACALL LCD_COMMAND
MOV A,#01H                                     
ACALL LCD_COMMAND
RET

LCD_COMMAND:                                    ;APPLY A COMMAND TO THE LCD
MOV LCD_PORT,A
CLR Rs
SETB E
CLR E
ACALL DELAY
RET

LCD_DATA:                                      
MOV LCD_PORT,A
SETB Rs
SETB E
CLR E
ACALL DELAY
RET

DELAY:                                         
MOV R3,#100
LOOP2: MOV R2,#200
LOOP1: DJNZ R2,LOOP1
DJNZ R3,LOOP2
RET
                               ;KEYBOARD BUTTONS
ROW1: DB '7','8','9','K'
ROW2: DB '4','5','6','*'
ROW3: DB '1','2','3','-'
ROW4: DB 'C','0','=','+'

SIN:    DB 0,128,192,238,255,238,192,128,64,17,0,17,64
SQUARE: DB 0,255,255,255,255,255,255,0,0,0,0,0,0
STAIRS: DB 0,255,232,209,186,163,140,117,94,71,48,24,0
TRIANGLE:DB 0,0,42,84,126,168,211,255,211,168,126,84,42
ERR: DB 'ERROR',0     
END