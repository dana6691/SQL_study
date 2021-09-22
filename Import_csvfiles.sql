
--BULK INSERT MULTIPLE FILES From a Folder 
DROP table allfilenames
--a table to loop thru filenames drop table ALLFILENAMES
CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255),WHICHFILE VARCHAR(255))

--some variables
DECLARE @filename VARCHAR(255),
        @path     VARCHAR(255),
        @sql      VARCHAR(8000),
        @cmd      VARCHAR(1000)


--get the list of files to process:
SET @path = 'C:\AdventureWorksDW-data-warehouse-install-script\'
SET @cmd = 'dir ' + @path + '*.csv /b'
INSERT INTO  ALLFILENAMES(WHICHFILE)
EXEC Master..xp_cmdShell @cmd
UPDATE ALLFILENAMES SET WHICHPATH = @path WHERE WHICHPATH is null

DELETE FROM ALLFILENAMES WHERE  WHICHFILE is null
--SELECT replace(whichfile,'.csv',''),* FROM dbo.ALLFILENAMES


--cursor loop
DECLARE c1 cursor for SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES WHERE WHICHFILE like '%.csv%' ORDER BY WHICHFILE DESC
OPEN c1
fetch next from c1 into @path,@filename
WHILE @@fetch_status <> -1
  BEGIN
  --bulk insert won't take a variable name, so make a sql and execute it instead:
   set @sql = 

   'select * into '+ Replace(@filename, '.csv','')+'
    from openrowset(''MSDASQL''
    ,''Driver={Microsoft Access Text Driver (*.txt, *.csv)}''
    ,''select * from '+@Path+@filename+''')' 


PRINT @sql
EXEC (@sql)

  fetch next from c1 into @path,@filename
  END
CLOSE c1
DEALLOCATE c1