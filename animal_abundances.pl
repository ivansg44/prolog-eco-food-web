% animal_abundance_csv_rows(Rows) is true if Rows is a list of
% row(Animal,Abundance) values corresponding to "animal_abundances.csv".
animal_abundance_csv_rows(Rows) :-
    csv_read_file("animal_abundances.csv", Rows, [skip_header('#')]).

% animal_abundances(Abundances) is true if Abundances is a list of
% abundance(Animal,Abundance) values corresponding to "animal_abundances.csv".
animal_abundances(Abundances) :-
    animal_abundance_csv_rows(Rows),
    rows_to_animal_abundances(Rows, Abundances).

% rows_to_animal_abundances(Rows, Abundances) is true if Rows and Abundances
% are a list of row(Animal, Abundance) and abundance(Animal, Abundance) values
% corresponding to "animal_abundances.csv" respectively.
rows_to_animal_abundances([], []).
rows_to_animal_abundances([row(Animal, Abundance)|T1],
                          [abundance(Animal, Abundance)|T2]) :-
    rows_to_animal_abundances(T1, T2).

% animal_abundance(Animal, Abundance) is true if Abundance is the abundance
% value for Animal described in "animal_abundances.csv".
animal_abundance(Animal, Abundance) :-
    animal_abundances(Abundances),
    member(abundance(Animal, Abundance), Abundances).

