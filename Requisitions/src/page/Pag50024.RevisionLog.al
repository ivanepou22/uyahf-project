/// <summary>
/// Page Revision Log (ID 50222).
/// </summary>
page 50024 "Revision Log"
{
    // version NFL03.000   51407300

    Editable = false;
    PageType = Card;
    SourceTable = "Change Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time"; Rec."Date and Time")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field("Table No."; Rec."Table No.")
                {
                }
                field("Table Caption"; Rec."Table Caption")
                {
                }
                field("Field No."; Rec."Field No.")
                {
                }
                field("Field Caption"; Rec."Field Caption")
                {
                }
                field("Type of Change"; Rec."Type of Change")
                {
                }
                field("Old Value"; Rec."Old Value")
                {
                }
                field("New Value"; Rec."New Value")
                {
                }
                field("Primary Key"; Rec."Primary Key")
                {
                }
            }
        }
    }

    actions
    {
    }
}

