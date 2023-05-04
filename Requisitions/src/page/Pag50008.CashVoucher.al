/// <summary>
/// Page Cash Voucher (ID 50052).
/// </summary>
page 50008 "Cash Voucher"
{
    Caption = 'Cash Voucher';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Home,Delegate,Attachments';
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    SourceTableView = WHERE("Document Type" = CONST("Cash Voucher"));

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

                        // MAG 08 AUG. 2018, Validate budget checks.
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
                        // MAG - END.
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
                }
            }
            part(Details; "Cash Voucher Details Subform")
            {
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
                UpdatePropagation = Both;
            }
            part(Lines; "Cash Voucher Lines Subform")
            {
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
                UpdatePropagation = Both;
                Visible = PaymentVoucherLinesVisible;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachments Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50031),
                              "No." = FIELD("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
            part("Budget Analysis As at Date"; "CashBudget Analysis As at Date")
            {
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Monthly Budget Analysis"; "Cash Monthly Budget Analysis")
            {
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Quarterly Budget Analysis"; "Cash Quarterly Budget Analysis")
            {
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("Annual Budget Analysis"; "Cash Annual Budget Analysis")
            {
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No."),
                              "Control Account" = FIELD("Control Account");
            }
            part("<Cash Budget Analysis Fact Box>"; "Cash Budget Analysis Fact Box")
            {
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
            group("Request Approval")
            {
                Caption = 'Request Approval';
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
                action("List of All Approval Entries")
                {
                    Caption = '&List of All Approval Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Process;
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
                    PromotedIsBig = true;
                    // RunObject = page "NFL Approval Comments";
                    // RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50075); TODO:Review these comments
                }

                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Enabled = Rec."No." <> '';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim;
                        CurrPage.SaveRecord;
                    end;
                }
                action("Print Payment Requisition")
                {
                    Image = PrintDocument;
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
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.TESTFIELD(Status, Rec.Status::Released);
                        Rec.TESTFIELD("Transferred to Journals", TRUE);
                        IF NOT CONFIRM('Do you really want to archieve the selected document?', FALSE) THEN
                            EXIT;
                        // PaymentVoucherHeader.ArchiveRequisition(Rec);
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
        // MAG 08 AUG. 2018, Validate budget checks.
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
        // MAG - END.
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
        //WshShell: Automation "{F935DC20-1CF0-11D0-ADB9-00C04FD58A0B} 1.0:{72C24DD5-D70A-438B-8A42-98424B88AFB8}:'Windows Script Host Object Model'.WshShell";
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GeneralLedgerSetup: Record "General Ledger Setup";
        TotalPaymentVoucherDetailsAmount: Decimal;
        TotalPaymentVoucherLinesAmount: Decimal;
        Text018: Label 'You must delete the existing payment voucher lines before you can change the currency code and spot rates';
        CUstp: Record "User Setup";

    /// <summary>
    /// Description for ArePaymentVoucherLinesVisible.
    /// </summary>
    local procedure ArePaymentVoucherLinesVisible();
    begin
        // MAG 20TH JULY 2018, Toggle Visibility of Subforms basing on the Payment Voucher Status.
        IF Rec.Status = Rec.Status::Open THEN BEGIN
            PaymentVoucherLinesVisible := FALSE;
        END ELSE BEGIN
            PaymentVoucherLinesVisible := TRUE;
        END;
        // MAG - END.
    end;
}

