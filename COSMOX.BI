'----------------------------------------------------------------------------
'
'   CosmoX Library v2.0 INCLUDE File (COSMOX.BI)
'
'   Constants, types definitions, routines and functions prototypes.
'
'                                         by bobby (c) CosmoSoft 2000-2001
'----------------------------------------------------------------------------

'BIT Module         10 routines
DECLARE FUNCTION CSBin$ (BYVAL Value%)
DECLARE FUNCTION CSBinToDec% (Number$)
DECLARE FUNCTION CSClearBit% (BYVAL Value%, BYVAL BIT%)
DECLARE FUNCTION CSReadBit% (BYVAL Value%, BYVAL BIT%)
DECLARE FUNCTION CSRotateL% (BYVAL Value%, BYVAL Times%)
DECLARE FUNCTION CSRotateR% (BYVAL Value%, BYVAL Times%)
DECLARE FUNCTION CSSetBit% (BYVAL Value%, BYVAL BIT%)
DECLARE FUNCTION CSShiftL% (BYVAL Value%, BYVAL Times%)
DECLARE FUNCTION CSShiftR% (BYVAL Value%, BYVAL Times%)
DECLARE FUNCTION CSToggleBit% (BYVAL Value%, BYVAL BIT%)

'BLENDING Module     6 routines
DECLARE FUNCTION CSCreateBMap% ()
DECLARE FUNCTION CSGetBMap% (BYVAL ForeColor%, BYVAL BackColor%)
DECLARE FUNCTION CSLoadBMap% (FileName$)
DECLARE FUNCTION CSSaveBMap% (FileName$)
DECLARE SUB CSDestroyBMap ()
DECLARE SUB CSSetBMap (BYVAL ForeColor%, BYVAL BackColor%, BYVAL NewColor%)

'D3D Module          8 routines
DECLARE SUB CSTextureWidth (BYVAL NewWidth%)
DECLARE SUB CSTriF (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL Col%)
DECLARE SUB CSTriFB (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL Col%)
DECLARE SUB CSTriG (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL Col1%, BYVAL X2%, BYVAL Y2%, BYVAL Col2%, BYVAL X3%, BYVAL Y3%, BYVAL Col3%)
DECLARE SUB CSTriGB (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL Col1%, BYVAL X2%, BYVAL Y2%, BYVAL Col2%, BYVAL X3%, BYVAL Y3%, BYVAL Col3%)
DECLARE SUB CSTriT (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL U1%, BYVAL V1%, BYVAL U2%, BYVAL V2%, BYVAL U3%, BYVAL V3%, BYVAL TSeg%, BYVAL TOff%)
DECLARE SUB CSTriTB (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL U1%, BYVAL V1%, BYVAL U2%, BYVAL V2%, BYVAL U3%, BYVAL V3%, BYVAL TSeg%, BYVAL TOff%)
DECLARE SUB CSTriTF (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL U1%, BYVAL V1%, BYVAL U2%, BYVAL V2%, BYVAL U3%, BYVAL V3%, BYVAL TSeg%, BYVAL TOff%)

'DISK Module         8 routines
DECLARE FUNCTION CSChdir% (NewDir$)
DECLARE FUNCTION CSDrive$ ()
DECLARE FUNCTION CSFindFile$ (Mask$, Attribute%)
DECLARE FUNCTION CSFreeDiskSpc& (BYVAL DriveNumber%)
DECLARE FUNCTION CSPath$ ()
DECLARE FUNCTION CSTotalDiskSpc& (BYVAL DriveNumber%)
DECLARE FUNCTION CSTotalDrives% ()
DECLARE SUB CSSetDrive (Drive$)

'DRAW Module        22 routines
DECLARE FUNCTION CSPoint% (BYVAL Layer%, BYVAL X%, BYVAL Y%)
DECLARE SUB CSAntiAliase (BYVAL Layer%)
DECLARE SUB CSBox (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Col%)
DECLARE SUB CSBoxF (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Col%)
DECLARE SUB CSBoxFB (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Col%)
DECLARE SUB CSCircle (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Rad%, BYVAL Col%)
DECLARE SUB CSCircleF (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Rad%, BYVAL Col%)
DECLARE SUB CSClear (BYVAL Layer%, BYVAL Col%)
DECLARE SUB CSCopyBlock (BYVAL Source%, BYVAL Destiny%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE SUB CSEllipse (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL RadX%, BYVAL RadY%, BYVAL Col%)
DECLARE SUB CSEllipseF (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL RadX%, BYVAL RadY%, BYVAL Col%)
DECLARE SUB CSLine (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Col%)
DECLARE SUB CSPcopy (BYVAL Source%, BYVAL Destiny%)
DECLARE SUB CSPcopyB (BYVAL Source%, BYVAL Destiny%)
DECLARE SUB CSPcopyC (BYVAL Source%, BYVAL Destiny%, BYVAL Col%)
DECLARE SUB CSPcopyT (BYVAL Source%, BYVAL Destiny%)
DECLARE SUB CSPset (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Col%)
DECLARE SUB CSPsetB (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Col%)
DECLARE SUB CSScroll (BYVAL Layer%, BYVAL Pixels%, BYVAL Direction%)
DECLARE SUB CSScrollArea (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Direction%)
DECLARE SUB CSTri (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL X3%, BYVAL Y3%, BYVAL Col%)
DECLARE SUB CSWin (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL WinCol%, BYVAL Shadow%, BYVAL Light%)

'EMS Module         18 routines
DECLARE FUNCTION CSAllocateEMS% (BYVAL Pages%)
DECLARE FUNCTION CSDetectEMS% ()
DECLARE FUNCTION CSEMSHandles% ()
DECLARE FUNCTION CSEMSVersion$ ()
DECLARE FUNCTION CSFreeEMS& ()
DECLARE FUNCTION CSFreeEMSPages% ()
DECLARE FUNCTION CSGetEMSFrame% ()
DECLARE FUNCTION CSResizeEMS% (BYVAL Handle%, BYVAL Pages%)
DECLARE FUNCTION CSTotalEMS& ()
DECLARE FUNCTION CSTotalEMSPages% ()
DECLARE SUB CSDeallocateEMS (BYVAL Handle%)
DECLARE SUB CSMapEMS (BYVAL Handle%, BYVAL PhyPage%, BYVAL LogPage%)
DECLARE SUB CSMapEMSLayer (BYVAL Handle%, BYVAL LogPage%)
DECLARE SUB CSMoveEMS (BYVAL SHandle%, BYVAL SLogPage%, BYVAL SPageOffset%, BYVAL DHandle%, BYVAL DLogPage%, BYVAL DPageOffset%, BYVAL Length&)
DECLARE SUB CSMoveFromEMS (BYVAL Segment%, BYVAL Offset&, BYVAL Handle%, BYVAL LogPage%, BYVAL PageOffset%, BYVAL Length&)
DECLARE SUB CSMoveToEMS (BYVAL Segment%, BYVAL Offset&, BYVAL Handle%, BYVAL LogPage%, BYVAL PageOffset%, BYVAL Length&)
DECLARE SUB CSScrollHEMS (BYVAL Layer%, BYVAL XOffset%, BYVAL Handle1%, BYVAL LogPage1%, BYVAL Handle2%, BYVAL LogPage2%)
DECLARE SUB CSScrollVEMS (BYVAL Layer%, BYVAL XOffset%, BYVAL Handle1%, BYVAL LogPage1%, BYVAL Handle2%, BYVAL LogPage2%)

'FONT Module        15 routines
DECLARE FUNCTION CSGetTextSpacing% ()
DECLARE FUNCTION CSLen% (Text$)
DECLARE FUNCTION CSLoadFont% (FileName$, FontBuffer$)
DECLARE SUB CSGetFont (Font$)
DECLARE SUB CSPrint (Layer%, X%, Y%, Text$, Col%)
DECLARE SUB CSPrintBlended (Layer%, X%, Y%, Text$, Col%)
DECLARE SUB CSPrintBold (Layer%, X%, Y%, Text$, Col%)
DECLARE SUB CSPrintReversed (Layer%, X%, Y%, Text$, Col%)
DECLARE SUB CSPrintShadow (Layer%, X%, Y%, Text$, Col%, Shadow%)
DECLARE SUB CSPrintSolid (Layer%, X%, Y%, Text$, FCol%, BCol%)
DECLARE SUB CSPrintTextured (Layer%, X%, Y%, Text$)
DECLARE SUB CSResetFont ()
DECLARE SUB CSSetFont (Font$)
DECLARE SUB CSSetTextSpacing (BYVAL TextSpacing%)
DECLARE SUB CSTextTexture (BYVAL Segment%, BYVAL Offset%)

'GFX Module          1 routines
DECLARE SUB CSFire (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL FWidth%, BYVAL MaxColorIndex%, BYVAL MaxScanLine%)

'IMAGE Module        4 routines
DECLARE FUNCTION CSLoadBMP% (Layer%, X%, Y%, File$, Pal$)
DECLARE FUNCTION CSLoadPCX% (Layer%, X%, Y%, File$, Pal$)
DECLARE FUNCTION CSSaveBMP% (Layer%, X1%, Y1%, X2%, Y2%, File$, Pal$)
DECLARE FUNCTION CSSnapShot% (FileName$)

'KEYBOARD Module     8 routines
DECLARE FUNCTION CSAsc% (BYVAL ScanCode%, BYVAL Shift%)
DECLARE FUNCTION CSCheckKeys% ()
DECLARE FUNCTION CSKey% (BYVAL ScanCode%)
DECLARE FUNCTION CSReadKey% ()
DECLARE SUB CSInstallKeyBoard ()
DECLARE SUB CSLockKeys (BYVAL LKey%, BYVAL State%)
DECLARE SUB CSRemoveKeyBoard ()
DECLARE SUB CSWaitKey (BYVAL ScanCode%)

'MAIN Module       16 routines
DECLARE FUNCTION CSCpuId$ ()
DECLARE FUNCTION CSDetectCPU% ()
DECLARE FUNCTION CSGetCard$ ()
DECLARE FUNCTION CSId$ ()
DECLARE FUNCTION CSProcessor$ ()
DECLARE FUNCTION CSTimerTicks& ()
DECLARE FUNCTION CSVer% ()
DECLARE SUB CSClose ()
DECLARE SUB CSDelay (BYVAL Increments%)
DECLARE SUB CSFfix ()
DECLARE SUB CSGetClipBox (X1%, Y1%, X2%, Y2%)
DECLARE SUB CSInitText ()
DECLARE SUB CSInitVGA ()
DECLARE SUB CSRemoveFfix ()
DECLARE SUB CSSetClipBox (BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE SUB CSSort (BYVAL RecordSeg%, BYVAL RecordOff%, BYVAL NumOfRecords%, BYVAL SizeOfRecord%, BYVAL IndexKey%)

'MATRIX Module      16 routines
DECLARE FUNCTION CSPolyFacing% (BYVAL Vec1Seg%, BYVAL Vec1Off&, BYVAL Vec2Seg%, BYVAL Vec2Off&, BYVAL Vec3Seg%, BYVAL Vec3Off&)
DECLARE FUNCTION CSVectorDot! (BYVAL Vec1Seg%, BYVAL Vec1Off&, BYVAL Vec2Seg%, BYVAL Vec2Off&)
DECLARE FUNCTION CSXNormal! (BYVAL Vec1Seg%, BYVAL Vec1Off&, BYVAL Vec2Seg%, BYVAL Vec2Off&, BYVAL Vec3Seg%, BYVAL Vec3Off&)
DECLARE FUNCTION CSYNormal! (BYVAL Vec1Seg%, BYVAL Vec1Off&, BYVAL Vec2Seg%, BYVAL Vec2Off&, BYVAL Vec3Seg%, BYVAL Vec3Off&)
DECLARE FUNCTION CSZNormal! (BYVAL Vec1Seg%, BYVAL Vec1Off&, BYVAL Vec2Seg%, BYVAL Vec2Off&, BYVAL Vec3Seg%, BYVAL Vec3Off&)
DECLARE SUB CSCopyMatrix (BYVAL SMatrixS%, BYVAL SMatrixO&, BYVAL DMatrixS%, BYVAL DMatrixO&)
DECLARE SUB CSIdentityMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&)
DECLARE SUB CSInitRotXMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL Cosine!, BYVAL Sine!)
DECLARE SUB CSInitRotYMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL Cosine!, BYVAL Sine!)
DECLARE SUB CSInitRotZMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL Cosine!, BYVAL Sine!)
DECLARE SUB CSInitScaleMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL ScaleX!, BYVAL ScaleY!, BYVAL ScaleZ!)
DECLARE SUB CSInitTransMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL TransX!, BYVAL TransY!, BYVAL TransZ!)
DECLARE SUB CSMatrixMulMatrix (BYVAL MatrixSeg%, BYVAL MatrixOff&, BYVAL TMatrixSeg%, BYVAL TMatrixOff&)
DECLARE SUB CSProjectVector (BYVAL Vec3DSeg%, BYVAL Vec3DOff&, BYVAL Vec2DSeg%, BYVAL Vec2DOff&, BYVAL ZEye!)
DECLARE SUB CSUnitVector (BYVAL SVecSeg%, BYVAL SVecOff%, BYVAL DVecSeg%, BYVAL DVecOff%)
DECLARE SUB CSVectorMulMatrix (BYVAL SVecSeg%, BYVAL SVecOff&, BYVAL MatSeg%, BYVAL MatOff&, BYVAL DVecSeg%, BYVAL DVecOff&)

'MEMORY Module       8 routines
DECLARE FUNCTION CSPeek% (BYVAL Segment%, BYVAL Offset&)
DECLARE FUNCTION CSPeek16% (BYVAL Segment%, BYVAL Offset&)
DECLARE FUNCTION CSPeek32& (BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSMemCopy (BYVAL SSegment%, BYVAL SOffset&, BYVAL DSegment%, BYVAL DOffset&, BYVAL Bytes&)
DECLARE SUB CSMemSwap (BYVAL Segment1%, BYVAL Offset1&, BYVAL Segment2%, BYVAL Offset2&, BYVAL Bytes&)
DECLARE SUB CSPoke (BYVAL Segment%, BYVAL Offset&, BYVAL Value%)
DECLARE SUB CSPoke16 (BYVAL Segment%, BYVAL Offset&, BYVAL Value%)
DECLARE SUB CSPoke32 (BYVAL Segment%, BYVAL Offset&, BYVAL Value&)

'MMX Module          5 routines
DECLARE FUNCTION CSDetectMMX% ()
DECLARE SUB CSClearMMX (BYVAL Layer%, BYVAL Col%)
DECLARE SUB CSMemCopyMMX (BYVAL SSegment%, BYVAL SOffset&, BYVAL DSegment%, BYVAL DOffset&, BYVAL Bytes&)
DECLARE SUB CSMemSwapMMX (BYVAL SSegment%, BYVAL SOffset&, BYVAL DSegment%, BYVAL DOffset&, BYVAL Bytes&)
DECLARE SUB CSPcopyMMX (BYVAL Source%, BYVAL Destiny%)

'MOUSE Module       14 routines
DECLARE FUNCTION CSDetectMouse% ()
DECLARE FUNCTION CSMouseClickOn% (BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE FUNCTION CSMouseLB% ()
DECLARE FUNCTION CSMouseOver% (BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE FUNCTION CSMouseRB% ()
DECLARE FUNCTION CSMouseX% ()
DECLARE FUNCTION CSMouseY% ()
DECLARE SUB CSMouseOff ()
DECLARE SUB CSMouseOn ()
DECLARE SUB CSResetMouse ()
DECLARE SUB CSSetMouseCursor (HotX%, HotY%, Cursor$)
DECLARE SUB CSSetMouseRange (BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE SUB CSSetMouseSpeed (BYVAL XSpeed%, BYVAL YSpeed%)
DECLARE SUB CSSetMouseXY (BYVAL X%, BYVAL Y%)

'PALETTE Module     19 routines
DECLARE FUNCTION CSFindCol% (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE FUNCTION CSLoadPal% (FileName$, Pal$)
DECLARE FUNCTION CSSavePal% (FileName$, Pal$)
DECLARE SUB CSBlackPal (BYVAL FirstCol%, BYVAL LastCol%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB CSFadeIn (FirstCol%, LastCol%, Pal$)
DECLARE SUB CSFadeInStep (FirstCol%, LastCol%, Pal$)
DECLARE SUB CSFadeTo (BYVAL FirstCol%, BYVAL LastCol%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB CSFadeToStep (BYVAL FirstCol%, BYVAL LastCol%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB CSGetCol (BYVAL Col%, Red%, Green%, Blue%)
DECLARE SUB CSGetPal (Pal$)
DECLARE SUB CSGradientPal (Col1%, Col2%)
DECLARE SUB CSGrayPal (BYVAL FirstCol%, BYVAL LastCol%)
DECLARE SUB CSMakePhongPal (Ra!, Rd!, Rs!, Ga!, Gd!, Gs!, Ba!, Bd!, Bs!, N%, Col1%, Col2%)
DECLARE SUB CSNegativePal (BYVAL FirstCol%, BYVAL LastCol%)
DECLARE SUB CSRotatePalB (BYVAL FirstCol%, BYVAL LastCol%)
DECLARE SUB CSRotatePalF (BYVAL FirstCol%, BYVAL LastCol%)
DECLARE SUB CSSetCol (BYVAL Col%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB CSSetPal (Pal$)
DECLARE SUB CSWaitRetrace ()

'SBLASTER Module     9 routines
DECLARE FUNCTION CSInitBlaster% ()
DECLARE FUNCTION CSLoadRawSound& (SoundFile$, BufferSeg%, BufferOff&)
DECLARE FUNCTION CSLoadWavSound& (SoundFile$, BufferSeg%, BufferOff&)
DECLARE FUNCTION CSSoundDone% ()
DECLARE SUB CSContinueSound ()
DECLARE SUB CSPauseSound ()
DECLARE SUB CSPlaySound (BYVAL SoundSeg%, BYVAL SoundOff&, BYVAL SoundSize&, BYVAL Freq&)
DECLARE SUB CSTurnBlasterOff ()
DECLARE SUB CSTurnBlasterOn ()

'SPRITE Module      17 routines
DECLARE FUNCTION CSCollide% (BYVAL X1%, BYVAL Y1%, BYVAL Segment1%, BYVAL Offset1&, BYVAL X2%, BYVAL Y2%, BYVAL Segment2%, BYVAL Offset2&)
DECLARE FUNCTION CSCollision% (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE FUNCTION CSCollisionC% (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&, BYVAL Col%)
DECLARE FUNCTION CSSize% (BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%)
DECLARE SUB CSGet (BYVAL Layer%, BYVAL X1%, BYVAL Y1%, BYVAL X2%, BYVAL Y2%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSprite (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteB (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteC (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&, BYVAL Col%)
DECLARE SUB CSSpriteF (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteFlipH (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteFlipV (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteFlipped (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteN (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteO (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Segment%, BYVAL Offset&, BYVAL Operation%)
DECLARE SUB CSSpriteR (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL Angle%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteRZ (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL NewWidth%, BYVAL NewHeight%, BYVAL Angle%, BYVAL Segment%, BYVAL Offset&)
DECLARE SUB CSSpriteS (BYVAL Layer%, BYVAL X%, BYVAL Y%, BYVAL NewWidth%, BYVAL NewHeight%, BYVAL Segment%, BYVAL Offset&)

'TIMER Module        7 routines
DECLARE FUNCTION CSElapsedTicks& (BYVAL WhichTimer%)
DECLARE FUNCTION CSTimerFlag% (BYVAL WhichTimer%)
DECLARE SUB CSInstallTimer ()
DECLARE SUB CSRemoveTimer ()
DECLARE SUB CSResetTicks (BYVAL WhichTimer%)
DECLARE SUB CSSetTimer (BYVAL WhichTimer%, BYVAL Millisecs&)
DECLARE SUB CSWaitTimer (BYVAL WhichTimer%)

'WINDOW Module       3 routines
DECLARE SUB CSButton (Layer%, X1%, Y1%, X2%, Y2%, ButCol%, TextCol%, Shadow%, Light%, Text$)
DECLARE SUB CSPushButton (Layer%, X1%, Y1%, X2%, Y2%, ButCol%, TextCol%, Shadow%, Light%, Text$)
DECLARE SUB CSWindow (Layer%, X1%, Y1%, X2%, Y2%, WinCol%, HeadCol%, TextCol%, Shadow%, Light%, Text$)

'WIN    Module      21 routines
DECLARE FUNCTION CSDetectWin% ()
DECLARE FUNCTION CSWinAppGetTitle$ ()
DECLARE FUNCTION CSWinChdir% (Dir$)
DECLARE FUNCTION CSWinDelFile% (File$)
DECLARE FUNCTION CSWinFindFile$ (File$, Attributes%)
DECLARE FUNCTION CSWinFindNext$ ()
DECLARE FUNCTION CSWinGetClipBDataSize& ()
DECLARE FUNCTION CSWinGetClipBDataType% ()
DECLARE FUNCTION CSWinGetVMID% ()
DECLARE FUNCTION CSWinMakeDir% (Dir$)
DECLARE FUNCTION CSWinOpenClipB% ()
DECLARE FUNCTION CSWinPath$ ()
DECLARE FUNCTION CSWinRemoveDir% (Dir$)
DECLARE FUNCTION CSWinVMGetTitle$ ()
DECLARE SUB CSWinAppSetTitle (Title$)
DECLARE SUB CSWinCloseClipB ()
DECLARE SUB CSWinEmptyClipB ()
DECLARE SUB CSWinFindClose ()
DECLARE SUB CSWinGetClipBData (BYVAL Segm%, BYVAL Offs&, BYVAL TypeOfData%)
DECLARE SUB CSWinSetClipBData (BYVAL Segm%, BYVAL Offs&, BYVAL TypeOfData%, BYVAL SyzeOfData&)
DECLARE SUB CSWinVMSetTitle (Title$)

'XMS Module         15 routines
DECLARE FUNCTION CSAllocateXMS% (BYVAL KB&)
DECLARE FUNCTION CSDetectXMS% ()
DECLARE FUNCTION CSFreeXMS& ()
DECLARE FUNCTION CSResizeXMS% (BYVAL Handle%, BYVAL KB&)
DECLARE FUNCTION CSTotalXMS& ()
DECLARE FUNCTION CSXAllocateXMS% (BYVAL KB&)
DECLARE FUNCTION CSXFreeXMS& ()
DECLARE FUNCTION CSXMSHandles% ()
DECLARE FUNCTION CSXMSVersion$ ()
DECLARE FUNCTION CSXResizeXMS% (BYVAL Handle%, BYVAL KB&)
DECLARE FUNCTION CSXTotalXMS& ()
DECLARE SUB CSDeallocateXMS (BYVAL Handle%)
DECLARE SUB CSMoveFromXMS (BYVAL Segment%, BYVAL Offset&, BYVAL Handle%, BYVAL XMSOffset&, BYVAL Length&)
DECLARE SUB CSMoveToXMS (BYVAL Segment%, BYVAL Offset&, BYVAL Handle%, BYVAL XMSOffset&, BYVAL Length&)
DECLARE SUB CSMoveXMS (BYVAL SHandle%, BYVAL SOffset&, BYVAL DHandle%, BYVAL DOffset&, BYVAL Length&)

'Miscellaneus Constants
CONST ATTRIB.VOLLABEL = &H8, ATTRIB.DIR = &H10, ATTRIB.ARCHIVE = &H20
CONST ATTRIB.READONLY = &H1, ATTRIB.HIDDEN = &H2, ATTRIB.SYSTEM = &H4
CONST BIT.XOR = 0, BIT.AND = 1, BIT.OR = 2
CONST KEYESC = 1, KEYENTER = 28, KEYSPACE = 57, KEYTAB = &HF
CONST KEYUP = 72, KEYDOWN = 80, KEYLEFT = 75, KEYRIGHT = 77
CONST NUM = 0, CAPS = 1, SCROLL = 2
CONST UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3
CONST VIDEO = &HA000, ANYKEY = -1, CENTERED = -1
CONST CLIPB.TEXT = &H1, CLIPB.BITMAP = &H2, CLIPB.META = &H3
CONST CLIPB.SYLK = &H4, CLIPB.DIF = &H5, CLIPB.TIFF = &H6
CONST CLIPB.OEMTEXT = &H7, CLIPB.DIBBITMAP = &H8, CLIPB.DSPTEXT = &H81
CONST CLIPB.DSPBITMAP = &H82

'3D graphics TYPES definitions

  TYPE Vector3DType
    X AS SINGLE
    Y AS SINGLE
    Z AS SINGLE
  END TYPE

  TYPE Vector2DType
    X AS INTEGER
    Y AS INTEGER
  END TYPE

  TYPE WinClipBoardBitMap
    BType           AS INTEGER
    XSize           AS INTEGER
    YSize           AS INTEGER
    BytesPerLine    AS INTEGER
    NumColorPlanes  AS STRING * 1
    NumAdjColBitsPx AS STRING * 1
    PtrToData       AS LONG
    XSizeMM         AS INTEGER
    YSizeMM         AS INTEGER
  END TYPE

  TYPE WinClipBoardMetaPic
    MappingMode     AS INTEGER
    XSize           AS INTEGER
    YSize           AS INTEGER
  END TYPE

DEFINT A-Z
