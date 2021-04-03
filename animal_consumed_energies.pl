% animal_consumed_energy_csv_rows(Rows) is true if Rows is a list of
% row(Animal, ConsumedEnergy) values corresponding to
% "animal_consumed_energies.csv".
animal_consumed_energy_csv_rows(Rows) :-
    csv_read_file("animal_consumed_energies.csv",
                  Rows,
                  [skip_header('#')]).

% animal_consumed_energies(ConsumedEnergies) is true if Cost is a list of
% consumed_energy(Animal, ConsumedEnergy) values corresponding to
% "animal_consumed_energies.csv".
animal_consumed_energies(ConsumedEnergies) :-
    animal_consumed_energy_csv_rows(Rows),
    rows_to_animal_consumed_energies(Rows, ConsumedEnergies).

% rows_to_animal_consumed_energies(Rows, ConsumedEnergies) is true if Rows and
% ConsumedEnergies are a list of row(Animal, ConsumedEnergy) and
% consumed_energy(Animal, ConsumedEnergy) values corresponding to
% "animal_consumed_energies.csv" respectively.
rows_to_animal_consumed_energies([], []).
rows_to_animal_consumed_energies([row(Animal, EnergyConsumed)|T1],
                                 [consumed_energy(Animal, EnergyConsumed)|T2])
                                 :-
                                 rows_to_animal_consumed_energies(T1, T2).

% consumed_energy(Animal, ConsumedEnergy) is true if ConsumedEnergy is the
% energy consumed by the animal for consumption as described in
% "animal_consumed_energies.csv".
consumed_energy(Animal, ConsumedEnergy) :-
    animal_consumed_energies(ConsumedEnergies),
    member(consumed_energy(Animal, ConsumedEnergy), ConsumedEnergies).

