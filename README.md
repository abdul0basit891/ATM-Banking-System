# ATM / Bank Account Management System

**Course:** EL-2003 Computer Organization and Assembly Language (COAL) Lab  
**Semester:** Fall 2026  
**Campus:** FAST-NUCES, Karachi  
**Section:** BCS-3J  
**Instructor:** Mr. Abdullah Shaikh

## Project Overview

This project is an ATM and bank account management system developed in **x86 Assembly (MASM)** with a Windows GUI. It uses the Irvine32 library and the Win32 API.

Customers will be able to log in using an account number and PIN, check their balance, deposit and withdraw money, transfer funds, change their PIN, and view recent transactions. Administrators will be able to create, freeze, unfreeze, and review accounts.

Account data is stored in memory while the program is running. Data is not permanently saved after the application closes.

## Team Members

| Name | Roll Number | Role |
|---|---|---|
| Abdul Basit | 25K-0997 | Group Leader |
| Sheikh Jawad | 25K-3093 | Member |
| Muhammad Daniyal | 25K-0944 | Member |

## Main Features

- Customer login with masked PIN input and a three-attempt lockout
- Balance inquiry
- Cash deposits and withdrawals
- Transfers between accounts, including a 1% transfer fee
- Mini statement showing the five most recent transactions
- PIN change
- Admin account creation and account management
- Input validation, transaction limits, and minimum-balance checks
- Windows GUI using Win32 API controls and message handling

## Technologies and Tools

- x86 Assembly (MASM), 32-bit
- Microsoft Visual Studio with MASM
- Irvine32 library
- Win32 API
- `kernel32.lib` and `user32.lib`
