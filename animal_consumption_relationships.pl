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

% TODO Not sure how to describe this
cascading_animals(Animal, CascadingAnimals) :-
    predators(Animal, Predators),
    cascading_animals_helper(Predators, [Animal], CascadingAnimals).

% TODO cascading_animals_helper(ToVisit, Visited, CascadingAnimals)
cascading_animals_helper([], CascadingAnimals, CascadingAnimals).
cascading_animals_helper([H1|T1], Visited, CascadingAnimals) :-
    predators(H1, P1),
    append(Visited, [H1], NewVisited),
    subtract_list(NewVisited, P1, FilteredVisited),
    append_new_elements(T1, P1, NewToVisit),
    cascading_animals_helper(NewToVisit, FilteredVisited, CascadingAnimals).

% append_new_elements(List1, List2, List3) is true if List3 is equal to a list
% of elements in List2 that were not already in List1 appended to List1.
append_new_elements(List1, [], List1).
append_new_elements(List1, [H2|T2], List3) :-
    member(H2, List1),
    append_new_elements(List1, T2, List3).
append_new_elements(List1, [H2|T2], List3) :-
    not(member(H2, List1)),
    append(List1, [H2], NewList1),
    append_new_elements(NewList1, T2, List3).

% recursive_predators(Prey, RecursivePredators) is true if RecursivePredators
% is a list of animals higher up on the food chain than Prey.
recursive_predators(Prey, RecursivePredators) :-
    recursive_predators_helper([Prey], RecursivePredators, [Prey]).

% recursive_predators_helper([Prey], RecursivePredators, VisitedAnimals) is
% true if RecursivePredators is a list recursive predators of Prey representing
% a successful iteration through the food web, using VistedAnimals as an
% accumulator.
recursive_predators_helper([], [], _).
recursive_predators_helper([H1|T1], RecursivePredators, VisitedAnimals) :-
    predators(H1, []),
    recursive_predators_helper(T1, RecursivePredators, VisitedAnimals).
recursive_predators_helper([H1|T1], RecursivePredators, VisitedAnimals) :-
    predators(H1, P1),
    subtract_list(P1, VisitedAnimals, FilteredP1),
    append(T1, FilteredP1, T1FilteredP1),
    append(VisitedAnimals, FilteredP1, NewVisitedAnimals),
    recursive_predators_helper(T1FilteredP1,
                               AlmostRecursivePredators,
                               NewVisitedAnimals),
    append(FilteredP1, AlmostRecursivePredators, RecursivePredators).

% subtract_list(List1, List2, List3) is True if List3 is List1 with all its
% elements also found in List2 removed.
subtract_list([], _, []).
subtract_list([H1|T1], List2, List3) :-
    member(H1, List2),
    subtract_list(T1, List2, List3).
subtract_list([H1|T1], List2, [H1|List3]) :-
    not(member(H1, List2)),
    subtract_list(T1, List2, List3).

