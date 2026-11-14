
.386

INCLUDE Irvine32.inc
INCLUDE ATMCommon.inc
INCLUDE ATMData.inc

.data

accountFile BYTE "accounts.dat", 0

.code

PUBLIC LoadAccounts
PUBLIC SaveAccounts

; =========================================
; LOAD ACCOUNT DATA
; =========================================

LoadAccounts PROC C USES ebx

    mov edx, OFFSET accountFile
    call OpenInputFile

    ; Check whether file exists
    cmp eax, -1
    je FileNotFound

    mov ebx, eax

    ; Read account count
    mov eax, ebx
    mov edx, OFFSET accountCount
    mov ecx, 4
    call ReadFromFile

    jc InvalidFile
    cmp eax, 4
    jne InvalidFile

    ; Validate account count
    cmp accountCount, 1
    jb InvalidFile

    cmp accountCount, MAX_ACCOUNTS
    ja InvalidFile

    ; Read account numbers
    mov eax, ebx
    mov edx, OFFSET accountNumbers
    mov ecx, 40
    call ReadFromFile

    jc InvalidFile
    cmp eax, 40
    jne InvalidFile

    ; Read PINs
    mov eax, ebx
    mov edx, OFFSET accountPins
    mov ecx, 40
    call ReadFromFile

    jc InvalidFile
    cmp eax, 40
    jne InvalidFile

    ; Read balances
    mov eax, ebx
    mov edx, OFFSET accountBalances
    mov ecx, 40
    call ReadFromFile

    jc InvalidFile
    cmp eax, 40
    jne InvalidFile

    ; Read account statuses
    mov eax, ebx
    mov edx, OFFSET accountStatus
    mov ecx, 40
    call ReadFromFile

    jc InvalidFile
    cmp eax, 40
    jne InvalidFile

    ; Close file
    mov eax, ebx
    call CloseFile

    mov eax, 1
    ret

; =========================================
; FILE DOES NOT EXIST
; =========================================

FileNotFound:

    call InitializeDefaults
    call SaveAccounts

    ret

; =========================================
; INVALID OR CORRUPTED FILE
; =========================================

InvalidFile:

    mov eax, ebx
    call CloseFile

    call InitializeDefaults
    call SaveAccounts

    ret

LoadAccounts ENDP


; =========================================
; SAVE ACCOUNT DATA
; =========================================

SaveAccounts PROC C USES ebx

    mov edx, OFFSET accountFile
    call CreateOutputFile

    cmp eax, -1
    je SaveFailed

    mov ebx, eax

    ; Save account count
    mov eax, ebx
    mov edx, OFFSET accountCount
    mov ecx, 4
    call WriteToFile

    jc SaveError
    cmp eax, 4
    jne SaveError

    ; Save account numbers
    mov eax, ebx
    mov edx, OFFSET accountNumbers
    mov ecx, 40
    call WriteToFile

    jc SaveError
    cmp eax, 40
    jne SaveError

    ; Save PINs
    mov eax, ebx
    mov edx, OFFSET accountPins
    mov ecx, 40
    call WriteToFile

    jc SaveError
    cmp eax, 40
    jne SaveError

    ; Save balances
    mov eax, ebx
    mov edx, OFFSET accountBalances
    mov ecx, 40
    call WriteToFile

    jc SaveError
    cmp eax, 40
    jne SaveError

    ; Save account statuses
    mov eax, ebx
    mov edx, OFFSET accountStatus
    mov ecx, 40
    call WriteToFile

    jc SaveError
    cmp eax, 40
    jne SaveError

    ; Close file
    mov eax, ebx
    call CloseFile

    mov eax, 1
    ret

SaveError:

    mov eax, ebx
    call CloseFile

SaveFailed:

    mov eax, 0
    ret

SaveAccounts ENDP

END
