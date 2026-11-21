; ATM Management System - native Win32 GUI (32-bit MASM)
; Requires the Windows SDK headers/libraries and a MASM-compatible assembler.

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

HINSTANCE TYPEDEF DWORD
HWND TYPEDEF DWORD
HFONT TYPEDEF DWORD
UINT TYPEDEF DWORD
WPARAM TYPEDEF DWORD
LPARAM TYPEDEF DWORD
LPSTR TYPEDEF DWORD

WNDCLASSEX STRUCT
    cbSize DWORD ?
    style DWORD ?
    lpfnWndProc DWORD ?
    cbClsExtra DWORD ?
    cbWndExtra DWORD ?
    hInstance DWORD ?
    hIcon DWORD ?
    hCursor DWORD ?
    hbrBackground DWORD ?
    lpszMenuName DWORD ?
    lpszClassName DWORD ?
    hIconSm DWORD ?
WNDCLASSEX ENDS

POINT STRUCT
    x SDWORD ?
    y SDWORD ?
POINT ENDS

MSG STRUCT
    hwnd DWORD ?
    message DWORD ?
    wParam DWORD ?
    lParam DWORD ?
    time DWORD ?
    pt POINT <>
MSG ENDS

CreateWindowExA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetWindowTextA PROTO STDCALL :DWORD,:DWORD
GetWindowTextA PROTO STDCALL :DWORD,:DWORD,:DWORD
lstrlenA PROTO STDCALL :DWORD
lstrcpyA PROTO STDCALL :DWORD,:DWORD
lstrcatA PROTO STDCALL :DWORD,:DWORD
SendMessageA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
CreateFontA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetModuleHandleA PROTO STDCALL :DWORD
RegisterClassExA PROTO STDCALL :DWORD
LoadIconA PROTO STDCALL :DWORD,:DWORD
LoadCursorA PROTO STDCALL :DWORD,:DWORD
ShowWindow PROTO STDCALL :DWORD,:DWORD
UpdateWindow PROTO STDCALL :DWORD
GetMessageA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
TranslateMessage PROTO STDCALL :DWORD
DispatchMessageA PROTO STDCALL :DWORD
DefWindowProcA PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
PostQuitMessage PROTO STDCALL :DWORD
ExitProcess PROTO STDCALL :DWORD

TRUE EQU 1
FALSE EQU 0
WS_CHILD EQU 40000000h
WS_VISIBLE EQU 10000000h
WS_OVERLAPPEDWINDOW EQU 00CF0000h
WS_THICKFRAME EQU 00040000h
WS_MAXIMIZEBOX EQU 00010000h
WS_VSCROLL EQU 00200000h
WS_EX_CLIENTEDGE EQU 00000200h
ES_AUTOHSCROLL EQU 0080h
ES_PASSWORD EQU 0020h
ES_MULTILINE EQU 0004h
ES_AUTOVSCROLL EQU 0040h
ES_READONLY EQU 0800h
CS_VREDRAW EQU 0001h
CS_HREDRAW EQU 0002h
WM_CREATE EQU 0001h
WM_DESTROY EQU 0002h
WM_COMMAND EQU 0111h
WM_SETFONT EQU 0030h
IDC_ARROW EQU 32512
IDI_APPLICATION EQU 32512
COLOR_BTNFACE EQU 15
FW_NORMAL EQU 400
DEFAULT_CHARSET EQU 1
OUT_DEFAULT_PRECIS EQU 0
CLIP_DEFAULT_PRECIS EQU 0
DEFAULT_QUALITY EQU 0
DEFAULT_PITCH EQU 0
FF_DONTCARE EQU 0
CW_USEDEFAULT EQU 80000000h
SW_SHOWDEFAULT EQU 10

ATM_Initialize PROTO
ATM_Login PROTO :DWORD,:DWORD
ATM_GetBalance PROTO :DWORD
ATM_Deposit PROTO :DWORD,:DWORD
ATM_Withdraw PROTO :DWORD,:DWORD
ATM_Transfer PROTO :DWORD,:DWORD,:DWORD
ATM_GetStatement PROTO :DWORD,:DWORD,:DWORD
ATM_AdminLogin PROTO :DWORD
ATM_CreateAccount PROTO :DWORD,:DWORD
ATM_SetAccountActive PROTO :DWORD,:DWORD
ATM_ChangePIN PROTO :DWORD,:DWORD,:DWORD
ATM_GetAccountCount PROTO
ATM_GetAccountInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
ATM_AdminResetPIN PROTO :DWORD,:DWORD

ID_ACCOUNT      EQU 101
ID_PIN          EQU 102
ID_AMOUNT       EQU 103
ID_RECIPIENT    EQU 104
ID_NEW_PIN      EQU 105
ID_LOGIN        EQU 201
ID_BALANCE      EQU 202
ID_DEPOSIT      EQU 203
ID_WITHDRAW     EQU 204
ID_TRANSFER     EQU 205
ID_STATEMENT    EQU 206
ID_ADMIN        EQU 207
ID_CREATE       EQU 208
ID_FREEZE       EQU 209
ID_UNFREEZE     EQU 210
ID_CHANGEPIN    EQU 211
ID_LOGOUT       EQU 212
ID_OUTPUT       EQU 301
ID_LIST         EQU 213
ID_RESET_PIN    EQU 214

.data
className  BYTE "ATMMainWindow",0
windowTitle BYTE "ATM Management System",0
fontName BYTE "Segoe UI",0
textAccount BYTE "Account number",0
textPin BYTE "PIN",0
textAmount BYTE "Amount (Rs.)",0
textRecipient BYTE "Recipient account",0
textNewPin BYTE "New PIN",0
textWelcome BYTE "Welcome to ATM Management System",0
textAdminHint BYTE "Administrator login required.",0
textLoginFirst BYTE "Please login first.",0
textInvalid BYTE "Invalid input or operation failed.",0
textWrongPIN BYTE "Incorrect PIN. Please try again.",0
textLocked BYTE "Account locked after 3 incorrect attempts. Contact administrator.",0
textLoginOK BYTE "Login successful.",0
textDepositOK BYTE "Deposit successful.",0
textWithdrawOK BYTE "Withdrawal successful.",0
textTransferOK BYTE "Transfer successful.",0
textFreezeOK BYTE "Account frozen.",0
textUnfreezeOK BYTE "Account unfrozen.",0
textResetPinOK BYTE "PIN reset successful.",0
textChangePinOK BYTE "PIN changed successfully.",0
textAdminOK BYTE "Administrator mode enabled.",0
textCreateOK BYTE "Account created. New account number: ",0
textBalance BYTE "Available balance: Rs. ",0
textCRLF BYTE 13,10,0
textListTitle BYTE "ACCOUNT LIST",13,10,"------------------------------",13,10,0
textAccLabel BYTE "Account: ",0
textBalLabel BYTE " | Balance: Rs. ",0
textStatusActive BYTE " | Active",13,10,0
textStatusFrozen BYTE " | Frozen",13,10,0
textTotalLabel BYTE "Total bank balance: Rs. ",0
szStatic BYTE "STATIC",0
szEdit BYTE "EDIT",0
szButton BYTE "BUTTON",0
strLoginBtn BYTE "Login",0
strBalanceBtn BYTE "Balance",0
strDepositBtn BYTE "Deposit",0
strWithdrawBtn BYTE "Withdraw",0
strTransferBtn BYTE "Transfer",0
strStatementBtn BYTE "Statement",0
strAdminBtn BYTE "Admin Login",0
strCreateBtn BYTE "Create Account",0
strFreezeBtn BYTE "Freeze",0
strUnfreezeBtn BYTE "Unfreeze",0
strChangeBtn BYTE "Change PIN",0
strLogoutBtn BYTE "Logout",0
strListBtn BYTE "List Accounts",0
strResetPinBtn BYTE "Reset PIN",0
textStatement BYTE 4096 DUP(0)
numBuffer BYTE 16 DUP(0)

.data?
hInstance HINSTANCE ?
hMain HWND ?
hAccount HWND ?
hPin HWND ?
hAmount HWND ?
hRecipient HWND ?
hNewPin HWND ?
accNoBuffer DWORD ?
balanceBuffer DWORD ?
activeBuffer DWORD ?
totalBuffer DWORD ?
indexBuffer DWORD ?
hOutput HWND ?
hFont HFONT ?
currentIndex DWORD ?
loggedIn DWORD ?
adminMode DWORD ?

.code

ShowMessage PROC pText:DWORD
    invoke SetWindowTextA,hOutput,pText
    ret
ShowMessage ENDP


ParseDecimal PROC USES esi pText:DWORD
    mov esi,pText
    xor eax,eax
pdLoop:
    movzx edx,BYTE PTR [esi]
    test dl,dl
    jz pdDone
    cmp dl,'0'
    jb pdBad
    cmp dl,'9'
    ja pdBad
    imul eax,10
    jo pdBad
    sub edx,'0'
    add eax,edx
    jc pdBad
    inc esi
    jmp pdLoop
pdDone:
    ret
pdBad:
    xor eax,eax
    ret
ParseDecimal ENDP

GetEditNumber PROC hEdit:DWORD
    LOCAL buffer[32]:BYTE
    invoke GetWindowTextA,hEdit,ADDR buffer,32
    invoke lstrlenA,ADDR buffer
    test eax,eax
    jz genBad
    invoke ParseDecimal,ADDR buffer
    ret
genBad:
    xor eax,eax
    ret
GetEditNumber ENDP

; Local unsigned integer-to-text helper for messages.
NumberToText PROC USES ebx esi edi value:DWORD,pBuffer:DWORD
    LOCAL digits[16]:BYTE,count:DWORD
    mov eax,value
    mov ebx,10
    xor ecx,ecx
    .if eax == 0
        mov digits[0],'0'
        inc ecx
    .else
ntLoop:
        xor edx,edx
        div ebx
        add dl,'0'
        mov digits[ecx],dl
        inc ecx
        test eax,eax
        jnz ntLoop
    .endif
    mov count,ecx
    mov edi,pBuffer
ntCopy:
    dec ecx
    mov al,digits[ecx]
    mov [edi],al
    inc edi
    test ecx,ecx
    jnz ntCopy
    mov BYTE PTR [edi],0
    ret
NumberToText ENDP

CreateControls PROC
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textWelcome,WS_CHILD or WS_VISIBLE,20,12,420,24,hMain,0,hInstance,0
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textAccount,WS_CHILD or WS_VISIBLE,20,48,120,22,hMain,0,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL,150,46,130,24,hMain,ID_ACCOUNT,hInstance,0
    mov hAccount,eax
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textPin,WS_CHILD or WS_VISIBLE,300,48,50,22,hMain,0,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_PASSWORD or ES_AUTOHSCROLL,350,46,100,24,hMain,ID_PIN,hInstance,0
    mov hPin,eax
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textAmount,WS_CHILD or WS_VISIBLE,20,84,120,22,hMain,0,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL,150,82,130,24,hMain,ID_AMOUNT,hInstance,0
    mov hAmount,eax
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textRecipient,WS_CHILD or WS_VISIBLE,300,84,120,22,hMain,0,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL,420,82,130,24,hMain,ID_RECIPIENT,hInstance,0
    mov hRecipient,eax
    invoke CreateWindowExA,0,ADDR szStatic,ADDR textNewPin,WS_CHILD or WS_VISIBLE,20,120,120,22,hMain,0,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_PASSWORD or ES_AUTOHSCROLL,150,118,130,24,hMain,ID_NEW_PIN,hInstance,0
    mov hNewPin,eax

    invoke CreateWindowExA,0,ADDR szButton,ADDR strLoginBtn,WS_CHILD or WS_VISIBLE,20,158,90,30,hMain,ID_LOGIN,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strBalanceBtn,WS_CHILD or WS_VISIBLE,120,158,90,30,hMain,ID_BALANCE,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strDepositBtn,WS_CHILD or WS_VISIBLE,220,158,90,30,hMain,ID_DEPOSIT,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strWithdrawBtn,WS_CHILD or WS_VISIBLE,320,158,90,30,hMain,ID_WITHDRAW,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strTransferBtn,WS_CHILD or WS_VISIBLE,420,158,90,30,hMain,ID_TRANSFER,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strStatementBtn,WS_CHILD or WS_VISIBLE,20,198,90,30,hMain,ID_STATEMENT,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strAdminBtn,WS_CHILD or WS_VISIBLE,120,198,100,30,hMain,ID_ADMIN,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strCreateBtn,WS_CHILD or WS_VISIBLE,230,198,120,30,hMain,ID_CREATE,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strFreezeBtn,WS_CHILD or WS_VISIBLE,360,198,80,30,hMain,ID_FREEZE,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strUnfreezeBtn,WS_CHILD or WS_VISIBLE,450,198,90,30,hMain,ID_UNFREEZE,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strChangeBtn,WS_CHILD or WS_VISIBLE,20,238,100,30,hMain,ID_CHANGEPIN,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strLogoutBtn,WS_CHILD or WS_VISIBLE,130,238,90,30,hMain,ID_LOGOUT,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strListBtn,WS_CHILD or WS_VISIBLE,230,238,120,30,hMain,ID_LIST,hInstance,0
    invoke CreateWindowExA,0,ADDR szButton,ADDR strResetPinBtn,WS_CHILD or WS_VISIBLE,360,238,110,30,hMain,ID_RESET_PIN,hInstance,0
    invoke CreateWindowExA,WS_EX_CLIENTEDGE,ADDR szEdit,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or ES_AUTOVSCROLL or ES_READONLY or WS_VSCROLL,20,282,540,190,hMain,ID_OUTPUT,hInstance,0
    mov hOutput,eax
    invoke SendMessageA,hOutput,WM_SETFONT,hFont,TRUE
    invoke SetWindowTextA,hOutput,ADDR textWelcome
    ret
CreateControls ENDP

HandleCommand PROC USES esi edi hWnd:DWORD,wParam:DWORD
    LOCAL cmd:DWORD,val:DWORD,accNo:DWORD,balance:DWORD,active:DWORD
    mov eax,wParam
    and eax,0FFFFh
    mov cmd,eax
    
.if eax == ID_LOGIN
    invoke GetEditNumber,hAccount
    mov accNo,eax

    invoke GetEditNumber,hPin
    invoke ATM_Login,accNo,eax

    cmp eax,-2
    je hcLoginLocked

    cmp eax,-1
    je hcLoginWrong

    mov currentIndex,eax
    mov loggedIn,1
    mov adminMode,0
    invoke ShowMessage,ADDR textLoginOK

    .elseif eax == ID_ADMIN
        invoke GetEditNumber,hPin
        invoke ATM_AdminLogin,eax
        test eax,eax
        jz hcFail
        mov adminMode,1
        invoke ShowMessage,ADDR textAdminOK
    .elseif eax == ID_LOGOUT
        mov loggedIn,0
        mov adminMode,0
        invoke ShowMessage,ADDR textWelcome
    .elseif eax == ID_BALANCE
        cmp loggedIn,1
        jne hcNeedLogin
        invoke ATM_GetBalance,currentIndex
        invoke NumberToText,eax,ADDR numBuffer
        invoke lstrcpyA,ADDR textStatement,ADDR textBalance
        invoke lstrcatA,ADDR textStatement,ADDR numBuffer
        invoke ShowMessage,ADDR textStatement
    .elseif eax == ID_DEPOSIT
        cmp loggedIn,1
        jne hcNeedLogin
        invoke GetEditNumber,hAmount
        invoke ATM_Deposit,currentIndex,eax
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textDepositOK
    .elseif eax == ID_WITHDRAW
        cmp loggedIn,1
        jne hcNeedLogin
        invoke GetEditNumber,hAmount
        invoke ATM_Withdraw,currentIndex,eax
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textWithdrawOK
    .elseif eax == ID_TRANSFER
        cmp loggedIn,1
        jne hcNeedLogin
        invoke GetEditNumber,hRecipient
        mov accNo,eax
        invoke GetEditNumber,hAmount
        invoke ATM_Transfer,currentIndex,accNo,eax
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textTransferOK
    .elseif eax == ID_STATEMENT
        cmp loggedIn,1
        jne hcNeedLogin
        invoke ATM_GetStatement,currentIndex,ADDR textStatement,4096
        invoke ShowMessage,ADDR textStatement
    .elseif eax == ID_CREATE
        cmp adminMode,1
        jne hcNeedAdmin
        invoke GetEditNumber,hPin
        mov val,eax
        invoke GetEditNumber,hAmount
        invoke ATM_CreateAccount,val,eax
        test eax,eax
        jz hcFail
        invoke NumberToText,eax,ADDR numBuffer
        invoke lstrcpyA,ADDR textStatement,ADDR textCreateOK
        invoke lstrcatA,ADDR textStatement,ADDR numBuffer
        invoke ShowMessage,ADDR textStatement
    .elseif eax == ID_FREEZE
        cmp adminMode,1
        jne hcNeedAdmin
        invoke GetEditNumber,hAccount
        invoke ATM_SetAccountActive,eax,0
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textFreezeOK
    .elseif eax == ID_UNFREEZE
        cmp adminMode,1
        jne hcNeedAdmin
        invoke GetEditNumber,hAccount
        invoke ATM_SetAccountActive,eax,1
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textUnfreezeOK
    .elseif eax == ID_LIST
        cmp adminMode,1
        jne hcNeedAdmin
        invoke lstrcpyA,ADDR textStatement,ADDR textListTitle
        invoke ATM_GetAccountCount
        mov indexBuffer,0
        mov totalBuffer,0
        mov balance, eax
        xor esi,esi
    hcListLoop:
        cmp esi,balance
        jae hcListDone
        invoke ATM_GetAccountInfo,esi,ADDR accNoBuffer,ADDR balanceBuffer,ADDR activeBuffer
        test eax,eax
        jz hcListNext
        invoke lstrcatA,ADDR textStatement,ADDR textAccLabel
        invoke NumberToText,accNoBuffer,ADDR numBuffer
        invoke lstrcatA,ADDR textStatement,ADDR numBuffer
        invoke lstrcatA,ADDR textStatement,ADDR textBalLabel
        invoke NumberToText,balanceBuffer,ADDR numBuffer
        invoke lstrcatA,ADDR textStatement,ADDR numBuffer
        mov eax,balanceBuffer
        add totalBuffer,eax
        cmp activeBuffer,1
        jne hcListFrozen
        invoke lstrcatA,ADDR textStatement,ADDR textStatusActive
        jmp hcListNext
    hcListFrozen:
        invoke lstrcatA,ADDR textStatement,ADDR textStatusFrozen
    hcListNext:
        inc esi
        jmp hcListLoop
    hcListDone:
        invoke lstrcatA,ADDR textStatement,ADDR textTotalLabel
        invoke NumberToText,totalBuffer,ADDR numBuffer
        invoke lstrcatA,ADDR textStatement,ADDR numBuffer
        invoke ShowMessage,ADDR textStatement
    .elseif eax == ID_RESET_PIN
        cmp adminMode,1
        jne hcNeedAdmin
        invoke GetEditNumber,hAccount
        mov accNo,eax
        invoke GetEditNumber,hNewPin
        invoke ATM_AdminResetPIN,accNo,eax
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textResetPinOK
    .elseif eax == ID_CHANGEPIN
        cmp loggedIn,1
        jne hcNeedLogin
        invoke GetEditNumber,hPin
        mov val,eax
        invoke GetEditNumber,hNewPin
        invoke ATM_ChangePIN,currentIndex,val,eax
        test eax,eax
        jz hcFail
        invoke ShowMessage,ADDR textChangePinOK
    .endif
    ret
hcLoginWrong:
    invoke ShowMessage,ADDR textWrongPIN
    ret

hcLoginLocked:
    invoke ShowMessage,ADDR textLocked
    ret

hcNeedLogin:
    invoke ShowMessage,ADDR textLoginFirst
    ret
hcNeedAdmin:
    invoke ShowMessage,ADDR textAdminHint
    ret
hcFail:
    invoke ShowMessage,ADDR textInvalid
    ret
HandleCommand ENDP

WndProc PROC hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    .if uMsg == WM_CREATE
        mov eax,hWnd
        mov hMain,eax
        invoke CreateControls
        xor eax,eax
        ret
    .elseif uMsg == WM_COMMAND
        invoke HandleCommand,hWnd,wParam
        xor eax,eax
        ret
    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,0
        xor eax,eax
        ret
    .endif
    invoke DefWindowProcA,hWnd,uMsg,wParam,lParam
    ret
WndProc ENDP

WinMain PROC hInst:HINSTANCE,hPrev:HINSTANCE,lpCmdLine:LPSTR,nShowCmd:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    mov eax,hInst
    mov hInstance,eax
    invoke ATM_Initialize
    test eax,eax
    jz wmInitFail
    mov wc.cbSize,SIZEOF WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc,OFFSET WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0
    mov eax,hInst
    mov wc.hInstance,eax
    invoke LoadIconA,0,IDI_APPLICATION
    mov wc.hIcon,eax
    mov wc.hIconSm,eax
    invoke LoadCursorA,0,IDC_ARROW
    mov wc.hCursor,eax
    mov wc.hbrBackground,COLOR_BTNFACE+1
    mov wc.lpszMenuName,0
    mov wc.lpszClassName,OFFSET className
    invoke RegisterClassExA,ADDR wc
    invoke CreateFontA,16,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH or FF_DONTCARE,ADDR fontName
    mov hFont,eax
    invoke CreateWindowExA,0,ADDR className,ADDR windowTitle,WS_OVERLAPPEDWINDOW xor WS_THICKFRAME xor WS_MAXIMIZEBOX,CW_USEDEFAULT,CW_USEDEFAULT,600,560,0,0,hInst,0
    mov hMain,eax
    test eax,eax
    jz wmInitFail
    invoke ShowWindow,hMain,nShowCmd
    invoke UpdateWindow,hMain
wmMessage:
    invoke GetMessageA,ADDR msg,0,0,0
    cmp eax,0
    jle wmExit
    invoke TranslateMessage,ADDR msg
    invoke DispatchMessageA,ADDR msg
    jmp wmMessage
wmExit:
    mov eax,msg.wParam
    ret
wmInitFail:
    mov eax,0
    ret
WinMain ENDP

start:
    invoke GetModuleHandleA,0
    invoke WinMain,eax,0,0,SW_SHOWDEFAULT
    invoke ExitProcess,eax

END start