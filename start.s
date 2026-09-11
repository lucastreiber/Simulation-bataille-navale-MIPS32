# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
    
# ===== Section code =====  
.text

# ----- Main ----- 
main:
    jal initPartie
    jal displayGrille
    jal simulationJeu
    j   exit 

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:
    addi     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, 5
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, 4  
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, 3
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, 3
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, 2
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    lw      $ra, 0($sp)                 # On recharge la reference 
    addi     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$t3, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j boucle_initGrille
    end_initGrille:
        jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    jal displayLettres
    la      $t0, grille     #Charge l'adresse de la grille dans $t0
    li      $t1, 0          #Initialisation du compteur de boucle dans $t1
    boucle_displayGrille:
        bge     $t1, 100, end_displayGrille     # Si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
            move $a0,$t1
            jal addLineCount
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 11                 # code pour l'affichage d'un caractère (char)
            syscall
	    li $a0,32
	    syscall
            addi    $t1, $t1, 1            # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        jal     addNewLine
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, $v0, $a0

displayLettres:
	li $t0,65 # on initialise t0 a 65 car c est le caractere A
	li $v0,11 # on met v0 a 11 pour que lors d un syscall on affiche un caractere
	li $a0,32 # on met a0 à 32 pour l espace
	syscall # on affiche
	syscall # on affiche
	boucleLettre: # debut de la boucle
		li $a0,32 # on met a0 à 32 pour l espace
		syscall
		move $a0,$t0 # on met la valeur de t0 donc la lettre ou on est dans a0
		syscall # on l affiche
		addi $t0,$t0,1 # t0 ++
		bne $t0,75,boucleLettre # si t0 n es pas egale a 75 on continue la boucle 
	jr $ra

# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    jr      $ra             # Retour à la fonction précendente

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:
	li $a1,10
	addi     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
	jal getModulo
	bne $v0,0,finAddLineCount
		jal addNewLine
		addi $v1,$v1,1
		beq $v1,10,suite2
			li $a0,32
			li $v0,11
			syscall
		suite2:
		move $a0,$v1
		li $v0,1
		syscall
		li $a0,32
		li $v0,11
		syscall
	finAddLineCount:
		lw      $ra, 0($sp)                 # On recharge la reference 
        	addi     $sp, $sp, 4  
		jr $ra

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo: 
    li $v1, 0
    subi     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
        addi $v1, $v1, 1
        sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caraètre pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip:
    subi     $sp, $sp, 4
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour
     
    move 	$s0, $a0		# On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip:
        lw      $ra, 0($sp)
        addi     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
        
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
	li $a1,10
	jal getAleatoire
	move $s2,$a0
	sub $a1,$a1,$s0
	jal getAleatoire
	move $s3,$a0
	j verifPlaceHorizontale
	placeH:
	la      $t0, grille     #Charge l'adresse de la grille dans $t0
    	sub 	$t1,$t1,$s0	#coordonne de depart
    	bouclePlaceH:
        bge     $t1, $t4, end_placementGrilleH # Si $t1 est plus grand ou egal a t4 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$s4, 0($t2)		# On place la valeur à l'adresse contenue dans $t2 dans s4
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j bouclePlaceH
    	end_placementGrilleH:
        	j end_setShip
		

# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:
	la      $t0, grille     # Chargement de l'adresse de la grille
    	move      $t1, $s3          # Initialisation du compteur de boucle dans $t1
    	li $t3,10
    	mult $s2,$t3
    	mflo $t3
    	add $t1,$t1,$t3
    	add $t4,$t1,$s0
    	boucle_parcourGrilleH:
        bge     $t1, $t4, end_parcourGrilleH # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb	$t3,0($t2)
            beq $t3,46,caseVideH
            	li $v0,1
            	j try_setShip
            caseVideH:
            	addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
            	j boucle_parcourGrilleH
        end_parcourGrilleH:
        li $v0,0
        j placeH

# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:
	li $a1,10
	jal getAleatoire
	move $s3,$a0
	sub $a1,$a1,$s0
	jal getAleatoire
	move $s2,$a0
	j verifPlaceVerticale
	placeV:
	la      $t0, grille     #Charge l'adresse de la grille dans $t0
    	li $t3,10
    	mult $s0,$t3
    	mflo $t3
    	sub 	$t1,$t1,$t3	#coordonne de depart
    	bouclePlaceV:
        bge     $t1, $t4, end_placementGrilleV # Si $t1 est plus grand ou egal a t4 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$s4, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 10     # $t1 += 10 (On augemente le compteur)
        j bouclePlaceV
    	end_placementGrilleV:
        	j end_setShip

# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale:
	la      $t0, grille     # Chargement de l'adresse de la grille
    	move      $t1, $s3          # Initialisation du compteur de boucle dans $t1
    	li $t3,10	#charge dans t3 10
    	mult $s2,$t3	#multiplie s2 par t3 (donc la ligne par 10)
    	mflo $t3	#met le resultat dans t3
    	add $t1,$t1,$t3		#incremente t1 de t3
    	li $t4,10	#charge dans t4 10
    	mult $s0,$t4	#multiplie s0 par t4 (donc le nb de ligne par 10)
    	mflo $t4	#met le resultat dans t4
    	add $t4,$t4,$t1
    	boucle_parcourGrilleV:
        bge     $t1, $t4, end_parcourGrilleV # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   	# $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb	$t3,0($t2)		# met dans t3 la valeur a l addresse t2 dans la ram
            beq $t3,46,caseVideV
            	li $v0,1
            	j try_setShip
            caseVideV:
            	addi    $t1, $t1, 10     # $t1 += 10 (On augemente le compteur)
            	j boucle_parcourGrilleV
        end_parcourGrilleV:
        li $v0,0
        j placeV

# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3], $a1, $a0 , $sp, $ra

simulationJeu:
	li $s0,0	# 'nb_coups' initialise a 0
	li $s1,0 	# 'nb_coups_but' initialise a 0
	li $a1,10	
	subi     $sp, $sp, 4
        sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour
	while :
	beq $s1,17,finSimu
		jal getAleatoire
		move $s2,$a0	#On sauvegarde une ligne aleatoire dans s2
		jal getAleatoire
		move $s3,$a0	#On sauvegarde une colone aleatoire dans s3
		jal traque
		j while	
	finSimu:
		li $v0,1
		move $a0,$s0
		syscall
		lw      $ra, 0($sp)
        	addi     $sp, $sp, 4     # On retablie l'adresse de retour
    		jr $ra
# ----- Fontion traque -----     
# Objectif : Verifie la presence d'un navire et le traque de maniere recursive
# Registres utilises : $t[8-9], $s[0-3]

traque:
	li $t8,10
	mult $s2,$t8
	mflo $t8
	add $t8,$t8,$s3		#t8 a les co aleatoire du tir
	add $t8,$t8,$t0
	lb $t9,0($t8)
	beq $t9,126,retour	#si on a deja tire dessus (loupe)
	beq $t9,88,retour	#si on a deja tire dessus (touche)
	addi $s0,$s0,1
	bne $t9,46,touche	
		li $t9,126
		sb $t9,0($t8)	#dans l'eau
		jr $ra
	touche :
		addi $s1,$s1,1
		li $t9,88
		sb $t9,0($t8)
		subi $sp,$sp,4
		sw $ra,0($sp)
		jal displayGrille
		
		#verif nord
		subi $s2,$s2,1
		bgezal $s2,traque
		addi $s2,$s2,1
		#verif ouest
		subi $s3,$s3,1
		bgezal $s3,traque
		addi $s3,$s3,1
		#verif sud
		addi $s2,$s2,1
		bge $s2,10,est
		jal traque
		est:		
		subi $s2,$s2,1
		#verif est
		addi $s3,$s3,1
		bge $s3,10,finTraque
		jal traque
		finTraque:		
		subi $s3,$s3,1
		
		lw $ra,0($sp)
		addi $sp,$sp,4
				
retour:
	jr $ra			

exit: 
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
