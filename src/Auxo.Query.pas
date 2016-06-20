unit Auxo.Query;

interface

uses
  Auxo.Query.Core, System.Generics.Collections, Auxo.Query.Compiled, Auxo.Query.Types, Auxo.Query.Access;

type
  IQueryExecute = Auxo.Query.Core.IQueryExecute;
  IQueryTranslator = Auxo.Query.Compiled.IQueryTranslator;
  IQuery = Auxo.Query.Core.IQuery;

  TLogical = Auxo.Query.Types.TLogical;
  TOperator = Auxo.Query.Types.TOperator;
  TOrder = Auxo.Query.Types.TOrder;

  OrderAccess = Auxo.Query.Access.OrderAccess;
  WhereAccess = Auxo.Query.Access.WhereAccess;
  QueryAccess = Auxo.Query.Access.QueryAccess;

  TQuery = class(TInterfacedObject, IQueryInfo, IQuery, ISelect, IFrom, IAndJoin, IOrder, IWhere, IAndWhere, IOrWhere, IBaseQuery)
  private
    FCurrentQuery: TCompiledQuery;
    FCurrentWhere: TCompiledWhere;
    function Get(const IID: TGUID; out Obj): Boolean;
  protected
    function IQueryInfo_Query: IQuery;
    function IQueryInfo_Select: ISelect;
    function IQueryInfo_From: IFrom;
    function IQueryInfo_AndJoin: IAndJoin;
    function IQueryInfo_Where: IWhere;
    function IQueryInfo_Order: IOrder;
    function IQueryInfo_AndWhere: IAndWhere;
    function IQueryInfo_OrWhere: IOrWhere;

    function IQueryInfo.Query = IQueryInfo_Query;
    function IQueryInfo.Select = IQueryInfo_Select;
    function IQueryInfo.From = IQueryInfo_From;
    function IQueryInfo.AndJoin = IQueryInfo_AndJoin;
    function IQueryInfo.Where = IQueryInfo_Where;
    function IQueryInfo.Order = IQueryInfo_Order;
    function IQueryInfo.AndWhere = IQueryInfo_AndWhere;
    function IQueryInfo.OrWhere = IQueryInfo_OrWhere;


  //IBaseQuery
    function ToString(Translator: IQueryTranslator): string; reintroduce;
    function Info: IQueryInfo;
    function Union: IQuery;
    function Compile: TCompiledQuery;
    function Run(Exec: IQueryExecute): IQueryExecute;

  //IOrWhere
    function OrWhere(Field: string; Value: Variant): IWhere;
    function OrWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere;

  //IAndWhere
    function AndWhere(Field: string; Value: Variant): IWhere; overload;
    function AndWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere; overload;
    function Orr: IOrWhere;

  //IOrder
    function Order(Field: string): IOrder; overload;
    function Order(Field: string; Order: TOrder): IOrder; overload;
    function Count: Integer;
    procedure IOrder_Clear;
    procedure IOrder.Clear = IOrder_Clear;

  //IWhere
    function Order: IOrder; overload;
    function Where(AId: string; AActive: Boolean = True): IWhere;

  //IAndJoin
    function AndJoin(Field: string; Value: Variant): IFrom; overload;
    function AndJoinOp(Field: string; AOp: TOperator; Value: Variant): IFrom; overload;

  //IFrom
    function Inner(Join: string; Alias: string = ''): IFrom; overload;
    function Left(Join: string; Alias: string = ''): IFrom; overload;
    function Right(Join: string; Alias: string = ''): IFrom; overload;
    function Full(Join: string; Alias: string = ''): IFrom; overload;

  //ISelect
    function From(Name: string; Alias: string = ''): IFrom;

  //IQuery
    function SetSkip(Value: Integer): IQuery; overload;
    function SetTake(Value: Integer): IQuery; overload;
    function SetSkipTake(Skip: Integer; Take: Integer): IQuery; overload;

    property Skip[AValue: Integer]: IQuery read SetSkip;
    property Take[AValue: Integer]: IQuery read SetTake;
    property SkipTake[Skip: Integer; Take: Integer]: IQuery read SetSkipTake;

    function Select(const Fields: array of string): ISelect; overload;
    function Select(Fields: string): ISelect; overload;
  public
    class function New: IQuery;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;



implementation

uses
  System.StrUtils, System.SysUtils;

{ TQuery }

procedure TQuery.AfterConstruction;
begin
  inherited;
  FCurrentQuery := TCompiledQuery.Create;
end;

function TQuery.AndJoin(Field: string; Value: Variant): IFrom;
begin
  Result := Self;
end;

function TQuery.AndJoinOp(Field: string; AOp: TOperator; Value: Variant): IFrom;
begin
  Result := Self;
end;

function TQuery.AndWhere(Field: string; Value: Variant): IWhere;
begin
  Result := Self;
  FCurrentWhere.Andd(Field, TOperator.Equal, Value);
end;

function TQuery.AndWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere;
begin
  Result := Self;
  FCurrentWhere.Andd(Field, AOp, Value);
end;

procedure TQuery.BeforeDestruction;
begin
  inherited;
  FCurrentQuery.Free;
end;

function TQuery.Compile: TCompiledQuery;
begin
  Result := FCurrentQuery;
end;

function TQuery.Count: Integer;
begin
  Result := FCurrentQuery.Order.Count;
end;

class function TQuery.New: IQuery;
begin
  Result := TQuery.Create;
end;

function TQuery.From(Name, Alias: string): IFrom;
begin
  FCurrentQuery.From := Name;
  Result := Self;
end;

function TQuery.Full(Join, Alias: string): IFrom;
begin
  Result := Self;
end;

function TQuery.Get(const IID: TGUID; out Obj): Boolean;
begin
  Result := Self.GetInterface(IID, Obj);
end;

function TQuery.Info: IQueryInfo;
begin
  Result := Self;
end;

function TQuery.Inner(Join, Alias: string): IFrom;
begin
  Result := Self;
end;

procedure TQuery.IOrder_Clear;
begin
  FCurrentQuery.Order.Clear;
end;

function TQuery.IQueryInfo_AndJoin: IAndJoin;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_AndWhere: IAndWhere;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_From: IFrom;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_Order: IOrder;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_OrWhere: IOrWhere;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_Query: IQuery;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_Select: ISelect;
begin
  Result := Self;
end;

function TQuery.IQueryInfo_Where: IWhere;
begin
  Result := Self;
end;

function TQuery.Left(Join, Alias: string): IFrom;
begin
  Result := Self;
end;

function TQuery.Order(Field: string; Order: TOrder): IOrder;
begin
  Result := Self;
  FCurrentQuery.Order.Field[Field] := Order;
end;

function TQuery.Order(Field: string): IOrder;
begin
  Result := Order(Field, TOrder.Asc);
end;

function TQuery.Order: IOrder;
begin
  Result := Self;
end;

function TQuery.Orr: IOrWhere;
begin
  Result := Self;
end;

function TQuery.OrWhere(Field: string; Value: Variant): IWhere;
begin
  Result := Self;
  FCurrentWhere.Orr(Field, TOperator.Equal, Value);
end;

function TQuery.OrWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere;
begin
  Result := Self;
  FCurrentWhere.Orr(Field, AOp, Value);
end;

function TQuery.Right(Join, Alias: string): IFrom;
begin
  Result := Self;
end;

function TQuery.Run(Exec: IQueryExecute): IQueryExecute;
begin
  Exec.SetQuery(Self);
  Result := Exec;
end;

function TQuery.Select(Fields: string): ISelect;
begin
  Result := Self;
  FCurrentQuery.Select.Add(Fields);
end;

function TQuery.Select(const Fields: array of string): ISelect;
begin
  Result := Self;
  FCurrentQuery.Select.Add(string.Join(',', Fields));
end;

function TQuery.SetSkip(Value: Integer): IQuery;
begin
  Result := Self;
end;

function TQuery.SetSkipTake(Skip, Take: Integer): IQuery;
begin
  Result := Self;
end;

function TQuery.SetTake(Value: Integer): IQuery;
begin
  Result := Self;
end;

function TQuery.ToString(Translator: IQueryTranslator): string;
begin
  Result := Translator.ToString(Compile);
end;

function TQuery.Union: IQuery;
begin
  Result := Self;
end;

function TQuery.Where(AId: string; AActive: Boolean): IWhere;
begin
  Result := Self;
  FCurrentWhere := FCurrentQuery.Where[AId];
  FCurrentWhere.Accept := AActive;
end;

end.
