/// <summary>
/// Page Cash Voucher (ID 50146).
/// </summary>
page 50040 "Voucher Form"
{
    // version

    Caption = 'Cash Voucher';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Delegate,Attachments';
    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit();
                    begin
                        IF Rec.AssistEdit(xRec) THEN
                            CurrPage.UPDATE;
                    end;

                    trigger OnValidate();
                    begin
                        IF Rec."No." <> xRec."No." THEN BEGIN
                            PurchPaySetup.GET;
                            NoSeriesMgt.TestManual(PurchPaySetup."Cash Voucher Nos.");
                            Rec."No. Series" := '';
                        END;
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Payee No."; Rec."Payee No.")
                {
                    ApplicationArea = All;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Hub Code"; Rec."Hub Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Balancing Entry"; Rec."Balancing Entry")
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
                field("Prepared by"; Rec."Prepared by")
                {
                    ApplicationArea = All;
                }
                field("Received by"; Rec."Received by")
                {
                    ApplicationArea = All;
                }
                field("Accountability Comment"; Rec."Accountability Comment")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnAssistEdit();
                    var
                        lvPayVouchLine: Record "Payment Voucher Line";
                    begin
                        CLEAR(ChangeExchangeRate);
                        IF Rec."Posting Date" <> 0D THEN
                            ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date")
                        ELSE
                            ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", WORKDATE);
                        IF ChangeExchangeRate.RUNMODAL = ACTION::OK THEN BEGIN
                            Rec.VALIDATE("Currency Factor", ChangeExchangeRate.GetParameter);
                            CurrPage.UPDATE;
                        END;
                        CLEAR(ChangeExchangeRate);

                        IF Rec."Currency Factor" <> xRec."Currency Factor" THEN
                            Rec.UpdatePaymentVoucherLines(Rec.FIELDCAPTION("Currency Factor"));

                        IF Rec."Currency Factor" <> xRec."Currency Factor" THEN BEGIN
                            IF Rec.PaymentVoucherLinesExist THEN
                                ERROR(Text018, Rec.FIELDCAPTION("Currency Code"));
                        END;

                        //Validate budget checks.
                        lvPayVouchLine.RESET;
                        lvPayVouchLine.SETRANGE("Document No.", Rec."No.");
                        lvPayVouchLine.LOCKTABLE;
                        IF lvPayVouchLine.FIND('-') THEN
                            REPEAT
                                lvPayVouchLine."Accounting Period Start Date" := Rec."Accounting Period Start Date";
                                lvPayVouchLine."Accounting Period End Date" := Rec."Accounting Period End Date";
                                lvPayVouchLine."Fiscal Year Start Date" := Rec."Fiscal Year Start Date";
                                lvPayVouchLine."Fiscal Year End Date" := Rec."Fiscal Year End Date";
                                lvPayVouchLine."Filter to Date Start Date" := Rec."Filter to Date Start Date";
                                lvPayVouchLine."Filter to Date End Date" := Rec."Filter to Date End Date";
                                lvPayVouchLine."Quarter Start Date" := Rec."Quarter Start Date";
                                lvPayVouchLine."Quarter End Date" := Rec."Quarter End Date";
                                lvPayVouchLine.VALIDATE("Filter to Date Start Date");
                                lvPayVouchLine.VALIDATE("Filter to Date End Date");
                                lvPayVouchLine.VALIDATE("Fiscal Year Start Date");
                                lvPayVouchLine.VALIDATE("Fiscal Year End Date");
                                lvPayVouchLine.VALIDATE("Quarter Start Date");
                                lvPayVouchLine.VALIDATE("Quarter End Date");

                                lvPayVouchLine.VALIDATE("Balance on Budget for the Year");
                                lvPayVouchLine.VALIDATE("Bal. on Budget for the Quarter");
                                lvPayVouchLine.VALIDATE("Bal. on Budget for the Month");
                                lvPayVouchLine.VALIDATE("Balance on Budget as at Date");
                                lvPayVouchLine.MODIFY;
                            UNTIL lvPayVouchLine.NEXT = 0;
                        //  - END.
                        CurrPage.UPDATE;
                    end;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field(Archieved; Rec.Archieved)
                {
                    ApplicationArea = All;
                }
                field(Commited; Rec.Commited)
                {
                    ApplicationArea = All;
                }
                field("Bank File Generated"; Rec."Bank File Generated")
                {
                    ApplicationArea = All;
                }
                field("Transferred to Journals"; Rec."Transferred to Journals")
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Details Total"; Rec."Payment Voucher Details Total")
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Lines Total"; Rec."Payment Voucher Lines Total")
                {
                    ApplicationArea = All;
                }
                field("Has Links"; Rec."Has Links")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Budget At Date Exceeded"; Rec."Budget At Date Exceeded")
                {
                    ToolTip = 'Specifies the value of the Budget At Date Exceeded field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quarter Budget Exceeded"; Rec."Quarter Budget Exceeded")
                {
                    ToolTip = 'Specifies the value of the Quarter Budget Exceeded field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Month Budget Exceeded"; Rec."Month Budget Exceeded")
                {
                    ToolTip = 'Specifies the value of the Month Budget Exceeded field';
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
            part(Details; "Voucher Details Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
                UpdatePropagation = Both;
            }
            part(Lines; "Voucher Lines Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachments Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50001),
                              "No." = FIELD("No.");
            }
            part("Budget Analysis As at Date"; "CashBudget Analysis As at Date")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Monthly Budget Analysis"; "Cash Monthly Budget Analysis")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Quarterly Budget Analysis"; "Cash Quarterly Budget Analysis")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Annual Budget Analysis"; "Cash Annual Budget Analysis")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("<Cash Budget Analysis Fact Box>"; "Cash Budget Analysis Fact Box")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
        }

    }

    actions
    {
        area(processing)
        {
            group("Manage Vouchers")
            {
                Caption = 'Manage Vouchers';
                Image = SendApprovalRequest;
                action("Approval Entries")
                {
                    Caption = '&Approval Entries';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Enabled = true;
                    ApplicationArea = all;
                    RunObject = Page "NV Approval Entries";
                    RunPageLink = "Document No." = FIELD("No.");
                    RunPageView = WHERE(Status = FILTER(Open | Created | Approved));
                }
                action("List of All Approval Entries")
                {
                    Caption = '&List of All Approval Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;
                    Enabled = true;
                    RunObject = Page "All NV Approval Entries";
                    RunPageLink = "Document No." = FIELD("No.");
                }
                action(Comments)
                {
                    Image = Comment;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;
                    // RunObject = page "NFL Approval Comments";
                    // RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50075);
                }
                action("Print Payment Requisition")
                {
                    Image = PrintDocument;
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        PaymentVoucherHeader: Record "Payment Voucher Header";
                        ChequePaymentVoucher: Report "Cheque Payment Voucher";
                    begin
                        PaymentVoucherHeader.RESET;
                        PaymentVoucherHeader.SETRANGE("No.", Rec."No.");
                        ChequePaymentVoucher.SETTABLEVIEW(PaymentVoucherHeader);
                        ChequePaymentVoucher.RUN();
                    end;
                }
                action("Transfer Payee Lines to Journal")
                {
                    Image = TransferToGeneralJournal;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        PaymentVoucherLine: Record "Payment Voucher Line";
                    begin
                        PaymentVoucherHeader.TransferPayeeLinesToJournal(Rec);
                    end;
                }
                action("Generate Bank File")
                {
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;
                    RunObject = Report "Generate Bank Payment 1";

                    trigger OnAction();
                    var
                        lvGenJnlLine: Record "Gen. Journal Line";
                        lvPaymentVoucherHeader: Record "Payment Voucher Header";
                    begin
                    end;
                }
                action("Archive Voucher")
                {
                    Image = Archive;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.TESTFIELD(Status, Rec.Status::Released);
                        Rec.TESTFIELD("Transferred to Journals", TRUE);
                        IF NOT CONFIRM('Do you really want to archieve the selected document?', FALSE) THEN
                            EXIT;
                        PaymentVoucherHeader.ArchiveRequisition(Rec);
                    end;
                }

                action(DocAttach1)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attached Vouchers";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }
            }

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
                        CustomFunctions: Codeunit "Custom Functions Cash";
                    begin
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
                        end;
                        Rec.CheckVoucherRelease(Rec);
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
                        CustomFunctions: Codeunit "Custom Functions Cash";
                    // ApprovalComments: Record "NFL Approval Comment Line";TODO:
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
                            //send Email implemented
                            CustomFunctions.RejectApprovalRequest(Rec);
                            // end else begin
                            //     ApprovalComments2.Reset();
                            //     ApprovalComments2.SetRange(ApprovalComments2."Document No.", Rec."No.");
                            //     ApprovalComments2.SetRange(ApprovalComments2."Document Type", Rec."Document Type");
                            //     ApprovalComments2.SetRange(ApprovalComments2."Table ID", Database::"Payment Voucher Header");
                            //     approvalComment.SetTableView(ApprovalComments2);
                            //     approvalComment.Run();
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
                        CustomFunctions: Codeunit "Custom Functions Cash";
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
                        CustomFunctions: Codeunit "Custom Functions Cash";
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
    }

    trigger OnAfterGetCurrRecord();
    begin
        ArePaymentVoucherLinesVisible;
    end;

    trigger OnAfterGetRecord();
    var
        lvPayVouchLine: Record "Payment Voucher Line";
    begin
        ArePaymentVoucherLinesVisible;
        Rec.VALIDATE("Has Links", Rec.HASLINKS);
        OpenApprovalEntriesExistForcurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    trigger OnModifyRecord(): Boolean;
    begin
        IF Rec."Posting Date" <> 0D THEN Rec.VALIDATE("Posting Date");
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        PurchPaySetup.GET;
        PurchPaySetup.TESTFIELD(PurchPaySetup."Cash Voucher Nos.");
        Rec."No." := NoSeriesMgt.GetNextNo(PurchPaySetup."Cash Voucher Nos.", TODAY, TRUE);
        Rec.VALIDATE("Document Type", Rec."Document Type"::"Cash Voucher");
        Rec.VALIDATE("Prepared by", USERID);
        Rec.VALIDATE("Posting Date", WORKDATE);
        GeneralLedgerSetup.GET;
        GeneralLedgerSetup.TESTFIELD("Approved Budget");
        Rec.VALIDATE("Budget Code", GeneralLedgerSetup."Approved Budget");
        Rec.VALIDATE("Has Links", Rec.HASLINKS);
    end;

    trigger OnNextRecord(Steps: Integer): Integer;
    var
        lvPayVouchLine: Record "Payment Voucher Line";
    begin
    end;

    trigger OnOpenPage();
    var
        lvPayVouchLine: Record "Payment Voucher Line";
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

        //Validate budget checks.
        IF Rec."Posting Date" <> 0D THEN Rec.VALIDATE("Posting Date");
        ArePaymentVoucherLinesVisible;
        Rec.VALIDATE("Has Links", Rec.HASLINKS);
        lvPayVouchLine.RESET;
        lvPayVouchLine.SETRANGE("Document No.", Rec."No.");
        lvPayVouchLine.SETRANGE("Document Type", Rec."Document Type");
        lvPayVouchLine.LOCKTABLE;
        IF lvPayVouchLine.FIND('-') THEN
            REPEAT

                lvPayVouchLine."Accounting Period Start Date" := Rec."Accounting Period Start Date";
                lvPayVouchLine."Accounting Period End Date" := Rec."Accounting Period End Date";
                lvPayVouchLine."Fiscal Year Start Date" := Rec."Fiscal Year Start Date";
                lvPayVouchLine."Fiscal Year End Date" := Rec."Fiscal Year End Date";
                lvPayVouchLine."Filter to Date Start Date" := Rec."Filter to Date Start Date";
                lvPayVouchLine."Filter to Date End Date" := Rec."Filter to Date End Date";
                lvPayVouchLine."Fiscal Year Start Date" := Rec."Fiscal Year Start Date";
                lvPayVouchLine."Fiscal Year End Date" := Rec."Fiscal Year End Date";
                lvPayVouchLine."Quarter Start Date" := Rec."Quarter Start Date";
                lvPayVouchLine."Quarter End Date" := Rec."Quarter End Date";

                lvPayVouchLine.VALIDATE("Accounting Period Start Date");
                lvPayVouchLine.VALIDATE("Accounting Period End Date");
                lvPayVouchLine.VALIDATE("Fiscal Year Start Date");
                lvPayVouchLine.VALIDATE("Fiscal Year End Date");
                lvPayVouchLine.VALIDATE("Filter to Date Start Date");
                lvPayVouchLine.VALIDATE("Filter to Date End Date");
                lvPayVouchLine.VALIDATE("Fiscal Year Start Date");
                lvPayVouchLine.VALIDATE("Fiscal Year End Date");
                lvPayVouchLine.VALIDATE("Quarter Start Date");
                lvPayVouchLine.VALIDATE("Quarter End Date");

                lvPayVouchLine.VALIDATE("Balance on Budget for the Year");
                lvPayVouchLine.VALIDATE("Bal. on Budget for the Quarter");
                lvPayVouchLine.VALIDATE("Bal. on Budget for the Month");
                lvPayVouchLine.VALIDATE("Balance on Budget as at Date");
                lvPayVouchLine.MODIFY;
                CurrPage.UPDATE;
            UNTIL lvPayVouchLine.NEXT = 0;
        //END.
    end;

    var
        Text001: Label 'Total Payee amount is less total Expenditure amount by %1. Are you sure you want to transfer the entries to the journal';
        Text002: Label 'Status for No %1 must be Released in order to archive this Requisition';
        Text003: Label 'You are not permitted to Archieve  document No. %1';
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        // NFLApprovalsManagement: Codeunit "NFL Approvals Management";
        [InDataSet]
        PaymentVoucherLinesVisible: Boolean;
        ChangeExchangeRate: Page "Change Exchange Rate";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        DocumentNo: Code[20];
        SelectTemplateBatch: Report "Select Template & Batch";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        gvJournalTemplateName: Code[20];
        gvJournalBatchName: Code[20];
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GeneralLedgerSetup: Record "General Ledger Setup";
        TotalPaymentVoucherDetailsAmount: Decimal;
        TotalPaymentVoucherLinesAmount: Decimal;
        Text018: Label 'You must delete the existing payment voucher lines before you can change the currency code and spot rates';
        CUstp: Record "User Setup";

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

    /// <summary>
    /// Description for ArePaymentVoucherLinesVisible.
    /// </summary>
    local procedure ArePaymentVoucherLinesVisible();
    begin
        // Toggle Visibility of Subforms basing on the Payment Voucher Status.
        IF Rec.Status = Rec.Status::Open THEN BEGIN
            PaymentVoucherLinesVisible := FALSE;
        END ELSE BEGIN
            PaymentVoucherLinesVisible := TRUE;
        END;
        //END.
    end;
}

