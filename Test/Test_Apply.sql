DECLARE @RC int
DECLARE @Template nvarchar(max)=''
DECLARE @ObjectName nvarchar(max)='[@Templates].[@isDatabase@]'
DECLARE @p01 nvarchar(max)='master'
DECLARE @ParameterNameList nvarchar(max)='@database@'

EXECUTE @RC = [@@].[ApplyTemplateProcedure]
   @ObjectName=@ObjectName
  ,@Template=@Template OUTPUT
  ,@p01=@p01
  ,@ParameterNameList=@ParameterNameList

print 'Return Code: ' + CAST(@RC AS nvarchar(10))
PRINT 'Template:'
print '-------------'
print @Template
print '-------------'
