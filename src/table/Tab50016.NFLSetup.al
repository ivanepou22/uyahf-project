/// <summary>
/// Table NFL Setup (ID 50074).
/// </summary>
table 50016 "NFL Setup"
{
    // version NFL02.001


    fields
    {
        field(1; PrimaryKey; Text[30])
        {
        }
        field(2; "EFT Creation Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(3; "EFT Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(4; "EFT Re-Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5; "Store Requisition Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(6; "Archive Store Requisition"; Boolean)
        {
        }
        field(7; "Purchase Requisition Nos"; Code[10])
        {
            Caption = 'Purchase Requisition Nos.';
            TableRelation = "No. Series";
        }
        field(8; "Archive Purch. Requisition"; Boolean)
        {
        }
        field(9; "Store Req Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template";
        }
        field(10; "Store Req Item Jnl Batch"; Code[10])
        {

            trigger OnLookup();
            var
                frmBatchList: Page "Item Journal Batches";
                lvItemJnlBatch: Record "Item Journal Batch";
            begin
                CLEAR(frmBatchList);
                lvItemJnlBatch.SETRANGE(lvItemJnlBatch."Journal Template Name", "Store Req Item Jnl Template");
                lvItemJnlBatch.SETRANGE(lvItemJnlBatch."Template Type", lvItemJnlBatch."Template Type"::Item);
                frmBatchList.SETRECORD(lvItemJnlBatch);
                frmBatchList.SETTABLEVIEW(lvItemJnlBatch);
                frmBatchList.LOOKUPMODE(TRUE);
                IF frmBatchList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    frmBatchList.GETRECORD(lvItemJnlBatch);
                    "Store Req Item Jnl Batch" := lvItemJnlBatch.Name;
                END;
                CLEAR(frmBatchList);
            end;
        }
        field(11; "Store Req. Validity Period"; DateFormula)
        {
        }
        field(12; "Purch. Req. Validity Period"; DateFormula)
        {
        }
        field(14; "Purch. Order Validity Period"; DateFormula)
        {
        }
        field(15; "Sales Quote Validity Period"; DateFormula)
        {
        }
        field(16; "Service Quote Validity Period"; DateFormula)
        {
        }
        field(17; "Bank Batch No. Series"; Code[11])
        {
            TableRelation = "No. Series";
        }
        field(18; "Def Service Item Group Code"; Code[10])
        {
            Description = 'Default Service Item Group Code for creating Service Items for Fixed Assets';
            TableRelation = "Service Item Group";
        }
        field(20; "Def Service Price Group Code"; Code[10])
        {
            Description = 'Default Service Price Group Code for creating Service Items for Fixed Assets';
            TableRelation = "Service Price Group";
        }
        field(21; "Bulk Receipt No Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(22; "Prev. Maint. Planning Horizon"; DateFormula)
        {
        }
        field(23; "Sales Enquiry No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(24; "Reminder Template Path"; Text[150])
        {
        }
        field(25; "Posted Inv. Revaln Template"; Code[10])
        {
            TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Revaluation));
        }
        field(26; "Posted Inv. Revaln Batch"; Code[10])
        {
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Posted Inv. Revaln Template"),
                                                             "Template Type" = CONST(Revaluation));
        }
        field(27; "Transfer Job to FA template"; Code[20])
        {
            TableRelation = "Gen. Journal Template" WHERE(Type = CONST(Assets));
        }
        field(28; "Transfer Job to FA Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Transfer Job to FA template"));
        }
        field(29; "Store Req. Archive No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(30; "Bulk Invoice No Series"; Code[10])
        {
            Description = 'For auto-numbering bulk invoices';
            TableRelation = "No. Series";
        }
        field(31; "Return Order Validity Period"; DateFormula)
        {
        }
        field(32; "Store Return Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(33; "Store Return Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Item));
        }
        field(34; "Store Return Item Jnl Batch"; Code[10])
        {

            trigger OnLookup();
            var
                frmBatchList: Page "Item Journal Batches";
                lvItemJnlBatch: Record "Item Journal Batch";
            begin
                CLEAR(frmBatchList);
                lvItemJnlBatch.SETRANGE(lvItemJnlBatch."Journal Template Name", "Store Return Item Jnl Template");
                lvItemJnlBatch.SETRANGE(lvItemJnlBatch."Template Type", lvItemJnlBatch."Template Type"::Item);
                frmBatchList.SETRECORD(lvItemJnlBatch);
                frmBatchList.SETTABLEVIEW(lvItemJnlBatch);
                frmBatchList.LOOKUPMODE(TRUE);
                IF frmBatchList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    frmBatchList.GETRECORD(lvItemJnlBatch);
                    "Store Return Item Jnl Batch" := lvItemJnlBatch.Name;
                END;
                CLEAR(frmBatchList);
            end;
        }
        field(35; "Store Return Validity Period"; DateFormula)
        {
        }
        field(36; "Store Return Archive No series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(43; "Budget Check On Purch. Req."; Boolean)
        {
        }
        field(44; "Budget Check Period"; Option)
        {
            OptionCaption = '" ,Weekly,Monthly,Quarter,Bi-Annual,Annual"';
            OptionMembers = " ",Weekly,Monthly,Quarter,"Bi-Annual",Annual;
        }
        field(45; "WHT Percentage"; Decimal)
        {
            Caption = 'WHT Percentage';
            MinValue = 0;
            MaxValue = 100;
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
        }
    }

    fieldgroups
    {
    }
}

