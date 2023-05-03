/// <summary>
/// TableExtension VendorExt (ID 50055) extends Record Vendor.
/// </summary>
tableextension 50002 "VendorExtRQ" extends Vendor
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Preferred Bank Account"; Code[10])
        {
            TableRelation = "Vendor Bank Account".Code WHERE("Vendor No." = FIELD("No."));
        }
    }

    var
        myInt: Integer;
}