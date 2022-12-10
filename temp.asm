################# temp.asm ##################################
################# Daniel Kogan ##################################
################# 11.15.2022 ##################################

########################################################################################################
## TODO:delete before submitting ############################################################################
########################################################################################################

.globl add_person_3
add_person_3:
  # inputs: a0=network, a1=name1, a2=name2 a3=ans_buffer
  # expected outputs: v0 = a0, v1 = -1
  addi $sp, $sp, -8
  sw $ra, 4($sp)
  jal add_person # should be successful
  # sw $v0, 0($sp)
  sw $v0, 0($a3)
  sw $v1, 4($a3)
  move $a1, $a2
  jal add_person
  # lw $v0, 0($sp)
  sw $v0, 8($a3)
  sw $v1, 12($a3)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  jr $ra


.macro nextName (%namebuffer) 
  nextNameMacroTest:
    lbu $t0, 0(%namebuffer)
    beqz $t0, end_nameMacroTest
    addi %namebuffer, %namebuffer, 1
    j nextNameMacroTest
  end_nameMacroTest:
  addi %namebuffer, %namebuffer, 2
.end_macro

.macro returnResult2Buffer (%buffer)
  # sw $a1, 0(%buffer)
  # addi %buffer, %buffer, 4
  sw $v0, 0(%buffer)
  addi %buffer, %buffer, 4
  sw $v1, 0(%buffer)
  addi %buffer, %buffer, 4
.end_macro

.globl add_person_4
add_person_4:
  # inputs: a0=network, a1=name_buffer, a2=ans_buffer
  # expected outputs: v0 = a0, v1 = -1
  addi $sp, $sp, -8
  sw $ra, 4($sp)
  jal add_person # should be successful
  returnResult2Buffer($a2)
  li $t9, 5
  add_person_4_testing_loop_add_new_people:
    nextName($a1)
    jal add_person # should be successful
    returnResult2Buffer($a2)
    beqz $t9, end_add_person_4_789238462387492367985327984527
    addi $t9, $t9, -1
    j add_person_4_testing_loop_add_new_people
  end_add_person_4_789238462387492367985327984527:
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  jr $ra


.globl get_person_1
get_person_1:
  # inputs: a0=network, a1=name1
  # expected outputs: v0 = name1_node, v1 = 1
  addi $sp, $sp, -8
  sw $ra, 4($sp)
  jal add_person # should be successful
  jal get_person
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  jr $ra

.globl add_relationship_1
add_relationship_1:
  # inputs: a0=network, a1=name_buffer, a2=relation_type, a3=ans_buffer
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  jal add_person # should be successful
  returnResult2Buffer($a3)  
  move $t9, $a1
  nextName($a1)
  jal add_person # should be successful
  returnResult2Buffer($a3)
  # now there are two nodes in the network
  addi $sp, $sp, -12
  sw $a1, 0($sp)  
  sw $a2, 4($sp)
  sw $a3, 8($sp)
  move $a3, $a2
  move $a2, $a1
  move $a1, $t9
  # inputs: a0=network a1=name1 a2=name2 a3=type
  jal add_relation
  lw $a1, 0($sp)  
  lw $a2, 4($sp)
  lw $a3, 8($sp)
  returnResult2Buffer($a3)
  addi $sp, $sp, 12
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra


.globl add_relationship_2
add_relationship_2:
  # inputs: a0=network, a1=name_buffer, a2=relation_type, a3=ans_buffer
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  jal add_person # should be successful
  returnResult2Buffer($a3)  
  move $t9, $a1
  nextName($a1)
  jal add_person # should be successful
  returnResult2Buffer($a3)
  # now there are two nodes in the network
  addi $sp, $sp, -12
  sw $a1, 0($sp)  
  sw $a2, 4($sp)
  sw $a3, 8($sp)
  move $a3, $a2
  move $t8, $a3
  move $a2, $a1
  move $a1, $t9
  # inputs: a0=network a1=name1 a2=name2 a3=type
  jal add_relation
  lw $a3, 8($sp)
  returnResult2Buffer($a3)
  sw $a3  8($sp)
  move $a3, $t8
  jal add_relation
  lw $a1, 0($sp)  
  lw $a2, 4($sp)
  lw $a3, 8($sp)
  # addi $a3, $a3, 8
  returnResult2Buffer($a3)
  addi $sp, $sp, 12
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

.globl add_relationship_3
add_relationship_3:
  # inputs: a0=network, a1=name_buffer, a2=relation_type, a3=ans_buffer
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  jal add_person # should be successful
  returnResult2Buffer($a3)  
  move $t9, $a1
  nextName($a1)
  jal add_person # should be successful
  returnResult2Buffer($a3)
  nextName($a1)
  # now there are two nodes in the network
  addi $sp, $sp, -12
  sw $a1, 0($sp)  
  sw $a2, 4($sp)
  sw $a3, 8($sp)
  move $a3, $a2
  move $t8, $a3
  move $a2, $a1
  move $a1, $t9
  # inputs: a0=network a1=name1 a2=name2 a3=type
  jal add_relation
  lw $a1, 0($sp)  
  lw $a2, 4($sp)
  lw $a3, 8($sp)
  # addi $a3, $a3, 8
  returnResult2Buffer($a3)
  addi $sp, $sp, 12
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

# .data
# Name1: .asciiz "Elizabeth"
# Name2: .asciiz "Joey"
# Name3: .asciiz "Demetrius"
# Name4: .asciiz "Constable Jeffrey"
# Name5: .asciiz "Stanislav"
# Name6: .asciiz "Bethany"

.text
.macro addPersonTest(%label)
  addi $sp, $sp, -12
  sw $ra, 0($sp)
  sw $a1, 4($sp)
  la $a1, %label
  jal add_person
  lw $ra, 0($sp)
  lw $a1, 4($sp)
  returnResult2Buffer($a2)  
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
  returnResult2Buffer($a2)  
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
  returnResult2Buffer($a2)  
  addi $sp, $sp, 12
.end_macro


.globl get_distant_friends_1
get_distant_friends_1:
  # inputs: a0=network, a1=name_buffer, a2=ans_buffer
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  addPersonTest(Name1)
  addPersonTest(Name2)
  addPersonTest(Name3)
  addPersonTest(Name4)
  addPersonTest(Name5)

  addRelationTest(Name1, Name2,2)
  addRelationTest(Name3, Name2,1)
  addRelationTest(Name1, Name4,2)
  addRelationTest(Name5, Name4,2)
  addRelationTest(Name1, Name3,2)

  getDistantFriendsTest(Name1)
  addi $sp, $sp, 4
  jr $ra
