%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% Header file for use in multiple processes
%%% @end
%%% Created : 17. дек. 2023 17:57
%%%-------------------------------------------------------------------
-author("r0xyz").

-record(keylist_rec,{
  key = undefined      :: atom(),
  value = undefined    :: integer(),
  comment = undefined  :: string()
}).