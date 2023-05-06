/// <summary>
/// PageExtension ListofAll Payment Vouchers Ext (ID 50307) extends Record List of All Payment Vouchers.
/// </summary>
pageextension 50027 "ListofAll Payment Vouchers Ext" extends "List of All Payment Vouchers"
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
}