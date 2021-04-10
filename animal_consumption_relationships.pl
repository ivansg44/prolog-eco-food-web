% animal_consumption_relationship_csv_rows(Rows) is true if Rows is a list of
% row(Animal, ConsumedBy, FrequencyOfConsumption) values corresponding to
% "animal_consumption_relationships.csv".
% Try: animal_consumption_relationship_csv_rows(Rows).
animal_consumption_relationship_csv_rows(Rows) :-
    csv_read_file("animal_consumption_relationships.csv",
                  Rows,
                  [skip_header('#')]).

% animal_consumption_relationships(ConsumptionRelationships) is true if
% ConsumptionsRelationships is a list of
% consumption(ConsumedAnimal, ConsumingAnimal, Freq) values corresponding to
% "animal_consumption_relationships.csv".
% Try: animal_consumption_relationships(ConsumptionRelationships).
animal_consumption_relationships(ConsumptionRelationships) :-
    animal_consumption_relationship_csv_rows(Rows),
    rows_to_consumption_relationships(Rows, ConsumptionRelationships).

% rows_to_consumption_relationships(Rows, ConsumptionRelationships) is true if
% Rows and ConsumptionRelationships are a list of row(Animal, ConsumedBy,
% FrequencyOfConsumption) and consumption(ConsumedAnimal, ConsumingAnimal,
% Freq) values corresponding to "animal_consumption_relationships.csv"
% respectively.
% Try: rows_to_consumption_relationships([row(unicorn, dragon, 0.5), row(pixies, unicorn, 0.9)], ConsumptionRelationships).
rows_to_consumption_relationships([], []).
rows_to_consumption_relationships([row(Animal,
                                       ConsumedBy,
                                       FrequencyOfConsumption)|T1],
                                  [consumption(Animal,
                                               ConsumedBy,
                                               FrequencyOfConsumption)|T2]) :-
    rows_to_consumption_relationships(T1, T2).

% consumption(ConsumedAnimal, ConsumingAnimal, Freq) is true if ConsumedAnimal
% is consumed by ConsumingAnimal at a rate of Freq compared to other animals
% that may consume it, as described in "animal_consumption_relationships.csv".
% Try: consumption(rat, ConsumingAnimal, Freq).
%      consumption(ConsumedAnimal, eagle, Freq).
consumption(ConsumedAnimal, ConsumingAnimal, Freq) :-
    animal_consumption_relationships(ConsumptionRelationships),
    member(consumption(ConsumedAnimal, ConsumingAnimal, Freq),
           ConsumptionRelationships).

% predators(Prey, Predators) is true if Predators is a list of animals that
% consumed Prey, as described in "animal_consumption_relationships.csv".
% Try: predators(rat, Predators).
predators(Prey, Predators) :-
    animal_consumption_relationships(ConsumptionRelationships),
    predators_helper(Prey, ConsumptionRelationships, Predators).

% predators(Prey, ConsumptionRelationships, Predators) is true if Predators is
% a list of animals from ConsumptionRelationships that consume Prey.
predators_helper(_, [], []).
predators_helper(Prey,
                 [consumption(Prey, Predator, _)|T1],
                 [Predator|T2]) :-
    predators_helper(Prey, T1, T2).
predators_helper(Prey1, [consumption(Prey2, _, _)|T1], T2) :-
    dif(Prey1, Prey2),
    predators_helper(Prey1, T1, T2).

% prey(Predator, Prey) is true if Prey is a list of animals that Prey consumes,
% as described in "animal_consumption_relationships.csv".
% Try: prey(eagle, Prey).
prey(Predator, Prey) :-
    animal_consumption_relationships(ConsumptionRelationships),
    prey_helper(Predator, ConsumptionRelationships, Prey).

% prey_helper(Predator, ConsumptionRelationships, Prey) is true if Prey is a
% list of animals from ConsumptionRelationships that Predator consumes.
prey_helper(_, [], []).
prey_helper(Predator,
            [consumption(Prey, Predator, _)|T1],
            [Prey|T2]) :-
    prey_helper(Predator, T1, T2).
prey_helper(Predator1, [consumption(_, Predator2, _)|T1], T2) :-
    dif(Predator1, Predator2),
    prey_helper(Predator1, T1, T2).

