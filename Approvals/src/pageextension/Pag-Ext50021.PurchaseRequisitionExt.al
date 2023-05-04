/// <summary>
/// PageExtension Purchase Requisition Ext (ID 50032) extends Record Purchase Requisition.
/// </summary>
pageextension 50021 "Purchase Requisition Ext" extends "Purchase Requisition Card"
{
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Home,Delegate';
    layout
    {
        // Add changes to page layout here
        addafter("Converted to Order")
        {
            field("Approvals Entry"; "Approvals Entry")
            {
                ApplicationArea = All;
            }
            field(Freelance; Freelance)
            {
                ApplicationArea = All;
            }
            field("Current Approver"; "Current Approver")
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
                        if Status = Status::Released then
                            Error('This document is already released');
                        if Status = Status::Open then
                            Error('Document Status must be set to Pending Approval');


                        if "Requisition Lines Total" <= 0 then begin
                            Error(Txt002);
                        end;

                        if Confirm(Txt001, true) then begin
                            ClaimCount := 0;
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange(ApprovalEntry."Document No.", "No.");
                            ApprovalEntry.SetRange(ApprovalEntry."Approval Type", ApprovalEntry."Approval Type"::Approver);
                            ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
                            if ApprovalEntry.FindFirst() then begin
                                ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                                if Rec."Approvals Entry" = 0 then
                                    SendRequisitionApprovedEmail();
                            end
                            else begin
                                UserSetup.Reset();
                                UserSetup.SetRange(UserSetup."User ID", UserId);
                                UserSetup.SetRange(UserSetup."SBU Head", true);
                                if UserSetup.FindFirst() then begin
                                    // ApprovalDoc.CheckBudgetPurchase(Rec);
                                end;
                                ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                                ReleaseTheApprovedDoc();
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
                        ApprovalComments: Record "NFL Approval Comment Line";
                    begin
                        if Confirm('Are you sure you want to Reject this Requisition ?', true) then begin
                            //Checking for comments before rejecting
                            ApprovalComments.Reset();
                            ApprovalComments.SetRange(ApprovalComments."Document No.", Rec."No.");
                            ApprovalComments.SetRange(ApprovalComments."Document Type", Rec."Document Type");
                            ApprovalComments.SetRange(ApprovalComments."User ID", UserId);
                            if ApprovalComments.FindFirst() then begin
                                ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                                //Send email implemented
                                customFunction.RejectApprovalRequest(Rec);
                            end else begin
                                Error('You can not reject a document with out a comment.');
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
                                    if (userSetup."Voucher Admin" = true) or (UserId = ApprovalEntries."Approver ID") or (UserId = Rec."Prepared by") then begin
                                        customFunction.DelegatePurchaseApprovalRequest(Rec);
                                        //Send Email implemented
                                        SendingDelegateEmail(Rec);
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
                        CalcFields("Requisition Lines Total");
                        RequisitionLineTotal := "Requisition Lines Total";
                        if RequisitionLineTotal <= 0 then
                            Error('Requisition Lines are Empty, You cannot Escalate this Document');

                        if Confirm(Txt002, true) then begin

                            //Send Email implemented
                            customFunction.EscalateApprovalRequest(Rec);
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
                        CalcFields("Requisition Details Total");
                        CalcFields("Requisition Lines Total");
                        gvHeaderTotal := "Requisition Details Total";
                        RequisitionDetailTotal := "Requisition Details Total";
                        IF ("Currency Code" <> '') AND (gvHeaderTotal <= 0) THEN
                            ERROR(Text0022)

                        ELSE
                            IF ("Currency Code" = '') AND (gvHeaderTotal <= 100) THEN
                                ERROR(Text0022);

                        TESTFIELD("Request-By No.");
                        TESTFIELD("Posting Date");
                        TESTFIELD("Shortcut Dimension 1 Code");
                        TESTFIELD("Order Date");
                        TESTFIELD("Document Date");
                        TESTFIELD("Budget Code");
                        TestField(Status, Status::Open);

                        IF "Prepared by" <> USERID THEN
                            ERROR('The selected request can only be sent for approval by the initiator %1', "Prepared by");

                        IF "Posting Description" = '' THEN
                            ERROR('Please specify the subject of Procurement');

                        if Confirm('Are you sure you want to send this Approval Request ?', true) then begin
                            if ApprovalsMgmtCut.CheckClaimApprovalsWorkflowEnable(Rec) then begin
                                ApprovalsMgmtCut.OnSendClaimForApproval(Rec);
                                //Send email implemented
                                SendRequestApprovalEmail(Rec);
                                customCodeunit.modifyApprovalEntry(Rec);
                            end;
                        end;
                    end;
                }
                action("Update now")
                {
                    ApplicationArea = All;
                    Caption = 'Update Now';
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    Visible = false;
                    Image = Image;
                    trigger OnAction()
                    var
                        Codes: Codeunit "Custom Functions Requisition";
                    begin
                        Codes.UpdateApprovalEntryInfo();
                    end;
                }
                action("Cancel Approval Re&quest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    // Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
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
                        TestField(Status, Status::"Pending Approval");
                        if "Converted to Order" = TRUE then
                            ERROR('The purchase requisition has already been converted to an order');
                        IF "Prepared by" <> USERID THEN BEGIN
                            CUstp.SETRANGE(CUstp."User ID", USERID);
                            IF CUstp.FIND('-') THEN BEGIN
                                IF CUstp."Voucher Admin" = FALSE THEN
                                    ERROR('The voucher can only be cancelled by the initiator %1', "Prepared by");
                            END;
                        END;
                        if Confirm('Are you sure you want to cancel this request ?', true) then begin
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
                            ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
                            if ApprovalEntry.FindFirst() then begin
                                customFunction.CancelPurchaseApprovalRequest(Rec);
                                //send Email implemented
                                SendingCancelApprovalEmail(Rec);
                            end else begin
                                //ApprovalsMgmtCut.OnCancelClaimForApproval(Rec);
                                customFunction.CancelPurchaseApprovalRequest(Rec);
                                //send Email implemented
                                SendingCancelApprovalEmail(Rec);
                            end;
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
                action("Approval Comments")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    Caption = 'Approval Comments';
                    Image = Comment;
                    RunObject = page "NFL Approval Comments";
                    RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50069);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForcurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
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
        if Status = Status::Open then begin
            sendApprovalRequest := true;
        end else begin
            sendApprovalRequest := false;
        end;

        if Status = Status::Released then begin
            CancelApprovalVisible := false;
        end else begin
            CancelApprovalVisible := true;
        end;

        if Status = Status::"Pending Approval" then begin
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