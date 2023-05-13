/// <summary>
/// Table Payment Voucher Header (ID 50072).
/// </summary>
table 50001 "Payment Voucher Header"
{
    // version MAG

    Caption = 'Payment Voucher Header';
    DataCaptionFields = "Document Type", "No.", "Budget Code", "Shortcut Dimension 1 Code";
    permissions = tabledata "Approval Entry" = rm;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Posting Date"; Date)
        {

            trigger OnValidate();
            begin
                GetFiscalYearAndAccountingPeriod("Posting Date");
                IF PaymentVoucherLinesExist THEN
                    UpdateAllLineDateFilters("Posting Date");
            end;
        }
        field(4; "Budget Code"; Code[10])
        {
            Editable = false;
            TableRelation = "G/L Budget Name";

            trigger OnValidate();
            begin
                IF PaymentVoucherLinesExist THEN
                    UpdateAllLineBudget("Budget Code");
            end;
        }
        field(5; Status; Option)
        {
            Editable = true;
            OptionMembers = Open,"Pending Approval",Released;
        }
        field(6; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(9; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher,Procurement Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher";
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist("G/L Entry" WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Prepared by"; Code[50])
        {
            Editable = false;
        }
        field(12; Payee; Text[50])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                TESTFIELD("Payee No.", '');
            end;
        }
        field(13; "Payment Type"; Option)
        {
            OptionCaption = ' ,Cash Requisition,Supplier Payment,Advance,Interbank Transfer,Customer Refund,Supplier & Advance Payment';
            OptionMembers = " ","Cash Requisition","Supplier Payment",Advance,"Interbank Transfer","Customer Refund","Supplier & Advance Payment";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(14; "WHT Local"; Boolean)
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::"Pending Approval");
                PaymentVoucherLinesExist;
                IF "WHT Foreign" = TRUE THEN
                    ERROR('Payment Voucher has already been selected for Foreign WHT Computations');

                IF "WHT Local" = TRUE THEN BEGIN
                    PurchasesPayablesSetup.GET;
                    PurchasesPayablesSetup.TESTFIELD("WHT Local %");
                    PurchasesPayablesSetup.TESTFIELD("WHT Local Account");
                    PurchasesPayablesSetup.TESTFIELD("WHT Minimum Amount");
                    TestPaymentVoucherLineFields;
                    CalculatePaymentVoucherLineWHT;
                END;

                IF "WHT Local" = FALSE THEN
                    ReversePaymentVoucherLineWHTCalculation;
            end;
        }
        field(15; "WHT Foreign"; Boolean)
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::"Pending Approval");
                PaymentVoucherLinesExist;
                IF "WHT Local" = TRUE THEN
                    ERROR('Payment Voucher has already been selected for Local WHT Computations');

                IF "WHT Foreign" = TRUE THEN BEGIN
                    PurchasesPayablesSetup.GET;
                    PurchasesPayablesSetup.TESTFIELD("WHT Foreign %");
                    PurchasesPayablesSetup.TESTFIELD("WHT Foreign Account");
                    PurchasesPayablesSetup.TESTFIELD("WHT Minimum Amount");

                    TestPaymentVoucherLineFields;
                    CalculatePaymentVoucherLineWHT;
                END;

                IF "WHT Foreign" = FALSE THEN
                    ReversePaymentVoucherLineWHTCalculation;
            end;
        }
        field(32; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate();
            begin
                IF NOT (CurrFieldNo IN [0, FIELDNO("Posting Date")]) OR ("Currency Code" <> xRec."Currency Code") THEN
                    TESTFIELD(Status, Status::Open);
                IF (CurrFieldNo <> FIELDNO("Currency Code")) AND ("Currency Code" = xRec."Currency Code") THEN
                    UpdateCurrencyFactor
                ELSE BEGIN
                    IF "Currency Code" <> xRec."Currency Code" THEN BEGIN
                        UpdateCurrencyFactor;
                        IF PaymentVoucherLinesExist THEN
                            IF CONFIRM(ChangeCurrencyQst, FALSE, FIELDCAPTION("Currency Code")) THEN BEGIN
                                SetHideValidationDialog(TRUE);
                                RecreatePaymentVoucherLines(FIELDCAPTION("Currency Code"));
                                SetHideValidationDialog(FALSE);
                            END ELSE
                                ERROR(Text018, FIELDCAPTION("Currency Code"));
                    END ELSE
                        IF "Currency Code" <> '' THEN BEGIN
                            UpdateCurrencyFactor;
                            IF "Currency Factor" <> xRec."Currency Factor" THEN
                                ConfirmUpdateCurrencyFactor;
                        END;
                END;

                IF "Currency Code" <> xRec."Currency Code" THEN BEGIN
                    IF PaymentVoucherLinesExist THEN
                        ERROR(Text018, FIELDCAPTION("Currency Code"));
                END;
            end;
        }
        field(33; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;

            trigger OnValidate();
            begin
                IF "Currency Factor" <> xRec."Currency Factor" THEN
                    UpdatePaymentVoucherLines(FIELDCAPTION("Currency Factor"));
            end;
        }
        field(38; Archieved; Boolean)
        {
            Editable = false;
        }
        field(40; Commited; Boolean)
        {
            Editable = false;
        }
        field(41; "Transferred to Journals"; Boolean)
        {
            Editable = false;
        }
        field(42; "Bank File Generated"; Boolean)
        {
            CalcFormula = Exist("Payment Voucher Line" WHERE("Document No." = FIELD("No."),
                                                              "Document Type" = FIELD("Document Type"),
                                                              "Bank File Generated" = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(43; "Received by"; Text[50])
        {
        }
        field(44; "Payment Voucher Details Total"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Detail".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                     "Document No." = FIELD("No.")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Payment Voucher Lines Total"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Line".Amount WHERE("Document No." = FIELD("No."),
                                                                   "Document Type" = FIELD("Document Type")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(46; "Payee No."; Code[20])
        {
            TableRelation = "Staff Advances".Code WHERE(Blocked = CONST(false));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF "Payee No." <> '' THEN BEGIN
                    StaffAdvances.GET("Payee No.");
                    StaffAdvances.TESTFIELD(Blocked, FALSE);
                    Payee := StaffAdvances.Name;
                END ELSE
                    CLEAR(Payee);
            end;
        }
        field(47; "Accounting Period Start Date"; Date)
        {
            Editable = false;
        }
        field(48; "Accounting Period End Date"; Date)
        {
            Editable = false;
        }
        field(49; "Fiscal Year Start Date"; Date)
        {
            Editable = false;
        }
        field(50; "Fiscal Year End Date"; Date)
        {
            Editable = false;
        }
        field(51; "Filter to Date Start Date"; Date)
        {
            Editable = false;
        }
        field(52; "Filter to Date End Date"; Date)
        {
            Editable = false;
        }
        field(53; "Quarter Start Date"; Date)
        {
            Editable = false;
        }
        field(54; "Quarter End Date"; Date)
        {
            Editable = false;
        }
        field(56; "Accountability Comment"; Text[50])
        {
        }
        field(57; "Has Links"; Boolean)
        {
            Editable = false;
        }
        field(70; "Balancing Entry"; Option)
        {
            OptionCaption = 'Same Line,Different Line';
            OptionMembers = "Same Line","Different Line";

            trigger OnValidate();
            begin
                IF "Balancing Entry" <> xRec."Balancing Entry" THEN
                    IF PaymentVoucherLinesExist THEN
                        ERROR(Text018, FIELDCAPTION("Balancing Entry"));
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDocDim;
            end;
        }
        field(50113; "Hub Code"; Code[50])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('SUB COST CENTRE'), Blocked = filter(false));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(8, "Hub Code");
            end;
        }
        field(50114; "Release Date"; Date)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.", "Document Type")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        TESTFIELD(Status, Status::Open);

        PaymentVoucherLine.SETRANGE("Document Type", "Document Type");
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        IF PaymentVoucherLine.FINDSET THEN
            REPEAT
                PaymentVoucherLine.DELETE(TRUE);
            UNTIL PaymentVoucherLine.NEXT = 0;

        PaymentVoucherDetail.SETRANGE("Document Type", "Document Type");
        PaymentVoucherDetail.SETRANGE("Document No.", "No.");
        IF PaymentVoucherDetail.FINDSET THEN
            REPEAT
                PaymentVoucherDetail.DELETE(TRUE);
            UNTIL PaymentVoucherDetail.NEXT = 0;
    end;

    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        DimMgt: Codeunit DimensionManagement;
        Text051: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        PaymentVoucherLine: Record "Payment Voucher Line";
        CurrExchRate: Record "Currency Exchange Rate";
        OriginalAmount: Decimal;
        CurrencyDate: Date;
        ChangeCurrencyQst: Label 'If you change %1, the existing payment voucher lines will be deleted and new payment voucher lines based on the new information in the header will be created. You may need to update the price information manually.\\Do you want to change %1?';
        HideValidationDialog: Boolean;
        Text016: Label 'If you change %1, the existing payment voucher lines will be deleted and new payment voucher lines based on the new information in the header will be created.\\';
        Text004: Label 'Do you want to change %1?';
        Confirmed: Boolean;
        Text018: Label 'You must delete the existing payment voucher lines before you can change %1.';
        Text022: Label 'Do you want to update the exchange rate?';
        GeneralLedgerSetup: Record "General Ledger Setup";
        StaffAdvances: Record "Staff Advances";
        gvCommitmentEntry: Record "Commitment Entry";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";

    /// <summary>
    /// Description for ShowDocDim.
    /// </summary>
    procedure ShowDocDim();
    var
        OldDimSetID: Integer;
        customFuncEvent: Codeunit "Custom Functions And EVents";
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          customFuncEvent.EditDimensionSet2(
            "Dimension Set ID", STRSUBSTNO('%1', "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        IF OldDimSetID <> "Dimension Set ID" THEN BEGIN
            MODIFY;
            IF PaymentVoucherLinesExist THEN
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        END;
    end;

    /// <summary>
    /// Description for PaymentVoucherLinesExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure PaymentVoucherLinesExist(): Boolean;
    begin
        PaymentVoucherLine.RESET;
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        EXIT(PaymentVoucherLine.FINDFIRST);
    end;

    /// <summary>
    /// Description for ValidateShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <param name="ShortcutDimCode">Parameter of type Code[20].</param>
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        IF "No." <> '' THEN
            MODIFY;

        IF OldDimSetID <> "Dimension Set ID" THEN BEGIN
            MODIFY;
            IF PaymentVoucherLinesExist THEN
                TESTFIELD(Status, Status::Open); // Shortcut dimension 1 code is used for budget checks so it should only be changed when document is open.
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        END;
    end;

    /// <summary>
    /// Description for UpdateAllLineDim.
    /// </summary>
    /// <param name="NewParentDimSetID">Parameter of type Integer.</param>
    /// <param name="OldParentDimSetID">Parameter of type Integer.</param>
    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer);
    var
        NewDimSetID: Integer;
    begin
        // Update all lines with changed dimensions.
        IF NewParentDimSetID = OldParentDimSetID THEN
            EXIT;

        PaymentVoucherLine.RESET;
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        PaymentVoucherLine.LOCKTABLE;
        IF PaymentVoucherLine.FIND('-') THEN
            REPEAT
                NewDimSetID := DimMgt.GetDeltaDimSetID(PaymentVoucherLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                IF PaymentVoucherLine."Dimension Set ID" <> NewDimSetID THEN BEGIN
                    PaymentVoucherLine."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      PaymentVoucherLine."Dimension Set ID", PaymentVoucherLine."Shortcut Dimension 1 Code", PaymentVoucherLine."Shortcut Dimension 2 Code");
                    PaymentVoucherLine.MODIFY;
                END;
            UNTIL PaymentVoucherLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for UpdateAllLineBudget.
    /// </summary>
    /// <param name="BudgetCode">Parameter of type Code[10].</param>
    local procedure UpdateAllLineBudget(BudgetCode: Code[10]);
    var
        NewBudgetCode: Code[10];
    begin
        // Update all lines with changed budget code.

        PaymentVoucherLine.RESET;
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        PaymentVoucherLine.LOCKTABLE;
        IF PaymentVoucherLine.FIND('-') THEN
            REPEAT
                PaymentVoucherLine."Budget Code" := BudgetCode;
                PaymentVoucherLine.MODIFY;
            UNTIL PaymentVoucherLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for AssistEdit.
    /// </summary>
    /// <param name="OldPaymentVoucherHeader">Parameter of type Record "Payment Voucher Header".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure AssistEdit(OldPaymentVoucherHeader: Record "Payment Voucher Header"): Boolean;
    begin
    end;

    /// <summary>
    /// Description for TestPaymentVoucherLineFields.
    /// </summary>
    local procedure TestPaymentVoucherLineFields();
    begin
        // MAG 26TH JULY 2018.
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        IF PaymentVoucherLine.FINDFIRST THEN
            REPEAT
                PaymentVoucherLine.TESTFIELD("Account No.");
                PaymentVoucherLine.TESTFIELD("Account Name");
                PaymentVoucherLine.TESTFIELD(Description);
                PaymentVoucherLine.TESTFIELD(Amount);
                PaymentVoucherLine.TESTFIELD("Shortcut Dimension 1 Code");
                PaymentVoucherLine.TESTFIELD("Dimension Set ID");
                PaymentVoucherLine.TESTFIELD("Bal. Account No.");
            UNTIL PaymentVoucherLine.NEXT = 0;
        // MAG- END.
    end;

    /// <summary>
    /// Description for CalculatePaymentVoucherLineWHT.
    /// </summary>
    local procedure CalculatePaymentVoucherLineWHT();
    var
        NewPaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 26TH JULY 2018.
        TESTFIELD("Payment Type", "Payment Type"::"Supplier Payment");
        PurchasesPayablesSetup.GET;
        PaymentVoucherLine.SETRANGE("Document No.", "No.");
        PaymentVoucherLine.SETRANGE(WHT, FALSE);
        PaymentVoucherLine.SETRANGE("Account Type", PaymentVoucherLine."Account Type"::Vendor);
        IF PaymentVoucherLine.FIND('-') THEN
            REPEAT
                IF PaymentVoucherLine.Amount < PurchasesPayablesSetup."WHT Minimum Amount" THEN
                    EXIT;
                NewPaymentVoucherLine.INIT;
                NewPaymentVoucherLine."Line No." := GetLastPaymentVoucherLineNo + 10000;
                NewPaymentVoucherLine."Document No." := PaymentVoucherLine."Document No.";
                NewPaymentVoucherLine."Account No." := PaymentVoucherLine."Account No.";
                NewPaymentVoucherLine."Account Name" := PaymentVoucherLine."Account Name";
                NewPaymentVoucherLine.Description := PADSTR('WHT - ' + PaymentVoucherLine.Description, 50);
                NewPaymentVoucherLine."Bal. Account Type" := NewPaymentVoucherLine."Bal. Account Type"::"G/L Account";
                NewPaymentVoucherLine.WHT := TRUE;
                NewPaymentVoucherLine."Source Line No. For WHT" := PaymentVoucherLine."Line No.";
                IF "WHT Local" = TRUE THEN BEGIN
                    NewPaymentVoucherLine.VALIDATE(Amount, PaymentVoucherLine.Amount * PurchasesPayablesSetup."WHT Local %" / 100);
                    NewPaymentVoucherLine."Bal. Account No." := PurchasesPayablesSetup."WHT Local Account";
                END;
                IF "WHT Foreign" = TRUE THEN BEGIN
                    NewPaymentVoucherLine.VALIDATE(Amount, PaymentVoucherLine.Amount * PurchasesPayablesSetup."WHT Foreign %" / 100);
                    NewPaymentVoucherLine."Bal. Account No." := PurchasesPayablesSetup."WHT Foreign Account";
                END;
                NewPaymentVoucherLine."Shortcut Dimension 1 Code" := PaymentVoucherLine."Shortcut Dimension 1 Code";
                NewPaymentVoucherLine."Shortcut Dimension 2 Code" := PaymentVoucherLine."Shortcut Dimension 2 Code";
                NewPaymentVoucherLine."Dimension Set ID" := PaymentVoucherLine."Dimension Set ID";
                NewPaymentVoucherLine."Document Type" := PaymentVoucherLine."Document Type";
                NewPaymentVoucherLine."Budget Code" := PaymentVoucherLine."Budget Code";


                // Reset Amount to Zero before inserting WHT Line such that Payee Lines do not exceed Payee Details specified by the End user.
                OriginalAmount := PaymentVoucherLine.Amount;
                PaymentVoucherLine.VALIDATE(Amount, 0);
                PaymentVoucherLine.MODIFY;

                NewPaymentVoucherLine.INSERT;

                // Update Expense Amount with amount less WHT.
                PaymentVoucherLine.VALIDATE(Amount, (OriginalAmount - NewPaymentVoucherLine.Amount));
                PaymentVoucherLine.MODIFY;

            UNTIL PaymentVoucherLine.NEXT = 0;
        // MAG- END.
    end;

    /// <summary>
    /// Description for GetLastPaymentVoucherLineNo.
    /// </summary>
    /// <returns>Return variable "Integer".</returns>
    local procedure GetLastPaymentVoucherLineNo(): Integer;
    var
        LastPaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 26TH JULY 2018
        LastPaymentVoucherLine.SETRANGE("Document No.", "No.");
        IF LastPaymentVoucherLine.FINDLAST THEN
            EXIT(LastPaymentVoucherLine."Line No.");
        // MAG - END.
    end;

    /// <summary>
    /// Description for ReversePaymentVoucherLineWHTCalculation.
    /// </summary>
    local procedure ReversePaymentVoucherLineWHTCalculation();
    var
        WHTPaymentVoucherLine: Record "Payment Voucher Line";
        ParentPaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 26TH JULY 2018.
        WHTPaymentVoucherLine.SETRANGE("Document No.", "No.");
        WHTPaymentVoucherLine.SETRANGE(WHT, TRUE);
        IF WHTPaymentVoucherLine.FIND('-') THEN
            REPEAT
                ParentPaymentVoucherLine.SETRANGE("Line No.", WHTPaymentVoucherLine."Source Line No. For WHT");
                IF ParentPaymentVoucherLine.FIND('-') THEN BEGIN
                    ParentPaymentVoucherLine.VALIDATE(Amount, (ParentPaymentVoucherLine.Amount + WHTPaymentVoucherLine.Amount));
                    ParentPaymentVoucherLine.MODIFY;
                    WHTPaymentVoucherLine.DELETE;
                END;
            UNTIL WHTPaymentVoucherLine.NEXT = 0;
        // MAG- END.
    end;

    /// <summary>
    /// Description for UpdateCurrencyFactor.
    /// </summary>
    local procedure UpdateCurrencyFactor();
    begin
        IF "Currency Code" <> '' THEN BEGIN
            IF "Posting Date" <> 0D THEN
                CurrencyDate := "Posting Date"
            ELSE
                CurrencyDate := WORKDATE;

            "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, "Currency Code");
        END ELSE
            "Currency Factor" := 0;
    end;

    /// <summary>
    /// Description for SetHideValidationDialog.
    /// </summary>
    /// <param name="NewHideValidationDialog">Parameter of type Boolean.</param>
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean);
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    /// <summary>
    /// Description for RecreatePaymentVoucherLines.
    /// </summary>
    /// <param name="ChangedFieldName">Parameter of type Text[100].</param>
    procedure RecreatePaymentVoucherLines(ChangedFieldName: Text[100]);
    var
        PaymentVoucherLineTmp: Record "Payment Voucher Line" temporary;
        TempInteger: Record Integer temporary;
    begin
        // MAG 27TH JULY 2018 - BEGIN
        IF PaymentVoucherLinesExist THEN BEGIN
            IF HideValidationDialog THEN
                Confirmed := TRUE
            ELSE
                Confirmed :=
                  CONFIRM(
                    Text016 +
                    Text004, FALSE, ChangedFieldName);
            IF Confirmed THEN BEGIN
                PaymentVoucherLine.LOCKTABLE;
                MODIFY;

                PaymentVoucherLine.RESET;
                PaymentVoucherLine.SETRANGE("Document Type", "Document Type");
                PaymentVoucherLine.SETRANGE("Document No.", "No.");
                IF PaymentVoucherLine.FINDSET THEN BEGIN
                    REPEAT
                        PaymentVoucherLine.TESTFIELD("Account No.");
                        PaymentVoucherLine.TESTFIELD("Account Name");
                        PaymentVoucherLine.TESTFIELD("Budget Code");
                        PaymentVoucherLine.TESTFIELD("Shortcut Dimension 1 Code");
                        PaymentVoucherLine.TESTFIELD(Description);
                        PaymentVoucherLine.TESTFIELD("Bal. Account No.");

                        PaymentVoucherLineTmp := PaymentVoucherLine;
                        PaymentVoucherLineTmp.INSERT;
                    UNTIL PaymentVoucherLine.NEXT = 0;
                    PaymentVoucherLine.DELETEALL(TRUE);
                    PaymentVoucherLine.INIT;
                    PaymentVoucherLine."Line No." := 0;
                    PaymentVoucherLineTmp.FINDSET;
                    REPEAT
                        PaymentVoucherLine.INIT;
                        PaymentVoucherLine."Line No." := PaymentVoucherLine."Line No." + 10000;
                        PaymentVoucherLine."Document No." := PaymentVoucherLineTmp."Document No.";
                        PaymentVoucherLine.VALIDATE("Account Type", PaymentVoucherLineTmp."Account Type");
                        PaymentVoucherLine."Account No." := PaymentVoucherLineTmp."Account No.";
                        PaymentVoucherLine."Account Name" := PaymentVoucherLineTmp."Account Name";
                        PaymentVoucherLine.Description := PaymentVoucherLineTmp.Description;
                        PaymentVoucherLine.VALIDATE(Amount, PaymentVoucherLineTmp.Amount);
                        PaymentVoucherLine."Shortcut Dimension 1 Code" := PaymentVoucherLineTmp."Shortcut Dimension 1 Code";
                        PaymentVoucherLine."Shortcut Dimension 2 Code" := PaymentVoucherLineTmp."Shortcut Dimension 2 Code";
                        PaymentVoucherLine."Dimension Set ID" := PaymentVoucherLineTmp."Dimension Set ID";
                        PaymentVoucherLine.VALIDATE("Document Type", PaymentVoucherLineTmp."Document Type");
                        PaymentVoucherLine.VALIDATE("Budget Code", PaymentVoucherLineTmp."Budget Code");
                        PaymentVoucherLine.VALIDATE("Bal. Account Type", PaymentVoucherLineTmp."Bal. Account Type");
                        PaymentVoucherLine.WHT := PaymentVoucherLineTmp.WHT;
                        PaymentVoucherLine."Source Line No. For WHT" := PaymentVoucherLineTmp."Source Line No. For WHT";
                        PaymentVoucherLine.INSERT;
                    UNTIL PaymentVoucherLineTmp.NEXT = 0;
                    PaymentVoucherLineTmp.DELETEALL;
                END;
            END ELSE
                ERROR(
                  Text018, ChangedFieldName);
        END;
    end;

    /// <summary>
    /// Description for ConfirmUpdateCurrencyFactor.
    /// </summary>
    local procedure ConfirmUpdateCurrencyFactor();
    begin
        IF HideValidationDialog THEN
            Confirmed := TRUE
        ELSE
            Confirmed := CONFIRM(Text022, FALSE);
        IF Confirmed THEN
            VALIDATE("Currency Factor")
        ELSE
            "Currency Factor" := xRec."Currency Factor";
    end;

    /// <summary>
    /// Description for UpdatePaymentVoucherLines.
    /// </summary>
    /// <param name="ChangedFieldName">Parameter of type Text[100].</param>
    procedure UpdatePaymentVoucherLines(ChangedFieldName: Text[100]);
    var
        UpdateConfirmed: Boolean;
    begin
        // MAG 27TH JULY 2018
        IF NOT PaymentVoucherLinesExist THEN
            EXIT;

        IF NOT GUIALLOWED THEN
            UpdateConfirmed := TRUE
        ELSE
            CASE ChangedFieldName OF
            END;

        PaymentVoucherLine.LOCKTABLE;
        MODIFY;

        REPEAT
        //xPaymentVoucherLine := PaymentVoucherLine;
        UNTIL PaymentVoucherLine.NEXT = 0;

    end;

    /// <summary>
    /// Description for UpdateAllLineBudget2.
    /// </summary>
    /// <param name="BudgetCode">Parameter of type Code[10].</param>
    local procedure UpdateAllLineBudget2(BudgetCode: Code[10]);
    var
        NewBudgetCode: Code[10];
        lvPayVouchLine: Record "Payment Voucher Line";
    begin
        // Update all lines with changed budget code.

        lvPayVouchLine.RESET;
        lvPayVouchLine.SETRANGE("Document No.", "No.");
        lvPayVouchLine.LOCKTABLE;
        IF lvPayVouchLine.FIND('-') THEN
            REPEAT
                lvPayVouchLine."Budget Code" := BudgetCode;
                lvPayVouchLine."Accounting Period Start Date" := "Accounting Period Start Date";
                lvPayVouchLine."Accounting Period End Date" := "Accounting Period End Date";
                lvPayVouchLine."Fiscal Year Start Date" := "Fiscal Year Start Date";
                lvPayVouchLine."Fiscal Year End Date" := "Fiscal Year End Date";
                lvPayVouchLine."Filter to Date Start Date" := "Filter to Date Start Date";
                lvPayVouchLine."Filter to Date End Date" := "Filter to Date End Date";
                lvPayVouchLine."Quarter Start Date" := "Quarter Start Date";
                lvPayVouchLine."Quarter End Date" := "Quarter End Date";
                lvPayVouchLine.MODIFY;
            UNTIL lvPayVouchLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for GetFiscalYearAndAccountingPeriod.
    /// </summary>
    /// <param name="parDate">Parameter of type Date.</param>
    local procedure GetFiscalYearAndAccountingPeriod(var parDate: Date);
    var
        lvAccountingPeriod: Record "Accounting Period";
        lvAccountingPeriod2: Record "Accounting Period";
        lvStartingDate: Date;
        lvEndingDate: Date;
        NewDate: Date;
        lvFiscalYearStartingDate: Date;
        lvFiscalYearEndingDate: Date;
        lvFound: Boolean;
        lvQtrOneStartDate: Date;
        lvQtrTwoStartDate: Date;
        lvQtrThreeStartDate: Date;
        lvQtrFourStartDate: Date;
        DateStart: Date;
        DateEnd: Date;
        lvQtrStartDate: Date;
        lvQtrEndDate: Date;
        lvQtrFound: Boolean;
    begin
        // MAG 2ND AUG. 2018 - BEGIN
        lvStartingDate := DMY2DATE(1, DATE2DMY(parDate, 2), DATE2DMY(parDate, 3));
        lvEndingDate := CALCDATE('<CM>', parDate);
        VALIDATE("Accounting Period Start Date", lvStartingDate);
        VALIDATE("Accounting Period End Date", lvEndingDate);

        //VALIDATE("Accounting Period", FORMAT(lvStartingDate) + '..' + FORMAT(lvEndingDate));

        // Get Fiscal Year Start Date basing on the posting date entered.
        lvAccountingPeriod2.SETFILTER("Starting Date", '<=%1', lvStartingDate);
        IF lvAccountingPeriod2.FIND('-') THEN BEGIN
            REPEAT
                IF lvAccountingPeriod2."New Fiscal Year" = TRUE THEN BEGIN
                    lvFiscalYearStartingDate := lvAccountingPeriod2."Starting Date";
                END;
            UNTIL lvAccountingPeriod2.NEXT = 0;
        END ELSE
            ERROR('There is no accounting period in the selected posting date');


        // Get Fiscal Year End Date basing on the posting date entered.
        lvAccountingPeriod.SETFILTER("Starting Date", '>=%1', lvStartingDate);
        IF lvAccountingPeriod.FIND('-') THEN BEGIN
            REPEAT
                // The second condition prevents from having a fiscal year of one month. e.g. if the specified date falls in the month of July
                IF (lvAccountingPeriod."New Fiscal Year" = TRUE)
                AND (lvAccountingPeriod."Starting Date" <> lvFiscalYearStartingDate)
                THEN BEGIN
                    lvFiscalYearEndingDate := CALCDATE('-1D', lvAccountingPeriod."Starting Date"); // end of the previous month.
                    lvFound := TRUE;
                END;
            UNTIL lvFound OR (lvAccountingPeriod.NEXT = 0);
        END ELSE
            ERROR('There is no accounting period in the selected posting date');

        VALIDATE("Filter to Date Start Date", lvFiscalYearStartingDate);
        VALIDATE("Filter to Date End Date", parDate);

        VALIDATE("Fiscal Year Start Date", lvFiscalYearStartingDate);
        VALIDATE("Fiscal Year End Date", lvFiscalYearEndingDate);

        //VALIDATE("Filter to Date", FORMAT(lvFiscalYearStartingDate) + '..'+ FORMAT(parDate)); // Filter to date starts from the begining of the fiscal year to the posting date
        //VALIDATE("Fiscal Year", FORMAT(lvFiscalYearStartingDate) + '..' + FORMAT(lvFiscalYearEndingDate));

        // Get Quarter in which a date falls.
        DateStart := lvFiscalYearStartingDate;
        DateEnd := lvFiscalYearEndingDate;

        // Loop all Quarters and find where the posting date falls.
        WHILE (DateStart < DateEnd) AND (lvQtrFound = FALSE) DO BEGIN
            IF (parDate >= DateStart) AND (parDate <= CALCDATE('3M', DateStart)) THEN BEGIN
                lvQtrStartDate := DateStart;
                lvQtrEndDate := CALCDATE('3M', DateStart);
                lvQtrEndDate := CALCDATE('-1D', lvQtrEndDate);
                VALIDATE("Quarter Start Date", lvQtrStartDate);
                VALIDATE("Quarter End Date", lvQtrEndDate);
                // VALIDATE(Quarter, FORMAT(lvQtrStartDate) + '..' + FORMAT(lvQtrEndDate));
                lvQtrFound := TRUE;
            END;
            DateStart := CALCDATE('3M', DateStart);
        END;

        // MAG - END.
    end;

    /// <summary>
    /// Description for UpdateAllLineDateFilters.
    /// </summary>
    /// <param name="PostingDate">Parameter of type Date.</param>
    local procedure UpdateAllLineDateFilters(PostingDate: Date);
    var
        NewBudgetCode: Code[10];
        lvNFLRequisitionLine: Record "NFL Requisition Line";
        lvPayVouchLine: Record "Payment Voucher Line";
    begin
        // Update all lines with changed budget code.

        lvPayVouchLine.RESET;
        lvPayVouchLine.SETRANGE("Document No.", "No.");
        lvPayVouchLine.LOCKTABLE;
        IF lvPayVouchLine.FIND('-') THEN
            REPEAT
                lvPayVouchLine.VALIDATE("Posting Date", PostingDate);
                GetFiscalYearAndAccountingPeriod(PostingDate);
                lvPayVouchLine."Accounting Period Start Date" := "Accounting Period Start Date";
                lvPayVouchLine."Accounting Period End Date" := "Accounting Period End Date";
                lvPayVouchLine."Fiscal Year Start Date" := "Fiscal Year Start Date";
                lvPayVouchLine."Fiscal Year End Date" := "Fiscal Year End Date";
                lvPayVouchLine."Filter to Date Start Date" := "Filter to Date Start Date";
                lvPayVouchLine."Filter to Date End Date" := "Filter to Date End Date";
                lvPayVouchLine."Fiscal Year Start Date" := "Fiscal Year Start Date";
                lvPayVouchLine."Fiscal Year End Date" := "Fiscal Year End Date";
                lvPayVouchLine."Quarter Start Date" := "Quarter Start Date";
                lvPayVouchLine."Quarter End Date" := "Quarter End Date";

                //lvPayVouchLine."Accounting Period" := "Accounting Period"; // Month in which the posting date falls.
                //lvPayVouchLine."Fiscal Year" := "Fiscal Year";    // Fiscal Year
                //lvPayVouchLine."Filter to Date" := "Filter to Date";   // From Start of Fiscal Year to the Posting Date
                //lvPayVouchLine.Quarter := Quarter; // Quarter in which the posting date falls.
                //lvPayVouchLine.VALIDATE("Accounting Period");
                //lvPayVouchLine.VALIDATE("Filter to Date");
                //lvPayVouchLine.VALIDATE("Fiscal Year");
                //lvPayVouchLine.VALIDATE(Quarter);
                lvPayVouchLine.MODIFY;
            UNTIL lvPayVouchLine.NEXT = 0;
    end;

    // local procedure newProcedure(var lvPaytVoucherHeaderArchieve: Record "Payt Voucher Header Archieve")
    // begin
    //     lvPaytVoucherHeaderArchieve.INSERT;
    // end;

    /// <summary>
    /// Description for TransferPayeeLinesToJournal.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Parameter of type Record "51402242".</param>
    procedure TransferPayeeLinesToJournal(PaymentVoucherHeader: Record "Payment Voucher Header");
    var
        PaymentVoucherLine: Record "Payment Voucher Line";
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        // NFLApprovalsManagement: Codeunit "NFL Approvals Management";
        [InDataSet]
        PaymentVoucherLinesVisible: Boolean;
        ChangeExchangeRate: Page "Change Exchange Rate";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        DocumentNo: Code[20];
        SelectTemplateBatch: Report "Select Template & Batch";
        gvJournalTemplateName: Code[20];
        gvJournalBatchName: Code[20];
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        GeneralLedgerSetup: Record "General Ledger Setup";
        lvPaymentVoucherHeader: Record "Payment Voucher Header";
    begin
        IF NOT CONFIRM('Do you really want to transfer the payment voucher to the journal lines?', FALSE) THEN
            EXIT;

        SelectTemplateBatch.RUN;
        PurchasesPayablesSetup.GET;
        gvJournalTemplateName := PurchasesPayablesSetup."Payment Voucher Jnl. Template";
        gvJournalBatchName := PurchasesPayablesSetup."Payment Voucher Jnl. Batch";

        lvPaymentVoucherHeader.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
        lvPaymentVoucherHeader.SETRANGE("No.", PaymentVoucherHeader."No.");
        IF lvPaymentVoucherHeader.FIND('-') THEN BEGIN
            // Cheque vouchers are approved by CEO/CFO after the payment file has been exported and uploaded to the bank portal.
            // thus there is need to export it to the journals when it is still pending approval.
            //IF lvPaymentVoucherHeader."Document Type" <> lvPaymentVoucherHeader."Document Type"::"Cheque Payment Voucher" THEN
            lvPaymentVoucherHeader.TESTFIELD(Status, PaymentVoucherHeader.Status::Released);
            //ELSE
            //lvPaymentVoucherHeader.TESTFIELD(Status, PaymentVoucherHeader.Status::"Pending Approval");

            IF lvPaymentVoucherHeader."Transferred to Journals" = TRUE THEN
                ERROR('The payment requisition has already been transferred to the journals');

            // Prevent sending blank payee requisiton lines for approval.
            PaymentVoucherLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
            PaymentVoucherLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
            IF PaymentVoucherLine.FINDFIRST THEN
                REPEAT
                    PaymentVoucherLine.TESTFIELD("Account No.");
                    PaymentVoucherLine.TESTFIELD("Account Name");
                    PaymentVoucherLine.TESTFIELD(Description);
                    PaymentVoucherLine.TESTFIELD(Amount);
                    IF lvPaymentVoucherHeader."Payment Type" <> lvPaymentVoucherHeader."Payment Type"::"Supplier Payment" THEN BEGIN
                        PaymentVoucherLine.TESTFIELD("Shortcut Dimension 1 Code");
                        PaymentVoucherLine.TESTFIELD("Dimension Set ID");
                    END;

                    IF lvPaymentVoucherHeader."Balancing Entry" = lvPaymentVoucherHeader."Balancing Entry"::"Same Line" THEN
                        PaymentVoucherLine.TESTFIELD("Bal. Account No.")
                    ELSE
                        IF lvPaymentVoucherHeader."Balancing Entry" = lvPaymentVoucherHeader."Balancing Entry"::"Different Line" THEN
                            PaymentVoucherLine.TESTFIELD("Bal. Account No.", ''); // Because the balancing line is done on a different line.

                    IF lvPaymentVoucherHeader."Payment Type" = lvPaymentVoucherHeader."Payment Type"::Advance THEN BEGIN
                        IF PaymentVoucherLine."Account No." = PaymentVoucherLine."Control Account" THEN
                            ERROR('Control Account must be different from the Account No. for Staff Advance requisitions');
                    END;
                //IF PaymentVoucherLine."Account Type" = PaymentVoucherLine."Account Type"::Vendor THEN BEGIN
                //PaymentVoucherLine.TESTFIELD("Applies-to Doc. Type");
                //PaymentVoucherLine.TESTFIELD("Applies-to Doc. No.");
                //END;
                UNTIL PaymentVoucherLine.NEXT = 0;
            TransferToJournal(lvPaymentVoucherHeader."No.", gvJournalTemplateName, gvJournalBatchName, lvPaymentVoucherHeader."Document Type");
        END;
    end;

    /// <summary>
    /// Description for TransferToJournal.
    /// </summary>
    /// <param name="DocumentNumber">Parameter of type Code[20].</param>
    /// <param name="parGenJournalTemplate">Parameter of type Code[20].</param>
    /// <param name="parGenJournalBatch">Parameter of type Code[20].</param>
    /// <param name="DocumentType">Parameter of type Option "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher".</param>
    procedure TransferToJournal(var DocumentNumber: Code[20]; var parGenJournalTemplate: Code[20]; var parGenJournalBatch: Code[20]; var DocumentType: Option "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher");
    var
        PaymentVoucherLine: Record "Payment Voucher Line";
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        TotalExpenditureAmount: Decimal;
        TotalPayeeAmount: Decimal;
        PaymentVoucherLine2: Record "Payment Voucher Line";
        AmountDifference: Decimal;
        GenJournalLine: Record "Gen. Journal Line";
        Counter: Integer;
        GenJournalLine1: Record "Gen. Journal Line";
        "-- MAG--": Integer;
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesCode: Code[20];
        NoSeriesLines: Record "No. Series Line";
        LastUsedNo: Code[20];
        NewNoSeriesCode: Code[20];
        i: Integer;
        DocumentNo: Code[20];
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        Text001: Label 'Total Payee amount is less total Expenditure amount by %1. Are you sure you want to transfer the entries to the journal';
        Text002: Label 'Status for No %1 must be Released in order to archive this Requisition';
        Text003: Label 'You are not permitted to Archieve  document No. %1';
        lvGenJournalTemplate: Record "Gen. Journal Template";
        lvGenJournalBatch: Record "Gen. Journal Batch";
        lvNoSeries: Record "No. Series";
        lvNoSeriesLine: Record "No. Series Line";
        NoOfPayVouchLines: Integer;
    begin
        //- begin
        CLEAR(TotalExpenditureAmount);
        CLEAR(TotalPayeeAmount);
        PaymentVoucherHeader.GET(DocumentNumber, DocumentType);

        PaymentVoucherLine.RESET;
        PaymentVoucherDetail.SETRANGE("Document No.", DocumentNumber);
        PaymentVoucherDetail.SETRANGE("Document Type", DocumentType);
        IF PaymentVoucherDetail.FINDSET THEN BEGIN
            REPEAT
                TotalExpenditureAmount += PaymentVoucherDetail.Amount;
            UNTIL PaymentVoucherDetail.NEXT = 0;
        END;

        PaymentVoucherLine.RESET;
        PaymentVoucherLine.SETRANGE("Document No.", DocumentNumber);
        PaymentVoucherLine.SETRANGE("Document Type", DocumentType);
        IF PaymentVoucherLine.FINDSET THEN BEGIN
            REPEAT
                TotalPayeeAmount += PaymentVoucherLine.Amount;
            UNTIL PaymentVoucherLine.NEXT = 0;
        END;

        IF PaymentVoucherHeader."Balancing Entry" = PaymentVoucherHeader."Balancing Entry"::"Same Line" THEN
            IF TotalPayeeAmount <= 0 THEN
                ERROR('There is nothing to transfer to the journal');


        IF (TotalPayeeAmount > TotalExpenditureAmount) AND (PaymentVoucherHeader."Balancing Entry" = PaymentVoucherHeader."Balancing Entry"::"Same Line") THEN
            ERROR('Total Payee amount exceeds total Expenditure amount by %1', (TotalPayeeAmount - TotalExpenditureAmount))
        ELSE BEGIN
            AmountDifference := TotalExpenditureAmount - TotalPayeeAmount;
            IF (AmountDifference > 0) AND (PaymentVoucherHeader."Balancing Entry" = PaymentVoucherHeader."Balancing Entry"::"Same Line") THEN BEGIN
                IF NOT CONFIRM(STRSUBSTNO(Text001, AmountDifference)) THEN
                    EXIT;
            END;
            CLEAR(i);
            CLEAR(Counter);
            PaymentVoucherLine2.RESET;
            PaymentVoucherLine2.SETRANGE("Document No.", DocumentNumber);
            PaymentVoucherLine2.SETRANGE("Document Type", DocumentType);
            IF PaymentVoucherLine2.FINDSET THEN BEGIN
                REPEAT
                    GenJournalLine.RESET;
                    GenJournalLine.INIT;
                    // - Get the next document number.
                    GenJournalLine1.RESET;
                    GenJournalLine1.SETRANGE("Journal Template Name", parGenJournalTemplate);
                    GenJournalLine1.SETRANGE("Journal Batch Name", parGenJournalBatch);
                    IF GenJournalLine1.FINDLAST THEN BEGIN
                        GenJournalLine."Line No." := GenJournalLine1."Line No." + 10000;
                        IF Counter = 0 THEN
                            DocumentNo := INCSTR(GenJournalLine1."Document No.");
                    END ELSE BEGIN  // Journal batch empty, check whether no. serires are assigned to the batch
                        GenJournalLine."Line No." := 10000;
                        lvGenJournalBatch.SETRANGE("Journal Template Name", parGenJournalTemplate);
                        lvGenJournalBatch.SETRANGE(Name, parGenJournalBatch);
                        IF lvGenJournalBatch.FIND('-') THEN BEGIN
                            lvGenJournalBatch.TESTFIELD("No. Series");
                            lvNoSeries.SETRANGE(Code, lvGenJournalBatch."No. Series");
                            IF lvNoSeries.FIND('-') THEN BEGIN
                                lvNoSeriesLine.SETRANGE("Series Code", lvNoSeries.Code);
                                IF lvNoSeriesLine.FIND('-') THEN BEGIN
                                    lvNoSeriesLine.TESTFIELD("Starting No.");
                                    IF lvNoSeriesLine."Last No. Used" = '' THEN BEGIN
                                        IF Counter = 0 THEN
                                            DocumentNo := lvNoSeriesLine."Starting No.";
                                    END ELSE
                                        IF lvNoSeriesLine."Last No. Used" <> '' THEN BEGIN
                                            IF Counter = 0 THEN;
                                            DocumentNo := INCSTR(lvNoSeriesLine."Last No. Used");
                                        END;
                                END;
                            END ELSE
                                ERROR('There are no No. Series Lines for %1', lvNoSeries.Code);
                        END;
                    END;
                    //  END.
                    GenJournalLine."Journal Template Name" := parGenJournalTemplate;
                    GenJournalLine."Journal Batch Name" := parGenJournalBatch;
                    GenJournalLine."Document No." := DocumentNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Document Date" := TODAY;
                    IF PaymentVoucherLine2."Account Type" = PaymentVoucherLine2."Account Type"::"G/L Account" THEN BEGIN
                        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", PaymentVoucherLine2."Account No.");
                    END;
                    IF PaymentVoucherLine2."Account Type" = PaymentVoucherLine2."Account Type"::Vendor THEN BEGIN
                        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Vendor);
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", PaymentVoucherLine2."Account No.");
                    END;
                    IF PaymentVoucherLine2."Account Type" = PaymentVoucherLine2."Account Type"::Advance THEN BEGIN
                        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", PaymentVoucherLine2."Control Account");
                    END;
                    IF PaymentVoucherLine2."Account Type" = PaymentVoucherLine2."Account Type"::"Bank Account" THEN BEGIN
                        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"Bank Account");
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", PaymentVoucherLine2."Account No.");
                    END;
                    IF PaymentVoucherLine2."Account Type" = PaymentVoucherLine2."Account Type"::Customer THEN BEGIN
                        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Customer);
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.", PaymentVoucherLine2."Account No.");
                        GenJournalLine.VALIDATE(GenJournalLine."Document Type", GenJournalLine."Document Type"::Refund);
                    END;

                    GenJournalLine.Amount := PaymentVoucherLine2.Amount;
                    GenJournalLine.Description := PADSTR(COPYSTR(PaymentVoucherLine2.Description, 1, 50), 50);
                    GenJournalLine."Payment Voucher" := TRUE;
                    GenJournalLine."Payment Voucher No." := PaymentVoucherHeader."No.";
                    GenJournalLine."Bank File Generated" := PaymentVoucherLine2."Bank File Generated";
                    GenJournalLine."Bank File Generated On" := PaymentVoucherLine2."Bank File Generated On";
                    GenJournalLine."Bank File Gen. by" := PaymentVoucherLine2."Bank File Gen. by";
                    GenJournalLine."Advance Code" := PaymentVoucherLine2."Advance Code";
                    // GenJournalLine."Cashier ID" := USERID;
                    GenJournalLine."Loan Type" := PaymentVoucherLine2."Loan Type";
                    GenJournalLine."Voucher Acc. Account" := PaymentVoucherLine2."Account Type";

                    IF PaymentVoucherLine2."Bal. Account Type" = PaymentVoucherLine2."Bal. Account Type"::"G/L Account" THEN
                        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                    IF PaymentVoucherLine2."Bal. Account Type" = PaymentVoucherLine2."Bal. Account Type"::"Bank Account" THEN
                        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
                    GenJournalLine.VALIDATE("Bal. Account No.", PaymentVoucherLine2."Bal. Account No.");
                    GenJournalLine.VALIDATE("Currency Code", PaymentVoucherHeader."Currency Code");
                    GenJournalLine.VALIDATE("Currency Factor", PaymentVoucherHeader."Currency Factor");
                    GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", PaymentVoucherLine2."Shortcut Dimension 1 Code");
                    GenJournalLine.VALIDATE("Dimension Set ID", PaymentVoucherLine2."Dimension Set ID");
                    GenJournalLine.INSERT;
                    GenJournalLine.VALIDATE("Appl.-to Commitment Entry", PaymentVoucherLine2."Commitment Entry No.");
                    GenJournalLine.VALIDATE("Applies-to Doc. Type", PaymentVoucherLine2."Applies-to Doc. Type"::Invoice);
                    GenJournalLine.VALIDATE("Applies-to Doc. No.", PaymentVoucherLine2."Applies-to Doc. No.");

                    GenJournalLine.MODIFY;
                    Counter += 1;
                UNTIL PaymentVoucherLine2.NEXT = 0;
            END;

            IF Counter > 0 THEN BEGIN
                //ArchiveRequisition;
                MESSAGE('Transfered %1 payee entries to the journal', Counter);
            END ELSE
                MESSAGE('No payee lines were transfered to the journal');

            PaymentVoucherHeader."Transferred to Journals" := TRUE;
            PaymentVoucherHeader.MODIFY;
            // ArchiveRequisition(PaymentVoucherHeader);

        END;
        //  END
    end;

    /// <summary>
    /// Description for ShowPaymentVoucherDocument.
    /// </summary>
    /// <param name="DocumentNo">Parameter of type Code[20].</param>
    /// <param name="DocumentType">Parameter of type Option "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher".</param>
    procedure ShowPaymentVoucherDocument(var DocumentNo: Code[20]; var DocumentType: Option "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher");
    var
        PaymentJnl: Record "Gen. Journal Line";
        PurchHeader: Record "NFL Requisition Header";
        BankReconn: Record "Bank Acc. Reconciliation";
        PaymentVoucherHeader: Record "Payment Voucher Header";
    begin
        IF NOT PaymentVoucherHeader.GET(DocumentNo, DocumentType) THEN
            EXIT;

        CASE "Document Type" OF
            "Document Type"::"Cash Voucher":
                PAGE.RUN(PAGE::"Cash Voucher", PaymentVoucherHeader);
        END;
    end;

    /// <summary>
    /// Description for ArchiveRequisition.
    /// </summary>
    /// <param name="PaymentVoucherHeader">Parameter of type Record "51402242".</param>
    // procedure ArchiveRequisition(var PaymentVoucherHeader: Record "Payment Voucher Header");
    // var
    //     lvPaytVoucherHeaderArchieve: Record "Payt Voucher Header Archieve";
    //     lvPaytVoucherDetailArchieve: Record "Payt Voucher Detail Archieve";
    //     lvPaytVoucherLineArchieve: Record "Payt Voucher Line Archieve";
    //     lvPaymentVoucherHeader: Record "Payment Voucher Header";
    //     lvPaymentVoucherLine: Record "Payment Voucher Line";
    //     lvPaymentVoucherDetail: Record "Payment Voucher Detail";
    //     NoSeries: Record "No. Series";
    //     NewNo: Code[20];
    //     NoSeriesManagement: Codeunit NoSeriesManagement;
    //     // lvNFLPstdApprovalCommentLine: Record "NFL Pstd Approval Comment Line";
    //     NFLApprovalCommentLine: Record "NFL Approval Comment Line";
    // // lvNFLApprovalEntry: Record "NFL Approval Entry";
    // // lvNFLPostedApprovalEntry: Record "NFL Posted Approval Entry";
    // begin
    //     //
    //     CLEAR(NewNo);
    //     lvPaytVoucherHeaderArchieve.INIT;
    //     lvPaytVoucherHeaderArchieve.TRANSFERFIELDS(PaymentVoucherHeader);
    //     lvPaytVoucherHeaderArchieve."Voucher No." := PaymentVoucherHeader."No.";

    //     PurchasesPayablesSetup.GET;
    //     PurchasesPayablesSetup.TESTFIELD(PurchasesPayablesSetup."Payment Voucher Archieve Nos.");
    //     NoSeries.RESET;
    //     NoSeries.SETRANGE(Code, PurchasesPayablesSetup."Payment Voucher Archieve Nos.");
    //     IF NoSeries.FINDFIRST THEN BEGIN
    //         NewNo := NoSeriesManagement.GetNextNo(NoSeries.Code, 0D, TRUE);
    //     END;

    //     lvPaytVoucherHeaderArchieve."No." := NewNo;
    //     PaymentVoucherHeader.CALCFIELDS("Payment Voucher Details Total");
    //     PaymentVoucherHeader.CALCFIELDS("Payment Voucher Lines Total");
    //     lvPaytVoucherHeaderArchieve."Payment Voucher Details Total" := PaymentVoucherHeader."Payment Voucher Details Total";
    //     lvPaytVoucherHeaderArchieve."Payment Voucher Lines Total" := PaymentVoucherHeader."Payment Voucher Lines Total";
    //     lvPaytVoucherHeaderArchieve."Hub Code" := PaymentVoucherHeader."Hub Code";
    //     lvPaytVoucherHeaderArchieve.COPYLINKS(PaymentVoucherHeader);
    //     newProcedure(lvPaytVoucherHeaderArchieve);

    //     // // Copy voucher lines.
    //     // lvNFLPstdApprovalCommentLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     // lvNFLPstdApprovalCommentLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     // lvNFLPstdApprovalCommentLine.DELETEALL;

    //     // NFLApprovalCommentLine.RESET;
    //     // NFLApprovalCommentLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     // NFLApprovalCommentLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     // IF NFLApprovalCommentLine.FINDSET THEN BEGIN
    //     //     REPEAT
    //     //         lvNFLPstdApprovalCommentLine.INIT;
    //     //         lvNFLPstdApprovalCommentLine.TRANSFERFIELDS(NFLApprovalCommentLine);
    //     //         lvNFLPstdApprovalCommentLine.INSERT;
    //     //         NFLApprovalCommentLine.DELETE;
    //     //     UNTIL NFLApprovalCommentLine.NEXT = 0;
    //     // END;

    //     // // Copy Approval Entries.
    //     // lvNFLPostedApprovalEntry.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     // lvNFLPostedApprovalEntry.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     // lvNFLPostedApprovalEntry.DELETEALL;

    //     // // Copy Approval Entry.
    //     // lvNFLApprovalEntry.RESET;
    //     // lvNFLApprovalEntry.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     // lvNFLApprovalEntry.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     // IF lvNFLApprovalEntry.FINDSET THEN BEGIN
    //     //     REPEAT
    //     //         lvNFLPostedApprovalEntry.INIT;
    //     //         lvNFLPostedApprovalEntry.TRANSFERFIELDS(lvNFLApprovalEntry);
    //     //         lvNFLPostedApprovalEntry.INSERT;
    //     //         lvNFLApprovalEntry.DELETE;
    //     //     UNTIL lvNFLApprovalEntry.NEXT = 0;
    //     // END;

    //     // Copy Detail lines.
    //     lvPaymentVoucherDetail.RESET;
    //     lvPaymentVoucherDetail.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     lvPaymentVoucherDetail.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     IF lvPaymentVoucherDetail.FINDSET THEN BEGIN
    //         REPEAT
    //             lvPaytVoucherDetailArchieve.INIT;
    //             lvPaytVoucherDetailArchieve.TRANSFERFIELDS(lvPaymentVoucherDetail);
    //             lvPaytVoucherDetailArchieve."Document No." := NewNo;
    //             lvPaytVoucherDetailArchieve.INSERT;
    //             lvPaymentVoucherDetail.DELETE;
    //         UNTIL lvPaymentVoucherDetail.NEXT = 0;
    //     END;

    //     // Copy voucher lines.
    //     lvPaymentVoucherLine.RESET;
    //     lvPaymentVoucherLine.SETRANGE("Document No.", PaymentVoucherHeader."No.");
    //     lvPaymentVoucherLine.SETRANGE("Document Type", PaymentVoucherHeader."Document Type");
    //     IF lvPaymentVoucherLine.FINDSET THEN BEGIN
    //         REPEAT
    //             lvPaytVoucherLineArchieve.INIT;
    //             lvPaytVoucherLineArchieve.TRANSFERFIELDS(lvPaymentVoucherLine);
    //             lvPaytVoucherLineArchieve."Document No." := NewNo;

    //             lvPaymentVoucherLine.CALCFIELDS("Budget Amount as at Date");
    //             lvPaymentVoucherLine.CALCFIELDS("Budget Amount for the Year");
    //             lvPaymentVoucherLine.CALCFIELDS("Budget Amount for the Month");
    //             lvPaymentVoucherLine.CALCFIELDS("Budget Amount for the Quarter");

    //             lvPaymentVoucherLine.CALCFIELDS("Actual Amount as at Date");
    //             lvPaymentVoucherLine.CALCFIELDS("Actual Amount for the Year");
    //             lvPaymentVoucherLine.CALCFIELDS("Actual Amount for the Month");
    //             lvPaymentVoucherLine.CALCFIELDS("Actual Amount for the Quarter");

    //             lvPaymentVoucherLine.CALCFIELDS("Commitment Amount as at Date");
    //             lvPaymentVoucherLine.CALCFIELDS("Commitment Amount for the Year");
    //             lvPaymentVoucherLine.CALCFIELDS("Commitment Amt for the Month");
    //             lvPaymentVoucherLine.CALCFIELDS("Commitment Amt for the Quarter");

    //             lvPaytVoucherLineArchieve."Budget Amount as at Date" := lvPaymentVoucherLine."Budget Amount as at Date";
    //             lvPaytVoucherLineArchieve."Budget Amount for the Year" := lvPaymentVoucherLine."Budget Amount for the Year";
    //             lvPaytVoucherLineArchieve."Budget Amount for the Month" := lvPaymentVoucherLine."Budget Amount for the Month";
    //             lvPaytVoucherLineArchieve."Budget Amount for the Quarter" := lvPaymentVoucherLine."Budget Amount for the Quarter";

    //             lvPaytVoucherLineArchieve."Actual Amount as at Date" := lvPaymentVoucherLine."Actual Amount as at Date";
    //             lvPaytVoucherLineArchieve."Actual Amount for the Year" := lvPaymentVoucherLine."Actual Amount for the Year";
    //             lvPaytVoucherLineArchieve."Actual Amount for the Month" := lvPaymentVoucherLine."Actual Amount for the Month";
    //             lvPaytVoucherLineArchieve."Actual Amount for the Quarter" := lvPaymentVoucherLine."Actual Amount for the Quarter";

    //             lvPaytVoucherLineArchieve."Commitment Amount as at Date" := lvPaymentVoucherLine."Commitment Amount as at Date";
    //             lvPaytVoucherLineArchieve."Commitment Amount for the Year" := lvPaymentVoucherLine."Commitment Amount for the Year";
    //             lvPaytVoucherLineArchieve."Commitment Amt for the Month" := lvPaymentVoucherLine."Commitment Amt for the Month";
    //             lvPaytVoucherLineArchieve."Commitment Amt for the Quarter" := lvPaymentVoucherLine."Commitment Amt for the Quarter";

    //             lvPaytVoucherLineArchieve.INSERT;

    //             //Reversing the Payment Voucher Line ==
    //             ReverseCommitment(lvPaymentVoucherLine, FORMAT(PaymentVoucherHeader.Status));
    //             //End

    //             lvPaymentVoucherLine.DELETE;
    //         UNTIL lvPaymentVoucherLine.NEXT = 0;
    //     END;
    //     PaymentVoucherHeader.DELETE;

    //     //  -END
    // end;

    /// <summary>
    /// Description for ReverseCommitment.
    /// </summary>
    /// <param name="PaymentVoucherLines">Parameter of type Record "Payment Voucher Line".</param>
    /// <param name="DocumentStatus">Parameter of type Code[20].</param>
    procedure ReverseVoucherCommitment(var PaymentVoucherLines: Record "Payment Voucher Line"; DocumentStatus: Code[20]);
    begin
        //Reverse out commitment.
        gvCommitmentEntry.SETRANGE("Entry No.", PaymentVoucherLines."Commitment Entry No.");
        IF gvCommitmentEntry.FIND('-') THEN BEGIN
            IF NOT lastCommitmentEntry.FINDLAST THEN
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
            ELSE
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;

            reversedCommitmentEntry.INIT;
            reversedCommitmentEntry := lastCommitmentEntry;
            reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
            reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
            reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
            reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
            reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
            reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
            reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
            reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
            reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
            reversedCommitmentEntry.Quantity := 1 * gvCommitmentEntry.Quantity;
            reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
            reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
            reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
            reversedCommitmentEntry.Reversed := TRUE;
            reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
            reversedCommitmentEntry."User ID" := USERID;
            reversedCommitmentEntry."Source Code" := DocumentStatus;
            reversedCommitmentEntry.INSERT;
            gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
            gvCommitmentEntry.Reversed := true;
            gvCommitmentEntry.MODIFY;
        END;
        //END.
    end;
}

