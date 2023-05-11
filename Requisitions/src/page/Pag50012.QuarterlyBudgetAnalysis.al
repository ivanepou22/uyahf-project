/// <summary>
/// Page Quarterly Budget Analysis (ID 50012).
/// </summary>
page 50012 "Quarterly Budget Analysis"
{
    // version MAG

    Caption = 'Quarterly Budget Analysis';
    PageType = CardPart;
    SourceTable = "NFL Requisition Line";

    layout
    {
        area(content)
        {
            field("Quarter Start Date"; Rec."Quarter Start Date")
            {
                ApplicationArea = All;
            }
            field("Quarter End Date"; Rec."Quarter End Date")
            {
                ApplicationArea = All;
            }
            field("Budget Amount for the Quarter"; Rec."Budget Amount for the Quarter")
            {
                ApplicationArea = All;
            }
            field("Actual Amount for the Quarter"; Rec."Actual Amount for the Quarter")
            {
                ApplicationArea = All;
            }
            field("Commitment Amt for the Quarter"; Rec."Commitment Amt for the Quarter")
            {
                ApplicationArea = All;
            }
            field("Bal. on Budget for the Quarter"; Rec."Bal. on Budget for the Quarter")
            {
                ApplicationArea = All;
            }
            field("Budget Comment for the Quarter"; Rec."Budget Comment for the Quarter")
            {
                ApplicationArea = All;
                StyleExpr = StyleText1;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");
        StyleText1 := '';
        IF Rec."Budget Comment for the Quarter" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF Rec."Budget Comment for the Quarter" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

