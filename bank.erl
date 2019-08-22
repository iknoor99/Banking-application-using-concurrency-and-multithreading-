%% @author 14382
%% @doc @todo Add description to bank.

-module(bank).


%% ====================================================================
%% API functions
%% ====================================================================

-export([bankthread/3]).

bankthread(Bankname,Bankamount,Mapbanking)->
	
	chalreceivebank(Bankname,Bankamount,Mapbanking).
chalreceivebank(Bankname,Bankamount,Mapbanking) ->
	receive
		{Custname,Custamount} ->	
								
			if 
					Bankamount-Custamount >= 0 -> 
					Bankamountnew=Bankamount-Custamount,
					
				   	whereis(money)!{accept,Custname,Custamount,Bankname},
					chalreceivebank(Bankname,Bankamountnew,Mapbanking);
					
					true ->
			
						whereis(money)!{reject,Custname,Bankname,Custamount},
						chalreceivebank(Bankname,Bankamount,Mapbanking)

		    end;
	
		{bankmapfinal} ->
			
			whereis(money)!{lastdisplay,Bankname,Bankamount},
			chalreceivebank(Bankname,Bankamount,Mapbanking)
	
	
	%after 100 -> io:fwrite("")
				
	end.
%% ====================================================================
%% Internal functions
%% ====================================================================


