SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 2/5/2015
--	Taken from http://www.nigelrivett.net/SQLTsql/ParseCSVString.html
--	Written by Author Nigel Rivett 

CREATE function [dbo].[WP_fn_Parse_CSV]
(
@CSVString 	varchar(8000) ,
@Delimiter	varchar(10)
)
returns @tbl table (item varchar(100))
as
/*
select * from dbo.[WP_fn_Parse_CSV] ('qwe,c,rew,c,wer', ',c,')
select * from dbo.[WP_fn_Parse_CSV] ('qwe,c,rew,c,wer', ',')
*/
begin
declare @i int ,
	@j int
	select 	@i = 1
	while @i <= len(@CSVString)
	begin
		select	@j = charindex(@Delimiter, @CSVString, @i)
		if @j = 0
		begin
			select	@j = len(@CSVString) + 1
		end
		insert	@tbl select substring(@CSVString, @i, @j - @i)
		select	@i = @j + len(@Delimiter)
	end
	return
end
GO
