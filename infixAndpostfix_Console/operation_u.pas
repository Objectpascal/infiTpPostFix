unit operation_u;

interface
  uses System.SysUtils,System.classes;
  //#-------------------------------------------------------------------------
    Type
      TrecOperation=record
        OpName:string;
        OpPriority:byte;
        NumberOfArg:byte;
      end;
      TrecParentheses=record
        Open:string;
        Close:string;
      end;
      TopNames=(onMultiplication,onDivision,onAddition,onSubtraction,onSqrt,onCos,onSin,onPow,OnConstPi);
    const
      COperation:array[TopNames]of TrecOperation=(
                                             (OpName:'*';OpPriority:2;NumberOfArg:2)
                                            ,(OpName:'/';OpPriority:2;NumberOfArg:2)
                                            ,(OpName:'+';OpPriority:1;NumberOfArg:2)
                                            ,(OpName:'-';OpPriority:1;NumberOfArg:2)
                                            ,(OpName:'sqrt';OpPriority:3;NumberOfArg:1)
                                            ,(OpName:'cos';OpPriority:3;NumberOfArg:1)
                                            ,(OpName:'sin';OpPriority:3;NumberOfArg:1)
                                            ,(OpName:'pow';OpPriority:3;NumberOfArg:2)
                                            ,(OpName:'pi';OpPriority:3;NumberOfArg:0)

      );
     Cparentheses:array [1..3] of TrecParentheses=(
                                                (Open:'(';Close:')')
                                               ,(Open:'[';Close:']')
                                               ,(Open:'{';Close:'}')
     );
    type
    TOperation=record
    public
        class function IsOperation(const OpvalueStr:string):boolean;static;
        class function getOperationName(const OpvalueStr:string):TopNames;static;
        class function GetOperation(const opName:TopNames):TrecOperation;static;
        class function isOpenParentheses(const p:string):boolean;static;
        class function isCloseParentheses(const p:string):boolean;static;
        class function IsParenthesesSameType(const open:string;const close:string):boolean;static;
        class function HasHighPriority(const OpvalueStr1:string;const OpvalueStr2:string):boolean;static;
    end;

   //#-------------------------------------------------------------------------
implementation

{ TOperation }

class function TOperation.GetOperation(const opName: TopNames): TrecOperation;
begin
  result:=COperation[opName];
end;

class function TOperation.getOperationName(const OpvalueStr: string): TopNames;
var
  index:TopNames;
begin
  if not TOperation.IsOperation(OpvalueStr) then
    raise Exception.Create('[getOperationName]:its not valid Operations ');


  result:=onMultiplication;
  for index := Low(COperation) to High(COperation) do
      begin
         if (COperation[index].OpName=OpvalueStr) then
            begin
              result:=index;
              break;
            end;
      end;

end;

class function TOperation.HasHighPriority(const OpvalueStr1,
  OpvalueStr2: string): boolean;
var
  opName1,opName2:TopNames;
begin
  result:=false;
  opName1:=TOperation.getOperationName(OpvalueStr1);
  opName2:=TOperation.getOperationName(OpvalueStr2);
  Result:=TOperation.GetOperation(opName1).OpPriority > TOperation.GetOperation(opName2).OpPriority;
end;

class function TOperation.isCloseParentheses(const p: string): boolean;
var
  index:integer;
begin
  result:=false;
  for index := Low(Cparentheses) to High(Cparentheses) do
      begin
         if Cparentheses[index].Close=p then
            begin
              result:=true;
              break;
            end;
      end;

end;

class function TOperation.isOpenParentheses(const p: string): boolean;
var
  index:integer;
begin
  result:=false;
  for index := Low(Cparentheses) to High(Cparentheses) do
      begin
         if Cparentheses[index].Open=p then
            begin
              result:=true;
              break;
            end;
      end;

end;

class function TOperation.IsOperation(const OpvalueStr: string): boolean;
var
  index:TopNames;
begin
  result:=false;
  for index := Low(COperation) to High(COperation) do
      begin
         if (COperation[index].OpName=OpvalueStr) then
            begin
              result:=true;
              break;
            end;
      end;

end;
class function TOperation.IsParenthesesSameType(const open,
  close: string): boolean;
var
  index:integer;
begin
  result:=false;
  for index := Low(Cparentheses) to High(Cparentheses) do
      begin
         if (Cparentheses[index].Open=open) and (Cparentheses[index].Close=close) then
            begin
              result:=true;
              break;
            end;
      end;

end;


end.
