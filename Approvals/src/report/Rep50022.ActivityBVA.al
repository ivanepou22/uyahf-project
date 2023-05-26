report 50022 "ActivityBVA"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'Activity Budget Vs Actuals';

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            RequestFilterFields = "Project Code", Code;

            column(Code; Code) { }
            column(Name; Name) { }
            column(Project_Code; "Project Code") { }
            column(ActualAmount; ActualAmount) { }
            column(BudgetAmount; BudgetAmount) { }
            column(VarianceAmount; VarianceAmount) { }
            column(VarianceRate; VarianceRate) { }
            column(BurnRate; BurnRate) { }
            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyInfoPicture; CompanyInfo.Picture) { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyAddress2; CompanyInfo."Address 2") { }
            column(CompanyEmail; CompanyInfo."E-Mail") { }
            column(CompanyHomePage; CompanyInfo."Home Page") { }
            column(CompanyInfoPhone; CompanyInfo."Phone No.") { }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                "Dimension Value".SetRange("Dimension Code", 'P-ACTIVITY');
                "Dimension Value".SetRange("Dimension Value Type", "Dimension Value"."Dimension Value Type"::Standard);
            end;

            trigger OnAfterGetRecord()
            var
                GLEntry: Record "G/L Entry";
                BudgetEntry: Record "G/L Budget Entry";
            begin
                ActualAmount := 0;
                BudgetAmount := 0;
                VarianceAmount := 0;
                VarianceRate := 0;
                BurnRate := 0;

                GLEntry.Reset();
                GLEntry.SetRange("Shortcut Dimension 3 Code", "Dimension Value".Code);
                GLEntry.SetFilter("G/L Account No.", '%1..%2', '4500', '5999');
                if GLEntry.FindFirst() then
                    repeat
                        ActualAmount += GLEntry.Amount;
                    until GLEntry.Next() = 0;

                BudgetEntry.Reset();
                BudgetEntry.SetFilter("G/L Account No.", '%1..%2', '4500', '5999');
                BudgetEntry.SetRange("Budget Dimension 1 Code", "Dimension Value".Code);
                if BudgetEntry.FindFirst() then begin
                    repeat
                        BudgetAmount += BudgetEntry.Amount;
                    until BudgetEntry.Next() = 0;
                end;

                VarianceAmount := BudgetAmount - ActualAmount;
                VarianceRate := (VarianceAmount / BudgetAmount) * 100;
                if ActualAmount <> 0 then
                    BurnRate := (ActualAmount / BudgetAmount) * 100;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'ActivityBVA.rdl';
        }
    }

    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        ActualAmount: Decimal;
        BudgetAmount: Decimal;
        VarianceAmount: Decimal;
        VarianceRate: Decimal;
        BurnRate: Decimal;
        CompanyInfo: Record "Company Information";
}