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
            ReversePurchaseRequisitionCommitmentEntryOnRejectOrReopen();
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
    // procedure CheckDocumentRelease(var PurchaseRequisition: Record "NFL Requisition Header")
    // var
    //     ApprovalEntries: Record "Approval Entry";
    //     PurchaseSetup: Record "Purchases & Payables Setup";
    // begin
    //     ApprovalEntries.Reset();
    //     ApprovalEntries.SetRange("Document No.", PurchaseRequisition."No.");
    //     if ApprovalEntries.Find('-') then begin
    //         if not ((ApprovalEntries.Status = ApprovalEntries.Status::Open) or (ApprovalEntries.Status = ApprovalEntries.Status::Created)) then begin
    //             if PurchaseSetup."Create Purch. comm. on Approv." then
    //                 Rec.CreatePurchaseRequisitionCommitmentEntries();
    //         end;
    //     end;
    // end;

    procedure CheckForBudgetControllerApproval(var PurchaseRequisition: Record "NFL Requisition Header")
    var
        ApprovalEntries: Record "Approval Entry";
        UserSetup: Record "User Setup";
    begin
        ApprovalEntries.Reset();
        ApprovalEntries.SetRange("Approver ID", UserId);
        ApprovalEntries.SetRange("Document No.", PurchaseRequisition."No.");
        ApprovalEntries.SetRange(Status, ApprovalEntries.Status::Approved);
        if ApprovalEntries.FindFirst() then begin
            UserSetup.Reset();
            UserSetup.SetRange("User ID", ApprovalEntries."Approver ID");
            UserSetup.SetRange("Budget Controller", true);
            if UserSetup.FindFirst() then begin
                Rec.CreatePurchaseRequisitionCommitmentEntries();
            end;
        end;
    end;

    /// <summary>
    /// SendingCancelApprovalEmail.
    /// </summary>
    /// <param name="RequisitionHeader">Record "NFL Requisition Header".</param>
    procedure SendingCancelApprovalEmail(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
        UserSetup: Record "User Setup";
    begin

    end;

    /// <summary>
    /// SendRequisitionApprovedEmail.
    /// </summary>
    procedure SendRequisitionApprovedEmail(RequisitionHeader: Record "NFL Requisition Header")
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange("Document No.", RequisitionHeader."No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            SendEmailToVoucherOwner(RequisitionHeader, ApprovalEntry);
            SendEmailToVoucherApprover(RequisitionHeader, ApprovalEntry);
        end;
    end;

    procedure SendEmailToVoucherOwner(RequisitionHeader: Record "NFL Requisition Header"; ApprovalEntry: Record "Approval Entry")
    var
        EmailBody: Text[1000];
        MSTRecepientsList: List of [Text];
        MSTCCRecepientsList: List of [Text];
        MSTBCCRecepientsList: List of [Text];
        FileMgt: Codeunit "File Management";
        EmailObj: Codeunit Email;
        EmailMsg: Codeunit "Email Message";
        RequisitionStatus: Text[50];
        UserSetup: Record "User Setup";
        DocumentNo: Code[20];
        EmailSubject: Text[250];
    begin
        if UserSetup.Get(ApprovalEntry."Sender ID") then begin
            EmailBody := 'Dear ' + UserSetup."E-Mail" + ', Purchase Requisition No. ' + ApprovalEntry."Document No." + ' is with ' + ApprovalEntry."Approver ID";
            MSTRecepientsList.Add(UserSetup."E-Mail");
            DocumentNo := ApprovalEntry."Document No.";
            EmailSubject := 'Purchase Requisition Approval in Progress ' + DocumentNo;
            EmailMsg.Create(MSTRecepientsList, EmailSubject,
            EmailBody,
            false, MSTCCRecepientsList, MSTBCCRecepientsList);
            EmailObj.Send(EmailMsg, Enum::"Email Scenario"::Default);
        end;
    end;

    procedure SendEmailToVoucherApprover(RequisitionHeader: Record "NFL Requisition Header"; ApprovalEntry: Record "Approval Entry")
    var
        ApprovalEmailSubject: Text[150];
        EmailBody: Text[1000];
        MSTRecepientsList: List of [Text];
        MSTCCRecepientsList: List of [Text];
        MSTBCCRecepientsList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentInStream: InStream;
        FileMgt: Codeunit "File Management";
        EmailObj: Codeunit Email;
        EmailMsg: Codeunit "Email Message";
        RequisitionStatus: Text[50];
        UserSetup: Record "User Setup";
        DocumentNo: Code[20];
        EmailSubject: Text[250];
    begin
        if UserSetup.Get(ApprovalEntry."Approver ID") then begin
            EmailBody := 'Dear ' + UserSetup."E-Mail" + ', Purchase Requisition No. ' + ApprovalEntry."Document No." + ' is on your desk for approval ' + GetUrl(CLIENTTYPE::Web, CompanyName, ObjectType::Page, Page::"Requests to Approve");
            // EmailBody := STRSUBSTNO(EmailBody, GetUrl(CLIENTTYPE::Web, CompanyName, ObjectType::Page, Page::"Requests to Approve"));
            MSTRecepientsList.Add(UserSetup."E-Mail");
            DocumentNo := ApprovalEntry."Document No.";
            EmailSubject := 'Purchase Requisition ' + DocumentNo + ' Requires Your attension';
            EmailMsg.Create(MSTRecepientsList, EmailSubject,
            EmailBody,
            false, MSTCCRecepientsList, MSTBCCRecepientsList);
            EmailObj.Send(EmailMsg, Enum::"Email Scenario"::Default);
        end;
    end;
}