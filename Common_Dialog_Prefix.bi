$IncludeOnce

' Dialog flag constants (use + or OR to use more than 1 flag value)
Const OFN_ALLOWMULTISELECT = &H200& '  Allows the user to select more than one file, not recommended!
Const OFN_CREATEPROMPT = &H2000& '     Prompts if a file not found should be created(GetOpenFileName only).
Const OFN_EXTENSIONDIFFERENT = &H400& 'Allows user to specify file extension other than default extension.
Const OFN_FILEMUSTEXIST = &H1000& '    Chechs File name exists(GetOpenFileName only).
Const OFN_HIDEREADONLY = &H4& '        Hides read-only checkbox(GetOpenFileName only)
Const OFN_NOCHANGEDIR = &H8& '         Restores the current directory to original value if user changed
Const OFN_NODEREFERENCELINKS = &H100000& 'Returns path and file name of selected shortcut(.LNK) file instead of file referenced.
Const OFN_NONETWORKBUTTON = &H20000& ' Hides and disables the Network button.
Const OFN_NOREADONLYRETURN = &H8000& ' Prevents selection of read-only files, or files in read-only subdirectory.
Const OFN_NOVALIDATE = &H100& '        Allows invalid file name characters.
Const OFN_OVERWRITEPROMPT = &H2& '     Prompts if file already exists(GetSaveFileName only)
Const OFN_PATHMUSTEXIST = &H800& '     Checks Path name exists (set with OFN_FILEMUSTEXIST).
Const OFN_READONLY = &H1& '            Checks read-only checkbox. Returns if checkbox is checked
Const OFN_SHAREAWARE = &H4000& '       Ignores sharing violations in networking
Const OFN_SHOWHELP = &H10& '           Shows the help button (useless!)
'--------------------------------------------------------------------------------------------


Type FILEDIALOGTYPE
    $If 32BIT Then
    lStructSize AS LONG '        For the DLL call
    hwndOwner AS LONG '          Dialog will hide behind window when not set correctly
    hInstance AS LONG '          Handle to a module that contains a dialog box template.
    lpstrFilter AS _OFFSET '     Pointer of the string of file filters
    lpstrCustFilter AS _OFFSET
    nMaxCustFilter AS LONG
    nFilterIndex AS LONG '       One based starting filter index to use when dialog is called
    lpstrFile AS _OFFSET '       String full of 0's for the selected file name
    nMaxFile AS LONG '           Maximum length of the string stuffed with 0's minus 1
    lpstrFileTitle AS _OFFSET '  Same as lpstrFile
    nMaxFileTitle AS LONG '      Same as nMaxFile
    lpstrInitialDir AS _OFFSET ' Starting directory
    lpstrTitle AS _OFFSET '      Dialog title
    flags AS LONG '              Dialog flags
    nFileOffset AS INTEGER '     Zero-based offset from path beginning to file name string pointed to by lpstrFile
    nFileExtension AS INTEGER '  Zero-based offset from path beginning to file extension string pointed to by lpstrFile.
    lpstrDefExt AS _OFFSET '     Default/selected file extension
    lCustData AS LONG
    lpfnHook AS LONG
    lpTemplateName AS _OFFSET
    $Else
        lStructSize As _Offset '      For the DLL call
        hwndOwner As _Offset '        Dialog will hide behind window when not set correctly
        hInstance As _Offset '        Handle to a module that contains a dialog box template.
        lpstrFilter As _Offset '      Pointer of the string of file filters
        lpstrCustFilter As Long
        nMaxCustFilter As Long
        nFilterIndex As _Integer64 '  One based starting filter index to use when dialog is called
        lpstrFile As _Offset '        String full of 0's for the selected file name
        nMaxFile As _Offset '         Maximum length of the string stuffed with 0's minus 1
        lpstrFileTitle As _Offset '   Same as lpstrFile
        nMaxFileTitle As _Offset '    Same as nMaxFile
        lpstrInitialDir As _Offset '  Starting directory
        lpstrTitle As _Offset '       Dialog title
        flags As _Integer64 '         Dialog flags
        nFileOffset As _Integer64 '   Zero-based offset from path beginning to file name string pointed to by lpstrFile
        nFileExtension As _Integer64 'Zero-based offset from path beginning to file extension string pointed to by lpstrFile.
        lpstrDefExt As _Offset '      Default/selected file extension
        lCustData As _Integer64
        lpfnHook As _Integer64
        lpTemplateName As _Offset
    $End If
End Type

Declare Dynamic Library "comdlg32" ' Library declarations using _OFFSET types
    Function GetOpenFileNameA& (DIALOGPARAMS As FILEDIALOGTYPE) ' The Open file dialog
    '  Function GetOpenFileNameW& (DIALOGPARAMS As FILEDIALOGTYPE) ' The Open file dialog
    Function GetSaveFileNameA& (DIALOGPARAMS As FILEDIALOGTYPE) ' The Save file dialog
End Declare

Declare Library
    Function FindWindow& (ByVal ClassName As _Offset, WindowName$) ' To get hWnd handle
    Function MultiByteToWideChar~&& (CodePage As _Unsigned _Integer64, _
    dwFlags as  _Unsigned  _Integer64, _
    In_NLS_string as _offset, _
    cbMultiByte as _Integer64, _
    lpWideCharStr  as _offset, _
    cchWideChar as _Integer64) ' unsigned Int func    Kernel32
End Declare

' These are public so we can set any special params not accounted for
Dim Shared OpenCall As FILEDIALOGTYPE ' Needed for dialog call
Dim Shared SaveCall As FILEDIALOGTYPE ' Needed for dialog call
dim Shared lpstrFile$

$Let DIALOG_PREFIX = 1

