/****************************************************************************/
/*                       Pro SQL Server Internals                           */
/*      APress. 2nd Edition. ISBN-13: 978-1484219638 ISBN-10:1484219635     */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                      http://aboutsqlserver.com                           */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*            Chapter 36. Transaction Processing in In-Memory OLTP          */
/*                  Concurrency Model: Snapshot (Session 1)                 */
/****************************************************************************/

set noexec off
go

if convert(int,
		left(
			convert(nvarchar(128), serverproperty('ProductVersion')),
			charindex('.',convert(nvarchar(128), serverproperty('ProductVersion'))) - 1
		)
) < 12 
begin
	raiserror('You should have SQL Server 2014-2016 to execute this script',16,1) with nowait;
	set noexec on
end
go

if convert(int, serverproperty('EngineEdition')) != 3 or charindex('X64',@@Version) = 0
begin
	raiserror('That script requires 64-Bit Enterprise Edition of SQL Server to run',16,1);
	set noexec on
end
go

if not exists (select * from sys.databases where name = 'SQLServerInternalsHK')
begin
	raiserror('Create [SQLServerInternalsHK] database with "02.Create In-Memory OLTP DB.sql" script from "00.Init" project',16,1);
	set noexec on
end
go

use SQLServerInternalsHK
go

if not exists
(
	select * 
	from sys.tables t join sys.schemas s on 
		t.schema_id = s.schema_id 
	where s.name = 'dbo' and t.name = 'HKData'
)
begin
	raiserror('Create dbo.HKData table using "01.Test Table Creation.sql" script',16,1);
	set noexec on
end
go

/*** Test 1 ***/
-- Step 1
begin tran
	select ID, Col 
	from dbo.HKData with (snapshot);

	/*** Run Session 2 code ***/

	-- Step 2
	select ID, Col 
	from dbo.HKData with (snapshot);
commit
go

/*** Test 2 ***/
-- Step 1
begin tran
	select ID, Col 
	from dbo.HKData with (snapshot);

	/*** Run Session 2 code ***/

	-- Step 2
	select ID, Col 
	from dbo.HKData with (snapshot);
commit
go