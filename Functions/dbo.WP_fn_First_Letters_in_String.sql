SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



--KA: Sep 2014
--This funtion is used for Profile pages to generate acronyms for Journal names

CREATE FUNCTION [dbo].[WP_fn_First_Letters_in_String] ( @str NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @name_dup int
	DECLARE @short_name varchar(20)
	
		--KA: Remove quotes in the string
		SET @str = REPLACE(@str, '''', '')
		
	   --kA: Remove extra spaces between words
		SET @str = replace(replace(replace(@str,' ','<>'),'><',''),'<>',' ')	
		
		--KA: Get number of words in the string
		DECLARE @str_length int
		SET @str_length = LEN(@str) - LEN(REPLACE(@str, ' ', '')) + 1		
		
		--KA: If a string has more than 3 words, then pick the first letter of each word that starts with an uppercase (hence ignore conjunctions/preposition words like - of, it, an, and, etc)
		--E.x: Journal long name: International Journal of Strategic Information Technology and Applications
		--Journal acronym would be: ijsita   (ignores "of" & "and" in the acronym)
		--The total length of the acronym is limited to 6 characters.
		
			If @str_length > 3
			
			--=====================
			--KA: This function below retrieves only uppercase letters from a string
			--Codes: Courtesy: forums.asp.net.	
			
				BEGIN							
					DECLARE @RetCapLetters varchar(100)
					SET @RetCapLetters=''

					;WITH CTE AS
					(
						SELECT @str As oldstr,1 As TotalLen,SUBSTRING(@str,1,1) As newstr,
						ASCII(SUBSTRING(@str,1,1)) As AsciVal
						
						UNION ALL
						
						SELECT oldstr,TotalLen+1 As TotalLen,
						substring(@str,TotalLen+1,1) As newstr,
						ASCII(SUBSTRING(@str,TotalLen+1,1)) As AsciVal
						FROM CTE
						where CTE.TotalLen<=LEN(@str)
					)
					SELECT	@RetCapLetters= LEFT(@RetCapLetters+newstr ,6)
					FROM	CTE
							Inner Join master..spt_values as m on CTE.AsciVal=m.number and CTE.AsciVal between 65 and 90	
							
					
				END
			--===================
			
			--KA: When the journal name has 3 words including conjunctions/prepositions (and, or etc), the acronym could become too short, maybe 2 letters. 
			--Hence to avoid this, this case is handled differently.
			--If a string has 3 words, pick first 2 letters from each word to form the acronym. Hence the max length would be 6 characters.
			--e.x: Long name: 'AA rE    3'   (notice the extra space)
			--Short name: 'aare3'
			ELSE IF @str_length = 3
				BEGIN
					SET @str =SUBSTRING(@str, PATINDEX('%[A-Z]%', @str), LEN(@str))
					SET @str = (SELECT REPLACE(dbo.WP_fn_first_letters_in_string_sub((@str), 2) , ' ', '-')) 
					SELECT @RetCapLetters = lower(LEFT(@str, 6))
					
			
					
				END
			
			--If a string has 2 words, pick first 3 letters from each word to form the acronym. Hence the max length would be 6 characters.
			ELSE If @str_length = 2
				BEGIN
					SET @str =SUBSTRING(@str, PATINDEX('%[A-Z]%', @str), LEN(@str))
					SET @str = (SELECT REPLACE(dbo.WP_fn_first_letters_in_string_sub((@str), 3) , ' ', '-')) 
					SELECT @RetCapLetters = lower(LEFT(@str, 6))
					
				END
			
			ELSE IF @str_length = 1
				BEGIN
					--SELECT @RetCapLetters = lower(LEFT(@str, 6))
					SELECT @RetCapLetters = lower(@str)
				END
			
		--RETURN lower(LEFT(@RetCapLetters, 6))
		
		--Check for duplicates		
		DECLARE @random_str VARCHAR(5)		
		SET @random_str = dbo.[WP_fn_Random_string]()
		--PRINT @Random_string

				
		SET @short_name = @RetCapLetters					
		SET  @name_dup = (	SELECT count (*) 
							FROM DM_Shadow_Staging.[dbo].[Journal]
							WHERE journal_name = @short_name)
		
		
		IF @name_dup = 0
			BEGIN 
				SELECT @RetCapLetters = @RetCapLetters
			END
		ELSE
			BEGIN
				SELECT @RetCapLetters = @RetCapLetters + @random_str
			END
		
		
		
		RETURN lower(@RetCapLetters)
		
		
		
		

END

/*
SELECT dbo.WP_fn_first_letters_in_string('Commission on Auditors Responsibilities of the American Institute of Certified Public Accountants, New York')
SELECT dbo.WP_fn_first_letters_in_string('International Journal of Strategic Information Technology and Applications')
SELECT dbo.WP_fn_first_letters_in_string('AA rE    3')
SELECT dbo.WP_fn_first_letters_in_string('Test Journal 2')
SELECT dbo.WP_fn_first_letters_in_string('2011 JAR Conference')
SELECT dbo.WP_fn_first_letters_in_string('Accounting')
SELECT dbo.WP_fn_first_letters_in_string('B.E. Journal of Economic Analysis and Policy')

*/

GO
