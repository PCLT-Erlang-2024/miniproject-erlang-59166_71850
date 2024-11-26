%%%-------------------------------------------------------------------
%%% @author hugo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. nov. 2024 16:25
%%%-------------------------------------------------------------------
-module(truck).
-author("hugo").

%% API
-export([start/2, loop/3]).

start(Id, Capacity) ->
  spawn(?MODULE, loop, [Id, Capacity, 0]).

loop(Id, Capacity, Occupation) ->
  receive
    {is_truck_full, From} ->
      if
        Occupation < Capacity ->
          From ! {truck_not_full, Id},
          loop(Id, Capacity, Occupation);
        true ->
          From ! {truck_full, Id},
          io:format("[Truck ~p] is leaving. Final occupation: ~p~n", [Id, Occupation])
      end;
    {can_load_package, Weight, From} ->
      if
        Occupation + Weight =< Capacity ->
          NewOccupation = Occupation + Weight,
          From ! {truck_can_load, Id},
          loop(Id, Capacity, NewOccupation);
        true ->
          From ! {truck_full, Id},
          io:format("[Truck ~p] is leaving. Final occupation: ~p~n", [Id, Occupation])
      end;
    {load_package, Weight, From} ->
        NewOccupation = Occupation + Weight,
        From ! {package_loaded, Id},
        loop(Id, Capacity, NewOccupation);
    _ -> loop(Id, Capacity, Occupation)
  end.
