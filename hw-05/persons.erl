-module(persons).

-include_lib("person.hrl").

-export([filter/2, all/2, any/2, update/2, get_average_age/1]).

filter(Fun, Persons) ->
    lists:filter(Fun, Persons).

all(Fun, Persons) -> 
    lists:all(Fun, Persons).

any(Fun, Persons) ->
    lists:any(Fun, Persons).

update(Fun, Persons) ->
    lists:map(Fun, Persons).

get_average_age(Persons) when length(Persons) > 0 ->
    {AgeSum, PersonsCount} = lists:foldl(
        fun(Person, {AccSum, AccCount}) ->
            {AccSum + Person#person.age, AccCount + 1}
        end,
        {0,0},
        Persons
    ),
    case PersonsCount of
        0 -> {error, no_persons};
        _Any -> AgeSum / PersonsCount
    end;
get_average_age(_) ->
    {error, empty_list}.
