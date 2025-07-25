;
; Startup code for cc65 (PET version)
;

        .export         _exit
        .export         __STARTUP__ : absolute = 1      ; Mark as startup
        .import         initlib, donelib
        .import         zerobss, push0
        .import         callmain
        .import         CLRCH, BSOUT

        .include        "zeropage.inc"
        .include        "pet.inc"

; ------------------------------------------------------------------------
; Startup code

.segment        "STARTUP"

Start:

; Save the zero-page locations that we need.

        ldx     #zpspace-1
L1:     lda     c_sp,x
        sta     zpsave,x
        dex
        bpl     L1

; Switch to the second charset. The routine that is called by BSOUT to switch the
; character set will use FNLEN as temporary storage -- YUCK! Since the
; initmainargs routine, which parses the command line for arguments, needs that
; information, we need to save and restore it here.
; Thanks to Stefan Haubenthal for this information!

        lda     FNLEN
        pha                     ; Save FNLEN
        lda     #14
;       sta     $E84C           ; See PET FAQ
        jsr     BSOUT
        pla
        sta     FNLEN           ; Restore FNLEN

; Clear the BSS data.

        jsr     zerobss

; Save some system stuff; and, set up the stack.

        tsx
        stx     spsave          ; Save the system stack ptr

        lda     MEMSIZE
        sta     c_sp
        lda     MEMSIZE+1
        sta     c_sp+1          ; Set argument stack ptr

; Call the module constructors.

        jsr     initlib

; Push the command-line arguments; and, call main().

        jsr     callmain

; Call the module destructors. This is also the exit() entry.

_exit:  pha                     ; Save the return code on stack
        jsr     donelib

; Copy back the zero-page stuff.

        ldx     #zpspace-1
L2:     lda     zpsave,x
        sta     c_sp,x
        dex
        bpl     L2

; Store the program return code into BASIC's status variable.

        pla
        sta     STATUS

; Restore the stack pointer.

        ldx     spsave
        txs                     ; Restore stack pointer

; Back to BASIC.

        rts

; ------------------------------------------------------------------------

.segment        "INIT"

zpsave: .res    zpspace

; ------------------------------------------------------------------------

.bss

spsave: .res    1
mmusave:.res    1
