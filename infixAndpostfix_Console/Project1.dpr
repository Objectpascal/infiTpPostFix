program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  InfixToPostFix_u in 'InfixToPostFix_u.pas',
  stack_u in 'stack_u.pas',
  operation_u in 'operation_u.pas';

var
  f:TEvalueExpressions;
  exp:string;
begin
  f:=TEvalueExpressions.create();
  try
    f.ExpValue:='pow(-1,-1+21)';
    writeln('when update:',F.ExpValue);
    f.FillTheStack_and_PosFix();
    Writeln('postfix: ',f.PosFixString);
    writeln('result:',f.result);
//    f.ExpValue:='';
//    while true  do
//    begin
//    writeln;
//    write('-> ');readln(exp);
//    try
//        f.ExpValue:=exp;
//        writeln('-----------------------------------------------');
//        writeln('when update:',F.ExpValue);
//        f.FillTheStack_and_PosFix();
//        Writeln('postfix: ',f.PosFixString);
//        writeln('------------RESULT-----------------------------');
//        writeln('result:',f.result);
//        writeln('-----------------------------------------------');
//    except
//      on e:exception do
//        begin
//          Writeln(e.Message);
//          Sleep(1000);
//        end;
//
//    end;
//    end;
  finally
      f.Free;
  end;

 writeln('end');

  readln;
end.
