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
    }
}