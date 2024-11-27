%%%-------------------------------------------------------------------
%%% @author hugo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. nov. 2024 16:24
%%%-------------------------------------------------------------------
-module(task3).
-author("hugo").

%% API
-export([start/0]).

start() ->
  NumBelts = 2,
  NumTrucks = 3,
  CapacityTrucks = 5,
  PackageProducer = package_producer:start(),
  TruckProducer = truck_producer:start(NumTrucks, CapacityTrucks),

  Belts = create_belts(NumBelts, PackageProducer, TruckProducer),
  belts_routine(Belts).

create_belts(Num, PackageProducer, TrucksProducer) ->
  [belt:start(Id, PackageProducer, TrucksProducer) || Id <- lists:seq(1, Num)].

belts_routine(Belts) ->
  lists:foreach(fun(Belt) -> Belt ! {load_truck} end, Belts).