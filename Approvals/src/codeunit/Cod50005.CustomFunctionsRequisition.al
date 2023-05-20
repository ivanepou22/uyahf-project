/// <summary>
/// Codeunit Custom Functions LoanAdvance (ID 50116).
/// </summary>
codeunit 50005 "Custom Functions Requisition"
{
    Permissions = tabledata "Approval Entry" = rmid;
    trigger OnRun()
    begin

    end;

    var
        WorkflowManagement: Codeunit 1501;
        WorkflowEventHandlingCust: Codeunit "PRQ Workflow EventHandling Ext";
        NoWorkflowEnabledErr: TextConst ENU = 'No Approval Workflow for the type is enabled';


    // Page Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    begin
        if PageID = 0 then
            PageID := GetConditionalCardPageID(RecordRef);
    end;

    local procedure GetConditionalCardPageID(RecordRef: RecordRef): Integer
    begin
        case RecordRef.Number of
            DATABASE::"NFL Requisition Header":
                exit(Page::"Requisition Approval Form");
        end;
    end;
    // End page management

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        Claim: Record "NFL Requisition Header";
    begin
        case RecRef.Number of
            Database::"NFL Requisition Header":
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
        Claim: Record "NFL Requisition Header";
    begin
        case RecRef.Number of
            Database::"NFL Requisition Header":
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
        claim: Record "NFL Requisition Header";
    begin
        case RecRef.Number of
            Database::"NFL Requisition Header":
                begin
                    RecRef.SetTable(claim);
                    claim.Status := claim.Status::"Pending approval";
                    claim.Modify();
                    IsHandled := true;
                end;
        end;
    end;

    /// <summary>
    /// CheckBudgetPurchase.
    /// </summary>
    /// <param name="RequisitionHeader">VAR Record "NFL Requisition Header".</param>
    procedure CheckBudgetPurchase(var RequisitionHeader: Record "NFL Requisition Header");
    var
        RequisitionLine: Record "NFL Requisition Line";
    begin
        // New vision requires that all requisition out of budget are escaladed to the CEO/CFO
        // for approval.
        RequisitionHeader.TESTFIELD("Budget Code");
        RequisitionHeader.TESTFIELD("Shortcut Dimension 1 Code");
        RequisitionLine.RESET;
        IF RequisitionHeader.Status = RequisitionHeader.Status::"Pending Approval" THEN BEGIN
            // Budget holder should enter the codes before approving the document.
            RequisitionLine.SETRANGE("Document Type", RequisitionHeader."Document Type");
            RequisitionLine.SETRANGE("Document No.", RequisitionHeader."No.");
            IF RequisitionLine.FIND('-') THEN
                REPEAT
                    IF RequisitionLine.Type = RequisitionLine.Type::"G/L Account" THEN BEGIN
                        if RequisitionLine."G/L Account Type" = RequisitionLine."G/L Account Type"::"Income Statement" then begin
                            IF RequisitionLine."Budget Comment" = 'Out of Budget' THEN BEGIN
                                ERROR('Purchase Requisition Line %1 is Out of Budget and must be escaladed to CFO/CEO!', RequisitionLine."Line No.");
                            END;
                        end;
                    END;
                UNTIL RequisitionLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit 1521;
        WorkflowEventHandlingCust: Codeunit "PRQ Workflow EventHandling Ext";
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

    // Approval Management
    // ====================================
    /// <summary>
    /// CheckClaimApprovalsWorkflowEnable.
    /// </summary>
    /// <param name="Claim">VAR Record "NFL Requisition Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure CheckClaimApprovalsWorkflowEnable(var Claim: Record "NFL Requisition Header"): Boolean
    begin
        if not IsClaimDocApprovalsWorkflowEnable(Claim) then
            Error(NoWorkflowEnabledErr);
        exit(true);
    end;

    /// <summary>
    /// IsClaimDocApprovalsWorkflowEnable.
    /// </summary>
    /// <param name="Claim">VAR Record "NFL Requisition Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure IsClaimDocApprovalsWorkflowEnable(var Claim: Record "NFL Requisition Header"): Boolean
    begin
        if Claim.Status <> Claim.Status::Open then
            exit(false);
        exit(WorkflowManagement.CanExecuteWorkflow(Claim, WorkflowEventHandlingCust.RunWorkflowOnSendClaimForApprovalCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        Claim: Record "NFL Requisition Header";
    begin
        case RecRef.Number of
            Database::"NFL Requisition Header":
                begin
                    RecRef.SetTable(Claim);
                    ApprovalEntryArgument."Document No." := Claim."No.";
                    ApprovalEntryArgument."Document Type1" := Claim."Document Type"::"Purchase Requisition";
                end;
        end;
    end;

    /// <summary>
    /// OnSendClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "NFL Requisition Header".</param>
    [IntegrationEvent(false, false)]
    procedure OnSendClaimForApproval(var Claim: Record "NFL Requisition Header")
    begin

    end;

    /// <summary>
    /// OnCancelClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "NFL Requisition Header".</param>
    [IntegrationEvent(false, false)]
    procedure OnCancelClaimForApproval(var Claim: Record "NFL Requisition Header")
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
        LoanAdvance: Record "NFL Requisition Header";
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
                    RecRef.SetTable(LoanAdvance);
                    LoanAdvance.Validate(Status, LoanAdvance.Status::Open);
                    LoanAdvance.Modify();
                    Variant := LoanAdvance;
                end;
        end;
    end;

    /// <summary>
    /// modifyApprovalEntry.
    /// </summary>
    /// <param name="PurchaseReqHeader">Record "NFL Requisition Header".</param>
    procedure modifyApprovalEntry(PurchaseReqHeader: Record "NFL Requisition Header")
    var
        NflRequisitionLine: Record "NFL Requisition Line";
        AmountLcy: Decimal;
        ApprovalEntry: Record "Approval Entry";
    begin
        AmountLcy := 0;
        PurchaseReqHeader.CalcFields("Requisition Details Total");
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", PurchaseReqHeader."No.");
        ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created, ApprovalEntry.Status::Approved);
        if ApprovalEntry.FindFirst() then
            repeat
                ApprovalEntry."Document Type1" := PurchaseReqHeader."Document Type";
                ApprovalEntry."Prepared By" := PurchaseReqHeader."Prepared by";
                ApprovalEntry."Currency Code" := PurchaseReqHeader."Currency Code";
                ApprovalEntry.Amount := PurchaseReqHeader."Requisition Details Total";
                ApprovalEntry."Payee No." := PurchaseReqHeader."Request-By No.";
                ApprovalEntry."Payee Name" := PurchaseReqHeader."Request-By Name";
                ApprovalEntry.Description := PurchaseReqHeader."Posting Description";
                ApprovalEntry."Posting Date" := PurchaseReqHeader."Posting Date";
                ApprovalEntry.Modify();
            until ApprovalEntry.Next() = 0;
    end;

    /// <summary>
    /// UpdateApprovalEntryInfo.
    /// </summary>
    procedure UpdateApprovalEntryInfo()
    var
        PurchReq: Record "NFL Requisition Header";
        ApprovalEntry: Record "Approval Entry";
    begin

        PurchReq.Reset();
        PurchReq.SetRange(PurchReq."Document Type", PurchReq."Document Type"::"Purchase Requisition");
        PurchReq.SetRange(PurchReq.Status, PurchReq.Status::"Pending Approval");
        if PurchReq.FindFirst() then
            repeat
                PurchReq.CalcFields("Requisition Details Total");
                ApprovalEntry.SetRange(ApprovalEntry."Document No.", PurchReq."No.");
                ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created, ApprovalEntry.Status::Approved);
                if ApprovalEntry.FindFirst() then
                    repeat
                        ApprovalEntry."Document Type1" := PurchReq."Document Type";
                        ApprovalEntry."Prepared By" := PurchReq."Prepared by";
                        ApprovalEntry."Currency Code" := PurchReq."Currency Code";
                        ApprovalEntry.Amount := PurchReq."Requisition Details Total";
                        ApprovalEntry."Payee No." := PurchReq."Request-By No.";
                        ApprovalEntry."Payee Name" := PurchReq."Request-By Name";
                        ApprovalEntry.Description := PurchReq."Posting Description";
                        ApprovalEntry."Posting Date" := PurchReq."Posting Date";
                        ApprovalEntry.Modify();
                    until ApprovalEntry.Next() = 0;
            until PurchReq.Next() = 0;
        Message('Done Now');
    end;

    //Approval managed
    /// <summary>
    /// OpenApprovalEntries.
    /// </summary>
    /// <param name="Rec">Record "NFL Requisition Header".</param>
    procedure OpenApprovalEntries(Rec: Record "NFL Requisition Header")
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
                // NFLApprovalMgt.SendNFLRequisitionApprovalMail(Rec, ApprovalEntries1);
            end;
        end;
    end;

    // Reject The approval request.
    /// <summary>
    /// RejectApprovalRequest.
    /// </summary>
    /// <param name="Rec">Record "NFL Requisition Header".</param>
    procedure RejectApprovalRequest(Rec: Record "NFL Requisition Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
        NvText: Label 'The approval Request has been rejected';
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
            ApprovalEntries1.SetFilter(ApprovalEntries1.Status, '%1|%2|%3', ApprovalEntries1.Status::Created, ApprovalEntries1.Status::Open, ApprovalEntries1.Status::Approved);
            if ApprovalEntries1.FindFirst() then begin
                repeat
                    ApprovalEntries1.Status := ApprovalEntries1.Status::Rejected;
                    ApprovalEntries1.Modify();
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
    /// <param name="Rec">Record "NFL Requisition Header".</param>
    procedure OpenDocument(Rec: Record "NFL Requisition Header")
    var
        NFLRequisitionHeader: Record "NFL Requisition Header";
    begin
        NFLRequisitionHeader.Reset();
        NFLRequisitionHeader.SetRange(NFLRequisitionHeader."No.", Rec."No.");
        NFLRequisitionHeader.SetRange(NFLRequisitionHeader.Status, NFLRequisitionHeader.Status::"Pending Approval");
        if NFLRequisitionHeader.FindFirst() then begin
            NFLRequisitionHeader.Status := NFLRequisitionHeader.Status::Open;
            NFLRequisitionHeader.Modify();
        end;
    end;

    /// <summary>
    /// DelegatePurchaseApprovalRequest.
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>
    procedure DelegatePurchaseApprovalRequest(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
        UserSetup: Record "User Setup";
        Txt00003: Label 'Are you sure you want to delegate to:';
        MessageToSend: Text[100];
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            UserSetup.Reset();
            UserSetup.SetRange(UserSetup."User ID", ApprovalEntry."Approver ID");
            if UserSetup.FindFirst() then begin
                if UserSetup.Substitute <> '' then begin
                    MessageToSend := Txt00003 + ' ' + UserSetup.Substitute;
                    if Confirm(MessageToSend, true) then begin
                        ApprovalEntry."Approver ID" := UserSetup.Substitute;
                        ApprovalEntry."Last Modified By User ID" := UserId;
                        ApprovalEntry.Modify();
                        Message('Requisition has been Delegated to %1 Successfully', UserSetup.Substitute);
                    end;
                end else begin
                    Error('Substitute can not be empty. Contact your Systems Administrator');
                end;
            end else begin
                Error('You are not setup please consult your System Administrator');
            end;
        end else begin
            Error('You are not allowed to Delegate please contact your system Administrator');
        end;
    end;

    /// <summary>
    /// EscalateApprovalRequest.
    /// </summary>
    /// <param name="Rec">Record "NFL Requisition Header".</param>
    procedure EscalateApprovalRequest(Rec: Record "NFL Requisition Header")
    var
        ApprovalEntries: Record "Approval Entry";
        ApprovalEntries1: Record "Approval Entry";
        NvText: Label 'The approval Request has been Escalated';
        NvText1: Label 'This Operation Can not be performed contact your systems Administrator';
        NvText2: Label 'You do not have a person to escalate to. Contact your Systems Administrator';
        NvText3: Label 'Your not allowed to Escale because your not set as an SDU Head';
        userSetup: Record "User Setup";
        // DelegateEscalate: Record "Delegate Escalate Management";
        RequisitionLine: Record "NFL Requisition Line";
    begin
        // ApprovalEntries.Reset();
        // ApprovalEntries.SetRange(ApprovalEntries."Document No.", Rec."No.");
        // ApprovalEntries.SetRange(ApprovalEntries."Approver ID", UserId);
        // ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Open);
        // if ApprovalEntries.FindFirst() then begin
        //     //Check if the user is an SDU Head

        //     userSetup.Reset();
        //     userSetup.SetRange(userSetup."User ID", ApprovalEntries."Approver ID");
        //     userSetup.SetRange(userSetup."SBU Head", true);
        //     if userSetup.FindFirst() then begin
        //         //Getting the Escalate to ID

        //         DelegateEscalate.Reset();
        //         DelegateEscalate.SetRange(DelegateEscalate."Document Type", Rec."Document Type");
        //         DelegateEscalate.SetRange(DelegateEscalate."User ID", userSetup."User ID");
        //         DelegateEscalate.SetRange(DelegateEscalate."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
        //         if DelegateEscalate.FindFirst() then begin

        //             if DelegateEscalate."Escalate ID" <> '' then begin
        //                 Rec.TESTFIELD("Budget Code");
        //                 Rec.TESTFIELD("Shortcut Dimension 1 Code");
        //                 RequisitionLine.RESET;
        //                 IF Rec.Status = Rec.Status::"Pending Approval" THEN BEGIN

        //                     // Budget holder should enter the codes before approving the document.
        //                     RequisitionLine.SETRANGE("Document Type", Rec."Document Type");
        //                     RequisitionLine.SETRANGE("Document No.", Rec."No.");
        //                     IF RequisitionLine.FIND('-') THEN
        //                         REPEAT

        //                             IF RequisitionLine.Type = RequisitionLine.Type::"G/L Account" THEN BEGIN
        //                                 // if RequisitionLine."G/L Account Type" = RequisitionLine."G/L Account Type"::"Income Statement" then begin
        //                                 // IF RequisitionLine."Budget Comment" = 'Out of Budget' THEN BEGIN
        //                                 escalateDoc(ApprovalEntries."Approval Code", Rec."No.", UserId, DelegateEscalate."Escalate ID", Rec);
        //                                 // END;
        //                                 // end;
        //                             END;
        //                         UNTIL RequisitionLine.NEXT = 0;
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
        //     //voucher has to be out of budget
        //     //>500,000 all cash voucher
        //     //wen the voucher is out of budget it should escalated
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
    /// <param name="NFLRequisitionHeader">Record "NFL Requisition Header".</param>
    procedure escalateDoc(var ApproveCode: Code[50]; DocNo: Code[50]; userIDEsc: Code[50]; EscalateTo: Code[50]; NFLRequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
        Txt0010: Label 'Are you sure you want to escalate to';
        SendMessage: Text[100];
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", DocNo);
        ApprovalEntry.SetRange(ApprovalEntry."Approval Code", ApproveCode);
        ApprovalEntry.SetRange(ApprovalEntry."Approver ID", userIDEsc);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            SendMessage := Txt0010 + ' ' + EscalateTo;
            if Confirm(SendMessage, true) then begin
                ApprovalEntry."Approver ID" := EscalateTo;
                ApprovalEntry."Escalated By" := userIDEsc;
                ApprovalEntry."Escalated On" := Today();
                ApprovalEntry.Modify();
                Message('Document has been Escalated to: %1', EscalateTo);
            end else
                Message('The Document has not been escalate');
        end;
    end;

    /// <summary>
    /// CancelPurchaseApprovalRequest.
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>
    procedure CancelPurchaseApprovalRequest(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
        PurchRequisitionHeader: Record "NFL Requisition Header";
    begin
        PurchRequisitionHeader.Reset();
        PurchRequisitionHeader.SetRange(PurchRequisitionHeader."No.", RequisitionHeader."No.");
        PurchRequisitionHeader.SetRange(PurchRequisitionHeader.Status, PurchRequisitionHeader.Status::"Pending Approval");
        if PurchRequisitionHeader.FindFirst() then begin
            ApprovalEntry.Reset();
            ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
            ApprovalEntry.SetFilter(ApprovalEntry.Status, '%1|%2|%3', ApprovalEntry.Status::Approved, ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
            if ApprovalEntry.FindFirst() then begin
                repeat
                    ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                    ApprovalEntry."Last Modified By User ID" := UserId;
                    ApprovalEntry.Modify();
                until ApprovalEntry.Next() = 0;
            end;
            PurchRequisitionHeader.Status := PurchRequisitionHeader.Status::Open;
            PurchRequisitionHeader.Modify();
        end;
        Message('The Request has been Cancelled');
    end;


    /// <summary>
    /// ReopenApprovalEntries.
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>

    procedure ReopenApprovalEntries(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
        // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
        UserSetUp: Record "User Setup";
        VoucherAdmin: Boolean;
    begin
        if not (RequisitionHeader.Status = RequisitionHeader.Status::Open) then
            exit;

        VoucherAdmin := false;
        UserSetUp.Reset();
        UserSetUp.SetRange(UserSetUp."User ID", UserId);
        UserSetUp.SetRange(UserSetUp."Voucher Admin", true);
        if UserSetUp.FindFirst() then begin
            VoucherAdmin := true;
        end;
        if (VoucherAdmin = true) then begin
            if (RequisitionHeader.Status = RequisitionHeader.Status::Open) then begin
                ApprovalEntry.Reset();
                ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
                ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
                if ApprovalEntry.FindFirst() then
                    repeat
                        ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry.Modify();
                    until ApprovalEntry.Next() = 0;
            end;
        end;

    end;


}