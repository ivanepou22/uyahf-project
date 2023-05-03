/// <summary>
/// Page Purchase Requisition (ID 50235).
/// </summary>
page 50043 "Requisition Approval Form"
{
    // version NFL02.002

    Caption = 'Purchase Requisition';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "NFL Requisition Header";
    SourceTableView = WHERE("Document Type" = FILTER("Purchase Requisition" | "Cash Voucher"));
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Release,Home';
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    Editable = EditPage;

                    trigger OnAssistEdit();
                    begin
                        IF AssistEdit(xRec) THEN
                            CurrPage.UPDATE;
                    end;
                }
                field("Request-By No."; "Request-By No.")
                {
                    Editable = EditPage;
                }
                field("Request-By Name"; "Request-By Name")
                {
                    Editable = EditPage;
                }
                field("Posting Date"; "Posting Date")
                {
                    Editable = EditPage;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Wrks/Srvcs/Sup"; "Wrks/Srvcs/Sup")
                {
                    Editable = EditPage;
                }
                field("PD Entity"; "PD Entity")
                {
                }
                field("Procument Plan Reference"; "Procument Plan Reference")
                {
                }
                group("Budget Analysis1")
                {
                    Editable = EditPage;
                    Caption = 'Budget Analysis';
                    field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                    {
                    }
                    field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                    {
                    }
                    field("Hub Code"; "Hub Code")
                    {
                        ApplicationArea = All;
                    }

                    field("Budget Code"; "Budget Code")
                    {
                    }
                }
                field("Posting Description"; "Posting Description")
                {
                    Caption = 'Subject of Procurement';
                    Editable = EditPage;
                }
                field("Location Code"; "Location Code")
                {
                    Editable = EditPage;
                }
                field("Order Date"; "Order Date")
                {
                    Caption = 'Request Date';
                    Editable = EditPage;
                }
                field("Document Date"; "Document Date")
                {
                    Editable = EditPage;
                }
                field("Requested Receipt Date"; "Requested Receipt Date")
                {
                    Editable = EditPage;
                }
                field("Currency Code"; "Currency Code")
                {
                    Editable = EditPage;

                    trigger OnAssistEdit();
                    var
                        lvNFLRequisitionLine: Record "NFL Requisition Line";
                    begin

                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date");
                        IF ChangeExchangeRate.RUNMODAL = ACTION::OK THEN
                            VALIDATE("Currency Factor", ChangeExchangeRate.GetParameter);

                        CLEAR(ChangeExchangeRate);


                    end;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field(Status; Status)
                {
                }
                field("Valid to Date"; "Valid to Date")
                {
                    Editable = EditPage;
                }
                field("Converted to Order"; "Converted to Order")
                {
                    Editable = EditPage;
                }
                field("Converted to Quote"; "Converted to Quote")
                {
                }
                field(Commited; Commited)
                {
                }
                field(Archieved; Archieved)
                {
                }
                field("Prepared by"; "Prepared by")
                {
                }
                field("Requisition Details Total"; "Requisition Details Total")
                {
                }
                field("Requisition Lines Total"; "Requisition Lines Total")
                {
                }
            }
            part("Requisition Details"; "Purchase Requisition Details S")
            {
                Editable = EditPage;
                SubPageLink = "Document No." = FIELD("No.");
            }
            part(PurchLines; "Purchase Requisition Subform")
            {
                SubPageLink = "Document No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Budget Analysis As at Date"; "Budget Analysis As at Date")
            {
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Control Account" = FIELD("Control Account"),
                              "Line No." = FIELD("Line No.");
            }
            part("Monthly Budget Analysis"; "Monthly Budget Analysis")
            {
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Control Account" = FIELD("Control Account"),
                              "Line No." = FIELD("Line No.");
            }
            part("Quarterly Budget Analysis"; "Quarterly Budget Analysis")
            {
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Control Account" = FIELD("Control Account"),
                              "Line No." = FIELD("Line No.");
            }
            part("Annual Budget Analysis"; "Annual Budget Analysis")
            {
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Control Account" = FIELD("Control Account"),
                              "Line No." = FIELD("Line No.");
            }
            part("Budget Analysis"; "Budget Analysis Fact Box")
            {
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Control Account" = FIELD("Control Account"),
                              "Line No." = FIELD("Line No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Requisition")
            {
                Caption = '&Requisition';
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Employee Card";
                    RunPageLink = "No." = FIELD("Request-By No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = page "NFL Approval Comments";
                    RunPageLink = "Document No." = field("No."), "Document Type" = field("Document Type"), "Table ID" = const(50069);
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction();
                    begin
                        Rec.ShowDocDim;
                    end;
                }
                action(Approvals)
                {
                    Caption = 'Approvals';
                    Image = Approvals;
                    Visible = false;
                    trigger OnAction();
                    var
                        ApprovalEntries: Page "NFL Approval Entries";
                    begin
                        ApprovalEntries.Setfilters(DATABASE::"NFL Requisition Header", "Document Type", "No.");
                        ApprovalEntries.RUN;
                    end;
                }
                action("NFL Approval Entries History")
                {
                    Caption = 'NFL Approval Entries History';
                    Image = "Action";

                }
                separator(separator)
                {
                }
                group("Cross Referencing")
                {
                    Caption = 'Cross Referencing';
                    action("Store Req.")
                    {
                        Caption = 'Store Req.';
                    }
                    action("Archived Store Req.")
                    {
                        Caption = 'Archived Store Req.';
                    }
                    action("Archived Purchase Req.")
                    {
                        Caption = 'Archived Purchase Req.';
                    }
                    action("Purchase Quote")
                    {
                        Caption = 'Purchase Quote';
                        Image = Quote;
                        RunObject = Page "Purchase List";
                        RunPageLink = "Purchase Requisition No." = FIELD("No.");
                        RunPageView = SORTING("Document Type", "No.")
                                      WHERE("Document Type" = CONST(Quote));
                    }
                    action("Purchase Orders")
                    {
                        Caption = 'Purchase Orders';
                        RunObject = Page "Purchase List";
                        RunPageLink = "Purchase Requisition No." = FIELD("No.");
                        RunPageView = SORTING("Document Type", "No.")
                                      WHERE("Document Type" = CONST(Order));
                    }
                    action("Purchase Receipts")
                    {
                        Caption = 'Purchase Receipts';
                        RunObject = Page "Posted Purchase Receipts";
                    }
                    action("Posted Purchase Invoices")
                    {
                        Caption = 'Posted Purchase Invoices';
                        RunObject = Page "Posted Purchase Invoices";
                    }
                }
                action("Revision Log")
                {
                    Caption = 'Revision Log';
                    // RunObject = Page 51402644; IE
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                separator(separator1)
                {
                }
                action("Archi&ve Document")
                {
                    Caption = 'Archi&ve Document';
                    Image = Archive;
                    Promoted = true;
                    PromotedCategory = Category8;
                    trigger OnAction();
                    var
                        lvPurchLine: Record "NFL Requisition Line";
                        lvPurchReqHeader: Record "NFL Requisition Header";
                    begin
                        gvUserSetup.SETRANGE(gvUserSetup."User ID", USERID);
                        IF gvUserSetup.FIND('-') THEN BEGIN
                            IF gvUserSetup."Archive Document" = FALSE THEN
                                ERROR(Text0025);
                        END
                        ELSE
                            ERROR(Text0026);

                        IF CONFIRM(Text0023) THEN BEGIN
                            TESTFIELD("Converted to Order", true);
                            IF CONFIRM(Text0024) THEN BEGIN
                                StorePurchDocument(Rec, TRUE);   // Archives a Purchase Requisition
                                CurrPage.UPDATE(FALSE);
                                lvPurchLine.SETFILTER("Document Type", FORMAT(Rec."Document Type"::"Purchase Requisition"));
                                lvPurchLine.SETFILTER("Document No.", "No.");
                                IF lvPurchLine.FINDFIRST THEN
                                    lvPurchLine.DELETEALL;

                                Rec.DELETE(TRUE);
                            END;
                        END;
                    end;
                }
                separator(separator2)
                {
                }
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
                    PromotedIsBig = true;
                    Enabled = true;
                    RunObject = Page "All NV Approval Entries";
                    RunPageLink = "Document No." = FIELD("No.");

                    trigger OnAction();
                    var
                    // ApprovalEntry: Record "NFL Approval Entry";
                    begin
                    end;
                }
                action("Approval Request Entries")
                {
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Category8;
                    Visible = false;
                    PromotedIsBig = true;
                    RunObject = Page "Approval Entries";
                    RunPageLink = "Document No." = FIELD("No.");
                }
                separator(".......")
                {
                }
                separator(".....")
                {
                }
                action("Make Order")
                {
                    Caption = 'Make Order';
                    Image = MakeOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        // ApprovalMgt: Codeunit "NFL Approvals Management";
                        BankReconn: Record "Bank Acc. Reconciliation";
                        PaymentJnl: Record "Gen. Journal Line";
                        NflReqnLine: Record "NFL Requisition Line";
                        Int: Integer;
                        n: Integer;
                    begin
                        // Chech whether the requistion has not yet been converted to an order.
                        //To check if all lines have been converted into Purchase orders
                        NflReqnLine.RESET;
                        NflReqnLine.SETRANGE(NflReqnLine."Document No.", "No.");
                        Int := NflReqnLine.COUNT;
                        FOR n := 1 TO Int DO BEGIN
                            NflReqnLine.SETRANGE(Converted, FALSE);
                            IF NflReqnLine.FINDFIRST THEN BEGIN
                                IF NflReqnLine.Convert = FALSE THEN;
                            END ELSE
                                ERROR('This Purchase Requisition Has been fully converted into an Order(s)');
                        END;

                        IF ("Valid to Date" > 0D) AND ("Valid to Date" < TODAY) THEN
                            ERROR('This store requisition is already expired');

                        // IF ApprovalMgt.PrePostApprovalCheck(BankReconn, Rec, PaymentJnl) THEN
                        //     MakePurchOrder;

                    end;
                }
                action("Make Order from All Requisitions")
                {
                    Caption = 'Make Order from All Requisitions';
                    Visible = false;

                    trigger OnAction();
                    var
                        lvMyForm: Page "Create Orders from Requisition";
                        lvPurchaseOrderLine: Record "NFL Requisition Line";
                    begin
                        lvPurchaseOrderLine.SETFILTER("Document Type", FORMAT(lvPurchaseOrderLine."Document Type"::"Purchase Requisition"));
                        lvMyForm.SETTABLEVIEW(lvPurchaseOrderLine);
                        lvMyForm.GetVendorCode("Buy-from Vendor No.");
                        lvMyForm.RUNMODAL;
                    end;
                }
                separator("....")
                {
                }
                action("Make RFQ")
                {
                    Caption = 'Make RFQ';
                    Image = Quote;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction();
                    var
                        BankReconn: Record "Bank Acc. Reconciliation";
                        PaymentJnl: Record "Gen. Journal Line";
                    // ApprovalMgt: Codeunit "NFL Approvals Management";
                    begin
                        //Chech whether the requistion has not yet been converted to an order.
                        IF "Converted to Quote" = TRUE THEN
                            ERROR('The purchase requistion has already been converted to a quote.');
                        //END

                        // IF ("Valid to Date" > 0D) AND ("Valid to Date" < TODAY) THEN ERROR('This store requisition is already expired');
                        // IF ApprovalMgt.PrePostApprovalCheck(BankReconn, Rec, PaymentJnl) THEN
                        //     "PurchReqtoQuote(Y/N)"(Rec);
                    end;
                }
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        ReqnHeader: Record "NFL Requisition Header";
                        RptPurchaseReqn: Report "Purchase Requisition";
                    begin
                        ReqnHeader.SETRANGE("Document Type", ReqnHeader."Document Type"::"Purchase Requisition");
                        ReqnHeader.SETRANGE("No.", "No.");
                        RptPurchaseReqn.SETTABLEVIEW(ReqnHeader);
                        RptPurchaseReqn.RUNMODAL;
                    end;
                }
                action("Detail Commitment Report")
                {
                    Caption = 'Detail Commitment Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    // RunObject = Report 51402257; // Report not found IE
                }
                action("Form 5")
                {
                    Caption = 'Form 5';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        ReqnHeader: Record "NFL Requisition Header";
                        RptPurchaseReqn: Report "Purchase Requisition";
                    begin
                        ReqnHeader.SETRANGE("Document Type", ReqnHeader."Document Type"::"Purchase Requisition");
                        ReqnHeader.SETRANGE("No.", "No.");
                        ReptForm5.SETTABLEVIEW(ReqnHeader);
                        ReptForm5.RUNMODAL;
                        CLEAR(ReptForm5);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        lvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
    end;

    trigger OnAfterGetRecord();
    var
        lvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
    end;

    trigger OnDeleteRecord(): Boolean;
    begin

        TESTFIELD(Status, Status::Open);

        CurrPage.SAVERECORD;
        EXIT(ConfirmDeletion);
    end;

    trigger OnInit();
    begin
        PurchHistoryBtn1Visible := TRUE;
        PayToCommentBtnVisible := TRUE;
        PayToCommentPictVisible := TRUE;
        PurchHistoryBtnVisible := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        "Responsibility Center" := UserMgt.GetPurchasesFilter();
    end;

    trigger OnOpenPage();
    var
        lvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
        IF UserMgt.GetPurchasesFilter() <> '' THEN BEGIN
            FILTERGROUP(2);
            SETRANGE("Responsibility Center", UserMgt.GetPurchasesFilter());
            FILTERGROUP(0);
        END;

        EditFields;

        IF Status IN [Status::Released, Status::"Pending Approval"] THEN
            EditPage := FALSE
        ELSE
            EditPage := TRUE;

        //Validate budget checks.
        lvNFLRequisitionLine.RESET;
        lvNFLRequisitionLine.SETRANGE("Document No.", "No.");
        lvNFLRequisitionLine.LOCKTABLE;
        IF lvNFLRequisitionLine.FIND('-') THEN
            REPEAT
                lvNFLRequisitionLine."Accounting Period Start Date" := "Accounting Period Start Date";
                lvNFLRequisitionLine."Accounting Period End Date" := "Accounting Period End Date";
                lvNFLRequisitionLine."Fiscal Year Start Date" := "Fiscal Year Start Date";
                lvNFLRequisitionLine."Fiscal Year End Date" := "Fiscal Year End Date";
                lvNFLRequisitionLine."Filter to Date Start Date" := "Filter to Date Start Date";
                lvNFLRequisitionLine."Filter to Date End Date" := "Filter to Date End Date";
                lvNFLRequisitionLine."Quarter Start Date" := "Quarter Start Date";
                lvNFLRequisitionLine."Quarter End Date" := "Quarter End Date";
                lvNFLRequisitionLine.VALIDATE("Filter to Date Start Date");
                lvNFLRequisitionLine.VALIDATE("Filter to Date End Date");
                lvNFLRequisitionLine.VALIDATE("Fiscal Year Start Date");
                lvNFLRequisitionLine.VALIDATE("Fiscal Year End Date");
                lvNFLRequisitionLine.VALIDATE("Quarter Start Date");
                lvNFLRequisitionLine.VALIDATE("Quarter End Date");
                lvNFLRequisitionLine.VALIDATE("Accounting Period Start Date");
                lvNFLRequisitionLine.VALIDATE("Accounting Period End Date");
                lvNFLRequisitionLine.VALIDATE("Balance on Budget for the Year");
                lvNFLRequisitionLine.VALIDATE("Bal. on Budget for the Quarter");
                lvNFLRequisitionLine.VALIDATE("Bal. on Budget for the Month");
                lvNFLRequisitionLine.VALIDATE("Balance on Budget as at Date");
                lvNFLRequisitionLine.MODIFY;
            UNTIL lvNFLRequisitionLine.NEXT = 0;
        //END.
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        ChangeExchangeRate: Page "Change Exchange Rate";
        CopyPurchDoc: Report "Copy Purchase Document";
        DocPrint: Codeunit "Document-Print";
        UserMgt: Codeunit "User Setup Management";
        ArchiveManagement: Codeunit "NFL ArchiveManagement";
        PurchInfoPaneMgmt: Codeunit "NFL Reqn Info-Pane Management";
        Text000: Label 'Do you want to convert the Requisition to a Quote?';
        Text001: Label 'Requisition number %1 has been converted to Quote number %2.';
        PurchQuoteHeader: Record "Purchase Header";
        PurchQuoteLine: Record "Purchase Line";
        DocDim: Codeunit "DimensionManagement";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        PrepmtMgt: Codeunit "Prepayment Mgt.";
        PurchDocLineComment: Record "Purch. Comment Line";
        PurchCommentLine: Record "Purch. Comment Line";
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        PurchReqLine: Record "NFL Requisition Line";
        PurchReqHeader: Record "NFL Requisition Header";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        i: Integer;
        DocNo: array[30] of Code[20];
        Text002: Label 'Requsition number %1 has been converted to Quote Numbers %2 - %3';
        PurchaseReqLine: Record "NFL Requisition Line";
        Text003: Label 'Do you want to convert the Requisition to an Order?';
        Text004: Label 'Requisition number %1 has been converted to Order number %2.';
        Text005: Label 'Requsition number %1 has been converted to Orders Number %2 - %3';
        ANFSetup: Record "NFL Setup";
        [InDataSet]
        PurchHistoryBtnVisible: Boolean;
        [InDataSet]
        PayToCommentPictVisible: Boolean;
        [InDataSet]
        PayToCommentBtnVisible: Boolean;
        [InDataSet]
        PurchHistoryBtn1Visible: Boolean;
        Text19023272: Label 'Buy-from Vendor';
        Text19005663: Label 'Pay-to Vendor';
        "---MAG----": Integer;
        CommitmentEntry: Record "Commitment Entry";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        gvCommitmentEntry: Record "Commitment Entry";
        gvPurchLine: Record "Purchase Line";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        NFLRequisitionLine: Record "NFL Requisition Line";
        gvNFLRequisitionLine: Record "NFL Requisition Line";
        ShortcutDimCode: array[9] of Code[20];
        PurchOrderNo: Code[20];
        gvHeaderTotal: Decimal;
        Text0022: Label 'There must be atleast one line with amount in the Purchase requisition Details Subform';
        Text0023: Label 'Are you sure you want to archive this document? after archiving, it will be automatically deleted';
        Text0024: Label 'Please confirm archival and deletion of this document.';
        gvUserSetup: Record "User Setup";
        Text0025: Label 'You do not have permissions to archive this document, please consult the Admin';
        Text0026: Label 'You do not exist in the user setup,  please contact the Admin';
        [InDataSet]
        EditPage: Boolean;
        ReptForm5: Report "Form 5";
        [InDataSet]


        Edit: Boolean;

    /// <summary>
    /// Description for UpdateInfoPanel.
    /// </summary>
    local procedure UpdateInfoPanel();
    var
        DifferBuyFromPayTo: Boolean;
    begin
        DifferBuyFromPayTo := "Buy-from Vendor No." <> "Pay-to Vendor No.";
        PurchHistoryBtnVisible := DifferBuyFromPayTo;
        PayToCommentPictVisible := DifferBuyFromPayTo;
        PayToCommentBtnVisible := DifferBuyFromPayTo;
        PurchHistoryBtn1Visible := PurchInfoPaneMgmt.DocExist(Rec, "Buy-from Vendor No.");
        IF DifferBuyFromPayTo THEN
            PurchHistoryBtnVisible := PurchInfoPaneMgmt.DocExist(Rec, "Pay-to Vendor No.")
    end;

    /// <summary>
    /// Description for PurchReqtoQuote(Y/N.
    /// </summary>
    /// <param name="(var Rec">VAR Record "NFL Requisition Header".</param>
    procedure "PurchReqtoQuote(Y/N)"(var Rec: Record "NFL Requisition Header");
    begin
        TESTFIELD("Document Type", "Document Type"::"Purchase Requisition");
        IF NOT CONFIRM(Text000, FALSE) THEN
            EXIT;

        PurchReqtoQuote(Rec);
        GetPurchQuoteHeader(PurchQuoteHeader);

        IF i = 1 THEN BEGIN
            MESSAGE(Text001,
                "No.", PurchQuoteHeader."No.");
            VALIDATE("Converted to Quote", TRUE);
        END ELSE BEGIN
            MESSAGE(Text002,
                "No.", DocNo[1], DocNo[i]);
            VALIDATE("Converted to Quote", TRUE);
        END;
    end;

    /// <summary>
    /// Description for PurchReqtoQuote.
    /// </summary>
    /// <param name="Rec">Parameter of type Record "NFL Requisition Header".</param>
    procedure PurchReqtoQuote(var Rec: Record "NFL Requisition Header");
    var
        OldPurchCommentLine: Record "Purch. Comment Line";
        FromDocDim: Record "Document Dimension";
        ToDocDim: Record "Document Dimension";
        Vend: Record Vendor;
        PrevVendorNo: Code[20];
        LineNo: Integer;
        NextDocNo: Code[20];
    begin
        //NEW CODE FOR THE PURCHASE REQUISITION
        TESTFIELD("Document Type", "Document Type"::"Purchase Requisition");
        PurchSetup.GET;
        PurchaseReqLine.RESET;
        PurchaseReqLine.SETCURRENTKEY(PurchaseReqLine."Buy-from Vendor No.");
        PurchaseReqLine.SETRANGE(PurchaseReqLine."Document Type", "Document Type");
        PurchaseReqLine.SETFILTER(PurchaseReqLine."Document No.", '%1', "No.");

        FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");
        ToDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line");
        i := 0;    //to capture the first number
        PrevVendorNo := '';
        CLEAR(DocNo);
        IF PurchaseReqLine.FINDFIRST THEN BEGIN
            REPEAT
                PurchaseReqLine.TESTFIELD(PurchaseReqLine."Buy-from Vendor No.");
                IF PurchaseReqLine."Buy-from Vendor No." <> PrevVendorNo THEN BEGIN  //create new header
                    Vend.GET(PurchaseReqLine."Buy-from Vendor No.");
                    Vend.CheckBlockedVendOnDocs(Vend, FALSE);
                    PurchQuoteHeader.INIT;
                    NextDocNo := NoSeriesMgt.GetNextNo(PurchSetup."Quote Nos.", TODAY, TRUE);
                    PurchQuoteHeader."No." := NextDocNo;

                    PurchQuoteHeader."Document Type" := PurchQuoteHeader."Document Type"::Quote;
                    PurchQuoteHeader."Buy-from Vendor No." := PurchaseReqLine."Buy-from Vendor No.";

                    PurchQuoteHeader."No. Printed" := 0;
                    PurchQuoteHeader."Store Requisition No." := "Store Requisition No.";
                    PurchQuoteHeader."Purchase Requisition No." := "No.";
                    PurchQuoteHeader.Status := PurchQuoteHeader.Status::Open;
                    PurchQuoteHeader."Order Date" := "Order Date";
                    IF "Posting Date" <> 0D THEN
                        PurchQuoteHeader."Posting Date" := "Posting Date";
                    PurchQuoteHeader."Document Date" := "Document Date";
                    PurchQuoteHeader."Purchase Requisition No." := "No.";
                    PurchQuoteHeader."Expected Receipt Date" := "Expected Receipt Date";
                    PurchQuoteHeader."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                    PurchQuoteHeader."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                    PurchQuoteHeader."Dimension Set ID" := "Dimension Set ID";
                    PurchQuoteHeader.VALIDATE("Posting Description", "Posting Description");

                    PurchQuoteLine.LOCKTABLE;
                    PurchQuoteHeader.INSERT(TRUE);
                    PurchQuoteHeader.VALIDATE(PurchQuoteHeader."Buy-from Vendor No.");
                    PurchQuoteHeader.VALIDATE("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                    PurchQuoteHeader.VALIDATE("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                    PurchQuoteHeader.VALIDATE("Dimension Set ID", "Dimension Set ID");
                    PurchQuoteHeader.MODIFY;
                    LineNo := 0;
                    i += 1;
                    DocNo[i] := PurchQuoteHeader."No.";
                END;
                LineNo += 10000;
                PurchQuoteLine.TRANSFERFIELDS(PurchaseReqLine);
                PurchQuoteLine."Commitment Entry No." := PurchaseReqLine."Commitment Entry No.";

                PurchQuoteLine."Document Type" := PurchQuoteLine."Document Type"::Quote;

                PurchQuoteLine."Document No." := NextDocNo;
                PurchQuoteLine."Line No." := LineNo;

                //copying line dimensions to line on quote
                FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");
                IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Store Requisition" THEN
                    FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Store Requisition");
                IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Purchase Requisition" THEN
                    FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Purchase Requisition");
                FromDocDim.SETRANGE(FromDocDim."Document No.", PurchaseReqLine."Document No.");
                FromDocDim.SETRANGE(FromDocDim."Line No.", PurchaseReqLine."Line No.");
                "Dimension Set ID" := PurchaseReqLine."Dimension Set ID";

                PrevVendorNo := PurchaseReqLine."Buy-from Vendor No.";

                PurchQuoteLine.INSERT(TRUE);
                PrevVendorNo := PurchaseReqLine."Buy-from Vendor No.";
            UNTIL PurchaseReqLine.NEXT = 0;

            // NV requires that once requisition are
            // approved. All orders that originate from such requistions must be approved as well.
            PurchQuoteHeader.Status := Status::Released;
            PurchQuoteHeader.MODIFY;
            // - END.

        END;

        ANFSetup.GET;
        IF ANFSetup."Archive Purch. Requisition" THEN
            ArchiveManagement.ArchPurchDocumentNoConfirm(Rec);

        COMMIT;

    end;

    /// <summary>
    /// Description for GetPurchQuoteHeader.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "Purchase Header".</param>
    procedure GetPurchQuoteHeader(var PurchHeader: Record "Purchase Header");
    begin
        PurchHeader := PurchQuoteHeader;
    end;

    /// <summary>
    /// Description for MakePurchOrder.
    /// </summary>
    procedure MakePurchOrder();
    var
        "====AMI====": Integer;
        PurchaseOrderHdr: Record "Purchase Header";
        PurchaseOrderLine: Record "Purchase Line";
        PurchaseOrderLine2: Record "NFL Requisition Line";
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        LineNo: Integer;
        OldPurchCommentLine: Record "Purch. Comment Line";
        FromDocDim: Record "Document Dimension";
        ToDocDim: Record "Document Dimension";
        Vend: Record Vendor;
        PrevVendorNo: Code[20];
        NextDocNo: Code[20];
        NFLRequisitionLine: Record "NFL Requisition Line";
        lvPurchaseHeader: Record "Purchase Header";
        lvPurchLine: Record "NFL Requisition Line";
        partialOrder: Boolean;
        NflReqnLine3: Record "NFL Requisition Line";
        m: Integer;
        Int3: Integer;
    begin
        IF NOT CONFIRM(Text003, FALSE) THEN
            EXIT;

        PurchSetup.GET;
        PurchaseReqLine.RESET;
        PurchaseReqLine.SETCURRENTKEY("Buy-from Vendor No.");
        PurchaseReqLine.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
        PurchaseReqLine.SETRANGE(Convert, TRUE);
        PurchaseReqLine.SETRANGE(Converted, FALSE);
        PurchaseReqLine.SETFILTER("Document No.", "No.");

        //To ensure that at least a line is selected to be converted into an order
        IF NOT PurchaseReqLine.FIND('-') THEN
            ERROR('Select the lines you want to convert into an order')
        ELSE
            ;

        FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");

        i := 0;    //to capture the first number
        PrevVendorNo := '';
        CLEAR(DocNo);
        IF PurchaseReqLine.FINDFIRST THEN BEGIN
            REPEAT
                PurchaseReqLine.TESTFIELD(PurchaseReqLine."Buy-from Vendor No.");
                IF PurchaseReqLine."Buy-from Vendor No." <> PrevVendorNo THEN   //create new header
                  BEGIN
                    Vend.GET(PurchaseReqLine."Buy-from Vendor No.");
                    Vend.CheckBlockedVendOnDocs(Vend, FALSE);
                    PurchaseOrderHdr.INIT;
                    NextDocNo := NoSeriesMgt.GetNextNo(PurchSetup."Order Nos.", TODAY, TRUE);
                    PurchaseOrderHdr."No." := NextDocNo;

                    PurchaseOrderHdr."Document Type" := PurchaseOrderHdr."Document Type"::Order;
                    PurchaseOrderHdr."Buy-from Vendor No." := PurchaseReqLine."Buy-from Vendor No.";
                    PurchaseOrderHdr."No. Printed" := 0;
                    PurchaseOrderHdr."Store Requisition No." := "Store Requisition No.";
                    PurchaseOrderHdr."Purchase Requisition No." := "No.";
                    PurchaseOrderHdr.Status := PurchaseOrderHdr.Status::Open;
                    PurchaseOrderHdr."Order Date" := "Order Date";

                    PurchaseOrderHdr.InitRecord;
                    PurchOrderNo := PurchaseOrderHdr."No.";
                    PurchaseOrderHdr.VALIDATE("Posting Description", "Posting Description");
                    PurchaseOrderHdr."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                    PurchaseOrderHdr."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";


                    IF "Posting Date" <> 0D THEN
                        PurchaseOrderHdr."Posting Date" := "Posting Date";
                    PurchaseOrderHdr."Document Date" := "Document Date";
                    PurchaseOrderHdr."Purchase Requisition No." := "No.";
                    PurchaseOrderHdr."Expected Receipt Date" := "Expected Receipt Date";
                    PurchaseOrderHdr."Currency Code" := "Currency Code";


                    PurchaseOrderHdr.INSERT(TRUE);
                    //  Transfer dimension to the purchase header.
                    PurchaseOrderHdr.VALIDATE(PurchaseOrderHdr."Buy-from Vendor No.");
                    PurchaseOrderHdr.VALIDATE("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                    PurchaseOrderHdr.VALIDATE("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                    PurchaseOrderHdr.VALIDATE("Dimension Set ID", "Dimension Set ID");
                    PurchaseOrderHdr.VALIDATE("Currency Code", "Currency Code");
                    //END.

                    PurchaseOrderHdr.MODIFY;
                    LineNo := 0;
                    i += 1;
                    DocNo[i] := PurchaseOrderHdr."No.";

                    //Insert the Line Item Line
                    PurchaseOrderLine2.RESET;
                    PurchaseOrderLine2.SETFILTER("Document Type", FORMAT(PurchaseOrderLine2."Document Type"::"Purchase Requisition"));
                    PurchaseOrderLine2.SETFILTER("Buy-from Vendor No.", PurchaseReqLine."Buy-from Vendor No.");
                    PurchaseOrderLine2.SETFILTER(PurchaseOrderLine2."Document No.", "No.");
                    PurchaseOrderLine2.SETRANGE(Convert, TRUE);
                    PurchaseOrderLine2.SETRANGE(Converted, FALSE);
                    IF PurchaseOrderLine2.FINDSET THEN
                        REPEAT
                            LineNo += 10000;
                            PurchaseOrderLine.LOCKTABLE;
                            PurchaseOrderLine.INIT;


                            PurchaseOrderLine."Document Type" := PurchaseOrderLine."Document Type"::Order;
                            PurchaseOrderLine."Document No." := NextDocNo;
                            PurchaseOrderLine."Line No." := LineNo;
                            PurchaseOrderLine.VALIDATE("Buy-from Vendor No.", PurchaseOrderLine2."Buy-from Vendor No.");
                            PurchaseOrderLine.Type := PurchaseOrderLine2.Type;
                            PurchaseOrderLine.VALIDATE("No.", PurchaseOrderLine2."No.");
                            PurchaseOrderLine.Description := PurchaseOrderLine2.Description;
                            PurchaseOrderLine."Location Code" := PurchaseOrderLine2."Location Code";
                            PurchaseOrderLine.VALIDATE("Currency Code", PurchaseOrderLine2."Currency Code");
                            PurchaseOrderLine.VALIDATE("Dimension Set ID", PurchaseOrderLine2."Dimension Set ID");
                            PurchaseOrderLine.VALIDATE(Quantity, PurchaseOrderLine2.Quantity);
                            PurchaseOrderLine."Unit of Measure" := PurchaseOrderLine2."Unit of Measure";
                            PurchaseOrderLine.validate("Direct Unit Cost", PurchaseOrderLine2."Direct Unit Cost");
                            PurchaseOrderLine."Unit Cost (LCY)" := PurchaseOrderLine2."Unit Cost (LCY)";
                            PurchaseOrderLine.validate("VAT Prod. Posting Group", PurchaseOrderLine2."VAT Prod. Posting Group");
                            PurchaseOrderLine.validate("VAT Bus. Posting Group", PurchaseOrderLine2."VAT Bus. Posting Group");

                            PurchaseOrderHdr.VALIDATE("No.", "No.");
                            PurchaseOrderLine.VALIDATE(Quantity, PurchaseOrderLine2."Qty. to Order");
                            partialOrder := TRUE;
                            PurchaseOrderLine."Control Account" := PurchaseOrderLine2."Control Account";
                            PurchaseOrderLine."Deferral Code" := PurchaseOrderLine2."Deferral Code";


                            PurchaseOrderLine.INSERT(TRUE);
                            PurchaseOrderLine."Gen. Bus. Posting Group" := PurchaseOrderHdr."Gen. Bus. Posting Group";
                            PurchaseOrderLine.MODIFY;


                            PurchaseOrderLine2.Converted := TRUE;
                            PurchaseOrderLine2.MODIFY;

                        UNTIL PurchaseOrderLine2.NEXT = 0;

                    lvPurchaseHeader.GET(lvPurchaseHeader."Document Type"::Order, PurchOrderNo);
                    lvPurchaseHeader.Status := Status::Released;
                    lvPurchaseHeader.MODIFY;

                    //copying line dimensions to line on quote
                    FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");

                    IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Store Requisition" THEN
                        FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Store Requisition");

                    IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Purchase Requisition" THEN
                        FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Purchase Requisition");

                    FromDocDim.SETRANGE(FromDocDim."Document Type", PurchaseReqLine."Document Type");
                    FromDocDim.SETRANGE(FromDocDim."Document No.", PurchaseReqLine."Document No.");
                    FromDocDim.SETRANGE(FromDocDim."Line No.", PurchaseReqLine."Line No.");
                    ToDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");
                    "Dimension Set ID" := PurchaseReqLine."Dimension Set ID";


                    PrevVendorNo := PurchaseReqLine."Buy-from Vendor No.";


                END;
            UNTIL PurchaseReqLine.NEXT = 0;
        END;

        ANFSetup.GET;

        COMMIT;

        //Confirmation message
        IF i = 1 THEN BEGIN
            MESSAGE(Text004,
                "No.", DocNo[1]);
            "Converted to Order" := TRUE;
            MODIFY;
        END ELSE BEGIN
            MESSAGE(Text005,
                "No.", DocNo[1], DocNo[i]);
            "Converted to Order" := TRUE;
            MODIFY;
        END;
        // Achieve the requisition after converting it to an order.
        //To Archive only if all lines have been coverted into orders
        NflReqnLine3.Reset();
        NflReqnLine3.SetRange(NflReqnLine3."Document No.", Rec."No.");
        NflReqnLine3.SetRange(NflReqnLine3.Converted, false);
        if NflReqnLine3.FindFirst() then
            exit
        else begin
            if ANFSetup."Archive Purch. Requisition" then begin
                StorePurchDocumentModified(Rec, TRUE);   // Archives a Purchase Requisition
                CurrPage.UPDATE(FALSE);
                lvPurchLine.SETFILTER("Document Type", FORMAT(Rec."Document Type"::"Purchase Requisition"));
                lvPurchLine.SETFILTER("Document No.", "No.");
                IF lvPurchLine.FINDFIRST THEN
                    lvPurchLine.DELETEALL;

                Rec.DELETE(TRUE);
            end;
        end;
    end;


    /// <summary>
    /// Description for ReversePurchaseRequisitionCommitmentEntries.
    /// </summary>
    local procedure ReversePurchaseRequisitionCommitmentEntries();
    begin
        //Reverse commitment on converting requistion to order for a released purchase requisistion document.
        IF Commited = TRUE THEN BEGIN
            gvNFLRequisitionLine.SETRANGE("Document No.", "No.");
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
                    reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
                    reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
                    reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
                    reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
                    reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
                    reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
                    reversedCommitmentEntry."Additional-Currency Amount" := -1 * gvCommitmentEntry."Additional-Currency Amount";
                    reversedCommitmentEntry."Add.-Currency Debit Amount" := -1 * gvCommitmentEntry."Add.-Currency Debit Amount";
                    reversedCommitmentEntry."Add.-Currency Credit Amount" := -1 * gvCommitmentEntry."Add.-Currency Credit Amount";
                    reversedCommitmentEntry.Reversed := TRUE;
                    reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
                    reversedCommitmentEntry."User ID" := USERID;
                    reversedCommitmentEntry."Source Code" := 'converted to order';
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
    end;

    /// <summary>
    /// Description for EditFields.
    /// </summary>
    local procedure EditFields();
    var
        ReqnHeaderr: Record "NFL Requisition Header";
    begin
        ReqnHeaderr.RESET;
        ReqnHeaderr.SETRANGE("No.", "No.");
        ReqnHeaderr.SETRANGE(Status, Status::Released);
        ReqnHeaderr.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
        IF ReqnHeaderr.FINDFIRST THEN
            Edit := TRUE
        ELSE
            Edit := FALSE;
    end;
}

