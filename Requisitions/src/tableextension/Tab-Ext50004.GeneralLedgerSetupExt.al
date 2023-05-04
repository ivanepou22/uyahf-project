/// <summary>
/// TableExtension General Ledger Setup Ext (ID 50058) extends Record General Ledger Setup.
/// </summary>
tableextension 50004 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50010; "Approved Budget"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }

        field(50020; "Commitments Budget"; Code[20])
        {
            TableRelation = "G/L Budget Name";
        }
        field(50030; "Activate Commitments Control"; Boolean)
        {

        }        // Add changes to table fields here
        field(50031; "Budget Check Period"; Option)
        {
            OptionCaption = '" ,Weekly,Monthly,Quarter,Bi-Annual,Annual"';
            OptionMembers = " ",Weekly,Monthly,Quarter,"Bi-Annual",Annual;
        }
        field(50032; "EFT Creation Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50033; "EFT Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50034; "EFT Re-Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50035; "Store Requisition Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50036; "Archive Store Requisition"; Boolean)
        {
        }
        field(50037; "Purchase Requisition Nos"; Code[10])
        {
            Caption = 'Purchase Requisition Nos.';
            TableRelation = "No. Series";
        }
        field(50038; "Archive Purch. Requisition"; Boolean)
        {
        }
        field(50039; "Store Req Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template";
        }
        field(50040; "Store Req Item Jnl Batch"; Code[10])
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
        field(50041; "Store Req. Validity Period"; DateFormula)
        {
        }
        field(50042; "Purch. Req. Validity Period"; DateFormula)
        {
        }
        field(50044; "Purch. Order Validity Period"; DateFormula)
        {
        }
        field(50045; "Sales Quote Validity Period"; DateFormula)
        {
        }
        field(50046; "Service Quote Validity Period"; DateFormula)
        {
        }
        field(50047; "Bank Batch No. Series"; Code[11])
        {
            TableRelation = "No. Series";
        }
        field(50048; "Def Service Item Group Code"; Code[10])
        {
            Description = 'Default Service Item Group Code for creating Service Items for Fixed Assets';
            TableRelation = "Service Item Group";
        }
        field(50049; "WHT Percentage"; Decimal)
        {
            Caption = 'WHT Percentage';
            MinValue = 0;
            MaxValue = 100;
        }
        field(50050; "Def Service Price Group Code"; Code[10])
        {
            Description = 'Default Service Price Group Code for creating Service Items for Fixed Assets';
            TableRelation = "Service Price Group";
        }
        field(50051; "Bulk Receipt No Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50052; "Prev. Maint. Planning Horizon"; DateFormula)
        {
        }
        field(50053; "Sales Enquiry No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50054; "Reminder Template Path"; Text[150])
        {
        }
        field(50055; "Posted Inv. Revaln Template"; Code[10])
        {
            TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Revaluation));
        }
        field(50056; "Posted Inv. Revaln Batch"; Code[10])
        {
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Posted Inv. Revaln Template"),
                                                             "Template Type" = CONST(Revaluation));
        }
        field(50057; "Transfer Job to FA template"; Code[20])
        {
            TableRelation = "Gen. Journal Template" WHERE(Type = CONST(Assets));
        }
        field(50058; "Transfer Job to FA Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Transfer Job to FA template"));
        }
        field(50059; "Store Req. Archive No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50060; "Bulk Invoice No Series"; Code[10])
        {
            Description = 'For auto-numbering bulk invoices';
            TableRelation = "No. Series";
        }
        field(50061; "Return Order Validity Period"; DateFormula)
        {
        }
        field(50062; "Store Return Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50063; "Store Return Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Item));
        }
        field(50064; "Store Return Item Jnl Batch"; Code[10])
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
        field(50065; "Store Return Validity Period"; DateFormula)
        {
        }
        field(50066; "Store Return Archive No series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50067; "Budget Check On Purch. Req."; Boolean)
        {
        }
        field(50451; "Enable Budget Check"; Boolean)
        {
        }
        //scd.use.or.ug
        field(50452; "Release Budget"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }

        field(50454; "Vote on Account Budget"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }
        field(50455; "Supplimentary Budget"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }
        field(50006; "Enable Automatic Bank Rec"; Boolean)
        {
        }
        field(50007; "WHT Account"; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(50008; "WHT Pecentage"; Decimal)
        {
        }
        field(50009; "Approved Payments Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = CONST('GENERAL'));
        }
        field(50011; "WHT Percentage - Foreign"; Decimal)
        {
        }
        field(50012; "Foreign VAT Account No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }

        field(50015; "Populate Payment Dimensions"; Boolean)
        {
        }
        field(50321; "Shortcut Dimension 9 Code"; Code[20])
        {
            AccessByPermission = TableData 350 = R;
            Caption = 'Shortcut Dimension 9 Code';
            TableRelation = Dimension;

            trigger OnValidate();
            var
                Dim: Record Dimension;
                Text023: Label '%1\You cannot use the same dimension twice in the same setup.';
            begin
                IF Dim.CheckIfDimUsed("Shortcut Dimension 9 Code", 9, '', '', 0) THEN
                    ERROR(Text023, Dim.GetCheckDimErr);
                MODIFY;
            end;
        }

        field(50322; "Budget Assumption Nos."; Code[10])
        {
            AccessByPermission = TableData 270 = R;
            Caption = 'Budget Assumption Nos.';
            TableRelation = "No. Series";
        }
        field(50323; "Approved JV Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = CONST('GENERAL'));
        }
        field(50324; "Approved JV Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50325; "Doc. Ref. No. series"; Code[50])
        {
            TableRelation = "No. Series";
        }
        field(50326; "Bank Trans. Ref. No. series"; Code[50])
        {
            TableRelation = "No. Series";
        }
        field(50327; "Edit Status"; Boolean)
        {
            Caption = 'Edit Status';
        }
        field(50328; "Approved Payments Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }

        // Requisition Setup
    }
}