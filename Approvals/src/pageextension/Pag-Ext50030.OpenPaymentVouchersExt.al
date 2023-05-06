/// <summary>
/// PageExtension Open Payment Vouchers Ext (ID 50310) extends Record Open Payment Vouchers.
/// </summary>
pageextension 50030 "Open Payment Vouchers Ext" extends "Open Payment Vouchers"
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