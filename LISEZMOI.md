SUPER PONG v1.1
===============

par Erwan Rouzel, aKa nop
pour TI-89 sous doorsos

C'est un jeu qui reprend le concept d'un des premiers 
jeux-vid�os (Pong). Il s'agit de mon premier programme en 
assembleur 68k.

Installation
------------

Transf�rez simplement le fichier spong.89z sur votre TI. Il faut que 
vous poss�diez les libs : userlib, graphlib ; et bien s�r, vous devez
avoir doorsos (test� sur la Final Release, mais �a doit marcher sur 
les anciennes versions aussi) 

Le jeu 
------

Je crois qu'il n'est pas n�cessaire d'expliquer les r�gles :-)

Je pr�cise juste les r�gles de comportement de la balle :
 - elle acc�l�re l�g�rement � chaque fois qu'elle touche une raquette,
   et sa vitesse peut donc devenir consid�rable au bout d'un grand
   nombre d'�changes ;
 - vous pouvez lui faire subir des effets, qui d�pendent de la mani�re
   de renvoyer la balle : si vous la prenez dans le sens de sa
   trajectoire, vous lui faites subir une acc�l�ration verticale, dans
   le sens contaire une d�c�l�ration. Si vous ne comprenez pas, 
   essayez ! 
   
On peut jouer � 2 sur la m�me TI, ou � 1 contre une AI (dont le niveau est r�glable). Voici les touches :

 - joueur � gauche : 
    * haut : 2nd
    * bas  : Home

 - joueur � droite :
    * haut : fl�che haut
    * bas  : fl�che bas   

 - divers :
    * pause : enter
    * arr�ter la partie : esc 

Historique
----------
v1.1 :
Quelques am�liorations dans la gestion de la vitesse des raquettes, 
et des parties de code superflues ont �t� supprim�es. C'est la 
premi�re *vraie* release 

v1.0 :
Une genre de b�ta que presque personne n'a vue, �tant donn� que je 
ne l'ai pas publi�e sur ticalc.org   



Contact
-------

N'h�sitez pas � reporter tout bug, suggestion, etc...

e-mail : nop@ifrance.com
WEB : http://nop.ifrance.com