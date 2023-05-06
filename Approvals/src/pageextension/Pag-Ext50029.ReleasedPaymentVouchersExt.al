/// <summary>
/// PageExtension Released Payment Vouchers Ext (ID 50309) extends Record Released Payment Vouchers.
/// </summary>
pageextension 50029 "Released Payment Vouchers Ext" extends "Released Payment Vouchers"
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