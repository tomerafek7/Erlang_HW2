-module(matrix_calc).
-compile(export_all). 
-record(state, {server, name="", to_go=0}).

matrix_server_loop() ->
	receive
		{Pid, MsgRef, {multiple, Mat1, Mat2}} ->
			spawn(matrix_calc, mat_mul, [Mat1, Mat2, Pid, MsgRef]),
			matrix_server_loop();
		shutdown ->
			A=1;
		{Pid, MsgRef, get_version} ->
			A=1;
		sw_upgrade ->
			A=1
	end.

mat_mul(Mat1, Mat2, Pid, MsgRef) ->
	{Rows,Cols} = mat_mul_send(Mat1, Mat2),
	Pid ! {MsgRef, mat_mul_receive(0, matrix_utils:getZeroMat(Rows, Cols))}.

mat_mul_send(Mat1, Mat2) ->
	%create a process for each output element (rowXcol)
	{Rows,Cols} = matrix_utils:getOutputDim(Mat1, Mat2),
	[spawn(matrix_calc, vector_mul, [self(), matrix_utils:getRow(Mat1,X), matrix_utils:getCol(Mat2,Y), X, Y]) || X <- lists:seq(1,Rows), Y <- lists:seq(1,Cols)],
	{Rows,Cols}.

	
mat_mul_receive(NumOfResp, CurMat) ->
	% and wait for all processes to finish and return
	Size = matrix_utils:getSize(CurMat),
	if 
		NumOfResp == Size -> 
			CurMat;
		true ->
			receive
				{X, Y, Val} ->
					mat_mul_receive(NumOfResp+1, matrix_utils:setElementMat(X, Y, CurMat, Val))
			end
	end.
	
vector_mul(Pid, Row, Col, X, Y) ->
	ListToSum = [ element(I,Row) * element(I,Col) || I <- lists:seq(1,tuple_size(Row)) ],
	Val = lists:sum(ListToSum),
	Pid ! {X, Y, Val}.
	
	
