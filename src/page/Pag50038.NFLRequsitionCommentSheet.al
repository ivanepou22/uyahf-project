/// <summary>
/// Page NFL Requsition Comment Sheet (ID 50232).
/// </summary>
page 50038 "NFL Requsition Comment Sheet"
{
    // version MAG

    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionFields = "Document Type", "No.";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = Card;
    SourceTable = "NFL Requisition Comment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Old Value"; "Old Value")
                {
                    ApplicationArea = All;
                }
                field("New Value"; "New Value")
                {
                    ApplicationArea = All;
                }
                field(Username; Username)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        SetUpNewLine;
    end;
}

