pageextension 50033 "Dimension Values Ext" extends "Dimension Values"
{
    layout
    {
        // Add changes to page layout here
        addafter(Totaling)
        {

            field("Project Code"; Rec."Project Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Project Code field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}