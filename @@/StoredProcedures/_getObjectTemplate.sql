CREATE PROCEDURE [@@].[_getObjectTemplate]
@Object NVARCHAR (MAX)
,@Template NVARCHAR (MAX) OUTPUT
,@OnlyBeginEndBlock bit =1
,@TrimLines bit =1
,@RemoveEmptyLines bit =1
,@RemoveLineComments bit=1
,@RemoveTabCRLF bit =1
AS
BEGIN
DECLARE @Text varchar(max)= OBJECT_DEFINITION(OBJECT_ID(@Object))
DECLARE @i int=0
DECLARE @p int=0
DECLARE @l int=LEN(@Text)
DECLARE @z varchar(max)
DECLARE @CRLF char(2)=[@@].[CRLF]()
DECLARE @Begin int=0
DECLARE @End int=0
DECLARE @Template_BeforeEnd NVARCHAR (MAX)=''
DECLARE @LoopCounter int=10000  -- Schutz gegen Endlosschleifen
SET @Template=''

WHILE @i <= @l AND @LoopCounter > 0
BEGIN
  SET @LoopCounter=@LoopCounter-1
  SET @p=CHARINDEX(@CRLF,@Text,@i)
  SET @z=SUBSTRING(@Text,@i,@p-@i)
  SET @i=@p+2

	-- Tabs und CR LF entfernen
  IF @RemoveTabCRLF=1
	BEGIN
		SET @z = REPLACE(REPLACE(REPLACE(@z,CHAR(9),''),CHAR(10),''),CHAR(13),'')
	END
  -- Blanks links, rechts entfernen
	IF @TrimLines=1
	BEGIN
		SET @z = LTRIM(RTRIM(@z))
	END
 	-- Kommentare strippen
  IF @RemoveLineComments=1
	BEGIN
		SET @z = LEFT(@z,CASE WHEN CHARINDEX('--',@z)=0 THEN LEN(@z) ELSE CHARINDEX('--',@z)-1 END)
	END
  -- leere zeilen löschen
	IF @RemoveEmptyLines=1
	BEGIN
		IF LEN(@z)=0 OR @z IS NULL
      CONTINUE
	END
  IF @OnlyBeginEndBlock=1
	BEGIN
    IF @z='END' and @Begin>0
    BEGIN
      SET @Template=@Template+@Template_BeforeEnd
      SET @Template_BeforeEnd=''
    END
    IF @Begin > 0
    BEGIN
      SET @Template_BeforeEnd=@Template_BeforeEnd+@z+@CRLF
    END
    IF @z='BEGIN' and @Begin=0
    BEGIN
      SET @Begin=1
    END
	END
  IF @OnlyBeginEndBlock=0
	BEGIN
    SET @Template=@Template+@z+@CRLF
  END
END
END
GO

