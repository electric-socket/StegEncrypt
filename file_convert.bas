' SVG Builder
Option _Explicit
$Let SHOW = -1
'$Include:'L:\Programming\Basic\qb64pe_win-x64_User Programs\Common_Dialog_Prefix.bi'


Const Quote = Chr$(34)

Dim As Integer I, Index, NxX, NxY, BoxX, BoxY, Row, Col, Fail, Temp, Check
Dim As Integer SmallTextX, SmallTextY, ChangeColor, RedValue, GreenValue, BlueValue
Dim As _Unsigned Long StartHex, EndHex
Dim As String Table(1000), ColorNames(3)
Dim HexStart$, HexEnd$, TheFile$, CurrentHex$, Value$

Dim Filter$, Flags&, Hwnd&

Const FNum = 5
Dim FN$, OutFN$
Dim As _Unsigned _Integer64 FSize
Dim As Long Limit



Const BoxYStart = 29 '  Top  up-down
Const BoxXStart = 15 '  Left
Const BoxXAdd = 16 '    Amount to move right each box
Const BoxYAdd = 16 '    Amount to move down each box
Const SmallYAdd = 13 '  D(istance of 000000 below box
Const NxLeft = 5 '      Left (X) position for left Nx marks (0x..Fx)
Const NxTop = 38 '      Top (Y) position for 0x-Fx on left
Const ChangeRed = 1 '   Change xx0000
Const ChangeGreen = 2 ' Change 00xx00
Const ChangeBlue = 3 '  Change 0000xx
Const MaxLength = 79 '  Used by PRINTW
Const FALSE = 0
Const TRUE = Not FALSE

ColorNames(0) = "Unknown"
ColorNames(ChangeBlue) = "Blue"
ColorNames(ChangeGreen) = "Green"
ColorNames(ChangeRed) = "Red"


'  ***

_PaletteColor 3, _RGB32(255, 167, 0) ' Orange



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

Print "File "; FN$; " read, size"; Using "######## bytes."; FSize;



If _CommandCount > 2 Then
    HELP (1)
ElseIf _CommandCount > 0 Then
    Dim Opt$, Test(6) As String * 1, XCount%, IsInteractive%
    Opt$ = Command$(1)
    Value$ = UCase$(LTrim$(RTrim$(Opt$)))

    For I = 1 To 6: Test(I%) = Mid$(Value$, I%, 1): Next
    If (Test(1) = "/" Or Test(1) = "-" And Test(2) = "H") Or Left$(Opt$, 3) = "--H" Then HELP (0)

    ' Just give colors
    GoTo ProcessColor

Else

    ' Interactive Mode
    Interactive:
    IsInteractive% = TRUE
    Color 3

PrintW "This program creates an SVG file containing 256 " + _
"color swatches, with the 256 swatches being every "+ _
"representation of color for one of the three "+ _
"(Red, Green, Blue) colors against static values for " + _
"the other two. You will give the color range as a two-digit " + _
"hexadecimal (0-9,A-F) value for two of the colors in one " + _
"of three ways:"
    Print
    Print "   rrggXX - Specify the red and green values, varying blue"
    Print "   rrXXbb - Specify the red and blue values, varying green"
    Print "   XXggbb - Specify the green and blue values, varying red"
    Print
    Print "The separator XX may be upper or lower case, as may any hexadecimal digits "
    Print "(if you use any). For example, giving ";
    Color 11: Print "90xx65 ";: Color 3
    Print "neans to generate a color "
    Print "table from 900065 to 90FF65, varying the green value from 00 to FF. Giving"
    Color 11: Print "xxf3a9 ";: Color 3
    Print "neans to generate a color table from 00F3A9 to FFF3A9, varying the"
    Print "red value from 00 to FF."
    Print

    Retry:

    XCount% = 0
    RedValue = 0
    GreenValue = 0
    BlueValue = 0
    ChangeColor = 0
    Temp = 0
    Fail = 0

    Print "To repeat instructions type: -1"
    Input "Enter the starting color value in the form indicated above: "; Opt$
    Value$ = UCase$(LTrim$(RTrim$(Opt$)))
    If Value$ = "" Then End
    If Value$ = "-1" Then GoTo Interactive
    For I% = 1 To 6: Test(I%) = Mid$(Value$, I%, 1): Next

    ProcessColor:
    If Len(Value$) <> 6 Then Print "?Entry must be exactly 6 characters": Fail = TRUE: GoTo Failure ' can't validate

    Check = 1
    If Left$(Value$, 2) = "XX" Then
        $If TEST Then
            Print 100
        $End If
        ChangeColor = ChangeRed
    Else
        $If TEST Then
            Print 110
        $End If
        GoSub Analyze
        RedValue = Temp
    End If

    Check = 3
    If Mid$(Value$, 3, 2) = "XX" Then
        $If TEST Then
            Print 120
        $End If
        ChangeColor = ChangeColor * 10 + ChangeGreen
    Else
        $If TEST Then
            Print 130
        $End If
        GoSub Analyze
        GreenValue = Temp
    End If

    Check = 5
    If Right$(Value$, 2) = "XX" Then
        $If TEST Then
            Print 140
        $End If
        ChangeColor = ChangeColor * 10 + ChangeBlue
    Else
        $If TEST Then
            Print 150
        $End If
        GoSub Analyze
        BlueValue = Temp
    End If
    $If TEST Then
        Print "ChangeColor="; ChangeColor
    $End If

    If ChangeColor = 0 Then Print "?At least one color must be varied": Fail = TRUE
    If ChangeColor > ChangeBlue Then Print "?At most one color must be varied": Fail = TRUE

    StartHex = RedValue * 256 * 256 + GreenValue * 256 + BlueValue

    Select Case ChangeColor
        'Case ChangeRed: EndHex = StartHex Or &HFF0000
        'Case ChangeGreen: EndHex = StartHex Or &H00FF00
        'Case ChangeBlue: EndHex = StartHex Or 255
        Case ChangeRed: EndHex = 255 * 256 * 256 + GreenValue * 256 + BlueValue
        Case ChangeGreen: EndHex = RedValue * 256 * 256 + 255 * 256 + BlueValue
        Case ChangeBlue: EndHex = RedValue * 256 * 256 + GreenValue * 256 + 255

    End Select


    If Not Fail Then
        ' IF Red=0 or red and green=0, hex$ won't show one or both, so prefix with zeroes
        Print "Creating color values #"; Right$("00000" + Hex$(StartHex), 6); " thru #"; Right$("00000" + Hex$(EndHex), 6);
        Print "  RGB ("; RedValue; ","; GreenValue; ","; BlueValue; ")  Varying "; ColorNames(ChangeColor)
    End If

    Failure:
    If IsInteractive% And Fail Then Print: GoTo Retry

    ' Fail in batch mode
    If Fail Then System

End If

Index = 1
TheFile$ = "L:\$$temp.svg"
Open TheFile$ For Output As #1

Table(Index) = "<?xml version='1.0' encoding='UTF-8' standalone='no'?>": Index = Index + 1
Table(Index) = "  <svg  width='287mm'  height='297mm'  viewBox='0 1 284 290'  version='1.1'   id='svg1'": Index = Index + 1
Table(Index) = "        xmlns='http://www.w3.org/2000/svg'  xmlns:svg='http://www.w3.org/2000/svg'>": Index = Index + 1
Table(Index) = "     <defs id='defs1' />": Index = Index + 1
Table(Index) = "     <style type='text/css'  id='style1'>": Index = Index + 1
Table(Index) = "         rect {fill-opacity:1; stroke:#010102; stroke-width:0.0270867; }": Index = Index + 1
Table(Index) = "         text {font-family:Arial; -inkscape-font-specification:Arial;  fill:#0000fd; fill-opacity:1;  stroke:#010102;  stroke-width:0.079375; stroke-dasharray:none; }": Index = Index + 1
Table(Index) = "         .numbers {font-size:7.05556px; }": Index = Index + 1
Table(Index) = "         .small {font-size:5.64444px;}": Index = Index + 1
Table(Index) = "         .tiny {font-family: 'Courier New'; font-size: 3.52777778px;  fill:#0000fd;}": Index = Index + 1
Table(Index) = "     </style>": Index = Index + 1
Table(Index) = "     <g  inkscape:label='Layer 1' inkscape:groupmode='layer'  id='layer1'>": Index = Index + 1

' Insert background

Table(Index) = "    <rect style='fill:#ffffff;stroke:#010102;stroke-width:0.10034;fill-opacity:1'  id='background' width='284'  height='294'  x='0' y='0' />": Index = Index + 1

' Write title

Const TitleLeft = 62
Const TitleTop = 12

Table(Index) = "     <text id='title' xml:space='preserve'   x='" + LTrim$(Str$(TitleLeft)) + "' y='" + LTrim$(Str$(TitleTop)) + "'  class='numbers'  style=" + Quote + "font-size:9.87778px;text-align:start;text-anchor:start" + Quote + ">": Index = Index + 1
HexStart$ = Right$("00000" + Hex$(StartHex), 6) ' Always pad to 6 hex digits
HexEnd$ = Right$("00000" + Hex$(EndHex), 6)
Table(Index) = "         <tspan id='tspantitle' x='" + LTrim$(Str$(TitleLeft)) + "'   y='" + LTrim$(Str$(TitleTop)) + "'>Color Swatches - #" + HexStart$ + " - #" + HexEnd$ + "</tspan></text>": Index = Index + 1

' and top index

Table(Index) = "   <text id='topline'  xml:space='preserve'  x='17.364206'   y='27.008589'   class='numbers'>": Index = Index + 1
Table(Index) = "        <tspan id='tspantop'  x='17.364206' y='27.008589'>x0    x1    x2    x3     x4     x5    x6    x7     x8    x9    xA    xB    xC    xD    xE    xF </tspan></text>": Index = Index + 1

' Write the left side Nx

NxX = NxLeft
NxY = NxTop
For I = 0 To 15

    Table(Index) = "   <text id='side" + Hex$(I) + "x' xml:space='preserve'  class='numbers' x='" + LTrim$(Str$(NxX)) + "' y='" + LTrim$(Str$(NxY)) + "' >": Index = Index + 1
    Table(Index) = "         <tspan  id='tspanS" + Hex$(I) + "' x='" + LTrim$(Str$(NxX)) + "' y='" + LTrim$(Str$(NxY)) + "'>" + Hex$(I) + "x</tspan></text>": Index = Index + 1

    NxY = NxY + BoxYAdd

Next

' Generate boxes

BoxX = BoxXStart
BoxY = BoxYStart
SmallTextX = BoxXStart
SmallTextY = BoxYStart + SmallYAdd
Row = 0
Col = 0
CurrentHex$ = Right$("00000" + Hex$(StartHex), 6)
For Row = 0 To 15
    For Col = 0 To 15


        Table(Index) = "     <rect id='Square" + LTrim$(Str$(Col)) + LTrim$(Str$(Row)) + "' style='fill: #" + CurrentHex$ + ";' width='13' height='10'  x='" + LTrim$(Str$(BoxX)) + "' y='" + LTrim$(Str$(BoxY)) + "' />": Index = Index + 1
        Table(Index) = "     <text id='tinynum" + LTrim$(Str$(Col)) + LTrim$(Str$(Row)) + "'  xml:space='preserve'   class='tiny'  x='" + LTrim$(Str$(SmallTextX)) + "'  y='" + LTrim$(Str$(SmallTextY)) + "'>": Index = Index + 1
        Table(Index) = "           <tspan id='tspan" + LTrim$(Str$(Col)) + LTrim$(Str$(Row)) + "'   x='" + LTrim$(Str$(SmallTextX)) + "'   y='" + LTrim$(Str$(SmallTextY)) + "'>" + CurrentHex$ + "</tspan></text>": Index = Index + 1

        BoxX = BoxX + BoxXAdd
        SmallTextX = SmallTextX + BoxXAdd

        Select Case ChangeColor
            Case ChangeRed: StartHex = StartHex + &H010000
            Case ChangeGreen: StartHex = StartHex + &H000100
            Case ChangeBlue: StartHex = StartHex + 1
        End Select

        CurrentHex$ = Right$("00000" + Hex$(StartHex), 6)

    Next Col
    BoxX = BoxXStart
    BoxY = BoxY + BoxYAdd
    SmallTextX = BoxXStart
    SmallTextY = BoxY + SmallYAdd

Next Row

'Dim As Double ColorLineY, ColorLRed, ColorLBlue, ColorLGreen, ColorVRed, ColorVBlue, ColorVGreen

Const ColorLineY = 19 ' starting height for all

Const ColorLRed = 87
Const ColorLGreen = ColorLRed + 40
Const ColorLBlue = ColorLGreen + 43

Const ColorVRed = ColorLRed + 14
Const ColorVGreen = ColorLGreen + 17
Const ColorVBlue = ColorLBlue + 12.5

' Color label
Table(Index) = "    <text id='Redlabel' xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorLRed)) + "'  y='" + LTrim$(Str$(ColorLineY)) + "' >": Index = Index + 1
Table(Index) = "        <tspan id='tspanRedlabel' class='small' x='" + LTrim$(Str$(ColorLRed)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'>(Red</tspan></text>": Index = Index + 1

Table(Index) = "    <text id='GreenLabel' xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorLGreen)) + "' y='" + LTrim$(Str$(ColorLineY)) + "' >": Index = Index + 1
Table(Index) = "        <tspan id='tspanGreenLabel' class='small' x='" + LTrim$(Str$(ColorLGreen)) + "'  y='" + LTrim$(Str$(ColorLineY)) + "'>Green</tspan></text>": Index = Index + 1

Table(Index) = "    <text id='BlueLabel' xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorLBlue)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'  >": Index = Index + 1
Table(Index) = "        <tspan id='tspanBlueLabel' class='small'  x='" + LTrim$(Str$(ColorLBlue)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'>Blue               )</tspan></text>": Index = Index + 1

Dim ColorValue As String

' Variable color values


If ChangeColor = ChangeRed Then
    ColorValue = "Varying"
Else
    ColorValue = Right$("00" + LTrim$(Str$(RedValue)), 3) + "/#" + Right$("0" + Hex$(RedValue), 2) ' 000/xx
End If

Table(Index) = "    <text xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorVRed)) + "' y='" + LTrim$(Str$(ColorLineY)) + "' id='Redvalue'>": Index = Index + 1
Table(Index) = "        <tspan id='tspanRedvalue' x='" + LTrim$(Str$(ColorVRed)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'>" + ColorValue + "</tspan></text>": Index = Index + 1


If ChangeColor = ChangeGreen Then
    ColorValue = "Varying"
Else
    ColorValue = Right$("00" + LTrim$(Str$(GreenValue)), 3) + "/#" + Right$("0" + Hex$(GreenValue), 2) ' 000/xx
End If

Table(Index) = "     <text id='GreenValue' xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorVGreen)) + "' y='" + LTrim$(Str$(ColorLineY)) + "' >": Index = Index + 1
Table(Index) = "         <tspan id='tspanGreenValue' x='" + LTrim$(Str$(ColorVGreen)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'>" + ColorValue + "</tspan></text>": Index = Index + 1


If ChangeColor = ChangeBlue Then
    ColorValue = "Varying"
Else
    ColorValue = Right$("00" + LTrim$(Str$(BlueValue)), 3) + "/#" + Right$("0" + Hex$(BlueValue), 2) ' 000/xx
End If

Table(Index) = "     <text id='BlueValue' xml:space='preserve' class='small' x='" + LTrim$(Str$(ColorVBlue)) + "' y='" + LTrim$(Str$(ColorLineY)) + "' >": Index = Index + 1
Table(Index) = "         <tspan id='tspanBlueValue' x='" + LTrim$(Str$(ColorVBlue)) + "' y='" + LTrim$(Str$(ColorLineY)) + "'>" + ColorValue + "</tspan></text>": Index = Index + 1


Table(Index) = "": Index = Index + 1
Table(Index) = "": Index = Index + 1

'Table(Index) = "": Index = Index + 1
'Table(Index) = "": Index = Index + 1

Table(Index) = "</g>": Index = Index + 1

Table(Index) = "</svg>": Index = Index + 1


For I = 1 To Index
    Print #1, Table(I)

Next

Close #1

$If SHOW Then
    Shell _DontWait "start " + Quote + "C:\Program Files\Inkscape\bin\inkscape.exe" + Quote + " " + Quote + TheFile$ + Quote
$End If

Done:
If Not IsInteractive% Then System
End


Analyze:
''Print "(/** Check="; Check; " Test(Check) = "; Test(Check); " Test(Check+1) = "; Test(Check + 1)
If (Test(Check) >= "0" And Test(Check) <= "9") Or (Test(Check) >= "A" And Test(Check) <= "F") Then
    '   Temp = InStr(Test(Check), "0123456789ABCEF") - 1
    Temp = InStr("0123456789ABCDEF", Test(Check)) - 1
    $If TEST Then
        Print "x** temp="; Temp;
    $End If
Else
    Print "?Character"; Check; " not valid in argument: "; Opt$
    Fail = TRUE
End If


If (Test(Check + 1) >= "0" And Test(Check + 1) <= "9") Or (Test(Check + 1) >= "A" And Test(Check + 1) <= "F") Then
    '    I% = InStr(Test(Check + 1), "0123456789ABCEF") - 1
    I% = InStr("0123456789ABCDEF", Test(Check + 1)) - 1
    Temp = Temp * 16 + I%
    $If TEST Then
        Print "z** temp="; Temp; "  i="; I%
    $End If
Else
    Print "?Character"; Check + 1; " not valid in argument: "; Opt$
    Fail = TRUE
End If

Return


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



Sub HELP (quick%)
    If quick% Then
        Color
        Print "?Can't understaned, try -help or --help"
    Else
        Print "SVGBuilder - Create an SVG file of the 256 different colors"
        Print "             depending on which color to rotate."
        Print
    End If

    Print "Usage:"
    Print
    Print " SVGBUILDER change [filenme]"
    Print "     (or)"
    Print " SVGBUILDER h, help, /h, -h, or --h"
    Print "            (case is ignored)"
    If Not quick% Then
        Print
        Print "where"
        Print " change indicates the RGB value to start with, and which"
        Print "      color to rotate, in one of three forms,"
        Print " xxNNNN , NNxxNN , (or) NNNNxx , and"
        Print " NN is"
        Print "      a 2-digit hexadecimal value 00 to FF, and"
        Print " xx is"
        Print "       a separator, any of these 4: -, ., x, (or) X"
        Print "       the separator indicates which color to rotate."
    End If

    End
End Sub


'Takes a long string and breaks it into page-sized pieces.
' Const maxlength = 79
Sub PrintW (Msg$)
    Dim Temp$, Split$, breakspace%, breakdash%
    Temp$ = Msg$
    While Len(Temp$) > MaxLength
        $If PRINTWTEST Then
            Print Len(Temp$)
        $End If
        Split$ = Left$(Temp$, MaxLength)
        breakspace% = _InStrRev(Split$, " ")
        breakdash% = _InStrRev(Split$, "-")
        $If PRINTWTEST Then
            Print Split$
            Print breakspace%; breakdash%
            Input X$
        $End If
        If breakspace% > breakdash% Then
            Split$ = Left$(Split$, breakspace%)
            Temp$ = Mid$(Temp$, breakspace% + 1, Len(Temp$))
        Else
            Split$ = Left$(Split$, breakdash%)
            Temp$ = Mid$(Temp$, breakdash% + 1, Len(Temp$))
        End If
        $If PRINTWTEST Then
            Print "*"; Len(Temp$)
        $End If
        Print Split$
    Wend
    Print Temp$
End Sub


