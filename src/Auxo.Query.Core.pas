unit Auxo.Query.Core;

interface

uses
  Auxo.Query.Types, Auxo.Query.Compiled, Auxo.Access.Core, System.SysUtils;

const
  IBaseQuery_ID = '{25978A48-BE4D-452E-8E9A-BBC8DF00FE1E}';
  IOrWhere_ID   = '{D6053621-E14E-454D-B6EC-B8969566A3BA}';
  IAndWhere_ID  = '{03088C49-31F5-43D3-8BBB-8F854DEDDD5D}';
  IOrder_ID     = '{CBAD6193-AF27-4681-B8DF-389E6B37BD04}';
  IWhere_ID     = '{2DAC6088-3127-48E5-96F4-8CA3426DD66D}';
  IAndJoin_ID   = '{E8983B9A-75E6-4A3B-A580-56F67E9CCCE1}';
  IFrom_ID      = '{B904753D-388B-408D-A6A0-102D41B609C9}';
  ISelect_ID    = '{3D09808B-DE60-4C57-9B13-E5620593738B}';
  IQuery_ID     = '{FFB2939D-E319-4328-BFC5-82CF8C14DE10}';
  IQueryInfo_ID = '{426C27E5-DC86-48C3-8562-C59B385A9E42}';

  IBaseQuery_GUID: TGUID = IBaseQuery_ID;
  IOrWhere_GUID:   TGUID = IOrWhere_ID;
  IAndWhere_GUID:  TGUID = IAndWhere_ID;
  IOrder_GUID:     TGUID = IOrder_ID;
  IWhere_GUID:     TGUID = IWhere_ID;
  IAndJoin_GUID:   TGUID = IAndJoin_ID;
  IFrom_GUID:      TGUID = IFrom_ID;
  ISelect_GUID:    TGUID = ISelect_ID;
  IQuery_GUID:     TGUID = IQuery_ID;
  IQueryInfo_GUID: TGUID = IQueryInfo_ID;

type
  IFrom = interface;
  IQuery = interface;
  IWhere = interface;
  IOrder = interface;
  IBaseQuery = interface;
  IOrWhere = interface;
  IAndWhere = interface;
  IQueryInfo = interface;

  IQueryExecute = interface
    function SetQuery(AQuery: IBaseQuery): IQueryExecute;
    function ToList: IRecordList;
    procedure ToListAsync(Proc: TProc<IRecordList>); overload;
    procedure ToListAsync(Proc: TProc<IRecord>); overload;

    property Query[AQuery: IBaseQuery]: IQueryExecute read SetQuery; default;
  end;

  IBaseQuery = interface
  [IBaseQuery_ID]
    function Info: IQueryInfo;
    function Compile: TCompiledQuery;
    function Get(const IID: TGUID; out Obj): Boolean;
    function ToString(Translator: IQueryTranslator): string;
  end;

  IOrWhere = interface(IBaseQuery)
  [IOrWhere_ID]
    function OrWhere(Field: string; Value: Variant): IWhere;
    function OrWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere;
    property Orr[Field: string; Value: Variant]: IWhere read OrWhere; default;
    property Orr[Field: string; AOp: TOperator; Value: Variant]: IWhere read OrWhereOp; default;
  end;

  IAndWhere = interface(IBaseQuery)
  [IAndWhere_ID]
    function AndWhere(Field: string; Value: Variant): IWhere; overload;
    function AndWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere; overload;
    property Andd[Field: string; Value: Variant]: IWhere read AndWhere; default;
    property Andd[Field: string; AOp: TOperator; Value: Variant]: IWhere read AndWhereOp; default;
    function Orr: IOrWhere;
  end;

  IOrder = interface(IBaseQuery)
  [IOrder_ID]
    function Order(Field: string): IOrder; overload;
    function Order(Field: string; Order: TOrder): IOrder; overload;
    property Field[Field: string]: IOrder read Order; default;
    property Field[Field: string; Order: TOrder]: IOrder read Order; default;
    procedure Clear;
    function Count: Integer;
  end;

  IWhere = interface(IBaseQuery)
  [IWhere_ID]
    function Order: IOrder; overload;
    function Order(Field: string): IOrder; overload;
    function Order(Field: string; Order: TOrder): IOrder; overload;
    function Where(AId: string = ''; Condition: Boolean = True): IWhere;

    function AndWhere(Field: string; Value: Variant): IWhere; overload;
    function AndWhereOp(Field: string; AOp: TOperator; Value: Variant): IWhere; overload;
    property Andd[Field: string; Value: Variant]: IWhere read AndWhere; default;
    property Andd[Field: string; AOp: TOperator; Value: Variant]: IWhere read AndWhereOp; default;
    function Orr: IOrWhere;
  end;

  IAndJoin = interface(IBaseQuery)
  [IAndJoin_ID]
    function AndJoin(Field: string; Value: Variant): IFrom; overload;
    function AndJoinOp(Field: string; AOp: TOperator; Value: Variant): IFrom; overload;
    property Andd[Field: string; Value: Variant]: IFrom read AndJoin; default;
    property Andd[Field: string; AOp: TOperator; Value: Variant]: IFrom read AndJoinOp; default;
  end;

  IFrom = interface(IBaseQuery)
  [IFrom_ID]
    function Inner(Join: string; Alias: string = ''): IFrom; overload;
    function Left(Join: string; Alias: string = ''): IFrom; overload;
    function Right(Join: string; Alias: string = ''): IFrom; overload;
    function Full(Join: string; Alias: string = ''): IFrom; overload;
    function Where(AId: string = ''; Condition: Boolean = True): IWhere;
    function Order: IOrder; overload;
    function Order(Field: string): IOrder; overload;
    function Order(Field: string; Order: TOrder): IOrder; overload;
  end;

  ISelect = interface(IBaseQuery)
  [ISelect_ID]
    function From(Name: string; Alias: string = ''): IFrom;
  end;

  IQuery = interface(IBaseQuery)
  [IQuery_ID]
    function SetSkip(Value: Integer): IQuery; overload;
    function SetTake(Value: Integer): IQuery; overload;
    function SetSkipTake(Skip: Integer; Take: Integer): IQuery; overload;
    property Skip[AValue: Integer]: IQuery read SetSkip;
    property Take[AValue: Integer]: IQuery read SetTake;
    property SkipTake[Skip: Integer; Take: Integer]: IQuery read SetSkipTake;
    function Select(const Fields: array of string): ISelect; overload;
    function Select(Fields: string): ISelect; overload;
  end;

  IQueryInfo = interface
  [IQueryInfo_ID]
    function Query: IQuery;
    function Select: ISelect;
    function From: IFrom;
    function AndJoin: IAndJoin;
    function Where: IWhere;
    function Order: IOrder;
    function AndWhere: IAndWhere;
    function OrWhere: IOrWhere;
  end;

implementation

end.
