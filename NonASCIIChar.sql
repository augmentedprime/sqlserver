--Find/Replace yourcolumn and yourtable with your values you are looking at--

select yourcolumn,
  patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,yourcolumn) as [Position],
  substring(yourcolumn,patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,yourcolumn),1) as [InvalidCharacter],
  ascii(substring(yourcolumn,patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,yourcolumn),1)) as [ASCIICode]
from  yourtable
where patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,yourcolumn) >0