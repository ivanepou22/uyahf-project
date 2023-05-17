pageextension 50007 "General Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("External Document No.")
        {
            field("Advance Code"; Rec."Advance Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Advance Code field.';
            }
            field("Entry Date"; Rec."Entry Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Entry Date field.';
            }
            field("Payment Type"; Rec."Payment Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Type field.';
            }
            field("Payment Voucher"; Rec."Payment Voucher")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Voucher field.';
            }
            field("Payment Voucher No."; Rec."Payment Voucher No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Voucher No. field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}