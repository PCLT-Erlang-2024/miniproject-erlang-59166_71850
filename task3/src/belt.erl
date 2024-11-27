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
          TruckPid ! {is_truck_full, self()},
          receive
            {truck_full, TruckId} ->
              WaitingTime = rand:uniform(5),
              io:format("[Belt ~p]: [Truck ~p] is full, truck will take ~p seconds to be replaced.~n",
                [Id, TruckId, WaitingTime]),
              timer:sleep(round(timer:seconds(WaitingTime))),
              self() ! {request_truck},
              loop(Id, [], PackageProducer, TrucksProducer);
            {truck_not_full, TruckId} ->
              PackageProducer ! {request_package, self()},
              receive
                {package, PackageId} ->
                  TruckPid ! {load_package, self()},
                  io:format("[Belt ~p]: [Package ~p] loaded onto [Truck ~p].~n", [Id, PackageId, TruckId]),
                  self() ! {load_truck},
                  loop(Id, [TruckPid], PackageProducer, TrucksProducer)
              end
          end
      end;
    _ -> loop(Id, Trucks, PackageProducer, TrucksProducer)
  end.