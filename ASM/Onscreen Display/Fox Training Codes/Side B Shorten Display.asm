#To be inserted at 8006b7f4
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r3,0x8(r1)
.endm

.macro restore
lmw  r3,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.macro intToFloat reg,reg2
xoris    \reg,\reg,0x8000
lis    r18,0x4330
lfd    f16,-0x7470(rtoc)    # load magic number
stw    r18,0(r2)
stw    \reg,4(r2)
lfd    \reg2,0(r2)
fsubs    \reg2,\reg2,f16
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730
.set TextCreateFunction,0x80005928

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+0x0
.set TwoASAgo,PrevASStart+0x2
.set ThreeASAgo,PrevASStart+0x4
.set FourASAgo,PrevASStart+0x6
.set FiveASAgo,PrevASStart+0x8
.set SixASAgo,PrevASStart+0xA

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backup

	#General AS's


	#Check If Fox or Falco
	lwz	r3,0x4(playerdata)
	cmpwi	r3,0x1
	beq	FoxFalco
	cmpwi	r3,0x16
	beq	FoxFalco

	#Check If Anyone Else
	b	Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////

	FoxFalco:
	#CHECK IF ENABLED
	li	r0,8			#Fox Training Codes ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	#Branch to AS Functions
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0x15B			#Ground Side B Start
	beq	Fox_SideBStart
	cmpwi	r3,0x15E			#Air Side B Start
	beq	Fox_SideBStart

	cmpwi	r3,0x15C			#Ground Side B
	beq	Fox_SideB
	cmpwi	r3,0x15F			#Air Side B
	beq	Fox_SideB

	cmpwi	r3,0x15D			#Ground Side B End
	beq	Fox_SideBEnd
	cmpwi	r3,0x160			#Air Side B End
	beq	Fox_SideBEnd

	cmpwi	r3,0x169
	beq	Fox_ShineGroundLoop
	cmpwi	r3,0x16E
	beq	Fox_ShineAirLoop


	b	Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////

	Fox_SideBStart:
	#Check If Pressed B
	lwz	r3,0x668(playerdata)
	rlwinm.	r3,r3,0,22,22
	beq	Fox_SideBStart_NoPress

	#Create Text
	bl	CreateText
	mr	text,r3			#backup text pointer

	#Change Text Color
	load	r3,0xffa2baff
	stw	r3,0x30(text)

	#Create Top Line
	bl	ShortenPress

	#Create Bottom Line
	#Get Current Frame
	#lfs	f1,0x894(playerdata)
	#fctiwz	f1,f1
	#stfd	f1,0xF0(sp)
	#lwz	r3,0xF4(sp)
	lhz	r3,0x23EC(playerdata)
	#Get Frames Early
	lwz 	r5,0x590(playerdata)			#get anim data
	lfs	f1,0x008(r5)			#get anim length (float)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r4,0xF4(sp)
	sub	r5,r4,r3
	subi	r5,r5,0x1

	bl	EarlyPressText
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98


	Fox_SideBStart_NoPress:
	b	Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////

	Fox_SideB:
	#Check If Pressed B
	lwz	r3,0x668(playerdata)
	rlwinm.	r3,r3,0,22,22
	beq	Fox_SideB_NoPress

	#Create Text
	bl	CreateText
	mr	text,r3			#backup text pointer

	#Change Text Color
	load	r3,0x8dff6eff
	stw	r3,0x30(text)

	#Create Top Line
	bl	ShortenPress

	#Create Bottom Line
	#Get Current Frame
	lfs	f1,0x894(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r3,0xF4(sp)
	#Get Frames Early
	addi	r5,r3,0x1

	bl	ShortenTypeText
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98

	Fox_SideB_NoPress:
	b	Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////

	Fox_SideBEnd:
	#Check If Pressed B
	lwz	r3,0x668(playerdata)
	rlwinm.	r3,r3,0,22,22
	beq	Fox_SideBEnd_NoPress

	#Create Text
	bl	CreateText
	mr	text,r3			#backup text pointer

	#Change Text Color
	load	r3,0xffa2baff
	stw	r3,0x30(text)

	#Create Top Line
	bl	ShortenPress

	#Create Bottom Line
	#Get Current Frame
	#lfs	f1,0x894(playerdata)
	#fctiwz	f1,f1
	#stfd	f1,0xF0(sp)
	#lwz	r3,0xF4(sp)
	lhz	r5,0x23EC(playerdata)
	#addi	r5,r3,0x1

	bl	LatePressText
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98

	Fox_SideBEnd_NoPress:
	b	Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////


Fox_ShineGroundLoop:
	#Check For JC
	bl	CheckForJumpCancel
	cmpwi	r3,0x0
	beq	Moonwalk_Exit

	Fox_ShineGroundLoop_Interrupted:
	#Create Text
	bl	CreateText
	mr	text,r3			#backup text pointer


		#Check If Frame Perfect
		#Get Current Frame
		#lfs	f1,0x894(playerdata)
		#fctiwz	f1,f1
		#stfd	f1,0xF0(sp)
		#lwz	r3,0xF4(sp)
		lhz	r3,0x23EC(playerdata)
		cmpwi	r3,0x1
		bne	Fox_ShineGroundLoop_RedText

		#Frame Perfect
		load	r3,0x8dff6eff			#green
		b	Fox_ShineGroundLoop_StoreColor

		Fox_ShineGroundLoop_RedText:
		load	r3,0xffa2baff

		Fox_ShineGroundLoop_StoreColor:
		stw	r3,0x30(text)

		Fox_ShineGroundLoop_TopLine:
		#Create Text
		bl	ActOOShineTop
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		Fox_ShineGroundLoop_BottomLine:
		#Create Text2
		bl	ActOOShineBottom
		mr 	r3,r29			#text pointer
		mflr	r4
		#Get Current Frame
		#lfs	f1,0x894(playerdata)
		#fctiwz	f1,f1
		#stfd	f1,0xF0(sp)
		#lwz	r3,0xF4(sp)
		lhz	r5,0x23EC(playerdata)
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


#/////////////////////////////////////////////////////////////////////////////

Fox_ShineAirLoop:
	#Check For Remaining Jump
	lbz	r3, 0x1968 (playerdata)			#Jumps Used
	lwz	r0, 0x0168 (playerdata)			#Total Jumps
	cmpw	r3,r0
	bge	Moonwalk_Exit

	#Check For JC
	bl	CheckForJumpCancel
	cmpwi	r3,0x0
	beq	Moonwalk_Exit

	Fox_ShineAirLoop_Interrupted:
	#Create Text
	bl	CreateText
	mr	text,r3			#backup text pointer


		#Check If Frame Perfect
		#Get Current Frame
		#lfs	f1,0x894(playerdata)
		#fctiwz	f1,f1
		#stfd	f1,0xF0(sp)
		#lwz	r3,0xF4(sp)
		lhz	r3,0x23EC(playerdata)
		cmpwi	r3,0x1
		bne	Fox_ShineAirLoop_RedText

		#Frame Perfect
		load	r3,0x8dff6eff			#green
		b	Fox_ShineAirLoop_StoreColor

		Fox_ShineAirLoop_RedText:
		load	r3,0xffa2baff

		Fox_ShineAirLoop_StoreColor:
		stw	r3,0x30(text)

		Fox_ShineAirLoop_TopLine:
		#Create Text
		bl	ActOOShineTop
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		Fox_ShineAirLoop_BottomLine:
		#Create Text2
		bl	ActOOShineBottom
		mr 	r3,r29			#text pointer
		mflr	r4
		#Get Current Frame
		#lfs	f1,0x894(playerdata)
		#fctiwz	f1,f1
		#stfd	f1,0xF0(sp)
		#lwz	r3,0xF4(sp)
		lhz	r5,0x23EC(playerdata)
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit

#/////////////////////////////////////////////////////////////////////////////

CheckForJumpCancel:
mflr	r0
stw	r0, 0x0004 (sp)
stwu	sp, -0x0038 (sp)
	#Check For JC
	lwz	r5, -0x514C (r13)
	lfs	f0, 0x0070 (r5)
	lfs	f1, 0x0624 (playerdata)
	fcmpo	cr0,f1,f0
	blt	CheckForJumpCancel_CheckButtons
	lbz	r3, 0x0671 (playerdata)
	lwz	r0, 0x0074 (r5)
	cmpw	r3,r0
	bge	CheckForJumpCancel_CheckButtons
	li	r3,0x1
	b	CheckForJumpCancel_Exit
	CheckForJumpCancel_CheckButtons:
	lwz	r0, 0x0668 (playerdata)
	rlwinm.	r0, r0, 0, 20, 21
	beq	CheckForJumpCancel_NoButtons
	li	r3,0x1
	b	CheckForJumpCancel_Exit
CheckForJumpCancel_NoButtons:
li	r3,0x0
CheckForJumpCancel_Exit:
lwz	r0, 0x003C (sp)
addi	sp, sp, 56
mtlr	r0
blr

ShortenPress:
mflr	r0
stw	r0, 0x0004 (sp)
stwu	sp, -0x0038 (sp)
bl	ShortenPressText
mr 	r3,r29			#text pointer
mflr	r4
lfs	f1, -0x37B4 (rtoc)			#default text X/Y
lfs	f2, -0x37B4 (rtoc)			#default text X/Y
branchl r12,0x803a6b98
lwz	r0, 0x003C (sp)
addi	sp, sp, 56
mtlr	r0
blr


CreateText:
mflr	r0
stw	r0, 0x0004 (sp)
stwu	sp, -0x0008 (sp)
mr	r3,playerdata			#backup playerdata pointer
li	r4,60			#display for 60 frames
li	r5,0			#Area to Display (0-2)
li	r6,8			#Window ID (Unique to This Display)
branchl	r12,TextCreateFunction			#create text custom function
lwz	r0, 0x000C (sp)
addi	sp, sp, 8
mtlr r0
blr


###################
## TEXT CONTENTS ##
###################
ShortenPressText:
blrl
.long 0x53686f72
.long 0x74656e20
.long 0x50726573
.long 0x73000000

EarlyPressText:
blrl
.long 0x25646620
.long 0x4561726c
.long 0x79000000

ShortenTypeText:
blrl
.long 0x4672616d
.long 0x65202564
.long 0x815e3400

LatePressText:
blrl
.long 0x25646620
.long 0x4c617465
.long 0x00000000

ActOOShineTop:
blrl
.long 0x41637420
.long 0x4f4f5368
.long 0x696e6500

ActOOShineBottom:
blrl
.long 0x4672616d
.long 0x65202564
.long 0x00000000

##############################


Moonwalk_Exit:
restore
lwz	r12, 0x219C (r31)