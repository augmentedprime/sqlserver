-- Change white values
-- @Name should be DB_name
-- @Subject/@Description are the same (should be what your dataset is named on Confluence)
USE GLOBAL

DECLARE @Name AS VARCHAR(200) = ''

DECLARE @Subject AS VARCHAR(8000) = ''

DECLARE @Description AS VARCHAR(200) = ''

INSERT INTO Report (ReportName, To_EmailAddresses, CC_EmailAddresses, From_EmailAddresses, From_Name, Subject, ReplyTo_EmailAddresses, Attachment, Priority, Attachments, EmailType, Server, ReportType, msrepl_tran_version, BCC_EmailAddresses)
	VALUES (@Name, 'DL-DataServices@gvsi.com', NULL, 'DL-DataServices', 'GVSI Data Factory', @Subject, 'DL-DataServices@gvsi.com', NULL, 'Normal', NULL, 'TextPlain', 'mail.gvsi.com', 1, DEFAULT, NULL);

	INSERT INTO DataProvider (Name, Description, msrepl_tran_version)
	VALUES (@Name, @Description, DEFAULT);