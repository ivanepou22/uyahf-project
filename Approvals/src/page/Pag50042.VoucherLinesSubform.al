/// <summary>
/// Page Cash Voucher Lines Subform (ID 50078).
/// </summary>
page 50042 "Voucher Lines Subform"
{
    // version MAG

    AutoSplitKey = true;
    Caption = 'Voucher Lines Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Payment Voucher Line";
    //SourceTableView = WHERE("Document Type" = FILTER("Cash Voucher"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        // MAG 28TH AUG. 2018 - BEGIN
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                        // MAG - END.
                    end;
                }
                field("Advance Code"; Rec."Advance Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Control Account"; Rec."Control Account")
                {
                    ApplicationArea = All;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {

                    ApplicationArea = All;
                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    ApplicationArea = All;
                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(Control300; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(Control301; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(Control302; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(Control303; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(Control304; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(Control305; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");

                        //Added by SEJ
                        IF Rec."Account Type" = Rec."Account Type"::"G/L Account" THEN
                            Rec.TESTFIELD("Shortcut Dimension 1 Code");
                        CurrPage.UPDATE;
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                }
                // field("Invoice Remaining Amount"; Rec."Invoice Remaining Amount")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Invoice Remaining Amount field.';
                // }
                field("Exclude Amount"; Rec."Exclude Amount")
                {
                    ApplicationArea = All;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = All;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Bank Account"; Rec."Bank Account")
                {
                    ApplicationArea = All;
                }
                field("Beneficary Name"; Rec."Beneficary Name")
                {
                    ApplicationArea = All;
                }
                field("Beneficary Bank Account No."; Rec."Beneficary Bank Account No.")
                {
                    ApplicationArea = All;
                }
                field("Beneficary Bank Name"; Rec."Beneficary Bank Name")
                {
                    ApplicationArea = All;
                }
                field("Beneficary Bank Code"; Rec."Beneficary Bank Code")
                {
                    ApplicationArea = All;
                }
                field("Beneficary Branch Code"; Rec."Beneficary Branch Code")
                {
                    ApplicationArea = All;
                }
                field("Budget Amount as at Date"; Rec."Budget Amount as at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Actual Amount as at Date"; Rec."Actual Amount as at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Commitment Amount as at Date"; Rec."Commitment Amount as at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Balance on Budget as at Date"; Rec."Balance on Budget as at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Budget Comment as at Date"; Rec."Budget Comment as at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Budget Amount for the Year"; Rec."Budget Amount for the Year")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Actual Amount for the Year"; Rec."Actual Amount for the Year")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Commitment Amount for the Year"; Rec."Commitment Amount for the Year")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Balance on Budget for the Year"; Rec."Balance on Budget for the Year")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Budget Comment for the Year"; Rec."Budget Comment for the Year")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Budget Amount for the Quarter"; Rec."Budget Amount for the Quarter")
                {
                    ApplicationArea = All;
                }
                field("Bank File Generated"; Rec."Bank File Generated")
                {
                    ApplicationArea = All;
                }
                field("Bank File Generated On"; Rec."Bank File Generated On")
                {
                    ApplicationArea = All;
                }
                field("Bank File Gen. by"; Rec."Bank File Gen. by")
                {
                    ApplicationArea = All;
                }
                field("Income/Balance"; Rec."Income/Balance")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        // MAG 6TH AUG. 2018.
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");

        Rec.VALIDATE("Balance on Budget as at Date");
        Rec.VALIDATE("Balance on Budget for the Year");
        Rec.VALIDATE("Bal. on Budget for the Month");
        Rec.VALIDATE("Bal. on Budget for the Quarter");
        // MAG - END
    end;

    trigger OnOpenPage();
    begin
        // MAG 6TH AUG. 2018.
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");

        Rec.VALIDATE("Balance on Budget as at Date");
        Rec.VALIDATE("Balance on Budget for the Year");
        Rec.VALIDATE("Bal. on Budget for the Month");
        Rec.VALIDATE("Bal. on Budget for the Quarter");
        // MAG - END
    end;

    var
        ShortcutDimCode: array[9] of Code[20];
    // Text001: Label 'You must first specify the sub cost centre';
}

