tableextension 50043 "Dimension Value Ext" extends "Dimension Value"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Project Code"; Code[150])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('PROJECT'));
        }
    }

    var
        myInt: Integer;
}