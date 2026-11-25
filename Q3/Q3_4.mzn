include "depot_params.mzn";
include "globals.mzn";


% PARAMETRES

% Duree (periodes) de la session du sejour s sur un chargeur de type k
array[STAYS, TYPES] of int: duree = array2d(STAYS, TYPES, [energy[s] * periodsPerHour div power[k] | s in STAYS, k in TYPES]);

% Cout de l'energie (cents) de la session du sejour s sur le type k commencant a t (0 si elle deborde de la journee)
array[STAYS, TYPES, PERIODS] of int: coutSession = array3d(STAYS, TYPES, PERIODS,
  [ if t + duree[s, k] - 1 <= nPeriods then sum(u in t..t + duree[s, k] - 1)(price[u]) * power[k] div periodsPerHour else 0 endif
  | s in STAYS, k in TYPES, t in PERIODS ]);


% VARIABLES

% Type de chargeur (1 = lent, 2 = rapide) et debut de la session du sejour s
array[STAYS] of var TYPES: typeCh;
array[STAYS] of var PERIODS: debut;

% Nombre de chargeurs installes de chaque type
array[TYPES] of var 0..nBuses: nbChargeurs;

% Puissance de pointe (kW)
var 0..gridLimit: pointe;

% Duree, puissance et cout de la session selon le type et le debut choisis (element)
array[STAYS] of var 1..max(duree): dureeS = [duree[s, typeCh[s]] | s in STAYS];
array[STAYS] of var 0..max(power): puissS = [power[typeCh[s]] | s in STAYS];
array[STAYS] of var 0..max(coutSession): coutEnergieS = [coutSession[s, typeCh[s], debut[s]] | s in STAYS];


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
var int: coutEnergie = sum(coutEnergieS);
% Une operation de branchement par session
int: coutBranchements = plugCost * nStays;

solve minimize coutChargeurs + prime + coutEnergie + coutBranchements;


output
  [ "Chargeurs (lents, rapides) : \(nbChargeurs)\n"
  , "Pointe (kW)                : \(pointe)\n"
  , "Cout energie (cents)       : \(coutEnergie)\n"
  , "Cout total (cents)         : \(coutChargeurs + prime + coutEnergie + coutBranchements)\n"
  , "Type de chaque session     : \(typeCh)\n"
  , "Debut de chaque session    : \(debut)\n"
  ];
