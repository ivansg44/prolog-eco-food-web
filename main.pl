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

animal_ok(Animal) :- animal_consumption_relationships(ConsumptionRelationships), total_energy_consumed_csv(Animal, ConsumedEnergy), animal_ok_helper(Animal, ConsumedEnergy, ConsumptionRelationships).

animal_ok_helper(Animal, RemainingEnergyReq, _) :- RemainingEnergyReq =< 0.
animal_ok_helper(Animal1, RemainingEnergyReq, [consumption(_, Animal2, _)|T]) :- dif(Animal1, Animal2), animal_ok_helper(Animal1, RemainingEnergyReq, T).
animal_ok_helper(Animal, RemainingEnergyReq, [consumption(ConsumedAnimal, Animal, Freq)|T]) :- total_energy_produced_csv(ConsumedAnimal, Total_Produced), animal_ok_helper(Animal, (RemainingEnergyReq-(Total_Produced*Freq)), T).


