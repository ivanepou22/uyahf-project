/// <summary>
/// PageExtension NV Approval EntriesExt (ID 50020) extends Record NV Approval Entries.
/// </summary>
pageextension 50020 "NV Approval EntriesExt" extends "NV Approval Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Due Date")
        {
            field("Escalated By"; Rec."Escalated By")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Escalated On"; Rec."Escalated On")
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