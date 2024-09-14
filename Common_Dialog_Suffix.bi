$IncludeOnce
Function GetOpenFileName$ (Title$, InitialDir$, Filter$, FilterIndex, Flags&, hWnd&)
    '  Title$      - The dialog title.
    '  InitialDir$ - If this left blank, it will use the directory where the last opened file is
    '  located. Specify ".\" if you want to always use the current directory.
    '  Filter$     - File filters separated by pipes (|) in the same format as using VB6 common dialogs.
    '  FilterIndex - The initial file filter to use. Will be altered by user during the call.
    '  Flags&      - Dialog flags. Will be altered by the user during the call.
    '  hWnd&       - Your program's window handle that should be aquired by the FindWindow function.
    '
    ' Returns: Blank when cancel is clicked otherwise, the file name selected by the user.
    ' FilterIndex and Flags& will be changed depending on the user's selections.

    '    Dim OpenCall As FILEDIALOGTYPE ' Needed for dialog call
    Dim fFilter$, R As Integer, lpstrDefExt$, Result As Long
    ' Dim lpstrFile$ ' Allow main program to modify

    fFilter$ = Filter$
    For R = 1 To Len(fFilter$) ' Replace the pipes with character zero
        If Mid$(fFilter$, R, 1) = "|" Then Mid$(fFilter$, R, 1) = Chr$(0)
    Next R
    fFilter$ = fFilter$ + Chr$(0)

    lpstrFile$ = String$(2048, 0) ' For the returned file name
    lpstrDefExt$ = String$(10, 0) ' Extension will not be added when this is not specified
    OpenCall.lStructSize = Len(OpenCall)
    OpenCall.hwndOwner = hWnd&
    OpenCall.lpstrFilter = _Offset(fFilter$)
    OpenCall.nFilterIndex = FilterIndex
    OpenCall.lpstrFile = _Offset(lpstrFile$)
    OpenCall.nMaxFile = Len(lpstrFile$) - 1
    OpenCall.lpstrFileTitle = OpenCall.lpstrFile
    OpenCall.nMaxFileTitle = OpenCall.nMaxFile
    OpenCall.lpstrInitialDir = _Offset(InitialDir$)
    OpenCall.lpstrTitle = _Offset(Title$)
    OpenCall.lpstrDefExt = _Offset(lpstrDefExt$)
    OpenCall.flags = Flags&

    Result = GetOpenFileNameA&(OpenCall) '            Do Open File dialog call!

    If Result Then ' Trim the remaining zeros
        GetOpenFileName$ = Left$(lpstrFile$, InStr(lpstrFile$, Chr$(0)) - 1)
        Flags& = OpenCall.flags
        FilterIndex = OpenCall.nFilterIndex
    End If

End Function

Function GetSaveFileName$ (Title$, InitialDir$, Filter$, FilterIndex, Flags&, hWnd&)
    '  Title$      - The dialog title.
    '  InitialDir$ - If this left blank, it will use the directory where the last opened file is
    '     located. Specify ".\" if you want to always use the current directory.
    '  Filter$     - File filters separated by pipes (|) in the same format as VB6 common dialogs.
    '  FilterIndex - The initial file filter to use. Will be altered by user during the call.
    '  Flags&      - Dialog flags. Will be altered by the user during the call.
    '  hWnd&       - Your program's window handle that should be aquired by the FindWindow function.

    ' Returns: Blank when cancel is clicked otherwise, the file name entered by the user.
    ' FilterIndex and Flags& will be changed depending on the user's selections.

'    Dim SaveCall As FILEDIALOGTYPE ' Needed for dialog call

    Dim fFilter$, R As Integer,  lpstrDefExt$, Result As Long
    'dim lpstrFile$  ' Allowed to let main program modify
    fFilter$ = Filter$
    For R = 1 To Len(fFilter$) ' Replace the pipes with zeros
        If Mid$(fFilter$, R, 1) = "|" Then Mid$(fFilter$, R, 1) = Chr$(0)
    Next R
    fFilter$ = fFilter$ + Chr$(0)

    lpstrFile$ = String$(2048, 0) ' For the returned file name
    lpstrDefExt$ = String$(10, 0) ' Extension will not be added when this is not specified
    SaveCall.lStructSize = Len(SaveCall)
    SaveCall.hwndOwner = hWnd&
    SaveCall.lpstrFilter = _Offset(fFilter$)
    SaveCall.nFilterIndex = FilterIndex
    SaveCall.lpstrFile = _Offset(lpstrFile$)
    SaveCall.nMaxFile = Len(lpstrFile$) - 1
    SaveCall.lpstrFileTitle = SaveCall.lpstrFile
    SaveCall.nMaxFileTitle = SaveCall.nMaxFile
    SaveCall.lpstrInitialDir = _Offset(InitialDir$)
    SaveCall.lpstrTitle = _Offset(Title$)
    SaveCall.lpstrDefExt = _Offset(lpstrDefExt$)
    SaveCall.flags = Flags&

    Result = GetSaveFileNameA&(SaveCall) ' Do dialog call!

    If Result Then ' Trim the remaining zeros
        GetSaveFileName$ = Left$(lpstrFile$, InStr(lpstrFile$, Chr$(0)) - 1)
        Flags& = SaveCall.flags
        FilterIndex = SaveCall.nFilterIndex
    End If
End Function


