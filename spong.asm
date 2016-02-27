;Super Pong v1.1 for TI-89 under Doors OS 
;by Erwan Rouzel aKa nop
;
;e-mail : nop@ifrance.com
;WEB : http://nop.ifrance.com 


	include "doorsos.h"
	include "userlib.h"
	include "graphlib.h"

	xdef _main
	xdef _comment
	xdef _ti89

ErasBat	MACRO
	move.w	\1,d0
	move.w	\2,d1
	bsr	    ErasBatSubRout
	ENDM

DrawBat	MACRO
	move.w	\1,d0
	move.w	\2,d1
	lea	    \3(pc),a0
	bsr	    DrawBatSubRout
	ENDM
	
DrawBal	MACRO
	move.w	\1,d0
	move.w	\2,d1
	bsr	    DrawBalSubRout
	ENDM

ErasBal	MACRO
	move.w	\1,d0
	move.w	\2,d1
	bsr	    ErasBalSubRout
	ENDM
	
WriteStrCenter	MACRO	;y,col,str
	move.w	\1,d1
	move.w	\2,d2
	lea	    \3,a0				 
	bsr	    DrawStrCenterXY
	ENDM
	
PrintD0 MACRO
    bsr     PrintValue
    move.w  \3,-(a7)
    move.l  a0,-(a7)
    move.w  \2,-(a7)
    move.w  \1,-(a7)
    jsr     doorsos::DrawStrXY
    lea 10(a7),a7
    ENDM

	

RAQ_HEIGHT	    equ	14
BAL_SIZE	    equ	6
X1		        equ	1
X2		        equ	152
YMAX		    equ	83
YMIN		    equ	1
XMAX		    equ	144
XMIN		    equ	9
POSX_BAL_INIT	equ	78
POSY_BAL_INIT	equ	45
Y_RAQ_INIT	    equ	35
AI		        equ	0
HUMAN		    equ	1
RND_COEFF	    equ	4
EFFECT_COEFF    equ 14
ITEM_HEIGHT 	equ	10
MAIN_MENU	    equ	0
PLAY_MENU	    equ	1
OPTIONS_MENU	equ	2
FIRST_ITEM      equ 40
AI_BAD          equ 30
AI_GOOD         equ 80
AI_EXPERT       equ 130
AI_STEP         equ 50
AUTO_ACCELERATION_COEFF    equ 5

POINTS_PER_MATCH_MIN    equ 7
POINTS_PER_MATCH_MAX    equ 21
POINTS_PER_MATCH_DEFAULT   equ 11


;-----------------------------------------------------
;Initials values of game timers 
;The ball speed and the bat speed depend on these
;(the ball behaviour depends on the difference between
;the two associate timers, thus allowing some nice ball effects) 

TIMER_BALX_INIT		equ	120
TIMER_BALX_MIN      equ 40
TIMER_BALY_INIT		equ	200
TIMER_BALY_MAX		equ	350
TIMER_BALY_MIN		equ	50
TIMERCNT_BATS  		equ 	35
	

;-----------------------------------------------------
;Some stuffs for keyboard handling


MASK_L0		equ	%11111110
MASK_L1     equ %11111101
MASK_L5		equ	%11011111
MASK_L6		equ	%10111111
UP_BIT		equ	0
ENTER_BIT   equ 0
DOWN_BIT	equ	2
SECOND_BIT	equ	4
HOME_BIT	equ	6
ESC_BIT		equ	0

;-----------------------------------------------------

sel_rg		equr	d1
escFlag     equr    d4
menu_level	equr	d5

_main:


;------------------------------------------------------
;  MENU ROUTINES	
;------------------------------------------------------	


Menu
  	jsr	    graphlib::clr_scr
	move.w  #LCD_HEIGHT,d0
	asr.w   #1,d0
	move.w  d0,lcdHMid
	move.w	#0,d1
	bsr	    PxlHorzBlack
	move.w	#LCD_HEIGHT-1,d1
	bsr	    PxlHorzBlack
	move.w	#LCD_HEIGHT-16,d1
	bsr	    PxlHorzBlack
	move.w	#0,d0
	bsr	    PxlVertBlack
	move.w	#LCD_WIDTH-1,d0
	bsr	    PxlVertBlack
	SetFont	#2
	
	WriteStrCenter	#5,#2,szTitle
	SetFont	#0
	WriteStrCenter	#22,#2,szAuthor
	WriteStr        #2,#2,#0,szVersion
	WriteStr        #2,#LCD_HEIGHT-14,#1,szEmail
	WriteStr        #2,#LCD_HEIGHT-7,#1,szWeb
	
	SetFont	#1
	move.w	#MAIN_MENU,menu_level
	move.w	#FIRST_ITEM,sel
	
RedrawMenu
	cmp.w	#MAIN_MENU,menu_level
	beq	    MainMenu
	cmp.w	#PLAY_MENU,menu_level
	beq	    PlayMenu
	cmp.w	#OPTIONS_MENU,menu_level
	beq	    OptionsMenu
    
MainMenu
	move.w	#40+2*ITEM_HEIGHT,last_item		
	WriteStrCenter	#FIRST_ITEM,#1,szPlay
	WriteStrCenter	#FIRST_ITEM+ITEM_HEIGHT,#1,szOptions
	WriteStrCenter	#FIRST_ITEM+2*ITEM_HEIGHT,#1,szQuit
	bra	    CheckSel
	
PlayMenu
	move.w	#40+3*ITEM_HEIGHT,last_item
	WriteStrCenter	#FIRST_ITEM,#1,szHuVsHu
	WriteStrCenter	#FIRST_ITEM+ITEM_HEIGHT,#1,szHuVsAi
	WriteStrCenter	#FIRST_ITEM+2*ITEM_HEIGHT,#1,szAiVsAi
	WriteStrCenter	#FIRST_ITEM+3*ITEM_HEIGHT,#1,szBack
	bra	    CheckSel
	
OptionsMenu
    move.w  #40+2*ITEM_HEIGHT,last_item
    WriteStr #30,#FIRST_ITEM,#1,szAiSkill
    
    cmp.w   #AI_BAD,aiSkill
    beq     AiBad
    cmp.w   #AI_GOOD,aiSkill
    beq     AiGood
    cmp.w   #AI_EXPERT,aiSkill
    beq     AiExpert

AiBad
    WriteStr	#95,#FIRST_ITEM,#1,szBad
    move.w  #AI_BAD,aiSkill
    bra     EndSetAiSkill
    
AiGood
    WriteStr	#95,#FIRST_ITEM,#1,szGood
    move.w  #AI_GOOD,aiSkill
    bra     EndSetAiSkill
   
AiExpert
    WriteStr	#95,#FIRST_ITEM,#1,szExpert
    move.w  #AI_EXPERT,aiSkill
    bra     EndSetAiSkill
            
EndSetAiSkill
    
    WriteStr #30,#FIRST_ITEM+ITEM_HEIGHT,#1,szPointsPerMatch
    
    move.w  pointsPerMatch,d0
    PrintD0 #119,#FIRST_ITEM+ITEM_HEIGHT,#1   
	
	WriteStrCenter	#FIRST_ITEM+2*ITEM_HEIGHT,#1,szBack

CheckSel
	move.w	sel,sel_rg
	bsr	    UpdateSel
	jsr	    userlib::idle_loop
	move.w	d0,-(a7)
	bsr	    UpdateSel
	move.w	(a7)+,d0
	cmp.b	#337,d0
	beq	    SelUp
	cmp.b	#340,d0
	beq	    SelDown
	cmp.b	#13,d0
	beq	    ConfirmSel
	cmp.b	#264,d0
	beq	    ExitMenu

	bra	    CheckSel
	
SelUp
	cmp.w	#FIRST_ITEM,sel_rg
	beq	    WrapSelLast
	sub.w	#ITEM_HEIGHT,sel
	bra	    CheckSel	
WrapSelLast
	move.w	last_item,sel
	bra	    CheckSel
	
SelDown
	cmp.w	last_item,sel_rg
	beq	    WrapSelFirst
	add.w	#ITEM_HEIGHT,sel
	bra	    CheckSel	
WrapSelFirst
	move.w	#FIRST_ITEM,sel
	bra	    CheckSel
	
ExitMenu
	bsr	    ErasMenu
	move.w	#FIRST_ITEM,sel
	cmp.w	#MAIN_MENU,menu_level
	beq	    ExitProgram
	move.w	#MAIN_MENU,menu_level
	bra	    RedrawMenu		
	
ConfirmSel
	bsr	    ErasMenu
	move.w	#FIRST_ITEM,d2
	cmp.w	#MAIN_MENU,menu_level
	beq	    ConfMainMenu
	cmp.w	#PLAY_MENU,menu_level
	beq	    ConfPlayMenu
	cmp.w	#OPTIONS_MENU,menu_level
	beq	    ConfOptionsMenu

ConfMainMenu
	cmp.w	#FIRST_ITEM,sel
	beq	    InitPlayMenu
	cmp.w	#FIRST_ITEM+ITEM_HEIGHT,sel
	beq	    InitOptionsMenu

	bra	    ExitProgram
	
InitPlayMenu
    move.w	#FIRST_ITEM,sel
	move.w	#PLAY_MENU,menu_level
	bra	    RedrawMenu
InitOptionsMenu	
    move.w	#FIRST_ITEM,sel
	move.w	#OPTIONS_MENU,menu_level
	bra	    RedrawMenu
	
ConfPlayMenu
	cmp.w	#FIRST_ITEM,sel
	beq	    InitHuVsHuGame
	cmp.w	#FIRST_ITEM+ITEM_HEIGHT,sel
	beq	    InitHuVsAiGame
	cmp.w	#FIRST_ITEM+2*ITEM_HEIGHT,sel
	beq	    InitAiVsAiGame

	bra	    ExitMenu
	
InitHuVsHuGame
	move.b	#HUMAN,who_is_bat1
	move.b	#HUMAN,who_is_bat2
	bra	    StartGame
	
InitHuVsAiGame
	move.b	#AI,who_is_bat1
	move.b	#HUMAN,who_is_bat2
	bra	    StartGame
	
InitAiVsAiGame
	move.b	#AI,who_is_bat1
	move.b	#AI,who_is_bat2
	bra	    StartGame

	
ConfOptionsMenu
    cmp.w   #FIRST_ITEM,sel
    beq     RollAiSkill
    cmp.w   #FIRST_ITEM+ITEM_HEIGHT,sel
    beq     RollPointsPerMatch
    bra     ExitMenu
    
RollAiSkill
    cmp.w   #AI_EXPERT,aiSkill
    beq     WrapAiSkill
    add.w   #AI_STEP,aiSkill
    bra     RedrawMenu 
    
WrapAiSkill
    move.w  #AI_BAD,aiSkill
    bra     RedrawMenu

RollPointsPerMatch
    cmp.w   #POINTS_PER_MATCH_MAX,pointsPerMatch
    beq     WrapPointsPerMatch
    add.w   #1,pointsPerMatch
    bra     RedrawMenu

WrapPointsPerMatch
    move.w  #POINTS_PER_MATCH_MIN,pointsPerMatch
    bra     RedrawMenu
	
	
;------------------------------------------------------
;  GAME ROUTINES	
;------------------------------------------------------	
	
	
StartGame
	bsr	    InitGame

GameLoop
	bsr	UpdateTimerBats
	
	sub.w	#1,timerCntBalX
	tst.w	timerCntBalX
	beq	    UpdateBalx
	
	sub.w	#1,timerCntBalY
	tst.w	timerCntBalY
	beq	    UpdateBaly
	

	bsr	    Update_timerCntBat1
	beq	    GetBat1Request		;if timercnt=0 then
					;takes care of bat1
					;direction request 
	
RtGetBat1Request	
	
	bsr	    Update_timerCntBat2
	beq	    GetBat2Request		;if timercnt=0 then
					;takes care of bat2
					;direction request 

RtGetBat2Request	
	

	move.b  #MASK_L1,d0
	bsr     GetKey
	btst.b  #ENTER_BIT,d0
	beq     PauseGame
	move.b	#MASK_L6,d0	;Want to stop the game...
	bsr	    GetKey		;
	btst.b	#ESC_BIT,d0	;
	
	
	bne	    GameLoop	;...Ok if ESC is pressed
	
	bsr	    IntOn
	cmp.b   #1,escFlag
	beq     \NoClearKeyBuff
	jsr	    userlib::idle_loop ;clears the keyboard buffer 
	
\NoClearKeyBuff
	bra	    Menu
	

GetBat1Request			;Takes care of Bat1
				;direction request
	
	clr.b   lastMoveBat1
	cmp.b	#AI,who_is_bat1	;Checks whether Bat1 is 
	beq	    AiRoutine1	;human or ai and chooses the
				;correct routine according
				;to that
	
;HumanRoutine
	move.b	#MASK_L0,d0
	bsr	    GetKey
	btst.b	#SECOND_BIT,d0
	beq	    Up1
	move.b	#MASK_L5,d0
	bsr	    GetKey
	btst.b	#HOME_BIT,d0
	beq	    Down1
	
	bra	    RtGetBat1Request ;No request => return

AiRoutine1
    move.w  aiSkill,d0
	cmp.w	posXBal,d0	
	ble	    RtGetBat1Request
	cmp.w   #0,dirBalX
	bge     RtGetBat1Request

	move.w	y1,d0		;Moves according to ball y
	cmp.w	posYBal,d0	;position
	bge	    Up1
	bra	    Down1
	
		
Up1
	cmp.w	#YMIN+2,y1
	ble	    RtGetBat1Request
	move.w	timerBats,timerCntBat1
	ErasBat	#X1,y1
	sub.w	#1,y1
	DrawBat	#X1,y1,spriteBat1
	move.b  #2,lastMoveBat1
	bra	    RtGetBat1Request

Down1

	cmp.w	#YMAX-RAQ_HEIGHT+BAL_SIZE,y1
	bge	    RtGetBat1Request
	move.w	timerBats,timerCntBat1
	ErasBat	#X1,y1
	add.w	#1,y1
	DrawBat	#X1,y1,spriteBat1
	move.b  #1,lastMoveBat1
	bra	    RtGetBat1Request

	
GetBat2Request			;Takes care of Bat2
				;direction request
	
	clr.b   lastMoveBat2
	cmp.b	#AI,who_is_bat2	;Checks whether Bat2 is 
	beq	    AiRoutine2	;human or ai and chooses the
				;correct routine according
				;to that
	
;HumanRoutine
	move.b	#MASK_L0,d0
	bsr	    GetKey
	btst.b	#UP_BIT,d0
	beq	    Up2
	btst.b	#DOWN_BIT,d0
	beq	    Down2

	bra	    RtGetBat2Request ;No request => return

AiRoutine2
    move.w  #LCD_WIDTH,d0
    sub.w   aiSkill,d0
	cmp.w	posXBal,d0
	bge	    RtGetBat2Request
	cmp.w   #0,dirBalX
	ble     RtGetBat2Request

	move.w	y2,d0		;Moves according to ball y
	cmp.w	posYBal,d0	;position
	bge	    Up2
	bra	    Down2
	
Up2
	cmp.w	#YMIN+2,y2
	ble	    RtGetBat2Request
	move.w	timerBats,timerCntBat2
	ErasBat	#X2,y2
	sub.w	#1,y2
	DrawBat	#X2,y2,spriteBat2
	move.b  #2,lastMoveBat2
	bra	    RtGetBat2Request
Down2
	cmp.w	#YMAX-RAQ_HEIGHT+BAL_SIZE,y2
	bge	    RtGetBat2Request
	move.w	timerBats,timerCntBat2
	ErasBat	#X2,y2
	add.w	#1,y2
	DrawBat	#X2,y2,spriteBat2
	move.b  #1,lastMoveBat2
	bra	    RtGetBat2Request
	

UpdateBaly
	ErasBal	posXBal,posYBal
	cmp.w	#YMAX,posYBal
	bge	    Neg_dirBalY
	cmp.w	#YMIN,posYBal
	ble	    Neg_dirBalY
	bra	    NoNeg_dirBalY

Neg_dirBalY	
	neg.w	dirBalY

NoNeg_dirBalY
    move.w  posYBal,d0
	add.w	dirBalY,d0
	move.w  d0,posYBal
	move.w	timerBalY,timerCntBalY
	DrawBal	posXBal,posYBal
	bra	    GameLoop
	

UpdateBalx
	ErasBal	posXBal,posYBal
	cmp.w	#XMAX,posXBal
	bge	    CheckBat2
	cmp.w	#XMIN,posXBal
	ble	    CheckBat1
	bra	    EndUpdateBalx

CheckBat2
    bsr     DecTimerBalxy
	move.w	y2,d0
	sub.w	#BAL_SIZE,d0
	cmp.w	posYBal,d0
	bge	    Bat2Lose
	add.w	#RAQ_HEIGHT+BAL_SIZE,d0
	cmp.w	posYBal,d0
	ble	    Bat2Lose

	neg.w	dirBalX
	move.b  lastMoveBat2,d4    
    	bsr     EffectBall
    	bsr	UpdateTimerBats
	bra	EndUpdateBalx
	
Bat2Lose
	add.w	#1,score1
	move.w  pointsPerMatch,d0
    	cmp.w   score1,d0
    	beq     Bat1WinMatch
 
	bsr	    InitNewBal
	bra	    EndUpdateBalx
	
Bat1WinMatch
    bsr     RedrawScores
    bsr     IntOn
    SetFont #2
    WriteStrCenter    lcdHMid,#1,szBat1WinMatch
    bsr     WaitForEnterOREsc
    bra     Menu
		
CheckBat1
    	bsr     DecTimerBalxy
	move.w	y1,d0
	sub.w	#BAL_SIZE,d0
	cmp.w	posYBal,d0
	bge	    Bat1Lose
	add.w	#RAQ_HEIGHT+BAL_SIZE,d0
	cmp.w	posYBal,d0
	ble	    Bat1Lose
	
	neg.w	dirBalX
	move.b  lastMoveBat2,d4    
    	bsr     EffectBall
    	bsr	UpdateTimerBats
	bra	EndUpdateBalx
	
Bat1Lose
	add.w	#1,score2
	move.w  pointsPerMatch,d0
    	cmp.w   score2,d0
    	beq     Bat2WinMatch

	bsr	    InitNewBal
	bra	    EndUpdateBalx
	
Bat2WinMatch
    bsr     RedrawScores
    bsr     IntOn
    SetFont #2
    WriteStrCenter   lcdHMid,#1,szBat2WinMatch 
    bsr     WaitForEnterOREsc
    bra     Menu

EndUpdateBalx
    move.w  posXBal,d0
	add.w	dirBalX,d0
	move.w  d0,posXBal
	DrawBal	posXBal,posYBal
	move.w	timerBalX,timerCntBalX
	bra	    GameLoop
	
PauseGame
    bsr     IntOn
    SetFont #2
    WriteStr    #60,#30,#2,szPause
    SetFont #1
    WriteStr    #0,#1,#0,szModeToSd
    jsr     userlib::idle_hot
    cmp.b   #264,d0
    bne     \NoSetEscFlag
    move.b  #1,escFlag
    
\NoSetEscFlag  
    bsr     DrawBackground
    bsr     IntOff
    bra     GameLoop
    
ExitProgram
	rts
	

; end of _main
;------------------------------------------------------
;   DIVERS SUB-ROUTINES	
;------------------------------------------------------		


InitGame:
	clr.w	score1
	clr.w	score2
	move.w	#Y_RAQ_INIT,y1
	move.w  #Y_RAQ_INIT,y2
    bsr     DrawBackground
	bsr	    InitNewBal
	bsr	    IntOff
	clr.b   escFlag
	rts
	



InitNewBal:
	move.w	#1,timerCntBalX
	move.w	#1,timerCntBalY
	move.w	#TIMER_BALX_INIT,timerBalX
	move.w	#RND_COEFF,d0
	bsr	    GenerateSignedRnd
	add.w	d0,timerBalX
	move.w	#TIMER_BALY_INIT,timerBalY
	move.w	#RND_COEFF,d0
	bsr	    GenerateSignedRnd
	add.w	d0,timerBalY
	move.w	#POSX_BAL_INIT,posXBal
	move.w	#POSY_BAL_INIT,posYBal
	bsr	    GenerateRndSign
	move.w	d0,dirBalX
	bsr	    GenerateRndSign
	move.w	d0,dirBalY
	bsr     RedrawScores
	rts
	
Update_timerCntBat1:
	tst.w	timerCntBat1
	beq	    \NoSub_timerCntBat1
	sub.w	#1,timerCntBat1
\NoSub_timerCntBat1
	rts
	
Update_timerCntBat2:
	tst.w	timerCntBat2
	beq	    \NoSub_timerCntBat2
	sub.w	#1,timerCntBat2
\NoSub_timerCntBat2
	rts
	
UpdateTimerBats:	
	move.w	timerBalX,d0
	add.w	timerBalY,d0
	asr.w	#3,d0
	add.w	#TIMERCNT_BATS,d0
	move.w	d0,timerBats
	rts

EffectBall:
    move.w  timerBalY,-(a7)
    move.w  #RND_COEFF,d0
    bsr     GenerateSignedRnd
    add.w   d0,timerBalY
    tst.b   d4
    beq     \CheckEffect
    move.w  timerBalY,d1
   
   
    cmp.b   #1,d4
    beq     \DownEffect

;\UpEffect    
    cmp.w   #0,dirBalY
    bge     \DecelerateBall
    bra     \AccelerateBall
\DownEffect
    cmp.w   #0,dirBalY
    ble     \DecelerateBall
    bra     \AccelerateBall

\AccelerateBall
    move.w  timerBalY,d0
    sub.w   #EFFECT_COEFF,d0
    move.w  d0,timerBalY
    bra     \CheckEffect
\DecelerateBall
    move.w  timerBalY,d0
    add.w   #EFFECT_COEFF,d0
    move.w  d0,timerBalY
    
\CheckEffect
    cmp.w   #TIMER_BALY_MAX,d1
    ble     \ApplyEffect
    cmp.w   #TIMER_BALY_MIN,d1
    bge     \ApplyEffect

    move.w  (a7)+,timerBalY

\ApplyEffect
    add.l   #2,a7
    rts


DrawBackground:
    SetFont #1
    jsr	    graphlib::clr_scr
    DrawBat	#X1,y1,spriteBat1
	DrawBat	#X2,y2,spriteBat2
	WriteStr #0,#LCD_HEIGHT-8,#0,szScores
	move.w  #YMAX+BAL_SIZE+2,d1
	bsr     PxlHorzBlack
	clr.w   d1
	bsr     PxlHorzBlack
	bsr     RedrawScores
	rts

RedrawScores:
    move.w  score1,d0
	PrintD0 #10,#LCD_HEIGHT-8,#0
	move.w  score2,d0
    PrintD0 #LCD_WIDTH-16,#LCD_HEIGHT-8,#0
    rts


DecTimerBalxy:
    cmp.w   #TIMER_BALX_MIN,timerBalX
    ble     \NoDecTimerBalxy
    cmp.w    #TIMER_BALY_MIN,timerBalY
    ble     \NoDecTimerBalxy
    sub.w   #AUTO_ACCELERATION_COEFF,timerBalX
    sub.w   #AUTO_ACCELERATION_COEFF,timerBalY
\NoDecTimerBalxy
    rts
    


ErasBatSubRout:
	move.b	#$FF,d3
	lea	    XORSpriteBat(pc),a0
	jsr	    graphlib::put_sprite_mask
	rts


DrawBatSubRout:
	clr.b	d3
	jsr	    graphlib::put_sprite_mask
	rts
	

ErasBalSubRout:
	move.b	#$FF,d3
	lea	    XORspriteBal(pc),a0
	jsr	    graphlib::put_sprite_mask
	rts


DrawBalSubRout:
	clr.b	d3
	lea	    spriteBal(pc),a0
	jsr	    graphlib::put_sprite_mask
	rts

UpdateSel:
	move.w	#27,d0
	move.w	#LCD_WIDTH-2*27,d2
	move.w	#6,d3
	move.w	#0,d4
	jsr	    graphlib::fill
	rts
	
ErasMenu:
	move.w	#2,d0
	move.w	#FIRST_ITEM,d1
	move.w	#LCD_WIDTH-4,d2
	move.w	last_item,d3
	sub.w	#FIRST_ITEM,d3
	add.w	#ITEM_HEIGHT,d3
	move.w	#1,d4
	jsr	    graphlib::fill
	rts
	
WaitForEnterOREsc:
\loop
    jsr     userlib::idle_loop
    cmp.b   #264,d0
    beq     \ok
    cmp.b   #13,d0
    beq     \ok
    bra     \loop
\ok
     rts
	
PxlHorzBlack:
	move.w	#0,d0
	move.w	#LCD_WIDTH,d2
	move.w	#2,d3
	jsr	    graphlib::horiz
	rts
	
		
PxlVertBlack:
	move.w	#0,d1
	move.w	#LCD_HEIGHT,d2
	jsr	    graphlib::vert
	rts
	

PrintValue:
        move.l  #str+8,a0
        clr.b   (a0)
        clr.l   d1
\loop
        add.l   #1,d1
        divu    #10,d0
        swap    d0
        add.b   #48,d0
        move.b  d0,-(a0)
        clr.w   d0
        swap    d0
        tst.w   d0
        bne     \loop
        rts

GenerateRndSign:		    ;return -1 or +1 in d0
	move.w	#2,d0
	jsr	    userlib::random	;-> d0=1 or d0=0
	tst.w	d0		        ;d0!=0 then 
	bne	    \Plus		    ;  return d0=+1
	move.w	#-1,d0		    ;else return -1
\Plus	
    rts
	
GenerateSignedRnd:		;input:d0.w
				        ;output:RND [-d0.w;d0.w]
	jsr	    userlib::random
	move.w	d0,-(a7)	    ;save RND(d0) with the stack
	bsr	    GenerateRndSign	;-1->d0 or +1->d0
	muls.w	(a7)+,d0	    ;-1*RND(d0)->d0 OR
				            ;+1*RND(d0)->d0
	rts


IntOff:
	clr.l 	d0
    move.w 	#$0700,d0
    trap 	#1
	rts


IntOn:
	clr.l	d0
    trap 	#1
	rts

    
    
GetKey:
	move.w	d0,($600018)
  	nop
  	nop
  	nop
  	nop
	nop
  	nop
  	nop
  	nop
  	nop
  	nop
	nop
  	nop
	nop
  	nop
	nop
  	nop
  	move.b	($60001b),d0
	rts
	

DrawStrCenterXY: ;DrawStrCenterXY(y,col,str)
		 ;Draws a string centered on the middle of 
		 ;the screen
		 ;Input: d1.w = y
		 ;       d2.w = color	
		 ;       a0.l = address of the string

	movem	d0/d3/a1,-(a7)
	
	move.w	d2,-(a7)
	move.l	a0,-(a7)
	
	jsr	    doorsos::FontGetSys ;we've got to take into
	asl.w	#1,d0 		        ;account the font size
	move.w	#4,d3
	add.w	d0,d3		        ;d3=char. size in bits
	jsr	    doorsos::strlen
	mulu.w	d3,d0		        ;gets str lengh in bits
	move.w	#LCD_WIDTH,d3
	sub.w	d0,d3
	asr.w	#1,d3		        ;we've got our x position
	
	move.w	d1,-(a7)
	move.w	d3,-(a7)
	jsr	    doorsos::DrawStrXY
	lea	    10(a7),a7
	movem	(a7)+,d0/d3/a1
	rts

    

spriteBat2	dc.w	14
		dc.w	1
		dc.b	%01100000
		dc.b	%11100000
		dc.b	%11010000
		dc.b	%10110000
		dc.b	%11010000
		dc.b	%10110000
		dc.b	%11010000
		dc.b	%10110000
		dc.b	%11010000
		dc.b	%10110000
		dc.b	%11010000
		dc.b	%10110000
		dc.b	%11100000
		dc.b	%01100000

spriteBat1	dc.w	14
		dc.w	1
		dc.b	%00000110
		dc.b	%00000111
		dc.b	%00001101
		dc.b	%00001011
		dc.b	%00001101
		dc.b	%00001011
		dc.b	%00001101
		dc.b	%00001011
		dc.b	%00001101
		dc.b	%00001011
		dc.b	%00001101
		dc.b	%00001011
		dc.b	%00000111
		dc.b	%00000110


XORSpriteBat	dc.w	14
		        dc.w	1
		        ds.b	14
		
spriteBal	dc.w	6
		dc.w	1
		dc.b	%00111100
		dc.b	%01110010
		dc.b	%11111011
		dc.b	%11111111
		dc.b	%01111110
		dc.b	%00111100

XORspriteBal	dc.w	8
		        dc.w	1
		        ds.b	8		


oldInt1         ds.l    1
aiSkill         dc.w    AI_GOOD
pointsPerMatch  dc.w    POINTS_PER_MATCH_DEFAULT
posXBal         ds.w    1
posYBal         ds.w    1
lcdHMid         ds.w    1
y1		        ds.w	1
y2		        ds.w	1
score1		    ds.w	1
score2		    ds.w	1
timerCntBalX	ds.w	1
timerBalX	    ds.w	1
timerCntBalY	ds.w	1
timerBalY	    ds.w	1
timerCntBat1	ds.w	1
timerCntBat2	ds.w	1
timerBats	ds.w	1
dirBalX	        ds.w	1
dirBalY	        ds.w	1
last_item	    ds.w	1 
sel		        ds.w	1
lastMoveBat1    ds.b    1
lastMoveBat2    ds.b    1
who_is_bat1	    ds.b	1
who_is_bat2	    ds.b	1
str             ds.b    10

szBat1WinMatch  dc.b    "<<- YOU WiN !",0
szBat2WinMatch  dc.b    "YOU WiN ! ->>",0
szScores        dc.b    "    <-/\| SCORES |/\->     ",0
szPause         dc.b    "Pause",0
szModeToSd      dc.b    " <<  [MODE]: SHUTDOWN   >> ",0   
szPlay	        dc.b	"P L A Y",0
szOptions	    dc.b	"O P T I O N S",0
szQuit	        dc.b	"Q U I T",0

szHuVsHu	dc.b	"HUMAN VS HUMAN",0
szHuVsAi	dc.b	"HUMAN VS AI",0
szAiVsAi	dc.b	"AI VS AI",0
szBack	    dc.b	"B A C K",0

szAiSkill   dc.b    "AI SKILL :",0
szBad       dc.b    "   BAD",0        
szGood      dc.b    "  GOOD",0
szExpert    dc.b    "EXPERT",0

szPointsPerMatch    dc.b    "POINTS/MATCH :",0

szTitle		dc.b	"SUPER PONG",0
szVersion	dc.b	"v1.1",0
szAuthor    dc.b	"by Erwan Rouzel aKa nop",0
szEmail     dc.b    "e-mail : nop@ifrance.com",0
szWeb       dc.b    "WEB : http://nop.ifrance.com",0

_comment	dc.b	"SUPER PONG by nop",0

	end