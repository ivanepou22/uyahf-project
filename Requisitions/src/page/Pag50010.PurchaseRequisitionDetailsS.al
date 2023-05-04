/// <summary>
/// Page Purchase Requisition Details S (ID 50010).
/// </summary>
page 50010 "Purchase Requisition Details S"
{
    // version MAG

    AutoSplitKey = true;
    Caption = 'Purchase Requisition Details Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Requisition Detail";
    SourceTableView = WHERE("Document Type" = FILTER("Purchase Requisition"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Details; Rec.Details)
                {
                }
                field(Amount; Rec.Amount)
                {
                }
            }
        }
    }

    actions
    {
    }
}

