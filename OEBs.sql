USE MyiLibrary;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
BEGIN TRANSACTION;
GO

set nocount on

-- this is where your action code will go
	SELECT T.Title_ID, EAN.EAN
	  FROM mil_Titles as T
INNER JOIN tbl_Title_Cor_EANHolding_20150401 as EAN
		ON T.Title_ID = EAN.TitleID
	 WHERE T.Type = 'OEB'
	 Order By T.Title_ID
GO
COMMIT TRANSACTION;
GO