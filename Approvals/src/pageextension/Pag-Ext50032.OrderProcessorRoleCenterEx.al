pageextension 50032 "Order Processor Role Center Ex" extends "Order Processor Role Center"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Commitment Ledger Entries")
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