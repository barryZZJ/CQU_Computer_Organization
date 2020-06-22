.data 
	msg_first_val:	.asciiz "\nFirst floating-point value:\n>"
	msg_sencond_val:.asciiz "\nSecond floating-point value:\n>"
	msg_operator:	.asciiz "\n1. +\n2. -\n3. ×\n4. ÷\n>"
	msg_wrong_input:.asciiz "\nWrong input!\n"
	msg_over_flow:	.asciiz "\nError: Overflow!\n"
	msg_under_flow:	.asciiz "\nError: Underflow!\n"
	msg_start:		.asciiz "1. Calculate\n2. Exit\n>"
	msg_div_zero:	.asciiz "\nError: Cannot divde by zero!\n"
	msg_result_bin:	.asciiz "\nResult:\nBinary:\n"
	msg_result_hex: .asciiz "\nHex:\n"
	msg_change_base:.asciiz "\n1. Change into Hex\n2.Restart\n>"
	hex_table:  	.asciiz "0123456789ABCDEF"
	hex_digits: 	.asciiz "XXXXXX"
	string_neg:		.asciiz "-"
	string_1dot:	.asciiz "1."
	string_0dot:	.asciiz "0."
	string_totwo:	.asciiz "*2^"
	string_dot: 	.asciiz "."
	string_to16:	.asciiz "*16^"
	string_0:		.asciiz "0"
	string_1: 		.asciiz "1"
	string_hex0: 	.asciiz "000000*16^0"

.text
main:
# 输入提示
	la		$a0,	msg_start	
	li		$v0,	4	
	syscall 
# 读入
	li		$v0,	5
	syscall 
# 输入为2则退出，否则继续
	beq		$v0,	2,		exit

# 读入两个浮点数
	jal		input_operand	
# 读入运算符
	jal		input_operator

	# output 的jr返回到这里

# 回到开始
	j		main

##############################
	# 读入两个浮点数
input_operand:
	addi	$sp,	$sp,	-32 
	sw 		$ra,	20($sp)
	sw		$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 		$a0,	0($fp)
	#  读入第一个浮点数
	la		$a0,	msg_first_val
	li		$v0,	4
	
	syscall 
	li 		$v0,	6
	syscall	
	mfc1	$t0,	$f0
	# 保存第一个浮点数的符号至s0
	srl		$s0,	$t0,	31
	# 保存第一个浮点数的指数至s1
	sll 	$s1,	$t0,	1
	srl		$s1,	$s1,	24
	# 保存第一个浮点数的尾数至s2
	sll		$s2,	$t0,	9
	srl		$s2,	$s2,	9
	# 尾数补前导位1 16进制数
	addi	$s2,	$s2,	0x00800000
	
	#  读入第二个浮点数
	la		$a0,	msg_sencond_val
	li		$v0,	4	
	syscall 
	
	li	 	$v0,	6
	syscall			
	mfc1	$t0,	$f0
	
	# 保存第二个浮点数的符号至s3
	srl		$s3,	$t0,	31
	# 保存第二个浮点数的指数至s4
	sll 	$s4,	$t0,	1
	srl		$s4,	$s4,	24
	# 保存第二个浮点数的尾数至s5
	sll		$s5,	$t0,	9
	srl		$s5,	$s5,	9
	# 尾数补前导位1 16进制数
	addi	$s5,	$s5,	0x00800000
	# 接收操作指令，加法是1，减法是2，乘法是3，除法是4
	lw		$ra,	20($sp)
	lw 		$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr		$ra
	
input_operator:
# 读入运算符
	addi	$sp,	$sp,	-32 
	sw	 	$ra,	20($sp)
	sw		$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw	 	$a0,	0($fp)
# 输入提示
	la		$a0,	msg_operator	
	li		$v0,	4	
	syscall 
# 读入
	li		$v0,	5
	syscall 
	move	$t1,	$v0
	# 若为1跳转到加法
	beq		$t1,	1,	begin_add
	# 若为2跳转到减法
	beq		$t1,	2,	begin_sub
	# 若为3跳转到乘法
	beq		$t1, 	3, 	multiply
	# 若为4跳转到除法
	beq		$t1, 	4, 	divide	
	
	# 其他的输入则提示输入错误，重新输入
	la		$a0,	msg_wrong_input
	li		$v0,	4	
	syscall 
	j		input_operator

begin_sub:
	xori   	$s3,     $s3,    0x00000001
	j		begin_add
	
begin_add:
	sub		$t0,	$s1,	$s4
	bltz	$t0,	adjust_first
	bgtz	$t0,	adjust_second
	beq		$t0,	$0,		sign_judge

adjust_first:
	addi	$s1,	$s1,	1
	srl		$s2,	$s2,	1
	j		begin_add
	
adjust_second:
	addi	$s4,	$s4,	1
	srl		$s5,	$s5,	1
	j		begin_add
sign_judge:
	xor		$t3,	$s0,	$s3
	beq		$t3,	0,		same_symbol
	beq		$t3,	1,		different_symbol
	
same_symbol:
	# 尾数放在t3,指数放在t2,符号放在t1
	add		$t3,	$s2,	$s5	
	move	$t2,	$s1
	move	$t1,	$s0
	bge		$t3,	0x01000000,	carry_in
	
	j		output
	
different_symbol:
	move	$t2,	$s1
	sub		$t3,	$s2,	$s5
	bltz	$t3,	second_big
	bgtz	$t3,	first_big
	beq		$t3,	$0,		output_zero
	
first_big:
	move	$t1,	$s0
	j 		adjust_sub
	
second_big:
	move	$t1,	$s3
	sub		$t3,	$s5,	$s2
	j 		adjust_sub
adjust_sub:
	blt		$t3,	0x00800000,	adjust_sub1
	j		output
adjust_sub1:
	beq		$t2,	0,	ERR_Underflow
	addi	$t2,	$t2,	-1
	sll		$t3,	$t3,	1
	blt		$t3,	0x00800000,	adjust_sub1
	j		output

carry_in:
	beq		$t2,	255,	ERR_Overflow
	srl		$t3,	$t3,	1
	addi	$t2,	$t2,	1
	j		output

# 乘法
# s0, s1, s2 为第一个操作数的符号、指数、尾数（含整数位1共24位）
# s3, s4, s5 为第二个操作数的符号、指数、尾数（含整数位1共24位）
# t1, t2, t3 为结果的符号、指数、尾数（含整数位1共24位）
multiply:
# 先判断有没有0，有0则直接输出0
	beq		$s1, 	0, 		multFirstExp0
	beq		$s4, 	0, 		multSecondExp0
	j		multNoZero
	multFirstExp0:
	beq		$s2, 	0x800000, multHasZero
	beq		$s4, 	0, 		multSecondExp0
	j		multNoZero
	multSecondExp0:
	beq		$s5, 	0x800000, multHasZero
	j		multNoZero
	multHasZero:
	li		$t1, 	0
	li		$t2, 	0
	li		$t3, 	0
	j		multiply_end

	multNoZero:

# 1. 指数相加 - bias
    add		$t2, 	$s1, 	$s4
    li		$t4, 	127
    sub	    $t2, 	$t2, 	$t4
# 2. 尾数相乘
# HI: 16位0, 2位整数部分, 14位小数部分
# LO: 32位小数剩余部分
# 想要 $t3 = 7位0, 2位整数部分, 23位小数部分，即HI的低16拼LO的高9位
# 即HI<<9 | LO>>23
    mult	$s2, 	$s5
    mfhi	$t3					# $t3 = floor($s2 / $s5) 
    mflo	$t4					# $t4 = $s2 mod $s5 
    sll     $t3, 	$t3, 	9
    srl     $t4, 	$t4, 	23
    or      $t3, 	$t3, 	$t4

# 3. Normalize
# 如果尾数 $t3 的第25位是1，则要Normalize，$t3右移一位，指数 $t2 += 1
# 1) $t4 = 第25位
    srl     $t4, 	$t3, 	24
# 2) if $t4 = 0 则跳过Normalize操作
    beq		$t4, 	$0, 	after_norm
# 3) 尾数 $t3 >> 1， $t2 += 1
    srl     $t3, 	$t3, 	1
    addi	$t2, 	$t2, 	1
after_norm:
# 4. Check overflow/ underflow
# 1) if 指数 $t2 < 0 : underflow
    slti    $t4, 	$t2, 	0
    beq		$t4, 	1, 		ERR_Underflow
# 2) if 指数 $t2 > 255: overflow
    li		$t4, 	255
    slt     $t4, 	$t4, 	$t2
    beq		$t4, 	1, 		ERR_Overflow
# 5. 符号位，同号为0，异号为1
    xor     $t1, 	$s0, 	$s3
# 6. 结束
    j		multiply_end
multiply_end:
	j		output
	
# 除法
# s0, s1, s2 为第一个操作数的符号、指数、尾数（含整数位1共24位）
# s3, s4, s5 为第二个操作数的符号、指数、尾数（含整数位1共24位）
# t1, t2, t3 为结果的符号、指数、尾数（含整数位1共24位）
divide:
# 先判断被除数是不是0，是0则直接输出0
	beq		$s1, 	0, 		divFirstExp0
	j		divNoZero
	divFirstExp0:
	beq		$s2, 	0x800000, divFirstZero
	j		divNoZero
	divFirstZero:
	li		$t1, 	0
	li		$t2, 	0
	li		$t3, 	0
	j		div_end

	divNoZero:

# 0. 检测若除数为0则报错
    bne		$s4, 	0, 		normal
    bne		$s5, 	0x800000, normal
    j		ERR_DivideByZero
normal: 
# 1. 指数相减 + bias
    sub		$t2, 	$s1, 	$s4
    addi	$t2, 	$t2, 	127
# 2. 确定符号，同号为正，异号为负
    xor     $t1, 	$s0, 	$s3
# 3. 尾数相除
# 1) 商为结果的整数部分，存在 $t3
    div		$s2, 	$s5
    mflo	$t3
    mfhi	$t4
# 如果商为0则直接结束
    beq		$t3, 	$0, 	div_end
# 4. Normalize
# 1) 商不断右移直到为0，以确定整数部分的位数 i ($t5)
    li		$t5, 	1
div_loop1:
    srlv    $t6, 	$t3, 	$t5
    bne		$t6, 	$0, 	div_loop1
# 2) 整数部分除去最高位的1以后还剩 i-1 位，i <- i-1
    li		$t6, 	1
    sub 	$t5, 	$t5, 	$t6
# 3) 指数部分 += i
    add		$t2, 	$t2,	$t5
# 5. Check overflow/ underflow
# 1) if 指数 $t2 < 0 : underflow
    slti    $t4, 	$t2, 	0
    beq		$t4, 	1, 		ERR_Underflow
# 2) if 指数 $t2 > 255: overflow
    li		$t4, 	255
    slt     $t4, 	$t4, 	$t2
    beq		$t4, 	1, 		ERR_Overflow
# 6. 小数部分还可再算 23-i 位
# 若余数不为零，则 余数不断左移，用新的余数替换（相当于余数减去除数），直到余数为0或左移了23-i ($t7)次
# 每次移位后的余数 除以 除数，商加在 $t3左移一位后的 最低位
    li		$t7, 	23
    sub		$t7, 	$t7, 	$t5
# 计数器 $t6
    li		$t6, 	0
div_loop2:
# 余数左移1位
    sll     $t4, 	$t4, 	1
    div		$t4, 	$s5
    mflo	$t8					# $t8 = floor($t4 / $s5)
    mfhi	$t4					# $t4 = $t4 mod $s5 
# $t3左移一位后商补在低位
    sll     $t3, 	$t3, 	1
    add		$t3, 	$t3, 	$t8
# 计数器自增
    addi	$t6, 	$t6, 	1
# 左移了23-i位则小数部分已满，已得到结果，直接结束
    beq		$t6, 	$t7, 	div_end
# 否则需要继续把 尾数$t3 左移，使小数部分补齐23位
    beq		$t4, 	$0, 	div_comp_dec
    j		div_loop2
div_comp_dec:
# 如果因为余数为0而退出循环需要把 尾数$t3 左移，直到计数器=23-i（即左移 (23-i) - $t6 位）
    sub		$t6, 	$t7, 	$t6
    sllv    $t3, 	$t3, 	$t6
div_end:
	j		output

ERR_DivideByZero:
    la		$a0,	msg_div_zero
	li		$v0,	4	
	syscall 
	j		exit

ERR_Overflow:
	la		$a0,	msg_over_flow
	li		$v0,	4	
	syscall 
	j		exit
ERR_Underflow:
	la		$a0,	msg_under_flow
	li		$v0,	4	
	syscall 
	j		exit
output_zero:
	move	$a0,	$0
	li		$v0,	1
	syscall
	j		exit
	
output:
			
  	# 打印结果
	# "Result:"
	li	 	$v0,	4
	la		$a0, 	msg_result_bin
	syscall 
	# 值
# 	# 二进制输出 ----------------------------------------------
	# 判断是不是 0
	beq		$t1, 	0, 		resBinExp0
	j		resBinNoZero
	resBinExp0:
	beq		$t2, 	0, 		resBinZero
	j		resBinNoZero
	resBinZero:
	la		$a0, 	string_0dot
	syscall
	# 尾数
	move 	$a1, 	$t3
	li		$a2, 	22
	jal		coutBits
	# "*2^"
	la		$a0, 	string_totwo
	syscall
	# t2
	move	$a0, 	$t2
	li		$v0, 	1
	syscall
	j		binEnd

	resBinNoZero:
	beq		$t1, 	0, 		skipBinNeg
	# "-"
	la		$a0, 	string_neg
	syscall
	skipBinNeg:
	# "1.
	la		$a0, 	string_1dot	
	syscall
	# 尾数
	move 	$a1, 	$t3
	li		$a2, 	22
	jal		coutBits
	# "*2^"
	la		$a0, 	string_totwo
	syscall
	# t2-127
	addi	$a0, 	$t2, 	-127
	li		$v0, 	1
	syscall
	j		binEnd

binEnd:
#   # 十六进制输出 -------------------------------------------
	# 1. "Hex:"
	li	 	$v0,	4
	la		$a0, 	msg_result_hex
	syscall 
	# 2. 十六进制结果
	# 判断是不是 0
	beq		$t1, 	0, 		resHexExp0
	j		resHexNoZero
	resHexExp0:
	beq		$t2, 	0, 		resHexZero
	j		resHexNoZero
	resHexZero:
	# 0.
	la		$a0, 	string_0dot
	syscall

	# "000000*16^0"
	la		$a0, 	string_hex0
	syscall
	j		hexOutEnd

	resHexNoZero:
	beq		$t1, 	0, 		skipHexoutNeg
	# "-"
	la		$a0, 	string_neg
	syscall
	
	skipHexoutNeg:
	addi	$t7, 	$t2, 	-127
	bltz	$t7, 	hexoutLess
	# if (t7 >= 0)
	andi    $t4, 	$t7, 	0x3     		# $t4 = $t7 mod 4
	srl     $t5, 	$t7, 	2      			# $t5 = $t7 / 4
	j		hexFinal

	hexoutLess:
	# else
	li		$t4, 	0
	move 	$t6, 	$7

	hexoutLoop:
	andi    $t7, 	$t6, 	0x3     		# $t7 = $t6 mod 4
	beq		$t7, 	0, 		hexoutLoopEnd
	addi	$t6, 	$t6, 	-1
	addi	$t4, 	$t4, 	1
	j		hexoutLoop
	
	hexoutLoopEnd:
	srl     $t5, 	$t6, 	2      			# $t5 = $t6 / 4

	hexFinal:
	li		$t7, 	23
	sub		$t6, 	$t7, 	$t4
	srlv    $t6, 	$t3, 	$t6
	
	# 输出小数点前部分
	move 	$a0, 	$t6
	li		$a1, 	0
	jal		toHex
	
	# "."
	li	 	$v0,	4
	la		$a0, 	string_dot		
	syscall

	addi	$t6, 	$t4, 	9
	sllv    $t6, 	$t3, 	$t6
	# 输出尾数
	move 	$a0, 	$t6
	li		$a1, 	1
	jal		toHex
	
	# "*16^"
	li	 	$v0,	4
	la		$a0, 	string_to16
	syscall

	# 输出t5
	li		$v0, 	1
	move 	$a0, 	$t5
	syscall
	
	hexOutEnd:
	# 两个换行
	li		$v0, 	11
	li		$a0, 	'\n'
	syscall
	syscall

	# 3. jr
	lw		$ra,	20($sp)
	lw 		$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr		$ra

# ---------------------------------------------------
# void coutBits(a1 content, a2 startIndex)
coutBits: # 要显示的内容存在a1，从第a2位（0开始）开始输出
    addi	$sp,	$sp,	-32
    sw		$t1,    28($sp)
    sw		$t6,    24($sp)
    sw	 	$ra,	20($sp)
    sw		$fp,	16($sp)
    addiu 	$fp,	$sp,	28
    
    move 	$t6,    $a2
    li      $v0,    4

	shiftLoop:  
    srlv    $t1,    $a1,    $t6
    andi    $t1,    $t1,    0x1
    beqz    $t1,    is0
    j       is1
    is0:        
    la      $a0,    string_0
    j       printBin
    is1:        
    la      $a0,    string_1
    j       printBin
    
    printBin:   
    syscall

    addi    $t6,    $t6,    -1
    bgez    $t6,    shiftLoop
    
    # return
    lw		$t1,    28($sp)
    lw		$t6,    24($sp)		
    lw		$ra,	20($sp)
    lw 		$fp,	16($sp)
    addiu 	$sp,	$sp,	32
    jr      $ra
# -----------------------------------------
# void toHex(a0 content, a1 flag)
toHex: # a0为要输出的数，a1 = 0 时，输出3:0，否则输出31:8
    bne		$a1,    0,      high
    low: # 输出3:0
    andi    $a0,    $a0,   0xf     			# $a0 = $a0低4位
    lb		$a0,    hex_table($a0)
    # 输出
    li		$v0,    11
    
    j		toHexEnd

    high: # 输出31:8
    # 初始化
    srl     $a0,    $a0,    8      			# $a0 = $a0 >> 8
    li		$t9,    5
    
    toHexLoop:
    andi    $t7,    $a0,    0xf     		# $t7 = $a0低4位
    lb		$t8,    hex_table($t7)
    sb		$t8,    hex_digits($t9)
    sub		$t9,    $t9,    1
    srl     $a0,    $a0,    4
    bgez	$t9,    toHexLoop
    
    la		$a0,    hex_digits

    # 输出结果
    li		$v0,    4

    toHexEnd:
    syscall
    jr		$ra
# -----------------------------------------

exit:
	li		$v0,	10
	syscall