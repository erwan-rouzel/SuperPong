SUPER PONG v1.1
===============

par Erwan Rouzel, aKa nop
pour TI-89 sous doorsos

C'est un jeu qui reprend le concept d'un des premiers 
jeux-vidéos (Pong). Il s'agit de mon premier programme en 
assembleur 68k.

Installation
------------

Transférez simplement le fichier spong.89z sur votre TI. Il faut que 
vous possédiez les libs : userlib, graphlib ; et bien sûr, vous devez
avoir doorsos (testé sur la Final Release, mais ça doit marcher sur 
les anciennes versions aussi) 

Le jeu 
------

Je crois qu'il n'est pas nécessaire d'expliquer les règles :-)

Je précise juste les règles de comportement de la balle :
 - elle accélère légèrement à chaque fois qu'elle touche une raquette,
   et sa vitesse peut donc devenir considérable au bout d'un grand
   nombre d'échanges ;
 - vous pouvez lui faire subir des effets, qui dépendent de la manière
   de renvoyer la balle : si vous la prenez dans le sens de sa
   trajectoire, vous lui faites subir une accélération verticale, dans
   le sens contaire une décélération. Si vous ne comprenez pas, 
   essayez ! 
   
On peut jouer à 2 sur la même TI, ou à 1 contre une AI (dont le niveau est réglable). Voici les touches :

 - joueur à gauche : 
    * haut : 2nd
    * bas  : Home

 - joueur à droite :
    * haut : flêche haut
    * bas  : flêche bas   

 - divers :
    * pause : enter
    * arrêter la partie : esc 

Historique
----------
v1.1 :
Quelques améliorations dans la gestion de la vitesse des raquettes, 
et des parties de code superflues ont été supprimées. C'est la 
première *vraie* release 

v1.0 :
Une genre de bêta que presque personne n'a vue, étant donné que je 
ne l'ai pas publiée sur ticalc.org   



Contact
-------

N'hésitez pas à reporter tout bug, suggestion, etc...

e-mail : nop@ifrance.com
WEB : http://nop.ifrance.com