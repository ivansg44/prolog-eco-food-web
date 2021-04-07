%import files
:- [animal_abundances].
:- [animal_produced_energies].
:- [animal_consumed_energies].
:- [animal_consumption_relationships].


% total_energy_consumed_by(Animal, Total_Produced) is true if Animal is paired up
% with the toal energy produced by a species from the csv
% Total_Produced = Abundace*Produced
total_energy_produced_csv(Animal, Total_Produced) :-
    produced_energy(Animal, ProducedEnergy),
    animal_abundance(Animal, Abundance),
    Total_Produced is Abundance*ProducedEnergy.

% total_energy_consumed_by(Animal, Abundance, Total_Produced) is true if Animal is paired up
% with the toal energy produced by a species given an Abundace value
% Total_Produced = Abundace*Produced
total_energy_produced_by_abundance(Animal, Abundance, Total_Produced) :-
    produced_energy(Animal, ProducedEnergy),
    Total_Produced is Abundance*ProducedEnergy.


% total_energy_consumed_by(Animal, Total_Consumed) is true if Animal is paired up
% with the toal energy consumed by a species from the csv
% Total_Consumed = Abundace*ConsumedEnergy
total_energy_consumed_csv(Animal, Total_Consumed) :-
    consumed_energy(Animal, ConsumedEnergy), 
    animal_abundance(Animal, Abundance),
    Total_Consumed is Abundance*ConsumedEnergy.

% total_energy_consumed_by(Animal, Abundace, Total_Consumed) is true if Animal is paired up
% with the toal energy conusmed by a species given an Abundace value
% Total_Produced = Abundace*Produced
total_energy_consumed_by_abundance(Animal, Abundance, Total_Consumed) :-
    produced_energy(Animal, ConsumedEnergy),
    Total_Consumed is Abundance*ConsumedEnergy.

% system_ok is true if all animals in the system have enough animals to eat for
% their energy requirements.
system_ok :- animal_abundances(Abundances), system_ok_helper(Abundances).

% system_ok_helper(Abundances) is true if all animals in the list of animal
% abundances have enough animals to consume.
system_ok_helper([]).
system_ok_helper([abundance(Animal, _)|T]) :-
    animal_ok(Animal),
    system_ok_helper(T).

% animal_ok(Animal) is true if Animal has enough animals to consume for its
% energy requirements.
animal_ok(Animal) :-
    animal_consumption_relationships(ConsumptionRelationships),
    total_energy_consumed_csv(Animal, ConsumedEnergy),
    animal_ok_helper(Animal, ConsumedEnergy, ConsumptionRelationships).

% animal_ok_helper(Animal, RemainingEnergyReq, ConsumptionRelationships) is
% true if the frequency of energy available from each animal consumed by
% Animal, as described in ConsumptionRelationships, exceeds RemainingEnergyReq.
animal_ok_helper(_, RemainingEnergyReq, _) :- RemainingEnergyReq =< 0.
animal_ok_helper(Animal1,
                 RemainingEnergyReq,
                 [consumption(_, Animal2, _)|T]) :-
    dif(Animal1, Animal2),
    animal_ok_helper(Animal1, RemainingEnergyReq, T).
animal_ok_helper(Animal,
                 RemainingEnergyReq,
                 [consumption(ConsumedAnimal, Animal, Freq)|T]) :-
    total_energy_produced_csv(ConsumedAnimal, Total_Produced),
    animal_ok_helper(Animal, (RemainingEnergyReq-(Total_Produced*Freq)), T).



% available_energy_from_single_prey(Predator, Prey, Conusmedenergy) is true if the AvailableEnergy is 
% equal to the TotalProducedEnergy*Freq given from the csv files.
available_energy_from_single_prey(Predator, Prey, AvailableEnergy) :-
    total_energy_produced_csv(Prey, TotalProducedEnergy),
    consumption(Prey, Predator, Freq),
    AvailableEnergy is TotalProducedEnergy*Freq.
    


% available_energy_list(Predator, PreyList, AvailableEnergy) is true if the Predator is matched up with
% all its prey and their available energy as calcualted from available_energy_from_single_prey predicate
available_energy_list(Predator, PreyList, AvailableEnergyList) :-
    prey(Predator, PreyList),
    available_energy_list_helper(Predator, PreyList, AvailableEnergyList).

available_energy_list_helper(Predator, [], []).
available_energy_list_helper(Predator, [Prey|T1], [Energy|T2]) :-
    available_energy_from_single_prey(Predator, Prey, Energy),
    available_energy_list_helper(Predator, T1, T2).


% sum_available_energy_list(Predator, TotalAvailableEnergy) is true if the TotalAvailableEnergy is the sum
% of all the available energies from a predator's preylist
sum_available_energy_list(Predator, TotalAvailableEnergy) :-
    prey(Predator, PreyList),
    available_energy_list(Predator, PreyList, AvailableEnergyList),
    sum(AvailableEnergyList, TotalAvailableEnergy).


% max_allowable_abundance(Predator, MaxAbundance) returns true if MaxAbundance is equal to the TotalAvailableEnergy
% divided by the SingleEnergyRequirement (rounded down)
max_allowable_abundance(Predator, MaxAbundance) :-
    consumed_energy(Predator, SingleEnergyRequirement),
    sum_available_energy_list(Predator, TotalAvailableEnergy),
    MaxAbundance is floor(TotalAvailableEnergy/SingleEnergyRequirement).



% From Lecture
% sum(L,S) is true if S is the sum of the elements of numerical list L
sum([],0).
sum([H|T],S) :-
    sum(T,ST),
    S is H+ST.