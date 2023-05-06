/// <summary>
/// PageExtension Cash Vouchers Ext (ID 50300) extends Record Cash Vouchers.
/// </summary>
pageextension 50026 "Cash Vouchers Ext" extends "Cash Vouchers"
{
    layout
    {
        // Add changes to page layout here
        addafter("Prepared by")
        {
            field("Current Approver"; Rec."Current Approver")
            {
                ApplicationArea = All;
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