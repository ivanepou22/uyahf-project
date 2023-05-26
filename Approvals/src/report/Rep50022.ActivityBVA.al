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
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                "Dimension Value".SetRange("Dimension Code", 'P-ACTIVITY');
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

    var
        ActualAmount: Decimal;
        BudgetAmount: Decimal;
        VarianceAmount: Decimal;
        VarianceRate: Decimal;
        BurnRate: Decimal;
}