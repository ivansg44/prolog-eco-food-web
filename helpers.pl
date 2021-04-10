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

% subtract_list(List1, List2, List3) is True if List3 is List1 with all its
% elements also found in List2 removed.
subtract_list([], _, []).
subtract_list([H1|T1], List2, List3) :-
    member(H1, List2),
    subtract_list(T1, List2, List3).
subtract_list([H1|T1], List2, [H1|List3]) :-
    not(member(H1, List2)),
    subtract_list(T1, List2, List3).

