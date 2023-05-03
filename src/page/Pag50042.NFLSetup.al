/// <summary>
/// Page NFL Setup (ID 51407312).
/// </summary>
page 50042 "NFL Setup"
{
    // version NFL02.001

    PageType = Card;
    SourceTable = "NFL Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Def Service Item Group Code"; "Def Service Item Group Code")
                {
                }
                field("Def Service Price Group Code"; "Def Service Price Group Code")
                {
                }
                field("Prev. Maint. Planning Horizon"; "Prev. Maint. Planning Horizon")
                {
                }
                field("Purch. Order Validity Period"; "Purch. Order Validity Period")
                {
                }
                field("Sales Quote Validity Period"; "Sales Quote Validity Period")
                {
                }
                field("Service Quote Validity Period"; "Service Quote Validity Period")
                {
                }
                field("Store Return Validity Period"; "Store Return Validity Period")
                {
                }
                field("Posted Inv. Revaln Template"; "Posted Inv. Revaln Template")
                {
                }
                field("Posted Inv. Revaln Batch"; "Posted Inv. Revaln Batch")
                {
                }
                field("Transfer Job to FA template"; "Transfer Job to FA template")
                {
                }
                field("Transfer Job to FA Batch"; "Transfer Job to FA Batch")
                {
                }
                field("Store Req. Validity Period"; "Store Req. Validity Period")
                {
                }
                field("Purch. Req. Validity Period"; "Purch. Req. Validity Period")
                {
                }
                field("WHT Percentage"; "WHT Percentage")
                {
                    ApplicationArea = All;
                }

            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Bulk Receipt No Series"; "Bulk Receipt No Series")
                {
                    Caption = 'Bulk Receipt No. Series';
                }
                field("Sales Enquiry No. Series"; "Sales Enquiry No. Series")
                {
                }
                field("EFT Creation Batch"; "EFT Creation Batch")
                {
                }
                field("EFT Export Batch"; "EFT Export Batch")
                {
                }
                field("EFT Re-Export Batch"; "EFT Re-Export Batch")
                {
                }
                field("Bank Batch No. Series"; "Bank Batch No. Series")
                {
                }
                field("Store Requisition Nos"; "Store Requisition Nos")
                {
                }
                field("Purchase Requisition Nos"; "Purchase Requisition Nos")
                {
                }
                field("Bulk Invoice No Series"; "Bulk Invoice No Series")
                {
                }
                field("Store Return Nos"; "Store Return Nos")
                {
                }
                field("Store Return Archive No series"; "Store Return Archive No series")
                {
                }
            }
            group(Requisition)
            {
                Caption = 'Requisition';
                field("Archive Purch. Requisition"; "Archive Purch. Requisition")
                {
                }
                field("Store Req Item Jnl Template"; "Store Req Item Jnl Template")
                {
                }
                field("Store Req Item Jnl Batch"; "Store Req Item Jnl Batch")
                {
                }
                field("Store Req. Archive No. Series"; "Store Req. Archive No. Series")
                {
                }
                field("Store Return Item Jnl Template"; "Store Return Item Jnl Template")
                {
                }
                field("Store Return Item Jnl Batch"; "Store Return Item Jnl Batch")
                {
                }
            }
        }
    }

    actions
    {
    }
}

