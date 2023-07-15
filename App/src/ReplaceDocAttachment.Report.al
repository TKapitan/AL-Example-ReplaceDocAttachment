report 50000 "TKA Replace Doc. Attachment"
{
    Caption = 'Replace Document Attachment';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    dataset
    {
        dataitem(DocumentAttachment; "Document Attachment")
        {
            trigger OnPreDataItem()
            var
                NoOfFilesToReplace: Integer;
                NoFilesToReplaceErr: Label 'There are no files to replace.';
                ReplaceFilesQst: Label 'Do you really want to replace %1 files?', Comment = '%1 - number of files';
            begin
                DocumentAttachment.SetRange("File Name", FileName);
                DocumentAttachment.SetRange("File Type", DocumentAttachmentFileType);
                DocumentAttachment.SetFilter("Table ID", GetExcludedTablesFilter());

                NoOfFilesToReplace := DocumentAttachment.Count();
                if NoOfFilesToReplace = 0 then
                    Error(NoFilesToReplaceErr);
                if not Confirm(ReplaceFilesQst, false, NoOfFilesToReplace) then
                    Error('');
            end;

            trigger OnAfterGetRecord()
            begin
                DocumentAttachment.TKAReplaceAttachment(NewAttachmentTempBlob.CreateInStream(), ReplaceByFileName);
            end;

            trigger OnPostDataItem()
            var
                FilesReplacedMsg: Label 'Files were replaced.';
            begin
                Message(FilesReplacedMsg);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Replace)
                {
                    field(DocumentNameField; FileName)
                    {
                        Caption = 'File Name';
                        ToolTip = 'Specifies name of the file that should be replaced.';
                        NotBlank = true;
                        ApplicationArea = All;
                    }
                    field(DocumentAttachmentFileTypeField; DocumentAttachmentFileType)
                    {
                        Caption = 'Document File Type';
                        ToolTip = 'Specifies file type of the file that should be replaced.';
                        NotBlank = true;
                        ApplicationArea = All;
                    }
                    field(ReplaceByFileNameField; ReplaceByFileName)
                    {
                        Caption = 'New File';
                        Editable = false;
                        ToolTip = 'Specifies the filename of the new file.';
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        var
                            FileManagement: Codeunit "File Management";
                            ImportTxt: Label 'Attach a document.';
                            FileDialogTxt: Label 'Attachments (%1)|%1', Comment = '%1=file types, such as *.txt or *.docx';
                            FilterTxt: Label '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.*', Locked = true;
                        begin
                            ReplaceByFileName := FileManagement.BLOBImportWithFilter(
                                NewAttachmentTempBlob, ImportTxt, ReplaceByFileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt
                            );
                        end;
                    }

                }
            }
        }
    }

    trigger OnPreReport()
    var
        NewFileNameMandatoryErr: Label 'New File Name is mandatory.';
        DocumentNameAndTypeMandatoryErr: Label 'File Name and File Type are mandatory fields.';
    begin
        if (FileName = '') or (DocumentAttachmentFileType = DocumentAttachmentFileType::" ") then
            Error(DocumentNameAndTypeMandatoryErr);
        if ReplaceByFileName = '' then
            Error(NewFileNameMandatoryErr);
    end;

    var
        NewAttachmentTempBlob: Codeunit "Temp Blob";
        FileName, ReplaceByFileName : Text;
        DocumentAttachmentFileType: Enum "Document Attachment File Type";

    local procedure GetExcludedTablesFilter(): Text
    var
        ExcludedTables: List of [Integer];
        ExcludedTablesFilterTextBuilder: TextBuilder;
        ExcludedTable: Integer;
        ExcludedTablesFilterTok: Label '<>%1', Locked = true;
    begin
        ExcludedTables.Add(Database::"Sales Invoice Header");
        ExcludedTables.Add(Database::"Sales Invoice Line");
        ExcludedTables.Add(Database::"Sales Shipment Header");
        ExcludedTables.Add(Database::"Sales Shipment Line");
        ExcludedTables.Add(Database::"Sales Cr.Memo Header");
        ExcludedTables.Add(Database::"Sales Cr.Memo Line");
        ExcludedTables.Add(Database::"Return Receipt Header");
        ExcludedTables.Add(Database::"Return Receipt Line");
        ExcludedTables.Add(Database::"Purch. Inv. Header");
        ExcludedTables.Add(Database::"Purch. Inv. Line");
        ExcludedTables.Add(Database::"Purch. Rcpt. Header");
        ExcludedTables.Add(Database::"Purch. Rcpt. Line");
        ExcludedTables.Add(Database::"Purch. Cr. Memo Hdr.");
        ExcludedTables.Add(Database::"Purch. Cr. Memo Line");
        ExcludedTables.Add(Database::"Return Shipment Header");
        ExcludedTables.Add(Database::"Return Shipment Line");
        ExcludedTables.Add(Database::"Cust. Ledger Entry");
        ExcludedTables.Add(Database::"Vendor Ledger Entry");
        ExcludedTables.Add(Database::"G/L Entry");
        ExcludedTables.Add(Database::"VAT Entry");
        OnGetExcludedTablesFilterAfterCreateListOfExcludedTables(ExcludedTables);

        foreach ExcludedTable in ExcludedTables do begin
            if ExcludedTablesFilterTextBuilder.Length() <> 0 then
                ExcludedTablesFilterTextBuilder.Append('&');
            ExcludedTablesFilterTextBuilder.Append(StrSubstNo(ExcludedTablesFilterTok, ExcludedTable));
        end;
        exit(ExcludedTablesFilterTextBuilder.ToText());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetExcludedTablesFilterAfterCreateListOfExcludedTables(var ExcludedTables: List of [Integer])
    begin
    end;
}