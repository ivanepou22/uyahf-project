/// <summary>
/// </summary>
table 50014 "NFL Requisition Comment Line"
{
    // version MAG

    Caption = 'Purch. Comment Line';
    DrillDownPageID = 68;
    LookupPageID = 68;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return";
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
        }
        field(5; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(6; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(7; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(8; "Old Value"; Decimal)
        {
            Editable = false;
        }
        field(9; "New Value"; Decimal)
        {
            Editable = false;
        }
        field(10; Username; Code[50])
        {
            Editable = false;
        }
        field(11; "System Created"; Boolean)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.", "Document Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        IF "System Created" = TRUE THEN
            ERROR('You can not delete a system created comment line');
    end;

    /// <summary>
    /// Description for SetUpNewLine.
    /// </summary>
    procedure SetUpNewLine();
    var
        NFLReqnCommentLine: Record "NFL Requisition Comment Line";
    begin
        NFLReqnCommentLine.SETRANGE("Document Type", "Document Type");
        NFLReqnCommentLine.SETRANGE("No.", "No.");
        NFLReqnCommentLine.SETRANGE("Document Line No.", "Document Line No.");
        NFLReqnCommentLine.SETRANGE(Date, WORKDATE);
        IF NOT NFLReqnCommentLine.FINDFIRST THEN
            Date := WORKDATE;
    end;
}

