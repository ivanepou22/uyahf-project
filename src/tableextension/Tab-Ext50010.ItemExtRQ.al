/// <summary>
/// TableExtension ItemExt (ID 50065) extends Record Item.
/// </summary>
tableextension 50010 "ItemExtRQ" extends Item
{
    fields
    {
        // Add changes to table fields here
        field(50003; "Revenue Stream"; Code[20]) { }
        field(50004; "Requires Inspection"; Boolean) { }
        field(50005; "Item for Issue to Employees"; Boolean) { }
        field(50006; "Misc. Article Code"; Code[10])
        {
            TableRelation = "Misc. Article".Code;
        }
    }
}