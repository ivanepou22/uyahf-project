/// <summary>
/// Table NFL Approval Comment Line (ID 50091).
/// </summary>
table 50013 "NFL Approval Comment Line"
{
    // version NFL02.000

    Caption = 'NFL Approval Comment Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(3; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";

            trigger OnValidate()
            begin
                if "Document Type" = "Document Type"::"Purchase Requisition" then begin
                    "Table ID" := 50069;
                    Modify();
                end else begin
                    "Table ID" := 50075;
                    Modify();
                end;
            end;
        }
        field(4; "Document No."; Code[50])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(6; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
            Editable = false;
        }
        field(7; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(8; "Comment Entry No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Document Type", "Document No.", "Table ID")
        {
        }
        key(Key2; "Table ID", "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        "User ID" := USERID;
        "Date and Time" := CREATEDATETIME(TODAY, TIME);
        IF "Entry No." = 0 THEN
            "Entry No." := GetNextEntryNo;
    end;

    /// <summary>
    /// Description for GetNextEntryNo.
    /// </summary>
    /// <returns>Return variable "Integer".</returns>
    local procedure GetNextEntryNo(): Integer;
    var
        ApprovalCommentLine: Record "NFL Approval Comment Line";
    begin
        ApprovalCommentLine.SETCURRENTKEY("Entry No.");
        IF ApprovalCommentLine.FIND('+') THEN
            EXIT(ApprovalCommentLine."Entry No." + 1)
        ELSE
            EXIT(1);
    end;
}

