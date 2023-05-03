/// <summary>
/// Table Payt Voucher Detail Archieve (ID 50090).
/// </summary>
table 50007 "Payt Voucher Detail Archieve"
{
    // version MAG

    Caption = 'Payt Voucher Detail Archieve';

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
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";
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
}

