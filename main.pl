%import files
:- [animal_abundances].
:- [animal_produced_energies].
:- [animal_consumed_energies].
:- [animal_consumption_relationships].
:- [helpers].

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



% available_energy_from_single_prey(Predator, Prey, AvailableEnergy) is true if the AvailableEnergy is 
% equal to the TotalProducedEnergy*Freq given from the csv files.
available_energy_from_single_prey(Predator, Prey, AvailableEnergy) :-
    total_energy_produced_csv(Prey, TotalProducedEnergy),
    consumption(Prey, Predator, Freq),
    AvailableEnergy is TotalProducedEnergy*Freq.
    


% available_energy_list(Predator, AvailableEnergy) is true if the Predator is matched up with
% all its prey and their available energy as calcualted from available_energy_from_single_prey predicate
available_energy_list(Predator, AvailableEnergyList) :-
    prey(Predator, PreyList),
    available_energy_list_helper(Predator, PreyList, AvailableEnergyList).

available_energy_list_helper(_, [], []).
available_energy_list_helper(Predator, [Prey|T1], [Energy|T2]) :-
    available_energy_from_single_prey(Predator, Prey, Energy),
    available_energy_list_helper(Predator, T1, T2).


% sum_available_energy_list(Predator, TotalAvailableEnergy) is true if the TotalAvailableEnergy is the sum
% of all the available energies from a predator's preylist
sum_available_energy_list(Predator, TotalAvailableEnergy) :-
    available_energy_list(Predator, AvailableEnergyList),
    sum(AvailableEnergyList, TotalAvailableEnergy).


% max_allowable_abundance(Predator, MaxAbundance) returns true if MaxAbundance is equal to the TotalAvailableEnergy
% divided by the SingleEnergyRequirement (rounded down)
max_allowable_abundance(Predator, MaxAbundance) :-
    consumed_energy(Predator, SingleEnergyRequirement),
    sum_available_energy_list(Predator, TotalAvailableEnergy),
    MaxAbundance is floor(TotalAvailableEnergy/SingleEnergyRequirement).



% available_energy_new_abundance(Predator, (Prey,Abundance), AvailableEnergy) is true if the AvailableEnergy is 
% equal to the Freq*Abundance*ProducedEnergy
available_energy_new_abundance(Predator, (Prey,NewAbundance), AvailableEnergy) :-
    total_energy_produced_by_abundance(Prey, NewAbundance, ProducedEnergy),
    consumption(Prey, Predator, Freq),
    AvailableEnergy is ProducedEnergy*Freq.


% sum_energy_list_new_abundances(Predator, (Prey, Abundance), NewTotalAvailableEnergy) is true if the 
% TotalAvailableEnergy is the sum of all the available energies from a predator's preylist with the old 
% energy value removed and new energy value added
sum_energy_list_new_abundances(Predator, ChangedPreyList, NewTotalAvailableEnergy) :-
    available_energy_list(Predator, OriginalEnergyList),
    delta_prey_energy_list(Predator, ChangedPreyList, DeltaEnergyList),
    sum(OriginalEnergyList, OldTotalAvailableEnergy),
    sum(DeltaEnergyList, DeltaEnergies),
    NewTotalAvailableEnergy is OldTotalAvailableEnergy+DeltaEnergies.


% delta_prey_energy_list(Predator, ChangedPreyList, DeltaEnergies) is true when DeltaEnergies is the AvailableEnergy from 
% new abundances minus the 
delta_prey_energy_list(_, [], []).
delta_prey_energy_list(Predator, [(Prey, Abundance)|T1], [PreyDeltaEnergy|T2]) :-
    prey(Predator, PreyList),
    member(Prey, PreyList),
    available_energy_from_single_prey(Predator, Prey, CSV_Energy),
    available_energy_new_abundance(Predator, (Prey, Abundance), New_Energy),
    PreyDeltaEnergy is New_Energy-CSV_Energy,
    delta_prey_energy_list(Predator, T1, T2).
delta_prey_energy_list(Predator, [(_, _)|T1], [PreyDeltaEnergy|T2]) :-
    PreyDeltaEnergy is 0,
    delta_prey_energy_list(Predator, T1, T2).



% max_allowable_abundance_with_new_entries(Predator, (Prey, NewAbundance), NewMaxAbundance) returns true
% if MaxAbundance is equal to the TotalAvailableEnergy divided by the SingleEnergyRequirement (rounded down)
% (Considers the new abundance in calcualating the TotalAvailableEnergy)
max_allowable_abundance_with_new_entries(Predator, ChangedPreyList, NewMaxAbundance) :-
    consumed_energy(Predator, SingleEnergyRequirement),
    sum_energy_list_new_abundances(Predator, ChangedPreyList, TotalAvailableEnergy),
    NewMaxAbundance is floor(TotalAvailableEnergy/SingleEnergyRequirement).

% max_recursive_predator_abundances(Prey, MaxRecursivePredatorAbundances) is
% true if MaxRecursivePredatorAbundances is a list of
% abundance(Predator, MaxAbundance) predicates, where Predator is a recursive
% predator of Prey, and MaxAbundance is the maximum abundance of Predator given
% the energy requirement of Predator, and the abundance of Prey described in
% "animal_abundances.csv".
max_recursive_predator_abundances(Prey, MaxRecursivePredatorAbundances) :-
    recursive_predators(Prey, RecursivePredators),
    max_recursive_predator_abundances_helper(RecursivePredators,
                                             MaxRecursivePredatorAbundances).

% max_recursive_predator_abundances_helper(RecursivePredators,
% MaxRecursivePredatorAbundances) is true if MaxRecursivePredatorAbundances is
% a list of abundance(Predator, Abundance) values corresponding to the list of
% predators in RecursivePredators, and their max allowable abundances as per
% their prey abundances described in "animal_abundances.csv".
max_recursive_predator_abundances_helper([], []).
max_recursive_predator_abundances_helper([H1|T1],
                                         [abundance(H1, MaxAbundance)|T2]) :-
    max_allowable_abundance(H1, MaxAbundance),
    max_recursive_predator_abundances_helper(T1, T2).

% From Lecture
% sum(L,S) is true if S is the sum of the elements of numerical list L
sum([],0).
sum([H|T],S) :-
    sum(T,ST),
    S is H+ST.

cascading_abundance_changes(Animal,
                            NewAbundance,
                            CascadingAbundances) :-
    predators(Animal, Predators),
    cascading_abundance_changes_helper(Predators,
                                       [(Animal, NewAbundance)],
                                       CascadingAbundances).

cascading_abundance_changes_helper([],
                                   CascadingAbundances,
                                   CascadingAbundances).
cascading_abundance_changes_helper([H1|T1], Visited, CascadingAbundances) :-
    predators(H1, P1),
    max_allowable_abundance_with_new_entries(H1, Visited, A1),
    append(Visited, [(H1, A1)], NewVisited),
    remove_abundances_from_list(NewVisited, P1, FilteredVisited),
    append_new_elements(T1, P1, NewToVisit),
    cascading_abundance_changes_helper(NewToVisit,
                                       FilteredVisited,
                                       CascadingAbundances).

remove_abundances_from_list([], _, []).
remove_abundances_from_list([(Animal, _)|T1],
                            AnimalsToFilter,
                            FilteredAbundances) :-
  member(Animal, AnimalsToFilter),
  remove_abundances_from_list(T1, AnimalsToFilter, FilteredAbundances).
remove_abundances_from_list([(Animal, Abundance)|T1],
                            AnimalsToFilter,
                            [(Animal, Abundance)|FilteredAbundances]) :-
  not(member(Animal, AnimalsToFilter)),
  remove_abundances_from_list(T1, AnimalsToFilter, FilteredAbundances).

