/// <summary>
/// PageExtension NV Approval EntriesExt (ID 50031) extends Record NV Approval Entries.
/// </summary>
pageextension 50140 "NV Approval EntriesExt" extends "NV Approval Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Due Date")
        {
            field("Escalated By"; "Escalated By")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Escalated On"; "Escalated On")
            {
                ApplicationArea = All;
                Editable = false;
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