################# hw4.asm ##################################
################# Daniel Kogan ##################################
################# 11.12.2022 ##################################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

.macro isStringEqual (%a, %b)
  addi $sp, $sp, -16 # IS STRING EQUAL
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw %a, 8($sp)
  sw %b 12($sp)
  isStringEqualMacroLoop:
    lbu $t0, 0(%a)
    lbu $t1, 0(%b)
    bne $t0, $t1, notStringEqualMacro
    beqz $t0, yesStringEqualMacro
    addi %a, %a, 1
    addi %b, %b, 1
    j isStringEqualMacroLoop
  notStringEqualMacro:
    li $v0, -1
    j end_StringEqualMacro
  yesStringEqualMacro:
    li $v0, 1
  end_StringEqualMacro:
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw %a, 8($sp)
  lw %b 12($sp)
  addi $sp, $sp, 16 # IS STRING EQUAL END
.end_macro

.macro isNodeEqual(%node1, %node2)
  bne %node1, %node2, no_isNodeEqual
  yes_isNodeEqual:
    li $v0, 1
    j endisNodeEqual
  no_isNodeEqual:
    li $v0, -1
  endisNodeEqual:
.end_macro

.macro countChars (%a)
  addi $sp, $sp, -8 # COUNT CHARS
  sw %a, 0($sp)
  sw $t0, 4($sp)
  li $v0, 0
  countCharsLoop:
    lbu $t0, 0(%a)
    beqz $t0, end_countCharsLoopMacro
    addi %a, %a, 1
    addi $v0, $v0, 1
    j countCharsLoop
  end_countCharsLoopMacro:
  lw %a, 0($sp)
  lw $t0, 4($sp)
  addi $sp, $sp, 8 # CHAR COUNT END
.end_macro

.macro allocateHeapSpace(%a)
  addi $sp, $sp, -4 # ALLOCATE HEAP SPACE
  sw $a0, 0($sp)
  li $v0, 9
  move $a0, %a 
  syscall
  lw $a0, 0($sp)
  addi $sp, $sp, 4 # END ALLOCATE HEAP SPACE END
.end_macro

.macro createEdge(%node1, %node2, %relation)
  addi $sp, $sp, -4 # CREATE EDGE
  sw $a0, 0($sp)
  li $a0, 12
  allocateHeapSpace ($a0)
  # li $v0, 9
  # syscall
  sw %node1, 0($v0)
  sw %node2, 4($v0)
  sw %relation, 8($v0)
  # return location in v0  
  lw $a0, 0($sp)
  addi $sp, $sp, 4 # END CREATE EDGE
.end_macro

.macro createFriendNode(%node, %next)
  addi $sp, $sp, -20 # CREATE FRIEND NODE
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $s0, 8($sp)
  sw $t2, 12($sp)
  ########################################
  # li $t0, 5 # add 0 for null value
  lw $t1, 0(%node) # 3
  move $s0, %node
  addi $s0, $s0, 4
  addi $t1, $t1, 1 # add 1 char for \0 | 4
  # lw $s0, 4(%node)
  # beqz $s0, leave_createFriendNode_loop_save_name
  # add $t2, $t0, $t1
  li $t0, 4
  div $t1, $t0 # 4/4 = 0
  mfhi $t2 # 0
  sub $t2, $t0, $t2 # 4-0
  beq $t2, $t0, skip_add_4
  addi $t0, $t0, 4
  skip_add_4:
  add $t0, $t2, $t0 # 4+4 = 8
  allocateHeapSpace($t0)
  sw $v0, 16($sp)
  createFriendNode_loop_save_name:
    beqz $t2, leave_createFriendNode_loop_save_name # loop thru chars
    lbu $t2, 0($s0)
    sb $t2, 0($v0)
    addi $s0, $s0, 1
    addi $v0, $v0, 1
    j createFriendNode_loop_save_name
  leave_createFriendNode_loop_save_name:
  li $t0, 4
  div $v0, $t0
  mfhi $t2
  sub $t2, $t0, $t2
  beq $t2, $t0, skip_add_4_second_time
  add $v0, $t2, $v0
  skip_add_4_second_time:
  sw %next 0($v0)

  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $s0, 8($sp)
  lw $t2, 12($sp)
  lw $v0, 16($sp)
  addi $sp, $sp, 20 # END CREATE FRIEND NODE
.end_macro

.macro friendNodeSetNext(%friendnode, %next)
  addi $sp, $sp, -20 # FRIENDNODE SET NEXT
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)
  ########################################
  move $t0, %friendnode
  loop_friendNodeSetNext_zero:
    lbu $t2, 0($t0)
    addi $t0, $t0, 1
    beqz $t2, escape_loopGetFriends_set_not_zero
    j loop_friendNodeSetNext_zero
  escape_loopGetFriends_set_not_zero:
  li $t1, 4
  div $t0, $t1
  mfhi $t2
  sub $t2, $t1, $t2
  add $t0, $t2, $t0
  sw %next 0($t0)
  ###########################
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  addi $sp, $sp, 20 # END FRIEND NODE SET NEXT
.end_macro

.macro get_person_macro(%name)
  addi $sp, $sp, -16 # GET PERSON MACRO
  sw $a1, 0($sp)
  sw $a2, 4($sp)
  sw $a3, 8($sp)
  sw $ra, 12($sp)
  move $a1, %name
  jal get_person
  # lw $a1, 0($v0)
  # move $v0, $a1
  lw $a1, 0($sp)
  lw $a2, 4($sp)
  lw $a3, 8($sp)
  lw $ra, 12($sp)
  addi $sp, $sp, 16 # END GET PERSON MACRO
.end_macro

.macro writeCharsToAddress (%address, %charlist, %length)
  li $v0, 0 # WRITE CHARS TO ADDRESS
  addi $sp, $sp, -16
  sw $t0, 0($sp)
  sw %address, 4($sp)
  sw %charlist, 8($sp)
  sw %length, 12($sp)
  writeCharsToAddressMacro:
    addi %length, %length, -1
    addi $v0, $v0, 1
    lbu $t0, 0(%charlist)
    sb $t0, 0(%address)
    addi %charlist, %charlist, 1
    addi %address, %address, 1
    beqz %length, end_writeCharsToAddressMacro
    j writeCharsToAddressMacro
  end_writeCharsToAddressMacro:
  # addi %address, %address, 1
  sb $0, 1(%address)
  ##########################
  lw %address, 4($sp)
  lw %charlist, 8($sp)
  lw %length, 12($sp)  
  lw $t0, 0($sp)
  ############################
  addi $sp, $sp, 16 # END WRITE CHAR TO ADDRESS
.end_macro

.macro stringEqualNode(%node, %str)
  # node = len, chars[]
  addi $sp, $sp, -8 # STRING EQUAL NODE
  sw %node, 0($sp)
  sw $t0, 4($sp)
  # lw $t0, 0(%node) # count
  addi %node, %node, 4
  isStringEqual(%str, %node)
  lw %node, 0($sp)
  lw $t0, 4($sp)
  addi $sp, $sp, 8 # END STRING EQUAL NODE MACRO
.end_macro

.macro doesEdgeExist(%network, %node1, %node2)
  # addi %network, %network, 0
  addi $sp, $sp, -12 # # DOES EDGE EXIST MACRO
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)
  sw $t4, 12($sp)
  add %node1, %node1, $0 # name1
  add %node2, %node2, $0 # name2

  jumpToEdgeStart(%network)
  lw $t0, 12(%network) # current num of edges
  loop_thru_current_edges_add_relation_m:
    beqz $t0, node_does_not_exist_get_relation_m
    lw $t1, 0($t2) # get current edge in t1
    isEdgeEqualandFriend($t1, %node1, %node2) # edge, name1, name2
    bgtz $v0, end_macro_doesEdgeExist # node is equal
    addi $t2, $t2, 4 # next edge
    addi $t0, $t0, -1
  j loop_thru_current_edges_add_relation_m
  ##############################################
  node_does_not_exist_get_relation_m:
  li $v0, -1 
  end_macro_doesEdgeExist:
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  lw $t4, 12($sp)
  addi $sp, $sp, 12 # END DOES EDGE EXIST
.end_macro

.macro isEdgeEqual(%edge, %name1, %name2)
  # edge is a reference to an edge
  addi $sp, $sp, -8 # IS EDGE EQUAL
  sw $t3, 0($sp)
  sw $t4, 4($sp)
  # begin program
  lw $t3, 0(%edge) # edge node1
  lw $t4, 4(%edge) # edge node2
  # is node1 equal to name1
  stringEqualNode($t3, %name1)
  bgtz $v0, checkNodeTwoinEdgeEqualMacro
  # else, check if name1 is flipped
  stringEqualNode($t3, %name2)
  bltz $v0, endEdgeEqualMacro # if name1 isnt node1 or node2, not equal
  j checkNodeTwoinEdgeEqualMacro_ifName2
  checkNodeTwoinEdgeEqualMacro:
  # if node1=name1, node2 must equal name2
  stringEqualNode($t4, %name2)
  j endEdgeEqualMacro # if name1 isnt node1 or node2, not equal. return ans
  checkNodeTwoinEdgeEqualMacro_ifName2:
  stringEqualNode($t4, %name1)
  endEdgeEqualMacro:
    lw $t3, 0($sp)
    lw $t4, 4($sp)
    addi $sp, $sp, 8 # END IS EDGE EQUAL
.end_macro

.macro isEdgeEqualandFriend(%edge, %node1, %node2)
  # edge is a reference to an edge
  addi $sp, $sp, -8 # IS EDGE EQUAL
  sw $t3, 0($sp)
  sw $t4, 4($sp)
  # begin program
  ############## check if friend ###########
  lw $t3, 8(%edge)
  li $t4, 1 # friend
  li $v0, -1
  bne $t4, $t3, endEdgeEqualMacro
  #####################################
  lw $t3, 0(%edge) # edge node1
  lw $t4, 4(%edge) # edge node2
  # is node1 equal to name1
  isNodeEqual($t3, %node1)
  bgtz $v0, checkNodeTwoinEdgeEqualMacro
  # else, check if name1 is flipped
  isNodeEqual($t3, %node2)
  bltz $v0, endEdgeEqualMacro # if name1 isnt node1 or node2, not equal
  j checkNodeTwoinEdgeEqualMacro_ifName2
  checkNodeTwoinEdgeEqualMacro:
  # if node1=name1, node2 must equal name2
  isNodeEqual($t4, %node2)
  j endEdgeEqualMacro # if name1 isnt node1 or node2, not equal. return ans
  checkNodeTwoinEdgeEqualMacro_ifName2:
  isNodeEqual($t4, %node1)
  endEdgeEqualMacro:
    lw $t3, 0($sp)
    lw $t4, 4($sp)
    addi $sp, $sp, 8 # END IS EDGE EQUAL
.end_macro

.macro jumpToEdgeStart (%network)
  addi $t2, %network, 16 # JUMP TO EDGE START
  lw $t4, 0(%network)
  li $t3, 4
  mul $t4, $t4, $t3
  add $t2, $t4, $t2 # END JUMP TO EDGE START
.end_macro

.macro isNodeInEdge(%edge, %node)
  # if node in edge AND is friend
  addi $sp, $sp, -12 # IS NODE IN EDGE MACRO
  sw $t3, 0($sp)
  sw $t4, 4($sp)
  sw $t2, 8($sp)

  lw $t3, 0(%edge) # edge node1
  lw $t4, 4(%edge) # edge node2
  lw $t2, 8(%edge) # relationship type
  beq %node, $t3, yesisNodeInEdge
  beq %node, $t4, yesisNodeInEdge
  noisNodeInEdge:
    li $v0, -1
    j endisNodeInEdge
  yesisNodeInEdge:
    li $t3, 1 # friend is 1
    bne $t3, $t2, noisNodeInEdge # only if node is friend and in edge
    li $v0, 1
  endisNodeInEdge:
    lw $t3, 0($sp)
    lw $t4, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # END IS NODE IN EDGE
.end_macro

.macro doesNodeHaveRelation(%network, %node1, %node2)
  addi $sp, $sp, -20 # DOES NODE HAVE RELATION
  sw $t4, 0($sp)
  sw $t0, 4($sp)
  sw $t2, 8($sp)

  lw $t4, 12(%network) # num of current edges
  jumpToEdgeStart(%network)
  getNodesWithRelationLoop_doesNodeHaveRelation:
    beqz $t4, no_endgetNodesWithRelationMacro_doesNodeHaveRelation
    addi $t4, $t4, -1
    lw $t0, 0($t2) # get the address of edge
    getOtherNodeInEdge(%network, %node1)
    beq $v0, %node2, yes_endgetNodesWithRelationMacro_doesNodeHaveRelation
    addi $t2, $t2, 4
    j getNodesWithRelationLoop_doesNodeHaveRelation
  yes_endgetNodesWithRelationMacro_doesNodeHaveRelation:
    li $v0, 1 # END DOES NODE HAVE RELATION
    j endgetNodesWithRelationMacro_doesNodeHaveRelation
  no_endgetNodesWithRelationMacro_doesNodeHaveRelation:
    li $v0, -1 # END DOES NODE HAVE RELATION
  endgetNodesWithRelationMacro_doesNodeHaveRelation:
.end_macro

.macro loopGetFriends(%looper)
  addi $sp, $sp, -4 # GET FRIENDS LOOP MACRO 
  sw $s2, 0($sp) # I LOVE LOOPERS
  li $s2, %looper # THANK YOU MARK JOBS
  loopGetFriends_s:
  beqz $s2, escape_loopGetFriends
  addi $s2, $s2, -1
  getFriends()
  j loopGetFriends_s
  escape_loopGetFriends:
  lw $s2, 0($sp)
  addi $sp, $sp, 4 # END LOOP GET FRIENDS MACRO
.end_macro

.macro getFriends()
  move $t4, $v0 # GET FRIENDS MACRO / MAKE HEAP LIST OF RELATED NODES
  lw $t7, 0($v0)
  get_distant_friends_loop_thru_all_friends_macro:
    beqz $t7, escape_this_loop_get_distant_friends_macro
    addi $t7, $t7, -1
    addi $t4, $t4, 4
    addi $sp, $sp, -8
    sw $t4, 0($sp)
    sw $t8, 4($sp)
    lw $t8, 0($t4)
    getNodesWithRelation($a0, $t8, $t6) # v0 is now where the heap struct addy lives
      sw $v0, 0($gp)
      addi $gp, $gp, 4
    lw $t4, 0($sp)
    lw $t8, 4($sp)
    addi $sp, $sp, 8
    j get_distant_friends_loop_thru_all_friends_macro
  escape_this_loop_get_distant_friends_macro:
  addi $t0, $t0, 0 # END GET FRIENDS MACRO
.end_macro

.macro investigateGP(%start, %network, %node1) 
  addi $sp, $sp, -44
  sw $t4, 0($sp)
  sw $t0, 4($sp)
  sw $t9, 8($sp)
  sw %start, 16($sp)
  sw %network, 20($sp)
  sw %node1, 24($sp)
  sw $s1, 28($sp)
  sw $s2, 32($sp)
  sw $s3, 36($sp)  
  sw $s4, 40($sp)
  # allocate heap space
  ############################
  lw $t0, 8(%network) # investigate gp
  li $t4, 4
  mul $t4, $t0, $t4
  allocateHeapSpace($t4) # final heap allocation.
  #####################################
  sw $v0, 12($sp)
  move $t9, $v0
    sw $0, 0(%start)
    addi %start, %start, 4
  investigateGPLoop:
    # lw $t0, 0(%start) 
    # addi $t0, $t0, -1
    lw $t4, 0(%start)
    beqz $t4, endinvestigateGPLoop
    # t4 is reference to nodes*[]
    sw $0, 0(%start)
    addi %start, %start, 4
    # handle all t4
    lw $s1, 0($t4)
    addi $t4, $t4, 4
    loop_investigateGPLoop_indiv_nodes:
      beqz $s1, investigateGPLoop
      addi $s1, $s1, -1
      lw $s2, 0($t4)
      doesEdgeExist(%network, %node1, $s2)
      addi $t4, $t4, 4
      bgtz $v0, loop_investigateGPLoop_indiv_nodes
        lw $s3, 12($sp)
        lw $s4, 8(%network)
        isInX($s2, $s3, $s4) # (%item, %list, %len)
        bgtz $v0, loop_investigateGPLoop_indiv_nodes
      sw $s2, 0($t9)
      addi $t9, $t9, 4
    j loop_investigateGPLoop_indiv_nodes
    # this means there is a friend node to be made
  endinvestigateGPLoop:
  lw $t4, 0($sp)
  lw $t0, 4($sp)
  lw $t9, 8($sp)  
  lw $v0, 12($sp)
  lw %start, 16($sp)
  lw %network, 20($sp)
  lw %node1, 24($sp)
  lw $s1, 28($sp)
  lw $s2, 32($sp)
  lw $s3, 36($sp)  
  lw $s4, 40($sp)
  addi $sp, $sp, 44 # end investigate gp
.end_macro

.macro createFriendLinkedList(%heaplist)
  addi $sp, $sp, -20
  sw $t3, 0($sp)
  sw $t4, 8($sp)

  lw $t3, 0(%heaplist)
  li $v0, -1
  sw $v0, 4($sp)
  beqz $t3, endcreateFriendLinkedList
  createFriendNode($t3, $0)
  # sw $v0, 4($sp)
  move $t4, $v0
  addi %heaplist, %heaplist, 4
  friendlimkedlistloop_:
    lw $t3, 0(%heaplist)
    beqz $t3,endcreateFriendLinkedList
    createFriendNode($t3, $t4)
    # friendNodeSetNext($v0, $t4)
    move $t4, $v0
    addi %heaplist, %heaplist, 4
    j friendlimkedlistloop_
  endcreateFriendLinkedList:

  lw $t3, 0($sp)
  lw $t4, 8($sp)
  # lw $v0, 4($sp)
  addi $sp, $sp, 20
.end_macro

.macro getNodesWithRelation(%network, %node, %visitedList)
  # t2 is start address of edges
  # allocate enough heap space to track all friend nodes
  addi $sp, $sp, -28 # GET NODES WITH RELATION
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t3, 8($sp)
  sw $t4, 12($sp)
  sw $t9, 16($sp)
  sw %node, 20($sp)
  sw $t2, 24($sp)
  ##########################
  jumpToEdgeStart(%network)
  lw $t0, 12(%network)
  addi $t0, $t0, 1 # add number of related nodes
  li $t1, 4
  mul $t0, $t0, $t1
  allocateHeapSpace($t0) # track every node with relation
  addi $t1, $v0, 4 # skip first slot, use it for counter
  move $t9, $v0
  # check all edges
  li $t3, 0 # count related nodes
  lw $t4, 12(%network) # num of current edges
  getNodesWithRelationLoop:
    beqz $t4, endgetNodesWithRelationMacro
    addi $t4, $t4, -1
    lw $t0, 0($t2) # get the address of edge
    #t2 isnt changing thats why its failing
    isNodeInEdge($t0, %node)
    addi $t2, $t2, 4
    bltz $v0, skip_registerNodesWithRelations
      addi $sp, $sp, -4
      sw $t2, 0($sp)
      lw $t2, 12($a0)
      move $t5, $t0
      isInX($t5, %visitedList, $t2)
      lw $t2, 0($sp)
      addi $sp, $sp, 4
      bgtz $v0, skip_registerNodesWithRelations # add to visited list
    ################################
      addi $sp, $sp, -4
      sw $t2, 0($sp) 
      move $t2, $t0
      addToVisitedList(%visitedList, $t2) 
      lw $t2, 0($sp)
      addi $sp, $sp, 4
    #################################
    addi $t3, $t3, 1
    # get (other) node from edge
    getOtherNodeInEdge($t0, %node)
    sw $v0, 0($t1) # this is saving an edge. not a node. must fix.
    addi $t1, $t1, 4
    skip_registerNodesWithRelations:
    j getNodesWithRelationLoop
    # creates a new data structure which contains
    # number of edges containing node
    # edge[]
  endgetNodesWithRelationMacro:
  sw $t3, 0($t9)
  move $v0, $t9
  #########################
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t3, 8($sp)
  lw $t4, 12($sp)
  lw $t9, 16($sp)
  lw %node, 20($sp)
  lw $t2, 24($sp)
  addi $sp, $sp, 28 # END GET NODE WITH RELATION
.end_macro

.macro isInX(%item, %list, %len)
  addi $sp, $sp, -12 # IS IN X
  sw $t0, 0($sp)
  sw %list, 4($sp)
  sw %len, 8($sp)
  isinx_label:
    bltz %len, end_isinx_naur
    lw $t0, 0(%list)
    bltz $t0, end_isinx_naur
    beq %item, $t0, end_isinx_yaur
    addi %len, %len, -1
    addi %list, %list, 4
    j isinx_label
  end_isinx_naur:
    li $v0, -1
    j end_isinx
  end_isinx_yaur:
    li $v0, 1
  end_isinx:
    lw $t0, 0($sp)
    lw %list, 4($sp)
    lw %len, 8($sp)
    addi $sp, $sp, 12 # END IS IN X
.end_macro

# visited data structure:
# 0-4 : num edges visited [0-k]
# 4-4k : edge*[]
.macro createVisitedList(%network) 
  addi $sp, $sp, -8 # CREATE VISITED LIST
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  lw $t0, 4(%network)
  addi $t0, $t0, 1 # add number of related nodes
  li $t1, 4
  mul $t0, $t0, $t1
  allocateHeapSpace($t0) # track every node with relation
  #addi $t1, $v0, 4 # skip first slot, use it for counter
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  addi $sp, $sp, 8 # END CREATE VISITED LIST
.end_macro

.macro addToVisitedList(%visited, %edge)
  addi $sp, $sp, -20 # ADD2VISITED LIST
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw %visited, 8($sp)
  sw %edge, 12($sp)
  sw $s0, 16($sp)
  ################################
  lw $t0, 0(%visited)
  li $t1, 4
  mul $t1, $t1, $t0
  add $t1, %visited, $t1
  lw $s0, 0($t6)
  addi $s0, $s0, 1
  sw $s0, 0($t6)
  addi $t1, $t1, 4
  sw %edge, 0($t1)
  addi $t0, $t0, 1
  lw $t0, 0(%visited)
  ##################################
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw %visited, 8($sp)
  lw %edge, 12($sp)
  lw $s0, 16($sp)
  addi $sp, $sp, 20 # END ADD 2 VISITED LIST
.end_macro

.macro getOtherNodeInEdge(%edge, %node)
  addi $sp, $sp, -12 # IS NODE IN EDGE MACRO
  sw $t3, 0($sp)
  sw $t4, 4($sp)
  sw $t2, 8($sp)

  lw $t3, 0(%edge) # edge node1
  lw $t4, 4(%edge) # edge node2
  lw $t2, 8(%edge) # relationship type
  beq %node, $t3, yesisNodeInEdge_GETOTHERNODE_0
  beq %node, $t4, yesisNodeInEdge_GETOTHERNODE_1
  noisNodeInEdge_GETOTHERNODE:
    li $v0, -1
    j endisNodeInEdge_GETOTHERNODE
  yesisNodeInEdge_GETOTHERNODE_0:
    move $v0, $t4
    j endisNodeInEdge_GETOTHERNODE
  yesisNodeInEdge_GETOTHERNODE_1:
    move $v0, $t3
  endisNodeInEdge_GETOTHERNODE:
    lw $t3, 0($sp)
    lw $t4, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # END IS NODE IN EDGE
.end_macro

# I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS I HATE MARK JOBS
.globl create_network
create_network:
  # inputs I=a0, J=a1
  # outputs v0=network address
  # I = total number of possible nodes in network
  # J = max number of edges in network
  bltz $a0, create_network_error
  bltz $a1, create_network_error

  # allocate to the heap
  move $t0, $a0 # I 
  move $t1, $a1 # J

  li $t3, 4 # bytes come in packs of 4
  li $t4, 4 # max#nodes, max#edges, current#nodes, current#edges
  add $t4, $t4, $t0 # allocate space for all nodes
  add $t4, $t4, $t1 # allocate space for all edges

  mul $a0, $t4, $t3 # how much to allocate * 4 to rep words
  li $v0, 9
  syscall
  sw $t0, 0($v0)
  sw $t1, 4($v0)

  addi $t5, $v0, 8
  addi $t4, $t4, -2
  mul $t4, $t3, $t4
  init_loop_create_network:
    beqz $t4, end_create_network
    addi $t4, $t4, -4
    sw $0, 0($t5)
    addi $t5, $t5, 4
    j init_loop_create_network
  end_create_network:
  jr $ra

  create_network_error:
  li $v0, -1
  jr $ra

.globl add_person
add_person:
  # inputs: a0=network a1=name
  # outputs v0=a0/-1 v1=1/-1
  # check if at capacity
  addi $sp, $sp, -8
  sw $a0, 0($sp)
  sw $a1, 4($sp)
  ##################################
  lw $t0, 0($a0)
  lw $t1, 8($a0)
  beq $t0, $t1, error_out_add_person
  # check if empty string
  li $t0, '\0'
  lbu $t1, 0($a1)
  beq $t0, $t1, error_out_add_person
  # check if name already in network
  addi $t2, $a0, 16
  lw $t4, 8($a0)
  add_person_check_if_in_loop:
    lw $t3, 0($t2) # load string from memory
    beqz $t3, end_add_person_loop_check_if_in # if nothings there nothings there. end
    addi $t5, $t3, 4
    isStringEqual ($a1, $t5)
    bgtz $v0, error_out_add_person
    beqz $t4, end_add_person_loop_check_if_in
    addi $t2, $t2, 4
    addi $t4, $t4, -1
    j add_person_check_if_in_loop
  end_add_person_loop_check_if_in:
  # now actually add them
  # create node
  countChars($a1)
  move $t1, $v0
  move $t5, $a0
  addi $t2, $t1, 5 # 4 (one word) + null char
  allocateHeapSpace($t2)
  sw $t1, 0($v0)
  move $t6, $v0
  addi $t2, $v0, 4
  writeCharsToAddress ($t2, $a1, $t1)
  # sw $a1, 4($v0)
  move $a0, $t5
  move $v0, $t6
  # add node
  lw $t1, 8($a0)
  li $t2, 4
  mul $t3, $t1, $t2
  add $t3, $a0, $t3
  addi $t3, $t3, 16
  sw $v0, 0($t3)
  addi $t1, $t1, 1
  sw $t1, 8($a0)
  addi $v0, $v0, 4
  li $v1, 1
  move $v0, $a0
  lw $a0, 0($sp)
  lw $a1, 4($sp)
  addi $sp, $sp, 8
  jr $ra
  error_out_add_person:
  li $v0, -1
  li $v1, -1
  lw $a0, 0($sp)
  lw $a1, 4($sp)
  addi $sp, $sp, 8
  jr $ra

.globl get_person
get_person:
  # input a0=network a1=name
  # output v0 = reference to person node, v1 = success/fail
  addi $sp, $sp, -8
  sw $a0, 0($sp)
  sw $a1, 4($sp)

  # find person
  addi $t2, $a0, 16
  lw $t4, 8($a0) # how many nodes in node[]
  get_person_check_if_in_loop:
    lw $t3, 0($t2) # load string from memory
    beqz $t3, return_node_not_in_network_get_person # if nothings there nothings there. end
    addi $t5, $t3, 4
    isStringEqual ($a1, $t5)
    bgtz $v0, return_node_get_person
    beqz $t4, return_node_not_in_network_get_person
    addi $t2, $t2, 4
    addi $t4, $t4, -1
    j get_person_check_if_in_loop
  return_node_get_person:
    lw $v0, 0($t2)
    li $v1, 1
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    addi $sp, $sp, 8
    jr $ra
  return_node_not_in_network_get_person:
    li $v0, -1
    li $v1, -1
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    addi $sp, $sp, 8
    jr $ra

.globl add_relation
add_relation:
  # inputs a0=network a1=name1 a2=name2 a3=relation-type
  # output v0=a0
  # check if relation_type 0<a3<3
  li $t0, 3
  bltz $a3, error_add_edge
  bgt $a3, $t0, error_add_edge
  # check if names are equal
  isStringEqual($a1, $a2) # error string equal
  bgtz $v0, error_add_edge
  lw $t0, 12($a0)
  lw $t1, 4($a0)
  beq $t1, $t0, error_add_edge # max num of nodes
  # get node name1
  get_person_macro($a1)
  bltz $v1, error_add_edge # error person1 doesn't exist
  move $t9, $v0 # node1
  # get node name2
  get_person_macro($a2) # error person2 doesn't exist
  bltz $v1, error_add_edge
  move $t8, $v0 # node2
  # check if edge already exists ###############
  # loop thru each edge
  jumpToEdgeStart($a0) # // move t2 to edge start
  lw $t0, 12($a0) # current num of edges
  loop_thru_current_edges_add_relation:
  beqz $t0, node_does_not_exist_get_relation
  lw $t1, 0($t2) # get current edge in t1
  isEdgeEqual($t1, $a1, $a2) # edge, name1, name2
  bgtz $v0, error_add_edge # node is equal
  addi $t2, $t2, 4 # next edge
  addi $t0, $t0, -1
  j loop_thru_current_edges_add_relation
  ##############################################
  node_does_not_exist_get_relation:
  createEdge($t9, $t8, $a3)
  move $t0, $v0 # stores edge address
  # lw $t1, 12($a0) 
  # addi $t4, $a0, 16
  # move a0 to where edges start
  jumpToEdgeStart($a0) # // move t2 to edge start
  lw $t1, 12($a0) 
  li $t4, 4
  mul $t1, $t4, $t1
  add $t2, $t2, $t1
  lw $t1, 12($a0) 
  # lw $t2, 0($a0)
  # li $t3, 4
  # mul $t2, $t2, $t3
  # add $t2, $t4, $t2
  # now t2 is at the start of edges[]
  # mul $t1, $t1, $t3
  # add $t2, $t1, $t2 # go to current number of edges stored
  sw $t0, 0($t2) # store reference to edge
  addi $t1, $t1, 1
  sw $t1, 12($a0) # new current edge number
  li $v1, 1
  move $v0, $a0
  jr $ra
  error_add_edge:
  li $v0, -1
  li $v1, -1
  jr $ra

.globl get_distant_friends
get_distant_friends:
  # inputs: a0=network a1=name
  # outputs: v0=linkedList of all distant friends
  # check if person exists in network
  addi $sp, $sp, -4
  sw $gp, 0($sp)
  get_person_macro($a1)
  bltz $v1, distant_friends_p_does_not_exist_error_out # error person1 doesn't exist
  move $t8, $v0 # node1
  createVisitedList($a0)
  move $t6, $v0 # create visited list
  # network, node, visited list
  getNodesWithRelation($a0, $t8, $t6)
  sw $v0, 0($gp)
  addi $gp, $gp, 4
  # just do this however many times i want
  loopGetFriends(10)
  # create friend nodes by looping thru gp
  lw $gp, 0($sp) # 2147479544
  li $t0, 0
  investigateGP($gp, $a0, $t8)
  move $t9, $v0
  createFriendLinkedList($t9)
  lw $gp, 0($sp)
  bltz $v0, distant_friends_no_friends_error_out
  jr $ra
  distant_friends_no_friends_error_out:
  li $v0, -1
  lw $gp, 0($sp)
  addi $sp, $sp, 4
  jr $ra
  distant_friends_p_does_not_exist_error_out:
  li $v0, -2
  lw $gp, 0($sp)
  addi $sp, $sp, 4
  jr $ra