%%%-------------------------------------------------------------------
%%% @author hugo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. nov. 2024 18:29
%%%-------------------------------------------------------------------
-module(package_producer).
-author("hugo").

%% API
-export([start/0, loop/2]).

start() ->
  spawn(?MODULE, loop, [0, []]).

loop(PackageId, PackageStorage) ->
  receive
    {request_package, From} ->
      case PackageStorage of
         [] ->
           NewPackageId = PackageId + 1,
           NewPackageWeight = rand:uniform(5),
           From ! {package, {NewPackageId, NewPackageWeight}},
           loop(NewPackageId, []);
         [StoredPackage | T] ->
           From ! {package, StoredPackage},
           loop(PackageId, T)
      end;
    {send_back_package, PackageToStore} ->
      loop(PackageId, [PackageToStore] ++ PackageStorage);
    _ -> loop(PackageId, PackageStorage)
  end.