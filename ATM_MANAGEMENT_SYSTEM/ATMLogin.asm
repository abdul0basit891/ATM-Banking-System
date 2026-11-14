INCLUDE Irvine32.inc
INCLUDE ATMCommon.inc
INCLUDE ATMData.inc

.data

loginTitle BYTE "========== ATM CUSTOMER LOGIN ==========",0
accountMsg BYTE "Enter Account Number: ",0
pinMsg BYTE "Enter PIN: ",0
star BYTE "*",0

successMsg BYTE "Login Successful!",0
failureMsg BYTE "Incorrect Account Number or PIN!",0
lockedMsg BYTE "Account is Locked!",0
attemptMsg BYTE "Attempts Remaining: ",0

attempts DWORD 3
enteredAccount DWORD ?
enteredPIN DWORD ?
foundIndex DWORD ?

.code

PUBLIC CustomerLogin

CustomerLogin PROC USES ebx ecx esi

    mov attempts, 3

LoginAgain:

    call Clrscr

    mov edx, OFFSET loginTitle
    call WriteString
    call Crlf
    call Crlf

    mov edx, OFFSET accountMsg
    call WriteString
    call ReadDec

    mov enteredAccount, eax

    mov edx, OFFSET pinMsg
    call WriteString

    ; Mask PIN input
    call ReadDec
    mov enteredPIN, eax

    ; Search for account
    mov esi, 0
    mov ecx, accountCount

FindAccount:

    cmp ecx, 0
    je LoginFailed

    mov eax, accountNumbers[esi*4]

    cmp eax, enteredAccount
    je AccountFound

    inc esi
    dec ecx
    jmp FindAccount

AccountFound:

    mov foundIndex, esi

    ; Check account status
    cmp accountStatus[esi*4], 1
    jne AccountLocked

    ; Verify demonstration PIN
    mov eax, accountPins[esi*4]
    cmp eax, enteredPIN
    jne LoginFailed

    mov eax, 1
    jmp LoginEnd

LoginFailed:

    dec attempts

    cmp attempts, 0
    je AccountLocked

    mov edx, OFFSET failureMsg
    call WriteString
    call Crlf

    mov edx, OFFSET attemptMsg
    call WriteString

    mov eax, attempts
    call WriteDec
    call Crlf

    call WaitMsg
    jmp LoginAgain

AccountLocked:

    mov edx, OFFSET lockedMsg
    call WriteString
    call Crlf

    mov eax, 0

LoginEnd:

    ret

CustomerLogin ENDP

END
