########### Andrew Kwan ############
########### ankwan ################
########### 113360963 ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
#PART 1
.globl hash
hash:
  li $v0, 0 # initialize the sum of the ascii values of the string to be returned
  li $t1, 0x20 # Value of a space 
  whileHash:
  lb $t0, 0($a0) # loads first character of the string stored into $a0
  beqz $t0, doneHash # exit condition
  beq $t0, $t1, space #calculates space value
  #addi $t0, $t0, 96 # convert to ascii value
  add $v0, $v0, $t0 # updates the sum with the ascii of the first character
  addi $a0, $a0, 1 # increment str address
  j whileHash
  
  space:
  addi $v0, $v0, 32 # 32 is ascii value of space
  addi $a0, $a0, 1 # increment address
  j whileHash
doneHash:  
  jr $ra

# PART 2 
.globl isPrime
isPrime:
  li $t0, 2 # counter to increment up to integer n 
  whilePrime:
  beq $a0, $t0, prime # if the numbers are equal then it hasn't reached a remainder of zero
  div $a0, $t0 # $a0/$t0 quotient stored in mflo, remainder stored in mfhi
  mfhi $t1 # stores remainder into this register
  beqz $t1, composite # if remainder is 0, integer is composite
  addi $t0, $t0, 1 #increment divisor
  j whilePrime
  
  prime:
  li $v0, 1 # returns 1 if the number is prime
  j donePrime
  
  composite:
  li $v0, 0 # returns 0 if the number is composite
  j donePrime
  
donePrime:
  jr $ra

#PART 3
.globl lcm
lcm:
  # a*b/(gcd(a,b))
  mul $t0, $a0, $a1 #multiplication
  
  addi $sp, $sp, -8 #move stack pointer to save ra
  sw $ra, 0($sp)
  sw $t0, 4($sp)
  
  jal gcd
  
  lw $t0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 8 # fix the stack pointer to what it was before
  
  move $t1, $v0 # v0 is the GCD from the GCD function
  div $t0,$t1 # division
  mflo $t2 #quotient
  move $v0, $t2
  jr $ra

#PART 4
.globl gcd
gcd:
  move $t0, $a0 # copies number a0 to t0
  move $t1, $a1 # copies number a1 to t1
whileGCD:
  beq $t0, $t1, doneGCD # if both a0 and a1 are equal to each other GCD has been found
  blt $t0, $t1, firstLess # if t0<t1 branch
  sub $t0, $t0, $t1 # t0-=t1
  j whileGCD
firstLess:
  sub $t1, $t1, $t0 # t1-=t0
  j whileGCD
  
doneGCD:
  move $v0, $t1 # since both t0 and t1 are equal it doesn't matter which one i choose
  jr $ra

# PART 5 
.globl pubkExp
pubkExp:
  move $t0, $a0 # copy integer z onto t0
  
generate:
  addi $sp, $sp, -8 #move stack pointer to save ra and $a0 the original z int
  sw $ra, 0($sp)
  sw $a0, 4($sp)
  addi $t1, $t0, -2 # upper bound = a0 - 1
  move $a1, $t1 # upper bound for random
  li $v0, 42 # service number for random range (Stores the random value in 100)
  syscall 
  #li $a0, 0 #reset a0 here
  addi $a0, $a0, 2 # Adjust for [2,a0)
  lw $a1, 4($sp)    
  jal gcd
  
  move $t0, $a0 # Save random number into $t0
  lw $a0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 8 # fix the stack pointer to what it was before
  
whilepubExp:
  li $t3, 1 # check if z and r are co prime if not generate a random one again til it is
  beq $v0, $t3, donepubExp
  j generate
  
  
donepubExp:
  move $v0, $t0
  #li $v0, 13
  jr $ra

.globl prikExp
prikExp:
  addi $sp, $sp, -4 #move stack pointer to save ra and save gcd into $t0
  sw $ra, 0($sp)
  
  jal gcd
  
  lw $ra, 0($sp)
  addi $sp, $sp, 4 # fix the stack pointer to what it was before
  
  
  addi $sp, $sp, -12
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  
  li $t1, 1 # compare gcd in t0 to t1 to make sure it is 1
  bne $t0, $t1, donePrikExpErr # this means GCD is not 1 so a0 and a1 are composite
  
  #EUCLIDIAN FORMULA first 2 steps
  #step 0 
  move $t0, $a1 # moves int y to t0 (Y IS GREATER)
  move $t2, $a0 # moves int x to t2 
  # li $t1, 1 
  # mul $t2, $t0, $t1 # from exmaple 1*15
  div $a1, $a0 # y/x to get remainder  
  mflo $t1 # move quotient to t1 (1)
  mfhi $t3 # move remainder to t3 (11)
  move $t4, $t1 # copy t1 to t4 (q0)  
    
  #step 1
  move $t0, $t2 # move t2 to t0 
  move $t2, $t3 # move t3 to t2
  div $t0, $t2 
  mflo $t1 # quotient
  mfhi $t3 #remainder
  move $t5, $t1 # copy t1 to t5 (q1)
  
  #step 2
  move $t0, $t2 # move t2 to t0 
  move $t2, $t3 # move t3 to t2
  div $t0, $t2 
  mflo $t1 # quotient
  mfhi $t3 #remainder
  move $t6, $t1 # copy t1 to t5 (q2)
  
  li $s0, 0 # p0 (USE THIS TO UPDATE NEW Pi values)
  li $s1, 1 # p1 
  
  # finding p2 
  mul $s2, $s1, $t4 # (pi-1 * qi-2)
  sub $s2, $s0, $s2 # (pi-2 - $s2)
  
  #s2 mod a1
  div $s2, $a1 	
  mfhi $t7 # s2 % a1
  add $t7, $t7, $a1 # t7 + a1
  div $t7, $a1 # last step t7 % a1
  mfhi $s2 # p2 
  
EEAloop: # while loop to calculate extended euclidian algorithm 
# pi = (pi-2 - pi-1 * qi-2) (mod y) 
# for the first 2 steps p0 =0 and p1=1 ^^^
  
  move $t4, $t5 # copy t5 to t4
  move $t5, $t6 # copy t6 to t5
  
  move $t0, $t2 # move t2 to t0 
  move $t2, $t3 # move t3 to t2
  div $t0, $t2 
  mflo $t1 # quotient
  mfhi $t3 #remainder
  move $t6, $t1 # copy t1 to t5 (q2)
  
  beqz $t3, donePrikExp # loop exits when the remainder is 0 
  j auxValue
  
auxValue:
  move $s0, $s1 # copy s1 to s0
  move $s1, $s2 # copy s2 to s1 
  #s2 will be recalculated and set below
  mul $s2, $s1, $t4 # (pi-1 * qi-2)
  sub $s2, $s0, $s2 # (pi-2 - $s2)
  j mod

mod:
  # (s2 % a1 + a1)%a1
  div $s2, $a1 	
  mfhi $t7 # s2 % a1
  add $t7, $t7, $a1 # t7 + a1
  div $t7, $a1 # last step t7 % a1
  mfhi $v0 
  move $s2, $v0
  j EEAloop

donePrikExp:
  #CALCULATE AUXILARY P VALUE ONE MORE TIME
  move $s0, $s1 # copy s1 to s0
  move $s1, $s2 # copy s2 to s1 
  #s2 will be recalculated and set below
  mul $s2, $s1, $t4 # (pi-1 * qi-2)
  sub $s2, $s0, $s2 # (pi-2 - $s2)
  
  # (s2 % a1 + a1)%a1
  div $s2, $a1 	
  mfhi $t7 # s2 % a1
  add $t7, $t7, $a1 # t7 + a1
  div $t7, $a1 # last step t7 % a1
  mfhi $v0
  move $s2, $v0

  move $s0, $s1 # copy s1 to s0
  move $s1, $s2 # copy s2 to s1 
  move $t4, $t5 # copy t5 to t4
  #s2 will be recalculated and set below
  mul $s2, $s1, $t4 # (pi-1 * qi-2)
  sub $s2, $s0, $s2 # (pi-2 - $s2)
  
  # (s2 % a1 + a1)%a1
  div $s2, $a1 	
  mfhi $t7 # s2 % a1
  add $t7, $t7, $a1 # t7 + a1
  div $t7, $a1 # last step t7 % a1
  mfhi $v0
  move $s2, $v0
  
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  addi $sp, $sp, 12
  
  jr $ra
  
donePrikExpErr:
  #CALCULATE AUXILARY P VALUE ONE MORE TIME
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  addi $sp, $sp, 12
  
  li $v0, -1 # return -1 if a0 and a1 are composite
  jr $ra

.globl encrypt
encrypt:
  move $t8, $a0 # t8 = m
  
  addi $sp, $sp, -12
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  
  move $s0, $a0
  move $s1, $a1
  move $s2, $a2
  
  #FIRST CHECK IF INTS P AND Q ARE PRIME VALUE IS STORED IN V0
  addi $sp, $sp, -4 #move stack pointer to save ra and save gcd into $t0
  sw $ra, 0($sp)
  
  move $a0, $s1
  jal isPrime
  
  lw $ra, 0($sp)
  addi $sp, $sp, 4 # fix the stack pointer to what it was befor
  
  li $t0, 1
  bne $v0, $t0, encryptError # if 0 then not a prime number
  
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  move $a0, $s2
  jal isPrime
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  li $t0, 1
  bne $v0, $t0, encryptError
  
  move $t0, $a1 # int p 
  move $t1, $a2 # int q
  mul $t4, $a1, $a2 # n = p*q
  ble $t4, $t8, encryptError # jump if n <= m
  
  addi $a0, $a1, -1
  addi $a1, $a2, -1

  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal lcm
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  
  move $a0, $v0
  
  #modular exponentiation c = m^e (mod n)
  addi $sp, $sp, -4 #move stack pointer to save ra and save gcd into $t0
  sw $ra, 0($sp)
  
  jal pubkExp
  
  move $v1, $v0 #pub key into v1 which is e 
  lw $ra, 0($sp)
  addi $sp, $sp, 4 # fix the stack pointer to what it was before
  
  li $t1, 1 # c 
  li $t2, 0 # e' counter
  #repeat c = (c*m)mod n 'e' times
exponentiation:
  addi $t2, $t2, 1 # inccrement e' by 1
  
  mul $t3, $t1, $t8 # c*m
  div $t3, $t4 # t3 mod n(t4)
  mfhi $t5 
  move $t1, $t5 # update c 
  
  beq $t2, $v1, doneEncrypt
  j exponentiation
  
encryptError:
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  addi $sp, $sp, 12
  li $v0, 10
  syscall
doneEncrypt:
  
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  addi $sp, $sp, 12

  move $v0, $t1 # modular exponentiation move to v0
  jr $ra

.globl decrypt
decrypt:
  addi $sp, $sp, -16
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  sw $s3, 12($sp)
  move $s0, $a0 # SAVE EVERY ARGUMENT INTO SREGISTERS FIRST<3
  move $s1, $a1
  move $s2, $a2
  move $s3, $a3 
  
  addi $a0, $a2, -1 #p-1
  addi $a1, $a3, -1 #q-1 
  
  # CALCULATE Y = LCM(P-1,Q-1)
  addi $sp, $sp, -4 #move stack pointer to save ra and save gcd into $t0
  sw $ra, 0($sp)
  jal lcm
  lw $ra, 0($sp)
  addi $sp, $sp, 4 # fix the stack pointer to what it was before
  
  move $a0, $s1 
  move $a1, $v0 # move lcm into a1
  
  # GET THE PRIVATE KEY
  addi $sp, $sp, -4 #move stack pointer to save ra and save gcd into $t0
  sw $ra, 0($sp)
  
  jal prikExp
   
  lw $ra, 0($sp)
  addi $sp, $sp, 4 # fix the stack pointer to what it was before
  
  move $t7, $v0 #PRIV KEY INTO T7 DON'T FUCKING CHANGE THIS
  
  move $a0, $s0 #REMOVE EVERYTHING BACK 
  move $a1, $s1 
  move $a2, $s2
  move $a3, $s3
  
  move $t0, $s2 # int p 
  move $t1, $s3 # int q
  mul $t2, $t0, $t1 # n = p*q
  
  #MODULAR EXPONENTIATIOIN
  # m = c^d (mod n) (d IS PRIVATE KEY FROM ENCRYPT DON'T CHANGE T7)
  # DON'T CHANGE T2 WHICH IS N 
  li $t0, 1 # c 
  li $t1, 0 # d' counter
  #repeat m = (m*c)mod n 'd' times
exponentiation8:
  beq $t1, $t7, doneDecrypt # when counter t1 is equal to priv key t7
  
  mul $t3, $t0, $s0 # m*c
  div $t3, $t2 # t3 mod n(t2)
  mfhi $t5 
  move $t0, $t5 # update c 
  addi $t1, $t1, 1 # inccrement d' by 1
  

  j exponentiation8
  
doneDecrypt:
  move $v0, $t0
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)
  addi $sp, $sp, 16
  jr $ra
  

