/****************************************************************************/
/*                       Pro SQL Server Internals                           */
/*      APress. 2nd Edition. ISBN-13: 978-1484219638 ISBN-10:1484219635     */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                      http://aboutsqlserver.com                           */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*            Chapter 36. Transaction Processing in In-Memory OLTP          */
/*                Referential Integrity Enforcement (Session 2)             */
/****************************************************************************/

set noexec off
go

if convert(int,
	left(
		convert(nvarchar(128), serverproperty('ProductVersion')),
		charindex('.',convert(nvarchar(128), serverproperty('ProductVersion'))) - 1
	)
) < 13 
begin
	raiserror('You should have SQL Server 2016 to execute this script',16,1) with nowait
	set noexec on
end
go

if convert(int, serverproperty('EngineEdition')) != 3 or charindex('X64',@@Version) = 0
begin
	raiserror('That script requires 64-Bit Enterprise Edition of SQL Server to run',16,1)
	set noexec on
end
go

if not exists (select * from sys.databases where name = 'SQLServerInternalsHK')
begin
	raiserror('Create [SQLServerInternalsHK] database with "02.Create In-Memory OLTP DB.sql" script from "00.Init" project',16,1)
	set noexec on
end
go

use SQLServerInternalsHK
go

--Session 2 code
update dbo.Transactions with (snapshot) 
set Amount = 30
where TransactionId = 2;

