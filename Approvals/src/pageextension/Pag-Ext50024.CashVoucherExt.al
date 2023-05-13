/// <summary>
/// </summary>
pageextension 50024 "Cash Voucher Ext" extends "Cash Voucher"
{
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Delegate';
    layout
    {
        modify("Hub Code")
        {
            Visible = false;
        }
        modify("Has Links")
        {
            Visible = false;
        }
        // Add changes to page layout here
        addafter("Transferred to Journals")
        {
            field("Approvals Entry"; Rec."Approvals Entry")
            {
                ApplicationArea = All;
            }
            field(Freelance; Rec.Freelance)
            {
                ApplicationArea = All;
            }
            field("Current Approver"; Rec."Current Approver")
            {
                ApplicationArea = All;
            }
        }

        addafter("Has Links")
        {

            field("Budget At Date Exceeded"; Rec."Budget At Date Exceeded")
            {
                ToolTip = 'Specifies the value of the Budget At Date Exceeded field';
                ApplicationArea = All;
                Visible = false;
            }
            field("Month Budget Exceeded"; Rec."Month Budget Exceeded")
            {
                ToolTip = 'Specifies the value of the Month Budget Exceeded field';
                ApplicationArea = All;
                Visible = false;
            }
            field("Quarter Budget Exceeded"; Rec."Quarter Budget Exceeded")
            {
                ToolTip = 'Specifies the value of the Quarter Budget Exceeded field';
                ApplicationArea = All;
                Visible = false;
            }
            field("Year Budget Exceeded"; Rec."Year Budget Exceeded")
            {
                ToolTip = 'Specifies the value of the Year Budget Exceeded field';
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        modify("Request Approval")
        {
            Caption = 'Manage Vouchers';
        }

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
                        Txt002: Label 'Payment Lines must have atleast one line with Amount.';
                        PaymentLineTotal: Decimal;
                        UserSetup: Record "User Setup";
                        UserSetup2: Record "User Setup";
                        ApprovalDoc: Codeunit "Custom Functions Cash";
                    begin
                        //check amounts
                        UserSetup2.Reset();
                        UserSetup2.SetRange(UserSetup2."User ID", UserId);
                        UserSetup2.SetRange(UserSetup2."Budget Controller", true);
                        if UserSetup2.FindFirst() then begin
                            Rec.CheckAmountCoded()
                        end;

                        Rec.CheckPaymentVoucherLinesTotal();
                        Rec.CheckForLinesApproval();
                        Rec.CheckDoubleEntry();
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
                                    ApprovalDoc.CheckBudget(Rec);
                                end;

                                ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                                Rec.ReleaseTheApprovedDoc();
                            end;
                            //Send email implemented
                            CustomFunctions.OpenApprovalEntries(Rec);
                            CustomFunctions.DoubleCheckApprovalEntries(Rec);
                            CustomFunctions.CompleteDocumentApproval(Rec);
                            Rec.CheckForBudgetControllerApproval(Rec);
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
                    // ApprovalComments: Record "NFL Approval Comment Line";
                    // approvalComment: Page "NFL Approval Comments";
                    // ApprovalComments2: Record "NFL Approval Comment Line";
                    begin

                        if Confirm('Are you sure you want to Reject this Voucher ?', true) then begin
                            //Checking for comments before rejecting
                            // ApprovalComments.Reset();TODO:
                            // ApprovalComments.SetRange(ApprovalComments."Document No.", Rec."No.");
                            // ApprovalComments.SetRange(ApprovalComments."Document Type", Rec."Document Type");
                            // ApprovalComments.SetRange(ApprovalComments."User ID", UserId);
                            // if ApprovalComments.FindFirst() then begin
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            CustomFunctions.RejectApprovalRequest(Rec);
                            Rec.ReversePaymentVoucherCommitmentEntries();
                            // end else begin
                            //     // ApprovalComments2.Reset();
                            //     // ApprovalComments2.SetRange(ApprovalComments2."Document No.", Rec."No.");
                            //     // ApprovalComments2.SetRange(ApprovalComments2."Document Type", Rec."Document Type");
                            //     // ApprovalComments2.SetRange(ApprovalComments2."Table ID", Database::"Payment Voucher Header");
                            //     // approvalComment.SetTableView(ApprovalComments2);
                            //     // approvalComment.Run();

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
                                        CustomFunctions.DelegatePaymentVoucherApprovalRequest(Rec);
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
                        PaymentLineTotal: Decimal;
                        UserSetup: Record "User Setup";
                    // ApprovalDoc: Codeunit "NFL Approvals Management";
                    begin
                        Rec.CalcFields("Payment Voucher Lines Total");
                        PaymentLineTotal := Rec."Payment Voucher Lines Total";
                        if PaymentLineTotal <= 0 then begin
                            Error('Voucher Lines are Empty, You can not Escalate this document');
                        end;

                        if Confirm(Txt002, true) then begin
                            //Send Email implemented
                            CustomFunctions.EscalateApprovalRequest(Rec);
                        end;
                    end;
                }
            }

        }

        addafter(Approve1)
        {
            group("Request Approval1")
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
                        PaymentDetailTotal: Decimal;
                        CustomCodeunit: Codeunit "Custom Functions Cash";
                        PaymentLineTotal: Decimal;
                        Text0001: Label 'Payment Details must have atleast one line with amount';
                    begin

                        Rec.TESTFIELD("Posting Date");
                        Rec.TESTFIELD("Shortcut Dimension 1 Code");
                        Rec.TESTFIELD("Budget Code");
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField("Payment Type");
                        IF (Rec.Status = Rec.Status::Released) THEN
                            ERROR('The payment voucher is released , an approval request cannot be sent');
                        IF (Rec.Status = Rec.Status::"Pending Approval") THEN
                            ERROR('The payment voucher is pending approval , an approval request cannot be sent');
                        Rec.CalcFields("Payment Voucher Details Total");

                        PaymentDetailTotal := Rec."Payment Voucher Details Total";


                        if PaymentDetailTotal <= 0 then
                            Error(Text0001);

                        IF Rec."Prepared by" <> USERID THEN
                            ERROR('The selected request can only be sent for approval by the initiator %1', Rec."Prepared by");

                        if Confirm('Do you really want to send the request for approval?', true) then begin
                            if ApprovalsMgmtCut.CheckClaimApprovalsWorkflowEnable(Rec) then begin
                                ApprovalsMgmtCut.OnSendClaimForApproval(Rec);
                                //Send email implemented
                                Rec.SendRequestApprovalEmail(Rec);
                                CustomCodeunit.modifyApprovalEntry(Rec);
                            end;
                        end;
                    end;
                }
                action("Update Now")
                {
                    ApplicationArea = All;
                    Caption = 'Update Now';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    Image = UpdateShipment;
                    trigger OnAction()
                    var
                        CustomCodeunit: Codeunit "Custom Functions Cash";
                    begin
                        CustomCodeunit.UpdateApprovalEntryInfo();
                    end;
                }
                action("Cancel Approval Re&quest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    //Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ToolTip = 'Cancel the approval request.';
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                        CUstp: Record "User Setup";
                        ApprovalEntry: Record "Approval Entry";
                        CustCodeUnit: Codeunit "Custom Functions Cash";
                    begin
                        Rec.TestField(Rec.Status, Rec.Status::"Pending Approval");
                        if Rec."Transferred to Journals" = TRUE then
                            ERROR('The Payment Voucher has already been transfered to the Journals');


                        IF Rec."Prepared by" <> USERID THEN BEGIN
                            CUstp.SETRANGE(CUstp."User ID", USERID);
                            IF CUstp.FIND('-') THEN BEGIN
                                IF CUstp."Voucher Admin" = FALSE THEN
                                    ERROR('The voucher can only be cancelled by the initiator %1', Rec."Prepared by");
                            END;
                        END;
                        if Confirm('Are you sure you want to cancel this request ?') then begin
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
                            ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
                            if ApprovalEntry.FindFirst() then begin
                                CustCodeUnit.CancelPaymentVoucherApprovalRequest(Rec);
                                //send Email implemented
                                Rec.SendingCancelApprovalEmail(Rec);
                            end else begin
                                // ApprovalsMgmtCut.OnCancelClaimForApproval(Rec);
                                CustCodeUnit.CancelPaymentVoucherApprovalRequest(Rec);
                                //send Email implemented
                                Rec.SendingCancelApprovalEmail(Rec);
                            end;
                            Rec.ReversePaymentVoucherCommitmentEntries();
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
                    ToolTip = 'Reopens the Payment Voucher Document';
                    Image = ReOpen;
                    trigger OnAction()
                    var
                        PaymentVoucher: Record "Payment Voucher Header";
                        userSetup: Record "User Setup";
                    begin
                        if Confirm('Are You Want to Open This Document ?', true) then begin
                            //send email implemented
                            PaymentVoucher.PerformManualReopen(Rec);
                            CustomFunctions.ReopenApprovalEntries(Rec);
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
                    // RunObject = page "NFL Approval Comments";TODO:
                    // RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50075);
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
        ApprovalsMgmtCut: Codeunit "Custom Functions Cash";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        OpenApprovalEntriesExistForcurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        gvHeaderTotal: Decimal;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApprovalForFlow: Boolean;
        sendApprovalRequest: Boolean;
        Text0022: Label 'There must be atleast one line with amount in the Payment Voucher  Details Subform';
        CancelApprovalVisible: Boolean;
        StatusPending: Boolean;
        CustomFunctions: Codeunit "Custom Functions Cash";


    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        StatusPending := false;
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
                if (UserSetup."Voucher Admin" = true) or (UserId = Rec."Prepared by") then
                    StatusPending := true;
            end;
        end;
    end;
}