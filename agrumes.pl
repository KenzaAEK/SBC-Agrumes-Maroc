% ============================================================================
% SYSTÈME À BASE DE CONNAISSANCES
% Diagnostic Phytosanitaire des Agrumes
% Auteur: ABOU-EL KASEM Kenza
% Module: Ingénierie de la Connaissance - GINF3
% Encadré par: Pr. M. El Alami
% ============================================================================

% ============================================================================
% 1. DÉCLARATIONS ET PRÉDICATS DYNAMIQUES
% ============================================================================

:- dynamic symptome/3.
:- dynamic hypothese/2.
:- dynamic region/1.
:- dynamic trace_regles/1.

% ============================================================================
% 2. BASE DE CONNAISSANCES - RÈGLES DE DIAGNOSTIC
% ============================================================================

% ---------------------------------------------------------------------------
% R1: Discrimination Greening (HLB) vs Carence en Zinc
% Source: Expert Khallou + ONSSA (BVP N°10)
% Pivot: Asymétrie foliaire
% ---------------------------------------------------------------------------
diagnostic(greening_hlb, 0.90) :-
    symptome(feuille, aspect, jaunissement),
    symptome(feuille, symetrie_jauniss, asymetrique),
    ajouter_trace('R1: Jaunissement asymétrique détecté → Greening (HLB)').

diagnostic(carence_zinc, 0.80) :-
    symptome(feuille, aspect, jaunissement),
    symptome(feuille, symetrie_jauniss, symetrique),
    ajouter_trace('R1b: Jaunissement symétrique détecté → Carence en Zinc').

% ---------------------------------------------------------------------------
% R2: Identification du Stubborn (Spiroplasma citri)
% Source: Segment S2 + Rapport Rungs
% Pivot: Floraison hors saison
% ---------------------------------------------------------------------------
diagnostic(stubborn, 0.85) :-
    symptome(arbre, croissance, rabougrie),
    symptome(arbre, floraison, hors_saison),
    symptome(fruit, calibre_moyen, reduit),
    ajouter_trace('R2: Croissance rabougrie + floraison hors saison → Stubborn').

% ---------------------------------------------------------------------------
% R3: Diagnostic de la Psorose
% Source: Expert Khallou
% Pivot: Écaillage écorce + porte-greffe Trifoliata
% ---------------------------------------------------------------------------
diagnostic(psorose, 0.90) :-
    symptome(tronc, aspect_ecorce, ecaillee),
    symptome(arbre, porte_greffe, trifoliata),
    ajouter_trace('R3: Écorce écaillée sur Trifoliata → Psorose').

% ---------------------------------------------------------------------------
% R4: Identification des Thrips
% Source: Expert Smaili + Rapport Rungs
% Pivot: Cicatrice liégeuse sous le calice
% ---------------------------------------------------------------------------
diagnostic(thrips, 0.80) :-
    symptome(fruit, cicatrice_epiderme, liegeuse),
    symptome(fruit, loc_cicatrice, sous_calice),
    ajouter_trace('R4: Cicatrice liégeuse sous calice → Thrips').

% ---------------------------------------------------------------------------
% R5: Diagnostic de la Gommose
% Source: Guide INRA + Expertise terrain
% Pivot: Exsudat brunâtre + forte humidité
% ---------------------------------------------------------------------------
diagnostic(gommose, 0.85) :-
    symptome(tronc, ecoulement_gomme, oui),
    symptome(tronc, couleur_gomme, brunatre),
    symptome(environnement, humidite, H),
    H > 70,
    ajouter_trace('R5: Gomme brunâtre + humidité >70% → Gommose').

% ---------------------------------------------------------------------------
% R6: Prévalence des Viroïdes (Région Oriental)
% Source: Étude INRA 2025
% Pivot: Prévalence régionale élevée (55%)
% ---------------------------------------------------------------------------
diagnostic(exocortis, 0.55) :-
    symptome(tronc, aspect_ecorce, ecaillee),
    symptome(arbre, croissance, rabougrie),
    region(oriental),
    ajouter_trace('R6: Écorce écaillée + rabougrissement en Oriental → Exocortis').

% ---------------------------------------------------------------------------
% R7: Diagnostic de la Fumagine
% Source: Documents techniques
% Pivot: Pellicule noire (suie) sur feuilles
% ---------------------------------------------------------------------------
diagnostic(fumagine, 0.75) :-
    symptome(feuille, pellicule_suie, presente),
    ajouter_trace('R7: Pellicule noire détectée → Fumagine').

% ---------------------------------------------------------------------------
% R8: Diagnostic de la Cératite
% Source: Documents techniques
% Pivot: Perforation + ramollissement fruits
% ---------------------------------------------------------------------------
diagnostic(ceratite, 0.85) :-
    symptome(fruit, perforation, oui),
    symptome(fruit, texture_peau, ramollie),
    symptome(fruit, chute, prematuree),
    ajouter_trace('R8: Perforation + ramollissement + chute → Cératite').

% ---------------------------------------------------------------------------
% R9: Diagnostic de la Tristeza
% Source: Expert Khallou
% Pivot: Dépérissement + présence vecteur puceron
% ---------------------------------------------------------------------------
diagnostic(tristeza, 0.70) :-
    symptome(arbre, croissance, rabougrie),
    symptome(feuille, aspect, jaunissement),
    symptome(vecteur, presence_puceron, oui),
    ajouter_trace('R9: Rabougrissement + jaunissement + puceron → Tristeza').

% ============================================================================
% 3. RÈGLES DE BOOST ET D'EXCLUSION
% ============================================================================

% ---------------------------------------------------------------------------
% R10: Boost Greening par présence du vecteur Psylle
% Source: ONSSA (BVP N°10)
% ---------------------------------------------------------------------------
boost_greening(Ci, Cf) :-
    hypothese(greening_hlb, Ci),
    symptome(vecteur, presence_psylle, oui),
    Cf is min(Ci + 0.15, 0.99),
    ajouter_trace('R10: Boost Greening (+15%) - Psylle détecté').

% ---------------------------------------------------------------------------
% R11: Boost Gommose (conditions climatiques favorables)
% Source: Guide INRA
% ---------------------------------------------------------------------------
boost_gommose(Ci, Cf) :-
    hypothese(gommose, Ci),
    symptome(environnement, humidite, H),
    H > 70,
    symptome(environnement, drainage_sol, mauvais),
    Cf is min(Ci + 0.10, 0.95),
    ajouter_trace('R11: Boost Gommose (+10%) - Conditions climatiques favorables').

% ---------------------------------------------------------------------------
% R12: Exclusion Thrips vs Vent (cicatrices éparses)
% Source: Rapport Rungs
% ---------------------------------------------------------------------------
exclusion_thrips_vent(Ci, Cf) :-
    hypothese(thrips, Ci),
    symptome(fruit, loc_cicatrice, eparse),
    symptome(fruit, cicatrice_epiderme, marbrure),
    Cf is Ci * 0.4,
    ajouter_trace('R12: Réduction Thrips (-60%) - Marbrures éparses (prob. vent)').

% ============================================================================
% 4. MOTEUR D'INFÉRENCE (CHAÎNAGE ARRIÈRE)
% ============================================================================

% Lancer le diagnostic complet
demarrer_diagnostic :-
    retractall(symptome(_, _, _)),
    retractall(hypothese(_, _)),
    retractall(trace_regles(_)),
    retractall(region(_)),
    nl, nl,
    write('================================================================'), nl,
    write('   SYSTEME DE DIAGNOSTIC PHYTOSANITAIRE DES AGRUMES'), nl,
    write('   Ecole Nationale des Sciences Appliquees - Tanger'), nl,
    write('   Module: Ingenierie de la Connaissance - GINF3'), nl,
    write('================================================================'), nl,
    nl,
    collecter_symptomes,
    analyser_diagnostic,
    afficher_resultats.

% Collecte interactive des symptômes
collecter_symptomes :-
    nl,
    write('----------------------------------------------------------------'), nl,
    write('ETAPE 1: COLLECTE DES OBSERVATIONS'), nl,
    write('----------------------------------------------------------------'), nl,
    nl,
    
    % Localisation géographique
    poser_question('Région de l\'exploitation (oriental/autre)', region, [oriental, autre]),
    
    % Observations sur les feuilles
    write('--- OBSERVATION DES FEUILLES ---'), nl,
    poser_question('Aspect des feuilles (normal/jaunissement/tache_brune/necrose)', 
                   feuille, aspect, [normal, jaunissement, tache_brune, necrose]),
    
    (symptome(feuille, aspect, jaunissement) ->
        poser_question('Symétrie du jaunissement (symetrique/asymetrique)', 
                       feuille, symetrie_jauniss, [symetrique, asymetrique])
    ; true),
    
    poser_question('Présence de pellicule noire (absente/presente)', 
                   feuille, pellicule_suie, [absente, presente]),
    
    % Observations sur le tronc
    nl,
    write('--- OBSERVATION DU TRONC ---'), nl,
    poser_question('Aspect de l\'écorce (lisse/ecaillee)', 
                   tronc, aspect_ecorce, [lisse, ecaillee]),
    
    (symptome(tronc, aspect_ecorce, ecaillee) ->
        poser_question('Porte-greffe utilisé (trifoliata/bigaradier/citrange/autre)', 
                       arbre, porte_greffe, [trifoliata, bigaradier, citrange, autre])
    ; true),
    
    poser_question('Écoulement de gomme visible (non/oui)', 
                   tronc, ecoulement_gomme, [non, oui]),
    
    (symptome(tronc, ecoulement_gomme, oui) ->
        poser_question('Couleur de la gomme (brunatre/rougeatre/claire)', 
                       tronc, couleur_gomme, [brunatre, rougeatre, claire])
    ; true),
    
    % Observations sur les fruits
    nl,
    write('--- OBSERVATION DES FRUITS ---'), nl,
    poser_question('Chute des fruits (normale/prematuree/massive)', 
                   fruit, chute, [normale, prematuree, massive]),
    
    poser_question('Perforation visible (non/oui)', 
                   fruit, perforation, [non, oui]),
    
    (symptome(fruit, perforation, oui) ->
        poser_question('Texture de la peau (ferme/ramollie)', 
                       fruit, texture_peau, [ferme, ramollie])
    ; true),
    
    poser_question('Type de cicatrice (nulle/liegeuse/marbrure)', 
                   fruit, cicatrice_epiderme, [nulle, liegeuse, marbrure]),
    
    (symptome(fruit, cicatrice_epiderme, liegeuse) ->
        poser_question('Localisation cicatrice (sous_calice/eparse)', 
                       fruit, loc_cicatrice, [sous_calice, eparse])
    ; true),
    
    poser_question('Calibre moyen des fruits (normal/reduit)', 
                   fruit, calibre_moyen, [normal, reduit]),
    
    % Observations sur l'arbre
    nl,
    write('--- OBSERVATION GÉNÉRALE DE L\'ARBRE ---'), nl,
    poser_question('Croissance de l\'arbre (normale/rabougrie)', 
                   arbre, croissance, [normale, rabougrie]),
    
    poser_question('Période de floraison (saisonniere/hors_saison)', 
                   arbre, floraison, [saisonniere, hors_saison]),
    
    % Observations environnementales
    nl,
    write('--- CONDITIONS ENVIRONNEMENTALES ---'), nl,
    poser_question_numerique('Humidité moyenne (%) [0-100]', environnement, humidite),
    
    poser_question('Qualité du drainage (bon/moyen/mauvais)', 
                   environnement, drainage_sol, [bon, moyen, mauvais]),
    
    % Présence de vecteurs
    nl,
    write('--- PRÉSENCE DE VECTEURS ---'), nl,
    poser_question('Psylle asiatique observé (non/oui)', 
                   vecteur, presence_psylle, [non, oui]),
    
    poser_question('Pucerons observés (non/oui)', 
                   vecteur, presence_puceron, [non, oui]),
    
    nl.

% Poser une question binaire/multiple
poser_question(Question, Categorie, Attribut, Options) :-
    format('~w ? ~w : ', [Question, Options]),
    read(Reponse),
    (member(Reponse, Options) ->
        assertz(symptome(Categorie, Attribut, Reponse))
    ;
        write('Réponse invalide, veuillez réessayer.'), nl,
        poser_question(Question, Categorie, Attribut, Options)
    ).

% Poser une question pour la région
poser_question(Question, region, Options) :-
    format('~w ? ~w : ', [Question, Options]),
    read(Reponse),
    (member(Reponse, Options) ->
        assertz(region(Reponse))
    ;
        write('Réponse invalide, veuillez réessayer.'), nl,
        poser_question(Question, region, Options)
    ).

% Poser une question numérique
poser_question_numerique(Question, Categorie, Attribut) :-
    format('~w : ', [Question]),
    read(Valeur),
    (number(Valeur) ->
        assertz(symptome(Categorie, Attribut, Valeur))
    ;
        write('Veuillez entrer un nombre.'), nl,
        poser_question_numerique(Question, Categorie, Attribut)
    ).

% Analyser et générer les hypothèses
analyser_diagnostic :-
    nl,
    write('----------------------------------------------------------------'), nl,
    write('ETAPE 2: ANALYSE ET INFERENCE'), nl,
    write('----------------------------------------------------------------'), nl,
    nl,
    write('Analyse en cours...'), nl, nl,
    
    % Collecter toutes les hypothèses diagnostiques
    findall(Maladie-Confiance, diagnostic(Maladie, Confiance), Hypotheses),
    
    % Stocker les hypothèses
    forall(member(M-C, Hypotheses), assertz(hypothese(M, C))),
    
    % Appliquer les règles de boost/exclusion
    appliquer_boosts.

% Appliquer les règles de boost
appliquer_boosts :-
    (hypothese(greening_hlb, Ci) ->
        (boost_greening(Ci, Cf) ->
            retract(hypothese(greening_hlb, Ci)),
            assertz(hypothese(greening_hlb, Cf))
        ; true)
    ; true),
    
    (hypothese(gommose, Ci2) ->
        (boost_gommose(Ci2, Cf2) ->
            retract(hypothese(gommose, Ci2)),
            assertz(hypothese(gommose, Cf2))
        ; true)
    ; true),
    
    (hypothese(thrips, Ci3) ->
        (exclusion_thrips_vent(Ci3, Cf3) ->
            retract(hypothese(thrips, Ci3)),
            assertz(hypothese(thrips, Cf3))
        ; true)
    ; true).

% Afficher les résultats
afficher_resultats :-
    nl,
    write('================================================================'), nl,
    write('                RESULTATS DU DIAGNOSTIC'), nl,
    write('================================================================'), nl,
    nl,
    
    findall(C-M, hypothese(M, C), Liste),
    
    (Liste = [] ->
        write('AUCUNE pathologie identifiee avec les symptomes fournis.'), nl,
        write('Recommandation: Consulter un expert agronome.'), nl
    ;
        % Trier par confiance décroissante
        sort(0, @>=, Liste, ListeTriee),
        
        % Afficher le diagnostic principal
        ListeTriee = [CPrinc-MPrinc|_],
        nl,
        write('>> DIAGNOSTIC PRINCIPAL:'), nl,
        write('----------------------------------------------------------------'), nl,
        format('   Pathologie: ~w~n', [MPrinc]),
        ConfPourcent is CPrinc * 100,
        format('   Confiance: ~1f%~n', [ConfPourcent]),
        afficher_recommandations(MPrinc),
        
        % Afficher les hypothèses alternatives si confiance < 85%
        (CPrinc < 0.85 ->
            nl,
            write('>> HYPOTHESES ALTERNATIVES (confiance < 85%):'), nl,
            write('----------------------------------------------------------------'), nl,
            afficher_alternatives(ListeTriee)
        ; true),
        
        % Afficher la trace de raisonnement
        nl,
        write('>> TRACE DU RAISONNEMENT (Explicabilite):'), nl,
        write('----------------------------------------------------------------'), nl,
        afficher_trace
    ),
    
    nl,
    write('================================================================'), nl,
    nl.

% Afficher les hypothèses alternatives
afficher_alternatives([]).
afficher_alternatives([C-M|Reste]) :-
    C < 0.85,
    ConfPourcent is C * 100,
    format('   • ~w (~1f%)~n', [M, ConfPourcent]),
    afficher_alternatives(Reste).
afficher_alternatives([_|Reste]) :-
    afficher_alternatives(Reste).

% Afficher les recommandations par pathologie
afficher_recommandations(greening_hlb) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Arrachage immediat de l arbre (maladie de quarantaine)'), nl,
    write('      - Lutte contre le vecteur Diaphorina citri'), nl,
    write('      - Surveillance accrue des arbres voisins'), nl,
    write('      - Notification obligatoire a l ONSSA'), nl.

afficher_recommandations(gommose) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Ameliorer le drainage du sol'), nl,
    write('      - Traitement fongicide a base de cuivre'), nl,
    write('      - Eviter les blessures au collet'), nl,
    write('      - Reduire l irrigation si excessive'), nl.

afficher_recommandations(ceratite) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Piegeage massif (bouteilles McPhail)'), nl,
    write('      - Ramassage et destruction des fruits tombes'), nl,
    write('      - Traitements insecticides en periode critique'), nl,
    write('      - Lutte biologique (parasitoides)'), nl.

afficher_recommandations(thrips) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Eliminer les mauvaises herbes a fleurs jaunes'), nl,
    write('      - Traitement insecticide cible'), nl,
    write('      - Favoriser les auxiliaires naturels'), nl,
    write('      - Impact commercial: declassement a l export'), nl.

afficher_recommandations(psorose) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Utiliser du materiel vegetal certifie'), nl,
    write('      - Desinfecter les outils de taille'), nl,
    write('      - Arracher les arbres severement atteints'), nl,
    write('      - Privilegier les porte-greffes resistants'), nl.

afficher_recommandations(fumagine) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Traiter les pucerons et cochenilles (producteurs de miellat)'), nl,
    write('      - Lavage des arbres a l eau sous pression'), nl,
    write('      - Traitement insecticide contre les ravageurs'), nl,
    write('      - Ameliorer l aeration du verger'), nl.

afficher_recommandations(stubborn) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Traitement antibiotique (tetracycline)'), nl,
    write('      - Lutte contre les vecteurs (cicadelles)'), nl,
    write('      - Arrachage des arbres tres atteints'), nl,
    write('      - Utilisation de plants sains'), nl.

afficher_recommandations(exocortis) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Utiliser du materiel vegetal certifie indemne'), nl,
    write('      - Desinfecter tous les outils de taille'), nl,
    write('      - Choisir des porte-greffes tolerants'), nl,
    write('      - Prevalence elevee dans l Oriental (55%)'), nl.

afficher_recommandations(carence_zinc) :-
    nl,
    write('   MESURES CORRECTIVES:'), nl,
    write('      - Fertilisation foliaire au zinc'), nl,
    write('      - Analyse de sol pour confirmer la carence'), nl,
    write('      - Apport de sulfate de zinc'), nl,
    write('      - Corriger le pH du sol si necessaire'), nl.

afficher_recommandations(tristeza) :-
    nl,
    write('   MESURES PROPHYLACTIQUES:'), nl,
    write('      - Utiliser des porte-greffes tolerants'), nl,
    write('      - Lutte contre les pucerons vecteurs'), nl,
    write('      - Premunition des plants sensibles'), nl,
    write('      - Surveillance phytosanitaire reguliere'), nl.

afficher_recommandations(_).

% Gestion de la trace de raisonnement
ajouter_trace(Message) :-
    assertz(trace_regles(Message)).

afficher_trace :-
    trace_regles(Message),
    format('   > ~w~n', [Message]),
    fail.
afficher_trace.

% ============================================================================
% 5. INTERFACE UTILISATEUR PRINCIPALE
% ============================================================================

% Point d'entrée principal
:- initialization(menu_principal).

menu_principal :-
    nl, nl,
    write('================================================================'), nl,
    write('   SYSTEME DE DIAGNOSTIC PHYTOSANITAIRE - AGRUMES'), nl,
    write('   ENSA Tanger - Module: IC - GINF3'), nl,
    write('================================================================'), nl,
    nl,
    write('1. Lancer un nouveau diagnostic'), nl,
    write('2. Afficher les maladies de la base de connaissances'), nl,
    write('3. Quitter'), nl,
    nl,
    write('Votre choix : '),
    read(Choix),
    traiter_choix(Choix).

traiter_choix(1) :-
    demarrer_diagnostic,
    nl,
    write('Appuyez sur Entrée pour continuer...'),
    get_char(_),
    menu_principal.

traiter_choix(2) :-
    afficher_base_connaissances,
    nl,
    write('Appuyez sur Entrée pour continuer...'),
    get_char(_),
    menu_principal.

traiter_choix(3) :-
    nl,
    write('Merci d\'avoir utilisé le système SBC Agrumes !'), nl,
    write('Au revoir.'), nl,
    halt.

traiter_choix(_) :-
    nl,
    write('Choix invalide. Veuillez réessayer.'), nl,
    menu_principal.

% Afficher la base de connaissances
afficher_base_connaissances :-
    nl,
    write('================================================================'), nl,
    write('      BASE DE CONNAISSANCES - PATHOLOGIES TRAITEES'), nl,
    write('================================================================'), nl,
    nl,
    write('1. Greening (HLB) - Huanglongbing'), nl,
    write('   Vecteur: Diaphorina citri (Psylle asiatique)'), nl,
    write('   Gravite: QUARANTAINE - Arrachage obligatoire'), nl,
    nl,
    write('2. Gommose (Phytophthora spp.)'), nl,
    write('   Type: Maladie fongique du tronc et des racines'), nl,
    write('   Symptome cle: Exsudat de gomme brunatre'), nl,
    nl,
    write('3. Ceratite (Ceratitis capitata)'), nl,
    write('   Type: Insecte ravageur des fruits'), nl,
    write('   Impact: Piqures, ramollissement, chute prematuree'), nl,
    nl,
    write('4. Thrips des agrumes'), nl,
    write('   Type: Ravageur provoquant des cicatrices liegeuses'), nl,
    write('   Localisation: Sous le calice du fruit'), nl,
    nl,
    write('5. Psorose'), nl,
    write('   Type: Maladie virale'), nl,
    write('   Symptome cle: Ecaillage de l ecorce'), nl,
    nl,
    write('6. Fumagine'), nl,
    write('   Type: Champignon saprophyte (pellicule noire)'), nl,
    write('   Cause: Miellat produit par pucerons/cochenilles'), nl,
    nl,
    write('7. Stubborn (Spiroplasma citri)'), nl,
    write('   Type: Maladie bacterienne'), nl,
    write('   Symptome cle: Floraison hors saison'), nl,
    nl,
    write('8. Exocortis (Viroide)'), nl,
    write('   Prevalence: 55% dans la region de l Oriental'), nl,
    write('   Symptome: Ecaillage + rabougrissement'), nl,
    nl,
    write('9. Tristeza (CTV)'), nl,
    write('   Vecteur: Toxoptera citricida (puceron)'), nl,
    write('   Impact: Deperissement rapide'), nl,
    nl,
    write('================================================================'), nl.