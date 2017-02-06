unit stack_u;

interface
uses System.sysUtils,System.classes;
   Type
        Tstack=class
          private
            FList:TStringList;
              function getIsEmpty: boolean;
              function getTopString: string;
          public
            Constructor create;virtual;
            destructor destroy;Override;
            function pop():string;
            procedure Push(const value:string);
            procedure clear;
            property IsEmpty:boolean read getIsEmpty;
            property Top:string read getTopString;
        end;
       TListPosFix=class(Tstack)
  private
    function getItems(index: integer): string;
    function getStringText: string;
    function getCount: integer;
       public
          constructor create; override;
          destructor Destroy; override;

       property items[index:integer]:string read getItems;
       property ToText:string read getStringText;
       property count:integer read getCount;
       end;
implementation

{ Tstack }

procedure Tstack.clear;
begin
  FList.Clear;
end;

constructor Tstack.create;
begin
  inherited create;
  FList:=TStringList.Create;
end;

destructor Tstack.destroy;
begin
  if Assigned(FList) then
  begin
    FList.Clear;
    FreeAndNil(FList);
  end;
  inherited;
end;

function Tstack.getIsEmpty: boolean;
begin
  result:=FList.Count=0;
end;

function Tstack.getTopString: string;
begin
  result:='';
  if IsEmpty then raise Exception.Create('[getTopString]:List Its Empty there is No Top ');

  result:=FList.Strings[FList.Count-1];
end;

function Tstack.pop: string;
var
  LastIndex:integer;
begin
  result:='';
    if IsEmpty then raise Exception.Create('[pop]:List its Empty Can not pop');

  LastIndex:=FList.Count-1;
  result:=FList.Strings[LastIndex];
  FList.Delete(LastIndex);
end;

procedure Tstack.Push(const value: string);
begin
  FList.Add(value);
end;

{ TListPosFix }

constructor TListPosFix.create;
begin
  inherited;

end;

destructor TListPosFix.Destroy;
begin

  inherited;
end;

function TListPosFix.getCount: integer;
begin
  result:=FList.Count;
end;

function TListPosFix.getItems(index: integer): string;
begin
  if (index<0) or (index>FList.Count) then raise Exception.Create('[getItems]:index of item its out of length of the list');
  result:=FList.Strings[index];
end;

function TListPosFix.getStringText: string;
var
  i:integer;
begin
  result:='';
  for i := 0 to FList.count-1 do
    result:=result+FList.Strings[i]+',';
  Delete(result,length(result),1);
end;

end.
