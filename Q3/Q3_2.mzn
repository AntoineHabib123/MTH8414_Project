include "depot_params.mzn";
include "globals.mzn";


% PARAMETRES

% Duree (periodes) de la session du sejour s sur un chargeur de type k
array[STAYS, TYPES] of int: duree = array2d(STAYS, TYPES, [energy[s] * periodsPerHour div power[k] | s in STAYS, k in TYPES]);


% VARIABLES

% Type de chargeur (1 = lent, 2 = rapide) et debut de la session du sejour s
array[STAYS] of var TYPES: typeCh;
array[STAYS] of var PERIODS: debut;

% Nombre de chargeurs installes de chaque type
array[TYPES] of var 0..nBuses: nbChargeurs;

% Puissance de pointe (kW)
var 0..gridLimit: pointe;

% Duree et puissance de la session selon le type choisi (element)
array[STAYS] of var 1..max(duree): dureeS = [duree[s, typeCh[s]] | s in STAYS];
array[STAYS] of var 0..max(power): puissS = [power[typeCh[s]] | s in STAYS];


% CONTRAINTES

% 1. La session se deroule pendant le sejour
constraint forall(s in STAYS)(debut[s] >= arrival[s] /\ debut[s] + dureeS[s] <= departure[s]);

% 2. Nombre de chargeurs de chaque type
constraint forall(k in TYPES)(cumulative(debut, dureeS, [bool2int(typeCh[s] = k) | s in STAYS], nbChargeurs[k]));

% 3. Puissance de pointe
constraint cumulative(debut, dureeS, puissS, pointe);


% FONCTION OBJECTIF (cents)

var int: coutChargeurs = sum(k in TYPES)(chargerCost[k] * nbChargeurs[k]);
var int: prime = demandCharge * pointe;

solve minimize coutChargeurs + prime;


output
  [ "Chargeurs (lents, rapides) : \(nbChargeurs)\n"
  , "Pointe (kW)                : \(pointe)\n"
  , "Cout infrastructure (cents): \(coutChargeurs + prime)\n"
  , "Cout energie (cents)       : \(sum(s in STAYS, t in fix(debut[s])..fix(debut[s]) + fix(dureeS[s]) - 1)(price[t] * fix(puissS[s])) div periodsPerHour)\n"
  , "Type de chaque session     : \(typeCh)\n"
  , "Debut de chaque session    : \(debut)\n"
  ];
