/// <summary>
/// TableExtension Item Journal Line Ext (ID 50064) extends Record Item Journal Line.
/// </summary>
tableextension 50009 "Item Journal Line ExtRQ" extends "Item Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50500; "G/L Expense A/c"; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(50501; "Misc. Article Code"; Code[10])
        {
            TableRelation = "Misc. Article".Code;
        }
        field(50502; "Employee No."; Code[20])
        {
            TableRelation = Employee."No.";
        }
        field(50503; "Store Req. No"; Code[20]) { }
        field(50504; "From Store Req"; Boolean) { }
        field(50505; "Store Req. Invt Charge Acc"; Code[20]) { }
        field(50506; "FA No."; Code[20])
        {
            TableRelation = "Fixed Asset"."No.";
        }
    }

    var
        myInt: Integer;
}