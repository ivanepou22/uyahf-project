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
            column(TotalBudget; TotalBudget) { }
            column(ReportFilters; ReportFilters) { }
            column(StartDate; StartDate) { }
            column(Enddate; Enddate) { }
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
                BudgetEntry1: Record "G/L Budget Entry";
            begin
                ActualAmount := 0;
                BudgetAmount := 0;
                VarianceAmount := 0;
                VarianceRate := 0;
                BurnRate := 0;
                TotalBudget := 0;

                GLEntry.Reset();
                GLEntry.SetRange("Shortcut Dimension 3 Code", "Dimension Value".Code);
                GLEntry.SetFilter("Posting Date", '%1..%2', StartDate, Enddate);
                GLEntry.SetFilter("G/L Account No.", '%1..%2', '4500', '5999');
                if GLEntry.FindFirst() then
                    repeat
                        ActualAmount += GLEntry.Amount;
                    until GLEntry.Next() = 0;

                //TotalBudget
                BudgetEntry1.Reset();
                BudgetEntry1.SetFilter("G/L Account No.", '%1..%2', '4500', '5999');
                BudgetEntry1.SetRange("Budget Name", GenLedgerSetup."Approved Budget");
                BudgetEntry1.SetRange("Budget Dimension 1 Code", "Dimension Value".Code);
                if BudgetEntry1.FindFirst() then begin
                    repeat
                        TotalBudget += BudgetEntry1.Amount;
                    until BudgetEntry1.Next() = 0;
                end;

                BudgetEntry.Reset();
                BudgetEntry.SetFilter("G/L Account No.", '%1..%2', '4500', '5999');
                BudgetEntry.SetFilter(Date, '%1..%2', StartDate, Enddate);
                BudgetEntry.SetRange("Budget Name", GenLedgerSetup."Approved Budget");
                BudgetEntry.SetRange("Budget Dimension 1 Code", "Dimension Value".Code);
                if BudgetEntry.FindFirst() then begin
                    repeat
                        BudgetAmount += BudgetEntry.Amount;
                    until BudgetEntry.Next() = 0;
                end;

                VarianceAmount := BudgetAmount - ActualAmount;
                if (VarianceAmount <> 0) and (BudgetAmount <> 0) then
                    VarianceRate := (VarianceAmount / BudgetAmount) * 100;
                if (ActualAmount <> 0) and (BudgetAmount <> 0) then
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
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = All;
                    }
                    field("End Date"; Enddate)
                    {
                        ApplicationArea = All;
                    }
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

        GenLedgerSetup.Get();
        GenLedgerSetup.TestField("Approved Budget");

        ReportFilters := "Dimension Value".GetFilters;

        if StartDate = 0D then
            Error('Starting date can not be empty');

        if Enddate = 0D then
            Error('End Date can not be empty');

        if Enddate < StartDate then
            Error('End date can not be less than Start Date');
    end;

    var
        ActualAmount: Decimal;
        BudgetAmount: Decimal;
        VarianceAmount: Decimal;
        VarianceRate: Decimal;
        BurnRate: Decimal;
        CompanyInfo: Record "Company Information";
        StartDate: Date;
        Enddate: Date;
        TotalBudget: Decimal;
        ReportFilters: Text[500];
        GenLedgerSetup: Record "General Ledger Setup";
}