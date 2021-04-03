% animal_produced_energy_csv_rows(Rows) is true if Rows is a list of
% row(Animal, ProducedEnergy) values corresponding to
% "animal_produced_energies.csv".
animal_produced_energy_csv_rows(Rows) :-
    csv_read_file("animal_produced_energies.csv",
                  Rows,
                  [skip_header('#')]).

% animal_produced_energies(ProducedEnergies) is true if Cost is a list of
% produced_energy(Animal, ProducedEnergy) values corresponding to
% "animal_produced_energies.csv".
animal_produced_energies(ProducedEnergies) :-
    animal_produced_energy_csv_rows(Rows),
    rows_to_animal_produced_energies(Rows, ProducedEnergies).

% rows_to_animal_produced_energies(Rows, ProducedEnergies) is true if Rows and
% ProducedEnergies are a list of row(Animal, ProducedEnergy) and
% produced_energy(Animal, ProducedEnergy) values corresponding to
% "animal_produced_energies.csv" respectively.
rows_to_animal_produced_energies([], []).
rows_to_animal_produced_energies([row(Animal, EnergyProduced)|T1],
                                 [produced_energy(Animal, EnergyProduced)|T2])
                                 :-
                                 rows_to_animal_produced_energies(T1, T2).

% produced_energy(Animal, ProducedEnergy) is true if ProducedEnergy is the
% energy produced by the animal for consumption as described in
% "animal_produced_energies.csv".
produced_energy(Animal, ProducedEnergy) :-
    animal_produced_energies(ProducedEnergies),
    member(produced_energy(Animal, ProducedEnergy), ProducedEnergies).

