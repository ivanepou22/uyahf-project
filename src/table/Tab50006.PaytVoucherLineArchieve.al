/// <summary>
/// Table Payt Voucher Line Archieve (ID 50089).
/// </summary>
table 50006 "Payt Voucher Line Archieve"
{
    // version MAG

    Caption = 'Payt Voucher Line Archieve';

    fields
    {
        field(1; "Document No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Account No."; Code[20])
        {
            TableRelation = IF ("Account Type" = FILTER("G/L Account")) "G/L Account"."No." WHERE(Blocked = CONST(false),
                                                                                           "Account Type" = CONST(Posting))
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor."No.";
        }
        field(4; "Account Name"; Text[150])
        {
            Editable = false;
        }
        field(5; Description; Text[150])
        {
            Caption = 'Description';
        }
        field(6; Amount; Decimal)
        {
            DecimalPlaces = 0 : 2;

            trigger OnValidate();
            var
                TotalExpenditure: Decimal;
                TotalPayeeAmount: Decimal;
            begin
            end;
        }
        field(7; "Account Type"; Option)
        {
            OptionCaption = '" ,G/L Account,Vendor,Advance,Bank Account,Customer"';
            OptionMembers = " ","G/L Account",Vendor,Advance,"Bank Account",Customer;
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(10; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";
        }
        field(14; "Budget Code"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }
        field(17; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'Bank Account,G/L Account';
            OptionMembers = "Bank Account","G/L Account";
        }
        field(18; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                           Blocked = CONST(false))
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account";

            trigger OnValidate();
            var
                lvVendorBankRec: Record "Vendor Bank Account";
            begin
            end;
        }
        field(19; WHT; Boolean)
        {
        }
        field(20; "Source Line No. For WHT"; Integer)
        {
        }
        field(21; "Budget Amount as at Date"; Decimal)
        {
            Caption = 'Budget Amount as at Date';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(22; "Budget Amount for the Year"; Decimal)
        {
            Caption = 'Budget Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(24; "Actual Amount as at Date"; Decimal)
        {
            Caption = 'Actual Amount as at Date';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(25; "Actual Amount for the Year"; Decimal)
        {
            Caption = 'Actual Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(26; "Balance on Budget as at Date"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(27; "Balance on Budget for the Year"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(28; "Bal. on Budget for the Month"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;

            trigger OnValidate();
            var
                lvNFLRequisitionLine: Record "NFL Requisition Line";
            begin
            end;
        }
        field(29; "Budget Comment as at Date"; Text[50])
        {
            Editable = false;
        }
        field(30; "Budget Comment for the Year"; Text[50])
        {
            Editable = false;
        }
        field(33; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(35; "Fiscal Year Date Filter"; Date)
        {
            Caption = 'Fiscal Year Date Filter';
            FieldClass = FlowFilter;
        }
        field(36; "Filter to Date Filter"; Date)
        {
            Caption = 'Filter to Date Filter';
            FieldClass = FlowFilter;
        }
        field(37; "Month Date Filter"; Date)
        {
            Caption = 'Month Date Filter';
            FieldClass = FlowFilter;
        }
        field(38; "Quarter Date Filter"; Date)
        {
            Caption = 'Quarter Date Filter';
            FieldClass = FlowFilter;
        }
        field(40; "Commitment Entry No."; Integer)
        {
            Description = 'Identifies a line that has been commited';
        }
        field(41; "Commitment Amount as at Date"; Decimal)
        {
            Caption = 'Commitment Amount as at Date';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(42; "Commitment Amount for the Year"; Decimal)
        {
            Caption = 'Commitment Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(43; "Purchase Orders"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Purchase Requisition No." = FIELD("Document No.")));
            Caption = 'Purchase Orders';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Purchase Header" WHERE("Document Type" = FILTER(Order));
        }
        field(44; "Commitment Amt for the Month"; Decimal)
        {
            Caption = 'Commitment Amt for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(45; "Commitment Amt for the Quarter"; Decimal)
        {
            Caption = 'Commitment Amt for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(46; "Actual Amount for the Month"; Decimal)
        {
            Caption = 'Actual Amount for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(47; "Actual Amount for the Quarter"; Decimal)
        {
            Caption = 'Actual Amount for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(48; "Budget Comment for the Month"; Text[50])
        {
            Caption = 'Budget Comment for the Month';
            Editable = false;
        }
        field(49; "Budget Comment for the Quarter"; Text[50])
        {
            Caption = 'Budget Comment for the Quarter';
            Editable = false;
        }
        field(50; "Budget Amount for the Month"; Decimal)
        {
            Caption = 'Budget Amount for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(51; "Budget Amount for the Quarter"; Decimal)
        {
            Caption = 'Budget Amount for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(52; "Bal. on Budget for the Quarter"; Decimal)
        {
            Caption = 'Bal. on Budget for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(53; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(92; "Posting Date"; Date)
        {
        }
        field(93; "Control Account"; Code[20])
        {
            Description = 'Holds a control account for an Item or Fixed Asset Purchase line Commitment';
            TableRelation = "G/L Account"."No.";
        }
        field(94; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DecimalPlaces = 0 : 2;
            Description = 'Handles the LCY Amount for Line Amount';
            Editable = false;
        }
        field(95; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = '" ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund"';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(96; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';

            trigger OnLookup();
            var
                PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
                AccType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";
                AccNo: Code[20];
                ApplyVendEntries: Page "Apply Vendor Entries";
            begin
            end;

            trigger OnValidate();
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                VendLedgEntry: Record "Vendor Ledger Entry";
                TempGenJnlLine: Record "Gen. Journal Line" temporary;
                TpGenJnlLine: Record "Gen. Journal Line" temporary;
            begin
            end;
        }
        field(97; "Bank Account"; Code[10])
        {
            Caption = 'Preferred Bank Account';
            TableRelation = "Vendor Bank Account".Code WHERE("Vendor No." = FIELD("Account No."));
        }
        field(98; "Bank File Generated"; Boolean)
        {
            Editable = false;
        }
        field(99; "Bank File Generated On"; Date)
        {
            Editable = false;
        }
        field(100; "Bank File Gen. by"; Code[50])
        {
            Editable = false;
        }
        field(101; "Advance Code"; Code[20])
        {
            Description = 'Staff Members'' Codes for tracking advances and loans';
            TableRelation = "Staff Advances";
        }
        field(102; "Income/Balance"; Option)
        {
            Caption = 'Income/Balance';
            Description = 'If Balance Sheet, then skip budget check';
            Editable = false;
            OptionCaption = 'Income Statement,Balance Sheet';
            OptionMembers = "Income Statement","Balance Sheet";

            trigger OnValidate();
            var
                CostType: Record "Cost Type";
            begin
            end;
        }
        field(103; "Accounting Period Start Date"; Date)
        {
            Editable = false;
        }
        field(104; "Accounting Period End Date"; Date)
        {
            Editable = false;
        }
        field(105; "Fiscal Year Start Date"; Date)
        {
            Editable = false;
        }
        field(106; "Fiscal Year End Date"; Date)
        {
            Editable = false;
        }
        field(107; "Filter to Date Start Date"; Date)
        {
            Editable = false;
        }
        field(108; "Filter to Date End Date"; Date)
        {
            Editable = false;
        }
        field(109; "Quarter Start Date"; Date)
        {
            Editable = false;
        }
        field(110; "Quarter End Date"; Date)
        {
            Editable = false;
        }
        field(111; "Budget Comment"; Text[50])
        {
            Description = 'if both "as at date" and "monthly" analyses are within budget then the budget comment should be "within budget" else "out of budget"';
        }
        field(112; "Beneficary Name"; Text[50])
        {
        }
        field(113; "Beneficary Bank Account No."; Code[20])
        {
        }
        field(114; "Beneficary Bank Name"; Text[50])
        {
        }
        field(115; "Beneficary Bank Code"; Code[20])
        {
        }
        field(116; "Beneficary Branch Code"; Code[20])
        {
        }
        field(117; "Exclude Amount"; Boolean)
        {
            InitValue = true;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions;
            end;
        }
        field(50090; "Loan Type"; Code[150])
        {
            Caption = 'Loan Type';
            // TableRelation = "Loan Types";
        }

    }

    keys
    {
        key(Key1; "Document No.", "Document Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        PaymentVoucherHeader: Record "Payment Voucher Header";
        PaymentVoucherLine: Record "Payment Voucher Line";
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        DimMgt: Codeunit DimensionManagement;
        CommitmentEntry: Record "Commitment Entry";
        LineAmount: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
        DeferralPostDate: Date;
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        FromCurrencyCode: Code[10];
        ToCurrencyCode: Code[10];
        Text003: Label 'The %1 in the %2 will be changed from %3 to %4.\Do you want to continue?';
        Text005: Label 'The update has been interrupted to respect the warning.';
        Text009: Label 'LCY';
        ApplyVendorEntries: Page "Apply Vendor Entries";
        gvUserSetup: Record "User Setup";

    /// <summary>
    /// Description for ValidateShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <param name="ShortcutDimCode">Parameter of type Code[20].</param>
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    /// <summary>
    /// Description for ShowDimensions.
    /// </summary>
    procedure ShowDimensions();
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2', "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    /// <summary>
    /// Description for TestStatusPendingApproval.
    /// </summary>
    local procedure TestStatusPendingApproval();
    begin
        GetPaymentVoucherHeader;
        PaymentVoucherHeader.TESTFIELD(Status, PaymentVoucherHeader.Status::"Pending Approval");
    end;

    /// <summary>
    /// Description for GetPaymentVoucherHeader.
    /// </summary>
    local procedure GetPaymentVoucherHeader();
    begin
        TESTFIELD("Document No.");
        IF ("Document Type" <> PaymentVoucherHeader."Document Type") OR ("Document No." <> PaymentVoucherHeader."No.") THEN BEGIN
            PaymentVoucherHeader.GET("Document No.", "Document Type");
        END;
    end;

    /// <summary>
    /// Description for AreLineChangesAllowed.
    /// </summary>
    local procedure AreLineChangesAllowed();
    var
        WHTPaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 26TH JULY 2018 - Prevent Modifying a WHT Line or a WHT Parent Line
        IF WHT THEN
            ERROR('WHT Line cannot be modified')
        ELSE BEGIN
            WHTPaymentVoucherLine.SETRANGE(WHT, TRUE);
            WHTPaymentVoucherLine.SETRANGE("Source Line No. For WHT", "Line No.");
            IF WHTPaymentVoucherLine.FINDFIRST THEN
                ERROR('You  cannot modify this transaction because it has a WHT Line No. %1', WHTPaymentVoucherLine."Line No.");
        END;
        // MAG - END.
    end;

    /// <summary>
    /// Description for DeleteParentLineAndChild.
    /// </summary>
    local procedure DeleteParentLineAndChild();
    var
        WHTPaymentVoucherLine: Record "Payment Voucher Line";
    begin
        // MAG 26TH JULY 2018 - Delete Line
        IF WHT THEN
            ERROR('WHT Line cannot be deleted')
        ELSE BEGIN
            WHTPaymentVoucherLine.SETRANGE(WHT, TRUE);
            WHTPaymentVoucherLine.SETRANGE("Source Line No. For WHT", "Line No.");
            IF WHTPaymentVoucherLine.FINDFIRST THEN
                WHTPaymentVoucherLine.DELETE;
        END;
        // MAG - END
    end;

    /// <summary>
    /// Description for GetDate.
    /// </summary>
    /// <returns>Return variable "Date".</returns>
    procedure GetDate(): Date;
    begin
        IF ("Document Type" IN ["Document Type"::"HR Cash Voucher", "Document Type"::"Store Requisition"]) AND
           (PaymentVoucherHeader."Posting Date" = 0D)
        THEN
            EXIT(WORKDATE);
        EXIT(PaymentVoucherHeader."Posting Date");
    end;

    /// <summary>
    /// Description for LookupShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <param name="ShortcutDimCode">Parameter of type Code[20].</param>
    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    /// <summary>
    /// Description for ShowShortcutDimCode.
    /// </summary>
    /// <param name="ShortcutDimCode">Parameter of type array[8] of Code[20].</param>
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20]);
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    /// <summary>
    /// Description for ModificationAllowed.
    /// </summary>
    local procedure ModificationAllowed();
    begin
        gvUserSetup.SETRANGE(gvUserSetup."User ID", USERID);
        IF gvUserSetup.FIND('-') THEN BEGIN
            IF gvUserSetup."Budget Controller" = FALSE THEN
                ERROR('The Payment Voucher line cell can only be modified by the Budget monitoring officer');
        END ELSE
            ERROR('User %1 is not setup for Budget monitoring', USERID);
    end;

    /// <summary>
    /// Description for ApprovedByBudgetMonitorOfficer.
    /// </summary>
    local procedure ApprovedByBudgetMonitorOfficer();
    var
        // lvNFLApprovalEntry: Record "NFL Approval Entry";
        lvUserSetup: Record "User Setup";
    begin
        // MAG 21. OCT. 2018 - BEGIN
        // Prevent Editing of lines once the budget monitoring officer has done the budget checks.
        // Editing should only happen when the NFL Approval Entry is open on the budget monitor's desk
        // lvUserSetup.RESET;
        // lvUserSetup.SETRANGE("User ID", USERID);
        // IF lvUserSetup.FIND('-') THEN BEGIN
        //     IF lvUserSetup."Budget Controller" = FALSE THEN
        //         ERROR('The Payment Voucher line cell can only be modified by the Budget monitoring officer')
        //     ELSE
        //         IF lvUserSetup."Budget Controller" = TRUE THEN BEGIN
        //             // Check whether the budget holder has approved the document.
        //             lvNFLApprovalEntry.SETRANGE("Document Type", "Document Type");
        //             lvNFLApprovalEntry.SETRANGE("Document No.", "Document No.");
        //             lvNFLApprovalEntry.SETRANGE("Approver ID", lvUserSetup."User ID");
        //             lvNFLApprovalEntry.SETRANGE(Status, lvNFLApprovalEntry.Status::Open);
        //             IF NOT lvNFLApprovalEntry.FINDFIRST THEN
        //                 ERROR('You can modify a document that you have already approved');
        //         END;
        // END ELSE
        //     ERROR('User %1 is not setup for Budget monitoring', USERID);
        // // MAG - END.
    end;
}

