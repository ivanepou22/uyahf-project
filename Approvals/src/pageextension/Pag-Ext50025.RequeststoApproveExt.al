/// <summary>
/// PageExtension Requests to Approve Ext (ID 50042) extends Record Requests to Approve.
/// </summary>
pageextension 50025 "Requests to Approve Ext" extends "Requests to Approve"
{
    layout
    {
        modify(Comment) { Visible = false; }
        modify("Amount (LCY)") { Visible = false; }
        // Add changes to page layout heret
        addbefore(ToApprove)
        {
            field("Document No."; Rec."Document No.")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here

        modify(Approve)
        {
            Visible = VisibleApprove;
        }
        modify(Reject)
        {
            Visible = VisibleReject;
        }
        modify(Delegate)
        {
            Visible = VisibleDelegate;
        }
        modify(Comments)
        {
            Visible = false;
        }
    }

    var
        VisibleApprove: Boolean;
        VisibleReject: Boolean;
        VisibleDelegate: Boolean;

    trigger OnAfterGetRecord()
    begin
        if (Rec."Table ID" = Database::"Payment Voucher Header") or (Rec."Table ID" = Database::"NFL Requisition Header") then begin
            VisibleApprove := false;
            VisibleReject := false;
            VisibleDelegate := false;
        end;
    end;
}