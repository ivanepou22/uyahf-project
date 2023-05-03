/// <summary>
/// TableExtension Vendor Bank Account Ext (ID 50054) extends Record Vendor Bank Account.
/// </summary>
tableextension 50001 "Vendor Bank Account Ext" extends "Vendor Bank Account"
{
    fields
    {
        field(50000; "Bank Code"; Code[10]) { }
        field(50001; "Branch Code"; Code[10]) { }
        field(50002; "Default Bank Account"; Boolean) { }
        field(50003; "Vendor Bank Code"; Code[10])
        {
            // TableRelation = "Employee Bank Account"."No.";
        }
    }

    var
        myInt: Integer;
}