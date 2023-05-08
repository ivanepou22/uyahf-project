/// <summary>
/// TableExtension Loan and Advance HeaderExt (ID 50140) extends Record Loan and Advance Header.
/// </summary>
tableextension 50040 "NFL Requisition HeaderExt" extends "NFL Requisition Header"
{

    fields
    {
        // Add changes to table fields here
        field(50100; "Approvals Entry"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Approval Entry" where("Document No." = field("No."), Status = filter(open | Created)));
        }
        field(50101; Freelance; Boolean)
        {
            Caption = 'Freelance';
        }
        field(50102; "Current Approver"; Code[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Approval Entry"."Approver ID" where("Document No." = field("No."), Status = filter(Open)));
        }
    }

    trigger OnDelete()
    begin

    end;


    /// <summary>
    /// PerformManualReopen.
    /// </summary>
    /// <param name="VAR NFLRequisitionHeader">Record "NFL Requisition Header".</param>
    procedure PerformManualReopen(VAR NFLRequisitionHeader: Record "NFL Requisition Header")
    var
        UserSetUp: Record "User Setup";
        VoucherAdmin: Boolean;
    begin
        VoucherAdmin := false;

        UserSetUp.Reset();
        UserSetUp.SetRange(UserSetUp."User ID", UserId);
        UserSetUp.SetRange(UserSetUp."Voucher Admin", true);
        if UserSetUp.FindFirst() then begin
            VoucherAdmin := true;
        end;
        if (VoucherAdmin = true) then begin
            IF NFLRequisitionHeader.Status = NFLRequisitionHeader.Status::"Pending Approval" THEN
                ERROR('You Can not open a document Pending Approval');
            Reopen(NFLRequisitionHeader);
        end else begin
            Error('Your not allowed to perfom this Operation, Document can only be opened by Voucher Admin');
        end;
    end;

    /// <summary>
    /// Reopen.
    /// </summary>
    /// <param name="VAR NFLRequisitionHeader">Record "NFL Requisition Header".</param>
    procedure Reopen(VAR NFLRequisitionHeader: Record "NFL Requisition Header")
    begin
        WITH NFLRequisitionHeader DO BEGIN
            IF Status = Status::Open THEN
                EXIT;
            Status := Status::Open;
            MODIFY(TRUE);
            ReversePurchaseRequisitionCommitmentEntry();
            Message('The Document has been Reopened Successfully');
        END;
    end;


    /// <summary>
    /// ReleaseTheApprovedDoc.
    /// </summary>
    procedure ReleaseTheApprovedDoc()
    var
        NvText: Label 'The approval Request has been Approved .......';
    begin
        CalcFields("Approvals Entry");
        if "Approvals Entry" = 0 then begin
            if Rec.Status = Rec.Status::"Pending approval" then begin
                Rec.Status := Rec.Status::Released;
                Rec."Release date" := Today();
                Rec.Modify();
                SendRequisitionApprovedEmail();
            end;
            Message(NvText);
        end;
    end;


    /// <summary>
    /// SendingDelegateEmail.
    /// </summary>
    /// <param name="RequisitionHeader">Record "Payment Voucher Header".</param>
    procedure SendingDelegateEmail(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry."Last Modified By User ID", UserId);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            // NFLApprovalMgt.SendNFLRequisitionDelegationMail(RequisitionHeader, ApprovalEntry);
        end;
    end;

    /// <summary>
    /// SendRequestApprovalEmail
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>
    procedure SendRequestApprovalEmail(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            // NFLApprovalMgt.SendNFLRequisitionApprovalMail(RequisitionHeader, ApprovalEntry);
        end;
    end;

    //check he document release
    procedure CheckDocumentRelease(var PurchaseRequisition: Record "NFL Requisition Header")
    var
        ApprovalEntries: Record "Approval Entry";
    begin
        ApprovalEntries.Reset();
        ApprovalEntries.SetRange("Document No.", PurchaseRequisition."No.");
        if ApprovalEntries.Find('-') then begin
            if not ((ApprovalEntries.Status = ApprovalEntries.Status::Open) or (ApprovalEntries.Status = ApprovalEntries.Status::Created)) then
                Message('Fully Approved');
        end;
    end;

    /// <summary>
    /// SendingCancelApprovalEmail.
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>
    procedure SendingCancelApprovalEmail(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", RequisitionHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Canceled);
        ApprovalEntry.SetFilter(ApprovalEntry."Approver ID", '<>%1', UserId);
        if ApprovalEntry.FindFirst() then
            repeat
            // NFLApprovalMgt.SendNFLRequisitionCancellationMail(RequisitionHeader, ApprovalEntry);
            until ApprovalEntry.Next() = 0;
    end;

    /// <summary>
    /// SendRequisitionApprovedEmail.
    /// </summary>
    procedure SendRequisitionApprovedEmail()
    var
        ApprovalEntry: Record "Approval Entry";
    // NFLApprovalMgt: Codeunit "NFL Approvals Mgt Notification";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
        ApprovalEntry.SetFilter(ApprovalEntry."Approver ID", '<>%1', UserId);
        if ApprovalEntry.FindFirst() then
            repeat
            // NFLApprovalMgt.SendNFLRequisitionApprovedMail(Rec, ApprovalEntry);
            until ApprovalEntry.Next() = 0;
    end;

    /// <summary>
    /// ReversePurchaseRequisitionCommitmentEntry.
    /// </summary>
    procedure ReversePurchaseRequisitionCommitmentEntry()
    var
        gvCommitmentEntry: Record "Commitment Entry";
        gvPurchLine: Record "Purchase Line";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        NFLRequisitionLine: Record "NFL Requisition Line";
        gvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
        //Reverse commitment on reopening an already released purchase requisistion document.
        IF Commited = TRUE THEN BEGIN
            gvNFLRequisitionLine.SETRANGE("Document No.", Rec."No.");
            IF gvNFLRequisitionLine.FIND('-') THEN
                REPEAT
                    gvCommitmentEntry.SETRANGE(gvCommitmentEntry."Entry No.", gvNFLRequisitionLine."Commitment Entry No.");
                    IF gvCommitmentEntry.FIND('-') THEN
                        IF NOT lastCommitmentEntry.FINDLAST THEN
                            lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
                        ELSE
                            lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;
                    reversedCommitmentEntry.INIT;
                    reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
                    reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
                    reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
                    reversedCommitmentEntry."Document Type" := gvCommitmentEntry."Document Type";
                    reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
                    reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
                    reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
                    reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
                    reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
                    reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
                    reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
                    reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
                    reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
                    reversedCommitmentEntry."Additional-Currency Amount" := -1 * gvCommitmentEntry."Additional-Currency Amount";
                    reversedCommitmentEntry."Add.-Currency Debit Amount" := -1 * gvCommitmentEntry."Add.-Currency Debit Amount";
                    reversedCommitmentEntry."Add.-Currency Credit Amount" := -1 * gvCommitmentEntry."Add.-Currency Credit Amount";
                    reversedCommitmentEntry.Reversed := TRUE;
                    reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
                    reversedCommitmentEntry."User ID" := USERID;
                    reversedCommitmentEntry."Source Code" := 'Reopened';
                    gvCommitmentEntry.Reversed := TRUE;
                    gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
                    reversedCommitmentEntry.INSERT;
                    gvCommitmentEntry.MODIFY;
                    gvNFLRequisitionLine."Commitment Entry No." := 0; //Reset the commited purchase line back to zero.
                    gvNFLRequisitionLine.MODIFY;
                UNTIL gvNFLRequisitionLine.NEXT = 0;
        END;
        Commited := FALSE;
        //END

        MODIFY(TRUE);
    end;
}