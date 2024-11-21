%%%-------------------------------------------------------------------
%%% @author hugo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. nov. 2024 18:39
%%%-------------------------------------------------------------------
-module(truck_producer).
-author("hugo").

%% API
-export([start/2, loop/3]).

start(TruckAmount, TruckCapacity) ->
  spawn(?MODULE, loop, [TruckAmount, 0, TruckCapacity]).

loop(TruckAmount, CurrentTruckId, TruckCapacity) ->
  receive
    {request_truck, From} ->
      if
        CurrentTruckId < TruckAmount ->
          NewTruck = truck:start(CurrentTruckId+1, TruckCapacity),
          From !  {add_truck, NewTruck},
          loop(TruckAmount, CurrentTruckId+1, TruckCapacity);
        true ->
          From ! {no_more_trucks},
          loop(TruckAmount, CurrentTruckId, TruckCapacity)
      end;
    _ -> loop(TruckAmount, CurrentTruckId, TruckCapacity)
  end.