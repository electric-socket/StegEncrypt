$Console:Only
Option _Explicit
'$Include:'L:\Programming\Basic\qb64pe_win-x64_User Programs\Common_Dialog_Prefix.bi'

' Used by open dialog
Dim Filter$, Flags&, Hwnd&

Const FNum = 5
Dim FN$, OutFN$
Dim As _Unsigned _Integer64 FSize
Dim As Long Limit

Limit = _CommandCount

If Limit <> 1 Then Print "?Name of file to copy required.": GoTo Done

FN$ = Command$(1)

Print "Attempting to open "; FN$

On Error GoTo Error1
Open FN$ For Binary Access Read As #FNum

On Error GoTo Error2

' Find out how big the file is, and resize the array to fit
FSize = LOF(FNum)

ReDim Fi(FSize)

' Load the file in its entirety to array Fi

Get #FNum, , Fi()
Close #FNum

Print "File "; FN$; " read, size"; Using "######## bytes. "; FSize;

Print "Enter name to save file as:"


Filter$ = "All files (*.*)|*.*"
Flags& = OFN_OVERWRITEPROMPT + OFN_NOCHANGEDIR '   add flag constants here
OutFN$ = GetSaveFileName$("Enter name to copy file " + FN$ + " to:", ".\", Filter$, 1, Flags&, Hwnd&)



If OutFN$ = "" Then
    Print "Save cancelled."
    GoTo Done
End If

On Error GoTo Error3

Open OutFN$ For Binary Access Write As #FNum

On Error GoTo Error4

Put #FNum, , Fi()
Close #FNum
Print "File "; FN$; " successfully copied to "; OutFN$; "."



Done:

End

Error1:
Print "?File "; FN$; " could not be opened."
Resume Done

Error2:
Print "?File "; FN$; " could not be read."
Resume Done

Error3:
Print "?Output File "; OutFN$; " could not be opened."
Resume Done

Error4:
Print "?Output File "; OutFN$; " could not be written."
Resume Done


'$Include:'L:\Programming\Basic\qb64pe_win-x64_User Programs\Common_Dialog_Suffix.bi'


