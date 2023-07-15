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
                DocumentAttachment.SetFilter("Table ID",
                    '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8&<>%9&<>%10&<>%11&<>%12&<>%13&<>%14&<>%15&<>%16&<>%17&<>%18&<>%19&<>%20',
                    Database::"Sales Invoice Header", Database::"Sales Invoice Line",
                    Database::"Sales Shipment Header", Database::"Sales Shipment Line",
                    Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Line",
                    Database::"Return Receipt Header", Database::"Return Receipt Line",
                    Database::"Purch. Inv. Header", Database::"Purch. Inv. Line",
                    Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Line",
                    Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Line",
                    Database::"Return Shipment Header", Database::"Return Shipment Line",
                    Database::"Cust. Ledger Entry", Database::"Vendor Ledger Entry", Database::"G/L Entry", Database::"VAT Entry"
                );

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
}