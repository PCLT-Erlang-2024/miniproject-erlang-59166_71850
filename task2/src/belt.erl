%%%-------------------------------------------------------------------
%%% @author hugo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. nov. 2024 16:25
%%%-------------------------------------------------------------------
-module(belt).
-author("hugo").

%% API
-export([start/3, loop/4]).

start(Id, PackageProducer, TrucksProducer) ->
  spawn(?MODULE, loop, [Id, [], PackageProducer, TrucksProducer]).

loop(Id, Trucks, PackageProducer, TrucksProducer) ->
  receive
    {request_truck} ->
      TrucksProducer ! {request_truck, self()},
      loop(Id, Trucks, PackageProducer, TrucksProducer);
    {add_truck, TruckPid} ->
      self() ! {load_truck},
      loop(Id, [TruckPid], PackageProducer, TrucksProducer);
    {no_more_trucks} -> io:format("[Belt ~p]: No more trucks available. Stopping belt. ~n", [Id]);
    {load_truck} ->
      case Trucks of
        [] ->
          self() ! {request_truck},
          loop(Id, Trucks, PackageProducer, TrucksProducer);
        [TruckPid] ->
          PackageProducer ! {request_package, self()},
          receive
            {package, {PackageId, PackageWeight}} ->
              TruckPid ! {can_load_package, PackageWeight, self()},
              receive
                {truck_can_load, TruckId} ->
                  io:format("[Belt ~p]: [Package ~p] with weight ~p loaded onto [Truck ~p].~n",
                    [Id, PackageId, PackageWeight, TruckId]),
                  self() ! {load_truck},
                  loop(Id, [TruckPid], PackageProducer, TrucksProducer);
                {truck_full, TruckId} ->
                  PackageProducer ! {send_back_package, {PackageId, PackageWeight}},
                  io:format("[Belt ~p]: [Truck ~p] is full, waiting for new truck.~n", [Id, TruckId]),
                  self() ! {request_truck},
                  loop(Id, [], PackageProducer, TrucksProducer)
              end
          end
      end;
    _ -> loop(Id, Trucks, PackageProducer, TrucksProducer)
  end.