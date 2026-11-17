; ATM Management System - MASM32 backend
; Build as 32-bit COFF with the MASM32 SDK / Visual Studio MASM tools.
; Data files are created in the application's current working directory.

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

CreateFileA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFile PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteFile PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CloseHandle PROTO STDCALL :DWORD
lstrcpyA PROTO STDCALL :DWORD,:DWORD
lstrcatA PROTO STDCALL :DWORD,:DWORD
lstrlenA PROTO STDCALL :DWORD

GENERIC_READ EQU 80000000h
GENERIC_WRITE EQU 40000000h
FILE_SHARE_READ EQU 1
OPEN_EXISTING EQU 3
CREATE_ALWAYS EQU 2
INVALID_HANDLE_VALUE EQU -1
FILE_ATTRIBUTE_NORMAL EQU 80h

AppendNumber PROTO :DWORD,:DWORD,:DWORD
AddTransaction PROTO :DWORD,:DWORD,:DWORD,:DWORD


MAX_ACCOUNTS EQU 20
MAX_TX        EQU 10
MIN_BALANCE   EQU 1000
ADMIN_PIN     EQU 9876

ACCOUNT STRUCT
    accNo       DWORD ?
    pinCode     DWORD ?
    balance     DWORD ?
    active      DWORD ?
    failed      DWORD ?
    locked      DWORD ?
ACCOUNT ENDS

ACCOUNT_OFFSET MACRO indexReg
    imul ebx,indexReg,SIZEOF ACCOUNT
ENDM

TRANSACTION STRUCT
    kind        DWORD ?
    amount      DWORD ?
    otherAcc    DWORD ?
TRANSACTION ENDS

.data
accountsFile BYTE "accounts.dat",0
txFile       BYTE "transactions.dat",0
strNoTx BYTE "No transactions recorded.",0
strDep BYTE "Deposit: Rs. ",0
strWd BYTE "Withdrawal: Rs. ",0
strSent BYTE "Transfer sent: Rs. ",0
strRecv BYTE "Transfer received: Rs. ",0
strAccount BYTE "  Account: ",0
strSpaces BYTE "  ",0
strCRLF BYTE 13,10,0
accountCount DWORD 0
accountData  ACCOUNT MAX_ACCOUNTS DUP(<> )
txCounts     DWORD MAX_ACCOUNTS DUP(0)
txNext       DWORD MAX_ACCOUNTS DUP(0)
txData       TRANSACTION (MAX_ACCOUNTS*MAX_TX) DUP(<> )

PUBLIC ATM_Initialize
PUBLIC ATM_Login
PUBLIC ATM_GetBalance
PUBLIC ATM_Deposit
PUBLIC ATM_Withdraw
PUBLIC ATM_Transfer
PUBLIC ATM_GetStatement
PUBLIC ATM_AdminLogin
PUBLIC ATM_CreateAccount
PUBLIC ATM_SetAccountActive
PUBLIC ATM_ChangePIN
PUBLIC ATM_GetAccountCount
PUBLIC ATM_GetAccountInfo
PUBLIC ATM_AdminResetPIN

.code

FindAccount PROC USES esi ebx accNo:DWORD
    xor esi,esi
@@:
    cmp esi,accountCount
    jae faNotFound
    mov eax,accNo
    ACCOUNT_OFFSET esi
    cmp eax,accountData[ebx].accNo
    je faFound
    inc esi
    jmp @B
faFound:
    mov eax,esi
    ret
faNotFound:
    mov eax,-1
    ret
FindAccount ENDP

SaveAccounts PROC USES esi
    LOCAL hFile:DWORD, written:DWORD, accountBytes:DWORD
    invoke CreateFileA,ADDR accountsFile,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    cmp eax,INVALID_HANDLE_VALUE
    je saFail
    mov hFile,eax
    invoke WriteFile,hFile,ADDR accountCount,4,ADDR written,0
    test eax,eax
    jz saBad
    cmp written,4
    jne saBad
    mov eax,accountCount
    imul eax,SIZEOF ACCOUNT
    mov accountBytes,eax
    invoke WriteFile,hFile,ADDR accountData,accountBytes,ADDR written,0
    test eax,eax
    jz saBad
    invoke CloseHandle,hFile
    mov eax,1
    ret
saBad:
    invoke CloseHandle,hFile
saFail:
    xor eax,eax
    ret
SaveAccounts ENDP

LoadAccounts PROC USES esi ebx
    LOCAL hFile:DWORD, got:DWORD, need:DWORD
    invoke CreateFileA,ADDR accountsFile,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    cmp eax,INVALID_HANDLE_VALUE
    je laDefaults
    mov hFile,eax
    invoke ReadFile,hFile,ADDR accountCount,4,ADDR got,0
    cmp eax,0
    je laBad
    cmp got,4
    jne laBad
    cmp accountCount,1
    jb laBad
    cmp accountCount,MAX_ACCOUNTS
    ja laBad
    mov eax,accountCount
    imul eax,SIZEOF ACCOUNT
    mov need,eax
    invoke ReadFile,hFile,ADDR accountData,need,ADDR got,0
    cmp eax,0
    je laBad
    mov eax,got
    cmp eax,need
    jne laBad
    invoke CloseHandle,hFile
    mov eax,1
    ret
laBad:
    invoke CloseHandle,hFile
    xor eax,eax
    ret
laDefaults:
    mov accountCount,5
    mov accountData[0].accNo,10001
    mov accountData[0].pinCode,1234
    mov accountData[0].balance,50000
    mov accountData[0].active,1
    mov accountData[4*SIZEOF ACCOUNT].accNo,10002
    mov accountData[4*SIZEOF ACCOUNT].pinCode,2222
    mov accountData[4*SIZEOF ACCOUNT].balance,75000
    mov accountData[4*SIZEOF ACCOUNT].active,1
    mov accountData[8*SIZEOF ACCOUNT].accNo,10003
    mov accountData[8*SIZEOF ACCOUNT].pinCode,3333
    mov accountData[8*SIZEOF ACCOUNT].balance,100000
    mov accountData[8*SIZEOF ACCOUNT].active,1
    mov accountData[12*SIZEOF ACCOUNT].accNo,10004
    mov accountData[12*SIZEOF ACCOUNT].pinCode,4444
    mov accountData[12*SIZEOF ACCOUNT].balance,25000
    mov accountData[12*SIZEOF ACCOUNT].active,1
    mov accountData[16*SIZEOF ACCOUNT].accNo,10005
    mov accountData[16*SIZEOF ACCOUNT].pinCode,5555
    mov accountData[16*SIZEOF ACCOUNT].balance,90000
    mov accountData[16*SIZEOF ACCOUNT].active,1
    mov esi,0
ldClear:
    cmp esi,accountCount
    jae ldSave
    ACCOUNT_OFFSET esi
    mov accountData[ebx].failed,0
    mov accountData[ebx].locked,0
    inc esi
    jmp ldClear
ldSave:
    call SaveAccounts
    mov eax,1
    ret
LoadAccounts ENDP

SaveTransactions PROC USES esi
    LOCAL hFile:DWORD, written:DWORD
    invoke CreateFileA,ADDR txFile,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
    cmp eax,INVALID_HANDLE_VALUE
    je stFail
    mov hFile,eax
    invoke WriteFile,hFile,ADDR txCounts,MAX_ACCOUNTS*4,ADDR written,0
    test eax,eax
    jz stBad
    invoke WriteFile,hFile,ADDR txNext,MAX_ACCOUNTS*4,ADDR written,0
    test eax,eax
    jz stBad
    invoke WriteFile,hFile,ADDR txData,SIZEOF txData,ADDR written,0
    test eax,eax
    jz stBad
    invoke CloseHandle,hFile
    mov eax,1
    ret
stBad:
    invoke CloseHandle,hFile
stFail:
    xor eax,eax
    ret
SaveTransactions ENDP

LoadTransactions PROC USES esi
    LOCAL hFile:DWORD, got:DWORD
    invoke CreateFileA,ADDR txFile,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    cmp eax,INVALID_HANDLE_VALUE
    je ltEmpty
    mov hFile,eax
    invoke ReadFile,hFile,ADDR txCounts,MAX_ACCOUNTS*4,ADDR got,0
    test eax,eax
    jz ltBad
    cmp got,MAX_ACCOUNTS*4
    jne ltBad
    invoke ReadFile,hFile,ADDR txNext,MAX_ACCOUNTS*4,ADDR got,0
    test eax,eax
    jz ltBad
    cmp got,MAX_ACCOUNTS*4
    jne ltBad
    invoke ReadFile,hFile,ADDR txData,SIZEOF txData,ADDR got,0
    test eax,eax
    jz ltBad
    cmp got,SIZEOF txData
    jne ltBad
    invoke CloseHandle,hFile
    xor esi,esi
ltValidate:
    cmp esi,MAX_ACCOUNTS
    jae ltOk
    cmp txCounts[esi*4],MAX_TX
    ja ltEmpty
    cmp txNext[esi*4],MAX_TX
    jae ltEmpty
    inc esi
    jmp ltValidate
ltOk:
    mov eax,1
    ret
ltBad:
    invoke CloseHandle,hFile
ltEmpty:
    push edi
    xor eax,eax
    mov edi,OFFSET txCounts
    mov ecx,(SIZEOF txCounts + SIZEOF txNext + SIZEOF txData)/4
    rep stosd
    pop edi
    call SaveTransactions
    mov eax,1
    ret
LoadTransactions ENDP

ATM_Initialize PROC
    call LoadAccounts
    test eax,eax
    jz aiFail
    call LoadTransactions
    ret
aiFail:
    xor eax,eax
    ret
ATM_Initialize ENDP

; Returns account index in EAX, or -1. Three incorrect PIN attempts lock account.
ATM_Login PROC USES esi ebx accNo:DWORD,pinValue:DWORD
    invoke FindAccount,accNo
    cmp eax,-1
    je alFail
    mov esi,eax
    ACCOUNT_OFFSET esi
    cmp accountData[ebx].active,1
    jne alFail
    cmp accountData[ebx].locked,0
    jne alFail
    mov eax,accountData[ebx].pinCode
    cmp eax,pinValue
    jne alWrong
    mov accountData[ebx].failed,0
    call SaveAccounts
    mov eax,esi
    ret
alWrong:
    inc accountData[ebx].failed
    cmp accountData[ebx].failed,3
    jb alSave
    mov accountData[ebx].locked,1
alSave:
    call SaveAccounts
alFail:
    mov eax,-1
    ret
ATM_Login ENDP

ATM_GetBalance PROC USES ebx idx:DWORD
    mov eax,idx
    cmp eax,0
    jl agbBad
    cmp eax,accountCount
    jae agbBad
    ACCOUNT_OFFSET eax
    mov eax,accountData[ebx].balance
    ret
agbBad:
    xor eax,eax
    ret
ATM_GetBalance ENDP

AddTransaction PROC USES esi idx:DWORD,kind:DWORD,amount:DWORD,otherAcc:DWORD
    mov esi,idx
    mov eax,txNext[esi*4]
    imul eax,SIZEOF TRANSACTION
    mov edx,esi
    imul edx,MAX_TX*SIZEOF TRANSACTION
    add eax,edx
    mov edx,kind
    mov txData[eax].kind,edx
    mov edx,amount
    mov txData[eax].amount,edx
    mov edx,otherAcc
    mov txData[eax].otherAcc,edx
    inc txNext[esi*4]
    cmp txNext[esi*4],MAX_TX
    jb atCount
    mov txNext[esi*4],0
atCount:
    cmp txCounts[esi*4],MAX_TX
    jae atSave
    inc txCounts[esi*4]
atSave:
    call SaveTransactions
    ret
AddTransaction ENDP

ATM_Deposit PROC USES esi ebx idx:DWORD,amount:DWORD
    mov esi,idx
    cmp esi,0
    jl adBad
    cmp esi,accountCount
    jae adBad
    mov eax,amount
    test eax,eax
    jz adBad
    ACCOUNT_OFFSET esi
    mov edx,accountData[ebx].balance
    add edx,eax
    jc adBad
    mov accountData[ebx].balance,edx
    invoke AddTransaction,esi,1,amount,0
    call SaveAccounts
    mov eax,1
    ret
adBad:
    xor eax,eax
    ret
ATM_Deposit ENDP

ATM_Withdraw PROC USES esi ebx idx:DWORD,amount:DWORD
    mov esi,idx
    cmp esi,0
    jl awBad
    cmp esi,accountCount
    jae awBad
    mov eax,amount
    test eax,eax
    jz awBad
    ACCOUNT_OFFSET esi
    mov edx,accountData[ebx].balance
    cmp edx,eax
    jb awBad
    sub edx,eax
    cmp edx,MIN_BALANCE
    jb awBad
    mov accountData[ebx].balance,edx
    invoke AddTransaction,esi,2,amount,0
    call SaveAccounts
    mov eax,1
    ret
awBad:
    xor eax,eax
    ret
ATM_Withdraw ENDP

; Transfer fee is 1%, rounded down. EAX=1 on success, 0 on failure.
ATM_Transfer PROC USES esi edi ebx senderIdx:DWORD,recipientNo:DWORD,amount:DWORD
    LOCAL fee:DWORD, total:DWORD
    mov esi,senderIdx
    cmp esi,0
    jl atrBad
    cmp esi,accountCount
    jae atrBad
    invoke FindAccount,recipientNo
    cmp eax,-1
    je atrBad
    mov edi,eax
    cmp edi,esi
    je atrBad
    ACCOUNT_OFFSET edi
    cmp accountData[ebx].active,1
    jne atrBad
    mov eax,amount
    test eax,eax
    jz atrBad
    xor edx,edx
    mov ecx,100
    div ecx
    mov fee,eax
    mov eax,amount
    add eax,fee
    jc atrBad
    mov total,eax
    ACCOUNT_OFFSET esi
    mov edx,accountData[ebx].balance
    cmp edx,total
    jb atrBad
    sub edx,total
    cmp edx,MIN_BALANCE
    jb atrBad
    ACCOUNT_OFFSET edi
    mov eax,accountData[ebx].balance
    add eax,amount
    jc atrBad
    ACCOUNT_OFFSET esi
    mov accountData[ebx].balance,edx
    ACCOUNT_OFFSET edi
    mov accountData[ebx].balance,eax
    invoke AddTransaction,esi,3,amount,recipientNo
    ACCOUNT_OFFSET esi
    mov eax,accountData[ebx].accNo
    invoke AddTransaction,edi,4,amount,eax
    call SaveAccounts
    mov eax,1
    ret
atrBad:
    xor eax,eax
    ret
ATM_Transfer ENDP

ATM_GetStatement PROC USES esi edi idx:DWORD,pOut:DWORD,maxLen:DWORD
    LOCAL n:DWORD,slot:DWORD,offsetTx:DWORD,used:DWORD
    mov esi,idx
    mov edi,pOut
    cmp esi,0
    jl agsBad
    cmp esi,accountCount
    jae agsBad
    cmp maxLen,2
    jb agsBad
    mov BYTE PTR [edi],0
    mov used,0
    mov eax,txCounts[esi*4]
    mov n,eax
    cmp n,0
    jne agsStart
    invoke lstrcpyA,pOut,ADDR strNoTx
    mov eax,1
    ret
agsStart:
    mov eax,txNext[esi*4]
    sub eax,n
    jns agsSlot
    add eax,MAX_TX
agsSlot:
    mov slot,eax
agsLoop:
    cmp n,0
    je agsDone
    mov eax,esi
    imul eax,MAX_TX*SIZEOF TRANSACTION
    mov edx,slot
    imul edx,SIZEOF TRANSACTION
    add eax,edx
    mov offsetTx,eax
    mov ecx,offsetTx
    mov eax,txData[ecx].kind
    .if eax == 1
        invoke lstrcatA,pOut,ADDR strDep
    .elseif eax == 2
        invoke lstrcatA,pOut,ADDR strWd
    .elseif eax == 3
        invoke lstrcatA,pOut,ADDR strSent
    .else
        invoke lstrcatA,pOut,ADDR strRecv
    .endif
    mov eax,offsetTx
    mov eax,txData[eax].amount
    invoke AppendNumber,pOut,eax,maxLen
    invoke lstrcatA,pOut,ADDR strSpaces
    mov eax,offsetTx
    mov eax,txData[eax].otherAcc
    .if eax != 0
        invoke lstrcatA,pOut,ADDR strAccount
        invoke AppendNumber,pOut,eax,maxLen
    .endif
    invoke lstrcatA,pOut,ADDR strCRLF
    invoke lstrlenA,pOut
    mov used,eax
    cmp eax,maxLen
    jae agsDone
    inc slot
    cmp slot,MAX_TX
    jb agsNext
    mov slot,0
agsNext:
    dec n
    jmp agsLoop
agsDone:
    mov eax,1
    ret
agsBad:
    xor eax,eax
    ret
ATM_GetStatement ENDP

; Appends an unsigned decimal number while respecting maxLen.
AppendNumber PROC USES ebx esi edi pText:DWORD,value:DWORD,maxLen:DWORD
    LOCAL digits[12]:BYTE, count:DWORD, currentLen:DWORD
    lea esi,digits
    mov eax,value
    xor ecx,ecx
    mov ebx,10
    .if eax == 0
        mov BYTE PTR [esi], '0'
        inc ecx
    .else
anLoop:
        xor edx,edx
        div ebx
        add dl,'0'
        mov [esi+ecx],dl
        inc ecx
        test eax,eax
        jnz anLoop
    .endif
    mov count,ecx
    invoke lstrlenA,pText
    mov currentLen,eax
    mov eax,currentLen
    add eax,count
    inc eax
    cmp eax,maxLen
    ja anExit
    mov edi,pText
    add edi,currentLen
    mov ecx,count
anCopy:
    dec ecx
    mov al,digits[ecx]
    mov [edi],al
    inc edi
    test ecx,ecx
    jnz anCopy
    mov BYTE PTR [edi],0
anExit:
    ret
AppendNumber ENDP

ATM_AdminLogin PROC pinValue:DWORD
    mov eax,pinValue
    cmp eax,ADMIN_PIN
    jne aalBad
    mov eax,1
    ret
aalBad:
    xor eax,eax
    ret
ATM_AdminLogin ENDP

; Creates account. EAX returns the new account number, or 0 on failure.
ATM_CreateAccount PROC USES esi ebx pinValue:DWORD,openingBalance:DWORD
    mov eax,accountCount
    cmp eax,MAX_ACCOUNTS
    jae acaBad
    mov esi,eax
    mov edx,openingBalance
    cmp edx,MIN_BALANCE
    jb acaBad
    mov eax,10001
    add eax,esi
    ACCOUNT_OFFSET esi
    mov accountData[ebx].accNo,eax
    mov edx,pinValue
    cmp edx,1000
    jb acaBad
    cmp edx,9999
    ja acaBad
    mov accountData[ebx].pinCode,edx
    mov eax,openingBalance
    mov accountData[ebx].balance,eax
    mov accountData[ebx].active,1
    mov accountData[ebx].failed,0
    mov accountData[ebx].locked,0
    inc accountCount
    call SaveAccounts
    ACCOUNT_OFFSET esi
    mov eax,accountData[ebx].accNo
    ret
acaBad:
    xor eax,eax
    ret
ATM_CreateAccount ENDP

; Active value must be 0 (freeze) or 1 (unfreeze).
ATM_SetAccountActive PROC USES ebx accNo:DWORD,activeValue:DWORD
    invoke FindAccount,accNo
    cmp eax,-1
    je asaBad
    mov ecx,activeValue
    cmp ecx,0
    je asaSet
    cmp ecx,1
    jne asaBad
asaSet:
    ACCOUNT_OFFSET eax
    mov accountData[ebx].active,ecx
    call SaveAccounts
    mov eax,1
    ret
asaBad:
    xor eax,eax
    ret
ATM_SetAccountActive ENDP

ATM_ChangePIN PROC USES ebx idx:DWORD,oldPIN:DWORD,newPIN:DWORD
    mov eax,idx
    cmp eax,0
    jl acpBad
    cmp eax,accountCount
    jae acpBad
    ACCOUNT_OFFSET eax
    mov edx,accountData[ebx].pinCode
    cmp edx,oldPIN
    jne acpBad
    mov edx,newPIN
    cmp edx,1000
    jb acpBad
    cmp edx,9999
    ja acpBad
    mov accountData[ebx].pinCode,edx
    call SaveAccounts
    mov eax,1
    ret
acpBad:
    xor eax,eax
    ret
ATM_ChangePIN ENDP


; Administrator resets a customer's PIN and clears lockout state.
; EAX=1 on success, 0 on invalid account/PIN or save failure.
ATM_AdminResetPIN PROC USES esi ebx accNo:DWORD,newPIN:DWORD
    invoke FindAccount,accNo
    cmp eax,-1
    je arpBad
    mov esi,eax
    mov edx,newPIN
    cmp edx,1000
    jb arpBad
    cmp edx,9999
    ja arpBad
    ACCOUNT_OFFSET esi
    mov accountData[ebx].pinCode,edx
    mov accountData[ebx].failed,0
    mov accountData[ebx].locked,0
    call SaveAccounts
    mov eax,1
    ret
arpBad:
    xor eax,eax
    ret
ATM_AdminResetPIN ENDP

ATM_GetAccountCount PROC
    mov eax,accountCount
    ret
ATM_GetAccountCount ENDP

ATM_GetAccountInfo PROC USES esi ebx idx:DWORD,pAccNo:DWORD,pBalance:DWORD,pActive:DWORD
    mov esi,idx
    cmp esi,0
    jl agiBad
    cmp esi,accountCount
    jae agiBad
    ACCOUNT_OFFSET esi
    mov eax,accountData[ebx].accNo
    mov ecx,pAccNo
    mov [ecx],eax
    mov eax,accountData[ebx].balance
    mov ecx,pBalance
    mov [ecx],eax
    mov eax,accountData[ebx].active
    mov ecx,pActive
    mov [ecx],eax
    mov eax,1
    ret
agiBad:
    xor eax,eax
    ret
ATM_GetAccountInfo ENDP

END
