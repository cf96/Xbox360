# ============================================================================
# 			A few X360 patches for live based things
#			by tch1. Use for whatever you like, but
#			please give credit where due!
# ============================================================================

    .globl _start
_start:

# ----------------------------------------------------------------------------
#						SECTION: Patched Functions
# ----------------------------------------------------------------------------

.set XContentGetLicenseMask, 0x816EEBA8
.set XamUserCheckPrivilege, 0x816DCB90
.set XamUserGetGamerTag, 0x816D7B60

# ----------------------------------------------------------------------------
#						SECTION: Variables
# ----------------------------------------------------------------------------

.set memcpy, 0x81729750 # memcpy in XAM, easy to find
.set GamertagStr, 0x8162FA28 # random string in XAM, looks like it can be overwritten ¯\(°_o)/¯

# ----------------------------------------------------------------------------
#						SECTION: Variable initialization
# ----------------------------------------------------------------------------
.long GamertagStr
.long (9f-0f)/4
0:
	.string "tch1"
	.byte 0
	.align 3
9:

# ----------------------------------------------------------------------------
#						SECTION: Patched functions
# ----------------------------------------------------------------------------

# ============================================================================
# Patches all arcade games to full licensed game
# ============================================================================
.long XContentGetLicenseMask
.long (9f-0f)/4
0:
	li %r11, 0x1 # LICENSE_MASK_FULL
	stw %r11, 0(%r3)
	li %r3, 0
	blr
9:

# ============================================================================
# Allows silver profiles to enjoy gold privileges such as mp
# ============================================================================
.long XamUserCheckPrivilege
.long (9f-0f)/4
0:
	li %r11, 0x1 # TRUE
	stw %r11, 0(%r5)
	li %r3, 0
	blr
9:
# ============================================================================

# ============================================================================
# Spoofs gamertag to the one specified above 
# Might not work, never tested, assuming args are as follows, can be adjusted 
# accordingly: XamUserGetGamertag(DWORD userIndex, char *buffer)
# ============================================================================
.long XamUserGetGamerTag
.long (9f-0f)/4
0:
	mflr %r12
	stw %r12, -8(%r1) # save our lr
	stwu %r1, -80(%r1) # setup stack frame to preserve our lr
	mr %r3, %r4 # copy our gamertag buffer to r3
	lis %r11, GamertagStr@h
	addi %r4, %r11, GamertagStr@l
	li %r5, 5 # length of our gamertag + '\0'
	li %r11, 0 # need to clear r11 here
	lis %r11, memcpy@h
	addi %r11, %r11, memcpy@l
	mtcr %r11
	bctr # branch to memcpy
	li %r3, 0 # our result
	addi %r1, %r1, 80 # lets tear down this stack frame
	lwz %r12, -8(%r1) # pop our lr off the stack to r12
	mtlr %r12
	blr
9:

.long 0xFFFFFFFF
