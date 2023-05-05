/// <summary>
/// PageExtension Approval User SetupExt (ID 50034) extends Record Approval User Setup.
/// </summary>
pageextension 50023 "Approval User SetupExt" extends "Approval User Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(Substitute)
        {
            field("Escalate to"; Rec."Escalate to")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
        modify(Substitute)
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}