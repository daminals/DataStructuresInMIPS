
############################ CHANGE THIS FILE AS YOU DEEM FIT ############################
############################ Add more names if needed ####################################

.data

Name1: .asciiz "Jane"
Name2: .asciiz "Joey"
Name3: .asciiz "Alit"
Name4: .asciiz "Veen"
Name5: .asciiz "Stan"
Name6: .asciiz "Bethany"
test: .asciiz "llj"
test2: .asciiz "llj"

Buffer:
    .asciiz "Bethany"	# num rows
    .asciiz "Alonzo"	# num columns
    # matrix
    # .word 12 3 24 45 6 17 7 8 9 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

ansBuffer:
    .word 0	# num rows
    .word 0	# num columns
    # matrix
    .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0


I: .word 5
J: .word 10

.text
.macro addPersonTest(%label)
  addi $sp, $sp, -12
  sw $ra, 0($sp)
  sw $a1, 4($sp)
  la $a1, %label
  jal add_person
  lw $ra, 0($sp)
  lw $a1, 4($sp)
  addi $sp, $sp, 12
.end_macro

.macro addRelationTest(%label1, %label2, %reltype)
  #a0=network a1=name1 a2=name2 a3=relation-type
  addi $sp, $sp, -16
  sw $ra, 0($sp)
  sw $a1, 4($sp)
  sw $a2, 8($sp)
  sw $a3, 12($sp)

  la $a1, %label1
  la $a2, %label2
  li $a3, 2
  jal add_relation

  lw $ra, 0($sp)
  lw $a1, 4($sp)
  lw $a2, 8($sp)
  lw $a3, 12($sp)
  addi $sp, $sp, 16
.end_macro

.macro getDistantFriendsTest(%label)
  addi $sp, $sp, -12
  sw $ra, 0($sp)
  sw $a1, 4($sp)
  la $a1, %label
  jal get_distant_friends
  lw $ra, 0($sp)
  lw $a1, 4($sp)
  addi $sp, $sp, 12
.end_macro


main:
    lw $a0, I
    lw $a1, J
    jal create_network
    add $s0, $v0, $0		# network address in heap

    add $a0, $0, $s0		# pass network address to add_person
    #la $a1, Name6
    
  #addPersonTest(Name1)
 # addPersonTest(Name2)
  ###addPersonTest(Name3)
#  addPersonTest(Name4)
 # addPersonTest(Name5)

  #addRelationTest(Name1, Name2,2)
  #addRelationTest(Name3, Name2,1)
  #addRelationTest(Name1, Name4,2)
  #addRelationTest(Name5, Name4,2)
  #addRelationTest(Name1, Name3,2)

	
   #getDistantFriendsTest(Name2)
    
    
    #j exit


    #jal get_person_1
    #j exit
    
    #la $a1, Name2
    #la $a2, Name2
    #jal add_person_3
    
    
    la $a1, test 
    jal add_person # add one person
    #jal get_person
    #move $s1, $v0
    la $a1, test2
    jal add_person
    
    la $a1, test2
    jal get_person
    #j exit
    
    
    la $a1, Name1 # add two
    jal add_person
    #jal get_person
    #move $s2, $v0

    #move $a0, $s0
    #la $a1, Buffer
    #li $a2, 2
    #la $a3, ansBuffer
    #jal add_relationship_1
    
    move $a0, $s0
    la $a1, Name1
    la $a2, test
    li $a3, 1

    jal add_relation
    jal add_relation
    #j exit
    
    move $a0, $s0
    la $a1, Name2 # add three
    jal add_person    
    
    la $a1, Name2
    jal add_person # fail 
    la $a1, Name2 
    jal add_person # fail  
    la $a1, Name2 
    jal add_person # fail
    
    la $a1, Name3 # add four
    jal add_person
    la $a1, Name3 # find name 3
    jal get_person
    la $a1, Name4 # find name 4
    jal get_person # should return -1
    
    la $a1, Name4 # add five
    jal add_person   
    
    la $a1, Name1
    la $a2, Name4
    li $a3, 1
    jal add_relation
    
    la $a1, Name2
    la $a2, Name4
    li $a3, 1
    jal add_relation # why fail
    
    la $a1, Name2
    la $a2, Name3
    li $a3, 1
    jal add_relation #
    
    la $a1, Name3
    la $a2, Name1
    li $a3, 1
    jal add_relation
    
    la $a1, Name5 # add six. should fail
    jal add_person

    # name4 -> name1 -> name3 -> name2
    #                            name2 -> name4 # not distant
    
    la $a1, Name4
    jal get_distant_friends
    
    #write test code
    


exit:
    li $v0, 10
    syscall
.include "hw4.asm"
