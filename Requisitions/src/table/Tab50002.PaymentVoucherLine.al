/// <summary>
/// Table Payment Voucher Line (ID 50218).
/// </summary>
table 50002 "Payment Voucher Line"
{
    // version MAG

    Caption = 'Payment Voucher Line';

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
            IF ("Account Type" = CONST(Vendor)) Vendor."No."
            ELSE
            IF ("Account Type" = CONST(Advance)) "Staff Advances".Code WHERE(Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"."No." WHERE(Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer."No.";

            trigger OnValidate();
            var
                lvCustomer: Record Customer;
            begin
                TestStatusPendingApproval;
                GetPaymentVoucherHeader;
                //Added by SEJ
                IF "Account Type" = "Account Type"::"G/L Account" THEN BEGIN
                    GLAccount.GET("Account No.");
                    IF GLAccount.Blocked THEN
                        ERROR(Text010, "Account No.");
                END
                ELSE
                    IF "Account Type" = "Account Type"::Vendor THEN BEGIN
                        Vendor.GET("Account No.");
                        IF Vendor.Blocked IN [Vendor.Blocked::Payment, Vendor.Blocked::All] THEN
                            ERROR(Text010, "Account No.");
                    END;
                //END

                CASE "Account Type" OF
                    "Account Type"::"Bank Account":
                        BEGIN
                            BankAcc.GET("Account No.");
                            "Account Name" := BankAcc.Name;
                            BankAcc.TESTFIELD(Blocked, FALSE);
                            IF ("Bal. Account No." = '') OR
                               ("Bal. Account Type" IN
                                ["Bal. Account Type"::"G/L Account", "Bal. Account Type"::"Bank Account"])
                            THEN BEGIN

                            END;
                            IF BankAcc."Currency Code" = '' THEN BEGIN
                                IF "Bal. Account No." = '' THEN
                                    "Currency Code" := '';
                            END ELSE
                                IF SetCurrencyCode("Bal. Account Type", "Bal. Account No.") THEN
                                    BankAcc.TESTFIELD("Currency Code", "Currency Code")
                                ELSE BEGIN
                                    PaymentVoucherHeader.TESTFIELD("Currency Code", BankAcc."Currency Code");
                                    "Currency Code" := BankAcc."Currency Code";
                                END;
                        END;
                    "Account Type"::Customer:
                        BEGIN
                            Cust.GET("Account No.");
                            Cust.CheckBlockedCustOnJnls(Cust, "Document Type", FALSE);
                            IF NOT SetCurrencyCode("Bal. Account Type", "Bal. Account No.") THEN
                                "Currency Code" := Cust."Currency Code";
                            IF (Cust."Bill-to Customer No." <> '') AND (Cust."Bill-to Customer No." <> "Account No.") THEN
                                IF NOT CONFIRM(Text014, FALSE, Cust.TABLECAPTION, Cust."No.", Cust.FIELDCAPTION("Bill-to Customer No."),
                                     Cust."Bill-to Customer No.")
                                THEN
                                    ERROR('');
                        END;

                END;

                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;
                GetPaymentVoucherHeader;
                PaymentVoucherHeader.TESTFIELD("Budget Code");
                PaymentVoucherHeader.TESTFIELD(PaymentVoucherHeader."Shortcut Dimension 1 Code");
                PaymentVoucherHeader.TESTFIELD("Payment Type");

                IF "Account Type" = "Account Type"::"G/L Account" THEN BEGIN
                    IF PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier & Advance Payment" THEN
                        IF PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Customer Refund" THEN
                            PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Cash Requisition");
                    GLAccount.GET("Account No.");
                    "Account Name" := GLAccount.Name;
                    "Income/Balance" := GLAccount."Income/Balance";
                    "Control Account" := "Account No.";
                END ELSE
                    IF "Account Type" = "Account Type"::Vendor THEN BEGIN
                        IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier Payment")
                         THEN /*BEGIN*/
                            IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier & Advance Payment")
               THEN
                                IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Customer Refund") THEN
                                    PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Supplier Payment");

                        Vendor.GET("Account No.");
                        "Account Name" := Vendor.Name;
                        VALIDATE("Bank Account", Vendor."Preferred Bank Account");
                        "Applies-to Doc. No." := '';
                    END ELSE
                        IF "Account Type" = "Account Type"::Advance THEN BEGIN
                            PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::Advance);
                            StaffAdvances.GET("Account No.");
                            StaffAdvances.TESTFIELD("Staff Control Account");
                            GLAccount.GET(StaffAdvances."Staff Control Account");
                            "Control Account" := StaffAdvances."Staff Control Account";
                            "Beneficary Bank Account No." := StaffAdvances."Bank Account No.";
                            "Beneficary Name" := StaffAdvances.Name;
                            "Beneficary Bank Name" := StaffAdvances."Bank Name";
                            "Beneficary Bank Code" := StaffAdvances."Bank Code";
                            "Beneficary Branch Code" := StaffAdvances."Branch Code";
                            "Account Name" := GLAccount.Name;
                            "Advance Code" := "Account No.";
                        END ELSE
                            IF "Account Type" = "Account Type"::"Bank Account" THEN BEGIN
                                IF PaymentVoucherHeader."Balancing Entry" = PaymentVoucherHeader."Balancing Entry"::"Same Line" THEN
                                    PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Interbank Transfer");
                                BankAccount.GET("Account No.");
                                "Account Name" := BankAccount.Name;
                            END ELSE
                                IF "Account Type" = "Account Type"::Customer THEN BEGIN
                                    PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Customer Refund");
                                    lvCustomer.GET("Account No.");
                                    "Account Name" := lvCustomer.Name;
                                END ELSE BEGIN
                                    "Account Name" := '';
                                    "Applies-to Doc. No." := '';
                                    "Bank Account" := '';
                                    "Beneficary Bank Account No." := '';
                                    "Beneficary Bank Name" := '';
                                    "Beneficary Bank Code" := '';
                                    "Beneficary Branch Code" := '';
                                END;

                VALIDATE("Budget Code", PaymentVoucherHeader."Budget Code");
                VALIDATE("Currency Code", PaymentVoucherHeader."Currency Code");
                VALIDATE("Currency Factor", PaymentVoucherHeader."Currency Factor");
                VALIDATE("Shortcut Dimension 1 Code", PaymentVoucherHeader."Shortcut Dimension 1 Code");
                VALIDATE("Shortcut Dimension 2 Code", PaymentVoucherHeader."Shortcut Dimension 2 Code");
                VALIDATE("Dimension Set ID", PaymentVoucherHeader."Dimension Set ID");
                VALIDATE("Budget Code", PaymentVoucherHeader."Budget Code");
                VALIDATE("Fiscal Year Start Date", PaymentVoucherHeader."Fiscal Year Start Date");
                VALIDATE("Fiscal Year End Date", PaymentVoucherHeader."Fiscal Year End Date");
                VALIDATE("Accounting Period Start Date", PaymentVoucherHeader."Accounting Period Start Date");
                VALIDATE("Accounting Period End Date", PaymentVoucherHeader."Accounting Period End Date");
                VALIDATE("Quarter Start Date", PaymentVoucherHeader."Quarter Start Date");
                VALIDATE("Quarter End Date", PaymentVoucherHeader."Quarter End Date");
                VALIDATE("Filter to Date Start Date", PaymentVoucherHeader."Filter to Date Start Date");
                VALIDATE("Filter to Date End Date", PaymentVoucherHeader."Filter to Date End Date");


                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;

            end;
        }
        field(4; "Account Name"; Text[150])
        {
            Editable = false;
        }
        field(5; Description; Text[150])
        {
            Caption = 'Description';

            trigger OnValidate();
            begin
                //TestStatusPendingApproval;
            end;
        }
        field(6; Amount; Decimal)
        {
            DecimalPlaces = 0 : 2;

            trigger OnValidate();
            var
                TotalExpenditure: Decimal;
                TotalPayeeAmount: Decimal;
                PaytVoucherHeader: Record "Payment Voucher Header";
                Employee: Record Employee;
            begin


                TestStatusPendingApproval;
                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;
                TESTFIELD("Account No.");
                CLEAR(TotalExpenditure);
                CLEAR(TotalPayeeAmount);

                PaymentVoucherDetail.RESET;
                PaymentVoucherDetail.SETRANGE("Document No.", "Document No.");
                IF PaymentVoucherDetail.FINDSET THEN BEGIN
                    REPEAT
                        TotalExpenditure += PaymentVoucherDetail.Amount;
                    UNTIL PaymentVoucherDetail.NEXT = 0;
                END;

                PaymentVoucherLine.RESET;
                PaymentVoucherLine.SETRANGE("Document No.", "Document No.");
                PaymentVoucherLine.SETRANGE(WHT, FALSE);
                IF PaymentVoucherLine.FINDSET THEN BEGIN
                    REPEAT
                        TotalPayeeAmount += PaymentVoucherLine.Amount;
                    UNTIL PaymentVoucherLine.NEXT = 0;
                END;

                IF (TotalPayeeAmount + Amount) > TotalExpenditure THEN
                    ERROR('The Total Payment Voucher Line Amount exceeds the Total Voucher Details Amount by %1', ABS(TotalExpenditure - (TotalPayeeAmount + Amount)));

                GetPaymentVoucherHeader;

                IF Amount < 0 THEN    // Negative Amounts are only permited if you have multiple entries balancing of with a different line
                    PaymentVoucherHeader.TESTFIELD(PaymentVoucherHeader."Balancing Entry", PaymentVoucherHeader."Balancing Entry"::"Different Line");



                IF PaymentVoucherHeader."Currency Code" <> '' THEN BEGIN
                    PaymentVoucherHeader.TESTFIELD("Currency Factor");
                    "Amount (LCY)" :=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate, "Currency Code",
                        Amount, PaymentVoucherHeader."Currency Factor");
                END ELSE
                    "Amount (LCY)" := Amount;

                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(7; "Account Type"; Option)
        {
            OptionCaption = ' ,G/L Account,Vendor,Advance,Bank Account,Customer';
            OptionMembers = " ","G/L Account",Vendor,Advance,"Bank Account",Customer;

            trigger OnValidate();
            begin
                TestStatusPendingApproval;
                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;

                IF "Account Type" <> xRec."Account Type" THEN BEGIN
                    CLEAR("Account No.");
                    CLEAR("Control Account");
                    CLEAR(Description);
                    CLEAR("Account Name");
                END;

                GetPaymentVoucherHeader;
                PaymentVoucherHeader.TESTFIELD("Budget Code");
                PaymentVoucherHeader.TESTFIELD(PaymentVoucherHeader."Shortcut Dimension 1 Code");
                PaymentVoucherHeader.TESTFIELD("Payment Type");

                IF "Account Type" = "Account Type"::"G/L Account" THEN
                    IF PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier & Advance Payment" THEN
                        IF PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Customer Refund" THEN
                            PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Cash Requisition")
                        ELSE
                            IF "Account Type" = "Account Type"::Vendor THEN BEGIN

                                IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier Payment")
                                 THEN
                                    IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Supplier & Advance Payment")
                                 THEN
                                        IF (PaymentVoucherHeader."Payment Type" <> PaymentVoucherHeader."Payment Type"::"Customer Refund") THEN
                                            PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Supplier Payment")

                            END ELSE
                                IF "Account Type" = "Account Type"::Advance THEN
                                    PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::Advance)
                                ELSE
                                    IF "Account Type" = "Account Type"::"Bank Account" THEN
                                        IF PaymentVoucherHeader."Balancing Entry" = PaymentVoucherHeader."Balancing Entry"::"Same Line" THEN
                                            PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Interbank Transfer")
                                        ELSE
                                            IF "Account Type" = "Account Type"::Customer THEN
                                                PaymentVoucherHeader.TESTFIELD("Payment Type", PaymentVoucherHeader."Payment Type"::"Customer Refund");

            end;
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                TestStatusPendingApproval;
                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                TestStatusPendingApproval;
                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(10; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher,Procurement Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher";
        }
        field(14; "Budget Code"; Code[10])
        {
            Editable = false;
            TableRelation = "G/L Budget Name";

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(17; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'Bank Account,G/L Account';
            OptionMembers = "Bank Account","G/L Account";

            trigger OnValidate();
            begin
                IF "Bal. Account Type" <> xRec."Bal. Account Type" THEN
                    CLEAR("Bal. Account No.");
            end;
        }
        field(18; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                           Blocked = CONST(false))
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account" WHERE(Blocked = CONST(false));

            trigger OnValidate();
            var
                lvVendorBankRec: Record "Vendor Bank Account";
                lvGLAccount: Record "G/L Account";
            begin
                GetPaymentVoucherHeader;
                lvGLAccount.SETRANGE("No.", "Bal. Account No.");
                IF lvGLAccount.FIND('-') THEN
                    VALIDATE("Exclude Amount", lvGLAccount."Tax Account");

                CASE "Bal. Account Type" OF
                    "Bal. Account Type"::"Bank Account":
                        BEGIN
                            BankAcc.GET("Bal. Account No.");
                            BankAcc.TESTFIELD(Blocked, FALSE);
                            IF "Account No." = '' THEN
                                Description := BankAcc.Name;

                            IF ("Account No." = '') OR
                               ("Account Type" IN
                                ["Account Type"::"G/L Account", "Account Type"::"Bank Account"])
                            THEN BEGIN
                            END;

                            IF BankAcc."Currency Code" = '' THEN BEGIN
                                IF "Account No." = '' THEN
                                    "Currency Code" := '';
                            END ELSE
                                IF SetCurrencyCode("Bal. Account Type", "Bal. Account No.") THEN
                                    BankAcc.TESTFIELD("Currency Code", "Currency Code")
                                ELSE BEGIN
                                    "Currency Code" := BankAcc."Currency Code";
                                    PaymentVoucherHeader.TESTFIELD("Currency Code", BankAcc."Currency Code"); //  To ensure that the payment voucher is
                                                                                                              // entered using the currency code of the bank that is paying out the money except when paying from the bank with no currency code.

                                END;
                        END;
                END;
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
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Account No."),
                                                               Date = FIELD("Filter to Date Filter")));

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(22; "Budget Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                              "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                              "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Account No."),
                                                               Date = FIELD("Fiscal Year Date Filter")));
            Caption = 'Budget Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(24; "Actual Amount as at Date"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Account No."),
                                                        "Posting Date" = FIELD("Filter to Date Filter")));
            Caption = 'Actual Amount as at Date';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Actual Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Account No."),
                                                        "Posting Date" = FIELD("Fiscal Year Date Filter")));
            Caption = 'Actual Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Balance on Budget as at Date"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;

            trigger OnValidate();
            begin
                SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
                CALCFIELDS("Budget Amount as at Date");
                CALCFIELDS("Actual Amount as at Date");
                CALCFIELDS("Commitment Amount as at Date");

                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            Amount, "Currency Factor");
                    END ELSE
                        LineAmount := Amount;
                END;

                CLEAR("Balance on Budget as at Date");
                CLEAR("Budget Comment as at Date");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    "Balance on Budget as at Date" := "Budget Amount as at Date" - LineAmount
                                                      - ("Actual Amount as at Date") - "Commitment Amount as at Date";


                    IF "Balance on Budget as at Date" < 0 THEN
                        "Budget Comment as at Date" := 'Out of Budget'
                    ELSE
                        "Budget Comment as at Date" := 'Within Budget';

                    IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                        "Budget Comment" := 'Within Budget';
                        "Exceeded at Date Budget" := false;
                    end
                    ELSE begin
                        "Budget Comment" := 'Out of Budget';
                        "Exceeded at Date Budget" := true;
                    end;


                END;
            end;
        }
        field(27; "Balance on Budget for the Year"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;

            trigger OnValidate();
            begin
                SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
                CALCFIELDS("Budget Amount for the Year");
                CALCFIELDS("Actual Amount for the Year");
                CALCFIELDS("Commitment Amount for the Year");
                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            Amount, "Currency Factor");
                    END ELSE
                        LineAmount := Amount;
                END;

                CLEAR("Balance on Budget for the Year");
                CLEAR("Budget Comment for the Year");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    "Balance on Budget for the Year" := "Budget Amount for the Year" - LineAmount
                                                      - ("Actual Amount for the Year") - "Commitment Amount for the Year";

                    IF "Balance on Budget for the Year" < 0 THEN
                        "Budget Comment for the Year" := 'Out of Budget'
                    ELSE
                        "Budget Comment for the Year" := 'Within Budget';

                    IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                        "Budget Comment" := 'Within Budget';
                        "Exceeded Year Budget" := false;
                    end
                    ELSE begin
                        "Budget Comment" := 'Out of Budget';
                        "Exceeded Year Budget" := true;
                    end;
                END;
            end;
        }
        field(28; "Bal. on Budget for the Month"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;

            trigger OnValidate();
            var
                lvNFLRequisitionLine: Record "NFL Requisition Line";
            begin
                SETFILTER("Month Date Filter", '%1..%2', "Accounting Period Start Date", "Accounting Period End Date");
                CALCFIELDS("Budget Amount for the Month");
                CALCFIELDS("Actual Amount for the Month");
                CALCFIELDS("Commitment Amt for the Month");
                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            Amount, "Currency Factor");
                    END ELSE
                        LineAmount := Amount;
                END;

                CLEAR("Bal. on Budget for the Month");
                CLEAR("Budget Comment for the Month");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    "Bal. on Budget for the Month" := "Budget Amount for the Month" - LineAmount
                                                      - ("Actual Amount for the Month") - "Commitment Amt for the Month";

                    IF "Bal. on Budget for the Month" < 0 THEN
                        "Budget Comment for the Month" := 'Out of Budget'
                    ELSE
                        "Budget Comment for the Month" := 'Within Budget';

                    IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                        "Budget Comment" := 'Within Budget';
                        "Exceeded Month Budget" := false;
                    end
                    ELSE begin
                        "Budget Comment" := 'Out of Budget';
                        "Exceeded Month Budget" := true;
                    end;

                END;
            end;
        }
        field(29; "Budget Comment as at Date"; Text[150])
        {
            Editable = false;
        }
        field(30; "Budget Comment for the Year"; Text[150])
        {
            Editable = false;
        }
        field(33; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
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
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Account No."),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Filter to Date Filter")));
            Caption = 'Commitment Amount as at Date';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; "Commitment Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Account No."),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Fiscal Year Date Filter")));
            Caption = 'Commitment Amount for the Year';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
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
            CalcFormula = Sum("Commitment Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Account No."),
                                                               "Posting Date" = FIELD("Month Date Filter")));
            Caption = 'Commitment Amt for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Commitment Amt for the Quarter"; Decimal)
        {
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Account No."),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Quarter Date Filter")));
            Caption = 'Commitment Amt for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(46; "Actual Amount for the Month"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Account No."),
                                                        "Posting Date" = FIELD("Month Date Filter")));
            Caption = 'Actual Amount for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(47; "Actual Amount for the Quarter"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Account No."),
                                                        "Posting Date" = FIELD("Quarter Date Filter")));
            Caption = 'Actual Amount for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(48; "Budget Comment for the Month"; Text[150])
        {
            Caption = 'Budget Comment for the Month';
            Editable = false;
        }
        field(49; "Budget Comment for the Quarter"; Text[150])
        {
            Caption = 'Budget Comment for the Quarter';
            Editable = false;
        }
        field(50; "Budget Amount for the Month"; Decimal)
        {
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Account No."),
                                                               Date = FIELD("Month Date Filter")));
            Caption = 'Budget Amount for the Month';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(51; "Budget Amount for the Quarter"; Decimal)
        {
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Account No."),
                                                               Date = FIELD("Quarter Date Filter")));
            Caption = 'Budget Amount for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(52; "Bal. on Budget for the Quarter"; Decimal)
        {
            Caption = 'Bal. on Budget for the Quarter';
            DecimalPlaces = 0 : 2;
            Editable = false;

            trigger OnValidate();
            begin
                SETFILTER("Quarter Date Filter", '%1..%2', "Quarter Start Date", "Quarter End Date");
                CALCFIELDS("Budget Amount for the Quarter");
                CALCFIELDS("Actual Amount for the Quarter");
                CALCFIELDS("Commitment Amt for the Quarter");

                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");

                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            Amount, "Currency Factor");
                    END ELSE
                        LineAmount := Amount;
                END;

                CLEAR("Bal. on Budget for the Quarter");
                CLEAR("Budget Comment for the Quarter");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    "Bal. on Budget for the Quarter" := "Budget Amount for the Quarter" - LineAmount
                                                      - ("Actual Amount for the Quarter") - "Commitment Amt for the Quarter";

                    IF "Bal. on Budget for the Quarter" < 0 THEN
                        "Budget Comment for the Quarter" := 'Out of Budget'
                    ELSE
                        "Budget Comment for the Quarter" := 'Within Budget';

                    IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                        "Budget Comment" := 'Within Budget';
                        "Exceeded Quarter Budget" := false;
                    end
                    ELSE begin
                        "Budget Comment" := 'Out of Budget';
                        "Exceeded Quarter Budget" := true;
                    end;

                END;
            end;
        }
        field(53; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";

            trigger OnValidate();
            begin
                GetPaymentVoucherHeader;
                DeferralPostDate := PaymentVoucherHeader."Posting Date";
            end;
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

            trigger OnValidate();
            begin
                ModificationAllowed;
                ApprovedByBudgetMonitorOfficer;
                TESTFIELD("Account Type", "Account Type"::"G/L Account");
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    GLAccount.SETRANGE("No.", "Account No.");
                    IF GLAccount.FIND('-') THEN BEGIN
                        IF GLAccount."Prepayment Account" = FALSE THEN BEGIN
                            ERROR('You can only change the Expense Account for only Prepayment related Account No.');
                        END;
                    END;
                END;

                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(94; "Amount (LCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            Caption = 'Amount (LCY)';
            DecimalPlaces = 0 : 2;
            Description = 'Handles the LCY Amount for Line Amount';
            Editable = false;

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }
        field(95; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;

            trigger OnValidate();
            begin
                TESTFIELD("Account Type", "Account Type"::Vendor);
                TESTFIELD("Applies-to Doc. Type", "Applies-to Doc. Type"::Invoice);
                IF "Applies-to Doc. Type" <> xRec."Applies-to Doc. Type" THEN
                    VALIDATE("Applies-to Doc. No.", '');
            end;
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
                VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Invoice);
                VendLedgEntry.SETRANGE("Vendor No.", "Account No.");
                VendLedgEntry.SETRANGE(Reversed, FALSE);
                VendLedgEntry.SETRANGE(Open, TRUE);
                IF PAGE.RUNMODAL(PAGE::"Vendor Ledger Entries", VendLedgEntry) = ACTION::LookupOK THEN BEGIN
                    VALIDATE("Applies-to Doc. No.", VendLedgEntry."Document No.");
                END;
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

            trigger OnValidate();
            begin
                IF "Bank Account" <> xRec."Bank Account" THEN BEGIN
                    IF "Bank Account" <> '' THEN BEGIN
                        VendorBankAccount.GET("Account No.", "Bank Account");
                        VALIDATE("Beneficary Name", VendorBankAccount.Name);
                        VALIDATE("Beneficary Bank Account No.", VendorBankAccount."Bank Account No.");
                        VALIDATE("Beneficary Bank Name", VendorBankAccount.Name);
                        VALIDATE("Beneficary Bank Code", VendorBankAccount."Bank Code");
                        VALIDATE("Beneficary Branch Code", VendorBankAccount."Branch Code");
                    END ELSE BEGIN
                        CLEAR("Beneficary Name");
                        CLEAR("Beneficary Bank Account No.");
                        CLEAR("Beneficary Bank Name");
                        CLEAR("Beneficary Bank Code");
                        CLEAR("Beneficary Branch Code");
                    END;
                END;
            end;
        }
        field(98; "Bank File Generated"; Boolean)
        {
            Editable = false;
        }
        field(99; "Bank File Generated On"; Date)
        {
            Editable = false;
        }
        field(100; "Bank File Gen. by"; Code[150])
        {
            Editable = false;
        }
        field(101; "Advance Code"; Code[20])
        {
            Description = 'Staff Members'' Codes for tracking advances and loans';
            TableRelation = "Staff Advances" where(Blocked = const(false));

            trigger OnValidate();
            begin
                // Ensure that the Advance code is the same as the selected Acc. No.
                TESTFIELD("Account Type");
                TESTFIELD("Account No.");
                IF "Account Type" = "Account Type"::Advance THEN BEGIN
                    TESTFIELD("Advance Code", "Account No.");
                END;
            end;
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
        field(111; "Budget Comment"; Text[150])
        {
            Description = 'if both "as at date" and "monthly" analyses are within budget then the budget comment should be "within budget" else "out of budget"';
        }
        field(112; "Beneficary Name"; Text[150])
        {
        }
        field(113; "Beneficary Bank Account No."; Code[20])
        {
        }
        field(114; "Beneficary Bank Name"; Text[150])
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

            trigger OnValidate();
            begin
                IF ("Account Type" = "Account Type"::"G/L Account") AND ("Income/Balance" = "Income/Balance"::"Income Statement") THEN BEGIN
                    VALIDATE("Balance on Budget as at Date");
                    VALIDATE("Balance on Budget for the Year");
                    VALIDATE("Bal. on Budget for the Quarter");
                    VALIDATE("Bal. on Budget for the Month");
                END;
            end;
        }

        field(50082; "Exceeded at Date Budget"; Boolean)
        {
            Caption = 'Exceeded at Date Budget';
            Editable = false;
        }
        field(50083; "Exceeded Month Budget"; Boolean)
        {
            Caption = 'Exceeded Month Budget';
            Editable = false;
        }
        field(50084; "Exceeded Quarter Budget"; Boolean)
        {
            Caption = 'Exceeded Quarter Budget';
            Editable = false;
        }
        field(50085; "Exceeded Year Budget"; Boolean)
        {
            Caption = 'Exceeded Year Budget';
            Editable = false;
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

    trigger OnDelete();
    begin
        gvUserSetup.SETRANGE(gvUserSetup."User ID", USERID);
        IF gvUserSetup.FIND('-') THEN BEGIN
            IF gvUserSetup."Budget Controller" = FALSE THEN
                ERROR('Payment Voucher Lines can only be deleted by the Budget monitoring officer');
        END ELSE
            ERROR('User %1 is not setup for Budget monitoring', USERID);
        DeleteParentLineAndChild;
    end;

    trigger OnInsert();
    begin
        gvUserSetup.SETRANGE(gvUserSetup."User ID", USERID);
        IF gvUserSetup.FIND('-') THEN BEGIN
            IF gvUserSetup."Budget Controller" = FALSE THEN
                ERROR('Payment Voucher Lines can only be inserted by the Budget monitoring officer');
        END ELSE
            ERROR('User %1 is not setup for Budget monitoring', USERID);
    end;

    trigger OnModify();
    begin
        AreLineChangesAllowed;
    end;

    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        PaymentVoucherLine: Record "Payment Voucher Line";
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        DimMgt: Codeunit "DimensionManagement";
        CommitmentEntry: Record "Commitment Entry";
        BankAcc: Record "Bank Account";
        BankAcc2: Record "Bank Account";
        Cust: Record Customer;
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
        StaffAdvances: Record "Staff Advances";
        VendorBankAccount: Record "Vendor Bank Account";
        Text010: Label 'Account No %1 is blocked, you can only use un blocked accounts';
        Text014: Label 'The %1 %2 has a %3 %4.\Do you still want to use %1 %2 in this line?';
        Text015: Label 'Payment Type must be either Supplier Payment or Supplier & Advance Payment';

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
        gvUserSetup.SETRANGE(gvUserSetup."User ID", USERID);
        IF gvUserSetup.FIND('-') THEN BEGIN
            IF gvUserSetup."EDIT PVL" = FALSE THEN
                PaymentVoucherHeader.TESTFIELD(Status, PaymentVoucherHeader.Status::"Pending Approval")
        END;
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
        //  Prevent Modifying a WHT Line or a WHT Parent Line
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
        // Delete Line
        IF WHT THEN
            ERROR('WHT Line cannot be deleted')
        ELSE BEGIN
            WHTPaymentVoucherLine.SETRANGE(WHT, TRUE);
            WHTPaymentVoucherLine.SETRANGE("Source Line No. For WHT", "Line No.");
            IF WHTPaymentVoucherLine.FINDFIRST THEN
                WHTPaymentVoucherLine.DELETE;
        END;
        //  END
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
    /// <param name="ShortcutDimCode">Parameter of type array [8] of Code[20].</param>
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
        lvNFLApprovalEntry: Record "Approval Entry";
        lvUserSetup: Record "User Setup";
        lvUserSetup1: Record "User Setup";
    begin
        // BEGIN
        // Prevent Editing of lines once the budget monitoring officer has done the budget checks.
        // Editing should only happen when the NFL Approval Entry is open on the budget monitor's desk
        lvUserSetup.RESET;
        lvUserSetup.SETRANGE("User ID", USERID);
        IF lvUserSetup.FIND('-') THEN BEGIN
            IF lvUserSetup."Budget Controller" = FALSE THEN
                ERROR('The Payment Voucher line cell can only be modified by the Budget monitoring officer')
            // ELSE
            //     IF lvUserSetup."Budget Controller" = TRUE THEN BEGIN
            //         // Check whether the budget holder has approved the document.
            //         lvNFLApprovalEntry.Reset();
            //         lvNFLApprovalEntry.SETRANGE("Document No.", "Document No.");
            //         lvNFLApprovalEntry.SETRANGE("Approver ID", lvUserSetup."User ID");
            //         lvNFLApprovalEntry.SETRANGE(Status, lvNFLApprovalEntry.Status::Open);
            //         IF NOT lvNFLApprovalEntry.FINDFIRST THEN BEGIN
            //             lvUserSetup1.Reset();
            //             lvUserSetup1.SETRANGE(lvUserSetup1."User ID", USERID);
            //             IF lvUserSetup1.FIND('-') THEN BEGIN
            //                 IF lvUserSetup1."Voucher Admin" = FALSE THEN
            //                     ERROR('You cannot modify a document that you have already approved')
            //             END;
            //         END;
            //     END;
        END ELSE
            ERROR('User %1 is not setup for Budget monitoring', USERID);
        // MEND.
    end;

    /// <summary>
    /// Description for SetCurrencyCode.
    /// </summary>
    /// <param name="AccType2">Parameter of type Option "G/L Account",Customer,Vendor,"Bank Account".</param>
    /// <param name="AccNo2">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure SetCurrencyCode(AccType2: Option "G/L Account",Customer,Vendor,"Bank Account"; AccNo2: Code[20]): Boolean;
    begin
        "Currency Code" := '';
        IF AccNo2 <> '' THEN
            IF AccType2 = AccType2::"Bank Account" THEN
                IF BankAcc2.GET(AccNo2) THEN
                    "Currency Code" := BankAcc2."Currency Code";
        EXIT("Currency Code" <> '');
    end;
}

