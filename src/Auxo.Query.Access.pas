unit Auxo.Query.Access;

interface

uses
  Auxo.Query.Core, Auxo.Query.Types;

type
  OrderAccess = record
  private
    FOrder: IOrder;
    function OrderFieldDef(AField: string): OrderAccess;
    function OrderField(AField: string; AOrder: TOrder): OrderAccess;
    constructor Create(Order: IOrder);
    function GetCount: Integer;
  public
    property Field[Field: string]: OrderAccess read OrderFieldDef; default;
    property Field[Field: string; AOrder: TOrder]: OrderAccess read OrderField; default;
    function ReOrder: OrderAccess;
    property Count: Integer read GetCount;
  end;

  WhereAccess = record
  private
    FWhere: IWhere;
    function OrWhereOp(Field: string; AOp: TOperator; Value: Variant): WhereAccess;
    function AndWhere(Field: string; Value: Variant): WhereAccess; overload;
    function AndWhereOp(Field: string; AOp: TOperator; Value: Variant): WhereAccess; overload;
    constructor Create(Where: IWhere);
  public
    property Andd[Field: string; Value: Variant]: WhereAccess read AndWhere; default;
    property Andd[Field: string; AOp: TOperator; Value: Variant]: WhereAccess read AndWhereOp; default;
    property Orr[Field: string; AOp: TOperator; Value: Variant]: WhereAccess read OrWhereOp;
  end;

  QueryAccess = record
  private
    FQuery: IBaseQuery;
    constructor Create(AQuery: IBaseQuery);
  public
    class operator Explicit(AQuery: IBaseQuery): QueryAccess;
    function Where(AId: string = ''; Accept: Boolean = True): WhereAccess;
    function Order: OrderAccess;

    function Select(AFields: string): QueryAccess;
    function SkipTake(ASkip: Integer; ATake: Integer): QueryAccess;

    procedure ClearSelect;
    procedure ClearOrder;
  end;

implementation

{ Metadata }

procedure QueryAccess.ClearOrder;
begin
  FQuery.Compile.Order.Clear;
end;

procedure QueryAccess.ClearSelect;
begin
  FQuery.Compile.Select.Clear;
end;

constructor QueryAccess.Create(AQuery: IBaseQuery);
begin
  FQuery := AQuery;
end;

class operator QueryAccess.Explicit(AQuery: IBaseQuery): QueryAccess;
begin
  Result := QueryAccess.Create(AQuery);
end;

function QueryAccess.Order: OrderAccess;
begin
  Result := OrderAccess.Create(FQuery.Info.Order);
end;

function QueryAccess.Select(AFields: string): QueryAccess;
begin
  Result := Self;
  FQuery.Info.Query.Select(AFields);
end;

function QueryAccess.SkipTake(ASkip: Integer; ATake: Integer): QueryAccess;
begin
  Result := Self;
  FQuery.Info.Query.SkipTake[ASkip, ATake];
end;

function QueryAccess.Where(AId: string; Accept: Boolean): WhereAccess;
begin
  Result := WhereAccess.Create(FQuery.Info.Where.Where(AId, Accept));
end;

{ WhereAccess }

function WhereAccess.AndWhere(Field: string; Value: Variant): WhereAccess;
begin
  Result := Self;
  FWhere.Andd[Field, Value];
end;

function WhereAccess.AndWhereOp(Field: string; AOp: TOperator; Value: Variant): WhereAccess;
begin
  Result := Self;
  FWhere.Andd[Field, AOp, Value];
end;

constructor WhereAccess.Create(Where: IWhere);
begin
  FWhere := Where;
end;

function WhereAccess.OrWhereOp(Field: string; AOp: TOperator; Value: Variant): WhereAccess;
begin
  Result := Self;
  FWhere.Orr[Field, AOp, Value];
end;

{ OrderAccess }

function OrderAccess.ReOrder: OrderAccess;
begin
  Result := Self;
  FOrder.Clear;
end;

constructor OrderAccess.Create(Order: IOrder);
begin
  FOrder := Order;
end;

function OrderAccess.GetCount: Integer;
begin
  Result := FOrder.Count;
end;

function OrderAccess.OrderField(AField: string; AOrder: TOrder): OrderAccess;
begin
  Result := Self;
  FOrder.Field[AField, AOrder];
end;

function OrderAccess.OrderFieldDef(AField: string): OrderAccess;
begin
  Result := OrderField(AField, TOrder.Asc);
end;

end.
