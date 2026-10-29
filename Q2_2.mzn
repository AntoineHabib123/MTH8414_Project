include "depot_params.mzn";


% Puissance maximale du chargeur individuel (kW)
float: maxPower = max(power);


% VARIABLES

% Puissance de recharge du bus b pendant la periode t (kW)
array[BUSES, PERIODS] of var 0.0..maxPower: p;

%AJOUT
% Nombre de chargeurs installes de chaque type
array[TYPES] of var 0..nBuses: nbChargeurs;

% 1 si le bus b est branche sur un chargeur de type k pendant la periode t, 0 sinon
array[BUSES, PERIODS, TYPES] of var 0..1: x;


% PARAMÈTRES

% Energie dans la batterie du bus b a la fin de la periode t (kWh) où E[b, 0] correspond au debut de la journee.
array[BUSES, 0..nPeriods] of var int2float(reserve)..int2float(capacity): E;




% CONTRAINTES


% 1. Batteries pleines au debut de la journee
constraint forall(b in BUSES)(E[b, 0] = capacity);

% 2. Batteries pleines a la fin de la journee
constraint forall(b in BUSES)(E[b, nPeriods] = capacity);

% MISE-À-JOUR (sum type_borne) 3. Recharge interdite lorsque le bus est sur la route
constraint forall(b in BUSES, t in PERIODS)(sum(type_borne in TYPES)(x[b,t,type_borne]) <= 1 - away[b,t]);

% 4. Bilan d'energie de chaque batterie
constraint forall(b in BUSES)(forall(t in PERIODS)(E[b, t] = E[b, t - 1] - away[b, t]* cons[b,t] + p[b, t]/periodsPerHour));

% 5. Limite de puissance totale du depot, a chaque periode
constraint forall(t in PERIODS)(sum(b in BUSES)(p[b, t]) <= gridLimit);

% AJOUT
% 6. Respecter le nombre de chargeur
constraint forall(t in PERIODS, type_borne in TYPES)(sum(b in BUSES)(x[b,t,type_borne]) <= nbChargeurs[type_borne]);

% 7. Respecter la puissance max du type de chargeur
constraint forall(b in BUSES, t in PERIODS)(p[b,t] <= sum(type_borne in TYPES)(power[type_borne] * x[b,t,type_borne]));


% FONCTION OBJECTIF


% Cout de l'énergie en dollars
var float: cost = sum(b in BUSES, t in PERIODS)(price[t] * p[b, t]/periodsPerHour)/100;

%Puissance de pointe du réseau
var float: p_pointe = max([sum(b in BUSES)(p[b,t]) | t in PERIODS]);
var float: prime = demandCharge * p_pointe / 100.0;
var float: cout_chargeurs = sum(type_borne in TYPES)(chargerCost[type_borne] * nbChargeurs[type_borne]) / 100.0;
var float: facture_totale = cost + prime + cout_chargeurs;

solve minimize facture_totale;


output
  [ "Energie ($)        : \(cost)\n"

  , "Pointe (kW)        : \(p_pointe)\n"

  , "Prime ($)          : \(prime)\n"
  
  , "Chargeurs ($)      : \(cout_chargeurs) (\(nbChargeurs))\n"

  , "Facture totale ($) : \(facture_totale)\n"
  ];

