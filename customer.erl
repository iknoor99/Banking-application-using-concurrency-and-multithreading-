%% @author 14382
%% @doc @todo Add description to customer.

-module(customer).

-export([custthread/4]).
-export([for/4]).
-import(lists,[delete/2]).

custthread(Custname,Custamount,Banklt,Mapcust)->	
	
	%io:fwrite("customerrrrr ~p~n",[Custname]),
	%io:fwrite("customerrrrr ~p~n",[Custamount]).
	B = Banklt,
	
	for(Custname,Custamount,B,Mapcust).
	
for(Custname,0,B,Mapcust) -> 
   whereis(money)!{finishcust,Custname,0,Mapcust}; 
   
for(Custname,Custamount,B,Mapcust) when Custamount > 0 -> 
	
	%io:fwrite("banks left for ~p are ~p ~n",[Custname,B]),
	Lenbanklist=length(B),
	%io:fwrite("length is ---------------:~p ~n",[Lenbanklist]),
	%io:fwrite(" Bankname list new ~p for in for ~p ~n",[B,Custname]),
	
	if Lenbanklist == 0 ->
		  %io:fwrite("banks left for ~p are ~p ~n",[Custname,B]),
		  Custearamount=maps:get(Custname,Mapcust),
		  Custamountborr=Custearamount-Custamount,
		  whereis(money)!{incompfinishcust,Custname,Custamountborr};
	   
	true ->
		  io:fwrite("")
	end,
	
	
	Bankval=lists:nth(rand:uniform(length(B)), B),
	checkval(Custamount,Custname,Bankval,B,Mapcust).


checkval(Custamount,Custname,Bankval,B,Mapcust) ->	
	
	
	Numb=rand:uniform(50),
	A1 = Custamount,
	B1= Bankval,
	if Numb =< A1 ->
		   %io:fwrite("correct numb is ~p ~n",[Numb]),

		   
		   whereis(money)!{requestdisplay,Custname,Numb,B1},
		   %io:fwrite("control came back for ~p ~p ~p ~n",[Custname,Numb,B1]),
		   
		   Slp=rand:uniform(100),
		   timer:sleep(Slp),
		   
		   whereis(B1)!{Custname,Numb};
	   true ->
		   %io:fwrite("wrong amount is ~p ~n",[Numb]),
		   checkval(Custamount,Custname,B1,B,Mapcust)
	end,	   
		   	
	%io:fwrite("numb is ~p ~n",[Numb]),
	
	chalreceivecustomer(Custname,Custamount,B,Mapcust).

chalreceivecustomer(Custname,Custamount,B,Mapcust) ->
						   
	receive
		
		{givenloan,Name,Amount} ->	
			
			%io:fwrite("bankeeeee~p~n",[Bankamount])
					
		    %io:fwrite("message reply from money to customer ~p to deduct ~p from its total amount ~n",[Name,Amount]),
			
			%io:fwrite("earlier amount of cust ~p is ~p",[Custname,Custamount]),

			Custamountnew=Custamount-Amount,
			
			%io:fwrite("new amount of cust ~p is ~p",[Custname,Custamountnew]),
			
			%io:fwrite("Reduced amount for ~p is ~p ~n",[Name,Custamountnew]),
			%chalreceivecustomer(Custname,Custamount,B)
			for(Custname,Custamountnew,B,Mapcust),
	        chalreceivecustomer(Custname,Custamount,B,Mapcust);
			
		
		{notgivenloan,Cname,Bname,Camount} ->	
			
			%io:fwrite("message reply from money to customer ~p that loan rejected from ~p ~n",[Cname,Bname]),
			%io:fwrite("bankeeeee~p~n",[Bankamount]).
			%io:fwrite(" Bankname list old--~p ~n",[B]),
			Bank1 = Bname,
			Bnew = delete(Bank1,B),
			%io:fwrite(" Bankname list notgivenloan new--~p for ~p ~n",[Bnew,Cname]),
			for(Custname,Custamount,Bnew,Mapcust),
	    	chalreceivecustomer(Custname,Custamount,Bnew,Mapcust)
			
	end.
		
	%io:fwrite("Bankval ~p~n",[Bankval]).
	
%% ====================================================================
%% Internal functions
%% ====================================================================


