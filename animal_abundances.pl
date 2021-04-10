% animal_abundance_csv_rows(Rows) is true if Rows is a list of
% row(Animal,Abundance) values corresponding to "animal_abundances.csv".
% Try: animal_abundance_csv_rows(Rows).
animal_abundance_csv_rows(Rows) :-
    csv_read_file("animal_abundances.csv", Rows, [skip_header('#')]).

% animal_abundances(Abundances) is true if Abundances is a list of
% abundance(Animal,Abundance) values corresponding to "animal_abundances.csv".
% Try: animal_abundances(Abundances).
animal_abundances(Abundances) :-
    animal_abundance_csv_rows(Rows),
    rows_to_animal_abundances(Rows, Abundances).

% rows_to_animal_abundances(Rows, Abundances) is true if Rows and Abundances
% are a list of row(Animal, Abundance) and abundance(Animal, Abundance) values
% corresponding to "animal_abundances.csv" respectively.
% Try: rows_to_animal_abundances([row(dragon, 100), row(unicorn, 20)], Abundances).
rows_to_animal_abundances([], []).
rows_to_animal_abundances([row(Animal, Abundance)|T1],
                          [abundance(Animal, Abundance)|T2]) :-
    rows_to_animal_abundances(T1, T2).

% animal_abundance(Animal, Abundance) is true if Abundance is the abundance
% value for Animal described in "animal_abundances.csv".
% Try: animal_abundance(wolf, Abundance).
%      animal_abundance('fruit fly', Abundance).
animal_abundance(Animal, Abundance) :-
    animal_abundances(Abundances),
    member(abundance(Animal, Abundance), Abundances).

