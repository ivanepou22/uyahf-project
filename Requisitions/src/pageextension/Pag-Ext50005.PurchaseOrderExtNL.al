/// <summary>
/// PageExtension Purchase Order Ext (ID 50105) extends Record Purchase Order.
/// </summary>
pageextension 50005 "Purchase Order ExtNL" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("Purchase Requisition No."; Rec."Purchase Requisition No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(Post)
        {
            action("Transfer Requistion Qty")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateDescription;
                Visible = false;
                trigger OnAction()
                var
                    CustomeFunction: Codeunit "Custom Functions And EVents";
                begin
                    CustomeFunction.TransferQty();
                end;
            }

            action("Update Requistion Qty")
            {
                ApplicationArea = All;
                Visible = false;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateDescription;
                trigger OnAction()
                var
                    CustomeFunction: Codeunit "Custom Functions And EVents";
                begin
                    CustomeFunction.FillinQtyToOrder();
                end;
            }
        }
    }

    var
        myInt: Integer;
}