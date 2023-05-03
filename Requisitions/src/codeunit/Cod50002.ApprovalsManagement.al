/// <summary>
/// Codeunit Approvals Management (ID 50052).
/// </summary>
codeunit 50002 "Approvals Management"
{
    // version NAVW18.00

    Permissions = TableData "Approval Entry" = imd,
                  TableData "Approval Comment Line" = imd,
                  TableData "Posted Approval Entry" = imd,
                  TableData "Posted Approval Comment Line" = imd,
                  TableData "Overdue Approval Entry" = imd;

    trigger OnRun();
    begin
    end;


    var
        Text001: Label '%1 %2 requires further approval.\\Approval request entries have been created.';
        Text002: Label '%1 %2 approval request cancelled.';
        Text003: Label '%1 %2 has been automatically approved and released.';
        Text004: Label 'Approval Setup not found.';
        Text005: Label 'User ID %1 does not exist in the User Setup table.';
        Text006: Label 'Approver ID %1 does not exist in the User Setup table.';
        Text007: Label '%1 for %2  does not exist in the User Setup table.';
        Text008: Label 'User ID %1 does not exist in the User Setup table for %2 %3.';
        Text013: TextConst Comment = '%1=document type, %2=document no., e.g. Order 321 must be approved...', ENU = '%1 %2 must be approved and released before you can perform this action.';
        Text010: Label 'Approver not found.';
        Text014: Label 'The %1 approval entries have now been cancelled.';
        Text015: Label 'The %1 %2 does not have any Lines.';
        Text022: Label 'There has to be a %1 on %2 %3.';
        //AddApproversTemp: Record "465" temporary; IE
        Text023: Label '"A template with a blank Approval Type or with Limit Type ""Credit Limit"", must have additional approvers. "';
        Text024: Label '%1 are only for purchase request orders.';
        Text025: Label '%1 is not a valid limit type for %2 %3.';
        Text026: Label '%1 is only a valid limit type for %2.';
        Text027: Label 'When Approval Type is blank, additional approvers must be added to the template.';
        Text028: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        Text100: Label 'S-QUOTE';
        Text101: Label 'Sales Quote Approval';
        Text102: Label 'S-ORDER';
        Text103: Label 'Sales Order Approval';
        Text104: Label 'S-INVOICE';
        Text105: Label 'Sales Invoice Approval';
        Text106: Label 'S-CREDIT MEMO';
        Text107: Label 'Sales Credit Memo Approval';
        Text108: Label 'S-RETURN ORDER';
        Text109: Label 'Sales Return Order Approval';
        Text110: Label 'S-BLANKET ORDER';
        Text111: Label 'Sales Blanket Order Approval';
        Text112: Label 'P-QUOTE';
        Text113: Label 'Purchase Quote Approval';
        Text114: Label 'P-ORDER';
        Text115: Label 'Purchase Order Approval';
        Text116: Label 'P-INVOICE';
        Text117: Label 'Purchase Invoice Approval';
        Text118: Label 'P-CREDIT MEMO';
        Text119: Label 'Purchase Credit Memo Approval';
        Text120: Label 'P-RETURN ORDER';
        Text121: Label 'Purchase Return Order Approval';
        Text122: Label 'P-BLANKET ORDER';
        Text123: Label 'Purchase Blanket Order Approval';
        Text124: Label 'S-O-CREDITLIMIT';
        Text125: Label 'Sales Order Credit Limit Approval';
        Text126: Label 'S-I-CREDITLIMIT';
        Text127: Label 'Sales Invoice Credit Limit Approval';
        Text128: Label '%1 %2 has been automatically approved. Status changed to Pending Prepayment.';
        Text129: Label 'No Approval Templates are enabled for document type %1.';
        IsOpenStatusSet: Boolean;
        Text130: Label 'The approval request cannot be canceled because the order has already been released. To modify this order, you must reopen it.';
        UnpostedPrepaymentExistsMsg: Label '%1 There are unposted prepayment amounts on the document of type %2 with the number %3.';
        "=======": Integer;
        DispMessage: Boolean;
        JnlTemplate: Record "Gen. Journal Template";
        JnlLine: Record "Gen. Journal Line";
        JnlBatch: Record "Gen. Journal Batch";
        //NFLApprovalSetup: Record "452"; IE
        NewDescription: Text[200];
        Text155: Label 'User ID %1 does not exist in the Departmental User Setup table for this Document Type and Department';
        Text144: Label '%1 May not be used for Payment Journals. Ensure your setup is done correctly';
        PmtCode: Code[20];
        FinalCount: Integer;
        NewLineNo: Integer;
        GenLedgSetUp: Record "General Ledger Setup";
        PaymentRequestApprovalMailSent: Boolean;
        Text145: Label '&All open lines [%1 line(s)],&Selected line(s) only';
        Text146: Label '&All submitted lines [%1 line(s)],&Selected line(s) only';
        Text147: Label 'Submit for approval';
        Text148: Label 'Reopen for editing';
        gvGenJournalBatch: Record "Gen. Journal Batch";
        BatchIdentifierCode: Code[20];
        gvUserSetup: Record "User Setup";
        Sender: Code[20];
        Receipient: Code[20];
        // NFLApprovalsMgtNotification: Codeunit "NFL Approvals Mgt Notification";
        NFLRequisitionHeader: Record "NFL Requisition Header";

    // /// <summary>
    // /// Description for SendSalesApprovalRequest.
    // /// </summary>
    // /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure SendSalesApprovalRequest(var SalesHeader: Record "Sales Header"): Boolean;
    // var
    //     // TemplateRec: Record "464";  IE
    //     // ApprovalSetup: Record "452"; IE
    //     MessageType: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval;
    // begin
    //     TestSetup;
    //     WITH SalesHeader DO BEGIN
    //         IF Status <> Status::Open THEN
    //             EXIT(FALSE);

    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         IF NOT SalesLinesExist THEN
    //             ERROR(Text015, FORMAT("Document Type"), "No.");

    //         CalcInvDiscForHeader;

    //         TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //         TemplateRec.SETRANGE("Table ID", DATABASE::"Sales Header");
    //         TemplateRec.SETRANGE("Document Type", "Document Type");
    //         TemplateRec.SETRANGE(Enabled, TRUE);
    //         IF TemplateRec.FIND('-') THEN BEGIN
    //             REPEAT
    //                 IF NOT FindApproverSales(SalesHeader, ApprovalSetup, TemplateRec) THEN
    //                     ERROR(Text010);
    //             UNTIL TemplateRec.NEXT = 0;
    //             FinishApprovalEntrySales(SalesHeader, ApprovalSetup, MessageType);
    //             CASE MessageType OF
    //                 MessageType::AutomaticPrePayment:
    //                     IF TestSalesPrepayment(SalesHeader) THEN
    //                         MESSAGE(
    //                           UnpostedPrepaymentExistsMsg,
    //                           STRSUBSTNO(Text128, "Document Type", "No."),
    //                           "Document Type",
    //                           "No.")
    //                     ELSE
    //                         MESSAGE(Text128, "Document Type", "No.");
    //                 MessageType::AutomaticRelease:
    //                     MESSAGE(Text003, "Document Type", "No.");
    //                 MessageType::RequiresApproval:
    //                     MESSAGE(Text001, "Document Type", "No.");
    //             END;
    //         END ELSE
    //             ERROR(STRSUBSTNO(Text129, "Document Type"));
    //         EXIT(TRUE);
    //     END;
    // end;

    // /// <summary>
    // /// Description for CancelSalesApprovalRequest.
    // /// </summary>
    // /// <param name="SalesHeader">Parameter of type Record "36".</param>
    // /// <param name="ShowMessage">Parameter of type Boolean.</param>
    // /// <param name="ManualCancel">Parameter of type Boolean.</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure CancelSalesApprovalRequest(var SalesHeader: Record "Sales Header"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    // var
    //     ApprovalEntry: Record "Approval Entry";
    //     // ApprovalSetup: Record "452";  IE
    //     // AppManagement: Codeunit "440"; IE
    //     SendMail: Boolean;
    //     MailCreated: Boolean;
    // begin
    //     TestSetup;
    //     IF SalesHeader.Status <> SalesHeader.Status::Released THEN BEGIN
    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         WITH SalesHeader DO BEGIN
    //             ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
    //             ApprovalEntry.SETRANGE("Table ID", DATABASE::"Sales Header");
    //             ApprovalEntry.SETRANGE("Document Type", "Document Type");
    //             ApprovalEntry.SETRANGE("Document No.", "No.");
    //             ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
    //             SendMail := FALSE;
    //             IF ApprovalEntry.FIND('-') THEN BEGIN
    //                 REPEAT
    //                     IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                        (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
    //                     THEN
    //                         SendMail := TRUE;
    //                     ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
    //                     ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //                     ApprovalEntry."Last Modified By ID" := USERID;
    //                     ApprovalEntry.MODIFY;
    //                     IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                         AppManagement.SendSalesCancellationsMail(SalesHeader, ApprovalEntry);
    //                         MailCreated := TRUE;
    //                         SendMail := FALSE;
    //                     END;
    //                 UNTIL ApprovalEntry.NEXT = 0;
    //                 IF MailCreated THEN BEGIN
    //                     AppManagement.SendMail;
    //                     MailCreated := FALSE;
    //                 END;
    //             END;

    //             IF ManualCancel OR (NOT ManualCancel AND NOT (Status = Status::Released)) THEN
    //                 Status := Status::Open;
    //             MODIFY(TRUE);
    //         END;
    //         IF ShowMessage THEN
    //             MESSAGE(Text002, SalesHeader."Document Type", SalesHeader."No.");
    //     END
    //     ELSE
    //         MESSAGE(Text130);
    // end;

    // /// <summary>
    // /// Description for SendPurchaseApprovalRequest.
    // /// </summary>
    // /// <param name="PurchaseHeader">Parameter of type Record "38".</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure SendPurchaseApprovalRequest(var PurchaseHeader: Record "Purchase Header"): Boolean;
    // var
    //     // TemplateRec: Record "464"; IE
    //     // ApprovalSetup: Record "452"; IE
    //     MessageType: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval;
    // begin
    //     TestSetup;
    //     WITH PurchaseHeader DO BEGIN
    //         IF Status <> Status::Open THEN
    //             EXIT(FALSE);

    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         IF NOT PurchLinesExist THEN
    //             ERROR(Text015, FORMAT("Document Type"), "No.");

    //         CalcInvDiscForHeader;

    //         TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //         TemplateRec.SETRANGE("Table ID", DATABASE::"Purchase Header");
    //         TemplateRec.SETRANGE("Document Type", "Document Type");
    //         TemplateRec.SETRANGE(Enabled, TRUE);
    //         IF TemplateRec.FIND('-') THEN BEGIN
    //             REPEAT
    //                 IF TemplateRec."Limit Type" = TemplateRec."Limit Type"::"Credit Limits" THEN BEGIN
    //                     ERROR(STRSUBSTNO(Text025, FORMAT(TemplateRec."Limit Type"), FORMAT("Document Type"),
    //                         "No."));
    //                 END ELSE BEGIN
    //                     IF NOT FindApproverPurchase(PurchaseHeader, ApprovalSetup, TemplateRec) THEN
    //                         ERROR(Text010);
    //                 END;
    //             UNTIL TemplateRec.NEXT = 0;
    //             FinishApprovalEntryPurchase(PurchaseHeader, ApprovalSetup, MessageType);
    //             CASE MessageType OF
    //                 MessageType::AutomaticPrePayment:
    //                     IF TestPurchasePrepayment(PurchaseHeader) THEN
    //                         MESSAGE(
    //                           UnpostedPrepaymentExistsMsg,
    //                           STRSUBSTNO(Text128, "Document Type", "No."),
    //                           "Document Type",
    //                           "No.")
    //                     ELSE
    //                         MESSAGE(Text128, "Document Type", "No.");
    //                 MessageType::AutomaticRelease:
    //                     MESSAGE(Text003, "Document Type", "No.");
    //                 MessageType::RequiresApproval:
    //                     MESSAGE(Text001, "Document Type", "No.");
    //             END;
    //         END ELSE
    //             ERROR(STRSUBSTNO(Text129, "Document Type"));
    //         EXIT(TRUE);
    //     END;
    // end;

    // /// <summary>
    // /// Description for CancelPurchaseApprovalRequest.
    // /// </summary>
    // /// <param name="PurchaseHeader">Parameter of type Record "Purchase Header".</param>
    // /// <param name="ShowMessage">Parameter of type Boolean.</param>
    // /// <param name="ManualCancel">Parameter of type Boolean.</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure CancelPurchaseApprovalRequest(var PurchaseHeader: Record "Purchase Header"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    // var
    //     ApprovalEntry: Record "Approval Entry";
    //     // ApprovalSetup: Record "452"; IE
    //     // AppManagement: Codeunit "440"; IE
    //     SendMail: Boolean;
    //     MailCreated: Boolean;
    // begin
    //     TestSetup;
    //     IF PurchaseHeader.Status <> PurchaseHeader.Status::Released THEN BEGIN
    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         WITH PurchaseHeader DO BEGIN
    //             ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
    //             ApprovalEntry.SETRANGE("Table ID", DATABASE::"Purchase Header");
    //             ApprovalEntry.SETRANGE("Document Type", "Document Type");
    //             ApprovalEntry.SETRANGE("Document No.", "No.");
    //             ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
    //             SendMail := FALSE;
    //             IF ApprovalEntry.FIND('-') THEN BEGIN
    //                 REPEAT
    //                     IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                        (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
    //                     THEN
    //                         SendMail := TRUE;
    //                     ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
    //                     ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //                     ApprovalEntry."Last Modified By ID" := USERID;
    //                     ApprovalEntry.MODIFY;
    //                     IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                         AppManagement.SendPurchaseCancellationsMail(PurchaseHeader, ApprovalEntry);
    //                         MailCreated := TRUE;
    //                         SendMail := FALSE;
    //                     END;
    //                 UNTIL ApprovalEntry.NEXT = 0;
    //                 IF MailCreated THEN BEGIN
    //                     AppManagement.SendMail;
    //                     MailCreated := FALSE;
    //                 END;
    //             END;

    //             IF ManualCancel OR (NOT ManualCancel AND NOT (Status = Status::Released)) THEN
    //                 Status := Status::Open;
    //             MODIFY(TRUE);
    //         END;
    //         IF ShowMessage THEN
    //             MESSAGE(Text002, PurchaseHeader."Document Type", PurchaseHeader."No.");
    //     END
    //     ELSE
    //         MESSAGE(Text130)
    // end;

    // /// <summary>
    // /// Description for CheckApprSalesDocument.
    // /// </summary>
    // /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure CheckApprSalesDocument(var SalesHeader: Record "Sales Header"): Boolean;
    // var
    // // ApprovalTemplate: Record "464";
    // begin
    //     // ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //     // ApprovalTemplate.SETRANGE("Table ID", DATABASE::"Sales Header");
    //     // ApprovalTemplate.SETRANGE("Document Type", SalesHeader."Document Type"); IE commented all these
    //     // ApprovalTemplate.SETRANGE(Enabled, TRUE);
    //     // EXIT(NOT ApprovalTemplate.ISEMPTY);
    // end;

    // /// <summary>
    // /// Description for CheckApprPurchaseDocument.
    // /// </summary>
    // /// <param name="PurchaseHeader">Parameter of type Record "38".</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure CheckApprPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Boolean;
    // var
    // // ApprovalTemplate: Record "464";
    // begin
    //     // ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //     // ApprovalTemplate.SETRANGE("Table ID", DATABASE::"Purchase Header");
    //     // ApprovalTemplate.SETRANGE("Document Type", PurchaseHeader."Document Type");  IE commented all these
    //     // ApprovalTemplate.SETRANGE(Enabled, TRUE);
    //     // EXIT(NOT ApprovalTemplate.ISEMPTY);
    // end;

    // /// <summary>
    // /// Description for SalesLines.
    // /// </summary>
    // /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    // /// <returns>Return variable "Boolean".</returns>
    // procedure SalesLines(SalesHeader: Record "Sales Header"): Boolean;
    // var
    //     SalesLines: Record "Sales Line";
    // begin
    //     SalesLines.SETCURRENTKEY("Document Type", "Document No.");
    //     SalesLines.SETRANGE("Document Type", SalesHeader."Document Type");
    //     SalesLines.SETRANGE("Document No.", SalesHeader."No.");
    //     IF SalesLines.FINDSET THEN
    //         REPEAT
    //             IF (SalesLines.Quantity <> 0) AND (SalesLines."Line Amount" <> 0) THEN
    //                 EXIT(TRUE);
    //         UNTIL SalesLines.NEXT = 0;

    //     EXIT(FALSE);
    // end;

    //IE Commented all this function
    /// <summary>
    /// Description for FindApproverSales.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="ApprovalSetup">Parameter of type Record "452".</param>
    /// <param name="ApprovalTemplates">Parameter of type Record "464".</param>
    /// <returns>Return variable "Boolean".</returns>
    // procedure FindApproverSales(SalesHeader: Record "Sales Header"; ApprovalSetup: Record "452"; ApprovalTemplates: Record "464"): Boolean;
    // var
    //     Cust: Record Customer;
    //     UserSetup: Record "User Setup";
    //     ApproverId: Code[50];
    //     ApprovalAmount: Decimal;
    //     ApprovalAmountLCY: Decimal;
    //     AboveCreditLimitAmountLCY: Decimal;
    //     InsertEntries: Boolean;
    //     SufficientApprover: Boolean;
    // begin

    // IE Commented all this function
    // AddApproversTemp.RESET;
    // AddApproversTemp.DELETEALL;

    // CalcSalesDocAmount(SalesHeader, ApprovalAmount, ApprovalAmountLCY);

    // CASE ApprovalTemplates."Approval Type" OF
    //     ApprovalTemplates."Approval Type"::"Sales Pers./Purchaser":
    //         BEGIN
    //             IF SalesHeader."Salesperson Code" = '' THEN
    //                 ERROR(STRSUBSTNO(Text022, SalesHeader.FIELDCAPTION("Salesperson Code"),
    //                     FORMAT(SalesHeader."Document Type"), SalesHeader."No."));

    //             CASE ApprovalTemplates."Limit Type" OF
    //                 ApprovalTemplates."Limit Type"::"Approval Limits":
    //                     BEGIN
    //                         AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                         UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                         UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
    //                         IF NOT UserSetup.FINDFIRST THEN
    //                             ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                               UserSetup."Salespers./Purch. Code");

    //                         MakeSalesHeaderApprovalEntry(
    //                           SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                           UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                         ApproverId := UserSetup."Approver ID";

    //                         IF NOT UserSetup."Unlimited Sales Approval" AND
    //                            ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") OR
    //                             (UserSetup."Sales Amount Approval Limit" = 0))
    //                         THEN BEGIN
    //                             UserSetup.RESET;
    //                             UserSetup.SETCURRENTKEY("User ID");
    //                             UserSetup.SETRANGE("User ID", ApproverId);
    //                             REPEAT
    //                                 IF NOT UserSetup.FINDFIRST THEN
    //                                     ERROR(Text006, ApproverId);
    //                                 ApproverId := UserSetup."User ID";
    //                                 MakeSalesHeaderApprovalEntry(
    //                                   SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                   ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                                 UserSetup.SETRANGE("User ID", UserSetup."Approver ID");

    //                                 SufficientApprover := UserSetup."Unlimited Sales Approval" OR
    //                                   ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") AND
    //                                    (UserSetup."Sales Amount Approval Limit" <> 0)) OR
    //                                   (UserSetup."User ID" = UserSetup."Approver ID")
    //                             UNTIL SufficientApprover;
    //                         END;

    //                         CheckAddApprovers(ApprovalTemplates);
    //                         AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                         IF AddApproversTemp.FINDSET THEN
    //                             REPEAT
    //                                 MakeSalesHeaderApprovalEntry(
    //                                   SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                   AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                             UNTIL AddApproversTemp.NEXT = 0;
    //                     END;
    //                 ApprovalTemplates."Limit Type"::"Credit Limits":
    //                     BEGIN
    //                         AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                         Cust.GET(SalesHeader."Bill-to Customer No.");
    //                         ApprovalTemplates.CALCFIELDS("Additional Approvers");
    //                         IF NOT ApprovalTemplates."Additional Approvers" THEN
    //                             ERROR(Text023);

    //                         InsertAddApprovers(ApprovalTemplates);
    //                         IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                             ApproverId := USERID;
    //                             MakeSalesHeaderApprovalEntry(
    //                               SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                         END ELSE BEGIN
    //                             UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                             UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                   UserSetup."Salespers./Purch. Code");

    //                             MakeSalesHeaderApprovalEntry(
    //                               SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                               UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakeSalesHeaderApprovalEntry(
    //                                       SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                     END;
    //                 ApprovalTemplates."Limit Type"::"Request Limits":
    //                     ERROR(STRSUBSTNO(Text024, FORMAT(ApprovalTemplates."Limit Type")));
    //                 ApprovalTemplates."Limit Type"::"No Limits":
    //                     BEGIN
    //                         AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                         UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                         UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
    //                         IF NOT UserSetup.FINDFIRST THEN
    //                             ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                               UserSetup."Salespers./Purch. Code");

    //                         ApproverId := UserSetup."User ID";
    //                         MakeSalesHeaderApprovalEntry(
    //                           SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                           ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

    //                         CheckAddApprovers(ApprovalTemplates);
    //                         AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                         IF AddApproversTemp.FINDSET THEN
    //                             REPEAT
    //                                 ApproverId := AddApproversTemp."Approver ID";
    //                                 MakeSalesHeaderApprovalEntry(
    //                                   SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                   ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                             UNTIL AddApproversTemp.NEXT = 0;
    //                     END;
    //             END;
    //         END;
    //     ApprovalTemplates."Approval Type"::Approver:
    //         CASE ApprovalTemplates."Limit Type" OF
    //             ApprovalTemplates."Limit Type"::"Approval Limits":
    //                 BEGIN
    //                     AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                     UserSetup.SETRANGE("User ID", USERID);
    //                     IF NOT UserSetup.FINDFIRST THEN
    //                         ERROR(Text005, USERID);
    //                     ApproverId := UserSetup."User ID";
    //                     MakeSalesHeaderApprovalEntry(
    //                       SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                       ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                     IF NOT UserSetup."Unlimited Sales Approval" AND
    //                        ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") OR
    //                         (UserSetup."Sales Amount Approval Limit" = 0))
    //                     THEN
    //                         REPEAT
    //                             UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text005, UserSetup."Approver ID");
    //                             ApproverId := UserSetup."User ID";
    //                             MakeSalesHeaderApprovalEntry(
    //                               SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                             SufficientApprover := UserSetup."Unlimited Sales Approval" OR
    //                               ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") AND
    //                                (UserSetup."Sales Amount Approval Limit" <> 0)) OR
    //                               (UserSetup."User ID" = UserSetup."Approver ID");
    //                         UNTIL SufficientApprover;

    //                     CheckAddApprovers(ApprovalTemplates);
    //                     AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                     IF AddApproversTemp.FINDSET THEN
    //                         REPEAT
    //                             MakeSalesHeaderApprovalEntry(
    //                               SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                               AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                         UNTIL AddApproversTemp.NEXT = 0;
    //                 END;
    //             ApprovalTemplates."Limit Type"::"Credit Limits":
    //                 BEGIN
    //                     AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                     Cust.GET(SalesHeader."Bill-to Customer No.");

    //                     ApprovalTemplates.CALCFIELDS("Additional Approvers");
    //                     IF NOT ApprovalTemplates."Additional Approvers" THEN
    //                         ERROR(Text023);

    //                     InsertAddApprovers(ApprovalTemplates);
    //                     IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                         ApproverId := USERID;
    //                         MakeSalesHeaderApprovalEntry(
    //                           SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                           ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                     END ELSE BEGIN
    //                         UserSetup.SETRANGE("User ID", USERID);
    //                         IF NOT UserSetup.FINDFIRST THEN
    //                             ERROR(Text005, USERID);
    //                         ApproverId := UserSetup."User ID";
    //                         MakeSalesHeaderApprovalEntry(
    //                           SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                           ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

    //                         AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                         IF AddApproversTemp.FINDSET THEN
    //                             REPEAT
    //                                 MakeSalesHeaderApprovalEntry(
    //                                   SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
    //                                   AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                             UNTIL AddApproversTemp.NEXT = 0;
    //                     END;
    //                 END;
    //             ApprovalTemplates."Limit Type"::"Request Limits":
    //                 ERROR(STRSUBSTNO(Text024, FORMAT(ApprovalTemplates."Limit Type")));
    //             ApprovalTemplates."Limit Type"::"No Limits":
    //                 BEGIN
    //                     AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //                     UserSetup.SETRANGE("User ID", USERID);
    //                     IF NOT UserSetup.FINDFIRST THEN
    //                         ERROR(Text005, USERID);
    //                     ApproverId := UserSetup."Approver ID";
    //                     IF ApproverId = '' THEN
    //                         ApproverId := UserSetup."User ID";
    //                     MakeSalesHeaderApprovalEntry(
    //                       SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                       ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                 END;
    //         END;
    //     ApprovalTemplates."Approval Type"::" ":
    //         BEGIN
    //             AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
    //             InsertEntries := FALSE;
    //             Cust.GET(SalesHeader."Bill-to Customer No.");
    //             IF IsCreditLimits(ApprovalTemplates) THEN
    //                 IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                     ApproverId := USERID;
    //                     MakeSalesHeaderApprovalEntry(
    //                       SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                       ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                 END ELSE
    //                     InsertEntries := TRUE;

    //             IF NOT IsCreditLimits(ApprovalTemplates) OR InsertEntries THEN BEGIN
    //                 CheckAddApprovers(ApprovalTemplates);
    //                 AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                 IF AddApproversTemp.FINDSET THEN
    //                     REPEAT
    //                         MakeSalesHeaderApprovalEntry(
    //                           SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                           AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
    //                     UNTIL AddApproversTemp.NEXT = 0
    //                 ELSE
    //                     ERROR(Text027);
    //             END;
    //         END;
    // END;

    // EXIT(TRUE);
    // end;

    /// <summary>
    /// Description for PurchaseLines.
    /// </summary>
    /// <param name="PurchaseHeader">Parameter of type Record "Purchase Header".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchaseLines(PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        PurchaseLines: Record "Purchase Line";
    begin
        WITH PurchaseLines DO BEGIN
            SETCURRENTKEY("Document Type", "Document No.");
            SETRANGE("Document Type", PurchaseHeader."Document Type");
            SETRANGE("Document No.", PurchaseHeader."No.");
            IF FINDSET THEN
                REPEAT
                    IF (Quantity <> 0) AND ("Line Amount" <> 0) THEN
                        EXIT(TRUE);
                UNTIL NEXT = 0;
        END;
        EXIT(FALSE);
    end;

    // IE Commented all this function
    /// <summary>
    /// Description for FindApproverPurchase.
    /// </summary>
    /// <param name="PurchaseHeader">Parameter of type Record "38".</param>
    /// <param name="ApprovalSetup">Parameter of type Record "452".</param>
    /// <param name="ApprovalTemplates">Parameter of type Record "464".</param>
    /// <returns>Return variable "Boolean".</returns>
    // procedure FindApproverPurchase(PurchaseHeader: Record "38"; ApprovalSetup: Record "452"; ApprovalTemplates: Record "464"): Boolean;
    // var
    //     UserSetup: Record "91";
    //     ApproverId: Code[50];
    //     ApprovalAmount: Decimal;
    //     ApprovalAmountLCY: Decimal;
    //     SufficientApprover: Boolean;
    // begin
    //     AddApproversTemp.RESET;
    //     AddApproversTemp.DELETEALL;

    //     CalcPurchaseDocAmount(PurchaseHeader, ApprovalAmount, ApprovalAmountLCY);

    //     CASE ApprovalTemplates."Approval Type" OF
    //         ApprovalTemplates."Approval Type"::"Sales Pers./Purchaser":
    //             IF PurchaseHeader."Purchaser Code" <> '' THEN
    //                 CASE ApprovalTemplates."Limit Type" OF
    //                     ApprovalTemplates."Limit Type"::"Approval Limits":
    //                         BEGIN
    //                             UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                             UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                   UserSetup."Salespers./Purch. Code");

    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
    //                               UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY);
    //                             ApproverId := UserSetup."Approver ID";
    //                             IF NOT UserSetup."Unlimited Purchase Approval" AND
    //                                ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") OR
    //                                 (UserSetup."Purchase Amount Approval Limit" = 0))
    //                             THEN BEGIN
    //                                 UserSetup.RESET;
    //                                 UserSetup.SETCURRENTKEY("User ID");
    //                                 UserSetup.SETRANGE("User ID", ApproverId);
    //                                 REPEAT
    //                                     IF NOT UserSetup.FINDFIRST THEN
    //                                         ERROR(Text006, ApproverId);
    //                                     ApproverId := UserSetup."User ID";
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                                     UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                                     SufficientApprover := UserSetup."Unlimited Purchase Approval" OR
    //                                       ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") AND
    //                                        (UserSetup."Purchase Amount Approval Limit" <> 0)) OR
    //                                       (UserSetup."User ID" = UserSetup."Approver ID")
    //                                 UNTIL SufficientApprover;
    //                             END;

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                     ApprovalTemplates."Limit Type"::"Request Limits":
    //                         BEGIN
    //                             IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote THEN
    //                                 ERROR(GetQuoteErrorText(ApprovalTemplates, PurchaseHeader));

    //                             UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                             UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                   UserSetup."Salespers./Purch. Code");
    //                             UserSetup.RESET;
    //                             UserSetup.SETRANGE("User ID", USERID);
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text005, USERID);
    //                             ApproverId := UserSetup."User ID";
    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY);

    //                             IF NOT UserSetup."Unlimited Request Approval" AND
    //                                ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") OR
    //                                 (UserSetup."Request Amount Approval Limit" = 0))
    //                             THEN
    //                                 REPEAT
    //                                     UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                                     IF NOT UserSetup.FINDFIRST THEN
    //                                         ERROR(Text005, USERID);
    //                                     ApproverId := UserSetup."User ID";
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                                     SufficientApprover := UserSetup."Unlimited Request Approval" OR
    //                                       ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") AND
    //                                        (UserSetup."Request Amount Approval Limit" <> 0)) OR
    //                                       (UserSetup."User ID" = UserSetup."Approver ID");
    //                                 UNTIL SufficientApprover;

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                     ApprovalTemplates."Limit Type"::"No Limits":
    //                         BEGIN
    //                             UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                             UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                   UserSetup."Salespers./Purch. Code");
    //                             ApproverId := UserSetup."User ID";
    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY);

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                 END;
    //         ApprovalTemplates."Approval Type"::Approver:
    //             BEGIN
    //                 UserSetup.SETRANGE("User ID", USERID);
    //                 IF NOT UserSetup.FINDFIRST THEN
    //                     ERROR(Text005, USERID);

    //                 CASE ApprovalTemplates."Limit Type" OF
    //                     ApprovalTemplates."Limit Type"::"Approval Limits":
    //                         BEGIN
    //                             ApproverId := UserSetup."User ID";
    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                             IF NOT UserSetup."Unlimited Purchase Approval" AND
    //                                ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") OR
    //                                 (UserSetup."Purchase Amount Approval Limit" = 0))
    //                             THEN
    //                                 REPEAT
    //                                     ApproverId := UserSetup."Approver ID";
    //                                     UserSetup.SETRANGE("User ID", ApproverId);
    //                                     IF NOT UserSetup.FINDFIRST THEN
    //                                         ERROR(Text005, ApproverId);
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                                     SufficientApprover := UserSetup."Unlimited Purchase Approval" OR
    //                                       ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") AND
    //                                        (UserSetup."Purchase Amount Approval Limit" <> 0)) OR
    //                                       (UserSetup."User ID" = UserSetup."Approver ID");
    //                                 UNTIL SufficientApprover;

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                     ApprovalTemplates."Limit Type"::"Request Limits":
    //                         BEGIN
    //                             IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote THEN
    //                                 ERROR(GetQuoteErrorText(ApprovalTemplates, PurchaseHeader));

    //                             UserSetup.SETRANGE("User ID", USERID);
    //                             IF NOT UserSetup.FINDFIRST THEN
    //                                 ERROR(Text005, USERID);
    //                             ApproverId := UserSetup."User ID";
    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                             IF NOT UserSetup."Unlimited Request Approval" AND
    //                                ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") OR
    //                                 (UserSetup."Request Amount Approval Limit" = 0))
    //                             THEN
    //                                 REPEAT
    //                                     ApproverId := UserSetup."Approver ID";
    //                                     UserSetup.SETRANGE("User ID", ApproverId);
    //                                     IF NOT UserSetup.FINDFIRST THEN
    //                                         ERROR(Text005, ApproverId);
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       ApproverId, ApprovalAmount, ApprovalAmountLCY);
    //                                     SufficientApprover := UserSetup."Unlimited Request Approval" OR
    //                                       ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") AND
    //                                        (UserSetup."Request Amount Approval Limit" <> 0)) OR
    //                                       (UserSetup."User ID" = UserSetup."Approver ID");
    //                                 UNTIL SufficientApprover;

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                     ApprovalTemplates."Limit Type"::"No Limits":
    //                         BEGIN
    //                             ApproverId := UserSetup."Approver ID";
    //                             IF ApproverId = '' THEN
    //                                 ApproverId := UserSetup."User ID";
    //                             MakePurchHeaderApprovalEntry(
    //                               PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
    //                               ApproverId, ApprovalAmount, ApprovalAmountLCY);

    //                             CheckAddApprovers(ApprovalTemplates);
    //                             AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                             IF AddApproversTemp.FINDSET THEN
    //                                 REPEAT
    //                                     MakePurchHeaderApprovalEntry(
    //                                       PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                                       AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;
    //                 END;
    //             END;
    //         ApprovalTemplates."Approval Type"::" ":
    //             BEGIN
    //                 CheckAddApprovers(ApprovalTemplates);
    //                 AddApproversTemp.SETCURRENTKEY("Sequence No.");
    //                 IF AddApproversTemp.FINDSET THEN
    //                     REPEAT
    //                         MakePurchHeaderApprovalEntry(
    //                           PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
    //                           AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
    //                     UNTIL AddApproversTemp.NEXT = 0
    //                 ELSE
    //                     ERROR(Text027);
    //             END;
    //     END;

    //     EXIT(TRUE);
    // end;


    // IE commented all this function
    // local procedure MakeSalesHeaderApprovalEntry(SalesHeader: Record "36"; ApprovalSetup: Record "452"; UserSetup: Record "91"; ApprovalTemplates: Record "464"; SalespersonPurchaser: Code[10]; ApproverId: Code[50]; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; ExceedAmountLCY: Decimal);
    // begin
    //     MakeApprovalEntry(
    //       DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.",
    //       SalespersonPurchaser, ApprovalSetup, ApproverId, UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //       SalesHeader."Currency Code", ApprovalTemplates, ExceedAmountLCY);
    // end;



    // IE commented all this function
    // local procedure MakePurchHeaderApprovalEntry(PurchHeader: Record "38"; ApprovalSetup: Record "452"; UserSetup: Record "91"; ApprovalTemplates: Record "464"; SalespersonPurchaser: Code[10]; ApproverId: Code[50]; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal);
    // begin
    //     MakeApprovalEntry(
    //       DATABASE::"Purchase Header", PurchHeader."Document Type", PurchHeader."No.",
    //       SalespersonPurchaser, ApprovalSetup, ApproverId, UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //       PurchHeader."Currency Code", ApprovalTemplates, 0);
    // end;

    // IE commented all this function
    // procedure MakeApprovalEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "452"; ApproverId: Code[50]; UserSetup: Record "91"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; ApprovalTemplates: Record "464"; ExeedAmountLCY: Decimal);
    // var
    //     ApprovalEntry: Record "454";
    //     NewSequenceNo: Integer;
    // begin
    //     WITH ApprovalEntry DO BEGIN
    //         SETRANGE("Table ID", TableID);
    //         SETRANGE("Document Type", DocType);
    //         SETRANGE("Document No.", DocNo);
    //         IF FINDLAST THEN
    //             NewSequenceNo := "Sequence No." + 1
    //         ELSE
    //             NewSequenceNo := 1;
    //         "Table ID" := TableID;
    //         "Document Type" := DocType;
    //         "Document No." := DocNo;
    //         "Salespers./Purch. Code" := SalespersonPurchaser;
    //         "Sequence No." := NewSequenceNo;
    //         "Approval Code" := ApprovalTemplates."Approval Code";
    //         "Sender ID" := USERID;
    //         Amount := ApprovalAmount;
    //         "Amount (LCY)" := ApprovalAmountLCY;
    //         "Currency Code" := CurrencyCode;
    //         "Approver ID" := ApproverId;
    //         IF ApproverId = USERID THEN
    //             Status := Status::Approved
    //         ELSE
    //             Status := Status::Created;
    //         "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //         "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         "Last Modified By ID" := USERID;
    //         "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
    //         "Approval Type" := ApprovalTemplates."Approval Type";
    //         "Limit Type" := ApprovalTemplates."Limit Type";
    //         "Available Credit Limit (LCY)" := ExeedAmountLCY;
    //         INSERT;
    //     END;
    // end;

    // IE commented all this function
    // procedure ApproveApprovalRequest(ApprovalEntry: Record "454"): Boolean;
    // var
    //     SalesHeader: Record "36";
    //     PurchaseHeader: Record "38";
    //     ApprovalSetup: Record "452";
    //     NextApprovalEntry: Record "454";
    //     ReleaseSalesDoc: Codeunit "414";
    //     ReleasePurchaseDoc: Codeunit "415";
    //     ApprovalMgtNotification: Codeunit "440";
    //     GenJournal: Record "81";
    //     ApprovedPmt: Record "81";
    //     NewApprovedPayments: Record "81";
    //     GetLastLineNo: Record "81";
    //     RemoveGenJnls: Record "81";
    //     GenJournal1: Record "81";
    // begin
    //     GenLedgSetUp.GET;
    //     GenLedgSetUp.TESTFIELD("Approved Payments Batch");
    //     GenLedgSetUp.TESTFIELD(GenLedgSetUp."Approved Payments Template");

    //     IF ApprovalEntry."Table ID" <> 0 THEN BEGIN
    //         ApprovalEntry.Status := ApprovalEntry.Status::Approved;
    //         ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         ApprovalEntry."Last Modified By ID" := USERID;
    //         ApprovalEntry.MODIFY;
    //         NextApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
    //         NextApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
    //         NextApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //         NextApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
    //         NextApprovalEntry.SETFILTER(Status, '%1|%2', NextApprovalEntry.Status::Created, NextApprovalEntry.Status::Open);
    //         IF NextApprovalEntry.FINDFIRST THEN BEGIN
    //             IF NextApprovalEntry.Status = NextApprovalEntry.Status::Open THEN
    //                 EXIT(FALSE);

    //             NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
    //             NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Modified By ID" := USERID;
    //             NextApprovalEntry.MODIFY;
    //             IF ApprovalSetup.GET THEN
    //                 IF ApprovalSetup.Approvals THEN BEGIN
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //                         IF SalesHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendSalesApprovalsMail(SalesHeader, NextApprovalEntry);
    //                     END ELSE BEGIN
    //                         IF PurchaseHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendPurchaseApprovalsMail(PurchaseHeader, NextApprovalEntry);
    //                     END;
    //                     /*
    //                     //BKM 040716 - begin
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //                       GenJournal1.SETFILTER("Journal Template Name", NextApprovalEntry."Journal Template Name");
    //                       GenJournal1.SETFILTER("Journal Batch Name", NextApprovalEntry."Journal Batch Name");
    //                       GenJournal1.SETFILTER("Document No.", NextApprovalEntry."Document No.");
    //                       IF GenJournal1.FINDFIRST THEN
    //                         ApprovalMgtNotification.SendPaymentApprovalsMail(GenJournal1 , NextApprovalEntry);
    //                     END;
    //                     //BKM 040716 - end
    //                     */
    //                 END;
    //             EXIT(FALSE);
    //         END;
    //         IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //             IF SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleaseSalesDoc.RUN(SalesHeader);
    //         END ELSE
    //             IF PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleasePurchaseDoc.RUN(PurchaseHeader);

    //         // JCK Payment Journal Approval
    //         IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //             IF GenJournal.FINDFIRST THEN
    //                 REPEAT
    //                     GenJournal.Status := GenJournal.Status::Approved;
    //                     GenJournal.MODIFY;
    //                 UNTIL GenJournal.NEXT = 0;

    //             // Move all approved Entries to a Payments batch
    //             ApprovedPmt.SETRANGE(ApprovedPmt."Journal Template Name", 'GENERAL');
    //             ApprovedPmt.SETRANGE(ApprovedPmt."Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             ApprovedPmt.SETRANGE(ApprovedPmt.Status, ApprovedPmt.Status::Approved);
    //             //PmtCode := ApprovalEntry."Bank Batch Number";

    //             NewLineNo := 10000;

    //             GetLastLineNo.SETRANGE(GetLastLineNo."Journal Template Name", GenLedgSetUp."Approved Payments Template");
    //             GetLastLineNo.SETRANGE(GetLastLineNo."Journal Batch Name", GenLedgSetUp."Approved Payments Batch");
    //             IF GetLastLineNo.FINDLAST THEN
    //                 NewLineNo := GetLastLineNo."Line No.";

    //             IF ApprovedPmt.FINDSET THEN
    //                 REPEAT
    //                     NewApprovedPayments."Journal Template Name" := GenLedgSetUp."Approved Payments Template";
    //                     NewApprovedPayments."Journal Batch Name" := GenLedgSetUp."Approved Payments Batch";
    //                     NewLineNo := NewLineNo + 20000;
    //                     NewApprovedPayments."Line No." := NewLineNo;
    //                     NewApprovedPayments."Account Type" := ApprovedPmt."Account Type";
    //                     NewApprovedPayments."Account No." := ApprovedPmt."Account No.";
    //                     NewApprovedPayments."Posting Date" := ApprovedPmt."Posting Date";
    //                     NewApprovedPayments."Document Type" := ApprovedPmt."Document Type";
    //                     NewApprovedPayments."Document No." := ApprovedPmt."Document No.";
    //                     NewApprovedPayments."Bank Batch No." := PmtCode;
    //                     NewDescription := PmtCode + '-' + ApprovedPmt.Description;
    //                     IF STRLEN(NewDescription) > 50 THEN
    //                         NewDescription := COPYSTR((PmtCode + '-' + ApprovedPmt.Description), 1, 50);
    //                     NewApprovedPayments.Description := NewDescription;
    //                     NewApprovedPayments."VAT %" := ApprovedPmt."VAT %";
    //                     NewApprovedPayments."Bal. Account No." := ApprovedPmt."Bal. Account No.";
    //                     NewApprovedPayments.VALIDATE(NewApprovedPayments."Currency Code", ApprovedPmt."Currency Code");
    //                     NewApprovedPayments.VALIDATE(NewApprovedPayments.Amount, ApprovedPmt.Amount);
    //                     NewApprovedPayments."Posting Group" := ApprovedPmt."Posting Group";
    //                     NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 1 Code", ApprovedPmt."Shortcut Dimension 1 Code");
    //                     NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 2 Code", ApprovedPmt."Shortcut Dimension 2 Code");
    //                     NewApprovedPayments."Applies-to Doc. Type" := ApprovedPmt."Applies-to Doc. Type";
    //                     NewApprovedPayments."Applies-to Doc. No." := ApprovedPmt."Applies-to Doc. No.";
    //                     NewApprovedPayments."Gen. Posting Type" := ApprovedPmt."Gen. Posting Type";
    //                     NewApprovedPayments."Gen. Bus. Posting Group" := ApprovedPmt."Gen. Bus. Posting Group";
    //                     NewApprovedPayments."Gen. Prod. Posting Group" := ApprovedPmt."Gen. Prod. Posting Group";
    //                     NewApprovedPayments."Document Date" := ApprovedPmt."Document Date";
    //                     NewApprovedPayments."Bal. Account Type" := ApprovedPmt."Bal. Account Type";
    //                     NewApprovedPayments."Cashier ID" := ApprovedPmt."Cashier ID";
    //                     NewApprovedPayments."Advance Code" := ApprovedPmt."Advance Code";
    //                     NewApprovedPayments."Payment Type" := ApprovedPmt."Payment Type";
    //                     NewApprovedPayments."Revenue Stream" := ApprovedPmt."Revenue Stream";
    //                     NewApprovedPayments.Status := ApprovedPmt.Status;
    //                     NewApprovedPayments."Bank Account No." := ApprovedPmt."Bank Account No.";
    //                     NewApprovedPayments."Bank Name" := ApprovedPmt."Bank Name";
    //                     NewApprovedPayments."Vendor Bank Code" := ApprovedPmt."Vendor Bank Code";
    //                     NewApprovedPayments."Bank Code" := ApprovedPmt."Bank Code";
    //                     NewApprovedPayments."Branch Code" := ApprovedPmt."Branch Code";
    //                     NewApprovedPayments.INSERT;
    //                 UNTIL ApprovedPmt.NEXT = 0;
    //             // Move All approved entries to a payments batch

    //             // Delete Journal entries from requisitioning batch
    //             RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Template Name", 'GENERAL');
    //             RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             RemoveGenJnls.SETRANGE(RemoveGenJnls.Status, ApprovedPmt.Status::Approved);
    //             IF RemoveGenJnls.FINDSET THEN
    //                 REPEAT
    //                     RemoveGenJnls.DELETE;
    //                 UNTIL RemoveGenJnls.NEXT = 0;
    //             // Delete Journal entries from requisitioning batch
    //         END;

    //         EXIT(TRUE);
    //     END;

    // end;

    /// <summary>
    /// Description for RejectApprovalRequest.
    /// </summary>
    /// <param name="ApprovalEntry">Parameter of type Record "454".</param>


    // IE commented all this function
    // procedure RejectApprovalRequest(ApprovalEntry: Record "454") Rejected: Boolean;
    // var
    //     ApprovalSetup: Record "452";
    //     SalesHeader: Record "36";
    //     PurchaseHeader: Record "38";
    //     ReleaseSalesDoc: Codeunit "414";
    //     ReleasePurchaseDoc: Codeunit "415";
    //     AppManagement: Codeunit "440";
    //     SendMail: Boolean;
    //     GenJournal: Record "81";
    //     MailSent: Boolean;
    // begin
    //     ApprovalSetup.GET;
    //     CLEAR(Sender);
    //     CLEAR(Receipient);
    //     /*
    //     IF ApprovalEntry."Table ID" <> 0 THEN BEGIN

    //       ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
    //       ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY,TIME);
    //       ApprovalEntry."Last Modified By ID" := USERID;
    //       ApprovalEntry.MODIFY;
    //     */
    //     //IF ApprovalSetup.Rejections THEN
    //     //SendRejectionMail(ApprovalEntry,AppManagement);
    //     ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
    //     ApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
    //     ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //     ApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
    //     ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
    //     IF ApprovalEntry.FIND('-') THEN
    //         REPEAT
    //             SendMail := FALSE;
    //             IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
    //             THEN
    //                 SendMail := TRUE;

    //             ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
    //             ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //             ApprovalEntry."Last Modified By ID" := USERID;
    //             ApprovalEntry.MODIFY;
    //         //IF ApprovalSetup.Rejections AND SendMail THEN
    //         //SendRejectionMail(ApprovalEntry,AppManagement);

    //         /*IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //            GenJournal.SETFILTER("Document Type", FORMAT(GenJournal."Document Type"::" "));
    //            GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //            GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //            GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //            IF GenJournal.FINDFIRST THEN
    //               REPEAT
    //                 GenJournal.Status:= GenJournal.Status::Open;
    //                 GenJournal.MODIFY;
    //               UNTIL GenJournal.NEXT=0;
    //         END; */

    //         UNTIL ApprovalEntry.NEXT = 0;

    //     IF NOT ApprovalEntry.JV THEN BEGIN
    //         IF ApprovalSetup.Rejections AND (MailSent = FALSE) THEN BEGIN
    //             SendRejectionMail(ApprovalEntry, AppManagement);
    //             AppManagement.SendMail;
    //             MailSent := TRUE;
    //         END;
    //     END;

    //     IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //         SalesHeader.SETCURRENTKEY("Document Type", "No.");
    //         SalesHeader.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //         SalesHeader.SETRANGE("No.", ApprovalEntry."Document No.");
    //         IF SalesHeader.FINDFIRST THEN
    //             ReleaseSalesDoc.Reopen(SalesHeader);
    //     END ELSE BEGIN
    //         PurchaseHeader.SETCURRENTKEY("Document Type", "No.");
    //         PurchaseHeader.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //         PurchaseHeader.SETRANGE("No.", ApprovalEntry."Document No.");
    //         IF PurchaseHeader.FINDFIRST THEN
    //             ReleasePurchaseDoc.Reopen(PurchaseHeader);

    //         //Journal Approval only for Payments and purchase line items.
    //         IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //             GenJournal.SETFILTER("Document Type", FORMAT(GenJournal."Document Type"::Payment));
    //             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //             IF GenJournal.FINDFIRST THEN
    //                 REPEAT
    //                     GenJournal.Status := GenJournal.Status::Open;
    //                     GenJournal.MODIFY;
    //                 UNTIL GenJournal.NEXT = 0;
    //         END;
    //         // JCK IF DOC TYPE'S BLANK
    //         IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //             GenJournal.SETFILTER("Document Type", FORMAT(GenJournal."Document Type"::" "));
    //             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //             IF GenJournal.FINDFIRST THEN
    //                 REPEAT
    //                     GenJournal.Status := GenJournal.Status::Open;
    //                     GenJournal.MODIFY;
    //                 UNTIL GenJournal.NEXT = 0;
    //             Rejected := TRUE;
    //         END;
    //     END;
    //     /*END;*/

    // end;

    // IE commented all this function
    // procedure DelegateApprovalRequest(ApprovalEntry: Record "454");
    // var
    //     UserSetup: Record "91";
    //     ApprovalSetup: Record "452";
    //     SalesHeader: Record "36";
    //     PurchaseHeader: Record "38";
    //     AppManagement: Codeunit "440";
    //     GenJournal: Record "81";
    // begin
    //     UserSetup.SETRANGE("User ID", ApprovalEntry."Approver ID");
    //     IF NOT UserSetup.FINDFIRST THEN
    //         ERROR(Text005, ApprovalEntry."Approver ID");
    //     IF NOT ApprovalSetup.GET THEN
    //         ERROR(Text004);

    //     IF UserSetup.Substitute <> '' THEN BEGIN
    //         UserSetup.SETRANGE("User ID", UserSetup.Substitute);
    //         IF UserSetup.FINDFIRST THEN BEGIN
    //             ApprovalEntry."Last Modified By ID" := USERID;
    //             ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //             ApprovalEntry."Approver ID" := UserSetup."User ID";
    //             ApprovalEntry.MODIFY;

    //             CASE ApprovalEntry."Table ID" OF
    //                 DATABASE::"Sales Header":
    //                     BEGIN
    //                         IF ApprovalSetup.Delegations THEN
    //                             IF SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                                 AppManagement.SendSalesDelegationsMail(SalesHeader, ApprovalEntry);
    //                     END;
    //                 DATABASE::"Purchase Header":
    //                     BEGIN
    //                         IF ApprovalSetup.Delegations THEN
    //                             IF PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                                 AppManagement.SendPurchaseDelegationsMail(PurchaseHeader, ApprovalEntry);
    //                     END;
    //                 // JCK Journal Approval for Payments
    //                 81:
    //                     BEGIN
    //                         IF ApprovalSetup.Delegations THEN
    //                             GenJournal.SETFILTER("Document Type", FORMAT(GenJournal."Document Type"::Payment));
    //                         GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //                         GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //                         GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //                         IF GenJournal.FINDFIRST THEN
    //                             AppManagement.SendPaymentDelegationsMail(GenJournal, ApprovalEntry);
    //                     END;
    //                 //JCK Doc type blank
    //                 81:
    //                     BEGIN
    //                         IF ApprovalSetup.Delegations THEN BEGIN
    //                             GenJournal.SETFILTER("Document Type", FORMAT(GenJournal."Document Type"::" "));
    //                             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //                             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //                             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //                             IF GenJournal.FINDFIRST THEN;
    //                             AppManagement.SendPaymentDelegationsMail(GenJournal, ApprovalEntry);
    //                         END;
    //                     END;
    //             END;
    //         END;
    //     END ELSE
    //         ERROR(Text007, UserSetup.FIELDCAPTION(Substitute), UserSetup."User ID");
    // end;


    // // IE commented all this function
    //     procedure PrePostApprovalCheck(var SalesHeader: Record "36"; var PurchaseHeader: Record "38"): Boolean;
    //     begin
    //         IF SalesHeader."No." <> '' THEN
    //             EXIT(PrePostApprovalCheckSales(SalesHeader));
    //         EXIT(PrePostApprovalCheckPurch(PurchaseHeader));
    //     end;

    //     procedure PrePostApprovalCheckSales(var SalesHeader: Record "36"): Boolean;
    //     begin
    //         IF NOT CheckApprSalesDocument(SalesHeader) THEN
    //             EXIT(TRUE);
    //         IF NOT (SalesHeader.Status IN [SalesHeader.Status::Released, SalesHeader.Status::"Pending Prepayment"]) THEN
    //             ERROR(Text013, SalesHeader."Document Type", SalesHeader."No.");
    //         EXIT(TRUE);
    //     end;

    //     procedure PrePostApprovalCheckPurch(var PurchaseHeader: Record "38"): Boolean;
    //     begin
    //         IF NOT CheckApprPurchaseDocument(PurchaseHeader) THEN
    //             EXIT(TRUE);
    //         IF NOT (PurchaseHeader.Status IN [PurchaseHeader.Status::Released, PurchaseHeader.Status::"Pending Prepayment"]) THEN
    //             ERROR(Text013, PurchaseHeader."Document Type", PurchaseHeader."No.");
    //         EXIT(TRUE);
    //     end;

    //     procedure MoveApprvalEntryToPosted(var ApprovalEntry: Record "454"; ToTableId: Integer; ToNo: Code[20]);
    //     var
    //         PostedApprvlEntry: Record "456";
    //         ApprovalCommentLine: Record "455";
    //         PostedApprovalCommentLine: Record "457";
    //     begin
    //         WITH ApprovalEntry DO BEGIN
    //             IF FIND('-') THEN
    //                 REPEAT
    //                     PostedApprvlEntry.INIT;
    //                     PostedApprvlEntry.TRANSFERFIELDS(ApprovalEntry);
    //                     PostedApprvlEntry."Table ID" := ToTableId;
    //                     PostedApprvlEntry."Document No." := ToNo;
    //                     PostedApprvlEntry.INSERT;
    //                 UNTIL NEXT = 0;
    //             ApprovalCommentLine.SETRANGE("Table ID", "Table ID");
    //             ApprovalCommentLine.SETRANGE("Document Type", "Document Type");
    //             ApprovalCommentLine.SETRANGE("Document No.", "Document No.");
    //             IF ApprovalCommentLine.FIND('-') THEN
    //                 REPEAT
    //                     PostedApprovalCommentLine.INIT;
    //                     PostedApprovalCommentLine.TRANSFERFIELDS(ApprovalCommentLine);
    //                     PostedApprovalCommentLine."Entry No." := 0;
    //                     PostedApprovalCommentLine."Table ID" := ToTableId;
    //                     PostedApprovalCommentLine."Document No." := ToNo;
    //                     PostedApprovalCommentLine.INSERT(TRUE);
    //                 UNTIL ApprovalCommentLine.NEXT = 0;
    //         END;
    //     end;

    //     procedure DeleteApprovalEntry(TableId: Integer; DocumentType: Option; DocumentNo: Code[20]);
    //     var
    //         ApprovalEntry: Record "454";
    //     begin
    //         ApprovalEntry.SETRANGE("Table ID", TableId);
    //         ApprovalEntry.SETRANGE("Document Type", DocumentType);
    //         ApprovalEntry.SETRANGE("Document No.", DocumentNo);
    //         DeleteApprovalCommentLine(TableId, DocumentType, DocumentNo);
    //         IF ApprovalEntry.FINDFIRST THEN
    //             ApprovalEntry.DELETEALL;
    //     end;

    //     procedure DeleteApprovalCommentLine(TableId: Integer; DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]);
    //     var
    //         ApprovalCommentLine: Record "455";
    //     begin
    //         ApprovalCommentLine.SETRANGE("Table ID", TableId);
    //         ApprovalCommentLine.SETRANGE("Document Type", DocumentType);
    //         ApprovalCommentLine.SETRANGE("Document No.", DocumentNo);
    //         IF ApprovalCommentLine.FINDFIRST THEN
    //             ApprovalCommentLine.DELETEALL;
    //     end;

    //     procedure DeletePostedApprovalEntry(TableId: Integer; DocumentNo: Code[20]);
    //     var
    //         PostedApprovalEntry: Record "456";
    //     begin
    //         PostedApprovalEntry.SETRANGE("Table ID", TableId);
    //         PostedApprovalEntry.SETRANGE("Document No.", DocumentNo);
    //         DeletePostedApprvlCommentLine(TableId, DocumentNo);
    //         IF PostedApprovalEntry.FINDFIRST THEN
    //             PostedApprovalEntry.DELETEALL;
    //     end;

    //     procedure DeletePostedApprvlCommentLine(TableId: Integer; DocumentNo: Code[20]);
    //     var
    //         PostedApprovalCommentLine: Record "457";
    //     begin
    //         PostedApprovalCommentLine.SETRANGE("Entry No.", TableId);
    //         PostedApprovalCommentLine.SETRANGE("Document No.", DocumentNo);
    //         IF PostedApprovalCommentLine.FINDFIRST THEN
    //             PostedApprovalCommentLine.DELETEALL;
    //     end;

    //     procedure DisableSalesApproval(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order");
    //     var
    //         SalesHeader: Record "36";
    //     begin
    //         SalesHeader.RESET;
    //         WITH SalesHeader DO BEGIN
    //             IF FIND('-') THEN
    //                 REPEAT
    //                     CancelSalesApprovalRequest(SalesHeader, FALSE, FALSE);
    //                 UNTIL NEXT = 0;
    //         END;
    //         MESSAGE(Text014, SELECTSTR(1 + DocType, Text028));
    //     end;

    //     procedure DisablePurchaseApproval(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order");
    //     var
    //         PurchaseHeader: Record "38";
    //     begin
    //         PurchaseHeader.RESET;
    //         WITH PurchaseHeader DO BEGIN
    //             SETRANGE("Document Type", DocType);
    //             REPEAT
    //                 CancelPurchaseApprovalRequest(PurchaseHeader, FALSE, FALSE);
    //             UNTIL NEXT = 0;
    //         END;
    //         MESSAGE(Text014, SELECTSTR(1 + DocType, Text028));
    //     end;

    //     procedure CalcSalesDocAmount(SalesHeader: Record "36"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    //     var
    //         TempSalesLine: Record "37" temporary;
    //         TotalSalesLine: Record "37";
    //         TotalSalesLineLCY: Record "37";
    //         SalesPost: Codeunit "80";
    //         TempAmount: array[5] of Decimal;
    //         VAtText: Text[30];
    //     begin
    //         SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
    //         CLEAR(SalesPost);
    //         SalesPost.SumSalesLinesTemp(
    //           SalesHeader, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
    //           TempAmount[1], VAtText, TempAmount[2], TempAmount[3], TempAmount[4]);
    //         ApprovalAmount := TotalSalesLine.Amount;
    //         ApprovalAmountLCY := TotalSalesLineLCY.Amount;
    //     end;

    //     procedure CalcPurchaseDocAmount(PurchaseHeader: Record "38"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    //     var
    //         TempPurchaseLine: Record "39" temporary;
    //         TotalPurchaseLine: Record "39";
    //         TotalPurchaseLineLCY: Record "39";
    //         PurchasePost: Codeunit "90";
    //         TempAmount: Decimal;
    //         VAtText: Text[30];
    //     begin
    //         PurchasePost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 0);
    //         CLEAR(PurchasePost);
    //         PurchasePost.SumPurchLinesTemp(
    //           PurchaseHeader, TempPurchaseLine, 0, TotalPurchaseLine, TotalPurchaseLineLCY,
    //           TempAmount, VAtText);
    //         ApprovalAmount := TotalPurchaseLine.Amount;
    //         ApprovalAmountLCY := TotalPurchaseLineLCY.Amount;
    //     end;

    //     procedure InsertAddApprovers(AppTemplate: Record "464");
    //     var
    //         AddApprovers: Record "465";
    //     begin
    //         CLEAR(AddApproversTemp);
    //         AddApprovers.SETCURRENTKEY("Sequence No.");
    //         AddApprovers.SETRANGE("Approval Code", AppTemplate."Approval Code");
    //         AddApprovers.SETRANGE("Approval Type", AppTemplate."Approval Type");
    //         AddApprovers.SETRANGE("Document Type", AppTemplate."Document Type");
    //         AddApprovers.SETRANGE("Limit Type", AppTemplate."Limit Type");
    //         IF AddApprovers.FIND('-') THEN
    //             REPEAT
    //                 AddApproversTemp := AddApprovers;
    //                 AddApproversTemp.INSERT;
    //             UNTIL AddApprovers.NEXT = 0;
    //     end;

    //     procedure CheckCreditLimit(SalesHeader: Record "36"): Decimal;
    //     var
    //         Customer: Record "18";
    //     begin
    //         IF NOT Customer.GET(SalesHeader."Bill-to Customer No.") THEN
    //             EXIT(0);
    //         EXIT(Customer.CalcAvailableCredit);
    //     end;

    //     procedure CheckAddApprovers(AppTemplate: Record "464");
    //     begin
    //         AppTemplate.CALCFIELDS("Additional Approvers");
    //         IF AppTemplate."Additional Approvers" THEN
    //             InsertAddApprovers(AppTemplate);
    //     end;

    //     procedure SetupDefualtApprovals();
    //     var
    //         ApprovalCode: Record "453";
    //         ApprovalTemplate: Record "464";
    //         "Object": Record "2000000001";
    //     begin
    //         IF NOT ApprovalCode.FIND('-') THEN BEGIN
    //             Object.SETRANGE(Type, Object.Type::Table);
    //             Object.SETRANGE(ID, DATABASE::"Sales Header");
    //             IF Object.FINDFIRST THEN;
    //             InsertDefaultApprovalCode(ApprovalCode, Text100, Text101, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text102, Text103, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text104, Text105, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text106, Text107, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text108, Text109, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text110, Text111, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text124, Text125, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text126, Text127, Object.ID, Object.Name);

    //             Object.SETRANGE(ID, DATABASE::"Purchase Header");
    //             IF Object.FINDFIRST THEN;
    //             InsertDefaultApprovalCode(ApprovalCode, Text112, Text113, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text114, Text115, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text116, Text117, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text118, Text119, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text120, Text121, Object.ID, Object.Name);
    //             InsertDefaultApprovalCode(ApprovalCode, Text122, Text123, Object.ID, Object.Name);
    //         END;

    //         IF NOT ApprovalTemplate.FINDFIRST AND ApprovalCode.FIND('-') THEN
    //             REPEAT
    //                 InsertDefaultApprovalTemplate(ApprovalTemplate, ApprovalCode);
    //             UNTIL ApprovalCode.NEXT = 0;
    //     end;

    //     procedure InsertDefaultApprovalCode(var ApprovalCodeRec: Record "453"; ApprovalCode: Code[20]; ApprovalName: Text[100]; TableId: Integer; Tablename: Text[50]);
    //     begin
    //         ApprovalCodeRec.INIT;
    //         ApprovalCodeRec.Code := ApprovalCode;
    //         ApprovalCodeRec.Description := ApprovalName;
    //         ApprovalCodeRec."Linked To Table Name" := Tablename;
    //         ApprovalCodeRec."Linked To Table No." := TableId;
    //         ApprovalCodeRec.INSERT;
    //     end;

    //     procedure InsertDefaultApprovalTemplate(var ApprovalTemplate: Record "464"; ApprovalCode: Record "453");
    //     begin
    //         CASE TRUE OF
    //             ApprovalCode.Code = Text100:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::" ";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text102:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Quote;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Approval Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text104:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text106:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Invoice;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text108:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Blanket Order";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text110:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Credit Memo";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text112:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::Approver;
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::" ";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Request Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text114:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Quote;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Approval Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text116:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text118:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Invoice;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text120:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Blanket Order";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text122:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Credit Memo";
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text124:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Quote;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Credit Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //             ApprovalCode.Code = Text126:
    //                 BEGIN
    //                     ApprovalTemplate.INIT;
    //                     ApprovalTemplate."Approval Code" := ApprovalCode.Code;
    //                     ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
    //                     ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
    //                     ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Credit Limits";
    //                     ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
    //                     ApprovalTemplate.INSERT;
    //                 END;
    //         END;
    //     end;

    //     procedure TestSalesPrepayment(SalesHeader: Record "36"): Boolean;
    //     var
    //         SalesLines: Record "37";
    //     begin
    //         SalesLines.SETRANGE("Document Type", SalesHeader."Document Type");
    //         SalesLines.SETRANGE("Document No.", SalesHeader."No.");
    //         SalesLines.SETFILTER("Prepmt. Line Amount", '<>%1', 0);
    //         IF SalesLines.FIND('-') THEN
    //             REPEAT
    //                 IF SalesLines."Prepmt. Amt. Inv." <> SalesLines."Prepmt. Line Amount" THEN
    //                     EXIT(TRUE);
    //             UNTIL SalesLines.NEXT = 0;
    //     end;

    //     procedure TestPurchasePrepayment(PurchaseHeader: Record "38"): Boolean;
    //     var
    //         PurchaseLines: Record "39";
    //     begin
    //         PurchaseLines.SETRANGE("Document Type", PurchaseHeader."Document Type");
    //         PurchaseLines.SETRANGE("Document No.", PurchaseHeader."No.");
    //         PurchaseLines.SETFILTER("Prepmt. Line Amount", '<>%1', 0);
    //         IF PurchaseLines.FIND('-') THEN
    //             REPEAT
    //                 IF PurchaseLines."Prepmt. Amt. Inv." <> PurchaseLines."Prepmt. Line Amount" THEN
    //                     EXIT(TRUE);
    //             UNTIL PurchaseLines.NEXT = 0;
    //     end;

    //     procedure TestSetup();
    //     var
    //         ApprovalSetup: Record "452";
    //     begin
    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);
    //     end;

    //     procedure TestSalesPayment(SalesHeader: Record "36"): Boolean;
    //     var
    //         SalesSetup: Record "311";
    //         CustLedgerEntry: Record "21";
    //         SalesInvHeader: Record "112";
    //         EntryFound: Boolean;
    //     begin
    //         EntryFound := FALSE;
    //         SalesSetup.GET;
    //         IF SalesSetup."Check Prepmt. when Posting" THEN BEGIN
    //             SalesInvHeader.SETCURRENTKEY("Prepayment Order No.", "Prepayment Invoice");
    //             SalesInvHeader.SETRANGE("Prepayment Order No.", SalesHeader."No.");
    //             SalesInvHeader.SETRANGE("Prepayment Invoice", TRUE);
    //             IF SalesInvHeader.FIND('-') THEN
    //                 REPEAT
    //                     CustLedgerEntry.SETCURRENTKEY("Document No.");
    //                     CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
    //                     CustLedgerEntry.SETRANGE("Document No.", SalesInvHeader."No.");
    //                     CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>%1', 0);
    //                     IF CustLedgerEntry.FINDFIRST THEN
    //                         EntryFound := TRUE;
    //                 UNTIL (SalesInvHeader.NEXT = 0) OR EntryFound;
    //         END;
    //         IF EntryFound THEN
    //             EXIT(TRUE);

    //         EXIT(FALSE);
    //     end;

    //     procedure TestPurchasePayment(PurchaseHeader: Record "38"): Boolean;
    //     var
    //         PurchaseSetup: Record "312";
    //         VendLedgerEntry: Record "25";
    //         PurchaseInvHeader: Record "122";
    //         EntryFound: Boolean;
    //     begin
    //         EntryFound := FALSE;
    //         PurchaseSetup.GET;
    //         IF PurchaseSetup."Check Prepmt. when Posting" THEN BEGIN
    //             PurchaseInvHeader.SETCURRENTKEY("Prepayment Order No.", "Prepayment Invoice");
    //             PurchaseInvHeader.SETRANGE("Prepayment Order No.", PurchaseHeader."No.");
    //             PurchaseInvHeader.SETRANGE("Prepayment Invoice", TRUE);
    //             IF PurchaseInvHeader.FIND('-') THEN
    //                 REPEAT
    //                     VendLedgerEntry.SETCURRENTKEY("Document No.");
    //                     VendLedgerEntry.SETRANGE("Document Type", VendLedgerEntry."Document Type"::Invoice);
    //                     VendLedgerEntry.SETRANGE("Document No.", PurchaseInvHeader."No.");
    //                     VendLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>%1', 0);
    //                     IF VendLedgerEntry.FINDFIRST THEN
    //                         EntryFound := TRUE;
    //                 UNTIL (PurchaseInvHeader.NEXT = 0) OR EntryFound;
    //         END;
    //         IF EntryFound THEN
    //             EXIT(TRUE);

    //         EXIT(FALSE);
    //     end;

    //     procedure SendRejectionMail(ApprovalEntry: Record "454"; AppManagement: Codeunit "440");
    //     var
    //         SalesHeader: Record "36";
    //         PurchaseHeader: Record "38";
    //         GenJournalLine: Record "81";
    //     begin
    //         CASE ApprovalEntry."Table ID" OF
    //             DATABASE::"Sales Header":
    //                 BEGIN
    //                     IF SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                         AppManagement.SendSalesRejectionsMail(SalesHeader, ApprovalEntry);
    //                 END;
    //             DATABASE::"Purchase Header":
    //                 BEGIN
    //                     IF PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                         AppManagement.SendPurchaseRejectionsMail(PurchaseHeader, ApprovalEntry);
    //                 END;

    //             DATABASE::"Gen. Journal Line":
    //                 BEGIN
    //                     GenJournalLine.SETRANGE("Journal Template Name", ApprovalEntry."Journal Template Name");
    //                     GenJournalLine.SETRANGE("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //                     GenJournalLine.SETRANGE("Document No.", ApprovalEntry."Document No.");
    //                     IF GenJournalLine.FINDFIRST THEN
    //                         AppManagement.SendJVRejectionsMail(GenJournalLine, ApprovalEntry);
    //                 END;

    //         END;
    //     end;

    //     procedure FinishApprovalEntrySales(var SalesHeader: Record "36"; ApprovalSetup: Record "452"; var MessageID: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval);
    //     var
    //         DocReleased: Boolean;
    //         ApprovalEntry: Record "454";
    //         ApprovalsMgtNotification: Codeunit "440";
    //     begin
    //         DocReleased := FALSE;
    //         WITH ApprovalEntry DO BEGIN
    //             INIT;
    //             SETRANGE("Table ID", DATABASE::"Sales Header");
    //             SETRANGE("Document Type", SalesHeader."Document Type");
    //             SETRANGE("Document No.", SalesHeader."No.");
    //             SETRANGE(Status, Status::Created);
    //             IF FINDSET(TRUE, FALSE) THEN
    //                 REPEAT
    //                     IF "Sender ID" = "Approver ID" THEN BEGIN
    //                         Status := Status::Approved;
    //                         MODIFY;
    //                     END ELSE
    //                         IF NOT IsOpenStatusSet THEN BEGIN
    //                             Status := Status::Open;
    //                             MODIFY;
    //                             IsOpenStatusSet := TRUE;
    //                             IF ApprovalSetup.Approvals THEN
    //                                 ApprovalsMgtNotification.SendSalesApprovalsMail(SalesHeader, ApprovalEntry);
    //                         END;
    //                 UNTIL NEXT = 0;

    //             IF NOT IsOpenStatusSet THEN BEGIN
    //                 SETRANGE(Status);
    //                 FINDLAST;
    //                 DocReleased := ApproveApprovalRequest(ApprovalEntry);
    //                 IF DocReleased THEN
    //                     SalesHeader.FIND;
    //             END;

    //             IF DocReleased THEN BEGIN
    //                 IF TestSalesPrepayment(SalesHeader) AND
    //                    (SalesHeader."Document Type" = SalesHeader."Document Type"::Order)
    //                 THEN
    //                     MessageID := MessageID::AutomaticPrePayment
    //                 ELSE
    //                     MessageID := MessageID::AutomaticRelease;
    //             END ELSE BEGIN
    //                 SalesHeader.Status := SalesHeader.Status::"Pending Approval";
    //                 SalesHeader.MODIFY(TRUE);
    //                 MessageID := MessageID::RequiresApproval;
    //             END;
    //         END;
    //     end;

    //     procedure FinishApprovalEntryPurchase(var PurchHeader: Record "38"; ApprovalSetup: Record "452"; var MessageID: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval);
    //     var
    //         DocReleased: Boolean;
    //         ApprovalEntry: Record "454";
    //         ApprovalsMgtNotification: Codeunit "440";
    //     begin
    //         DocReleased := FALSE;
    //         WITH ApprovalEntry DO BEGIN
    //             INIT;
    //             SETRANGE("Table ID", DATABASE::"Purchase Header");
    //             SETRANGE("Document Type", PurchHeader."Document Type");
    //             SETRANGE("Document No.", PurchHeader."No.");
    //             SETRANGE(Status, Status::Created);
    //             IF FINDSET(TRUE, FALSE) THEN
    //                 REPEAT
    //                     IF "Sender ID" = "Approver ID" THEN BEGIN
    //                         Status := Status::Approved;
    //                         MODIFY;
    //                     END ELSE
    //                         IF NOT IsOpenStatusSet THEN BEGIN
    //                             Status := Status::Open;
    //                             MODIFY;
    //                             IsOpenStatusSet := TRUE;
    //                             IF ApprovalSetup.Approvals THEN
    //                                 ApprovalsMgtNotification.SendPurchaseApprovalsMail(PurchHeader, ApprovalEntry);
    //                         END;
    //                 UNTIL NEXT = 0;

    //             IF NOT IsOpenStatusSet THEN BEGIN
    //                 SETRANGE(Status);
    //                 FINDLAST;
    //                 DocReleased := ApproveApprovalRequest(ApprovalEntry);
    //                 IF DocReleased THEN
    //                     PurchHeader.FIND;
    //             END;

    //             IF DocReleased THEN BEGIN
    //                 IF TestPurchasePrepayment(PurchHeader) AND
    //                    (PurchHeader."Document Type" = PurchHeader."Document Type"::Order)
    //                 THEN
    //                     MessageID := MessageID::AutomaticPrePayment
    //                 ELSE
    //                     MessageID := MessageID::AutomaticRelease;
    //             END ELSE BEGIN
    //                 PurchHeader.Status := PurchHeader.Status::"Pending Approval";
    //                 PurchHeader.MODIFY(TRUE);
    //                 MessageID := MessageID::RequiresApproval;
    //             END;
    //         END;
    //     end;

    //     local procedure GetQuoteErrorText(ApprovalTemplates: Record "464"; PurchaseHeader: Record "38") ErrorText: Text;
    //     begin
    //         ErrorText :=
    //           STRSUBSTNO(
    //             Text026,
    //             FORMAT(ApprovalTemplates."Limit Type"),
    //             FORMAT(PurchaseHeader."Document Type"::Quote));
    //     end;

    //     local procedure IsCreditLimits(ApprovalTemplates: Record "464"): Boolean;
    //     begin
    //         EXIT(ApprovalTemplates."Limit Type" = ApprovalTemplates."Limit Type"::"Credit Limits")
    //     end;

    //     local procedure "============="();
    //     begin
    //     end;

    //     procedure CancelPaymentApprovalRequest(var GenJournal: Record "81"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    //     var
    //         ApprovalEntry: Record "454";
    //         ApprovalSetup: Record "452";
    //         AppManagement: Codeunit "440";
    //         SendMail: Boolean;
    //         MailCreated: Boolean;
    //         ApprovalEntry2: Record "454";
    //     begin
    //         //Journal Approval only for Payments and purchase line items.
    //         TestSetup;
    //         IF GenJournal.Status = GenJournal.Status::Open THEN
    //             EXIT;

    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         WITH GenJournal DO BEGIN

    //             ApprovalEntry2.SETRANGE("Table ID", 81);
    //             ApprovalEntry2.SETRANGE("Document Type", GenJournal."Document Type");
    //             IF GenJournal.Status <> GenJournal.Status::Open THEN  //GMT 011117
    //                 ApprovalEntry2.SETRANGE(Status, Status::Open);
    //             ApprovalEntry2.SETRANGE("Document No.", GenJournal."Document No.");

    //             /*
    //             ApprovalEntry.SETCURRENTKEY("Table ID","Document Type","Document No.","Sequence No.");
    //             ApprovalEntry.SETRANGE("Table ID",81);
    //             ApprovalEntry.SETRANGE("Document Type","Document Type");
    //             ApprovalEntry.SETRANGE("Document No.","Document No.");
    //             //ApprovalEntry.SETFILTER(Status,'<>%1&<>%2',ApprovalEntry.Status::Rejected,ApprovalEntry.Status::Canceled);
    //             ApprovalEntry.SETRANGE(Status,ApprovalEntry.Status::Open);
    //             */
    //             SendMail := FALSE;
    //             IF ApprovalEntry2.FINDFIRST THEN BEGIN
    //                 //IF ApprovalEntry.FINDFIRST THEN BEGIN
    //                 MESSAGE('Hello!!!@@@#');
    //                 REPEAT
    //                     IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                        (ApprovalEntry.Status = ApprovalEntry.Status::Approved) THEN
    //                         SendMail := TRUE;

    //                     ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
    //                     ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //                     ApprovalEntry."Last Modified By ID" := USERID;
    //                     ApprovalEntry.MODIFY;
    //                     IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                         AppManagement.SendPaymentCancellationsMail(GenJournal, ApprovalEntry);
    //                         MailCreated := TRUE;
    //                         SendMail := FALSE;
    //                     END;
    //                 UNTIL ApprovalEntry.NEXT = 0;
    //                 IF MailCreated THEN BEGIN
    //                     AppManagement.SendMail;
    //                     MailCreated := FALSE;
    //                 END;
    //             END;

    //             IF ManualCancel OR (NOT ManualCancel AND NOT (Status = Status::"4")) THEN
    //                 Status := Status::Open;
    //             MODIFY(TRUE);
    //         END;
    //         IF ShowMessage THEN
    //             MESSAGE(Text002, GenJournal."Document Type", GenJournal."Document No.");

    //     end;

    //     procedure "------"();
    //     begin
    //     end;

    // IE commented all this function
    // procedure SendBlankApprovalRequest(var GenJournal: Record "81"): Boolean;
    // var
    //     Cust: Record "18";
    //     TemplateRec: Record "464";
    //     ApprovalSetup: Record "452";
    // begin
    //     /*
    //        //Journal Approval only for Payments and purchase line items.

    //     TestSetup;
    //     WITH GenJournal DO BEGIN
    //       IF Status <> Status::Open THEN
    //         EXIT(FALSE);

    //       IF NOT ApprovalSetup.GET THEN
    //         ERROR(Text004);


    //       TemplateRec.SETCURRENTKEY("Table ID","Document Type",Enabled);
    //       TemplateRec.SETRANGE("Table ID",DATABASE::"Gen. Journal Line");
    //       TemplateRec.SETRANGE("Document Type",TemplateRec."Document Type"::Payment);
    //       TemplateRec.SETRANGE(Enabled,TRUE);
    //       IF TemplateRec.FIND('-') THEN BEGIN
    //         REPEAT
    //           IF NOT FindApproverPayment(GenJournal,ApprovalSetup,TemplateRec) THEN
    //             ERROR(Text010);
    //         UNTIL TemplateRec.NEXT = 0;
    //         IF DispMessage THEN
    //           MESSAGE(Text001,"Document Type",GenJournal."Document No.");
    //       END ELSE
    //         ERROR(STRSUBSTNO(Text129,GenJournal."Document Type"));
    //     END;
    //     */

    // end;

    // IE commented all this function
    // procedure CancelBlankApprovalRequest(var GenJournal: Record "81"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    // var
    //     ApprovalEntry: Record "454";
    //     ApprovalSetup: Record "452";
    //     AppManagement: Codeunit "440";
    //     SendMail: Boolean;
    //     MailCreated: Boolean;
    // begin
    //     //Journal Approval only for Payments and purchase line items.
    //     TestSetup;
    //     IF GenJournal.Status = GenJournal.Status::Open THEN
    //         EXIT;

    //     IF NOT ApprovalSetup.GET THEN
    //         ERROR(Text004);

    //     WITH GenJournal DO BEGIN
    //         ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
    //         ApprovalEntry.SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //         ApprovalEntry.SETRANGE("Document Type", "Document Type");
    //         ApprovalEntry.SETRANGE("Document No.", "Document No.");
    //         ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
    //         SendMail := FALSE;
    //         IF ApprovalEntry.FIND('-') THEN BEGIN
    //             REPEAT
    //                 IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                    (ApprovalEntry.Status = ApprovalEntry.Status::Approved) THEN
    //                     SendMail := TRUE;
    //                 ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
    //                 ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //                 ApprovalEntry."Last Modified By ID" := USERID;
    //                 ApprovalEntry.MODIFY;
    //                 IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                     AppManagement.SendPaymentCancellationsMail(GenJournal, ApprovalEntry);
    //                     MailCreated := TRUE;
    //                     SendMail := FALSE;
    //                 END;
    //             UNTIL ApprovalEntry.NEXT = 0;
    //             IF MailCreated THEN BEGIN
    //                 AppManagement.SendMail;
    //                 MailCreated := FALSE;
    //             END;
    //         END;

    //         IF ManualCancel OR (NOT ManualCancel AND NOT (Status = Status::"4")) THEN
    //             Status := Status::Open;
    //         MODIFY(TRUE);
    //     END;
    //     IF ShowMessage THEN
    //         MESSAGE(Text002, GenJournal."Document Type", GenJournal."Document No.");
    // end;


    // IE commented all this function
    // procedure FindBlankApproverPayment(GenJournal: Record "81"; ApprovalSetup: Record "452"; AppTemplate: Record "464"): Boolean;
    // var
    //     Cust: Record "18";
    //     UserSetup: Record "91";
    //     ApprovalEntry: Record "454";
    //     ApprovalsMgtNotification: Codeunit "440";
    //     ApproverId: Code[20];
    //     EntryApproved: Boolean;
    //     DocReleased: Boolean;
    //     ApprovalAmount: Decimal;
    //     ApprovalAmountLCY: Decimal;
    //     AboveCreditLimitAmountLCY: Decimal;
    //     InsertEntries: Boolean;
    //     MailSent: Boolean;
    //     PreviousDocNo: Code[20];
    // begin
    //     AddApproversTemp.RESET;
    //     AddApproversTemp.DELETEALL;

    //     //CalcSalesDocAmount(GenJournal,ApprovalAmount,ApprovalAmountLCY);

    //     CASE AppTemplate."Approval Type" OF
    //         AppTemplate."Approval Type"::"Sales Pers./Purchaser":
    //             BEGIN
    //                 IF GenJournal."Salespers./Purch. Code" = '' THEN
    //                     ERROR(STRSUBSTNO(Text022, GenJournal.FIELDCAPTION("Salespers./Purch. Code"),
    //                         FORMAT(GenJournal."Document Type"), GenJournal."Document No."))
    //                 ELSE BEGIN
    //                     CASE AppTemplate."Limit Type" OF
    //                         AppTemplate."Limit Type"::"Approval Limits":
    //                             BEGIN
    //                                 //              AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                                 UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                                 UserSetup.SETRANGE("Salespers./Purch. Code", GenJournal."Salespers./Purch. Code");
    //                                 IF NOT UserSetup.FIND('-') THEN
    //                                     ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                       UserSetup."Salespers./Purch. Code")
    //                                 ELSE BEGIN
    //                                     ApproverId := UserSetup."User ID";
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                       GenJournal."Salespers./Purch. Code",
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                     ApproverId := UserSetup."Approver ID";

    //                                     IF NOT UserSetup."Unlimited Sales Approval" AND
    //                                        ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") OR
    //                                         (UserSetup."Sales Amount Approval Limit" = 0))
    //                                     THEN BEGIN
    //                                         UserSetup.RESET;
    //                                         UserSetup.SETCURRENTKEY("User ID");
    //                                         UserSetup.SETRANGE("User ID", ApproverId);
    //                                         REPEAT
    //                                             IF NOT UserSetup.FIND('-') THEN
    //                                                 ERROR(Text006, ApproverId);
    //                                             ApproverId := UserSetup."User ID";
    //                                             MakePaymentApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name");
    //                                             UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                                         UNTIL UserSetup."Unlimited Sales Approval" OR
    //                                               ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") AND
    //                                                (UserSetup."Sales Amount Approval Limit" <> 0)) OR
    //                                               (UserSetup."User ID" = UserSetup."Approver ID")
    //                                     END;

    //                                     CheckAddApprovers(AppTemplate);
    //                                     IF AddApproversTemp.FIND('-') THEN
    //                                         REPEAT
    //                                             ApproverId := AddApproversTemp."Approver ID";
    //                                             MakePaymentApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name");
    //                                         UNTIL AddApproversTemp.NEXT = 0;
    //                                 END;
    //                             END;

    //                         AppTemplate."Limit Type"::"Credit Limits":
    //                             BEGIN
    //                                 AppTemplate.CALCFIELDS("Additional Approvers");
    //                                 IF NOT AppTemplate."Additional Approvers" THEN
    //                                     ERROR(Text023)
    //                                 ELSE
    //                                     InsertAddApprovers(AppTemplate);
    //                                 IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                                     ApproverId := USERID;
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                       GenJournal."Salespers./Purch. Code",
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                 END ELSE BEGIN
    //                                     UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                                     UserSetup.SETRANGE("Salespers./Purch. Code", GenJournal."Salespers./Purch. Code");
    //                                     IF NOT UserSetup.FIND('-') THEN
    //                                         ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                           UserSetup."Salespers./Purch. Code")
    //                                     ELSE BEGIN
    //                                         ApproverId := UserSetup."User ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                           GenJournal."Salespers./Purch. Code",
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");

    //                                         IF AddApproversTemp.FIND('-') THEN BEGIN
    //                                             REPEAT
    //                                                 ApproverId := AddApproversTemp."Approver ID";
    //                                                 MakePaymentApprovalEntry(
    //                                                   DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                                   GenJournal."Salespers./Purch. Code",
    //                                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                                   GenJournal."Journal Batch Name");
    //                                             UNTIL AddApproversTemp.NEXT = 0;
    //                                         END;
    //                                     END;
    //                                 END;
    //                             END;

    //                         AppTemplate."Limit Type"::"Request Limits":
    //                             ERROR(STRSUBSTNO(Text024, FORMAT(AppTemplate."Limit Type")));

    //                         AppTemplate."Limit Type"::"No Limits":
    //                             BEGIN
    //                                 //              AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                                 UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
    //                                 UserSetup.SETRANGE("Salespers./Purch. Code", GenJournal."Salespers./Purch. Code");
    //                                 IF NOT UserSetup.FIND('-') THEN
    //                                     ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
    //                                       UserSetup."Salespers./Purch. Code")
    //                                 ELSE BEGIN
    //                                     ApproverId := UserSetup."User ID";
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                       GenJournal."Salespers./Purch. Code",
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");

    //                                     CheckAddApprovers(AppTemplate);
    //                                     IF AddApproversTemp.FIND('-') THEN
    //                                         REPEAT
    //                                             ApproverId := AddApproversTemp."Approver ID";
    //                                             MakePaymentApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name");
    //                                         UNTIL AddApproversTemp.NEXT = 0;
    //                                 END;
    //                             END;
    //                     END;
    //                 END;
    //             END;

    //         AppTemplate."Approval Type"::Approver:
    //             BEGIN
    //                 CASE AppTemplate."Limit Type" OF
    //                     AppTemplate."Limit Type"::"Approval Limits":
    //                         BEGIN
    //                             //            AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                             UserSetup.SETRANGE("User ID", USERID);
    //                             IF NOT UserSetup.FIND('-') THEN
    //                                 ERROR(Text005, USERID);
    //                             ApproverId := UserSetup."User ID";
    //                             MakePaymentApprovalEntry(
    //                               DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                               GenJournal."Journal Batch Name");
    //                             IF NOT UserSetup."Unlimited Sales Approval" AND
    //                                ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") OR
    //                                 (UserSetup."Sales Amount Approval Limit" = 0))
    //                             THEN
    //                                 REPEAT
    //                                     UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                                     IF NOT UserSetup.FIND('-') THEN
    //                                         ERROR(Text005, USERID);
    //                                     ApproverId := UserSetup."User ID";
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                 UNTIL UserSetup."Unlimited Sales Approval" OR
    //                                       ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") AND
    //                                        (UserSetup."Sales Amount Approval Limit" <> 0)) OR
    //                                       (UserSetup."User ID" = UserSetup."Approver ID");

    //                             CheckAddApprovers(AppTemplate);
    //                             IF AddApproversTemp.FIND('-') THEN
    //                                 REPEAT
    //                                     ApproverId := AddApproversTemp."Approver ID";
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                 UNTIL AddApproversTemp.NEXT = 0;
    //                         END;

    //                     AppTemplate."Limit Type"::"Credit Limits":
    //                         BEGIN
    //                             //            AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                             //            Cust.GET(GenJournal."Bill-to Customer No.");

    //                             AppTemplate.CALCFIELDS("Additional Approvers");
    //                             IF NOT AppTemplate."Additional Approvers" THEN
    //                                 ERROR(Text023)
    //                             ELSE
    //                                 InsertAddApprovers(AppTemplate);
    //                             IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                                 ApproverId := USERID;
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                   GenJournal."Salespers./Purch. Code",
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                             END ELSE BEGIN
    //                                 UserSetup.SETRANGE("User ID", USERID);
    //                                 IF NOT UserSetup.FIND('-') THEN
    //                                     ERROR(Text005, USERID);
    //                                 ApproverId := UserSetup."Approver ID";
    //                                 IF ApproverId = '' THEN
    //                                     ApproverId := UserSetup."User ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                   GenJournal."Salespers./Purch. Code",
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");

    //                                 IF AddApproversTemp.FIND('-') THEN BEGIN
    //                                     REPEAT
    //                                         ApproverId := AddApproversTemp."Approver ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.",
    //                                           GenJournal."Salespers./Purch. Code",
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");
    //                                     UNTIL AddApproversTemp.NEXT = 0;
    //                                 END;
    //                             END;
    //                         END;

    //                     AppTemplate."Limit Type"::"Request Limits":
    //                         ERROR(STRSUBSTNO(Text024, FORMAT(AppTemplate."Limit Type")));

    //                     AppTemplate."Limit Type"::"No Limits":
    //                         BEGIN
    //                             //            AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                             UserSetup.SETRANGE("User ID", USERID);
    //                             IF NOT UserSetup.FIND('-') THEN
    //                                 ERROR(Text005, USERID);
    //                             ApproverId := UserSetup."Approver ID";
    //                             IF ApproverId = '' THEN
    //                                 ApproverId := UserSetup."User ID";
    //                             MakePaymentApprovalEntry(
    //                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                               GenJournal."Journal Batch Name");
    //                         END;
    //                 END;
    //             END;

    //         AppTemplate."Approval Type"::" ":
    //             BEGIN
    //                 //      AboveCreditLimitAmountLCY := CheckCreditLimit(GenJournal);
    //                 InsertEntries := FALSE;
    //                 IF AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits" THEN BEGIN
    //                     IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                         ApproverId := USERID;
    //                         MakePaymentApprovalEntry(
    //                           DATABASE::"Gen. Journal Line", GenJournal."Document Type", GenJournal."Document No.", '',
    //                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                           GenJournal."Journal Batch Name");
    //                     END ELSE
    //                         InsertEntries := TRUE;
    //                 END;
    //                 IF NOT (AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits") OR InsertEntries THEN BEGIN
    //                     CheckAddApprovers(AppTemplate);
    //                     IF AddApproversTemp.FIND('-') THEN
    //                         REPEAT
    //                             ApproverId := AddApproversTemp."Approver ID";
    //                             MakePaymentApprovalEntry(
    //                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
    //                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                               GenJournal."Journal Batch Name");
    //                         UNTIL AddApproversTemp.NEXT = 0
    //                     ELSE
    //                         ERROR(Text027);
    //                 END;
    //             END;
    //     END;

    //     EntryApproved := FALSE;
    //     DocReleased := FALSE;
    //     CLEAR(PreviousDocNo);
    //     WITH ApprovalEntry DO BEGIN
    //         INIT;
    //         SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //         SETRANGE("Document Type", "Document Type"::" ");
    //         SETRANGE("Document No.", GenJournal."Document No.");
    //         SETRANGE(Status, Status::Created);
    //         IF FINDSET(TRUE, FALSE) THEN
    //             REPEAT
    //                 IF "Sender ID" = "Approver ID" THEN BEGIN
    //                     Status := Status::Approved;
    //                     MODIFY;
    //                 END ELSE
    //                     IF NOT IsOpenStatusSet THEN BEGIN
    //                         Status := Status::Open;
    //                         MODIFY;
    //                         IsOpenStatusSet := TRUE;

    //                         IF (ApprovalSetup.Approvals) THEN BEGIN
    //                             ApprovalsMgtNotification.SendPaymentApprovalsMail(GenJournal, ApprovalEntry);
    //                         END;
    //                     END;
    //             UNTIL NEXT = 0;
    //         SETFILTER(Status, '=%1|%2|%3', Status::Approved, Status::Created, Status::Open);
    //         IF FIND('-') THEN
    //             REPEAT
    //                 IF Status = Status::Approved THEN
    //                     EntryApproved := TRUE
    //                 ELSE
    //                     EntryApproved := FALSE;
    //             UNTIL NEXT = 0;
    //         IF EntryApproved THEN
    //             DocReleased := ApproveApprovalRequest(ApprovalEntry);
    //         DispMessage := FALSE;
    //         IF NOT DocReleased THEN BEGIN
    //             GenJournal.Status := GenJournal.Status::"Pending Approval";
    //             GenJournal.MODIFY(TRUE);
    //             DispMessage := TRUE;
    //         END;
    //         /*  IF DocReleased THEN
    //             IF TestSalesPrepayment(GenJournal) AND
    //                (GenJournal."Document Type" = GenJournal."Document Type"::Order) THEN BEGIN
    //               GenJournal.Status := GenJournal.Status::"Pending Prepayment";
    //               GenJournal.MODIFY(TRUE);
    //               MESSAGE(Text128,GenJournal."Document Type",GenJournal."No.");
    //             END ELSE
    //               MESSAGE(Text003,GenJournal."Document Type",GenJournal."No.");*/
    //         EXIT(TRUE);
    //     END;

    // end;

    // IE commented all this function
    // procedure MakeBlankApprovalEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "452"; ApproverId: Code[20]; ApprovalCode: Code[20]; UserSetup: Record "91"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; AppTemplate: Record "464"; ExeedAmountLCY: Decimal; JournalTemplateName: Code[10]; JournalBatchName: Code[10]);
    // var
    //     ApprovalEntry: Record "454";
    //     NewSequenceNo: Integer;
    // begin
    //     WITH ApprovalEntry DO BEGIN
    //         SETRANGE("Table ID", TableID);
    //         SETRANGE("Document Type", DocType);
    //         SETRANGE("Document No.", DocNo);
    //         IF FIND('+') THEN
    //             NewSequenceNo := "Sequence No." + 1
    //         ELSE
    //             NewSequenceNo := 1;
    //         "Table ID" := TableID;
    //         "Document Type" := DocType;
    //         "Document No." := DocNo;
    //         "Salespers./Purch. Code" := SalespersonPurchaser;
    //         "Sequence No." := NewSequenceNo;
    //         "Approval Code" := ApprovalCode;
    //         "Sender ID" := USERID;
    //         Amount := ApprovalAmount;
    //         "Amount (LCY)" := ApprovalAmountLCY;
    //         "Currency Code" := CurrencyCode;
    //         "Approver ID" := ApproverId;
    //         IF ApproverId = USERID THEN
    //             Status := Status::Approved
    //         ELSE
    //             Status := Status::Open;
    //         "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //         "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         "Last Modified By ID" := USERID;
    //         "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
    //         "Approval Type" := AppTemplate."Approval Type";
    //         "Limit Type" := AppTemplate."Limit Type";
    //         "Available Credit Limit (LCY)" := ExeedAmountLCY;
    //         "Journal Template Name" := JournalTemplateName;
    //         "Journal Batch Name" := JournalBatchName;
    //         INSERT;
    //     END;
    // end;

    local procedure "-----Journal Approvals Start------"();
    begin
    end;


    // IE commented all this function
    // procedure SendPaymentApprovalRequest(var GenJournal: Record "81"; SendMail: Boolean): Boolean;
    // var
    //     TemplateRec: Record "464";
    //     ApprovalSetup: Record "452";
    // begin
    //     TestSetup;
    //     WITH GenJournal DO BEGIN
    //         IF Status <> Status::Open THEN
    //             EXIT(FALSE);

    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //         TemplateRec.SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //         TemplateRec.SETRANGE("Document Type", TemplateRec."Document Type"::None);
    //         TemplateRec.SETRANGE(Enabled, TRUE);
    //         IF TemplateRec.FIND('-') THEN BEGIN
    //             REPEAT
    //                 IF NOT FindApproverPayment(GenJournal, ApprovalSetup, TemplateRec, SendMail) THEN
    //                     ERROR(Text010);
    //             UNTIL TemplateRec.NEXT = 0;
    //             IF DispMessage THEN
    //                 MESSAGE(Text001, "Document Type", GenJournal."Document No.");
    //         END ELSE
    //             ERROR(STRSUBSTNO(Text129, GenJournal."Document Type"));
    //     END;
    // end;

    // IE commented all this function
    // procedure FindApproverPayment(GenJournal: Record "81"; ApprovalSetup: Record "452"; AppTemplate: Record "464"; SendMail: Boolean): Boolean;
    // var
    //     Cust: Record "18";
    //     UserSetup: Record "91";
    //     ApprovalEntry: Record "454";
    //     ApprovalsMgtNotification: Codeunit "440";
    //     ApproverId: Code[20];
    //     EntryApproved: Boolean;
    //     DocReleased: Boolean;
    //     ApprovalAmount: Decimal;
    //     ApprovalAmountLCY: Decimal;
    //     AboveCreditLimitAmountLCY: Decimal;
    //     InsertEntries: Boolean;
    //     DepartmentalUserSetup: Record "51407341";
    //     JournalLineDimension: Record "356";
    //     CalcJnlLineBal: Record "81";
    //     MailSent: Boolean;
    // begin
    //     AddApproversTemp.RESET;
    //     AddApproversTemp.DELETEALL;

    //     IsOpenStatusSet := SendMail;
    //     //None Departmental Approvals
    //     NFLApprovalSetup.GET;
    //     IF NOT NFLApprovalSetup."Departmental Level Approval" THEN BEGIN
    //         CASE AppTemplate."Approval Type" OF
    //             AppTemplate."Approval Type"::Approver:
    //                 BEGIN
    //                     CASE AppTemplate."Limit Type" OF
    //                         AppTemplate."Limit Type"::"Approval Limits":
    //                             BEGIN
    //                                 UserSetup.SETRANGE("User ID", USERID);
    //                                 IF NOT UserSetup.FIND('-') THEN
    //                                     ERROR(Text005, USERID);
    //                                 ApproverId := UserSetup."User ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.",
    //                                   '', ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                                 IF NOT UserSetup."Unlimited Request Approval" AND
    //                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") OR
    //                                    (UserSetup."Request Amount Approval Limit" = 0))
    //                                 THEN
    //                                     REPEAT
    //                                         UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
    //                                         IF NOT UserSetup.FIND('-') THEN
    //                                             ERROR(Text005, USERID);
    //                                         ApproverId := UserSetup."User ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");
    //                                     UNTIL UserSetup."Unlimited Request Approval" OR
    //                                  ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") AND
    //                                   (UserSetup."Request Amount Approval Limit" <> 0)) OR
    //                                    (UserSetup."User ID" = UserSetup."Approver ID");

    //                                 CheckAddApprovers(AppTemplate);
    //                                 IF AddApproversTemp.FIND('-') THEN
    //                                     REPEAT
    //                                         ApproverId := AddApproversTemp."Approver ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");
    //                                     UNTIL AddApproversTemp.NEXT = 0;
    //                             END;

    //                         AppTemplate."Limit Type"::"Credit Limits":
    //                             BEGIN
    //                                 AppTemplate.CALCFIELDS("Additional Approvers");
    //                                 IF NOT AppTemplate."Additional Approvers" THEN
    //                                     ERROR(Text023)
    //                                 ELSE
    //                                     InsertAddApprovers(AppTemplate);
    //                                 IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                                     ApproverId := USERID;
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.",
    //                                       GenJournal."Salespers./Purch. Code",
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                 END ELSE BEGIN
    //                                     UserSetup.SETRANGE("User ID", USERID);
    //                                     IF NOT UserSetup.FIND('-') THEN
    //                                         ERROR(Text005, USERID);
    //                                     ApproverId := UserSetup."Approver ID";
    //                                     IF ApproverId = '' THEN
    //                                         ApproverId := UserSetup."User ID";
    //                                     MakePaymentApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.",
    //                                       GenJournal."Salespers./Purch. Code",
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name");
    //                                     IF AddApproversTemp.FIND('-') THEN BEGIN
    //                                         REPEAT
    //                                             ApproverId := AddApproversTemp."Approver ID";
    //                                             MakePaymentApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.",
    //                                               GenJournal."Salespers./Purch. Code",
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name");
    //                                         UNTIL AddApproversTemp.NEXT = 0;
    //                                     END;
    //                                 END;
    //                             END;
    //                         AppTemplate."Limit Type"::"Request Limits":
    //                             ERROR(STRSUBSTNO(Text024, FORMAT(AppTemplate."Limit Type")));

    //                         AppTemplate."Limit Type"::"No Limits":
    //                             BEGIN
    //                                 UserSetup.SETRANGE("User ID", USERID);
    //                                 IF NOT UserSetup.FIND('-') THEN
    //                                     ERROR(Text005, USERID);
    //                                 ApproverId := UserSetup."Approver ID";
    //                                 IF ApproverId = '' THEN
    //                                     ApproverId := UserSetup."User ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                             END;
    //                     END;
    //                 END;

    //             AppTemplate."Approval Type"::" ":
    //                 BEGIN
    //                     InsertEntries := FALSE;
    //                     IF AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits" THEN BEGIN
    //                         IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                             ApproverId := USERID;
    //                             MakePaymentApprovalEntry(
    //                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                               GenJournal."Journal Batch Name");
    //                         END ELSE
    //                             InsertEntries := TRUE;
    //                     END;
    //                     IF NOT (AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits") OR InsertEntries THEN BEGIN
    //                         CheckAddApprovers(AppTemplate);
    //                         IF AddApproversTemp.FIND('-') THEN
    //                             REPEAT
    //                                 ApproverId := AddApproversTemp."Approver ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                             UNTIL AddApproversTemp.NEXT = 0
    //                         ELSE
    //                             ERROR(Text027);
    //                     END;
    //                 END;
    //         END;
    //         //Departmental Approvals
    //     END ELSE BEGIN
    //         ApprovalAmountLCY := 0;
    //         CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Journal Template Name", GenJournal."Journal Template Name");
    //         CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Journal Batch Name", GenJournal."Journal Batch Name");
    //         CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Document No.", GenJournal."Document No.");
    //         IF CalcJnlLineBal.FINDSET THEN
    //             REPEAT
    //                 ApprovalAmountLCY := ApprovalAmountLCY + CalcJnlLineBal."Amount (LCY)";
    //             UNTIL CalcJnlLineBal.NEXT = 0;

    //         /*
    //         JournalLineDimension.SETRANGE("Table ID",81);
    //         JournalLineDimension.SETRANGE("Journal Template Name",GenJournal."Journal Template Name");
    //         JournalLineDimension.SETRANGE("Journal Batch Name",GenJournal."Journal Batch Name");
    //         JournalLineDimension.SETRANGE("Dimension Code",NFLApprovalSetup."Department Dimension");
    //         JournalLineDimension.SETRANGE(JournalLineDimension."Journal Line No.",GenJournal."Line No.");
    //         JournalLineDimension.SETFILTER("Dimension Value Code",'<>%1','');
    //         IF NOT JournalLineDimension.FINDFIRST THEN
    //           ERROR('Department Dimension must be speficied for all journal lines for you to use Departmental Approval');
    //         */

    //         CASE AppTemplate."Approval Type" OF
    //             AppTemplate."Approval Type"::Approver:
    //                 BEGIN
    //                     CASE AppTemplate."Limit Type" OF
    //                         AppTemplate."Limit Type"::"Approval Limits":
    //                             BEGIN
    //                                 DepartmentalUserSetup.SETRANGE("User ID", USERID);
    //                                 DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::"Purchase Requisition");
    //                                 DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");
    //                                 IF NOT DepartmentalUserSetup.FINDSET THEN
    //                                     ERROR(Text155, USERID);
    //                                 ApproverId := DepartmentalUserSetup."User ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                                 IF NOT DepartmentalUserSetup."Unlimited Request Approval" AND
    //                                   ((ApprovalAmountLCY > DepartmentalUserSetup."Request Amount Approval Limit") OR
    //                                    (DepartmentalUserSetup."Request Amount Approval Limit" = 0))
    //                                 THEN
    //                                     REPEAT
    //                                         DepartmentalUserSetup.SETRANGE("User ID", DepartmentalUserSetup."Approver ID"); // BKM 060516
    //                                         DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::"Purchase Requisition");
    //                                         DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");
    //                                         IF NOT DepartmentalUserSetup.FINDSET THEN
    //                                             ERROR(Text155, DepartmentalUserSetup."Approver ID");
    //                                         ApproverId := DepartmentalUserSetup."User ID"; //default
    //                                                                                        //ApproverId := DepartmentalUserSetup."Approver ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");
    //                                     UNTIL DepartmentalUserSetup."Unlimited Request Approval" OR
    //                                       ((ApprovalAmountLCY <= DepartmentalUserSetup."Request Amount Approval Limit") AND
    //                                        (DepartmentalUserSetup."Request Amount Approval Limit" <> 0)) OR
    //                                         (DepartmentalUserSetup."User ID" = DepartmentalUserSetup."Approver ID");

    //                                 CheckAddApprovers(AppTemplate);
    //                                 IF AddApproversTemp.FIND('-') THEN
    //                                     REPEAT
    //                                         ApproverId := AddApproversTemp."Approver ID";
    //                                         MakePaymentApprovalEntry(
    //                                           DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                           GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                           GenJournal."Journal Batch Name");
    //                                     UNTIL AddApproversTemp.NEXT = 0;
    //                             END;

    //                         AppTemplate."Limit Type"::"Credit Limits":
    //                             ERROR(STRSUBSTNO(Text144, FORMAT(AppTemplate."Limit Type")));

    //                         AppTemplate."Limit Type"::"Request Limits":
    //                             ERROR(STRSUBSTNO(Text024, FORMAT(AppTemplate."Limit Type")));

    //                         AppTemplate."Limit Type"::"No Limits":
    //                             BEGIN
    //                                 DepartmentalUserSetup.SETRANGE("User ID", USERID);
    //                                 DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::"Purchase Requisition");
    //                                 DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");

    //                                 IF NOT DepartmentalUserSetup.FIND('-') THEN
    //                                     ERROR(Text155, USERID);
    //                                 ApproverId := DepartmentalUserSetup."Approver ID";
    //                                 IF ApproverId = '' THEN
    //                                     ApproverId := DepartmentalUserSetup."User ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                             END;
    //                     END;
    //                 END;

    //             AppTemplate."Approval Type"::" ":
    //                 BEGIN
    //                     InsertEntries := FALSE;
    //                     IF AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits" THEN BEGIN
    //                         IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                             ApproverId := USERID;
    //                             MakePaymentApprovalEntry(
    //                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                               GenJournal."Journal Batch Name");
    //                         END ELSE
    //                             InsertEntries := TRUE;
    //                     END;
    //                     IF NOT (AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits") OR InsertEntries THEN BEGIN
    //                         CheckAddApprovers(AppTemplate);
    //                         IF AddApproversTemp.FIND('-') THEN
    //                             REPEAT
    //                                 ApproverId := AddApproversTemp."Approver ID";
    //                                 MakePaymentApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::"Return Order", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name");
    //                             UNTIL AddApproversTemp.NEXT = 0
    //                         ELSE
    //                             ERROR(Text027);
    //                     END;
    //                 END;
    //         END;
    //     END;//END AMI 121109 Departmental Approvals

    //     EntryApproved := FALSE;
    //     DocReleased := FALSE;
    //     WITH ApprovalEntry DO BEGIN
    //         INIT;
    //         SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //         SETRANGE("Document Type", ApprovalEntry."Document Type"::"Return Order");
    //         SETRANGE("Document No.", GenJournal."Document No.");
    //         SETRANGE(Status, Status::Open);
    //         MailSent := FALSE;
    //         IF FINDSET(TRUE, FALSE) THEN BEGIN
    //             REPEAT
    //                 IF "Sender ID" = "Approver ID" THEN BEGIN
    //                     Status := Status::Approved;
    //                     MODIFY;
    //                 END ELSE
    //                     IF NOT IsOpenStatusSet THEN BEGIN
    //                         Status := Status::Open;
    //                         MODIFY;
    //                         IsOpenStatusSet := TRUE;
    //                         //IF (ApprovalSetup.Approvals AND (NOT PaymentRequestApprovalMailSent)) THEN BEGIN //BKM 010716
    //                         IF (ApprovalSetup.Approvals) THEN BEGIN //BKM 010716
    //                             ApprovalsMgtNotification.SendPaymentApprovalsMail(GenJournal, ApprovalEntry);
    //                             PaymentRequestApprovalMailSent := TRUE;
    //                         END;
    //                     END;
    //             UNTIL NEXT = 0;

    //         END;

    //         SETFILTER(Status, '=%1|%2|%3', Status::Approved, Status::Created, Status::Open);
    //         IF FIND('-') THEN
    //             REPEAT
    //                 IF Status = Status::Approved THEN
    //                     EntryApproved := TRUE
    //                 ELSE
    //                     EntryApproved := FALSE;
    //             UNTIL NEXT = 0;
    //         IF EntryApproved THEN
    //             DocReleased := ApproveApprovalRequest(ApprovalEntry);
    //         DispMessage := FALSE;
    //         IF NOT DocReleased THEN BEGIN
    //             GenJournal.Status := GenJournal.Status::"Pending Approval";
    //             GenJournal.MODIFY(TRUE);
    //             DispMessage := TRUE;
    //         END;
    //         IF DocReleased THEN
    //             MESSAGE(Text003, GenJournal."Document Type", GenJournal."Document No.");
    //         EXIT(TRUE);
    //     END;

    // end;

    // IE commented all this function

    // procedure MakePaymentApprovalEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "452"; ApproverId: Code[20]; ApprovalCode: Code[20]; UserSetup: Record "91"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; AppTemplate: Record "464"; ExeedAmountLCY: Decimal; JournalTemplateName: Code[10]; JournalBatchName: Code[10]);
    // var
    //     ApprovalEntry: Record "454";
    //     NewSequenceNo: Integer;
    // begin
    //     WITH ApprovalEntry DO BEGIN
    //         SETRANGE("Table ID", TableID);
    //         SETRANGE("Document Type", DocType);
    //         SETRANGE("Document No.", DocNo);
    //         IF FIND('+') THEN
    //             NewSequenceNo := "Sequence No." + 1
    //         ELSE
    //             NewSequenceNo := 1;
    //         "Table ID" := TableID;
    //         "Document Type" := "Document Type"::"Return Order";
    //         "Document No." := DocNo;
    //         "Salespers./Purch. Code" := SalespersonPurchaser;
    //         "Sequence No." := NewSequenceNo;
    //         "Approval Code" := ApprovalCode;
    //         "Sender ID" := USERID;
    //         Amount := ApprovalAmount;
    //         "Amount (LCY)" := ApprovalAmountLCY;
    //         "Currency Code" := CurrencyCode;
    //         "Approver ID" := ApproverId;
    //         IF ApproverId = USERID THEN
    //             Status := Status::Approved
    //         ELSE
    //             Status := Status::Open;
    //         "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //         "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         "Last Modified By ID" := USERID;
    //         "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
    //         "Approval Type" := AppTemplate."Approval Type";
    //         "Limit Type" := AppTemplate."Limit Type";
    //         "Available Credit Limit (LCY)" := ExeedAmountLCY;
    //         "Journal Template Name" := JournalTemplateName;
    //         "Journal Batch Name" := JournalBatchName;
    //         INSERT;
    //     END;
    // end;

    /// <summary>
    /// Description for -----Journal Approvals End.
    /// </summary>
    local procedure "-----Journal Approvals End-------"();
    begin
    end;

    // IE commented all this function
    /// <summary>
    /// Description for ApprovalRequestMailSent.
    /// </summary>
    /// <param name="MailSent">Parameter of type Boolean.</param>
    // procedure ApprovalRequestMailSent(MailSent: Boolean);
    // begin
    //     PaymentRequestApprovalMailSent := MailSent;  //BKM 010716
    // end;

    // IE commented all this function
    // procedure SendJVApprovalRequest(var GenJournal: Record "81"; SendMail: Boolean) Success: Boolean;
    // var
    //     TemplateRec: Record "464";
    //     ApprovalSetup: Record "452";
    // begin
    //     TestSetup;
    //     WITH GenJournal DO BEGIN
    //         IF NOT GenJournal.JV THEN
    //             EXIT(FALSE);
    //         IF Status <> Status::Open THEN
    //             EXIT(FALSE);

    //         IF NOT ApprovalSetup.GET THEN
    //             ERROR(Text004);

    //         TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
    //         TemplateRec.SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //         TemplateRec.SETRANGE("Document Type", TemplateRec."Document Type"::" ");
    //         TemplateRec.SETRANGE(Enabled, TRUE);
    //         IF TemplateRec.FIND('-') THEN BEGIN
    //             REPEAT
    //                 IF NOT FindApproverJV(GenJournal, ApprovalSetup, TemplateRec, SendMail) THEN
    //                     ERROR(Text010);
    //             UNTIL TemplateRec.NEXT = 0;
    //             Success := TRUE;
    //             IF DispMessage THEN
    //                 MESSAGE(Text001, "Document Type", GenJournal."Document No.");
    //         END ELSE
    //             ERROR(STRSUBSTNO(Text129, GenJournal."Document Type"));
    //     END;
    // end;

    // IE commented all this function
    /// <summary>
    /// Description for FindApproverJV.
    /// </summary>
    /// <param name="GenJournal">Parameter of type Record "81".</param>
    /// <param name="ApprovalSetup">Parameter of type Record "452".</param>
    /// <param name="AppTemplate">Parameter of type Record "464".</param>
    /// <param name="SendMail">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    // procedure FindApproverJV(GenJournal: Record "Gen. Journal Line"; ApprovalSetup: Record "452"; AppTemplate: Record "464"; SendMail: Boolean): Boolean;
    // var
    //     Cust: Record Customer;
    //     UserSetup: Record "User Setup";
    //     ApprovalEntry: Record "454";
    //     ApprovalsMgtNotification: Codeunit "440";
    //     ApproverId: Code[20];
    //     EntryApproved: Boolean;
    //     DocReleased: Boolean;
    //     ApprovalAmount: Decimal;
    //     ApprovalAmountLCY: Decimal;
    //     AboveCreditLimitAmountLCY: Decimal;
    //     InsertEntries: Boolean;
    //     DepartmentalUserSetup: Record "51407341";
    //     JournalLineDimension: Record "356";
    //     CalcJnlLineBal: Record "81";
    //     MailSent: Boolean;
    // begin
    //     AddApproversTemp.RESET;
    //     AddApproversTemp.DELETEALL;

    //     CLEAR(BatchIdentifierCode);

    //     gvGenJournalBatch.INIT;
    //     gvGenJournalBatch.SETRANGE(gvGenJournalBatch."Journal Template Name", GenJournal."Journal Template Name");
    //     gvGenJournalBatch.SETRANGE(gvGenJournalBatch.Name, GenJournal."Journal Batch Name");
    //     IF gvGenJournalBatch.FINDFIRST THEN BEGIN
    //         gvGenJournalBatch.TESTFIELD("Batch Identifier Code");
    //         BatchIdentifierCode := gvGenJournalBatch."Batch Identifier Code";
    //     END;


    //     IsOpenStatusSet := SendMail;
    //     NFLApprovalSetup.GET;
    //     IF NOT NFLApprovalSetup."Enable JV Apporval" THEN
    //         ERROR('JV Approvals are not enabled in the approval setup')
    //     ELSE BEGIN
    //         IF NOT NFLApprovalSetup."Departmental Level Approval" THEN BEGIN
    //             ERROR('Departmental Approvals are not enabled in the approval setup')
    //             //Departmental Approvals
    //         END ELSE BEGIN
    //             ApprovalAmountLCY := 0;
    //             CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Journal Template Name", GenJournal."Journal Template Name");
    //             CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Journal Batch Name", GenJournal."Journal Batch Name");
    //             CalcJnlLineBal.SETFILTER(CalcJnlLineBal."Document No.", GenJournal."Document No.");
    //             IF CalcJnlLineBal.FINDSET THEN
    //                 REPEAT
    //                     ApprovalAmountLCY := ApprovalAmountLCY + CalcJnlLineBal."Amount (LCY)";
    //                 UNTIL CalcJnlLineBal.NEXT = 0;


    //             CASE AppTemplate."Approval Type" OF
    //                 AppTemplate."Approval Type"::Approver:
    //                     BEGIN
    //                         CASE AppTemplate."Limit Type" OF
    //                             AppTemplate."Limit Type"::"Approval Limits":
    //                                 BEGIN
    //                                     DepartmentalUserSetup.SETCURRENTKEY("User ID", "Approver ID", "Document Type", Department, "Sequence No.", "Batch Identifier Code", "Journal Template Name");
    //                                     DepartmentalUserSetup.SETRANGE("User ID", USERID);
    //                                     DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::" ");
    //                                     //DepartmentalUserSetup.SETRANGE("Document Type",DepartmentalUserSetup."Document Type"::none);
    //                                     DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");
    //                                     DepartmentalUserSetup.SETRANGE("Batch Identifier Code", BatchIdentifierCode);
    //                                     DepartmentalUserSetup.SETRANGE("Journal Template Name", GenJournal."Journal Template Name");
    //                                     IF NOT DepartmentalUserSetup.FINDSET THEN
    //                                         ERROR(Text155, USERID);
    //                                     ApproverId := DepartmentalUserSetup."User ID";
    //                                     MakeJVApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name", GenJournal.JV);

    //                                     IF NOT DepartmentalUserSetup."Unlimited Request Approval" AND
    //                                       ((ApprovalAmountLCY > DepartmentalUserSetup."Request Amount Approval Limit") OR
    //                                        (DepartmentalUserSetup."Request Amount Approval Limit" = 0))
    //                                     THEN
    //                                         REPEAT
    //                                             DepartmentalUserSetup.SETRANGE("User ID", DepartmentalUserSetup."Approver ID"); // BKM 060516
    //                                             DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::" ");
    //                                             DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");
    //                                             DepartmentalUserSetup.SETRANGE("Batch Identifier Code", BatchIdentifierCode);
    //                                             DepartmentalUserSetup.SETRANGE("Journal Template Name", GenJournal."Journal Template Name");
    //                                             IF NOT DepartmentalUserSetup.FINDSET THEN
    //                                                 ERROR(Text155, DepartmentalUserSetup."Approver ID");
    //                                             ApproverId := DepartmentalUserSetup."User ID"; //default
    //                                                                                            //ApproverId := DepartmentalUserSetup."Approver ID";
    //                                             MakeJVApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name", GenJournal.JV);
    //                                         UNTIL DepartmentalUserSetup."Unlimited Request Approval" OR
    //                                           ((ApprovalAmountLCY <= DepartmentalUserSetup."Request Amount Approval Limit") AND
    //                                            (DepartmentalUserSetup."Request Amount Approval Limit" <> 0)) OR
    //                                             (DepartmentalUserSetup."User ID" = DepartmentalUserSetup."Approver ID");

    //                                     CheckAddApprovers(AppTemplate);
    //                                     IF AddApproversTemp.FIND('-') THEN
    //                                         REPEAT
    //                                             ApproverId := AddApproversTemp."Approver ID";
    //                                             MakeJVApprovalEntry(
    //                                               DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                               GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                               GenJournal."Journal Batch Name", GenJournal.JV);
    //                                         UNTIL AddApproversTemp.NEXT = 0;
    //                                 END;

    //                             AppTemplate."Limit Type"::"Credit Limits":
    //                                 ERROR(STRSUBSTNO(Text144, FORMAT(AppTemplate."Limit Type")));

    //                             AppTemplate."Limit Type"::"Request Limits":
    //                                 ERROR(STRSUBSTNO(Text024, FORMAT(AppTemplate."Limit Type")));

    //                             AppTemplate."Limit Type"::"No Limits":
    //                                 BEGIN
    //                                     DepartmentalUserSetup.SETRANGE("User ID", USERID);
    //                                     DepartmentalUserSetup.SETRANGE("Document Type", DepartmentalUserSetup."Document Type"::" ");
    //                                     DepartmentalUserSetup.SETRANGE(Department, GenJournal."Shortcut Dimension 1 Code"); //JournalLineDimension."Dimension Value Code");
    //                                     DepartmentalUserSetup.SETRANGE("Batch Identifier Code", BatchIdentifierCode);
    //                                     DepartmentalUserSetup.SETRANGE("Journal Template Name", GenJournal."Journal Template Name");

    //                                     IF NOT DepartmentalUserSetup.FIND('-') THEN
    //                                         ERROR(Text155, USERID);
    //                                     ApproverId := DepartmentalUserSetup."Approver ID";
    //                                     IF ApproverId = '' THEN
    //                                         ApproverId := DepartmentalUserSetup."User ID";
    //                                     MakeJVApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name", GenJournal.JV);
    //                                 END;
    //                         END;
    //                     END;

    //                 AppTemplate."Approval Type"::" ":
    //                     BEGIN
    //                         InsertEntries := FALSE;
    //                         IF AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits" THEN BEGIN
    //                             IF (AboveCreditLimitAmountLCY > 0) OR (Cust."Credit Limit (LCY)" = 0) THEN BEGIN
    //                                 ApproverId := USERID;
    //                                 MakeJVApprovalEntry(
    //                                   DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                   GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                   GenJournal."Journal Batch Name", GenJournal.JV);
    //                             END ELSE
    //                                 InsertEntries := TRUE;
    //                         END;
    //                         IF NOT (AppTemplate."Limit Type" = AppTemplate."Limit Type"::"Credit Limits") OR InsertEntries THEN BEGIN
    //                             CheckAddApprovers(AppTemplate);
    //                             IF AddApproversTemp.FIND('-') THEN
    //                                 REPEAT
    //                                     ApproverId := AddApproversTemp."Approver ID";
    //                                     MakeJVApprovalEntry(
    //                                       DATABASE::"Gen. Journal Line", ApprovalEntry."Document Type"::" ", GenJournal."Document No.", '',
    //                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, GenJournal.Amount, GenJournal."Amount (LCY)",
    //                                       GenJournal."Currency Code", AppTemplate, AboveCreditLimitAmountLCY, GenJournal."Journal Template Name",
    //                                       GenJournal."Journal Batch Name", GenJournal.JV);
    //                                 UNTIL AddApproversTemp.NEXT = 0
    //                             ELSE
    //                                 ERROR(Text027);
    //                         END;
    //                     END;
    //             END;
    //         END;//END AMI 121109 Departmental Approvals

    //         EntryApproved := FALSE;
    //         DocReleased := FALSE;
    //         WITH ApprovalEntry DO BEGIN
    //             INIT;
    //             SETRANGE("Table ID", DATABASE::"Gen. Journal Line");
    //             SETRANGE("Document Type", ApprovalEntry."Document Type"::" ");
    //             SETRANGE("Document No.", GenJournal."Document No.");
    //             SETRANGE(Status, Status::Open);
    //             MailSent := FALSE;
    //             IF FINDSET(TRUE, FALSE) THEN BEGIN
    //                 REPEAT
    //                     IF "Sender ID" = "Approver ID" THEN BEGIN
    //                         Status := Status::Approved;
    //                         MODIFY;
    //                     END ELSE
    //                         IF NOT IsOpenStatusSet THEN BEGIN
    //                             Status := Status::Open;
    //                             MODIFY;
    //                             IsOpenStatusSet := TRUE;
    //                         END;
    //                 UNTIL NEXT = 0;

    //             END;

    //             SETFILTER(Status, '=%1|%2|%3', Status::Approved, Status::Created, Status::Open);
    //             IF FIND('-') THEN
    //                 REPEAT
    //                     IF Status = Status::Approved THEN
    //                         EntryApproved := TRUE
    //                     ELSE
    //                         EntryApproved := FALSE;
    //                 UNTIL NEXT = 0;
    //             IF EntryApproved THEN
    //                 DocReleased := ApproveJVApprovalRequest(ApprovalEntry); //GMT 071217
    //             DispMessage := FALSE;
    //             IF NOT DocReleased THEN BEGIN
    //                 GenJournal.Status := GenJournal.Status::"Pending Approval";
    //                 GenJournal.MODIFY(TRUE);
    //                 DispMessage := FALSE;  //Changed to false by GMT 071217
    //             END;
    //             IF DocReleased THEN
    //                 MESSAGE(Text003, GenJournal."Document Type", GenJournal."Document No.");
    //             EXIT(TRUE);
    //         END;
    //     END;
    // end;


    // IE commented all this function
    /// <summary>
    /// Description for MakeJVApprovalEntry.
    /// </summary>
    /// <param name="TableID">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Integer.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="SalespersonPurchaser">Parameter of type Code[10].</param>
    /// <param name="ApprovalSetup">Parameter of type Record "452".</param>
    /// <param name="ApproverId">Parameter of type Code[20].</param>
    /// <param name="ApprovalCode">Parameter of type Code[20].</param>
    /// <param name="UserSetup">Parameter of type Record "91".</param>
    /// <param name="ApprovalAmount">Parameter of type Decimal.</param>
    /// <param name="ApprovalAmountLCY">Parameter of type Decimal.</param>
    /// <param name="CurrencyCode">Parameter of type Code[10].</param>
    /// <param name="AppTemplate">Parameter of type Record "464".</param>
    /// <param name="ExeedAmountLCY">Parameter of type Decimal.</param>
    /// <param name="JournalTemplateName">Parameter of type Code[10].</param>
    /// <param name="JournalBatchName">Parameter of type Code[10].</param>
    /// <param name="JV">Parameter of type Boolean.</param>
    // procedure MakeJVApprovalEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[20]; ApprovalCode: Code[20]; UserSetup: Record "User Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; AppTemplate: Record "464"; ExeedAmountLCY: Decimal; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; JV: Boolean);
    // var
    //     ApprovalEntry: Record "454";
    //     NewSequenceNo: Integer;
    // begin
    //     WITH ApprovalEntry DO BEGIN
    //         SETRANGE("Table ID", TableID);
    //         SETRANGE("Document Type", DocType);
    //         SETRANGE("Document No.", DocNo);
    //         IF FIND('+') THEN
    //             NewSequenceNo := "Sequence No." + 1
    //         ELSE
    //             NewSequenceNo := 1;
    //         "Table ID" := TableID;
    //         "Document Type" := "Document Type"::" ";
    //         "Document No." := DocNo;
    //         "Salespers./Purch. Code" := SalespersonPurchaser;
    //         "Sequence No." := NewSequenceNo;
    //         "Approval Code" := ApprovalCode;
    //         "Sender ID" := USERID;
    //         Amount := ApprovalAmount;
    //         "Amount (LCY)" := ApprovalAmountLCY;
    //         "Currency Code" := CurrencyCode;
    //         JV := TRUE;
    //         "Approver ID" := ApproverId;
    //         IF ApproverId = USERID THEN
    //             Status := Status::Approved
    //         ELSE
    //             Status := Status::Open;
    //         "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //         "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         "Last Modified By ID" := USERID;
    //         "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
    //         "Approval Type" := AppTemplate."Approval Type";
    //         "Limit Type" := AppTemplate."Limit Type";
    //         "Available Credit Limit (LCY)" := ExeedAmountLCY;
    //         "Journal Template Name" := JournalTemplateName;
    //         "Journal Batch Name" := JournalBatchName;
    //         INSERT;
    //     END;
    // end;

    // IE commented all this function
    /// <summary>
    /// Description for ApproveJVApprovalRequest.
    /// </summary>
    /// <param name="ApprovalEntry">Parameter of type Record "454".</param>
    /// <returns>Return variable "Boolean".</returns>
    // procedure ApproveJVApprovalRequest(ApprovalEntry: Record "Approval Entry"): Boolean;
    // var
    //     SalesHeader: Record "36";
    //     PurchaseHeader: Record "38";
    //     ApprovalSetup: Record "452";
    //     NextApprovalEntry: Record "454";
    //     ReleaseSalesDoc: Codeunit "414";
    //     ReleasePurchaseDoc: Codeunit "415";
    //     ApprovalMgtNotification: Codeunit "440";
    //     GenJournal: Record "81";
    //     ApprovedPmt: Record "81";
    //     NewApprovedPayments: Record "81";
    //     GetLastLineNo: Record "81";
    //     RemoveGenJnls: Record "81";
    //     GenJournal1: Record "81";
    // begin
    //     /*GenLedgSetUp.GET;
    //     GenLedgSetUp.TESTFIELD("Approved JV Batch");
    //     GenLedgSetUp.TESTFIELD("Approved JV Template");*/

    //     IF ApprovalEntry."Table ID" <> 0 THEN BEGIN
    //         ApprovalEntry.Status := ApprovalEntry.Status::Approved;
    //         ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         ApprovalEntry."Last Modified By ID" := USERID;
    //         ApprovalEntry.MODIFY;
    //         NextApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
    //         NextApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
    //         NextApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //         NextApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
    //         NextApprovalEntry.SETFILTER(Status, '%1|%2', NextApprovalEntry.Status::Created, NextApprovalEntry.Status::Open);
    //         IF NextApprovalEntry.FINDFIRST THEN BEGIN
    //             IF NextApprovalEntry.Status = NextApprovalEntry.Status::Open THEN
    //                 EXIT(FALSE);

    //             NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
    //             NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Modified By ID" := USERID;
    //             NextApprovalEntry.MODIFY;
    //             IF ApprovalSetup.GET THEN
    //                 IF ApprovalSetup.Approvals THEN BEGIN
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //                         IF SalesHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendSalesApprovalsMail(SalesHeader, NextApprovalEntry);
    //                     END ELSE BEGIN
    //                         IF PurchaseHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendPurchaseApprovalsMail(PurchaseHeader, NextApprovalEntry);
    //                     END;

    //                     //BKM 040716 - begin
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //                         GenJournal1.SETFILTER("Journal Template Name", NextApprovalEntry."Journal Template Name");
    //                         GenJournal1.SETFILTER("Journal Batch Name", NextApprovalEntry."Journal Batch Name");
    //                         GenJournal1.SETFILTER("Document No.", NextApprovalEntry."Document No.");
    //                         IF GenJournal1.FINDFIRST THEN
    //                             ApprovalMgtNotification.SendPaymentApprovalsMail(GenJournal1, NextApprovalEntry);
    //                     END;
    //                     //BKM 040716 - end

    //                 END;
    //             EXIT(FALSE);
    //         END;
    //         IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //             IF SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleaseSalesDoc.RUN(SalesHeader);
    //         END ELSE
    //             IF PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleasePurchaseDoc.RUN(PurchaseHeader);

    //         // JCK Payment Journal Approval
    //         IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //             IF GenJournal.FINDFIRST THEN
    //                 REPEAT
    //                     GenJournal.Status := GenJournal.Status::Approved;
    //                     GenJournal.MODIFY;
    //                 UNTIL GenJournal.NEXT = 0;

    //             // Move all approved Entries to a JV batch
    //             ApprovedPmt.SETRANGE(ApprovedPmt."Journal Template Name", 'GENERAL');
    //             ApprovedPmt.SETRANGE(ApprovedPmt."Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             ApprovedPmt.SETRANGE(ApprovedPmt.Status, ApprovedPmt.Status::Approved);
    //             //PmtCode := ApprovalEntry."Bank Batch Number";

    //             NewLineNo := 10000;
    //             GetLastLineNo.SETRANGE(GetLastLineNo."Journal Template Name", GenLedgSetUp."Approved JV Template");
    //             GetLastLineNo.SETRANGE(GetLastLineNo."Journal Batch Name", GenLedgSetUp."Approved JV Batch");
    //             IF GetLastLineNo.FINDLAST THEN
    //                 NewLineNo := GetLastLineNo."Line No.";

    //             /*  IF ApprovedPmt.FINDSET THEN REPEAT
    //                  //NewApprovedPayments."Journal Template Name" := GenLedgSetUp."Approved JV Template";
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments."Journal Template Name",GenLedgSetUp."Approved JV Template");
    //                  //NewApprovedPayments."Journal Batch Name" := GenLedgSetUp."Approved JV Batch";
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments."Journal Batch Name",GenLedgSetUp."Approved JV Batch");
    //                  NewLineNo := NewLineNo + 20000;
    //                  NewApprovedPayments."Line No." := NewLineNo;
    //                  NewApprovedPayments."Account Type" := ApprovedPmt."Account Type";
    //                  NewApprovedPayments."Account No." :=  ApprovedPmt."Account No.";
    //                  NewApprovedPayments."Posting Date" := ApprovedPmt."Posting Date";
    //                  NewApprovedPayments."Document Type" := ApprovedPmt."Document Type";
    //                  NewApprovedPayments."Document No." := ApprovedPmt."Document No.";
    //                  NewApprovedPayments."Bank Batch No." := PmtCode;
    //                  NewDescription := PmtCode +'-'+ ApprovedPmt.Description;
    //                  IF STRLEN(NewDescription) > 50 THEN
    //                    NewDescription := COPYSTR((PmtCode +'-'+ ApprovedPmt.Description),1,50);
    //                  NewApprovedPayments.Description := NewDescription;
    //                  NewApprovedPayments."VAT %" := ApprovedPmt."VAT %";
    //                  NewApprovedPayments."Bal. Account No." := ApprovedPmt."Bal. Account No.";
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments."Currency Code",ApprovedPmt."Currency Code");
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments.Amount,ApprovedPmt.Amount);
    //                  NewApprovedPayments."Posting Group" := ApprovedPmt."Posting Group";
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 1 Code",ApprovedPmt."Shortcut Dimension 1 Code");
    //                  NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 2 Code",ApprovedPmt."Shortcut Dimension 2 Code");
    //                  NewApprovedPayments."Applies-to Doc. Type" := ApprovedPmt."Applies-to Doc. Type";
    //                  NewApprovedPayments."Applies-to Doc. No." := ApprovedPmt."Applies-to Doc. No.";
    //                  NewApprovedPayments."Gen. Posting Type" := ApprovedPmt."Gen. Posting Type";
    //                  NewApprovedPayments."Gen. Bus. Posting Group" := ApprovedPmt."Gen. Bus. Posting Group";
    //                  NewApprovedPayments."Gen. Prod. Posting Group" := ApprovedPmt."Gen. Prod. Posting Group";
    //                  NewApprovedPayments."Document Date" := ApprovedPmt."Document Date";
    //                  NewApprovedPayments."Bal. Account Type" := ApprovedPmt."Bal. Account Type";
    //                  NewApprovedPayments."Cashier ID" := ApprovedPmt."Cashier ID";
    //                  NewApprovedPayments."Advance Code" := ApprovedPmt."Advance Code";
    //                  NewApprovedPayments."Payment Type" := ApprovedPmt."Payment Type";
    //                  NewApprovedPayments."Revenue Stream" := ApprovedPmt."Revenue Stream";
    //                  NewApprovedPayments.Status := ApprovedPmt.Status;
    //                  NewApprovedPayments."Bank Account No." := ApprovedPmt."Bank Account No.";
    //                  NewApprovedPayments."Bank Name" := ApprovedPmt."Bank Name";
    //                  NewApprovedPayments."Vendor Bank Code" := ApprovedPmt."Vendor Bank Code";
    //                  NewApprovedPayments."Bank Code" := ApprovedPmt."Bank Code";
    //                  NewApprovedPayments."Branch Code" := ApprovedPmt."Branch Code";
    //                  NewApprovedPayments.INSERT;
    //               UNTIL ApprovedPmt.NEXT = 0;
    //               // Move All approved entries to a payments batch

    //               // Delete Journal entries from requisitioning batch
    //               RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Template Name",'GENERAL');
    //               RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Batch Name",ApprovalEntry."Journal Batch Name");
    //               RemoveGenJnls.SETRANGE(RemoveGenJnls.Status,ApprovedPmt.Status::Approved);
    //               IF RemoveGenJnls.FINDSET THEN REPEAT
    //                  RemoveGenJnls.DELETE;
    //               UNTIL RemoveGenJnls.NEXT = 0;        */
    //             // Delete Journal entries from requisitioning batch
    //         END;

    //         EXIT(TRUE);
    //     END;

    // end;

    // IE commented all this function
    /// <summary>
    /// Description for ApproveApprovalRequestJV.
    /// </summary>
    /// <param name="ApprovalEntry">Parameter of type Record "454".</param>
    /// <returns>Return variable "Boolean".</returns>
    // procedure ApproveApprovalRequestJV(ApprovalEntry: Record "Approval Entry"): Boolean;
    // var
    //     SalesHeader: Record "36";
    //     PurchaseHeader: Record "38";
    //     ApprovalSetup: Record "452";
    //     NextApprovalEntry: Record "454";
    //     ReleaseSalesDoc: Codeunit "414";
    //     ReleasePurchaseDoc: Codeunit "415";
    //     ApprovalMgtNotification: Codeunit "440";
    //     GenJournal: Record "81";
    //     ApprovedPmt: Record "81";
    //     NewApprovedPayments: Record "81";
    //     GetLastLineNo: Record "81";
    //     RemoveGenJnls: Record "81";
    //     GenJournal1: Record "81";
    // begin
    //     /*GenLedgSetUp.GET;
    //     GenLedgSetUp.TESTFIELD(GenLedgSetUp."Approved JV Batch");
    //     GenLedgSetUp.TESTFIELD(GenLedgSetUp."Approved JV Template");*/

    //     IF ApprovalEntry."Table ID" <> 0 THEN BEGIN
    //         ApprovalEntry.Status := ApprovalEntry.Status::Approved;
    //         ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //         ApprovalEntry."Last Modified By ID" := USERID;
    //         ApprovalEntry.MODIFY;
    //         NextApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
    //         NextApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
    //         NextApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
    //         NextApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
    //         NextApprovalEntry.SETFILTER(Status, '%1|%2', NextApprovalEntry.Status::Created, NextApprovalEntry.Status::Open);
    //         IF NextApprovalEntry.FINDFIRST THEN BEGIN
    //             IF NextApprovalEntry.Status = NextApprovalEntry.Status::Open THEN
    //                 EXIT(FALSE);

    //             NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
    //             NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //             NextApprovalEntry."Last Modified By ID" := USERID;
    //             NextApprovalEntry.MODIFY;
    //             IF ApprovalSetup.GET THEN
    //                 IF ApprovalSetup.Approvals THEN BEGIN
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //                         IF SalesHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendSalesApprovalsMail(SalesHeader, NextApprovalEntry);
    //                     END ELSE BEGIN
    //                         IF PurchaseHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") THEN
    //                             ApprovalMgtNotification.SendPurchaseApprovalsMail(PurchaseHeader, NextApprovalEntry);
    //                     END;
    //                     /*
    //                     //BKM 040716 - begin
    //                     IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //                       GenJournal1.SETFILTER("Journal Template Name", NextApprovalEntry."Journal Template Name");
    //                       GenJournal1.SETFILTER("Journal Batch Name", NextApprovalEntry."Journal Batch Name");
    //                       GenJournal1.SETFILTER("Document No.", NextApprovalEntry."Document No.");
    //                       IF GenJournal1.FINDFIRST THEN
    //                         ApprovalMgtNotification.SendPaymentApprovalsMail(GenJournal1 , NextApprovalEntry);
    //                     END;
    //                     //BKM 040716 - end
    //                     */
    //                 END;
    //             EXIT(FALSE);
    //         END;
    //         IF ApprovalEntry."Table ID" = DATABASE::"Sales Header" THEN BEGIN
    //             IF SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleaseSalesDoc.RUN(SalesHeader);
    //         END ELSE
    //             IF PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") THEN
    //                 ReleasePurchaseDoc.RUN(PurchaseHeader);

    //         // JCK Payment Journal Approval
    //         IF ApprovalEntry."Table ID" = DATABASE::"Gen. Journal Line" THEN BEGIN
    //             GenJournal.SETFILTER("Journal Template Name", ApprovalEntry."Journal Template Name");
    //             GenJournal.SETFILTER("Journal Batch Name", ApprovalEntry."Journal Batch Name");
    //             GenJournal.SETFILTER(GenJournal."Document No.", ApprovalEntry."Document No.");
    //             IF GenJournal.FINDFIRST THEN
    //                 REPEAT
    //                     GenJournal.Status := GenJournal.Status::Approved;
    //                     GenJournal.MODIFY;
    //                 UNTIL GenJournal.NEXT = 0;

    //             // Move all approved Entries to a Payments batch
    //             /* ApprovedPmt.SETRANGE(ApprovedPmt."Journal Template Name",'GENERAL');
    //              ApprovedPmt.SETRANGE(ApprovedPmt."Journal Batch Name",ApprovalEntry."Journal Batch Name");
    //              ApprovedPmt.SETRANGE(ApprovedPmt.Status,ApprovedPmt.Status::Approved);
    //              //PmtCode := ApprovalEntry."Bank Batch Number";

    //              NewLineNo := 10000;

    //              GetLastLineNo.SETRANGE(GetLastLineNo."Journal Template Name",GenLedgSetUp."Approved JV Template");
    //              GetLastLineNo.SETRANGE(GetLastLineNo."Journal Batch Name",GenLedgSetUp."Approved JV Batch");
    //              IF GetLastLineNo.FINDLAST THEN
    //                 NewLineNo := GetLastLineNo."Line No.";

    //              IF ApprovedPmt.FINDSET THEN REPEAT
    //                GenLedgSetUp.GET;
    //                 NewApprovedPayments."Journal Template Name" := GenLedgSetUp."Approved JV Template";
    //                 NewApprovedPayments."Journal Batch Name" := GenLedgSetUp."Approved JV Batch";
    //                 NewLineNo := NewLineNo + 20000;
    //                 NewApprovedPayments."Line No." := NewLineNo;
    //                 NewApprovedPayments."Account Type" := ApprovedPmt."Account Type";
    //                 NewApprovedPayments."Account No." :=  ApprovedPmt."Account No.";
    //                 NewApprovedPayments."Posting Date" := ApprovedPmt."Posting Date";
    //                 NewApprovedPayments."Document Type" := ApprovedPmt."Document Type";
    //                 NewApprovedPayments."Document No." := ApprovedPmt."Document No.";
    //                 NewApprovedPayments."Bank Batch No." := PmtCode;
    //                 NewDescription := PmtCode +'-'+ ApprovedPmt.Description;
    //                 IF STRLEN(NewDescription) > 50 THEN
    //                   NewDescription := COPYSTR((PmtCode +'-'+ ApprovedPmt.Description),1,50);
    //                 NewApprovedPayments.Description := NewDescription;
    //                 NewApprovedPayments."VAT %" := ApprovedPmt."VAT %";
    //                 NewApprovedPayments."Bal. Account No." := ApprovedPmt."Bal. Account No.";
    //                 NewApprovedPayments.VALIDATE(NewApprovedPayments."Currency Code",ApprovedPmt."Currency Code");
    //                 NewApprovedPayments.VALIDATE(NewApprovedPayments.Amount,ApprovedPmt.Amount);
    //                 NewApprovedPayments."Posting Group" := ApprovedPmt."Posting Group";
    //                 NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 1 Code",ApprovedPmt."Shortcut Dimension 1 Code");
    //                 NewApprovedPayments.VALIDATE(NewApprovedPayments."Shortcut Dimension 2 Code",ApprovedPmt."Shortcut Dimension 2 Code");
    //                 NewApprovedPayments."Applies-to Doc. Type" := ApprovedPmt."Applies-to Doc. Type";
    //                 NewApprovedPayments."Applies-to Doc. No." := ApprovedPmt."Applies-to Doc. No.";
    //                 NewApprovedPayments."Gen. Posting Type" := ApprovedPmt."Gen. Posting Type";
    //                 NewApprovedPayments."Gen. Bus. Posting Group" := ApprovedPmt."Gen. Bus. Posting Group";
    //                 NewApprovedPayments."Gen. Prod. Posting Group" := ApprovedPmt."Gen. Prod. Posting Group";
    //                 NewApprovedPayments."Document Date" := ApprovedPmt."Document Date";
    //                 NewApprovedPayments."Bal. Account Type" := ApprovedPmt."Bal. Account Type";
    //                 NewApprovedPayments."Cashier ID" := ApprovedPmt."Cashier ID";
    //                 NewApprovedPayments."Advance Code" := ApprovedPmt."Advance Code";
    //                 NewApprovedPayments."Payment Type" := ApprovedPmt."Payment Type";
    //                 NewApprovedPayments."Revenue Stream" := ApprovedPmt."Revenue Stream";
    //                 NewApprovedPayments.Status := ApprovedPmt.Status;
    //                 NewApprovedPayments."Bank Account No." := ApprovedPmt."Bank Account No.";
    //                 NewApprovedPayments."Bank Name" := ApprovedPmt."Bank Name";
    //                 NewApprovedPayments."Vendor Bank Code" := ApprovedPmt."Vendor Bank Code";
    //                 NewApprovedPayments."Bank Code" := ApprovedPmt."Bank Code";
    //                 NewApprovedPayments."Branch Code" := ApprovedPmt."Branch Code";
    //                 NewApprovedPayments.JV := ApprovedPmt.JV;
    //                 NewApprovedPayments."Prepared By" := ApprovedPmt."Prepared By";
    //                 NewApprovedPayments.INSERT;
    //              UNTIL ApprovedPmt.NEXT = 0;
    //              // Move All approved entries to a payments batch

    //              // Delete Journal entries from requisitioning batch
    //              RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Template Name",'GENERAL');
    //              RemoveGenJnls.SETRANGE(RemoveGenJnls."Journal Batch Name",ApprovalEntry."Journal Batch Name");
    //              RemoveGenJnls.SETRANGE(RemoveGenJnls.Status,ApprovedPmt.Status::Approved);
    //              IF RemoveGenJnls.FINDSET THEN REPEAT
    //                 RemoveGenJnls.DELETE;
    //              UNTIL RemoveGenJnls.NEXT = 0;   */
    //             // Delete Journal entries from requisitioning batch
    //         END;

    //         EXIT(TRUE);
    //     END;

    // end;

    // IE commented all this function
    /// <summary>
    /// Description for GetJVDialogText.
    /// </summary>
    /// <param name="ActionType">Parameter of type Option SendJVApproval,CancelJVApproval.</param>
    /// <param name="LinesQty">Parameter of type Integer.</param>
    /// <returns>Return variable "Text[100]".</returns>
    // procedure GetJVDialogText(ActionType: Option SendJVApproval,CancelJVApproval; LinesQty: Integer): Text[100];
    // begin
    //     CASE ActionType OF
    //         ActionType::SendJVApproval:
    //             EXIT(STRSUBSTNO(Text145, LinesQty));
    //         ActionType::CancelJVApproval:
    //             EXIT(STRSUBSTNO(Text146, LinesQty));
    //     END;
    // end;

    // IE commented all this function
    /// <summary>
    /// Description for GetJVDialogInstruction.
    /// </summary>
    /// <param name="ActionType">Parameter of type Option SendJVApproval,CancelJVApproval.</param>
    /// <returns>Return variable "Text[100]".</returns>
    // procedure GetJVDialogInstruction(ActionType: Option SendJVApproval,CancelJVApproval): Text[100];
    // begin
    //     CASE ActionType OF
    //         ActionType::SendJVApproval:
    //             EXIT(Text147);
    //         ActionType::CancelJVApproval:
    //             EXIT(Text148);
    //     END;
    // end;

    // IE commented all this function
    /// <summary>
    /// Description for CancelJVApprovalRequest.
    /// </summary>
    /// <param name="GenJournal">Parameter of type Record "81".</param>
    /// <param name="ShowMessage">Parameter of type Boolean.</param>
    /// <param name="ManualCancel">Parameter of type Boolean.</param>
    // procedure CancelJVApprovalRequest(var GenJournal: Record "Gen. Journal Line"; ShowMessage: Boolean; ManualCancel: Boolean) Cancelled: Boolean;
    // var
    //     ApprovalEntry: Record "454";
    //     ApprovalSetup: Record "452";
    //     AppManagement: Codeunit "440";
    //     SendMail: Boolean;
    //     MailCreated: Boolean;
    //     ApprovalEntry2: Record "454";
    //     GenJournal2: Record "81";
    // begin
    //     //Journal Approval only for Payments and purchase line items.
    //     //GMT 071217
    //     IF gvUserSetup.GET(USERID) THEN
    //         IF NOT gvUserSetup."Cancel Approved JV" THEN BEGIN
    //             //GMT
    //             IF ((GenJournal.Status = GenJournal.Status::Open) OR (GenJournal.Status = GenJournal.Status::Approved)) THEN
    //                 EXIT;
    //             //GMT 071217
    //         END ELSE BEGIN
    //             IF (GenJournal.Status = GenJournal.Status::Open) THEN
    //                 EXIT;
    //         END;
    //     //GMT
    //     TestSetup;

    //     IF NOT ApprovalSetup.GET THEN
    //         ERROR(Text004);

    //     WITH GenJournal DO BEGIN

    //         ApprovalEntry2.SETRANGE("Table ID", 81);
    //         ApprovalEntry2.SETRANGE("Document Type", GenJournal."Document Type");
    //         ApprovalEntry2.SETRANGE("Document No.", GenJournal."Document No.");
    //         ApprovalEntry2.SETFILTER(Status, '%1|%2', ApprovalEntry2.Status::Open, ApprovalEntry2.Status::Approved);
    //         IF ApprovalEntry2.FINDFIRST THEN
    //             REPEAT BEGIN
    //                 ApprovalEntry2.Status := ApprovalEntry2.Status::Canceled;
    //                 ApprovalEntry2."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
    //                 ApprovalEntry2."Last Modified By ID" := USERID;
    //                 ApprovalEntry2.MODIFY;
    //                 IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                     AppManagement.SendPaymentCancellationsMail(GenJournal, ApprovalEntry);
    //                     MailCreated := TRUE;
    //                     SendMail := FALSE;
    //                 END;
    //             END;
    //             UNTIL ApprovalEntry2.NEXT = 0;
    //         IF MailCreated THEN BEGIN
    //             AppManagement.SendMail;
    //             MailCreated := FALSE;
    //         END;

    //         GenJournal.Status := GenJournal.Status::Open;
    //         GenJournal.MODIFY;
    //         // END;
    //         Cancelled := TRUE;
    //         /* IF GenJournal.Status = GenJournal.Status::"Pending Approval" THEN
    //            ApprovalEntry2.SETRANGE(Status , Status::Open);
    //          ApprovalEntry2.SETRANGE("Document No." , GenJournal."Document No.");

    //          {
    //          ApprovalEntry.SETCURRENTKEY("Table ID","Document Type","Document No.","Sequence No.");
    //          ApprovalEntry.SETRANGE("Table ID",81);
    //          ApprovalEntry.SETRANGE("Document Type","Document Type");
    //          ApprovalEntry.SETRANGE("Document No.","Document No.");
    //          //ApprovalEntry.SETFILTER(Status,'<>%1&<>%2',ApprovalEntry.Status::Rejected,ApprovalEntry.Status::Canceled);
    //          ApprovalEntry.SETRANGE(Status,ApprovalEntry.Status::Open);
    //          }
    //          SendMail := FALSE;
    //          IF ApprovalEntry2.FINDFIRST THEN BEGIN
    //          //IF ApprovalEntry.FINDFIRST THEN BEGIN
    //            MESSAGE('Hello!!!@@@#');
    //            REPEAT
    //              IF (ApprovalEntry.Status = ApprovalEntry.Status::Open) OR
    //                 (ApprovalEntry.Status = ApprovalEntry.Status::Approved) THEN
    //                 SendMail := TRUE;

    //              ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
    //              ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY,TIME);
    //              ApprovalEntry."Last Modified By ID" := USERID;
    //              ApprovalEntry.MODIFY;
    //              IF ApprovalSetup.Cancellations AND ShowMessage AND SendMail THEN BEGIN
    //                AppManagement.SendPaymentCancellationsMail(GenJournal,ApprovalEntry);
    //                MailCreated := TRUE;
    //                SendMail := FALSE;
    //              END;
    //            UNTIL ApprovalEntry.NEXT = 0;
    //            IF MailCreated THEN BEGIN
    //              AppManagement.SendMail;
    //              MailCreated := FALSE;
    //            END;
    //          END;

    //          IF ManualCancel OR (NOT ManualCancel AND NOT (Status = Status::"4")) THEN
    //            Status := Status::Open;
    //          MODIFY(TRUE);
    //        END;*/
    //         //IF ShowMessage THEN
    //         // MESSAGE(Text002,GenJournal."Document Type",GenJournal."Document No.");
    //     END;

    // end;
}

