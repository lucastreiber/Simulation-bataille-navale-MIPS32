# Bataille Navale — MIPS 32 Assembly

Implémentation du jeu de la Bataille Navale en assembleur **MIPS 32**, réalisée dans le cadre de mes études. Le programme génère une grille 10x10, y place aléatoirement 5 bateaux (en s'assurant qu'ils ne se chevauchent pas), puis simule une partie où des tirs aléatoires sont effectués jusqu'à couler tous les navires — avec une traque **récursive** des bateaux touchés.

## Fonctionnement

Le programme se déroule en trois grandes étapes, orchestrées par `main` :

1. **`initPartie`** — Initialise une nouvelle partie : remplit la grille de cases vides (`.`) puis place les 5 bateaux réglementaires.
2. **`displayGrille`** — Affiche la grille dans la console avec les coordonnées (lettres en en-tête, numéros de ligne à gauche).
3. **`simulationJeu`** — Simule la partie : tire aléatoirement sur la grille jusqu'à ce que les 17 cases occupées par des bateaux soient toutes touchées, puis affiche le nombre total de coups joués.

### Placement des bateaux

Chaque bateau est placé par `setShip`, qui choisit aléatoirement :
- un axe (horizontal ou vertical),
- une position de départ sur la grille.

Avant de valider le placement, `verifPlaceHorizontale` / `verifPlaceVerticale` vérifient que toutes les cases nécessaires sont libres. Si le placement n'est pas valide (chevauchement avec un autre bateau ou il se fait couper par le bord de la grille), le tirage est recommencé (`try_setShip`).

Les 5 bateaux placés sont les suivants :

| Taille | Caractère | Nom                      |
|--------|-----------|--------------------------|
| 5      | `A`       | Porte-avions             |
| 4      | `B`       | Cuirassé                 |
| 3      | `C`       | Croiseur                 |
| 3      | `S`       | Sous-marin               |
| 2      | `D`       | Torpilleur               |

### Simulation des tirs et traque récursive

À chaque tour, `simulationJeu` tire des coordonnées aléatoires et appelle `traque` :

- Si la case est déjà marquée (`~` = raté, `X` = touché), le tir est ignoré.
- Si la case est vide (`.`), elle devient un tir dans l'eau (`~`).
- Si la case contient un bateau, elle est marquée comme touchée (`X`) et `traque` s'appelle **récursivement** sur les 4 cases adjacentes (nord, sud, est, ouest) pour poursuivre la traque du navire jusqu'à le couler entièrement, avec un affichage de la grille à chaque case touchée.

La partie se termine lorsque les 17 cases de bateaux ont toutes été touchées, et le nombre total de coups joués est affiché.

## Légende de la grille

| Symbole | Signification         |
|---------|------------------------|
| `.`     | Case vide (inconnue)   |
| `~`     | Tir dans l'eau (raté)  |
| `X`     | Bateau touché          |
| `A-D`,`S` | Bateau non découvert |

## Exécution

Ce programme est écrit en assembleur MIPS 32 et prévu pour être exécuté avec le simulateur **MARS (MIPS Assembler and Runtime Simulator)**.
- Lancez MARS
- Ouvrez start.s depuis l'application
- Compilez le script
- Puis exécutez le

## Structure du fichier

Le programme est entièrement contenu dans `start.s` et organisé en fonctions documentées, parmi lesquelles :

- `initGrille` / `displayGrille` / `displayLettres` — initialisation et affichage de la grille.
- `setShip` / `placeHorizontale` / `placeVerticale` / `verifPlaceHorizontale` / `verifPlaceVerticale` — placement aléatoire et validé les bateaux.
- `getAleatoire` / `getModulo` — utilitaires (nombre aléatoire, modulo maison).
- `simulationJeu` / `traque` — simulation de la partie et traque récursive les bateaux touchés.


## Auteur

Projet réalisé par **[@Lucas TREIBER-LUSTIG](https://github.com/lucastreiber/)** et **[@tom SCHWARTZ](https://github.com/T0M0R0W)
