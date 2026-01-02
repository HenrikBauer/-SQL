CREATE   PROCEDURE [@@].[_getObjectTemplate]
@Object NVARCHAR (MAX)
,@Template NVARCHAR (MAX)='' OUTPUT
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

DECLARE @Begin int=0
DECLARE @End int=0
DECLARE @Template_BeforeEnd NVARCHAR (MAX)=''

DECLARE @EOL varchar(2)=[@@].[CRLF]()
-- Prüfen, ob CRLF, LF oder CR als Zeilenumbruch verwendet wird
SET @p=CHARINDEX(@EOL,@Text,@i)
if @p=0 
begin
  set @EOL=char(10)  -- nur LF
  SET @p=CHARINDEX(@EOL,@Text,@i)
END
if @p=0 set @EOL=char(13) -- nur CR

DECLARE @EOL_LEN int=LEN(@EOL)
DECLARE @LoopCounter int=Len(@Text)-LEN(REPLACE(@Text,@EOL,''))+1  -- Schutz gegen Endlosschleifen, -- Anzahl der Zeilenumbrüche
WHILE @i <= @l AND @LoopCounter > 0
BEGIN
  SET @LoopCounter=@LoopCounter-1
  SET @p=CHARINDEX(@EOL,@Text,@i)
  IF @p=0
  BEGIN
    SET @p=@l+1
    SET @z=SUBSTRING(@Text,@i,@l)
  END
  ELSE
  BEGIN
    SET @z=SUBSTRING(@Text,@i,@p-@i)
  END
  SET @i=@p+@EOL_LEN

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
      SET @Template_BeforeEnd=@Template_BeforeEnd+@z+@EOL
    END
    IF @z='BEGIN' and @Begin=0
    BEGIN
      SET @Begin=1
    END
	END
  
  IF @OnlyBeginEndBlock=0
	BEGIN
    SET @Template=@Template+@z+@EOL
  END
END
END
GO

