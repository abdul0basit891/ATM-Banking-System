
.386
.model flat, stdcall

INCLUDE ATMCommon.inc

.data

PUBLIC accountCount
PUBLIC accountNumbers
PUBLIC accountPins
PUBLIC accountBalances
PUBLIC accountStatus
PUBLIC InitializeDefaults

accountCount DWORD 5

; Account numbers
accountNumbers DWORD 10001, 10002, 10003, 10004, 10005
               DWORD 0, 0, 0, 0, 0

; Temporary demonstration PINs
accountPins DWORD 1234, 2345, 3456, 4567, 5678
            DWORD 0, 0, 0, 0, 0

; Account balances in Pakistani Rupees
accountBalances DWORD 50000, 75000, 100000, 25000, 90000
                DWORD 0, 0, 0, 0, 0

; 1 = Active, 0 = Inactive
accountStatus DWORD 1, 1, 1, 1, 1
              DWORD 0, 0, 0, 0, 0

.code

; =================================
; INITIALIZE DEFAULT ACCOUNTS
; =================================

InitializeDefaults PROC C

    mov accountCount, 5

    mov accountNumbers[0], 10001
    mov accountNumbers[4], 10002
    mov accountNumbers[8], 10003
    mov accountNumbers[12], 10004
    mov accountNumbers[16], 10005

    mov accountPins[0], 1234
    mov accountPins[4], 2345
    mov accountPins[8], 3456
    mov accountPins[12], 4567
    mov accountPins[16], 5678

    mov accountBalances[0], 50000
    mov accountBalances[4], 75000
    mov accountBalances[8], 100000
    mov accountBalances[12], 25000
    mov accountBalances[16], 90000

    mov accountStatus[0], 1
    mov accountStatus[4], 1
    mov accountStatus[8], 1
    mov accountStatus[12], 1
    mov accountStatus[16], 1

    ; Clear unused account slots
    mov ecx, 5
    mov esi, 20

ClearRemaining:

    cmp ecx, MAX_ACCOUNTS
    jae InitializationDone

    mov accountNumbers[esi], 0
    mov accountPins[esi], 0
    mov accountBalances[esi], 0
    mov accountStatus[esi], 0

    add esi, 4
    inc ecx

    jmp ClearRemaining

InitializationDone:

    ret

InitializeDefaults ENDP

END
