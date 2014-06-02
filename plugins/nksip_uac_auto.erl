%% -------------------------------------------------------------------
%%
%% Copyright (c) 2013 Carlos Gonzalez Florido.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc Plugin implementing automatic registrations and pings support for SipApps.
-module(nksip_uac_auto).
-author('Carlos Gonzalez <carlosj.gf@gmail.com>').

-export([start_ping/5, stop_ping/2, get_pings/1]).
-export([start_register/5, stop_register/2, get_registers/1]).
-export([version/0, deps/0, parse_config/2]).


%% ===================================================================
%% Public
%% ===================================================================

%% @doc Version
-spec version() ->
    string().

version() ->
    "1.0".


%% @doc Dependant plugins
-spec deps() ->
    [{atom(), string()}].
    
deps() ->
    [].


%% @doc Starts a new registration serie.
-spec start_register(nksip:app_name()|nksip:app_id(), term(), nksip:user_uri(), pos_integer(),
                        nksip:optslist()) -> 
    {ok, boolean()} | {error, invalid_uri}.

start_register(App, RegId, Uri, Time, Opts) 
                when is_integer(Time), Time > 0, is_list(Opts) ->
    case nksip_parse:uris(Uri) of
        [ValidUri] -> 
            Msg = {'$nksip_uac_auto_start_register', RegId, ValidUri, Time, Opts},
            nksip:call(App, Msg);
        _ -> 
            {error, invalid_uri}
    end.


%% @doc Stops a previously started registration serie.
-spec stop_register(nksip:app_name()|nksip:app_id(), term()) -> 
    ok | not_found.

stop_register(App, RegId) ->
    nksip:call(App, {'$nksip_uac_auto_stop_register', RegId}).
    

%% @doc Get current registration status.
-spec get_registers(nksip:app_name()|nksip:app_id()) -> 
    [{RegId::term(), OK::boolean(), Time::non_neg_integer()}].
 
get_registers(App) ->
    nksip:call(App, '$nksip_uac_auto_get_registers').



%% @doc Starts a new automatic ping serie.
-spec start_ping(nksip:app_name()|nksip:app_id(), term(), nksip:user_uri(), pos_integer(),
                    nksip:optslist()) -> 
    {ok, boolean()} | {error, invalid_uri}.

start_ping(App, PingId, Uri, Time, Opts) 
            when is_integer(Time), Time > 0, is_list(Opts) ->
    case nksip_parse:uris(Uri) of
        [ValidUri] -> 
            Msg = {'$nksip_uac_auto_start_ping', PingId, ValidUri, Time, Opts},
            nksip:call(App, Msg);
        _ -> 
            {error, invalid_uri}
    end.


%% @doc Stops a previously started ping serie.
-spec stop_ping(nksip:app_name()|nksip:app_id(), term()) -> 
    ok | not_found.

stop_ping(App, PingId) ->
    nksip:call(App, {'$nksip_uac_auto_stop_ping', PingId}).
    

%% @doc Get current ping status.
-spec get_pings(nksip:app_name()|nksip:app_id()) -> 
    [{PingId::term(), OK::boolean(), Time::non_neg_integer()}].
 
get_pings(App) ->
    nksip:call(App, '$nksip_uac_auto_get_pings').


%% ===================================================================
%% Private
%% ===================================================================

%% @private
-spec parse_config(Config::term(), Opts::nksip:optslist()) ->
    {ok, Value::term()} | error.

parse_config({register, Register}, _Opts) ->
    case nksip_parse:uris(Register) of
        error -> error;
        Uris -> {update, Uris}
    end;

parse_config({register_expires, Expires}, _Opts) when is_integer(Expires), Expires>0 ->
    {update, Expires};

parse_config({nksip_uac_auto_timer, Timer}, _Opts) when is_integer(Timer), Timer>0 ->
    {update, Timer};

parse_config(_, _) ->
    error.


