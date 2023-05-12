/// <summary>
/// TableExtension Loan and Advance HeaderExt (ID 50056) extends Record Loan and Advance Header.
/// </summary>
tableextension 50042 "Payment Voucher Header" extends "Payment Voucher Header"
{

    fields
    {
        // Add changes to table fields here
        field(50100; "Approvals Entry"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Approval Entry" where("Document No." = field("No."), Status = filter(open | Created)));
        }
        field(50034; "Budget At Date Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Payment Voucher Line" where("Document No." = field("No."), "Account Type" = filter("G/L Account"), "Document Type" = field("Document Type"), "Exceeded at Date Budget" = filter(true)));
            Editable = false;
        }
        field(50035; "Month Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Payment Voucher Line" where("Document No." = field("No."), "Account Type" = filter("G/L Account"), "Document Type" = field("Document Type"), "Exceeded Month Budget" = filter(true)));
            Editable = false;
        }
        field(50036; "Quarter Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Payment Voucher Line" where("Document No." = field("No."), "Account Type" = filter("G/L Account"), "Document Type" = field("Document Type"), "Exceeded Quarter Budget" = filter(true)));
            Editable = false;
        }
        field(50037; "Year Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Payment Voucher Line" where("Document No." = field("No."), "Account Type" = filter("G/L Account"), "Document Type" = field("Document Type"), "Exceeded Year Budget" = filter(true)));
            Editable = false;
        }
        field(50038; Freelance; Boolean)
        {
            Caption = 'Freelance';
        }
        field(50039; "Current Approver"; Code[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Approval Entry"."Approver ID" where("Document No." = field("No."), Status = filter(Open)));
        }
    }

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    //reopen function
    /// <summary>
    /// OpenReleasedVouchers.
    /// </summary>
    procedure OpenReleasedVouchers()
    var
        PaymentVoucher: Record "Payment Voucher Header";
    begin
        PaymentVoucher.Reset();
        PaymentVoucher.SetRange(Status, PaymentVoucher.Status::Released);
        PaymentVoucher.SetFilter("Current Approver", '<>%1', '');
        if PaymentVoucher.FindFirst() then begin
            repeat
                PaymentVoucher.Status := PaymentVoucher.Status::"Pending Approval";
                PaymentVoucher.Modify();
            until PaymentVoucher.Next() = 0;
            // Message('Job Done');
        end;
    end;

    /// <summary>
    /// PerformManualReopen.
    /// </summary>
    /// <param name="VAR PaymentVoucher">Record "Payment Voucher Header".</param>
    procedure PerformManualReopen(VAR PaymentVoucher: Record "Payment Voucher Header")
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
            IF PaymentVoucher.Status = PaymentVoucher.Status::"Pending Approval" THEN
                ERROR('You Can not open a document Pending Approval');
            Reopen(PaymentVoucher);
        end else begin
            Error('Your not allowed to perfom this Operation, Document can only be opened by Voucher Admin');
        end;
    end;

    /// <summary>
    /// Reopen.
    /// </summary>
    /// <param name="VAR PaymentVoucher">Record "Payment Voucher Header".</param>
    procedure Reopen(VAR PaymentVoucher: Record "Payment Voucher Header")
    begin
        WITH PaymentVoucher DO BEGIN
            IF Status = Status::Open THEN
                EXIT;
            Status := Status::Open;
            MODIFY(TRUE);
            ReversePaymentVoucherCommitmentEntrie();
            Message('The Document has been Reopened Successfully');
        END;
    end;

    /// <summary>
    /// ReleaseTheApprovedDoc.
    /// </summary>
    procedure ReleaseTheApprovedDoc()
    var
        NvText: Label 'The approval Request has been Approved';
        ApprovalManagement: Codeunit "Custom Functions Cash";
    begin
        CalcFields("Approvals Entry");
        if "Approvals Entry" = 0 then begin
            if Rec.Status = Rec.Status::"Pending approval" then begin
                Rec."Release Date" := Today();
                Rec.Status := Rec.Status::Released;
                Rec.Modify();
                SendRequisitionApprovedEmail();
                ApprovalManagement.CreatePaymentVoucherCommitment(Rec);
            end;
            Message(NvText);
        end;
    end;


    /// <summary>
    /// SendingDelegateEmail.
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>
    procedure SendingDelegateEmail(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        NFLApprovalMgt: Codeunit "Custom Functions Cash";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry."Last Modified By User ID", UserId);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            NFLApprovalMgt.SendPaymentVoucherDelegationMail(VoucherHeader, ApprovalEntry);
        end;
    end;




    /// <summary>
    /// SendRequestApprovalEmail
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>
    procedure SendRequestApprovalEmail(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        NFLApprovalMgt: Codeunit "Custom Functions Cash";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            NFLApprovalMgt.SendPaymentVoucherApprovalMail(VoucherHeader, ApprovalEntry);
        end;
    end;

    /// <summary>
    /// SendingCancelApprovalEmail.
    /// </summary>
    /// <param name="VoucherHeader">Record "Payment Voucher Header".</param>
    procedure SendingCancelApprovalEmail(VoucherHeader: Record "Payment Voucher Header")
    var
        ApprovalEntry: Record "Approval Entry";
        NFLApprovalMgt: Codeunit "Custom Functions Cash";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", VoucherHeader."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Canceled);
        ApprovalEntry.SetFilter(ApprovalEntry."Approver ID", '<>%1', UserId);
        if ApprovalEntry.FindFirst() then
            repeat
                NFLApprovalMgt.SendPaymentVoucherCancellationMail(VoucherHeader, ApprovalEntry)
            until ApprovalEntry.Next() = 0;
    end;


    /// <summary>
    /// SendRequisitionApprovedEmail.
    /// </summary>
    procedure SendRequisitionApprovedEmail()
    var
        ApprovalEntry: Record "Approval Entry";
        NFLApprovalMgt: Codeunit "Custom Functions Cash";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", Rec."No.");
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Approved);
        ApprovalEntry.SetFilter(ApprovalEntry."Approver ID", '<>%1', UserId);
        if ApprovalEntry.FindFirst() then
            repeat
                NFLApprovalMgt.SendPaymentVoucherApprovedMail(Rec, ApprovalEntry);
            until ApprovalEntry.Next() = 0;
    end;

    /// <summary>
    /// ReversePaymentVoucherCommitmentEntrie.
    /// </summary>
    procedure ReversePaymentVoucherCommitmentEntrie()
    var
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        PaytVouchLine: Record "Payment Voucher Line";
        gvPaytVouchLine: Record "Payment Voucher Line";
        gvCommitmentEntry: Record "Commitment Entry";
    begin
        //Reverse commitment on reopening an already released Cash voucher document.
        IF Commited = TRUE THEN BEGIN
            gvPaytVouchLine.SETRANGE("Document No.", Rec."No.");
            gvPaytVouchLine.SETRANGE("Document Type", Rec."Document Type");
            IF gvPaytVouchLine.FIND('-') THEN
                REPEAT
                    gvCommitmentEntry.SETRANGE(gvCommitmentEntry."Entry No.", gvPaytVouchLine."Commitment Entry No.");
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
                    reversedCommitmentEntry."Source Code" := 'CANCELLED';
                    gvCommitmentEntry.Reversed := TRUE;
                    gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
                    reversedCommitmentEntry.INSERT;
                    gvCommitmentEntry.MODIFY;
                    gvPaytVouchLine."Commitment Entry No." := 0; //Reset the commited purchase line back to zero.
                    gvPaytVouchLine.MODIFY;
                UNTIL gvPaytVouchLine.NEXT = 0;
        END;
        Commited := FALSE;
        MODIFY(TRUE);
    end;

    /// <summary>
    /// CheckPaymentVoucherLinesTotal.
    /// </summary>
    procedure CheckPaymentVoucherLinesTotal()
    var
        PaymentLineTotal: Decimal;
        PaymentVoucherLine: Record "Payment Voucher Line";
        Txt002: Label 'Payment Lines must have atleast one line with Amount Ivan.';
        Txt003: Label 'Payment Voucher Lines must have atleast one line with Amount';
        PVLineAmount: Decimal;
    begin
        PVLineAmount := 0;
        CalcFields("Payment Voucher Lines Total");
        PaymentLineTotal := "Payment Voucher Lines Total";

        if (Rec."Balancing Entry" = Rec."Balancing Entry"::"Same Line") then begin
            if (PaymentLineTotal <= 0) then begin
                Error(Txt002);
            end;
        end else
            if (Rec."Balancing Entry" = Rec."Balancing Entry"::"Different Line") then begin
                PaymentVoucherLine.Reset();
                PaymentVoucherLine.SetRange(PaymentVoucherLine."Document No.", Rec."No.");
                PaymentVoucherLine.SetRange(PaymentVoucherLine."Document Type", Rec."Document Type");
                PaymentVoucherLine.SetFilter(PaymentVoucherLine."Account Type", '<>%1', PaymentVoucherLine."Account Type"::"Bank Account");
                if PaymentVoucherLine.FindFirst() then
                    repeat
                        if PaymentVoucherLine.Amount > 0 then
                            PVLineAmount += PaymentVoucherLine.Amount;
                    until PaymentVoucherLine.Next() = 0;
                if PVLineAmount <= 0 then
                    Error(Txt003);
            end;
    end;

    //check for over-Quoting or Under-Quoting
    /// <summary>
    /// CheckAmountCoded.
    /// </summary>
    procedure CheckAmountCoded()
    var
        PaymentVoucherLine: Record "Payment Voucher Line";
        PaymentVoucherLine1: Record "Payment Voucher Line";
        PaymentVoucherDetailsAmount: Decimal;
        PaymentVoucherLinesAmount: Decimal;
        LinesDetailsDifference: Decimal;
        DifferenceLineAmount: Decimal;
        Text001: Label 'Total Payee amount is less total Expenditure amount by %1. Are you sure you want to transfer the entries to the journal';
        Text002: Label 'Total Payee amount exceeds total Expenditure amount by %1';
        Text003: Label 'You have an empty line in your Voucher Lines, Please delete the empty Line and try Again';
    begin
        Clear(LinesDetailsDifference);
        Clear(PaymentVoucherDetailsAmount);
        Clear(PaymentVoucherLinesAmount);
        Clear(DifferenceLineAmount);
        CalcFields(Rec."Payment Voucher Details Total");
        CalcFields(Rec."Payment Voucher Lines Total");

        PaymentVoucherLine1.Reset();
        PaymentVoucherLine1.SetRange(PaymentVoucherLine1."Document No.", Rec."No.");
        PaymentVoucherLine1.SetRange(PaymentVoucherLine1."Document Type", Rec."Document Type");
        PaymentVoucherLine1.SetRange(PaymentVoucherLine1.Amount, 0);
        if PaymentVoucherLine1.FindFirst() then begin
            Error(Text003);
        end;

        PaymentVoucherDetailsAmount := Rec."Payment Voucher Details Total";
        if (Rec."Balancing Entry" = Rec."Balancing Entry"::"Same Line") then begin
            PaymentVoucherLinesAmount := Rec."Payment Voucher Lines Total";
            if (PaymentVoucherLinesAmount > PaymentVoucherDetailsAmount) then begin
                Error(Text002, (PaymentVoucherLinesAmount - PaymentVoucherDetailsAmount));
            end else
                if (PaymentVoucherLinesAmount < PaymentVoucherDetailsAmount) then begin
                    LinesDetailsDifference := PaymentVoucherDetailsAmount - PaymentVoucherLinesAmount;
                    if (LinesDetailsDifference > 0) then begin
                        if not Confirm(StrSubstNo(Text001, LinesDetailsDifference)) then
                            exit;
                    end;
                end;
        end else
            if (Rec."Balancing Entry" = Rec."Balancing Entry"::"Different Line") then begin
                PaymentVoucherLine.Reset();
                PaymentVoucherLine.SetRange(PaymentVoucherLine."Document No.", Rec."No.");
                PaymentVoucherLine.SetRange(PaymentVoucherLine."Document Type", Rec."Document Type");
                PaymentVoucherLine.SetFilter(PaymentVoucherLine.Amount, '>%1', 0);
                if PaymentVoucherLine.FindFirst() then
                    repeat
                        DifferenceLineAmount += PaymentVoucherLine.Amount;
                    until PaymentVoucherLine.Next() = 0;

                if (DifferenceLineAmount > PaymentVoucherDetailsAmount) then begin
                    Error(Text002, (DifferenceLineAmount - PaymentVoucherDetailsAmount));
                end else
                    if (DifferenceLineAmount < PaymentVoucherDetailsAmount) then begin
                        LinesDetailsDifference := PaymentVoucherDetailsAmount - DifferenceLineAmount;
                        if not Confirm(StrSubstNo(Text001, LinesDetailsDifference)) then
                            exit;
                    end;
            end;
    end;

    //check for the lines
    /// <summary>
    /// CheckForLinesApproval.
    /// </summary>
    procedure CheckForLinesApproval()
    var
        VoucherLines: Record "Payment Voucher Line";
    begin
        if Rec."Balancing Entry" = Rec."Balancing Entry"::"Same Line" then begin
            VoucherLines.Reset();
            VoucherLines.SetRange(VoucherLines."Document Type", Rec."Document Type");
            VoucherLines.SetRange(VoucherLines."Document No.", Rec."No.");
            VoucherLines.SetRange(VoucherLines."Bal. Account No.", '');
            if VoucherLines.FindFirst() then
                VoucherLines.TestField("Bal. Account No.");
        end;
    end;

    //check for double entry
    /// <summary>
    /// CheckDoubleEntry.
    /// </summary>
    procedure CheckDoubleEntry()
    var
        VoucherLines: Record "Payment Voucher Line";
    begin
        if Rec."Balancing Entry" = Rec."Balancing Entry"::"Same Line" then begin
            VoucherLines.Reset();
            VoucherLines.SetRange("Document Type", Rec."Document Type");
            VoucherLines.SetRange("Document No.", Rec."No.");
            if VoucherLines.Find('-') then begin
                if VoucherLines."Bal. Account No." = '' then
                    VoucherLines.TestField("Bal. Account No.");
            end;
        end;
    end;

    // procedure CheckVoucherRelease(var PaymentVoucher: Record "Payment Voucher Header")
    // var
    //     ApprovalEntries: Record "Approval Entry";
    //     PurchaseSetup: Record "Purchases & Payables Setup";
    //     customFunctionsCash: Codeunit "Custom Functions Cash";
    // begin
    //     ApprovalEntries.Reset();
    //     ApprovalEntries.SetRange("Document No.", PaymentVoucher."No.");
    //     if ApprovalEntries.Find('-') then begin
    //         if not ((ApprovalEntries.Status = ApprovalEntries.Status::Open) or (ApprovalEntries.Status = ApprovalEntries.Status::Created)) then begin
    //             if PurchaseSetup."Create Vouch. comm. on Approv." then
    //                 customFunctionsCash.CreatePaymentVoucherCommitment(Rec);
    //         end;
    //     end;
    // end;

    procedure CheckForBudgetControllerApproval(var PaymentVoucher: Record "Payment Voucher Header")
    var
        ApprovalEntries: Record "Approval Entry";
        UserSetup: Record "User Setup";
        customFunctionsCash: Codeunit "Custom Functions Cash";
    begin
        ApprovalEntries.Reset();
        ApprovalEntries.SetRange("Approver ID", UserId);
        ApprovalEntries.SetRange("Document No.", PaymentVoucher."No.");
        ApprovalEntries.SetRange(Status, ApprovalEntries.Status::Approved);
        if ApprovalEntries.FindFirst() then begin
            UserSetup.Reset();
            UserSetup.SetRange("User ID", ApprovalEntries."Approver ID");
            UserSetup.SetRange("Budget Controller", true);
            if UserSetup.FindFirst() then begin
                customFunctionsCash.CreatePaymentVoucherCommitment(Rec);
            end;
        end;
    end;

    procedure ArchiveRequisition(var PaymentVoucherHeader: Record "Payment Voucher Header")
    var
        myInt: Integer;
    begin

    end;
}