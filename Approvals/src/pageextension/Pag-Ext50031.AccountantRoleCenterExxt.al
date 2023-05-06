/// <summary>
/// PageExtension Accountant Role Center Exxt (ID 50311) extends Record Accountant Role Center.
/// </summary>
pageextension 50031 "Accountant Role Center Exxt" extends "Accountant Role Center"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addbefore("Staff Advances")
        {
            action("Transfer Voucher Approvals")
            {
                ApplicationArea = All;
                Caption = 'Transfer Payment Vouchers Approvals';
                RunObject = report "Transfer Voucher Approval";
            }
            action("Transfer Purch. Req. Approvals")
            {
                ApplicationArea = All;
                Caption = 'Transfer Purchase Requisition Approvals';
                RunObject = report "Transfer Purch. Vouch Approval";
            }
        }
    }

    var
        myInt: Integer;
}