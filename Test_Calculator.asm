;CIS-11 Test Calculator - Letter Grade Test

.ORIG x3000

; ==== INIT ====
LEA R1, Scores      ; Pointer to array
AND R2, R2, #0      ; Sum = 0
AND R3, R3, #0      ; Counter = 0 (for input loop)

; ==== INPUT LOOP (5 times) ====
INPUT_LOOP
    LEA R0, PROMPT
    PUTS

    ; Get first digit
    GETC
    OUT
    LD R4, ASCII_ZERO
    NOT R4, R4
    ADD R4, R4, #1
    ADD R4, R0, R4    ; R4 = digit1 (integer value)

    ; Check if 3-digit number (e.g., 100)
    LD R0, ASCII_ONE
    NOT R0, R0
    ADD R0, R0, #1
    ADD R0, R4, R0    ; R0 = digit1 - 1 (if 1, then score is 100)
    BRnp NOT_ONE_HUNDRED

    ; If first digit is 1, and next two are 00, then score is 100
    GETC ; read second '0'
    OUT
    GETC ; read third '0'
    OUT
    LD R5, HUNDRED_VAL ; Load the value 100 into R5
    BR STORE_SCORE

NOT_ONE_HUNDRED
    ; Multiply first digit by 10
    AND R5, R5, #0
    ADD R5, R5, R4    ; R5 = digit1
    ADD R5, R5, R5    ; R5 = digit1 * 2
    ADD R5, R5, R5    ; R5 = digit1 * 4
    ADD R5, R5, R5    ; R5 = digit1 * 8
    ADD R5, R5, R4    ; R5 = digit1 * 9
    ADD R5, R5, R4    ; R5 = digit1 * 10  (efficient multiplication by 10)

    ; Get second digit
    GETC
    OUT
    LD R4, ASCII_ZERO
    NOT R4, R4
    ADD R4, R4, #1
    ADD R4, R0, R4    ; R4 = digit2 (integer value)
    ADD R5, R5, R4    ; R5 = full score

STORE_SCORE
    LEA R0, NL
    PUTS

    STR R5, R1, #0    ; Store score in array
    ADD R1, R1, #1    ; Move array pointer
    ADD R2, R2, R5    ; Add to sum
    ADD R3, R3, #1    ; Counter++

    ADD R0, R3, #-5
    BRn INPUT_LOOP     ; Loop until 5 entries

; ==== FIND MIN & MAX ====
JSR FIND_MIN_MAX     ; R6 = Min, R4 = Max (before AVG calc)

; ==== DISPLAY MIN & MAX ====
LEA R0, MSG_MIN
PUTS
ADD R0, R6, #0         ; R0 = Min
JSR PRINT_NUM_GENERIC

LEA R0, MSG_MAX
PUTS
ADD R0, R4, #0         ; R0 = Max (R4 is still Max here)
JSR PRINT_NUM_GENERIC

; ==== CALCULATE AVERAGE ====
AND R0, R2, #0        ; R0 = Sum (from input loop)
ADD R1, R3, #0        ; R1 = Counter (5) (from input loop)
JSR DIVIDE_BY_5        ; R0 now holds the average
ADD R4, R0, #0         ; R4 now holds the average

; ==== DISPLAY AVERAGE ====
LEA R0, MSG_AVG
PUTS
ADD R0, R4, #0         ; R0 = Average (from R4)
JSR PRINT_NUM_GENERIC

; ==== DETERMINE LETTER GRADE ====
ADD R0, R4, #0         ; R0 = Average (prepare for LETTER_GRADE) <-- UNCOMMENT THIS BLOCK
JSR LETTER_GRADE       ; R0 will now hold the ASCII letter grade
LEA R0, MSG_GRADE
PUTS
JSR PRINT_CHAR         ; Prints the character in R0 <-- END OF UNCOMMENTED BLOCK

HALT                   ; <-- MOVE HALT TO HERE, at the very end of the main program

; ================================
; SUBROUTINES (DEFINITIONS MUST BE HERE)
; ================================

; ==== SUBROUTINE: FIND_MIN_MAX ====
; Finds the minimum and maximum values in the Scores array.
; R6 = Minimum
; R4 = Maximum
FIND_MIN_MAX
    ST R1, FMM_SAVE_R1 ; Save R1
    ST R3, FMM_SAVE_R3 ; Save R3
    ST R5, FMM_SAVE_R5 ; Save R5
    ST R4, FMM_SAVE_R4 ; SAVE R4

    LEA R1, Scores
    LDR R6, R1, #0    ; Initialize Min with first score
    LDR R4, R1, #0    ; Initialize Max with first score
    ADD R1, R1, #1    ; Move pointer to second element
    AND R3, R3, #0    ; Initialize loop counter to 0

FMM_LOOP
    LDR R5, R1, #0    ; Load current score

    ; Compare with current Min (R6)
    NOT R0, R6
    ADD R0, R0, #1    ; R0 = -Min
    ADD R0, R5, R0    ; R0 = Current_Score - Min
    BRzp SKIP_MIN     ; If Current_Score >= Min, skip update
    ADD R6, R5, #0    ; Update Min = Current_Score
SKIP_MIN

    ; Compare with current Max (R4)
    NOT R0, R4         ; R0 = -Max (R4)
    ADD R0, R0, #1     ; R0 = -Max (R4)
    ADD R0, R5, R0     ; R0 = Current_Score - Max (R4)
    BRnz SKIP_MAX      ; If Current_Score <= Max (R4), skip update
    ADD R4, R5, #0     ; Update Max = Current_Score
SKIP_MAX

    ADD R3, R3, #1    ; Increment loop counter
    ADD R1, R1, #1    ; Move to next score
    ADD R0, R3, #-4   ; Loop 4 more times (total 5 scores)
    BRn FMM_LOOP      ; Continue if not done

    LD R1, FMM_SAVE_R1 ; Restore R1
    LD R3, FMM_SAVE_R3 ; Restore R3
    LD R5, FMM_SAVE_R5 ; Restore R5
    LD R4, FMM_SAVE_R4 ; RESTORE R4
    RET

; ==== SUBROUTINE: DIVIDE_BY_5 ====
; Divides R0 by R1 (assumed to be 5 for this program)
; Stores quotient in R0
; R0 = Dividend
; R1 = Divisor
; R2 = Quotient (used as counter)
DIVIDE_BY_5
    ST R1, DV5_SAVE_R1 ; Save R1
    ST R2, DV5_SAVE_R2 ; Save R2
    ST R3, DV5_SAVE_R3 ; Save R3

    AND R2, R2, #0      ; Initialize quotient (R2) to 0
    NOT R3, R1          ; R3 = ~divisor
    ADD R3, R3, #1      ; R3 = -(divisor) (for subtraction)

DIVIDE_LOOP
    ADD R0, R0, R3      ; R0 = R0 - divisor
    BRn DIVIDE_DONE     ; If R0 < 0, division is done
    ADD R2, R2, #1      ; Increment quotient
    BR DIVIDE_LOOP

DIVIDE_DONE
    ADD R0, R0, R1      ; Add divisor back to R0 to get the correct remainder
    ADD R0, R2, #0      ; Move quotient to R0

    LD R1, DV5_SAVE_R1 ; Restore R1
    LD R2, DV5_SAVE_R2 ; Restore R2
    LD R3, DV5_SAVE_R3 ; Restore R3
    RET

; ==== SUBROUTINE: PRINT_NUM_GENERIC (R0 = number) ====
; Prints a number (up to 3 digits, handles 100)
PRINT_NUM_GENERIC
    ST R1, PN_SAVE_R1
    ST R2, PN_SAVE_R2
    ST R3, PN_SAVE_R3
    ST R4, PN_SAVE_R4

    LD R1, HUNDRED_VAL ; Load 100
    NOT R1, R1
    ADD R1, R1, #1 ; R1 = -100
    ADD R4, R0, R1         ; R4 = R0 + (-100) ; Check if number is 100
    BRz PRINT_100

    ADD R4, R0, #-10  ; Check if number is less than 10
    BRn PRINT_ONE_DIGIT

    ; Handle two digits
    ADD R1, R0, #0    ; Copy number to R1
    AND R2, R2, #0    ; R2 will be tens digit counter

DIV10_TWO
    ADD R1, R1, #-10
    BRn DONE_DIV_TWO
    ADD R2, R2, #1
    BR DIV10_TWO
DONE_DIV_TWO
    ADD R1, R1, #10    ; R1 now has the units digit (remainder)

    LD R3, ASCII_ZERO
    ADD R2, R2, R3    ; Convert tens to ASCII
    OUT               ; Print tens digit

    ADD R1, R1, R3    ; Convert units to ASCII
    OUT               ; Print units digit
    BR PRINT_NUM_DONE

PRINT_ONE_DIGIT
    LD R3, ASCII_ZERO
    ADD R0, R0, R3    ; Convert single digit to ASCII
    OUT               ; Print single digit
    BR PRINT_NUM_DONE

PRINT_100
    LD R0, ASCII_ONE  ; Print '1'
    OUT
    LD R0, ASCII_ZERO ; Print '0'
    OUT
    LD R0, ASCII_ZERO ; Print '0'
    OUT

PRINT_NUM_DONE
    LEA R0, NL
    PUTS
    LD R1, PN_SAVE_R1
    LD R2, PN_SAVE_R2
    LD R3, PN_SAVE_R3
    LD R4, PN_SAVE_R4
    RET

; ==== SUBROUTINE: PRINT_CHAR ====
; Prints the character in R0
PRINT_CHAR
    ST R1, PC_SAVE_R1
    OUT
    LEA R0, NL
    PUTS
    LD R1, PC_SAVE_R1
    RET

; ==== SUBROUTINE: LETTER_GRADE ====
; Input: R0 = average score
; Output: R0 = ASCII character of the letter grade
LETTER_GRADE
    ST R5, LG_SAVE_R5

    LD R5, VAL_90
    NOT R5, R5
    ADD R5, R5, #1
    ADD R5, R0, R5    ; R5 = Avg - 90
    BRzp GRADE_A      ; If Avg >= 90

    LD R5, VAL_80
    NOT R5, R5
    ADD R5, R5, #1
    ADD R5, R0, R5    ; R5 = Avg - 80
    BRzp GRADE_B      ; If Avg >= 80

    LD R5, VAL_70
    NOT R5, R5
    ADD R5, R5, #1
    ADD R5, R0, R5    ; R5 = Avg - 70
    BRzp GRADE_C      ; If Avg >= 70

    LD R5, VAL_60
    NOT R5, R5
    ADD R5, R5, #1
    ADD R5, R0, R5    ; R5 = Avg - 60
    BRzp GRADE_D      ; If Avg >= 60

    LD R0, ASCII_F    ; Default to F
    BR LG_DONE

GRADE_A LD R0, ASCII_A
BR LG_DONE
GRADE_B LD R0, ASCII_B
BR LG_DONE
GRADE_C LD R0, ASCII_C
BR LG_DONE
GRADE_D LD R0, ASCII_D
BR LG_DONE

LG_DONE
    LD R5, LG_SAVE_R5
    RET

; ==== DATA ====
; ALL DATA DEFINITIONS MUST BE HERE, BEFORE THE .END DIRECTIVE
PROMPT     .STRINGZ "Enter score: "
MSG_MIN    .STRINGZ "\nMin: "
MSG_MAX    .STRINGZ "Max: "
MSG_AVG    .STRINGZ "Avg: "
MSG_GRADE  .STRINGZ "Letter Grade: "
NL         .STRINGZ "\n"

ASCII_ZERO .FILL x0030 ; '0'
ASCII_ONE  .FILL x0031 ; '1'
ASCII_A    .FILL x0041 ; 'A'
ASCII_B    .FILL x0042 ; 'B'
ASCII_C    .FILL x0043 ; 'C'
ASCII_D    .FILL x0044 ; 'D'
ASCII_F    .FILL x0046 ; 'F'

VAL_90     .FILL #90
VAL_80     .FILL #80
VAL_70     .FILL #70
VAL_60     .FILL #60

HUNDRED_VAL     .FILL #100
NEG_HUNDRED_VAL .FILL #-100

Scores     .BLKW 5       ; Allocate 5 words for scores

; Save areas for registers in subroutines
FMM_SAVE_R1 .BLKW 1
FMM_SAVE_R3 .BLKW 1
FMM_SAVE_R5 .BLKW 1
FMM_SAVE_R4 .BLKW 1

DV5_SAVE_R1 .BLKW 1
DV5_SAVE_R2 .BLKW 1
DV5_SAVE_R3 .BLKW 1

PN_SAVE_R1  .BLKW 1
PN_SAVE_R2  .BLKW 1
PN_SAVE_R3  .BLKW 1
PN_SAVE_R4  .BLKW 1

PC_SAVE_R1  .BLKW 1

LG_SAVE_R5  .BLKW 1


.END