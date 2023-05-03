/// <summary>
/// TableExtension G/L Account Ext (ID 50009) extends Record G/L Account.
/// </summary>
tableextension 50019 "G/L Account Ext" extends "G/L Account"
{
    fields
    {
        // Add changes to table fields here
        field(50126; "Advance Filter"; Code[120])
        {
            FieldClass = FlowFilter;
            TableRelation = "Staff Advances";
        }
        field(50127; "Prepayment Account"; Boolean)
        {
            Description = 'Specifies whether an account is used as a prepayment account.';
        }
        field(50128; "Payment Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionMembers = " ",Cash,Cheque,Voucher;
        }
        field(50129; "Advance Posting"; Option)
        {
            OptionMembers = " ","Code Mandatory","No Code";
        }
        field(50130; "Include in Budget Check"; Boolean)
        {
            InitValue = true;
        }
        field(50131; "Spare1 Filter"; Code[120])
        {
            CaptionClass = '1,3,6';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('SPARE1'));
        }
        field(50132; "Spare2 Filter"; Code[120])
        {
            CaptionClass = '1,3,7';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('SPARE2'));
        }
        field(50133; "Spare3 Filter"; Code[120])
        {
            CaptionClass = '1,3,8';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('SPARE3'));
        }
        field(50134; "VoteCostCenter Filter"; Code[120])
        {
            CaptionClass = '1,3,3';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('VOTE COST CENTRE'));
        }
        field(50135; "Revenue Account"; Boolean)
        {
        }
        field(50136; "Budgeted Amount ACY"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("G/L Account No." = field("No."),
                                                               "G/L Account No." = FIELD(FILTER(Totaling)),
                                                               "Business Unit Code" = FIELD("Business Unit Filter"),
                                                               "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                               "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                               Date = FIELD("Date Filter"),
                                                               "Budget Name" = FIELD("Budget Filter")));
            Caption = 'Budget at Date';
            Description = '//Added to Sum up the Budgeted Column in additional reporting currency';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50137; "Fund Filter"; Code[120])
        {
            CaptionClass = '1,3,4';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('FUND'));
        }
        field(50138; "Fundingsource Filter"; Code[120])
        {
            CaptionClass = '1,3,5';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('FUNDING SOURCE'));
        }
        field(50139; "Force Revenue Stream"; Boolean)
        {
        }
        field(50150; "Media Type"; Code[20])
        {
        }
        field(50151; "Expense Account"; Boolean)
        {

            trigger OnValidate();
            begin

                IF "Income/Balance" = "Income/Balance"::"Balance Sheet" THEN
                    ERROR('Please select an income statement account');
            end;
        }
        // field(50052; "Commited Amount"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No."=FIELD("No."),
        //                                                        "Business Unit Code"=FIELD("Business Unit Filter"),
        //                                                        "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
        //                                                        "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
        //                                                        "Posting Date"=FIELD("Date Filter"),
        //                                                        "Dimension Set ID"=FIELD("Dimension Set ID Filter")));
        //     Caption = 'Commited Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(50053;"Dimension Set ID Filter";Integer)
        // {
        //     FieldClass = FlowFilter;
        // }
        field(50154; "Tax Account"; Boolean)
        {
            Description = '// Ensures that tax accounts are excluded on the payment voucher';
        }
        field(50155; "Cash collection Account"; Boolean)
        {
        }
        field(50156; "Net change new"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("No."), "G/L Account No." = FIELD(FILTER(Totaling)), "Business Unit Code" = FIELD("Business Unit Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Posting Date" = FIELD("Date Filter"), "Advance Code" = FIELD("Advance Filter")));
        }
    }

    var
        myInt: Integer;
}