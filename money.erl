%% @author 14382
%% @doc @todo Add description to money.

-module(money).
-import(lists,[nth/2]).
-export([start/0]).
-export([thcall/3]).
-import(customer,[custthread/3]).
-import(bank,[bankthread/2]).
-import(lists,[append/2]). 
-import(lists,[delete/2]).

start() -> 
	
   register(money,self()),
   
   {ok,Banklist}=file:consult("banks.txt"),
   
    Mapbanking = maps:from_list(Banklist),
	List1 = [],
   	List2 = thcall(Banklist,List1,Mapbanking),
     
	Custkeyss=startcust(List2,Banklist),  
   	chalreceivemoney(Custkeyss,Mapbanking).
   
chalreceivemoney(Custkeyss,Mapbanking) ->
	
   	receive
		{accept,CustName,CustAmount,Bankname} ->	
					
		    io:fwrite("~p approves a loan of ~p from ~p ~n",[Bankname,CustAmount,CustName]),
			
		    whereis(CustName)!{givenloan,CustName,CustAmount},
			chalreceivemoney(Custkeyss,Mapbanking);
			
		{reject,Custname,Bankname,Custamount} ->
			
			io:fwrite("~p denies a loan of ~p dollars from ~p ~n",[Bankname,Custamount,Custname]),
			whereis(Custname)!{notgivenloan,Custname,Bankname,Custamount},
			chalreceivemoney(Custkeyss,Mapbanking);
		
		{requestdisplay,Custname,Numb,B1} ->
			io:fwrite("~p requests a loan of ~p from ~p ~n",[Custname,Numb,B1]),
			chalreceivemoney(Custkeyss,Mapbanking);

		{finishcust,Custname,Custamount,Mapcust} -> 
				Amountreq=maps:get(Custname,Mapcust),
				io:fwrite("~p has reached the objective of ~p dollar(s). Woo Hoo! ~n",[Custname,Amountreq]),
				Custkeyss1= delete(Custname,Custkeyss),
				Mapbankinglist=maps:keys(Mapbanking),
				
				if length(Custkeyss1)==0 ->
					   
					 docustomer(Mapbankinglist);					
				  
				  true ->
					  io:fwrite("")
				end,
				
				chalreceivemoney(Custkeyss1,Mapbanking);
		
		{incompfinishcust,Custname,Custamountborr} ->
			
			io:fwrite("~p was only able to borrow ~p dollar(s). Boo Hoo! ~n",[Custname,Custamountborr]),
			Custkeyss1= delete(Custname,Custkeyss),
			Mapbankinglist=maps:keys(Mapbanking),
			%io:fwrite("Map banking list:~p~n",[Mapbankinglist]),
							
				if length(Custkeyss1)==0 ->
					 
				  	docustomer(Mapbankinglist);
				  true ->
					  io:fwrite("")
				end,
			
			chalreceivemoney(Custkeyss1,Mapbanking);
	
		{lastdisplay,Fundsname, Funds} ->
			
					io:fwrite("~p has ~p dollar(s) remaining.~n", [Fundsname, Funds]),
				chalreceivemoney(Custkeyss,Mapbanking)			
			
	end.

callbanks(0,_) ->
	io:fwrite("");

callbanks(L,Mapbankinglist) ->
	
	Onebank = nth(L,Mapbankinglist),

	whereis(Onebank)!{bankmapfinal},
	callbanks(L-1,Mapbankinglist).
	
docustomer(Mapbankinglist) ->
	
	io:fwrite("~n"),
	L = length(Mapbankinglist),
	callbanks(L,Mapbankinglist).
	
thcall([],List2,_)-> List2;
thcall([H|T],List1,Mapbanking) ->
	Bankname=lists:nth(1,tuple_to_list(H)),
	Bankamount=lists:nth(2,tuple_to_list(H)),
		
   	Pid = spawn(bank, bankthread, [Bankname,Bankamount,Mapbanking]),	
	register(Bankname,Pid),
	List2 = append(List1,[Bankname]),
	%io:fwrite("List1 in the call: ~p~n",[List1]),
	%List1 = Bankname ++ list1,

	thcall(T,List2,Mapbanking).

startcust(List2,Banklist) -> 

   {ok,Custlist}=file:consult("customers.txt"),
   
   Mapcust = maps:from_list(Custlist),
   
   io:fwrite("** Customers and loan objectives ** ~n"),
   
   maps:fold(
	fun(Key,Value, ok) ->
			
		io:fwrite("~p: ~p~n", [Key, Value])
	end, ok,Mapcust),
   
   io:fwrite("~n"),
   io:fwrite("~n"),
 
   Mapbank = maps:from_list(Banklist),
   
   io:fwrite("** Banks and financial resources ** ~n"),
   
   maps:fold(
	fun(Key,Value, ok) ->
		io:fwrite("~p: ~p~n", [Key, Value])
	end, ok,Mapbank),   
   
   io:fwrite("~n"),
   io:fwrite("~n"),
   
   Custkeys=thcall1(Custlist,List2,Mapcust),
   Custkeys.
  
thcall1([],_,Mapcust)-> maps:keys(Mapcust);
thcall1([H|T],List2,Mapcust) ->	
	Custname=lists:nth(1,tuple_to_list(H)),
	Custamount=lists:nth(2,tuple_to_list(H)),
	
	%io:fwrite("~p~n",[Custname]),
	%io:fwrite("~p~n",[Custamount]),
	
   	Pid = spawn(customer, custthread, [Custname,Custamount,List2,Mapcust]),	
			register(Custname,Pid),

	thcall1(T,List2,Mapcust).






