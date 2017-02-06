unit InfixToPostFix_u;

interface
      uses System.SysUtils,System.classes,Stack_u,Operation_u;

//#-------------------------------------------------------------------------

//#-------------------------------------------------------------------------
     type
       TEvalueExpressions=class
         private
          Fstack:Tstack;
          FposFix:TListPosFix;
          FExp:string;
           procedure setExpretion(const Value: string);
           procedure Fix_stackOperationPriorty(const opOrExp:string);
           procedure pushAllToPostFix();
           procedure fix_ClosingParentheses();
           procedure pust_numbersOnPostFix(const exp:string;var index:integer);
           procedure getOperation_subString(const exp:string;var substring:string;var index:integer);
           function getPostFixString: string;
           procedure calcOperation(opStr: string;var list:Tstack);
           function CalcResult(const op:TopNames;const v1:real;const v2:real):real;
           procedure fix_exp;
           procedure putPrentases_toOperation();//pow(2-1,1) --> pow( (2-1),(1));
           procedure putPrentases_toNumbers();//-1==>(-1)
    function getResult: string;
         public
            constructor create;overload;
            constructor create(const aExpValue:string);overload;
            destructor Destroy; override;
            procedure FillTheStack_and_PosFix;

            property ExpValue:string read FExp write setExpretion;
            property PosFixString:string read getPostFixString;
            property result:string read getResult;

       end;

//#-------------------------------------------------------------------------
implementation

{ TEvalueExpressions }
  uses math;
constructor TEvalueExpressions.create;
begin
  inherited create;
  Fstack:=Tstack.create;
  FposFix:=TListPosFix.create;
  FExp:='';
end;

procedure TEvalueExpressions.calcOperation(opStr: string;var list:Tstack);
var
  opName:TopNames;
  opRec:TrecOperation;
  opv1,opv2:string;
  resultValue:real;
begin
  resultValue:=0;
  opv1:='0';
  opv2:='0';
  opName:=TOperation.getOperationName(opStr);
  opRec:=TOperation.GetOperation(opName);
  if opRec.NumberOfArg=2 then
  begin

   opv2:=list.pop;
   if not list.IsEmpty then
      opv1:=list.pop;
   resultValue:=CalcResult(opName,StrToFloat(opv1),StrToFloat(opv2));

  end
  else
  if opRec.NumberOfArg=1 then
  begin
  if not list.IsEmpty then
   opv1:=list.pop;
   resultValue:=CalcResult(opName,StrToFloat(opv1),0);
  end
  else
  if opRec.NumberOfArg=0 then
  begin
   resultValue:=CalcResult(opName,0,0);
  end;


 list.Push(FloatToStr(resultValue));

end;

function TEvalueExpressions.CalcResult(const op: TopNames; const v1,
  v2: real): real;
begin
  case op of

    onMultiplication:result:=v1*v2 ;
    onDivision:Result:=v1/v2;
    onAddition: result:=v1+v2;
    onSubtraction:result:=v1-v2 ;
    onSqrt:result:=sqrt(v1) ;
    onCos:result:=cos(v1) ;
    onSin:result:=sin(v1) ;
    onPow:result:=Power(v1,v2);
    OnConstPi:result:=pi ;
   end;

end;

constructor TEvalueExpressions.create(const aExpValue: string);
begin
  create;
  ExpValue:=aExpValue;
end;


destructor TEvalueExpressions.Destroy;
begin
  if Assigned(Fstack) then
    begin
      FreeAndNil(Fstack);
    end;
  if Assigned(FposFix) then
  begin
      FreeAndNil(FposFix);
  end;
  inherited;
end;

procedure TEvalueExpressions.FillTheStack_and_PosFix;
var
  i:integer;
  substring:string;
  indexBef:integer;
begin
  if trim(FExp)='' then raise Exception.Create('[FExp]:Exp is Empty string');

  Fstack.clear;
  FposFix.clear;
  substring:='';
  i:=1;
  while (i<=length(FExp)) do
  begin
        begin
           substring:=FExp[i];
           if not TOperation.IsOperation(substring) then
           begin
              getOperation_subString(FExp,substring,i);
           end;
           substring:=LowerCase(substring);
          if TOperation.IsOperation(substring) then
          begin
               indexBef:=i-length(substring);
            if
               TOperation.isOpenParentheses(FExp[indexBef])
             or  TOperation.IsOperation(FExp[indexBef])
             or (indexBef<=0)
              then
              begin
              if (TOperation.getOperationName(substring)=onAddition) or (TOperation.getOperationName(substring)=onSubtraction) then

                FposFix.Push('0');
              end;

            Fix_stackOperationPriorty(substring);
            Fstack.Push(substring);
          end
          else
            if TOperation.isOpenParentheses(substring) then
            begin
                Fstack.Push(substring);
            end
          else
            if TOperation.isCloseParentheses(substring) then
            begin
               fix_ClosingParentheses();
            end
           else
           if substring[1] in ['0'..'9','.'] then

            begin
               pust_numbersOnPostFix(FExp,i);
            end;

        end;
      i:=i+1;
  end;
  pushAllToPostFix();

end;

procedure TEvalueExpressions.fix_ClosingParentheses;
begin
  while (not Fstack.IsEmpty) and (not TOperation.isOpenParentheses(Fstack.Top)) do
  begin
      FposFix.Push(Fstack.Top);
      Fstack.pop;
  end;
  Fstack.pop;//delete OpenParentheses
end;

procedure TEvalueExpressions.fix_exp;
var
  opName:TopNames;
  i:integer;
  indexSub,indexAfter:integer;
  substring,subAfter:string;
  closeAndOpenParentheses:string;
begin

//----------------------------Add () to operation thay have 0 arg exp:Pi()
  for opName := Low(TopNames) to High(TopNames) do
      begin
        if COperation[opName].NumberOfArg=0 then
          begin
            FExp:=StringReplace(FExp,COperation[opName].OpName,COperation[opName].OpName+'()',[rfReplaceAll,rfIgnoreCase]);
          end;
      end;

 putPrentases_toNumbers();
 putPrentases_toOperation();

end;


procedure TEvalueExpressions.Fix_stackOperationPriorty(const opOrExp: string);
begin
  while (not Fstack.IsEmpty) and (not TOperation.isOpenParentheses(Fstack.Top)) do
  begin
    if TOperation.IsOperation(Fstack.Top) and (TOperation.IsOperation(opOrExp)) then
      begin
          if TOperation.HasHighPriority(opOrExp,Fstack.Top) then
            begin
               Break;
            end;
      end;
    FposFix.Push(Fstack.Top);
    Fstack.pop;
  end;
end;

procedure TEvalueExpressions.getOperation_subString(const exp: string;
  var substring: string; var index: integer);
begin
 if  (not(substring[1] in ['0'..'9']))
                  and (not TOperation.isCloseParentheses(substring))
                   and (not TOperation.isOpenParentheses(substring))
                   and(not (substring=','))
                   then
                  begin
                    substring:='';
                    while( not(exp[index] in ['0'..'9']))
                      and (not TOperation.isCloseParentheses(exp[index]))
                         and (not TOperation.isOpenParentheses(exp[index]))
                         and (not TOperation.IsOperation(exp[index]))
                         and (index<=length(exp))
                          do
                         begin
                         substring:=substring+exp[index];
                         index:=index+1;
                         end;

                         index:=index-1;
                  end;
end;

function TEvalueExpressions.getPostFixString: string;
begin
  result:=FposFix.ToText;
end;

function TEvalueExpressions.getResult: string;
var
  resultStack:Tstack;
  index:integer;
  ValuePosfix:string;
begin
  result:='';
  ValuePosfix:='';
  resultStack:=Tstack.create;
  try
    for index := 0 to FposFix.count-1 do
    begin
     ValuePosfix:=FposFix.items[index];
     ValuePosfix:=LowerCase(ValuePosfix);
     if TOperation.IsOperation(ValuePosfix) then
        begin
          calcOperation(ValuePosfix,resultStack);
        end
      else
        begin
          resultStack.Push(ValuePosfix);
        end;
    end;
   result:=resultStack.Top;
  finally
    FreeAndNil(resultStack);
  end;

end;

procedure TEvalueExpressions.pushAllToPostFix;
begin
  while (not Fstack.IsEmpty) do
  begin
      FposFix.Push(Fstack.Top);
      Fstack.pop;
  end;
  //
end;

procedure TEvalueExpressions.pust_numbersOnPostFix(const exp: string;
  var index: integer);
var
  substring:string;
begin
  substring:='';
             while (not (TOperation.isCloseParentheses(exp[index])) )
                 and (not (TOperation.isOpenParentheses(exp[index])) )
                 and (not (TOperation.IsOperation(exp[index])) )
                 and (index<=length(exp))
                 and (exp[index] in ['0'..'9','.']) do
               begin

                 substring:=substring+exp[index];
                 index:=index+1;
               end;
               index:=index-1;
               substring:=LowerCase(substring);
               FposFix.Push(substring);
end;

procedure TEvalueExpressions.putPrentases_toNumbers;
var
  i,indexBefor,indexAfter:integer;
  OpStr,subStringAfter,strPrentasess:string;
  OpName:TopNames;
begin
  { TODO :
put prentases to operation like -1=> (-1)
pow(1,2+2)==>pow((1),(2+2)) }
  i:=1;
  OpStr:='';
  while i<=length(FExp) do
  begin
   OpStr:=FExp[i];
   if (not TOperation.IsOperation(OpStr))  then
    begin
        OpStr:='';
        while    (not(FExp[i] in ['0'..'9']))
             and (not TOperation.isOpenParentheses(FExp[i]))
             and (not TOperation.isCloseParentheses(FExp[i]))
         do
           begin
             OpStr:=OpStr+FExp[i];
              if TOperation.IsOperation(OpStr) then
                  break;
             i:=i+1;
           end;

    end;
    if Length(OpStr)>0 then
      begin
          if TOperation.IsOperation(OpStr) then
            begin

              OpName:=TOperation.getOperationName(OpStr);
              if (OpName=onAddition) or (OpName=onSubtraction) then
                begin
                // here only + and - go here
                  subStringAfter:='';
                  strPrentasess:='';
                  indexAfter:=i+1;//Length(TOperation.GetOperation(OpName).OpName); //i:=i+1 the same thing
                  while (indexAfter<=length(FExp))
                  do
                  begin
                     if TOperation.isOpenParentheses(FExp[indexAfter]) then
                        strPrentasess:=strPrentasess+'('
                     else
                      if ( TOperation.isCloseParentheses(FExp[indexAfter]) and ( length(strPrentasess)>0)  ) then
                        begin
                          Delete(strPrentasess,length(strPrentasess),1);
                          subStringAfter:=subStringAfter+')';
                        end;

                       if ( (length(strPrentasess)=0) and   ((TOperation.IsOperation(FExp[indexAfter]))  or (FExp[indexAfter] in [',']) ) )  then
                       begin

                        break;

                       end;
                      if not TOperation.isCloseParentheses(FExp[indexAfter]) then
                           subStringAfter:=subStringAfter+FExp[indexAfter];
                      indexAfter:=indexAfter+1;
                  end;
                    //  writeln('after:',subStringAfter);

                  // here only + and - go here
                       indexBefor:=i-length(OpStr);
                       if indexBefor>0 then
                       begin
                          if (TOperation.isOpenParentheses(FExp[indexBefor]))
                              or(TOperation.IsOperation(FExp[indexBefor]))
                           then
                           begin
                         //   writeln('ok');
                             Insert('(',FExp,i);
                             Insert(')',FExp,i+length(subStringAfter)+2);
                             i:=i+length(subStringAfter)+3;
                           end;

                       end//End indexBefor>0
                       else// else  indexBefor=0
                       begin
                     //  writeln('ok');
                           //here indexBefor its zero 0
                           Insert('(',FExp,i);
                           Insert(')',FExp,i+length(subStringAfter)+2);
                           i:=i+length(subStringAfter)+3;
                       end;//




                end;// End if (OpName=onAddition) or (OpName=onSubtraction) then





            end;// End IsOperation


      end;// end Length(OpStr)>0


  i:=i+1;
  end;// End Main While Loop

end;
procedure TEvalueExpressions.putPrentases_toOperation;
var
  i,indexBefor,indexAfter:integer;
  OpStr,subStringAfter,strPrentasess:string;
  OpName:TopNames;
begin
{ TODO :
put prantases to operation like pow(1,2+2)
==> pow((1),(2+2)) }
i:=1;
opStr:='';
    while i<=length(FExp) do
    begin
         OpStr:=FExp[i];
         if (not TOperation.IsOperation(OpStr))  then
          begin
              OpStr:='';
              while    (not(FExp[i] in ['0'..'9']))
                   and (not TOperation.isOpenParentheses(FExp[i]))
                   and (not TOperation.isCloseParentheses(FExp[i]))
               do
                 begin
                   OpStr:=OpStr+FExp[i];
                    if TOperation.IsOperation(OpStr) then
                        break;
                   i:=i+1;
                 end;

          end;
          //----------------------------
         if Length(OpStr)>0 then
            begin
                if TOperation.IsOperation(OpStr) then
                  begin

                    OpName:=TOperation.getOperationName(OpStr);
                    if (OpName=onSqrt) or (OpName=onCos)or (OpName=onSin) or (OpName=onPow) then
                      begin
                           // here only + and - go here
                          subStringAfter:='';
                          strPrentasess:='';
                          indexAfter:=i+1; //i:=i+1 the same thing
                          while (indexAfter<=length(FExp))
                          do
                          begin
                             if TOperation.isOpenParentheses(FExp[indexAfter]) then
                                strPrentasess:=strPrentasess+'('
                             else
                              if ( TOperation.isCloseParentheses(FExp[indexAfter]) and ( length(strPrentasess)>0)  ) then
                                begin
                                  Delete(strPrentasess,length(strPrentasess),1);
                                  subStringAfter:=subStringAfter+')';
                                end;

                               if ( (length(strPrentasess)=0) and   ((TOperation.IsOperation(FExp[indexAfter]))  or (FExp[indexAfter] in [',']) ) )  then
                               begin

                                break;

                               end;
                              if not TOperation.isCloseParentheses(FExp[indexAfter]) then
                                   subStringAfter:=subStringAfter+FExp[indexAfter];
                              indexAfter:=indexAfter+1;
                          end;

                            //Writeln('str afterll:',subStringAfter);
                            if pos(',',subStringAfter)>0 then
                              begin
                                { TODO :
                                  error when pow insde pow
                                  pow(pow(1,2),2);
                                  error its position of ,
                                  we need get last , position
                                   }
//                                insert('[',FExp,i+2);
//                                insert(']',FExp,i+pos(',',subStringAfter)+1);
//                                insert('[',FExp,i+pos(',',subStringAfter)+3);
//                                insert(']',FExp,i+length(subStringAfter)+3);
                              end
                            else
                              begin
                                insert('[',FExp,i+2);
                                Insert(']',FExp,i+length(subStringAfter)+1);
                               // i:=i+Length(subStringAfter)+2;
                              //  writeln(i);
                              end;

                end;// End if (OpName=onSqrt) or (OpName=onCos)or (OpName=onSin) or (OpName=onPow) then





                  end;// End IsOperation


            end;// end Length(OpStr)>0


    i:=i+1;
    end;//end loop
end;

procedure TEvalueExpressions.setExpretion(const Value: string);
begin
  FExp := Value;
  fix_exp;
end;

end.
