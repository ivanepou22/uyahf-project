/// <summary>
/// PageExtension Requisition Approval Form Ext (ID 50033) extends Record Requisition Approval Form.
/// </summary>
pageextension 50022 "Requisition Approval Form Ext" extends "Requisition Approval Form"
{
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Home,Delegate';
    layout
    {
        // Add changes to page layout here
        addafter("Converted to Order")
        {
            field("Approvals Entry"; Rec."Approvals Entry")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst(Processing)
        {
            group(Approve1)
            {
                Caption = 'Approve';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    trigger OnAction()
                    var
                        ApprovalEntry: Record "Approval Entry";
                        ClaimCount: Integer;
                        Txt001: Label 'Are you sure you want to Approve this document ?';
                        Txt002: Label 'Please make Sure you have at least one line in the Requisition Lines';
                        UserSetup: Record "User Setup";
                    // ApprovalDoc: Codeunit "NFL Approvals Management";
                    begin
                        if Rec.Status = Rec.Status::Released then
                            Error('This document is already released');
                        if Rec.Status = Rec.Status::Open then
                            Error('Document Status must be set to Pending Approval');


                        if Rec."Requisition Lines Total" <= 0 then begin
                            Error(Txt002);
                        end;

                        if Confirm(Txt001, true) then begin
                            ClaimCount := 0;
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
                            ApprovalEntry.SetRange(ApprovalEntry."Approval Type", ApprovalEntry."Approval Type"::Approver);
                            ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
                            if ApprovalEntry.FindFirst() then begin
                                ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                                if Rec."Approvals Entry" = 0 then
                                    Rec.SendRequisitionApprovedEmail();
                            end
                            else begin
                                UserSetup.Reset();
                                UserSetup.SetRange(UserSetup."User ID", UserId);
                                UserSetup.SetRange(UserSetup."SBU Head", true);
                                if UserSetup.FindFirst() then begin
                                    // ApprovalDoc.CheckBudgetPurchase(Rec);
                                end;
                                ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                                Rec.ReleaseTheApprovedDoc();
                            end;
                            //Send email implemented
                            customFunction.OpenApprovalEntries(Rec);
                        end;
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    trigger OnAction()
                    var
                        RequisitionHeader: Record "NFL Requisition Header";
                    // ApprovalComments: Record "NFL Approval Comment Line";
                    begin
                        if Confirm('Are you sure you want to Reject this Requisition ?', true) then begin
                            //Checking for comments before rejecting
                            // ApprovalComments.Reset();
                            // ApprovalComments.SetRange(ApprovalComments."Document No.", Rec."No.");
                            // ApprovalComments.SetRange(ApprovalComments."Document Type", Rec."Document Type");
                            // ApprovalComments.SetRange(ApprovalComments."User ID", UserId);
                            // if ApprovalComments.FindFirst() then begin
                            //     ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            //     //Send email implemented
                            //     customFunction.RejectApprovalRequest(Rec);
                            // end else begin
                            //     Error('You can not reject a document with out a comment.');
                            // end;
                        end;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    trigger OnAction()
                    var
                        Txt002: Label 'Are you sure you want to Delegate this document ?';
                        userSetup: Record "User Setup";
                        ApprovalEntries: Record "Approval Entry";
                    begin
                        if Confirm(Txt002, true) then begin
                            userSetup.Reset();
                            userSetup.SetRange(userSetup."User ID", UserId);
                            if userSetup.Find('-') then begin
                                ApprovalEntries.Reset();
                                ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No.");
                                ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Open);
                                if ApprovalEntries.Find('-') then begin
                                    if (userSetup."Voucher Admin" = true) or (UserId = ApprovalEntries."Approver ID") then begin
                                        customFunction.DelegatePurchaseApprovalRequest(Rec);
                                        //Send Email implemented
                                        Rec.SendingDelegateEmail(Rec);
                                    end else begin
                                        Error('Your Not Allowed to Delegate this voucher');
                                    end;
                                end else begin
                                    Error('You can not perform this action. Contact your Systems Administrator');
                                end;
                            end;

                        end;
                    end;
                }

                action(Escalate)
                {
                    ApplicationArea = All;
                    Caption = 'Escalate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Escalate the approval Request to an Escalate approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    trigger OnAction()
                    var
                        Txt002: Label 'Are you sure you want to Escalate this document ?';
                        RequisitionLineTotal: Decimal;
                        UserSetup: Record "User Setup";
                    // ApprovalDoc: Codeunit "NFL Approvals Management";
                    begin
                        Rec.CalcFields("Requisition Lines Total");
                        RequisitionLineTotal := Rec."Requisition Lines Total";
                        if RequisitionLineTotal <= 0 then
                            Error('Requisition Lines are Empty, You cannot Escalate this Document');

                        if Confirm(Txt002, true) then begin
                            //Send Email implemented
                            customFunction.EscalateApprovalRequest(Rec);
                        end;
                    end;
                }
                action("Approval Comments")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Caption = 'Approval Comments';
                    Image = Comment;
                    // RunObject = page "NFL Approval Comments";TODO:
                    // RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50069);
                }
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForcurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalsMgmtCut: Codeunit "Custom Functions Requisition";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        OpenApprovalEntriesExistForcurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        gvHeaderTotal: Decimal;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApprovalForFlow: Boolean;
        sendApprovalRequest: Boolean;
        Text0022: Label 'There must be atleast one line with amount in the Purchase requisition Details Subform';
        CancelApprovalVisible: Boolean;
        customFunction: Codeunit "Custom Functions Requisition";

    trigger OnOpenPage()

    begin
        if Rec.Status = Rec.Status::Open then begin
            sendApprovalRequest := true;
        end else begin
            sendApprovalRequest := false;
        end;

        if Rec.Status = Rec.Status::Released then begin
            CancelApprovalVisible := false;
        end else begin
            CancelApprovalVisible := true;
        end;
    end;
}