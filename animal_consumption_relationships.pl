% animal_consumption_relationship_csv_rows(Rows) is true if Rows is a list of
% row(Animal, ConsumedBy, FrequencyOfConsumption) values corresponding to
% "animal_consumption_relationships.csv".
animal_consumption_relationship_csv_rows(Rows) :-
    csv_read_file("animal_consumption_relationships.csv",
                  Rows,
                  [skip_header('#')]).

% animal_consumption_relationships(ConsumptionRelationships) is true if
% ConsumptionsRelationships is a list of
% consumption(ConsumedAnimal, ConsumingAnimal, Freq) values corresponding to
% "animal_consumption_relationships.csv".
animal_consumption_relationships(ConsumptionRelationships) :-
    animal_consumption_relationship_csv_rows(Rows),
    rows_to_consumption_relationships(Rows, ConsumptionRelationships).

% rows_to_consumption_relationships(Rows, ConsumptionRelationships) is true if Rows and ConsumptionRelationships are a list of row(Animal, ConsumedBy, FrequencyOfConsumption) and consumption(ConsumedAnimal, ConsumingAnimal, Freq) values corresponding to "animal_consumption_relationships.csv" respectively.
rows_to_consumption_relationships([], []).
rows_to_consumption_relationships([row(Animal,
                                       ConsumedBy,
                                       FrequencyOfConsumption)|T1],
                                  [consumption(Animal,
                                               ConsumedBy,
                                               FrequencyOfConsumption)|T2]) :-
    rows_to_consumption_relationships(T1, T2).

% consumption(ConsumedAnimal, ConsumingAnimal, Freq) is true if ConsumedAnimal is consumed by ConsumingAnimal at a rate of Freq compared to other animals that may consume it, as described in "animal_consumption_relationships.csv".
consumption(ConsumedAnimal, ConsumingAnimal, Freq) :-
    animal_consumption_relationships(ConsumptionRelationships),
    member(consumption(ConsumedAnimal, ConsumingAnimal, Freq),
           ConsumptionRelationships).

% predators(Prey, Predators) is true if Predators is a list of animals that
% consumed Prey, as described in "animal_consumption_relationships.csv".
predators(Prey, Predators) :-
    animal_consumption_relationships(ConsumptionRelationships),
    predators_helper(Prey, ConsumptionRelationships, Predators).

% predators(Prey, ConsumptionRelationships, Predators) is true if Predators is
% a list of animals from ConsumptionRelationships that consume Prey.
predators_helper(Prey, [], []).
predators_helper(Prey,
                 [consumption(Prey, Predator, _)|T1],
                 [Predator|T2]) :-
    predators_helper(Prey, T1, T2).
predators_helper(Prey1, [consumption(Prey2, Predator, _)|T1], T2) :-
    dif(Prey1, Prey2),
    predators_helper(Prey1, T1, T2).

% prey(Predator, Prey) is true if Prey is a list of animals that Prey consumes,
% as described in "animal_consumption_relationships.csv".
prey(Predator, Prey) :-
    animal_consumption_relationships(ConsumptionRelationships),
    prey_helper(Predator, ConsumptionRelationships, Prey).

% prey_helper(Predator, ConsumptionRelationships, Prey) is true if Prey is a
% list of animals from ConsumptionRelationships that Predator consumes.
prey_helper(Predator, [], []).
prey_helper(Predator,
            [consumption(Prey, Predator, _)|T1],
            [Prey|T2]) :-
    prey_helper(Predator, T1, T2).
prey_helper(Predator1, [consumption(Prey, Predator2, _)|T1], T2) :-
    dif(Predator1, Predator2),
    prey_helper(Predator1, T1, T2).

% append_without_duplicating(List1, List2, List3) is True if List3 is equal the result of adding all elements from List2 that are not already in List1, to the end of List1.
append_without_duplicating(List1, [], List1).
append_without_duplicating(List1, [H2|T2], List3) :-
    member(H2, List1),
    append_without_duplicating(List1, T2, List3).
append_without_duplicating(List1, [H2|T2], List3) :-
    not(member(H2, List1)),
    append(List1, [H2], NewList1),
    append_without_duplicating(NewList1, T2, List3).

