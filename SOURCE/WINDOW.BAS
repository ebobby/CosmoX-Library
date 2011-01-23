'----------------------------------------------------------------------------
'
'  CosmoX WINDOW Module
'
'  Part of the CosmoX Library v2.0
'  by bobby - CosmoSoft 2000-2001
'
'----------------------------------------------------------------------------
  REM $INCLUDE: 'COSMOX.BI'

SUB CSButton (Layer%, X1%, Y1%, X2%, Y2%, ButCol%, TextCol%, Shadow%, Light%, Text$)

  CSWin Layer%, X1%, Y1%, X2%, Y2%, ButCol%, Shadow%, Light%
  TX% = (((X2% - X1%) - (LEN(Text$) * CSGetTextSpacing)) \ 2) + X1%
  Incy% = ((Y2% - Y1%) - 8) \ 2
  CSPrint Layer%, TX%, Y1% + Incy%, Text$, TextCol%

END SUB

SUB CSPushButton (Layer%, X1%, Y1%, X2%, Y2%, ButCol%, TextCol%, Shadow%, Light%, Text$)

  CSButton Layer%, X1%, Y1%, X2%, Y2%, ButCol%, TextCol%, Light%, Shadow%, Text$

END SUB

SUB CSWindow (Layer%, X1%, Y1%, X2%, Y2%, WinCol%, HeadCol%, TextCol%, Shadow%, Light%, Text$)

  CSWin Layer%, X1%, Y1%, X2%, Y2%, WinCol%, Shadow%, Light%
  CSBoxF Layer%, X1% + 5, Y1% + 3, X2% - 5, Y1% + 15, HeadCol%
  TX% = (((X2% - X1%) - (LEN(Text$) * CSGetTextSpacing)) \ 2) + X1%
  CSPrint Layer%, TX%, Y1% + 6, Text$, TextCol%

END SUB

