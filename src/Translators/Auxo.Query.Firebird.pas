unit Auxo.Query.Firebird;

interface

uses
  Auxo.Query, Auxo.Query.Compiled, System.Generics.Collections;

type
  TFirebirdTranslator = class(TInterfacedObject, IQueryTranslator)
  private
    function VarToSQL(value: Variant): string;
    function WhereLogical(ALogical: TLogical): string;
    function WhereOperator(AOperator: TOperator): string;
    function SingleWhere(CompiledWhere: TCompiledWhere): string;
  public
    function Select(Compiled: TCompiledQuery): string;
    function Order(Compiled: TCompiledQuery): string;
    function Where(Compiled: TCompiledQuery): string;
    function ToString(Compiled: TCompiledQuery): string; reintroduce;
  end;


implementation

uses
  System.SysUtils, System.StrUtils, System.Variants;

{ TFirebirdTranslator }

function TFirebirdTranslator.Order(Compiled: TCompiledQuery): string;
const
  ORDER_STR: array[TOrder] of string = ('asc', 'desc');
var
  Order: TOrderField;
begin
  Result := '';
  for Order in Compiled.Order.ToArray do
    Result := Result + Order.Field + ' ' + ORDER_STR[Order.Order];
end;

function TFirebirdTranslator.Select(Compiled: TCompiledQuery): string;
begin
  Result := string.Join(',', Compiled.Select.ToArray);
end;

function TFirebirdTranslator.ToString(Compiled: TCompiledQuery): string;
var
  take: string;
  Whr: string;
  Ord: string;
  Sel: string;
  From: string;
  Sql: TList<string>;
begin
  if Compiled.Take > 0 then
    take := 'first ' + IntToStr(Compiled.Take) + ' ';
  From := Compiled.From;
  Whr := Where(Compiled);
  Ord := Order(Compiled);
  Sel := Select(Compiled);
  Sql := TList<string>.Create;
  try
    if Sel <> '' then
      Sql.Add('select ' + take + Sel);
    if From <> '' then
      Sql.Add('from ' + From);
    if Whr <> '' then
      Sql.Add('where ' + Whr);
    if Ord <> '' then
      Sql.Add('order by ' + Ord);
    Result := string.Join(' ', Sql.ToArray);
  finally
    Sql.Free;
  end;
end;

function TFirebirdTranslator.VarToSQL(value: Variant): string;
begin
  if VarIsNull(value) then
    Exit('null');
  if VarIsType(value, varDate) then
    Exit(FormatDateTime('yyyy-mm-dd HH:mm:ss', value));
  if VarIsStr(value) then
    Exit(QuotedStr(value));
  if VarIsNumeric(value) or VarIsFloat(value) then
    Exit(VarToStr(value));
end;

function TFirebirdTranslator.Where(Compiled: TCompiledQuery): string;
var
  Where: TCompiledWhere;
begin
  Result := '';
  for Where in Compiled.AllWhere do
  begin
    if Result <> EmptyStr then
      Result := Result + WhereLogical(TLogical.Andd);
    Result := Result + SingleWhere(Where);
  end;
end;

function TFirebirdTranslator.SingleWhere(CompiledWhere: TCompiledWhere): string;
var
  Predicate: TCompiledPredicate;
begin
  if not CompiledWhere.Accept then
    Exit('');
  for Predicate in CompiledWhere.Predicates do
  begin
    if Result <> '' then
      Result := Result + WhereLogical(Predicate.Logical);

      if StartsText('@', Predicate.Value) then
        Result := Result + Predicate.Field + WhereOperator(Predicate.Operatr) + Copy(Predicate.Value, 1, Length(Predicate.Value))
      else
        Result := Result + Predicate.Field + WhereOperator(Predicate.Operatr) + VarToSQL(Predicate.Value);
  end;
end;

function TFirebirdTranslator.WhereLogical(ALogical: TLogical): string;
const
  LOGICAL_STR: array[TLogical] of string = (' AND ', ' OR ');
begin
  Result := LOGICAL_STR[ALogical];
end;

function TFirebirdTranslator.WhereOperator(AOperator: TOperator): string;
const
  OPERATOR_STR: array[TOperator] of string = (' = ', ' < ', ' > ', ' <= ', ' >= ');
begin
  Result := OPERATOR_STR[AOperator];
end;

end.
