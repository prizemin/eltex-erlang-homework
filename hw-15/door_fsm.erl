%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. дек. 2023 8:46
%%%-------------------------------------------------------------------
-module(door_fsm).
-author("r0xyz").

-behavior(gen_statem).

%% API
-export([start_link/1, enter/2, set_new/3]).
-export([print_entered_nums/1]).
%% Callbacks
-export([init/1, callback_mode/0, locked/3, open/3, suspended/3, terminate/3]).

-define(SERVER, ?MODULE).

-record(door_data, {
  code                    :: list(),
  entered = []            :: list(),
  num_wrong_entered = 0   :: non_neg_integer()
}).

%% API
%% @doc Starts the linked process with initial code.
-spec(start_link(InitCode :: list()) -> {ok, pid()}).
start_link(InitCode) ->
  gen_statem:start_link(?MODULE, [InitCode], []).

%% @doc Entered an element to compare with the code.
-spec(enter(Pid :: pid(), Num :: integer()) -> {ok, atom()}).
enter(Pid, Num) ->
  gen_statem:call(Pid, {enter, Num}).

%% @doc Piecemeal entry of a new code.
-spec(set_new(Pid :: pid(), CodeLength :: non_neg_integer(), NewNum :: integer()) -> {ok, atom()}).
set_new(Pid, CodeLength, NewNum) ->
  gen_statem:call(Pid, {new_code, CodeLength, NewNum}).

%% @doc Print entered code.
-spec(print_entered_nums(Pid :: pid()) -> ok).
print_entered_nums(Pid) ->
  gen_statem:cast(Pid, print_entered_nums),
  ok.
%% Callbacks

init([InitCode]) ->
  io:format("Init callback was called~n"),
  process_flag(trap_exit, true),
  {ok, locked, #door_data{code = InitCode}}.

callback_mode() ->
  [state_functions, state_enter].

%% locked - open - suspended

locked(enter, State, DoorData) ->
  case State of
    suspended ->
      io:format("From ~p to the 'LOCKED'~n", [State]),
      {keep_state, DoorData#door_data{entered = [],num_wrong_entered = 0}};
    open ->
      io:format("From ~p to the 'LOCKED'~n", [State]),
      keep_state_and_data;
    locked ->
      keep_state_and_data
  end;

locked({call, From}, {enter, Num}, #door_data{code = Code, entered = EnteredCode0, num_wrong_entered = NumWrongTimes} = DoorData) ->
  io:format("Entered code ~p, current data ~p~n", [Num, DoorData]),
  %% 1 -> [1], 2 -> [2, 1], 3 -> [3, 2, 1]
  case length([Num | EnteredCode0]) == length(Code) of
    true ->
      EnteredCode = lists:reverse([Num | EnteredCode0]),
      case Code == EnteredCode of
        true ->
          io:format("Entered correct code~n"),
          {next_state, open, DoorData#door_data{entered = []}, [{reply, From, {ok, open}},
            {state_timeout, 10000, open_door_timeout}]};
        false ->
          case NumWrongTimes of
            3 ->
              io:format("Entered incorrect code~n"),
              {next_state, suspended, DoorData#door_data{num_wrong_entered = 0}, [{reply, From, {error, wrong_code_3_times}},
                {state_timeout, 30000, suspended_timeout}]};
            _ ->
              io:format("Entered wrong code~n"),
              {keep_state, DoorData#door_data{num_wrong_entered = NumWrongTimes + 1}, [{reply, From, {error, wrong_code}}]}
          end
      end;
    false ->
      io:format("Continue entering code~n"),
      {keep_state, DoorData#door_data{entered = [Num | EnteredCode0]},
        [{reply, From, {ok, next}}]}
  end;
locked(cast, print_entered_nums, #door_data{entered = Entered}) ->
  io:format("Entered nums: ~p~n", [lists:reverse(Entered)]),
  keep_state_and_data;
locked(info, {'EXIT', Pid, Reason}, _DoorData) ->
  io:format("Received EXIT msg from ~p in state ~p", [Pid, Reason]),
  {stop, shell_shutdown};
locked(info, {link, Pid}, _DoorData) ->
  link(Pid),
  io:format("Received link msg, createdlink with ~p", [Pid]),
  keep_state_and_data;
locked(info, Msg, DoorData) ->
  io:format("Received unhandled msg ~p in state ~p", [Msg, DoorData]),
  keep_state_and_data;
locked(state_timeout, set_code_timeout, _DoorData) ->
  io:format("Received state_timeout set_code_timeout~n", []),
  keep_state_and_data.

open(enter, State, DoorData) ->
  case State of
    open ->
      io:format("From ~p to the 'OPEN'~n", [State]),
      keep_state_and_data;
    locked ->
      io:format("From ~p to the 'OPEN'~n", [State]),
      {keep_state, DoorData#door_data{code = []}}
  end;
open({call, From}, {enter, Num}, _DoorData) ->
  io:format("The door opened, unhandled num ~p~n", [Num]),
  {keep_state_and_data, [{reply, From, {error, already_open}}]};
open({call, From}, {new_code, NewCodeLength, Num}, #door_data{code = Code} = DoorData) ->
  io:format("Received new code num ~p~n", [Num]),
  io:format("Code = ~p~n", [Code]),
  case length([Num | Code]) == NewCodeLength  of
    true ->
%%      io:format("length111: ~p~n", [length([Num | Code])]),
      RevCode = lists:reverse([Num | Code]),
      io:format("Entered new code ~p~n", [RevCode]),
      {next_state, locked, DoorData#door_data{code = RevCode, entered = []},
        [{reply, From, {ok, open}},
          {state_timeout, 15000, set_code_timeout}]};
    false ->
%%      io:format("length: ~p~n", [length([Num | Code])]),
      io:format("Continue entering code~n"),
      {keep_state, DoorData#door_data{code = [Num | Code]},
        [{reply, From, {ok, next}}, {state_timeout, cancel}]}
  end;
open(info, {'EXIT', Pid, Reason}, _DoorData) ->
  io:format("Received EXIT msg from ~p in state ~p", [Pid, Reason]),
  keep_state_and_data;
open(state_timeout, open_door_timeout, DoorData) ->
  io:format("Received state_timeout open_door_timeout~n", []),
  {next_state, locked, DoorData};
open(state_timeout, set_code_timeout, _DoorData) ->
  io:format("Received state_timeout set_code_timeout~n", []),
  keep_state_and_data.

suspended(enter, State, DoorData) ->
  io:format("From ~p to the 'SUSPENDED'~n", [State]),
  {keep_state, DoorData#door_data{entered = [], num_wrong_entered = 0}};
suspended({call, From}, {enter, _Num}, DoorData) ->
  io:format("Entered wrong code 3 times, wait 30 sec!~n"),
  {keep_state, DoorData#door_data{entered = [], num_wrong_entered = 0},
    [{reply, From, {wrong_code_3_times, suspended}}]};
suspended(state_timeout, suspended_timeout, DoorData) ->
  io:format("Received state_timeout suspended_door_timeout~n"),
  {next_state, locked, DoorData#door_data{num_wrong_entered = 0}}.



terminate(Reason, State, DoorData) ->
  io:format("Terminating with reason ~p, in state ~p, with data ~p~n", [Reason, State, DoorData]),
  ok.
