' SVG Builder
Option _Explicit
$Let SHOW = -1

Const Quote = Chr$(34)

Dim As Integer I, Index, X, Y, Row, Col
Dim As Long IDcount, FillColor
Dim As String Table(100000), ID, TheFile

X = 0
Y = 0

'  ***

Index = 1
TheFile$ = "L:\$$temp.svg"
Open TheFile$ For Output As #1

Table(Index) = "<?xml version='1.0' encoding='UTF-8' standalone='no'?>": Index = Index + 1
Table(Index) = "  <svg  width='287mm'  height='297mm'  viewBox='0 1 200 290'  version='1.1'   id='svg1'": Index = Index + 1
Table(Index) = "        xmlns='http://www.w3.org/2000/svg'  xmlns:svg='http://www.w3.org/2000/svg'>": Index = Index + 1
Table(Index) = "     <defs id='defs1' />": Index = Index + 1
Table(Index) = "     <style>   ": Index = Index + 1
Table(Index) = "     rect {fill-opacity: 1;}     ": Index = Index + 1
Table(Index) = "     </style>  ": Index = Index + 1

'Table(Index) = "     <g  inkscape:label='Layer 1' inkscape:groupmode='layer'  id='layer1'>": Index = Index + 1

IDcount = 1
FillColor = &H0000FF


For Y = 0 To 20
    For X = 1 To 50
        ID = Right$("000000" + LTrim$(Str$(IDcount)), 6): IDcount = IDcount + 1

        Table(Index) = "    <rect style='fill: #" + Right$("000000" + LTrim$(Str$(FillColor)), 6) + "; ' id='rect" + ID + "'  width='1' height='1'  x='" + LTrim$(Str$(X)) + "'  y='" + LTrim$(Str$(Y)) + "' />": Index = Index + 1
        FillColor = FillColor + &H0560
    Next X
Next Y
'Table(Index) = "": Index = Index + 1
'Table(Index) = "": Index = Index + 1

'Table(Index) = "</g>": Index = Index + 1

Table(Index) = "</svg>": Index = Index + 1


For I = 1 To Index
    Print #1, Table(I)

Next

Close #1

$If SHOW Then
    Shell _DontWait "start " + Quote + "C:\Program Files\Inkscape\bin\inkscape.exe" + Quote + " " + Quote + TheFile$ + Quote
$End If



End

