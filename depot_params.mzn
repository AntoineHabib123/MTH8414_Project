% ============================================================================
% MTH8414E - Project: Charging an Electric Bus Depot
% Declaration of the parameters contained in the instance files (depot_XX.dzn).
% Put  include "depot_params.mzn";  at the top of each of your models.
% All amounts of money are in cents.
% ============================================================================

% ---- Time and fleet ---------------------------------------------------------
int: nBuses;                                  % number of buses
set of int: BUSES = 1..nBuses;
int: nPeriods;                                % number of periods (period 1 = 04:00-04:30)
set of int: PERIODS = 1..nPeriods;
int: periodsPerHour;                          % a bus charging at p kW during one period receives p/periodsPerHour kWh

% ---- Batteries (kWh) --------------------------------------------------------
int: capacity;                                % capacity of a battery; all batteries are full at the start and at the end of the day
int: reserve;                                 % minimum level of a battery at any time

% ---- Timetable --------------------------------------------------------------
array[BUSES, PERIODS] of 0..1: away;          % away[b,t] = 1 if bus b is on the road during period t
array[BUSES, PERIODS] of int: cons;           % cons[b,t] = energy consumed by bus b during period t (kWh)

% ---- Electricity bill -------------------------------------------------------
array[PERIODS] of int: price;                 % energy price during period t (cents/kWh)
int: demandCharge;                            % cents per kW of the highest total power drawn over the day
int: gridLimit;                               % maximum total power that the depot can draw (kW)

% ---- Chargers (Parts 2 and 3) -----------------------------------------------
int: nTypes;                                  % number of charger types (1 = slow, 2 = fast)
set of int: TYPES = 1..nTypes;
array[TYPES] of int: power;                   % power of a charger of type k (kW)
array[TYPES] of int: chargerCost;             % daily cost of one charger of type k (cents)
int: plugCost;                                % cost of one plug-in operation (cents)

% ---- Stays (Part 3) ---------------------------------------------------------
int: nStays;                                  % number of stays that follow a trip
set of int: STAYS = 1..nStays;
array[STAYS] of BUSES: stayBus;               % bus concerned by stay s
array[STAYS] of PERIODS: arrival;             % first period of stay s
array[STAYS] of int: departure;               % first period after stay s (nPeriods+1 if the bus stays until the end of the day)
array[STAYS] of int: energy;                  % energy to be charged during stay s (kWh)
