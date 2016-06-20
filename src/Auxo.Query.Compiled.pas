unit Auxo.Query.Compiled;

interface

uses
  Auxo.Query.Types, System.Generics.Collections;

type
  TCompiledPredicate = class
  public
    Logical: TLogical;
    Field: string;
    Operatr: TOperator;
    Value: Variant;
    constructor Create(ALogical: TLogical; AField: string; AOpertator: TOperator; AValue: Variant);
  end;

  TCompiledWhere = class
  public
    Accept: Boolean;
    Predicates: TObjectList<TCompiledPredicate>;
    procedure Orr(AField: string; AOpertator: TOperator; Value: Variant);
    procedure Andd(AField: string; AOpertator: TOperator; Value: Variant);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TOrderField = class
  public
    Field: string;
    Order: TOrder;
    constructor Create(AField: string; AOrder: TOrder);
  end;

  TCompiledOrders = class
  private
    FOrder: TObjectDictionary<string, TOrderField>;
    function GetOrderField(AField: string): TOrder;
    procedure SetOrderField(AField: string; const Value: TOrder);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property Field[AField: string]: TOrder read GetOrderField write SetOrderField;
    procedure Delete(AField: string);
    procedure Clear;
    function Count: Integer;
    function ToArray: TArray<TOrderField>;
  end;

  TCompiledQuery = class
  private
    FWhere: TObjectDictionary<string, TCompiledWhere>;
    FOrder: TCompiledOrders;
    function GetWhere(AId: string): TCompiledWhere;
  public
    Take: Integer;
    Skip: Integer;
    Select: TList<string>;
    From: string;
    Alias: string;
    CurrentWhere: TCompiledWhere;
    property Where[AId: string]: TCompiledWhere read GetWhere;
    function AllWhere: TArray<TCompiledWhere>;
    function Order: TCompiledOrders;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  IQueryTranslator = interface
    function Select(Compiled: TCompiledQuery): string;
    function Where(Compiled: TCompiledQuery): string;
    function Order(Compiled: TCompiledQuery): string;
    function ToString(Compiled: TCompiledQuery): string;
  end;

implementation

{ TCompiledQuery }

function TCompiledQuery.GetWhere(AId: string): TCompiledWhere;
begin
  if not FWhere.ContainsKey(AId) then
    FWhere.Add(AId, TCompiledWhere.Create);
  Result := FWhere[AId];
end;

function TCompiledQuery.Order: TCompiledOrders;
begin
  Result := FOrder;
end;

procedure TCompiledQuery.AfterConstruction;
begin
  inherited;
  Select := TList<string>.Create;
  FWhere := TObjectDictionary<string, TCompiledWhere>.Create([doOwnsValues]);
  FOrder := TCompiledOrders.Create;
end;

function TCompiledQuery.AllWhere: TArray<TCompiledWhere>;
begin
  Result := FWhere.Values.ToArray;
end;

procedure TCompiledQuery.BeforeDestruction;
begin
  inherited;
  Select.Free;
  FWhere.Free;
  FOrder.Free;
end;

{ TCompiledWhere }

procedure TCompiledWhere.AfterConstruction;
begin
  inherited;
  Accept := True;
  Predicates := TObjectList<TCompiledPredicate>.Create;
end;

procedure TCompiledWhere.Andd(AField: string; AOpertator: TOperator; Value: Variant);
begin
  Predicates.Add(TCompiledPredicate.Create(TLogical.Andd, AField, AOpertator, Value));
end;

procedure TCompiledWhere.BeforeDestruction;
begin
  inherited;
  Predicates.Free;
end;

procedure TCompiledWhere.Orr(AField: string; AOpertator: TOperator; Value: Variant);
begin
  Predicates.Add(TCompiledPredicate.Create(TLogical.Orr, AField, AOpertator, Value));
end;

{ TCompiledOrder }

constructor TOrderField.Create(AField: string; AOrder: TOrder);
begin
  Field := AField;
  Order := AOrder;
end;

{ TCompiledPredicate }

constructor TCompiledPredicate.Create(ALogical: TLogical; AField: string; AOpertator: TOperator; AValue: Variant);
begin
  Logical := ALogical;
  Field := AField;
  Operatr := AOpertator;
  Value := AValue;
end;

{ TCompiledOrders }

procedure TCompiledOrders.AfterConstruction;
begin
  inherited;
  FOrder := TObjectDictionary<string, TOrderField>.Create([doOwnsValues]);
end;

procedure TCompiledOrders.BeforeDestruction;
begin
  inherited;
  FOrder.Free;
end;

procedure TCompiledOrders.Clear;
begin
  FOrder.Clear;
end;

function TCompiledOrders.Count: Integer;
begin
  Result := FOrder.Count;
end;

procedure TCompiledOrders.Delete(AField: string);
begin
  if FOrder.ContainsKey(AField) then
    FOrder.Remove(AField);
end;

function TCompiledOrders.GetOrderField(AField: string): TOrder;
begin
  if not FOrder.ContainsKey(AField) then
    FOrder.Add(AField, TOrderField.Create(AField, Asc));
  Result := FOrder[AField].Order;
end;

procedure TCompiledOrders.SetOrderField(AField: string; const Value: TOrder);
begin
  if not FOrder.ContainsKey(AField) then
    FOrder.Add(AField, TOrderField.Create(AField, Asc));
  FOrder[AField].Order := Value;
end;

function TCompiledOrders.ToArray: TArray<TOrderField>;
begin
  Result := FOrder.Values.ToArray;
end;

end.
