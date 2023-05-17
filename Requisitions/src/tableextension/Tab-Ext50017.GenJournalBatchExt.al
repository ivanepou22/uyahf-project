/// <summary>
/// TableExtension Gen. Journal Batch Ext (ID 50057) extends Record Gen. Journal Batch.
/// </summary>
tableextension 50017 "Gen. Journal Batch Ext" extends "Gen. Journal Batch"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Cashier ID"; Code[50])
        {
            TableRelation = "User Setup";
        }    //To Capture Cashier Data entry Code
    }

    var
        myInt: Integer;
}