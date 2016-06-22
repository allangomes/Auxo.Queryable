# Query Libary for Delphi v. 1.0.0-prealpha

* Dependencies
  None

```delphi

var
  query: IQuery;
begin
  query := TQuery.Create;
  query.SkipTake[0, 50]
       .Select('Name, Age')
       .From('Customer')
       .Where
          ['Age', TOperator.Lt, 16].Orr['Age', TOperator.Gt, 65]
       .Order['Age', TOrder.Desc];
{...}
```

Query Execute (Async)
```delphi
procedure Execute(AExec: IQueryExecute; AQuery: IQuery)
begin
  AExec[AQuery].ToListAsync( //When finished, will call callback function for each record.
  procedure(customer: IRecord)
  begin
    ShowMessage(customer['Name']);
  end)
end;
```

Query Execute and Set to AuxoDataSet (Async)
```delphi
procedure ExecuteAndSetDataSet(AExec: IQueryExecute; AQuery: IQuery)
begin
  AExec[AQuery].ToListAsync(
  procedure(customers: IRecordList)
  begin
    dataset.Data := customers;
  end;
end
```

Query Execute (Sync)
```delphi
procedure ExecuteSync(AExec: IQueryExecute; AQuery: IQuery)
var
  customer: IRecord;
begin
  for customer in AExec[AQuery].ToList do
  begin
    ShowMessage(customer['Name']);
  end;
end;
```

```delphi
QueryExecute := TFireDacQueryExecute.Create('localhost', TFirebirdQueryTranslator.Create)); //FireDac e Firebird
QueryExecute := TDBXQueryExecute.Create('localhost', TFirebirdQueryTranslator.Create));     //DBExpress e Firebird
QueryExecute := TDBXQueryExecute.Create('localhost', TSQLServerQueryTranslator.Create));     //DBExpress e SQLServer
QueryExecute := TMyApiQueryExecute.Create('localhost', TMyApiQueryTranslator.Create));      //MyApi e UrlParameters

Execute(QueryExecute, Query);
```
