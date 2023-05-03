/// <summary>
/// PageExtension Approval User Setup Exts (ID 50107) extends Record Approval User Setup.
/// </summary>
pageextension 50007 "Approval User Setup Exts" extends "Approval User Setup"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Notification Setup")
        {
            action("User Approval Setup")
            {
                ApplicationArea = All;
                Caption = 'User Approval Setup';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Delegate;
                RunObject = page "Delegate Escalate Setup";
                RunPageLink = "User ID" = field("User ID");
            }
        }
    }

    var
        myInt: Integer;
}