'----------------------------------------------------------------------------
'
'  CosmoX CALLS Module
'
'  Part of the CosmoX Library v2.0
'  by bobby - CosmoSoft 2000-2001
'
'----------------------------------------------------------------------------
DECLARE FUNCTION xCSChdir% (BYVAL Segment%, BYVAL Offset%)
DECLARE FUNCTION xCSDrive%
DECLARE FUNCTION xCSGetEMSVer%
DECLARE FUNCTION xCSGetXMSVer%
DECLARE FUNCTION xCSLen% (BYVAL Segment%, BYVAL Offset%)
DECLARE FUNCTION xCSLoadBMP% (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL PalSeg%, BYVAL PalOff%, BYVAL FileSeg%, BYVAL FileOff%)
DECLARE FUNCTION xCSLoadBMap% (BYVAL Segment%, BYVAL Offset%)
DECLARE FUNCTION xCSLoadFont% (BYVAL Bs%, BYVAL BO%, BYVAL S%, BYVAL O%)
DECLARE FUNCTION xCSLoadPCX% (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL PalSeg%, BYVAL PalOff%, BYVAL FileSeg%, BYVAL FileOff%)
DECLARE FUNCTION xCSLoadPal% (BYVAL Segment%, BYVAL Offset%, BYVAL FS%, BYVAL FO%)
DECLARE FUNCTION xCSLoadRawSound% (BYVAL FSeg%, BYVAL FOff%, BYVAL BufferSeg%, BYVAL BufferOff&)
DECLARE FUNCTION xCSLoadWavSound% (BYVAL FSeg%, BYVAL FOff%, BYVAL BufferSeg%, BYVAL BufferOff&)
DECLARE FUNCTION xCSSaveBMP% (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL PalSeg%, BYVAL PalOff%, BYVAL FileSeg%, BYVAL FileOff%)
DECLARE FUNCTION xCSSaveBMap% (BYVAL Segment%, BYVAL Offset%)
DECLARE FUNCTION xCSSavePal% (BYVAL Segment%, BYVAL Offset%, BYVAL FS%, BYVAL FO%)
DECLARE FUNCTION xCSWinChdir% (BYVAL Segm%, BYVAL Offs%)
DECLARE FUNCTION xCSWinDelFile% (BYVAL Segm%, BYVAL Offs%)
DECLARE FUNCTION xCSWinMakeDir% (BYVAL Segm%, BYVAL Offs%)
DECLARE FUNCTION xCSWinRemoveDir% (BYVAL Segm%, BYVAL Offs%)
DECLARE SUB xCSFadeIn (BYVAL FirstCol%, BYVAL LastCol%, BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSFadeInStep (BYVAL FirstCol%, BYVAL LastCol%, BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSFindFile (BYVAL Segment%, BYVAL Offset%, BYVAL attr%, BYVAL FS%, BYVAL FO%)
DECLARE SUB xCSGetCard (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSGetFont (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSGetPal (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSPath (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSPrint (BYVAL Layer%, BYVAL S%, BYVAL O%, BYVAL X%, BYVAL Y%, BYVAL Col%)
DECLARE SUB xCSPrintBlended (BYVAL Layer%, BYVAL S%, BYVAL O%, BYVAL X%, BYVAL Y%, BYVAL Col%)
DECLARE SUB xCSPrintReversed (BYVAL Layer%, BYVAL S%, BYVAL O%, BYVAL X%, BYVAL Y%, BYVAL Col%)
DECLARE SUB xCSPrintSolid (BYVAL Layer%, BYVAL S%, BYVAL O%, BYVAL X%, BYVAL Y%, BYVAL FCol%, BYVAL BCol%)
DECLARE SUB xCSPrintTextured (BYVAL Layer%, BYVAL S%, BYVAL O%, BYVAL X%, BYVAL Y%)
DECLARE SUB xCSSetDrive (BYVAL DriveNumber%)
DECLARE SUB xCSSetFont (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSSetMouseCursor (BYVAL HotX%, BYVAL HotY%, BYVAL CursorS%, BYVAL CursorO%)
DECLARE SUB xCSSetPal (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB xCSWinAppGetTitle (BYVAL Segm%, BYVAL Offs%)
DECLARE SUB xCSWinAppSetTitle (BYVAL Segm%, BYVAL Offs%)
DECLARE SUB xCSWinFindFile (BYVAL SS%, BYVAL SO%, BYVAL FS%, BYVAL FO%, BYVAL attr%)
DECLARE SUB xCSWinFindNext (BYVAL SS%, BYVAL SO%)
DECLARE SUB xCSWinPath (BYVAL Segm%, BYVAL Offs%)
DECLARE SUB xCSWinVMGetTitle (BYVAL Segm%, BYVAL Offs%)
DECLARE SUB xCSWinVMSetTitle (BYVAL Segm%, BYVAL Offs%)

REM $INCLUDE: 'COSMOX.BI'

FUNCTION CSChdir% (NewDir$)
  NewDir$ = NewDir$ + CHR$(0)
  CSChdir% = xCSChdir(VARSEG(NewDir$), SADD(NewDir$))
END FUNCTION

FUNCTION CSDrive$
  CSDrive = CHR$(xCSDrive)
END FUNCTION

FUNCTION CSEMSVersion$
  CSEMSVersion = HEX$((xCSGetEMSVer \ 16)) + "." + HEX$((xCSGetEMSVer AND &HF))
END FUNCTION

SUB CSFadeIn (FirstCol%, LastCol%, Pal$)
 xCSFadeIn FirstCol%, LastCol%, VARSEG(Pal$), SADD(Pal$)
END SUB

SUB CSFadeInStep (FirstCol%, LastCol%, Pal$)
  xCSFadeInStep FirstCol%, LastCol%, VARSEG(Pal$), SADD(Pal$)
END SUB

FUNCTION CSFindFile$ (Mask$, Attribute%)
  Temp$ = SPACE$(15)
  Mask$ = Mask$ + CHR$(0)
  xCSFindFile VARSEG(Mask$), SADD(Mask$), Attribute%, VARSEG(Temp$), SADD(Temp$)
  Temp$ = LTRIM$(RTRIM$(Temp$))
  IF Temp$ = CHR$(0) THEN Temp$ = ""
  CSFindFile$ = Temp$
END FUNCTION

FUNCTION CSGetCard$
  TempCard$ = SPACE$(256)
  xCSGetCard VARSEG(TempCard$), SADD(TempCard$)
  CSGetCard = RTRIM$(LTRIM$(TempCard$))
END FUNCTION

SUB CSGetFont (DestFont AS STRING)
  xCSGetFont VARSEG(DestFont), SADD(DestFont)
END SUB

SUB CSGetPal (Pal$)
  xCSGetPal VARSEG(Pal$), SADD(Pal$)
END SUB

SUB CSGradientPal (Col1%, Col2%)
  IF Col2% < Col1% THEN
    Temp% = Col1%
    Col1% = Col2%
    Col2% = Temp%
  END IF

  CSGetCol Col1%, R1%, G1%, B1%
  CSGetCol Col2%, R2%, G2%, B2%
  NumOfCols% = Col2% - Col1%
  GradR! = (R2% - R1%) / NumOfCols%
  GradG! = (G2% - G1%) / NumOfCols%
  GradB! = (B2% - B1%) / NumOfCols%
  R! = R1%: G! = G1%: B! = B1%
  FOR I% = Col1% TO Col2%
    CSSetCol I%, R!, G!, B!
    R! = R! + GradR!
    G! = G! + GradG!
    B! = B! + GradB!
  NEXT
END SUB

FUNCTION CSLen% (Text$)
  Text$ = Text$ + CHR$(0)
  CSLen = xCSLen(VARSEG(Text$), SADD(Text$))
END FUNCTION

FUNCTION CSLoadBMap% (FileName$)
  FileName$ = FileName$ + CHR$(0)
  CSLoadBMap = xCSLoadBMap(VARSEG(FileName$), SADD(FileName$))
END FUNCTION

FUNCTION CSLoadBMP% (Layer%, X%, Y%, File$, Pal$)
   File$ = File$ + CHR$(0)
   CSLoadBMP = xCSLoadBMP(Layer%, X%, Y%, VARSEG(Pal$), SADD(Pal$), VARSEG(File$), SADD(File$))
END FUNCTION

FUNCTION CSLoadFont% (FileName$, FontBuffer$)
  FileName$ = FileName$ + CHR$(0)
  CSLoadFont = xCSLoadFont(VARSEG(FontBuffer$), SADD(FontBuffer$), VARSEG(FileName$), SADD(FileName$))
END FUNCTION

FUNCTION CSLoadPal% (FileName$, Pal$)
  FileName$ = FileName$ + CHR$(0)
  CSLoadPal = xCSLoadPal(VARSEG(Pal$), SADD(Pal$), VARSEG(FileName$), SADD(FileName$))
END FUNCTION

FUNCTION CSLoadPCX% (Layer%, X%, Y%, File$, Pal$)
   File$ = File$ + CHR$(0)
   CSLoadPCX = xCSLoadPCX(Layer%, X%, Y%, VARSEG(Pal$), SADD(Pal$), VARSEG(File$), SADD(File$))
END FUNCTION

FUNCTION CSLoadRawSound& (SoundFile$, BufferSeg%, BufferOff&)
  SoundFile$ = SoundFile$ + CHR$(0)
  CSLoadRawSound = xCSLoadRawSound(VARSEG(SoundFile$), SADD(SoundFile$), BufferSeg%, BufferOff&)
END FUNCTION

FUNCTION CSLoadWavSound& (SoundFile$, BufferSeg%, BufferOff&)
  SoundFile$ = SoundFile$ + CHR$(0)
  CSLoadWavSound = xCSLoadWavSound(VARSEG(SoundFile$), SADD(SoundFile$), BufferSeg%, BufferOff&)
END FUNCTION

SUB CSMakePhongPal (Ra!, Rd!, Rs!, Ga!, Gd!, Gs!, Ba!, Bd!, Bs!, N%, Col1%, Col2%)
  Range% = Col2% - Col1%
  Angle! = 3.14159265# / 2!
  AngleStep! = (3.14159265# / 2!) / Range%

  FOR I% = Col1% TO Col2%
    CosineOfAngle! = COS(Angle!)
    Diffuse! = Rd! * CosineOfAngle!
    Specular! = Rs! * (CosineOfAngle! ^ N%)
    Red% = Ra! + Diffuse! + Specular!
    Diffuse! = Gd! * CosineOfAngle!
    Specular! = Gs! * (CosineOfAngle! ^ N%)
    Green% = Ga! + Diffuse! + Specular!
    Diffuse! = Bd! * CosineOfAngle!
    Specular! = Bs! * (CosineOfAngle! ^ N%)
    Blue% = Ba! + Diffuse! + Specular!
    IF Red% > 63 THEN Red% = 63
    IF Green% > 63 THEN Green% = 63
    IF Blue% > 63 THEN Blue% = 63
    CSSetCol I%, Red%, Green%, Blue%
    Angle! = Angle! - AngleStep!
  NEXT
END SUB

FUNCTION CSPath$
  Temp$ = SPACE$(67)
  xCSPath VARSEG(Temp$), SADD(Temp$)
  CSPath = RTRIM$(LTRIM$(Temp$))
END FUNCTION

SUB CSPrint (Layer%, X%, Y%, Text$, Col%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrint Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, Col%
END SUB

SUB CSPrintBlended (Layer%, X%, Y%, Text$, Col%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrintBlended Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, Col%
END SUB

SUB CSPrintBold (Layer%, X%, Y%, Text$, Col%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrint Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, Col%
  xCSPrint Layer%, VARSEG(Text$), SADD(Text$), X% + 1, Y%, Col%
END SUB

SUB CSPrintReversed (Layer%, X%, Y%, Text$, Col%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrintReversed Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, Col%
END SUB

SUB CSPrintShadow (Layer%, X%, Y%, Text$, Col%, Shadow%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrint Layer%, VARSEG(Text$), SADD(Text$), X% + 2, Y% + 2, Shadow%
  xCSPrint Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, Col%
END SUB

SUB CSPrintSolid (Layer%, X%, Y%, Text$, FCol%, BCol%)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrintSolid Layer%, VARSEG(Text$), SADD(Text$), X%, Y%, FCol%, BCol%
END SUB

SUB CSPrintTextured (Layer%, X%, Y%, Text$)
  Text$ = Text$ + CHR$(0)
  IF X% = -1 THEN X% = 160 - (((LEN(Text$) * 8) + (LEN(Text$) * (CSGetTextSpacing - 8))) / 2)
  xCSPrintTextured Layer%, VARSEG(Text$), SADD(Text$), X%, Y%
END SUB

FUNCTION CSSaveBMap% (FileName$)
  FileName$ = FileName$ + CHR$(0)
  CSSaveBMap = xCSSaveBMap(VARSEG(FileName$), SADD(FileName$))
END FUNCTION

FUNCTION CSSaveBMP% (Layer%, X1%, Y1%, X2%, Y2%, File$, Pal$)
  File$ = File$ + CHR$(0)
  CSSaveBMP = xCSSaveBMP%(Layer%, X1%, Y1%, X2%, Y2%, VARSEG(Pal$), SADD(Pal$), VARSEG(File$), SADD(File$))
END FUNCTION

FUNCTION CSSavePal% (FileName$, Pal$)
  FileName$ = FileName$ + CHR$(0)
  CSSavePal = xCSSavePal(VARSEG(Pal$), SADD(Pal$), VARSEG(FileName$), SADD(FileName$))
END FUNCTION

SUB CSSetDrive (Drive$)
  DriveNumber% = ASC(UCASE$(Drive$)) - 65
  xCSSetDrive DriveNumber%
END SUB

SUB CSSetFont (NewFont AS STRING)
  xCSSetFont VARSEG(NewFont), SADD(NewFont)
END SUB

SUB CSSetMouseCursor (HotX%, HotY%, Cursor$)
  xCSSetMouseCursor HotX%, HotY%, VARSEG(Cursor$), SADD(Cursor$)
END SUB

SUB CSSetPal (Pal$)
  xCSSetPal VARSEG(Pal$), SADD(Pal$)
END SUB

FUNCTION CSSnapShot (File$)
  DIM TempPalette AS STRING * 768
  CSGetPal TempPalette
  CSSnapShot = CSSaveBMP(VIDEO, 0, 0, 319, 199, File$, TempPalette)
END FUNCTION

FUNCTION CSWinAppGetTitle$
 
  Title$ = SPACE$(256)
  xCSWinAppGetTitle VARSEG(Title$), SADD(Title$)
  CSWinAppGetTitle$ = LTRIM$(RTRIM$(Title$))

END FUNCTION

SUB CSWinAppSetTitle (Title$)

  Title$ = Title$ + CHR$(0)
  xCSWinAppSetTitle VARSEG(Title$), SADD(Title$)

END SUB

FUNCTION CSWinChdir% (Dir$)

  Dir$ = RTRIM$(LTRIM$(Dir$)) + CHR$(0)
  CSWinChdir% = xCSWinChdir%(VARSEG(Dir$), SADD(Dir$))

END FUNCTION

FUNCTION CSWinDelFile% (File$)

  File$ = RTRIM$(LTRIM$(File$)) + CHR$(0)
  CSWinDelFile% = xCSWinDelFile%(VARSEG(File$), SADD(File$))

END FUNCTION

FUNCTION CSWinFindFile$ (File$, Attributes%)
  
  File$ = File$ + CHR$(0)
  Store$ = SPACE$(260)
  xCSWinFindFile VARSEG(Store$), SADD(Store$), VARSEG(File$), SADD(File$), Attributes%
  CSWinFindFile$ = LTRIM$(RTRIM$(Store$))

END FUNCTION

FUNCTION CSWinFindNext$
  
  Store$ = SPACE$(260)
  xCSWinFindNext VARSEG(Store$), SADD(Store$)
  CSWinFindNext$ = LTRIM$(RTRIM$(Store$))

END FUNCTION

FUNCTION CSWinMakeDir% (Dir$)

  Dir$ = RTRIM$(LTRIM$(Dir$)) + CHR$(0)
  CSWinMakeDir% = xCSWinMakeDir%(VARSEG(Dir$), SADD(Dir$))

END FUNCTION

FUNCTION CSWinPath$

  Path$ = SPACE$(600)
  xCSWinPath VARSEG(Path$), SADD(Path$)
  CSWinPath$ = LTRIM$(RTRIM$(Path$))

END FUNCTION

FUNCTION CSWinRemoveDir% (Dir$)

  Dir$ = RTRIM$(LTRIM$(Dir$)) + CHR$(0)
  CSWinRemoveDir% = xCSWinRemoveDir%(VARSEG(Dir$), SADD(Dir$))

END FUNCTION

FUNCTION CSWinVMGetTitle$

  Title$ = SPACE$(256)
  xCSWinVMGetTitle VARSEG(Title$), SADD(Title$)
  CSWinVMGetTitle$ = LTRIM$(RTRIM$(Title$))

END FUNCTION

SUB CSWinVMSetTitle (Title$)

  Title$ = Title$ + CHR$(0)
  xCSWinVMSetTitle VARSEG(Title$), SADD(Title$)

END SUB

FUNCTION CSXMSVersion$
  CSXMSVersion = HEX$((xCSGetXMSVer \ 256)) + "." + HEX$((xCSGetXMSVer AND &HFF))
END FUNCTION

