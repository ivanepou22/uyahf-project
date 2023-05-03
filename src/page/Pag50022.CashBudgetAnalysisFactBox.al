/// <summary>
/// Page Cash Budget Analysis Fact Box (ID 50214).
/// </summary>
page 50022 "Cash Budget Analysis Fact Box"
{
    // version MAG

    Caption = 'Budget Analysis Fact Box';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            group("Analysis Details")
            {
                field("Account No."; "Account No.")
                {
                }
                field("Budget Code"; "Budget Code")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Budget Comment"; "Budget Comment")
                {
                    StyleExpr = StyleText1;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
        StyleText1 := '';
        StyleText2 := '';
        IF "Budget Comment as at Date" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment for the Year" = 'Within Budget' THEN
            StyleText2 := 'Favorable';
        IF "Budget Comment as at Date" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
        IF "Budget Comment for the Year" = 'Out of Budget' THEN
            StyleText2 := 'Unfavorable';

        IF "Budget Comment" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
        CurrPage.UPDATE;
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

