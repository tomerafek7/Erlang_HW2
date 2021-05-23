-module (matrix_server).
-compie(export_all).

start_server() ->
	spawn(?MODULE, start_server_restarter, []).
	
	
start_server_restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(matrix_calc, matrix_server_loop, []),
	register(matrix_server, Pid),
	receive
		{'EXIT', Pid, normal} -> ok; % no crash
		{'EXIT', Pid, shutdown} -> ok; % no crash
		{'EXIT', Pid, _} -> start_server_restarter() % restart
	end.
	
shutdown() -> 
	matrix_server ! {shutdown}.
	
mult(Mat1,Mat2) ->
	matrix_server ! {self(),MsgRef=make_ref(),{multiple,Mat1,Mat2}} ,
	receive
		{MsgRef, Matrix} -> Matrix
	end.
	
get_version() ->
	matrix_server ! {self(),MsgRef=make_ref(),get_version} ,
	receive
		{MsgRef,VersionIdentifier} -> VersionIdentifier
	end.
explanation() ->
	{"ab"}.
	