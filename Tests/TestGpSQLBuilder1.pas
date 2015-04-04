unit TestGpSQLBuilder1;

interface

uses
  DUnitX.TestFramework,
  GpSQLBuilder;

type
  [TestFixture]
  TTestGpSQLBuilder = class(TObject)
  strict private
    SQL: IGpSQLBuilder;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test] procedure TestEmptyResult;
    [Test] procedure TestSelectAll;
    [Test] procedure TestSelectAll2;
    [Test] procedure TestSelectColumn;
    [Test] procedure TestSelectColumn2;
    [Test] procedure TestSelectTwoColumns;
    [Test] procedure TestSelectDBColumn;
    [Test] procedure TestDBAlias;
    [Test] procedure TestColumnAlias;
    [Test] procedure TestSelectFirst;
    [Test] procedure TestSelectFirst2;
    [Test] procedure TestSelectFirstSkip;
    [Test] procedure TestSelectWhere;
    [Test] procedure TestLeftJoin;
    [Test] procedure TestLeftJoin2;
    [Test] procedure TestLeftJoinAnd;
    [Test] procedure TestDoubleLeftJoin;
    [Test] procedure TestGroupBy;
    [Test] procedure TestGroupByHaving;
    [Test] procedure TestOrderBy;
    [Test] procedure TestOrderBy2;
    [Test] procedure TestOrderByTwoColumns;
    [Test] procedure TestOrderByDesc;
    [Test] procedure TestOrderByTwoColumnsDesc1;
    [Test] procedure TestOrderByTwoColumnsDesc2;
    [Test] procedure TestWhereAnd;
    [Test] procedure TestWhereAnd2;
    [Test] procedure TestWhereOr;
    [Test] procedure TestWhereAndOr;
    [Test] procedure TestCaseIntegration;
    [Test] procedure TestMixed;
    [Test] procedure TestSectionEmpty;
    [Test] procedure TestSectionEmpty2;
    [Test] procedure TestSectionEmpty3;
    [Test] procedure TestSectionNotEmpty;
    [Test] procedure TestSectionNotEmpty2;
  end;

  [TestFixture]
  TTestGpSQLBuilderCase = class(TObject)
  public
    [Test] procedure TestCase;
    [Test] procedure TestCase2;
    [Test] procedure TestCaseAndOr;
  end;

implementation

uses
  System.SysUtils;

const
  //test table names
  DB_TEST = 'Test';
  DB_TEST_ALIAS = 'TestAlias';
  DB_DETAIL = 'Detail';
  DB_SUB = 'Sub';

  COL_ALL_ALIAS = 'ALL';
  COL_1 = 'Column1';
  COL_2 = 'Column2';
  COL_DETAIL_ID = 'DetailID';
  COL_DETAIL_2 = 'Detail2';
  COL_SUB_ID = 'SubID';

{ TTestGpSQLBuilder }

procedure TTestGpSQLBuilder.Setup;
begin
  SQL := CreateGpSQLBuilder;
end;

procedure TTestGpSQLBuilder.TearDown;
begin
  SQL := nil;
end;

procedure TTestGpSQLBuilder.TestCaseIntegration;
const
  CExpected = 'SELECT CASE WHEN (Column2 < 0) THEN 0 WHEN (Column2 > 100) THEN 2 ' +
    'ELSE 1 END FROM Test';
begin
  SQL
    .Select
      .&Case
        .When([COL_2, '< 0']).&Then('0')
        .When([COL_2, '> 100']).&Then('2')
        .&Else('1')
      .&End
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestColumnAlias;
const
  CExpected = 'SELECT * AS ALL FROM Test';
begin
  SQL
    .Select('*').&As(COL_ALL_ALIAS)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestDBAlias;
const
  CExpected = 'SELECT * FROM Test AS TestAlias';
begin
  SQL
    .Select('*')
    .From(DB_TEST).&As(DB_TEST_ALIAS);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestDoubleLeftJoin;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON (Column1 = DetailID) ' +
    'LEFT JOIN Sub ON (DetailID = SubID)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On([COL_1, '=', COL_DETAIL_ID])
     .LeftJoin(DB_SUB).On([COL_DETAIL_ID, '=', COL_SUB_ID]);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestEmptyResult;
begin
  Assert.IsEmpty(SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestGroupBy;
const
  CExpected = 'SELECT * FROM Test GROUP BY Column2';
begin
 SQL
   .Select.All
   .From(DB_TEST)
   .GroupBy(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestGroupByHaving;
const
  CExpected = 'SELECT * FROM Test GROUP BY Column2 HAVING (Column2 > 0)';
begin
 SQL
   .Select.All
   .From(DB_TEST)
   .GroupBy(COL_2)
   .Having([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoin;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON (Column1 = DetailID)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On([COL_1, '=', COL_DETAIL_ID]);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoin2;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON (Column1 = DetailID)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On(Format('%s = %s', [COL_1, COL_DETAIL_ID]));
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoinAnd;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON (Column1 = DetailID) AND (Detail2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL)
       .On([COL_1, '=', COL_DETAIL_ID])
       .&And([COL_DETAIL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestMixed;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL.From(DB_TEST);
  SQL.Where([COL_1, 'IS NOT NULL']);
  SQL.Select.All;
  SQL.Where.&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderBy;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy(COL_1);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderBy2;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByDesc;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1 DESC';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy(COL_1).Desc;
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumns;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1, Column2';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1)
      .Column(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumnsDesc1;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1 DESC, Column2';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1).Desc
      .Column(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumnsDesc2;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1, Column2 DESC';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1)
      .Column(COL_2).Desc;
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty;
begin
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty2;
begin
  SQL.Select.All;
  SQL.Select.Clear;
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty3;
begin
  SQL.Select.All;
  SQL.Select.Clear;
  SQL.From(DB_TEST);
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionNotEmpty;
begin
  SQL.Select.All;
  Assert.IsFalse(SQL.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionNotEmpty2;
begin
  SQL.Select.All;
  SQL.OrderBy;
  Assert.IsFalse(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSelectAll;
const
  CExpected = 'SELECT * FROM Test';
begin
  SQL
    .Select('*')
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectAll2;
const
  CExpected = 'SELECT * FROM Test';
begin
  SQL
    .Select.All
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectColumn;
const
  CExpected = 'SELECT Column1 FROM Test';
begin
  SQL
    .Select(COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectColumn2;
const
  CExpected = 'SELECT Column1 FROM Test';
begin
  SQL
    .Select
      .Column(COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectDBColumn;
const
  CExpected = 'SELECT Test.Column1 FROM Test';
begin
  SQL
    .Select
      .Column(DB_TEST, COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectFirst;
const
  CExpected = 'SELECT FIRST 10 * FROM Test';
begin
  SQL
    .Select
      .All
      .First(10)
    .From(DB_TEST);
end;

procedure TTestGpSQLBuilder.TestSelectFirst2;
const
  CExpected = 'SELECT FIRST 10 * FROM Test';
begin
  SQL
    .Select
      .First(10)
      .All
    .From(DB_TEST);
end;

procedure TTestGpSQLBuilder.TestSelectFirstSkip;
const
  CExpected = 'SELECT FIRST 10 SKIP 5 * FROM Test';
begin
  SQL
    .Select
      .First(10)
      .Skip(5)
      .All
    .From(DB_TEST);
end;

procedure TTestGpSQLBuilder.TestSelectTwoColumns;
const
  CExpected = 'SELECT Column1, Column2 FROM Test';
begin
  SQL
    .Select
      .Column(COL_1)
      .Column(COL_2)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectWhere;
const
  CExpected = 'SELECT * FROM Test WHERE (Column2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAnd;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_1, 'IS NOT NULL'])
      .&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAnd2;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where
      .&And([COL_1, 'IS NOT NULL'])
      .&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAndOr;
const
  CExpected = 'SELECT * FROM Test WHERE ((Column1 IS NULL) OR (Column1 = 0)) AND ((Column2 > 0) OR (Column2 < 10))';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where
      .&And([COL_1, 'IS NULL'])
        .&Or([COL_1, '= 0'])
      .&And([COL_2, '> 0'])
        .&Or([COL_2, '< 10']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereOr;
const
  CExpected = 'SELECT * FROM Test WHERE ((Column1 IS NOT NULL) OR (Column2 > 0))';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_1, 'IS NOT NULL'])
      .&Or([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

{ TTestGpSQLBuilderCase }

procedure TTestGpSQLBuilderCase.TestCase;
const
  CExpected = 'CASE WHEN (Column2 < 0) THEN 0 WHEN (Column2 > 100) THEN 2 ELSE 1 END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case
    .When([COL_2, '< 0']).&Then('0')
    .When([COL_2, '> 100']).&Then('2')
    .&Else('1');
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

procedure TTestGpSQLBuilderCase.TestCase2;
const
  CExpected = 'CASE Column2 WHEN (0) THEN ''A'' WHEN (1) THEN ''B'' END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case(COL_2)
    .When([0]).&Then('''A''')
    .When([1]).&Then('''B''');
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

procedure TTestGpSQLBuilderCase.TestCaseAndOr;
const
  CExpected = 'CASE WHEN (Column2 < 0) AND (Column1 IS NOT NULL) THEN 0 ' +
    'WHEN ((Column2 > 100) OR (Column1 IS NULL)) THEN 2 ELSE 1 END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case
    .When([COL_2, '< 0'])
      .&And([COL_1, 'IS NOT NULL'])
      .&Then('0')
    .When([COL_2, '> 100'])
      .&Or([COL_1, 'IS NULL'])
      .&Then('2')
    .&Else('1');
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGpSQLBuilder);
end.