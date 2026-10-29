include "depot_params.mzn";


% Puissance maximale du chargeur individuel (kW)
float: maxPower = 150.0;


% VARIABLES

% Puissance de recharge du bus b pendant la periode t (kW)
array[BUSES, PERIODS] of var 0.0..maxPower: p;


% PARAMÈTRES

% Energie dans la batterie du bus b a la fin de la periode t (kWh) où E[b, 0] correspond au debut de la journee.
array[BUSES, 0..nPeriods] of var int2float(reserve)..int2float(capacity): E;


% CONTRAINTES


% 1. Batteries pleines au debut de la journee
constraint forall(b in BUSES)(E[b, 0] = capacity);

% 2. Batteries pleines a la fin de la journee
constraint forall(b in BUSES)(E[b, nPeriods] = capacity);

% 3. Recharge interdite lorsque le bus est sur la route
constraint forall(b in BUSES) (forall(t in PERIODS)(p[b, t] <= maxPower * (1 - away[b, t])));

% 4. Bilan d'energie de chaque batterie
constraint forall(b in BUSES)(forall(t in PERIODS)(E[b, t] = E[b, t - 1] - away[b, t]* cons[b,t] + p[b, t]/periodsPerHour));

% 5. Limite de puissance totale du depot, a chaque periode
constraint forall(t in PERIODS)(sum(b in BUSES)(p[b, t]) <= gridLimit);



% FONCTION OBJECTIF


% Cout de l'énergie en dollars
var float: cost = sum(b in BUSES, t in PERIODS)(price[t] * p[b, t]/periodsPerHour)/100;

%Pour le output
%Pour le output
var float: p_pointe = max([sum(b in BUSES)(p[b,t]) | t in PERIODS]);
var float: prime = demandCharge * p_pointe / 100.0;
var float: facture_totale = cost + prime;

solve minimize cost;


output
  [ "Energie ($)        : \(cost)\n"

  , "Pointe (kW)        : \(p_pointe)\n"

  , "Prime ($)          : \(prime)\n"

  , "Facture totale ($) : \(facture_totale)\n"
  ];

