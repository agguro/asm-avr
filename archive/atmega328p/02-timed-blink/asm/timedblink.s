; ============================================================================
; ATmega328P Timer1 Blink (Pin 13 / PB5)
; Toggles every 1 second (2 second period)
; ============================================================================

.equ F_CPU, 16000000
.equ PRESCALER, 1024

; Change this value to your desired interval in milliseconds
; 1000 = 1 second, 500 = 0.5 seconds, 250 = 0.25 seconds
.equ MS_INTERVAL, 500

; The Formula: (F_CPU / 1000) gives ticks per millisecond
; Then multiply by MS_INTERVAL and divide by PRESCALER
.equ OCR_VALUE, ((F_CPU / 1000) * MS_INTERVAL / PRESCALER) - 1

; --- Extracting Bytes ---
; If your assembler rejects lo8/hi8, use these bitwise versions:
.equ OCR_LOW,  (OCR_VALUE & 0xFF)
.equ OCR_HIGH, (OCR_VALUE >> 8)

; --- I/O Register Addresses (0x00 - 0x3F) ---
.equ DDRB,   0x04
.equ PORTB,  0x05
.equ PINB,   0x03
.equ SPH,    0x3E
.equ SPL,    0x3D
.equ SREG,   0x3F

; --- Extended Register Addresses (0x60+) ---
; These must be used with STS/LDS
.equ TIMSK1, 0x6F
.equ TCCR1A, 0x80
.equ TCCR1B, 0x81
.equ TCNT1H, 0x85
.equ TCNT1L, 0x84
.equ OCR1AH, 0x89
.equ OCR1AL, 0x88

; --- Bitmasks ---
.equ PB5,    5     ; Pin 13
.equ OCIE1A, 1     ; Timer1 Compare Match A Interrupt Enable
.equ WGM12,  3     ; CTC Mode
.equ CS12,   2     ; Prescaler 1024
.equ CS10,   0     ; Prescaler 1024

.section .vectors, "ax", @progbits

__vectors:
    jmp reset                ; 0x0000 Reset Vector
    .org 0x002C              ; Timer1 COMPA Vector address
    jmp timer1_compa_isr

.section .text
.global reset
reset:
    ; 1. Initialize Stack Pointer to 0x08FF
    ldi r16, 0x08
    out SPH, r16
    ldi r16, 0xFF
    out SPL, r16

    ; 2. Set PB5 (Pin 13) as Output
    sbi DDRB, PB5

    ; 3. Setup Timer1
    eor r16, r16
    sts TCCR1A, r16          ; Normal Mode

    ; Clear the counter (TCNT1) to ensure the first interval is exactly 1s
    eor r16, r16
    sts TCNT1H, r16
    sts TCNT1L, r16

    ; Set Compare Value using our calculated EQU constants
    ldi r16, OCR_HIGH      ; Loaded from (15624 >> 8)
    sts 0x89, r16
    ldi r16, OCR_LOW       ; Loaded from (15624 & 0xFF)
    sts 0x88, r16

    ; Enable Timer1 Compare Match A Interrupt
    ldi r16, (1 << OCIE1A)
    sts TIMSK1, r16

    ; Start Timer: CTC Mode (WGM12) + Prescaler 1024 (CS12 | CS10)
    ; Binary: 0000 1101 = 0x0D
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, r16

    sei                      ; Global Interrupt Enable

main_loop:
    rjmp main_loop           ; Idle loop

; --------------------------------------------------------------------------
; Timer 1 Compare Match A ISR
; --------------------------------------------------------------------------
timer1_compa_isr:
    push r16                 ; Save r16
    in   r16, SREG           ; Save SREG
    push r16
    push r17                 ; Save r17

    ; Toggle LED using the PINB hardware trick
    ldi  r17, (1 << PB5)     ; 0x20
    out  PINB, r17

    pop  r17                 ; Restore r17
    pop  r16                 ; Pop SREG into r16
    out  SREG, r16           ; Restore SREG
    pop  r16                 ; Restore original r16
    reti                     ; Return from interrupt
