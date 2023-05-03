/// <summary>
/// Page Payt Voucher Line Subform (ID 50228).
/// </summary>
page 50036 "Payt Voucher Line Subform"
{
    // version MAG

    AutoSplitKey = true;
    Caption = 'Payt Voucher Line Subform';
    PageType = ListPart;
    SourceTable = "Payt Voucher Line Archieve";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Type"; "Account Type")
                {
                }
                field("Account No."; "Account No.")
                {
                }
                field("Account Name"; "Account Name")
                {
                }
                field("Control Account"; "Control Account")
                {
                }
                field("Budget Code"; "Budget Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                }
                field("Bal. Account Type"; "Bal. Account Type")
                {
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                }
                field("Loan Type"; "Loan Type")
                {
                    ApplicationArea = All;
                }

                field("Exclude Amount"; "Exclude Amount")
                {
                }
                field("Bank Account"; "Bank Account")
                {
                }
                field("Beneficary Name"; "Beneficary Name")
                {
                }
                field("Beneficary Bank Account No."; "Beneficary Bank Account No.")
                {
                }
                field("Beneficary Bank Name"; "Beneficary Bank Name")
                {
                }
                field("Beneficary Bank Code"; "Beneficary Bank Code")
                {
                }
                field("Beneficary Branch Code"; "Beneficary Branch Code")
                {
                }
                field("Budget Amount for the Year"; "Budget Amount for the Year")
                {
                }
                field("Actual Amount for the Year"; "Actual Amount for the Year")
                {
                }
                field("Commitment Amount for the Year"; "Commitment Amount for the Year")
                {
                }
                field("Balance on Budget for the Year"; "Balance on Budget for the Year")
                {
                }
                field("Budget Comment for the Year"; "Budget Comment for the Year")
                {
                }
                field("Budget Amount as at Date"; "Budget Amount as at Date")
                {
                }
                field("Actual Amount as at Date"; "Actual Amount as at Date")
                {
                }
                field("Balance on Budget as at Date"; "Balance on Budget as at Date")
                {
                }
                field("Commitment Amount as at Date"; "Commitment Amount as at Date")
                {
                }
                field("Budget Comment as at Date"; "Budget Comment as at Date")
                {
                }
                field("Budget Amount for the Month"; "Budget Amount for the Month")
                {
                }
                field("Actual Amount for the Month"; "Actual Amount for the Month")
                {
                }
                field("Commitment Amt for the Month"; "Commitment Amt for the Month")
                {
                }
                field("Bal. on Budget for the Month"; "Bal. on Budget for the Month")
                {
                }
                field("Budget Comment for the Month"; "Budget Comment for the Month")
                {
                }
                field("Budget Amount for the Quarter"; "Budget Amount for the Quarter")
                {
                }
                field("Actual Amount for the Quarter"; "Actual Amount for the Quarter")
                {
                }
                field("Commitment Amt for the Quarter"; "Commitment Amt for the Quarter")
                {
                }
                field("Bal. on Budget for the Quarter"; "Bal. on Budget for the Quarter")
                {
                }
                field("Budget Comment for the Quarter"; "Budget Comment for the Quarter")
                {
                }
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                }
                field("Bank File Generated"; "Bank File Generated")
                {
                }
                field("Advance Code"; "Advance Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

