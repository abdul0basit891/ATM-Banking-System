INCLUDE Irvine32.inc
INCLUDE ATMCommon.inc
INCLUDE ATMData.inc
INCLUDE ATMFiles.inc

.data

titleMsg BYTE "========================================", 0
heading  BYTE "       ATM MANAGEMENT SYSTEM", 0
lineMsg  BYTE "========================================", 0

accountMsg BYTE "Account Number: ", 0
balanceMsg BYTE "Balance: Rs. ", 0

loadingMsg BYTE "Loading account database...", 0
successMsg BYTE "Account database loaded successfully!", 0
savingMsg  BYTE "Saving account database...", 0
savedMsg   BYTE "Account database saved successfully!", 0
errorMsg   BYTE "Error saving account database!", 0

currentIndex DWORD 0

.code

main PROC

    call Clrscr

    ; Display welcome screen
    mov edx, OFFSET titleMsg
    call WriteString
    call Crlf

    mov edx, OFFSET heading
    call WriteString
    call Crlf

    mov edx, OFFSET lineMsg
    call WriteString
    call Crlf
    call Crlf

    ; Load account database
    mov edx, OFFSET loadingMsg
    call WriteString
    call Crlf

    call LoadAccounts

    mov edx, OFFSET successMsg
    call WriteString
    call Crlf
    call Crlf

    ; Display accounts
    mov currentIndex, 0

DisplayAccounts:

    mov eax, currentIndex
    cmp eax, accountCount
    jae DisplayFinished

    ; Calculate array index
    mov esi, currentIndex
    shl esi, 2

    ; Display account number
    mov edx, OFFSET accountMsg
    call WriteString

    mov eax, accountNumbers[esi]
    call WriteDec
    call Crlf

    ; Display balance
    mov edx, OFFSET balanceMsg
    call WriteString

    mov eax, accountBalances[esi]
    call WriteDec
    call Crlf

    ; Display account status
    cmp accountStatus[esi], 1
    jne DisplayInactive

    mov al, 'A'
    call WriteChar
    mov al, 'c'
    call WriteChar
    mov al, 't'
    call WriteChar
    mov al, 'i'
    call WriteChar
    mov al, 'v'
    call WriteChar
    mov al, 'e'
    call WriteChar

    jmp ContinueDisplay

DisplayInactive:

    mov edx, OFFSET lineMsg
    call WriteString

ContinueDisplay:

    call Crlf
    call Crlf

    inc currentIndex
    jmp DisplayAccounts

DisplayFinished:

    ; Save account database
    mov edx, OFFSET savingMsg
    call WriteString
    call Crlf

    call SaveAccounts

    cmp eax, 1
    jne SaveError

    mov edx, OFFSET savedMsg
    call WriteString
    call Crlf

    jmp ProgramFinished

SaveError:

    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf

ProgramFinished:

    call Crlf
    call WaitMsg

    exit

main ENDP

END main
