/// <summary>
/// PageExtension Purchase Requisition Ext (ID 50032) extends Record Purchase Requisition.
/// </summary>
pageextension 50021 "Purchase Requisition Ext" extends "Purchase Requisition"
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
            field(Freelance; Rec.Freelance)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Current Approver"; Rec."Current Approver")
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
                        ApprovalDoc: Codeunit "Custom Functions Requisition";
                    begin
                        if Rec.Status = Rec.Status::Released then
                            Error('This document is already released');
                        if Rec.Status = Rec.Status::Open then
                            Error('Document Status must be set to Pending Approval');

                        Rec.TestField("Raised By");
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
                            end
                            else begin
                                UserSetup.Reset();
                                UserSetup.SetRange(UserSetup."User ID", UserId);
                                UserSetup.SetRange(UserSetup."SBU Head", true);
                                if UserSetup.FindFirst() then begin
                                    ApprovalDoc.CheckBudgetPurchase(Rec);
                                end;
                                ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                                Rec.ReleaseTheApprovedDoc();
                            end;
                            //Send email implemented
                            customFunction.OpenApprovalEntries(Rec);
                            Rec.CheckForBudgetControllerApproval(Rec);
                            Rec.CheckDocumentRelease(Rec);
                            Rec.SendRequisitionApprovedEmail(Rec);
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
                        ApprovalComments: Record "Sales Comment Line";
                        ApprovalComments2: Record "Sales Comment Line";
                        approvalComment: Page "Sales Comment Sheet";
                    begin
                        if Confirm('Are you sure you want to Reject this Requisition ?', true) then begin
                            //Checking for comments before rejecting
                            Rec.TestField("Raised By");
                            ApprovalComments.Reset();
                            ApprovalComments.SetRange(ApprovalComments."No.", Rec."No.");
                            ApprovalComments.SetRange(ApprovalComments."Document Type", ApprovalComments."Document Type"::"Purchase Requisition");
                            if ApprovalComments.FindFirst() then begin
                                ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                                customFunction.RejectApprovalRequest(Rec);
                                Rec.ReversePurchaseRequisitionCommitmentEntryOnRejectOrReopen();
                                Rec.SendRejectEmail(Rec);
                            end else begin
                                ApprovalComments2.Reset();
                                ApprovalComments2.SetRange(ApprovalComments2."Document Type", ApprovalComments2."Document Type"::"Purchase Requisition");
                                ApprovalComments2.SetRange(ApprovalComments2."No.", Rec."No.");
                                ApprovalComments2.SetRange("Document Line No.", 0);
                                approvalComment.SetTableView(ApprovalComments2);
                                approvalComment.Run();
                            end;
                        end;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = StatusPending;
                    trigger OnAction()
                    var
                        Txt002: Label 'Are you sure you want to Delegate this document ?';
                        CustomPurchFunction: Codeunit "Custom Functions Requisition";
                    begin
                        if Confirm(Txt002, true) then begin
                            Rec.TestField("Raised By");
                            CustomPurchFunction.DelegatePurchaseApprovalRequest(Rec);
                            Rec.SendRequisitionApprovedEmail(Rec);
                        end;
                    end;
                }
            }

        }

        addafter(Approve1)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                action("Send A&pproval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    ToolTip = 'Request approval of the document.';
                    trigger OnAction()
                    var
                        UserSetup: Record "User Setup";
                        RequisitionDetailTotal: Decimal;
                        customCodeunit: Codeunit "Custom Functions Requisition";
                    begin
                        Rec.CalcFields("Requisition Details Total");
                        Rec.CalcFields("Requisition Lines Total");
                        gvHeaderTotal := Rec."Requisition Details Total";
                        RequisitionDetailTotal := Rec."Requisition Details Total";
                        IF (Rec."Currency Code" <> '') AND (gvHeaderTotal <= 0) THEN
                            ERROR(Text0022)

                        ELSE
                            IF (Rec."Currency Code" = '') AND (gvHeaderTotal <= 100) THEN
                                ERROR(Text0022);

                        Rec.TESTFIELD("Request-By No.");
                        Rec.TESTFIELD("Posting Date");
                        Rec.TESTFIELD("Shortcut Dimension 1 Code");
                        Rec.TESTFIELD("Order Date");
                        Rec.TESTFIELD("Document Date");
                        Rec.TESTFIELD("Budget Code");
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField("Raised By");

                        IF Rec."Prepared by" <> USERID THEN
                            ERROR('The selected request can only be sent for approval by the initiator %1', Rec."Prepared by");

                        IF Rec."Posting Description" = '' THEN
                            ERROR('Please specify the subject of Procurement');

                        if Confirm('Are you sure you want to send this Approval Request ?', true) then begin
                            if ApprovalsMgmtCut.CheckClaimApprovalsWorkflowEnable(Rec) then begin
                                ApprovalsMgmtCut.OnSendClaimForApproval(Rec);
                                customCodeunit.modifyApprovalEntry(Rec);
                            end;
                            Rec.SendRequisitionApprovedEmail(Rec)
                        end;
                    end;
                }

                action(ApprovalComments)
                {
                    ApplicationArea = All;
                    Caption = 'Approval Comments';
                    Image = Comment;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'Add a comment about the approval request';
                    RunObject = page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Purchase Requisition"),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0);
                }
                action("Cancel Approval Re&quest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = ViewCancel;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ToolTip = 'Cancel the approval request.';
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                        RequisitionHeader: Record "NFL Requisition Header";
                        CUstp: Record "User Setup";
                        ApprovalEntry: Record "Approval Entry";
                    begin
                        Rec.TestField("Raised By");
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if Rec."Converted to Order" = TRUE then
                            ERROR('The purchase requisition has already been converted to an order');
                        IF Rec."Prepared by" <> USERID THEN BEGIN
                            CUstp.SETRANGE(CUstp."User ID", USERID);
                            IF CUstp.FIND('-') THEN BEGIN
                                IF CUstp."Voucher Admin" = FALSE THEN
                                    ERROR('The voucher can only be cancelled by the initiator %1', Rec."Prepared by");
                            END;
                        END;
                        if Confirm('Are you sure you want to cancel this request ?', true) then begin
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
                            ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
                            if ApprovalEntry.FindFirst() then begin
                                customFunction.CancelPurchaseApprovalRequest(Rec);
                                //send Email implemented
                                Rec.SendingCancelApprovalEmail(Rec);
                            end else begin
                                //ApprovalsMgmtCut.OnCancelClaimForApproval(Rec);
                                customFunction.CancelPurchaseApprovalRequest(Rec);
                                //send Email implemented
                                Rec.SendingCancelApprovalEmail(Rec);
                            end;

                            Rec.ReversePurchaseRequisitionCommitmentEntryOnRejectOrReopen();
                        end;
                    end;
                }

                action(ReOpen)
                {
                    ApplicationArea = All;
                    Caption = 'ReOpen';
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    ToolTip = 'Reopens the Requisition Document';
                    Image = ReOpen;
                    trigger OnAction()
                    var
                        RequisitionHeader: Record "NFL Requisition Header";
                    begin
                        if Confirm('Are You Want to Open This Document ?', true) then begin
                            RequisitionHeader.PerformManualReopen(Rec);
                            //send email implemented
                            customFunction.ReopenApprovalEntries(Rec);
                        end;
                    end;
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
        ViewCancel: Boolean;
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
        StatusPending: Boolean;
        customFunction: Codeunit "Custom Functions Requisition";

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        StatusPending := false;
        ViewCancel := false;
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

        if Rec.Status = Rec.Status::"Pending Approval" then begin
            UserSetup.Reset();
            UserSetup.SetRange(UserSetup."User ID", UserId);
            if UserSetup.FindFirst() then begin
                if (UserSetup."Voucher Admin" = true) or (UserId = Rec."Prepared by") then begin
                    StatusPending := true;
                    ViewCancel := true;
                end;
            end;
        end;

    end;
}