/// <summary>
/// Table Purchase Requisition Detail (ID 50073).
/// </summary>
table 50007 "Purchase Requisition Detail"
{
    // version MAG

    Caption = 'Payment Voucher Detail';

    fields
    {
        field(1; "Document No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
            Editable = false;
        }
        field(3; Details; Text[150])
        {
            Caption = 'Details';
        }
        field(4; Amount; Decimal)
        {
            DecimalPlaces = 0 : 2;
        }
        field(5; "Commitment Entry No."; Integer)
        {
        }
        field(6; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Payment Requisition,Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Payment Requisition","Payment Voucher";
        }
    }

    keys
    {
        key(Key1; "Document No.", "Document Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        NFLRequisitionLine.SETRANGE("Document Type", "Document Type");
        NFLRequisitionLine.SETRANGE("Document No.", "Document No.");
        IF NFLRequisitionLine.COUNT > 0 THEN
            ERROR('You can not delete the Payment Voucher Details because it already has related Payment Voucher Lines');
    end;

    var
        NFLRequisitionHeader: Record "NFL Requisition Header";
        NFLRequisitionLine: Record "NFL Requisition Line";
}

