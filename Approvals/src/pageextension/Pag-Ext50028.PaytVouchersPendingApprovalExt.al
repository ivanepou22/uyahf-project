/// <summary>
/// PageExtension PaytVouchersPendingApprovalExt (ID 50308) extends Record Payt Vouchers Pending Approval.
/// </summary>
pageextension 50028 "PaytVouchersPendingApprovalExt" extends "Payt Vouchers Pending Approval"
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