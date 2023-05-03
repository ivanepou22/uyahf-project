/// <summary>
/// </summary>
table 50005 "Payt Voucher Header Archieve"
{
    // version MAG

    Caption = 'Payt Voucher Header Archieve';
    DataCaptionFields = "Document Type", "No.", "Budget Code", "Shortcut Dimension 1 Code";

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Posting Date"; Date)
        {
        }
        field(4; "Budget Code"; Code[10])
        {
            Editable = false;
            TableRelation = "G/L Budget Name";
        }
        field(5; Status; Option)
        {
            Editable = false;
            OptionMembers = Open,"Pending Approval",Released;
        }
        field(6; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(9; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist("G/L Entry" WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Prepared by"; Code[50])
        {
            Editable = false;
        }
        field(12; Payee; Text[50])
        {
        }
        field(13; "Payment Type"; Option)
        {
            OptionCaption = '" ,Cash Requisition,Supplier Payment,Advance,Interbank Transfer,Customer Refund,Supplier & Advance Payment"';
            OptionMembers = " ","Cash Requisition","Supplier Payment",Advance,"Interbank Transfer","Customer Refund","Supplier & Advance Payment";
        }
        field(14; "WHT Local"; Boolean)
        {
        }
        field(15; "WHT Foreign"; Boolean)
        {
        }
        field(32; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(33; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(38; Archieved; Boolean)
        {
            Editable = false;
        }
        field(40; Commited; Boolean)
        {
            Editable = false;
        }
        field(41; "Transferred to Journals"; Boolean)
        {
            Editable = false;
        }
        field(42; "Bank File Generated"; Boolean)
        {
            CalcFormula = Exist("Payment Voucher Line" WHERE("Document No." = FIELD("No."),
                                                              "Document Type" = FIELD("Document Type"),
                                                              "Bank File Generated" = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(43; "Received by"; Text[50])
        {
        }
        field(44; "Payment Voucher Details Total"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(45; "Payment Voucher Lines Total"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(46; "Payee No."; Code[20])
        {
            TableRelation = "Staff Advances".Code;
        }
        field(47; "Accounting Period Start Date"; Date)
        {
            Editable = false;
        }
        field(48; "Accounting Period End Date"; Date)
        {
            Editable = false;
        }
        field(49; "Fiscal Year Start Date"; Date)
        {
            Editable = false;
        }
        field(50; "Fiscal Year End Date"; Date)
        {
            Editable = false;
        }
        field(51; "Filter to Date Start Date"; Date)
        {
            Editable = false;
        }
        field(52; "Filter to Date End Date"; Date)
        {
            Editable = false;
        }
        field(53; "Quarter Start Date"; Date)
        {
            Editable = false;
        }
        field(54; "Quarter End Date"; Date)
        {
            Editable = false;
        }
        field(55; "Voucher No."; Code[20])
        {
        }
        field(56; "Accountability Comment"; Text[50])
        {
        }
        field(57; "Has Links"; Boolean)
        {
            Editable = false;
        }
        field(70; "Balancing Entry"; Option)
        {
            OptionCaption = 'Same Line,Different Line';
            OptionMembers = "Same Line","Different Line";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(50113; "Hub Code"; Code[50])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('SUB COST CENTRE'), Blocked = filter(false));

            trigger OnValidate();
            begin
                //ValidateShortcutDimCode(8, "Hub Code");
            end;
        }
    }

    keys
    {
        key(Key1; "No.", "Document Type")
        {
        }
    }

    fieldgroups
    {
    }
}

