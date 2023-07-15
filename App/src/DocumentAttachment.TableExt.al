tableextension 50000 "TKA Document Attachment" extends "Document Attachment"
{
    procedure TKAReplaceAttachment(AttachmentInStream: InStream; FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        FileNameMustHaveValueErr: Label 'File Name must have a value.';
    begin
        if FileName = '' then
            Error(FileNameMustHaveValueErr);

        Validate("File Extension", FileManagement.GetExtension(FileName));
        Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen("File Name")));

        "Document Reference ID".ImportStream(AttachmentInStream, '');
        if not "Document Reference ID".HasValue() then
            Error(NoDocumentAttachedErr);

        Validate("Attached Date", CurrentDateTime);
        Rec."Attached By" := UserSecurityId();
        Rec.Modify(true);
    end;

}