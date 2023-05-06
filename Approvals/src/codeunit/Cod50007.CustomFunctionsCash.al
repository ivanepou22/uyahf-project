/// <summary>
/// Codeunit Custom Functions LoanAdvance (ID 50052).
/// </summary>
codeunit 50007 "Custom Functions Cash"
{
    Permissions = tabledata "Approval Entry" = rmid;
    trigger OnRun()
    begin

    end;

    /// <summary>
    /// modifyApprovalEntry.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Record "Payment Voucher Header".</param>
    procedure modifyApprovalEntry(PaymentVoucherHeader: Record "Payment Voucher Header")
    var
        NflRequisitionLine: Record "NFL Requisition Line";
        AmountLcy: Decimal;
        ApprovalEntry: Record "Approval Entry";
    begin
        AmountLcy := 0;
        PaymentVoucherHeader.CalcFields("Payment Voucher Details Total");
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", PaymentVoucherHeader."No.");
        ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created, ApprovalEntry.Status::Approved);
        if ApprovalEntry.FindFirst() then
            repeat
                ApprovalEntry."Document Type1" := PaymentVoucherHeader."Document Type";
                ApprovalEntry."Prepared By" := PaymentVoucherHeader."Prepared by";
                ApprovalEntry."Currency Code" := PaymentVoucherHeader."Currency Code";
                ApprovalEntry.Amount := PaymentVoucherHeader."Payment Voucher Details Total";
                ApprovalEntry."Payee No." := PaymentVoucherHeader."Payee No.";
                ApprovalEntry."Payee Name" := PaymentVoucherHeader.Payee;
                ApprovalEntry.Description := PaymentVoucherHeader.payee + ' ' + Format(PaymentVoucherHeader."Payment Type");
                ApprovalEntry."Posting Date" := PaymentVoucherHeader."Posting Date";
                ApprovalEntry.Modify();
            until ApprovalEntry.Next() = 0;
    end;

    /// <summary>
    /// UpdateApprovalEntryInfo.
    /// </summary>
    procedure UpdateApprovalEntryInfo()
    var
        PaymntVoucherHeader: Record "Payment Voucher Header";
        ApprovalEntry: Record "Approval Entry";
    begin

        PaymntVoucherHeader.Reset();
        PaymntVoucherHeader.SetFilter(PaymntVoucherHeader."Document Type", '<>%1', PaymntVoucherHeader."Document Type"::"Purchase Requisition");
        PaymntVoucherHeader.SetRange(PaymntVoucherHeader.Status, PaymntVoucherHeader.Status::"Pending Approval");
        if PaymntVoucherHeader.FindFirst() then
            repeat
                PaymntVoucherHeader.CalcFields("Payment Voucher Details Total");
                ApprovalEntry.SetRange(ApprovalEntry."Document No.", PaymntVoucherHeader."No.");
                ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created, ApprovalEntry.Status::Approved);
                if ApprovalEntry.FindFirst() then
                    repeat
                        ApprovalEntry."Document Type1" := PaymntVoucherHeader."Document Type";
                        ApprovalEntry."Prepared By" := PaymntVoucherHeader."Prepared by";
                        ApprovalEntry."Currency Code" := PaymntVoucherHeader."Currency Code";
                        ApprovalEntry.Amount := PaymntVoucherHeader."Payment Voucher Details Total";
                        ApprovalEntry."Payee No." := PaymntVoucherHeader."Payee No.";
                        ApprovalEntry."Payee Name" := PaymntVoucherHeader.Payee;
                        ApprovalEntry.Description := PaymntVoucherHeader.payee + ' ' + Format(PaymntVoucherHeader."Payment Type");
                        ApprovalEntry."Posting Date" := PaymntVoucherHeader."Posting Date";
                        ApprovalEntry.Modify();
                    until ApprovalEntry.Next() = 0;
            until PaymntVoucherHeader.Next() = 0;
        Message('Done Now');
    end;


    /// <summary>
    /// CancelPurchaseApprovalRequest.
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>

    procedure CancelPaymentVoucherApprovalRequest(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        PaymentVoucherHeader: Record "Payment Voucher Header";
    begin
        PaymentVoucherHeader.Reset();
        PaymentVoucherHeader.SetRange(PaymentVoucherHeader."No.", VoucherHeader."No.");
        PaymentVoucherHeader.SetRange(PaymentVoucherHeader.Status, PaymentVoucherHeader.Status::"Pending Approval");
        if PaymentVoucherHeader.FindFirst() then begin
            ApprovalEntry.Reset();
            ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No.");
            ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Approved, ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
            if ApprovalEntry.FindFirst() then begin
                repeat
                    ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                    ApprovalEntry."Last Modified By User ID" := UserId;
                    ApprovalEntry.Modify();
                until ApprovalEntry.Next() = 0;
            end;
            PaymentVoucherHeader.Status := PaymentVoucherHeader.Status::Open;
            PaymentVoucherHeader.Modify();
        end;
        Message('The Request has been Cancelled');
    end;

    /// <summary>
    /// ReopenApprovalEntries.
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>
    procedure ReopenApprovalEntries(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";TODO:
        UserSetUp: Record "User Setup";
        VoucherAdmin: Boolean;
    begin
        if not (VoucherHeader.Status = VoucherHeader.Status::Open) then
            exit;

        VoucherAdmin := false;
        UserSetUp.Reset();
        UserSetUp.SetRange(UserSetUp."User ID", UserId);
        UserSetUp.SetRange(UserSetUp."Voucher Admin", true);
        if UserSetUp.FindFirst() then begin
            VoucherAdmin := true;
        end;
        if (VoucherAdmin = true) then begin
            if (VoucherHeader.Status = VoucherHeader.Status::Open) then begin
                ApprovalEntry.Reset();
                ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No.");
                ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
                if ApprovalEntry.FindFirst() then
                    repeat
                        ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry.Modify();
                    // NFLApprovalMgt.SendPaymentVoucherCancellationMail(VoucherHeader, ApprovalEntry);TODO:
                    until ApprovalEntry.Next() = 0;
            end;
        end;

    end;

    // Reject The approval request.
    /// <summary>
    /// RejectApprovalRequest.
    /// </summary>
    /// <param name="Rec">Record "Payment Voucher Header".</param>
    procedure RejectApprovalRequest(Rec: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        NvText: Label 'The approval Request has been rejected';
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";TODO:
    begin

        ApprovalEntries.Reset();
        ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No.");
        ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
        ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Rejected);
        if ApprovalEntries.FindFirst() then begin
            ApprovalEntries1.Reset();
            ApprovalEntries1.SetRange(ApprovalEntries1."Document No.", ApprovalEntries."Document No.");
            ApprovalEntries1.SetRange(ApprovalEntries1."Approval Code", ApprovalEntries."Approval Code");
            ApprovalEntries1.SetFilter(ApprovalEntries1."Approver ID", '<>%1', ApprovalEntries."Approver ID");
            ApprovalEntries1.SetFilter(ApprovalEntries1.Status, '<>%1', ApprovalEntries1.Status::Canceled);
            if ApprovalEntries1.FindFirst() then begin
                repeat
                    ApprovalEntries1.Status := ApprovalEntries1.Status::Rejected;
                    ApprovalEntries1.Modify();
                // NFLApprovalMgt.SendPaymentVoucherRejectionMail(Rec, ApprovalEntries1);TODO:
                until ApprovalEntries1.Next() = 0;
            end;
            OpenDocument(Rec);
            Message(NvText);
        end;
    end;


    // open the rejected Document
    /// <summary>
    /// OpenDocument.
    /// </summary>
    /// <param name="PVHeader">Record "Payment Voucher Header".</param>
    procedure OpenDocument(PVHeader: Record "Payment Voucher Header")
    var
        PaymentVoucherHeader: Record "Payment Voucher Header";
    begin
        PaymentVoucherHeader.Reset();
        PaymentVoucherHeader.SetRange(PaymentVoucherHeader."No.", PVHeader."No.");
        PaymentVoucherHeader.SetRange(PaymentVoucherHeader.Status, PaymentVoucherHeader.Status::"Pending Approval");
        if PaymentVoucherHeader.FindFirst() then begin
            PaymentVoucherHeader.Status := PaymentVoucherHeader.Status::Open;
            PaymentVoucherHeader.Modify();
        end;
    end;

    /// <summary>
    /// DelegatePaymentVoucherApprovalRequest.
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>
    procedure DelegatePaymentVoucherApprovalRequest(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        // DelegateEscalate: Record "Delegate Escalate Management";TODO:
        text001: Label 'Are you sure you want to delegate to';
        MessageSent: Text[100];
    begin
        // ApprovalEntry.Reset();
        // ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No."); TODO:
        // ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        // if ApprovalEntry.FindFirst() then begin
        //     DelegateEscalate.Reset();
        //     DelegateEscalate.SetRange(DelegateEscalate."User ID", ApprovalEntry."Approver ID");
        //     DelegateEscalate.SetRange(DelegateEscalate."Document Type", VoucherHeader."Document Type");
        //     DelegateEscalate.SetRange(DelegateEscalate."Shortcut Dimension 1 Code", VoucherHeader."Shortcut Dimension 1 Code");
        //     if DelegateEscalate.FindFirst() then begin
        //         if DelegateEscalate."Delegate ID" <> '' then begin
        //             MessageSent := text001 + ' ' + DelegateEscalate."Delegate ID";
        //             if Confirm(MessageSent, true) then begin
        //                 ApprovalEntry."Approver ID" := DelegateEscalate."Delegate ID";
        //                 ApprovalEntry."Last Modified By User ID" := UserId;
        //                 ApprovalEntry.Modify();
        //                 Message('Voucher has been Delegated to %1 Successfully', DelegateEscalate."Delegate ID");
        //             end;
        //         end else begin
        //             Error('Delegate ID can not be empty. Contact your Systems Administrator');
        //         end;
        //     end else begin
        //         Error('You are not setup please consult your System Administrator');
        //     end;
        // end else begin
        //     Error('You are not allowed to Delegate please contact your system Administrator');
        // end;
    end;


    /// <summary>
    /// EscalateApprovalRequest1.
    /// </summary>
    /// <param name="Rec">Record "Payment Voucher Header".</param>
    procedure EscalateApprovalRequest(Rec: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        NvText: Label 'The approval Request has been Escalated';
        NvText1: Label 'This Operation Can not be performed contact your systems Administrator';
        NvText2: Label 'You do not have a person to escalate to. Contact your Systems Administrator';
        NvText3: Label 'Your not allowed to Escale because your not set as an SDU Head';
        userSetup: Record "User Setup";
        // DelegateEscalate: Record "Delegate Escalate Management";TODO:
        VoucherLine: Record "Payment Voucher Line";
    begin
        // ApprovalEntries.Reset();
        // ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No."); TODO:
        // ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
        // ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Open);
        // if ApprovalEntries.FindFirst() then begin
        //     //Check if the user is an SDU Head
        //     userSetup.Reset();
        //     userSetup.SetRange(userSetup."User ID", ApprovalEntries."Approver ID");
        //     userSetup.SetRange(userSetup."SBU Head", true);
        //     if userSetup.FindFirst() then begin
        //         //Getting the Escalate to IDf
        //         DelegateEscalate.Reset();
        //         DelegateEscalate.SetRange(DelegateEscalate."Document Type", Rec."Document Type");
        //         DelegateEscalate.SetRange(DelegateEscalate."User ID", userSetup."User ID");
        //         DelegateEscalate.SetRange(DelegateEscalate."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
        //         if DelegateEscalate.FindFirst() then begin
        //             if DelegateEscalate."Escalate ID" <> '' then begin
        //                 Rec.TESTFIELD("Budget Code");
        //                 Rec.TESTFIELD("Shortcut Dimension 1 Code");
        //                 VoucherLine.RESET;
        //                 IF Rec.Status = Rec.Status::"Pending Approval" THEN BEGIN
        //                     // Budget holder should enter the codes before approving the document.
        //                     VoucherLine.SETRANGE("Document Type", Rec."Document Type");
        //                     VoucherLine.SETRANGE("Document No.", Rec."No.");
        //                     IF VoucherLine.FIND('-') THEN
        //                         REPEAT
        //                             IF VoucherLine."Account Type" = VoucherLine."Account Type"::"G/L Account" THEN BEGIN
        //                                 //IF VoucherLine."Budget Comment" = 'Out of Budget' THEN BEGIN
        //                                 escalateDoc(ApprovalEntries."Approval Code", Rec."No.", UserId, DelegateEscalate."Escalate ID", Rec);
        //                                 //END;
        //                             END else begin
        //                                 escalateDoc(ApprovalEntries."Approval Code", Rec."No.", UserId, DelegateEscalate."Escalate ID", Rec);
        //                             end;
        //                         UNTIL VoucherLine.NEXT = 0;
        //                 END;
        //             end else begin
        //                 Error(NvText2);
        //             end;
        //         end else begin
        //             Error('You can not Escalate because you are not setup');
        //         end;
        //     end else begin
        //         Error(NvText3);
        //     end;
        // end else begin
        //     Error(NvText1);
        // end;
    end;

    /// <summary>
    /// escalateDoc.
    /// </summary>
    /// <param name="ApproveCode">VAR Code[50].</param>
    /// <param name="DocNo">Code[50].</param>
    /// <param name="userIDEsc">Code[50].</param>
    /// <param name="EscalateTo">Code[50].</param>
    /// <param name="PVHeader">Record "Payment Voucher Header".</param>
    procedure escalateDoc(var ApproveCode: Code[50]; DocNo: Code[50]; userIDEsc: Code[50]; EscalateTo: Code[50]; PVHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        // NFLApprovemgt: Codeunit "NFL Approvals Mgt Notification";TODO:
        TXT0002: Label 'Are you sure you want to Escalate to';
        MessageToSent: Text[100];
    begin

        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", DocNo);
        ApprovalEntry.SetRange(ApprovalEntry."Approval Code", ApproveCode);
        ApprovalEntry.SetRange(ApprovalEntry."Approver ID", userIDEsc);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            MessageToSent := TXT0002 + ' ' + EscalateTo;
            if Confirm(MessageToSent, true) then begin
                ApprovalEntry."Approver ID" := EscalateTo;
                ApprovalEntry."Escalated By" := userIDEsc;
                ApprovalEntry."Escalated On" := Today();
                ApprovalEntry.Modify();
                Message('Document Escalated to: %1', EscalateTo);
                // NFLApprovemgt.SendPaymentVoucherEscalationMail(PVHeader, ApprovalEntry);TODO:
            end;
        end;
    end;

    //Approval managed
    /// <summary>
    /// OpenApprovalEntries.
    /// </summary>
    /// <param name="Rec">Record "Payment Voucher Header".</param>
    procedure OpenApprovalEntries(Rec: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        SequenceNo: Integer;
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";TODO:
    begin
        SequenceNo := 0;
        ApprovalEntries.Reset();
        ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No.");
        ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
        ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
        if ApprovalEntries.FindFirst() then begin
            SequenceNo := ApprovalEntries."Sequence No." + 1;
            ApprovalEntries1.Reset();
            ApprovalEntries1.SetRange(ApprovalEntries1."Document No.", Rec."No.");
            ApprovalEntries1.SetRange(ApprovalEntries1."Approval Code", ApprovalEntries."Approval Code");
            ApprovalEntries1.SetRange(ApprovalEntries1."Sequence No.", SequenceNo);
            ApprovalEntries1.SetRange(ApprovalEntries1.Status, ApprovalEntries1.Status::Created);
            if ApprovalEntries1.FindFirst() then begin
                ApprovalEntries1.Status := ApprovalEntries1.Status::Open;
                ApprovalEntries1.Modify();
                // NFLApprovalMgt.SendPaymentVoucherApprovalMail(Rec, ApprovalEntries1);TODO:
            end;
        end;
    end;

    /// <summary>
    /// DoubleCheckApprovalEntries.
    /// </summary>
    /// <param name="Rec">Record "Payment Voucher Header".</param>
    procedure DoubleCheckApprovalEntries(Rec: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        SequenceNo: Integer;
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
    begin
        SequenceNo := 0;
        ApprovalEntries.Reset();
        ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No.");
        ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
        ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
        if ApprovalEntries.FindFirst() then begin
            SequenceNo := ApprovalEntries."Sequence No." + 1;
            ApprovalEntries1.Reset();
            ApprovalEntries1.SetRange(ApprovalEntries1."Document No.", Rec."No.");
            ApprovalEntries1.SetRange(ApprovalEntries1."Approval Code", ApprovalEntries."Approval Code");
            ApprovalEntries1.SetRange(ApprovalEntries1."Sequence No.", SequenceNo);
            ApprovalEntries1.SetRange(ApprovalEntries1.Status, ApprovalEntries1.Status::Created);
            if ApprovalEntries1.FindFirst() then begin
                ApprovalEntries1.Status := ApprovalEntries1.Status::Open;
                ApprovalEntries1.Modify();
            end;
        end;
    end;

    /// <summary>
    /// CompleteDocumentApproval.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Record "Payment Voucher Header".</param>
    procedure CompleteDocumentApproval(PaymentVoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalNotComplete: Boolean;
    begin
        if PaymentVoucherHeader.Status = PaymentVoucherHeader.Status::"Pending Approval" then begin
            ApprovalEntries.Reset();
            ApprovalEntries.SetRange("Document No.", PaymentVoucherHeader."No.");
            ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
            if ApprovalEntries.Find('-') then begin
                if ((ApprovalEntries.Status = ApprovalEntries.Status::Created) or (ApprovalEntries.Status = ApprovalEntries.Status::Open)) then begin
                    ApprovalNotComplete := true;
                end;
            end;

            if ApprovalNotComplete = false then begin
                PaymentVoucherHeader.Validate(Status, PaymentVoucherHeader.Status::Released);
                // PaymentVoucherHeader.Modify();
            end;
        end;
    end;


    //================================================================
    //===================WorkflowResponseHandling===============
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        Claim: Record "Payment Voucher Header";
    begin
        case RecRef.Number of
            Database::"Payment Voucher Header":
                begin
                    RecRef.SetTable(Claim);
                    Claim.Status := Claim.Status::Open;
                    Claim.Modify();
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        Claim: Record "Payment Voucher Header";
    begin
        case RecRef.Number of
            Database::"Payment Voucher Header":
                begin
                    RecRef.SetTable(Claim);
                    Claim.Status := Claim.Status::Released;
                    Claim.Modify();
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        claim: Record "Payment Voucher Header";
    begin
        case RecRef.Number of
            Database::"Payment Voucher Header":
                begin
                    RecRef.SetTable(claim);
                    claim.Status := claim.Status::"Pending approval";
                    claim.Modify();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit 1521;
        WorkflowEventHandlingCust: Codeunit "PCV Workflow EventHandling Ext";
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode,
                    WorkflowEventHandlingCust.RunWorkflowOnSendClaimForApprovalCode);
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode,
                    WorkflowEventHandlingCust.RunWorkflowOnSendClaimForApprovalCode);
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode,
                    WorkflowEventHandlingCust.RunWorkflowOnCancelClaimApprovalCode);
            WorkflowResponseHandling.OpenDocumentCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode,
                    WorkflowEventHandlingCust.RunWorkflowOnCancelClaimApprovalCode);
        end;
    end;

    //==============================Approval Mgmt==================

    /// <summary>
    /// CheckClaimApprovalsWorkflowEnable.
    /// </summary>
    /// <param name="Claim">VAR Record "Payment Voucher Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure CheckClaimApprovalsWorkflowEnable(var Claim: Record "Payment Voucher Header"): Boolean
    begin
        if not IsClaimDocApprovalsWorkflowEnable(Claim) then
            Error(NoWorkflowEnabledErr);
        exit(true);
    end;

    /// <summary>
    /// IsClaimDocApprovalsWorkflowEnable.
    /// </summary>
    /// <param name="Claim">VAR Record "Payment Voucher Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure IsClaimDocApprovalsWorkflowEnable(var Claim: Record "Payment Voucher Header"): Boolean
    begin
        if Claim.Status <> Claim.Status::Open then
            exit(false);
        exit(WorkflowManagement.CanExecuteWorkflow(Claim, WorkflowEventHandlingCust.RunWorkflowOnSendClaimForApprovalCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        Claim: Record "Payment Voucher Header";
    begin
        case RecRef.Number of
            Database::"Payment Voucher Header":
                begin
                    RecRef.SetTable(Claim);
                    ApprovalEntryArgument."Document No." := Claim."No.";
                    ApprovalEntryArgument."Document Type1" := claim."Document Type";
                end;
        end;
    end;

    /// <summary>
    /// OnSendClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "Payment Voucher Header".</param>
    [IntegrationEvent(false, false)]
    procedure OnSendClaimForApproval(var Claim: Record "Payment Voucher Header")
    begin

    end;

    /// <summary>
    /// OnCancelClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "Payment Voucher Header".</param>
    [IntegrationEvent(false, false)]
    procedure OnCancelClaimForApproval(var Claim: Record "Payment Voucher Header")
    begin

    end;

    /// <summary>
    /// ReOpenLoanAdvance.
    /// </summary>
    /// <param name="Variant">VAR Variant.</param>
    procedure ReOpenLoanAdvance(var Variant: Variant)
    var
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        PaymentVoucher: Record "Payment Voucher Header";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number() of
            DATABASE::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    TargetRecRef.Get(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    ReOpenLoanAdvance(Variant);
                end;
            DATABASE::Job:
                begin
                    RecRef.SetTable(PaymentVoucher);
                    PaymentVoucher.Validate(PaymentVoucher.Status, PaymentVoucher.Status::Open);
                    PaymentVoucher.Modify();
                    Variant := PaymentVoucher;
                end;
        end;
    end;

    //=====================Page Management===============

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    begin
        if PageID = 0 then
            PageID := GetConditionalCardPageID(RecordRef);
    end;

    local procedure GetConditionalCardPageID(RecordRef: RecordRef): Integer
    begin
        case RecordRef.Number of
            DATABASE::"Payment Voucher Header":
                exit(Page::"Voucher Form");
        end;
    end;


    //==================Other functions==============
    /// <summary> 
    /// Description for CheckBudget.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Parameter of type Record "Payment Voucher Header".</param>
    procedure CheckBudget(var PaymentVoucherHeader: Record "Payment Voucher Header");
    var
        PaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 23RD JULY 2018, New vision requires that all requisition out of budget are escaladed to the CEO/CFO
        // for approval.
        PaymentVoucherHeader.TESTFIELD("Budget Code");
        PaymentVoucherHeader.TESTFIELD("Shortcut Dimension 1 Code");
        PaymentVoucherLine.RESET;
        IF PaymentVoucherHeader.Status = PaymentVoucherHeader.Status::"Pending Approval" THEN BEGIN
            // Budget holder should enter the codes before approving the document.
            PaymentVoucherLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
            PaymentVoucherLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
            IF PaymentVoucherLine.FIND('-') THEN
                REPEAT
                    IF PaymentVoucherLine."Account Type" = PaymentVoucherLine."Account Type"::"G/L Account" THEN BEGIN
                        IF PaymentVoucherLine."Budget Comment" = 'Out of Budget' THEN BEGIN
                            ERROR('Payment Voucher Line %1 is Out of Budget and must be escaladed to CFO/CEO!', PaymentVoucherLine."Line No.");
                        END;
                    END;
                UNTIL PaymentVoucherLine.NEXT = 0;
        END;
    end;

    /// <summary> 
    /// Description for CreatePaymentVoucherCommitment.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Parameter of type Record "51402242".</param>
    procedure CreatePaymentVoucherCommitment(var PaymentVoucherHeader: Record "Payment Voucher Header");
    var
        PaytVouchLine: Record "Payment Voucher Line";
        CommitmentEntry: Record "Commitment Entry";
        GLAccount: Record "G/L Account";
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        // MAG 24TH SEPT. 2018, Create Payment Voucher Commitment on releasing payment requisiton.
        IF PaymentVoucherHeader."Payment Type" = PaymentVoucherHeader."Payment Type"::"Cash Requisition" THEN BEGIN
            // Invoice already posted for supplier, No need to create a commitment for supplier payment
            // Money will be deducted from the staff's salary, no need to create a commitment for advances.
            PaytVouchLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
            PaytVouchLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
            PaytVouchLine.SETFILTER("Commitment Entry No.", '%1', 0);
            IF PaytVouchLine.FIND('-') THEN
                REPEAT
                    IF NOT CommitmentEntry.FINDLAST THEN
                        CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1
                    ELSE
                        CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1;
                    CommitmentEntry.INIT;
                    IF PaytVouchLine."Account Type" = PaytVouchLine."Account Type"::"G/L Account" THEN BEGIN
                        GLAccount.SETRANGE("No.", PaytVouchLine."Account No.");
                        GLAccount.SETRANGE("Prepayment Account", TRUE);
                        IF GLAccount.FIND('-') THEN BEGIN
                            CommitmentEntry."G/L Account No." := PaytVouchLine."Control Account"; // Commit on the Actual Expense that was budgeted for.
                            CommitmentEntry."Prepayment Commitment" := TRUE;
                        END ELSE
                            CommitmentEntry."G/L Account No." := PaytVouchLine."Account No.";
                    END;

                    CommitmentEntry.Description := PaytVouchLine.Description;
                    CommitmentEntry.VALIDATE("Document Type", PaymentVoucherHeader."Document Type");
                    CommitmentEntry."Document No." := PaytVouchLine."Document No.";
                    //CommitmentEntry."Posting Date" := "Posting Date";
                    CommitmentEntry."Posting Date" := PaymentVoucherHeader."Posting Date";
                    CommitmentEntry."Dimension Set ID" := PaytVouchLine."Dimension Set ID";
                    CommitmentEntry."Global Dimension 1 Code" := PaytVouchLine."Shortcut Dimension 1 Code";
                    CommitmentEntry."Global Dimension 2 Code" := PaytVouchLine."Shortcut Dimension 2 Code";
                    CommitmentEntry.Amount := PaytVouchLine."Amount (LCY)";
                    CommitmentEntry."Source Code" := 'Released';
                    CommitmentEntry."User ID" := USERID;

                    IF CommitmentEntry.Amount > 0 THEN
                        CommitmentEntry."Debit Amount" := PaytVouchLine."Amount (LCY)"
                    ELSE
                        CommitmentEntry."Credit Amount" := PaytVouchLine."Amount (LCY)";
                    GeneralLedgerSetup.GET;
                    CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PaymentVoucherHeader."Posting Date", GeneralLedgerSetup."Additional Reporting Currency");
                    CommitmentEntry."Additional-Currency Amount" := ROUND(CommitmentEntry.Amount * CurrencyFactor, Currency."Amount Rounding Precision");
                    IF CommitmentEntry."Additional-Currency Amount" > 0 THEN
                        CommitmentEntry."Add.-Currency Debit Amount" := CommitmentEntry."Additional-Currency Amount"
                    ELSE
                        CommitmentEntry."Add.-Currency Credit Amount" := CommitmentEntry."Additional-Currency Amount";
                    CommitmentEntry.INSERT;
                    PaytVouchLine."Commitment Entry No." := CommitmentEntry."Entry No.";
                    PaytVouchLine.MODIFY;
                UNTIL PaytVouchLine.NEXT = 0;
            PaymentVoucherHeader.Commited := TRUE;
            PaymentVoucherHeader.MODIFY;
        END;
        //MAG - END
    end;

    procedure SendPaymentVoucherDelegationMail(PaymentVoucherHeader: Record "Payment Voucher Header"; NFLApprovalEntry: Record "Approval Entry");
    begin
        // FillPaymentVoucherBody(NFLApprovalEntry, PaymentVoucherHeader, 3);
    end;

    procedure SendPaymentVoucherApprovalMail(PaymentVoucherHeader: Record "Payment Voucher Header"; NFLApprovalEntry: Record "Approval Entry");
    begin
        // FillPaymentVoucherBody(NFLApprovalEntry, PaymentVoucherHeader, 0);
    end;

    procedure SendPaymentVoucherCancellationMail(PaymentVoucherHeader: Record "Payment Voucher Header"; NFLApprovalEntry: Record "Approval Entry");
    begin
        // FillPaymentVoucherBody(NFLApprovalEntry, PaymentVoucherHeader, 1);
    end;

    procedure SendPaymentVoucherApprovedMail(PaymentVoucherHeader: Record "Payment Voucher Header"; NFLApprovalEntry: Record "Approval Entry");
    begin
        // FillPaymentVoucherBody(NFLApprovalEntry, PaymentVoucherHeader, 4);
    end;


    var
        WorkflowManagement: Codeunit 1501;
        WorkflowEventHandlingCust: Codeunit "PCV Workflow EventHandling Ext";
        NoWorkflowEnabledErr: TextConst ENU = 'No Approval Workflow for the type is enabled';

}