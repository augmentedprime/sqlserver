

USE MVProdPerm2
GO

DECLARE @ExchangeCode varchar(200) = 'FUTSER',
		@DBName varchar(200) = 'futuresservices',
		@Description varchar(200) = 'Futures Services',
		@Propietary varchar(10) = 'N'


/*
SELECT *
FROM dbo.INSTRUMENT_METADATA
WHERE exchangeCode = @ExchangeCode

SELECT *
FROM dbo.EXCHANGE
WHERE EXCHANGE_CODE = @ExchangeCode

SELECT  *
FROM dbo.QUOTES
WHERE	EXCHANGE = @ExchangeCode
ORDER BY LOGIN
*/



/*
New datasets going into Wombat/SQL Server need entries added to 4 tables
to get it to show up in Marketview:
1.  Instrument_Metadata table
2.  FT_Exchange table
3.  Exchange table
4.  Quotes
Next steps:
4.  Add permissions
5.  Add Price Routing 

A middle tier restart is necessary to pick up changes added to 
the Instrument_Metadata table.
*/
--===================================================================
-- ADD INSTRUMENT_METADATA
--===================================================================

-- ALL QUERIES SHOULD BE RUN ON SCHTSQLA.MVProdPerm2

--Take an existing example, put in to a temp table, and modify the row/rows accordingly. Then insert from temp table.

DROP TABLE IF EXISTS #instrument_metadata

SELECT *
INTO #instrument_metadata
FROM dbo.INSTRUMENT_METADATA
WHERE ExchangeCode = 'ALPHB'

--Follow the example to change the exchange

UPDATE #instrument_metadata
SET
  ExchangeCode       = @ExchangeCode,
  SymbolDescription  = @Description,  --just an example
  CompanyName        = @ExchangeCode,  --just an example
  Category           = @ExchangeCode,
  overridefromsymbol = 1,  --'0' for don't override, or '1' to override from symbol table,
  basecode           = '1/1000000',  --num decimal places for values
  dbName             = @DBName

--Inserts:
--QA

INSERT INTO dbo.INSTRUMENT_METADATA (
  exchangeCode,
  feedInstrumentType,
  instrumentType,
  symbolPattern,
  symbolDescription,
  companyName,
  contractDisplayDate,
  category,
  underlier,
  optionRoot,
  putCall,
  tradeMonths,
  tradeDays,
  marketOpen,
  marketClose,
  resetOffset,
  tradeSession,
  sessionStart1,
  sessionEnd1,
  sessionStart2,
  sessionEnd2,
  baseCode,
  strikeBaseCode,
  contractSize,
  currency,
  lotUnits,
  minMove,
  maxMove,
  conversionFactor,
  contractInitiation,
  contractTermination,
  recordDescription,
  recordComments,
  warnOnUse,
  holidayCalendar,
  settleTime,
  settleType,
  settleTime2,
  settleType2,
  noPreload,
  overrideWithExplicit,
  overrideFromSymbol,
  lastUpdate,
  DBName
)
SELECT
  exchangeCode,
  feedInstrumentType,
  instrumentType,
  symbolPattern,
  symbolDescription,
  companyName,
  contractDisplayDate,
  category,
  underlier,
  optionRoot,
  putCall,
  tradeMonths,
  tradeDays,
  marketOpen,
  marketClose,
  resetOffset,
  tradeSession,
  sessionStart1,
  sessionEnd1,
  sessionStart2,
  sessionEnd2,
  baseCode,
  strikeBaseCode,
  contractSize,
  currency,
  lotUnits,
  minMove,
  maxMove,
  conversionFactor,
  contractInitiation,
  contractTermination,
  recordDescription,
  recordComments,
  warnOnUse,
  holidayCalendar,
  settleTime,
  settleType,
  settleTime2,
  settleType2,
  noPreload,
  overrideWithExplicit,
  overrideFromSymbol,
  lastUpdate,
  DBName
FROM #instrument_metadata



--===============================================================
-- ADD EXCHANGE
-- Insert your new exchange code into the Exchange table.
-- If your data is proprietary, make the proprietary column = 'Y',
-- otherwise it's 'N' for all other non-proprietary data.

-- NOTE FOR ARGUS DATA ONLY:
-- HISTORICAL_SP_NAMES must include the special stored procedures list for Argus data:
-- "getTradesDateRange_argus,getTicksDateRange_argus,GetIntradayTrades_argus, getDaily_argus,getVolPriceDateRange"
-- This is required to handle alternate exchanges.
--===============================================================
--Get example into temp table #exch
--SELECT *
--FROM dbo.EXCHANGE
--WHERE exchange_code LIKE 'ALPHB'

DROP TABLE IF EXISTS #exch

SELECT *
INTO #exch
FROM dbo.EXCHANGE
WHERE EXCHANGE_CODE = 'ALPHB'


--Update columns as needed

UPDATE #exch
SET
  EXCHANGE_CODE      = @ExchangeCode,
  [DESCRIPTION]      = @Description, 
  PROVIDER_CODE      = @ExchangeCode, --should be exchange code again
  PROPRIETARY        = @Propietary,    -- If your data is proprietary, make the proprietary column = 'Y',
  ETL_SOURCE         = @DBName, --db name again
  MASTERExchange     = @ExchangeCode --same as exchange code


--Insert:
--============
-- QA
--============

INSERT INTO dbo.EXCHANGE (
  EXCHANGE_CODE,
  [DESCRIPTION],
  PROVIDER_CODE,
  CRC,
  HISTORICAL_SP_NAMES,
  DELAY_FACTOR,
  TIMEZONE_NAME,
  ETL_SOURCE,
  MasterExchange,
  Proprietary
)
SELECT
	EXCHANGE_CODE,
	[DESCRIPTION],
	PROVIDER_CODE,
	CRC,
	HISTORICAL_SP_NAMES,
	DELAY_FACTOR,
	TIMEZONE_NAME,
	ETL_SOURCE,
	MasterExchange,
	Proprietary
FROM #Exch



--================================================
-- ADD DATA PERMISSIONS
-- Permissions for data go in the "Quotes" table.
-- After permissions are added, just restart your MarketView session to apply the permissions changes.
-- MT restart or tree rebuild is not necessary for permissions changes.
--================================================
-- Get an example of an existing exchange code and put into ##quote table.

DROP TABLE IF EXISTS #quote

SELECT *
INTO #quote
FROM dbo.QUOTES
WHERE exchange = 'ABIOM'
AND [LOGIN] IN (
  'AugieH',
  'JasonP',
  'MarkJ',
  'BruceW',
  'AmyG',
  'JakeD',
  'ChadB',
  'KevinB',
  'TESTB',
  'AustinM',
  'GalinaG',
  'Jack.Pyke',
  'michael.dearmas',
  'Kevin.Shane'
)

-- check it out:
--SELECT * FROM #quote

--Update the temp table for your exchange as needed

UPDATE #quote
SET
  Expiration_Date = '2050-12-31 00:00:00.000',
  update_date     = GETDATE(),
  create_Date     = GETDATE(),
  REALTIME        = 'N',
  exchange        = @ExchangeCode


--Do the insert into the QA permissions table

INSERT INTO dbo.QUOTES (
  [Login],
  EXCHANGE,
  REALTIME,
  STREAMING,
  DAYS_BACK,
  EXPIRATION_DATE,
  CREATE_DATE,
  UPDATE_DATE,
  TRANSACTION_ID,
  HISTORY_LIMIT,
  HISTORY_START_DATE
)
SELECT
  [Login],
  EXCHANGE,
  REALTIME,
  STREAMING,
  DAYS_BACK,
  EXPIRATION_DATE,
  CREATE_DATE,
  UPDATE_DATE,
  TRANSACTION_ID,
  HISTORY_LIMIT,
  HISTORY_START_DATE
FROM #quote

/*============================================================================
Once Instrument_Metadata, FT_Exchange, Exchange,
and permissions are set up, add your new exchange
to Price Routing.  
1) log on the QA middle tier server (currently schtmtte)
2) using the configuration tool (shortcut on the desktop),
   Price Routing tab, add your new exchange to the price routing list.
--============================================================================*/

SELECT *
FROM dbo.INSTRUMENT_METADATA
WHERE exchangeCode = @ExchangeCode

SELECT *
FROM dbo.EXCHANGE
WHERE EXCHANGE_CODE = @ExchangeCode

SELECT  *
FROM dbo.QUOTES
WHERE	EXCHANGE = @ExchangeCode
ORDER BY LOGIN
