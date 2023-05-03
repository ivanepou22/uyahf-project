/// <summary>
/// Table NFL Requisition Line Archive (ID 50044).
/// </summary>
table 50012 "NFL Requisition Line Archive"
{
    // version NFL02.001

    Caption = 'NFL Requisition Line Archive';
    //LookupPageID = 39006386; IE
    PasteIsValid = false;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";
        }
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Purchase Header Archive"."No." WHERE("Document Type" = FIELD("Document Type"),
                                                                 "Version No." = FIELD("Version No."));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = '" ,G/L Account,Item,,Fixed Asset,Charge (Item)"';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(3)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge";
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(8; "Posting Group"; Code[10])
        {
            Caption = 'Posting Group';
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST("Fixed Asset")) "FA Posting Group";
        }
        field(10; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(12; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(13; "Unit of Measure"; Text[10])
        {
            Caption = 'Unit of Measure';
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Outstanding Quantity"; Decimal)
        {
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(17; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FIELDNO("Direct Unit Cost"));
            Caption = 'Direct Unit Cost';
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
        }
        field(26; "Quantity Disc. %"; Decimal)
        {
            Caption = 'Quantity Disc. %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(27; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';
        }
        field(29; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
        }
        field(31; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
        }
        field(32; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;
        }
        field(34; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(35; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(36; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(37; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(38; "Appl.-to Item Entry"; Integer)
        {
            Caption = 'Appl.-to Item Entry';
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(45; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(54; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(57; "Outstanding Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Outstanding Amount';
        }
        field(58; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced';
            DecimalPlaces = 0 : 5;
        }
        field(59; "Amt. Rcd. Not Invoiced"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced';
        }
        field(60; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            DecimalPlaces = 0 : 5;
        }
        field(61; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0 : 5;
        }
        field(63; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(64; "Receipt Line No."; Integer)
        {
            Caption = 'Receipt Line No.';
        }
        field(67; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0 : 5;
        }
        field(68; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            TableRelation = Vendor;
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amount';
        }
        field(70; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
        }
        field(71; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(72; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Sales Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                         "Document No." = FIELD("Sales Order No."));
        }
        field(73; "Drop Shipment"; Boolean)
        {
            Caption = 'Drop Shipment';
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(75; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(77; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(78; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(79; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(80; "Attached to Line No."; Integer)
        {
            Caption = 'Attached to Line No.';
            Editable = false;
            TableRelation = "Purchase Line Archive"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                      "Document No." = FIELD("Document No."),
                                                                      "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                                                      "Version No." = FIELD("Version No."));
        }
        field(81; "Entry Point"; Code[10])
        {
            Caption = 'Entry Point';
            TableRelation = "Entry/Exit Point";
        }
        field(82; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(83; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(87; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(92; "Outstanding Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Outstanding Amount (LCY)';
        }
        field(93; "Amt. Rcd. Not Invoiced (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced (LCY)';
        }
        field(97; "Blanket Order No."; Code[20])
        {
            Caption = 'Blanket Order No.';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            Caption = 'Blanket Order Line No.';
            TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = CONST("Blanket Order"),
                                                              "Document No." = FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
        }
        field(103; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Line Amount"));
            Caption = 'Line Amount';
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
        }
        field(105; "Inv. Disc. Amount to Invoice"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Amount to Invoice';
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
        }
        field(107; "IC Partner Ref. Type"; Option)
        {
            Caption = 'IC Partner Ref. Type';
            OptionCaption = '" ,G/L Account,Item,,,Charge (Item),Cross Reference,Common Item No.,Vendor Item No."';
            OptionMembers = " ","G/L Account",Item,,,"Charge (Item)","Cross Reference","Common Item No.","Vendor Item No.";
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            Caption = 'IC Partner Reference';

            trigger OnLookup();
            var
                ICGLAccount: Record "IC G/L Account";
                // ItemCrossReference: Record "Item Cross Reference";
                ItemVendorCatalog: Record "Item Vendor";
            begin
            end;
        }
        field(109; "Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate();
            var
                GenPostingSetup: Record "General Posting Setup";
                GLAcc: Record "G/L Account";
            begin
            end;
        }
        field(110; "Prepmt. Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt. Line Amount"));
            Caption = 'Prepmt. Line Amount';
            MinValue = 0;
        }
        field(111; "Prepmt. Amt. Inv."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt. Amt. Inv."));
            Caption = 'Prepmt. Amt. Inv.';
            Editable = false;
        }
        field(112; "Prepmt. Amt. Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amt. Incl. VAT';
            Editable = false;
        }
        field(113; "Prepayment Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepayment Amount';
            Editable = false;
        }
        field(114; "Prepmt. VAT Base Amt."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. VAT Base Amt.';
            Editable = false;
        }
        field(115; "Prepayment VAT %"; Decimal)
        {
            Caption = 'Prepayment VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(116; "Prepmt. VAT Calc. Type"; Option)
        {
            Caption = 'Prepmt. VAT Calc. Type';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(117; "Prepayment VAT Identifier"; Code[10])
        {
            Caption = 'Prepayment VAT Identifier';
            Editable = false;
        }
        field(118; "Prepayment Tax Area Code"; Code[20])
        {
            Caption = 'Prepayment Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(119; "Prepayment Tax Liable"; Boolean)
        {
            Caption = 'Prepayment Tax Liable';
        }
        field(120; "Prepayment Tax Group Code"; Code[10])
        {
            Caption = 'Prepayment Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(121; "Prepmt Amt to Deduct"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt Amt to Deduct"));
            Caption = 'Prepmt Amt to Deduct';
            MinValue = 0;
        }
        field(122; "Prepmt Amt Deducted"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt Amt Deducted"));
            Caption = 'Prepmt Amt Deducted';
            Editable = false;
        }
        field(123; "Prepayment Line"; Boolean)
        {
            Caption = 'Prepayment Line';
            Editable = false;
        }
        field(124; "Prepmt. Amount Inv. Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. Incl. VAT';
            Editable = false;
        }
        field(130; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions;
            end;
        }
        field(5047; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(5048; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }
        field(5401; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            TableRelation = "Production Order"."No." WHERE(Status = FILTER(Released | Finished));
            ValidateTableRelation = false;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5416; "Outstanding Qty. (Base)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5417; "Qty. to Invoice (Base)"; Decimal)
        {
            Caption = 'Qty. to Invoice (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5418; "Qty. to Receive (Base)"; Decimal)
        {
            Caption = 'Qty. to Receive (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5458; "Qty. Rcd. Not Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5460; "Qty. Received (Base)"; Decimal)
        {
            Caption = 'Qty. Received (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5600; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5601; "FA Posting Type"; Option)
        {
            Caption = 'FA Posting Type';
            OptionCaption = '" ,Acquisition Cost,Maintenance"';
            OptionMembers = " ","Acquisition Cost",Maintenance;
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
        }
        field(5603; "Salvage Value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Salvage Value';
        }
        field(5605; "Depr. until FA Posting Date"; Boolean)
        {
            Caption = 'Depr. until FA Posting Date';
        }
        field(5606; "Depr. Acquisition Cost"; Boolean)
        {
            Caption = 'Depr. Acquisition Cost';
        }
        field(5609; "Maintenance Code"; Code[10])
        {
            Caption = 'Maintenance Code';
            TableRelation = Maintenance;
        }
        field(5610; "Insurance No."; Code[20])
        {
            Caption = 'Insurance No.';
            TableRelation = Insurance;
        }
        field(5611; "Budgeted FA No."; Code[20])
        {
            Caption = 'Budgeted FA No.';
            TableRelation = "Fixed Asset";
        }
        field(5612; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";
        }
        field(5613; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(5705; "Cross-Reference No."; Code[20])
        {
            Caption = 'Cross-Reference No.';
        }
        field(5706; "Unit of Measure (Cross Ref.)"; Code[10])
        {
            Caption = 'Unit of Measure (Cross Ref.)';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(5707; "Cross-Reference Type"; Option)
        {
            Caption = 'Cross-Reference Type';
            OptionCaption = '" ,Customer,Vendor,Bar Code"';
            OptionMembers = " ",Customer,Vendor,"Bar Code";
        }
        field(5708; "Cross-Reference Type No."; Code[30])
        {
            Caption = 'Cross-Reference Type No.';
        }
        field(5709; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5710; Nonstock; Boolean)
        {
            Caption = 'Nonstock';
        }
        field(5711; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5712; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            TableRelation = "Product Group".Code WHERE("Item Category Code" = FIELD("Item Category Code"));
        }
        field(5713; "Special Order"; Boolean)
        {
            Caption = 'Special Order';
        }
        field(5714; "Special Order Sales No."; Code[20])
        {
            Caption = 'Special Order Sales No.';
            TableRelation = IF ("Special Order" = CONST(true)) "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(5715; "Special Order Sales Line No."; Integer)
        {
            Caption = 'Special Order Sales Line No.';
            TableRelation = IF ("Special Order" = CONST(true)) "Sales Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                         "Document No." = FIELD("Special Order Sales No."));
        }
        field(5752; "Completely Received"; Boolean)
        {
            Caption = 'Completely Received';
        }
        field(5790; "Requested Receipt Date"; Date)
        {
            Caption = 'Requested Receipt Date';
        }
        field(5791; "Promised Receipt Date"; Date)
        {
            Caption = 'Promised Receipt Date';
        }
        field(5792; "Lead Time Calculation"; DateFormula)
        {
            Caption = 'Lead Time Calculation';
        }
        field(5793; "Inbound Whse. Handling Time"; DateFormula)
        {
            Caption = 'Inbound Whse. Handling Time';
        }
        field(5794; "Planned Receipt Date"; Date)
        {
            Caption = 'Planned Receipt Date';
        }
        field(5795; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(5800; "Allow Item Charge Assignment"; Boolean)
        {
            Caption = 'Allow Item Charge Assignment';
            InitValue = true;
        }
        field(5803; "Return Qty. to Ship"; Decimal)
        {
            Caption = 'Return Qty. to Ship';
            DecimalPlaces = 0 : 5;
        }
        field(5804; "Return Qty. to Ship (Base)"; Decimal)
        {
            Caption = 'Return Qty. to Ship (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5805; "Return Qty. Shipped Not Invd."; Decimal)
        {
            Caption = 'Return Qty. Shipped Not Invd.';
            DecimalPlaces = 0 : 5;
        }
        field(5806; "Ret. Qty. Shpd Not Invd.(Base)"; Decimal)
        {
            Caption = 'Ret. Qty. Shpd Not Invd.(Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5807; "Return Shpd. Not Invd."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd.';
        }
        field(5808; "Return Shpd. Not Invd. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd. (LCY)';
        }
        field(5809; "Return Qty. Shipped"; Decimal)
        {
            Caption = 'Return Qty. Shipped';
            DecimalPlaces = 0 : 5;
        }
        field(5810; "Return Qty. Shipped (Base)"; Decimal)
        {
            Caption = 'Return Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(6600; "Return Shipment No."; Code[20])
        {
            Caption = 'Return Shipment No.';
        }
        field(6601; "Return Shipment Line No."; Integer)
        {
            Caption = 'Return Shipment Line No.';
            Editable = false;
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(50000; "Qty. Requested"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(50001; "Request-By No."; Code[20])
        {
            TableRelation = Employee."No.";
        }
        field(50002; "Request-By Name"; Text[50])
        {
        }
        field(50003; "G/L Expense A/c"; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(50004; "Pay to Type"; Option)
        {
            OptionCaption = '" ,Vendor,Staff,Other"';
            OptionMembers = " ",Vendor,Staff,Other;
        }
        field(50005; "Pay to No."; Code[20])
        {

            trigger OnValidate();
            var
                EmpRec: Record Employee;
                VendRec: Record Vendor;
            begin
            end;
        }
        field(50006; "Pay to Name"; Text[80])
        {
        }
        field(50007; "External Document No."; Code[20])
        {
        }
        field(50008; "Posting Date"; Date)
        {
        }
        field(50009; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = '" ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund"';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(50010; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';

            trigger OnLookup();
            var
                PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
                AccType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";
                AccNo: Code[20];
            begin
            end;

            trigger OnValidate();
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                VendLedgEntry: Record "Vendor Ledger Entry";
                TempGenJnlLine: Record "NFL Requisition Line" temporary;
            begin
            end;
        }
        field(50011; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
        }
        field(50012; "Invoiced Amount"; Decimal)
        {
            Description = 'Used in the LPO pages list: JCK 13.08.12';
        }
        field(50013; "WHT Code"; Code[20])
        {
        }
        field(50016; "Budget Code"; Code[10])
        {
            Editable = false;
            TableRelation = "G/L Budget Name";
        }
        field(50017; "Budget Amount as at Date"; Decimal)
        {
            Caption = 'Budget Amount as at Date';
            Editable = false;
            FieldClass = Normal;
        }
        field(50018; "Budget Amount for the Year"; Decimal)
        {
            Caption = 'Budget Amount for the Year';
            Editable = false;
            FieldClass = Normal;
        }
        field(50019; "Budget Remark"; Text[100])
        {
        }
        field(50020; "Total Amount"; Decimal)
        {
            Editable = false;
        }
        field(50021; Department; Code[20])
        {
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
        }
        field(50023; "Actual Amount as at Date"; Decimal)
        {
            Caption = 'Actual Amount as at Date';
            Editable = false;
            FieldClass = Normal;
        }
        field(50024; "Actual Amount for the Year"; Decimal)
        {
            Caption = 'Actual Amount for the Year';
            Editable = false;
            FieldClass = Normal;
        }
        field(50025; "Balance on Budget as at Date"; Decimal)
        {
            Editable = false;
        }
        field(50026; "Balance on Budget for the Year"; Decimal)
        {
            Editable = false;
        }
        field(50027; "Bal. on Budget for the Month"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            var
                lvNFLRequisitionLine: Record "NFL Requisition Line";
            begin
            end;
        }
        field(50028; "Budget Comment as at Date"; Text[50])
        {
            Editable = false;
        }
        field(50029; "Budget Comment for the Year"; Text[50])
        {
            Editable = false;
        }
        field(50030; "Include in Purch. Order"; Boolean)
        {

            trigger OnValidate();
            var
                NFLRequisitionHeader: Record "NFL Requisition Header";
                // ApprovalMgt: Codeunit "NFL Approvals Management";
                BankReconn: Record "Bank Acc. Reconciliation";
                PaymentJnl: Record "Gen. Journal Line";
            begin
            end;
        }
        field(50031; "Inventory Charge A/c"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50032; "Total Cost"; Decimal)
        {
        }
        field(50034; "Fixed Asset No."; Code[20])
        {
            TableRelation = "Fixed Asset"."No.";
        }
        field(50035; "Control Account"; Code[20])
        {
            Description = 'Holds a control account for an Item or Fixed Asset Purchase line Commitment';
            Editable = false;
            TableRelation = "G/L Account"."No.";
        }
        field(50039; "Fiscal Year Date Filter"; Date)
        {
            Caption = 'Fiscal Year Date Filter';
            FieldClass = FlowFilter;
        }
        field(50040; "Filter to Date Filter"; Date)
        {
            Caption = 'Filter to Date Filter';
            FieldClass = FlowFilter;
        }
        field(50041; "Month Date Filter"; Date)
        {
            Caption = 'Month Date Filter';
            FieldClass = FlowFilter;
        }
        field(50042; "Quarter Date Filter"; Date)
        {
            Caption = 'Quarter Date Filter';
            FieldClass = FlowFilter;
        }
        field(50050; "Converted to Order"; Boolean)
        {
            Caption = 'Converted to Order';
            Description = 'Ensures that the purchase requisition is converted once to an order';
            Editable = false;
        }
        field(50052; "Commitment Entry No."; Integer)
        {
            Description = 'Identifies a line that has been commited';
        }
        field(50053; "Qty. to Order"; Decimal)
        {
        }
        field(50054; "Qty. Not Ordered"; Decimal)
        {
            Editable = false;
        }
        field(50055; "Qty. Ordered"; Decimal)
        {
            Editable = false;
        }
        field(50056; "Commitment Amount as at Date"; Decimal)
        {
            Caption = 'Commitment Amount as at Date';
            Editable = false;
            FieldClass = Normal;
        }
        field(50057; "Commitment Amount for the Year"; Decimal)
        {
            Caption = 'Commitment Amount for the Year';
            Editable = false;
            FieldClass = Normal;
        }
        field(50058; "Purchase Orders"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Purchase Requisition No." = FIELD("Document No.")));
            Caption = 'Purchase Orders';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Purchase Header" WHERE("Document Type" = FILTER(Order));
        }
        field(50059; "Commitment Amt for the Month"; Decimal)
        {
            Caption = 'Commitment Amt for the Month';
            Editable = false;
            FieldClass = Normal;
        }
        field(50060; "Commitment Amt for the Quarter"; Decimal)
        {
            Caption = 'Commitment Amt for the Quarter';
            Editable = false;
            FieldClass = Normal;
        }
        field(50061; "Actual Amount for the Month"; Decimal)
        {
            Caption = 'Actual Amount for the Month';
            Editable = false;
            FieldClass = Normal;
        }
        field(50062; "Actual Amount for the Quarter"; Decimal)
        {
            Caption = 'Actual Amount for the Quarter';
            Editable = false;
            FieldClass = Normal;
        }
        field(50063; "Budget Comment for the Month"; Text[50])
        {
            Caption = 'Budget Comment for the Month';
            Editable = false;
        }
        field(50064; "Budget Comment for the Quarter"; Text[50])
        {
            Caption = 'Budget Comment for the Quarter';
            Editable = false;
        }
        field(50065; "Budget Amount for the Month"; Decimal)
        {
            Caption = 'Budget Amount for the Month';
            Editable = false;
            FieldClass = Normal;
        }
        field(50066; "Budget Amount for the Quarter"; Decimal)
        {
            Caption = 'Budget Amount for the Quarter';
            Editable = false;
            FieldClass = Normal;
        }
        field(50069; "Bal. on Budget for the Quarter"; Decimal)
        {
            Caption = 'Bal. on Budget for the Quarter';
            Editable = false;
        }
        field(50070; "Direct Unit Cost (LCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FIELDNO("Direct Unit Cost (LCY)"));
            Caption = 'Direct Unit Cost (LCY)';
            Description = 'Handles the LCY Amount for Direct Unit Cost';
            Editable = false;
        }
        field(50071; "Line Amount (LCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Line Amount (LCY)"));
            Caption = 'Line Amount (LCY)';
            Description = 'Handles the LCY Amount for Line Amount';
            Editable = false;
        }
        field(50072; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
        }
        field(50073; "Accounting Period Start Date"; Date)
        {
            Editable = false;
        }
        field(50074; "Accounting Period End Date"; Date)
        {
            Editable = false;
        }
        field(50075; "Fiscal Year Start Date"; Date)
        {
            Editable = false;
        }
        field(50076; "Fiscal Year End Date"; Date)
        {
            Editable = false;
        }
        field(50077; "Filter to Date Start Date"; Date)
        {
            Editable = false;
        }
        field(50078; "Filter to Date End Date"; Date)
        {
            Editable = false;
        }
        field(50079; "Quarter Start Date"; Date)
        {
            Editable = false;
        }
        field(50080; "Quarter End Date"; Date)
        {
            Editable = false;
        }
        field(50081; "Budget Comment"; Text[50])
        {
            Description = 'if both "as at date" and "monthly" analyses are within budget then the budget comment should be "within budget" else "out of budget"';
        }
        field(50082; "Exceeded at Date Budget"; Boolean)
        {
            Caption = 'Exceeded at Date Budget';
            Editable = false;
        }
        field(50083; "Exceeded Month Budget"; Boolean)
        {
            Caption = 'Exceeded Month Budget';
            Editable = false;
        }
        field(50084; "Exceeded Quarter Budget"; Boolean)
        {
            Caption = 'Exceeded Quarter Budget';
            Editable = false;
        }
        field(50085; "Exceeded Year Budget"; Boolean)
        {
            Caption = 'Exceeded Year Budget';
            Editable = false;
        }
        field(50086; "G/L Account Type"; Option)
        {
            OptionMembers = " ","Balance Sheet","Income Statement";
        }
        field(50087; Committed; Boolean)
        {
            Editable = false;
        }
        field(50088; "Transfer to Item Jnl"; Boolean)
        {
        }
        field(50089; "Make Purchase Req."; Boolean)
        {
        }
        field(50090; "Qty To Transfer to Item Jnl"; Decimal)
        {
        }
        field(50091; "Qty To Make Purch. Req."; Decimal)
        {
        }
        field(50092; "Transferred To Item Jnl"; Boolean)
        {
            Editable = false;
        }
        field(50093; "Transferred To Purch. Req."; Boolean)
        {
            Editable = false;
        }
        field(50094; Currentbeingused; Boolean)
        {
        }
        field(50095; "Total Qty To Item Jnl"; Decimal)
        {
            Editable = false;
        }
        field(50096; "Total Qty To Purch. Req"; Decimal)
        {
            Editable = false;
        }
        field(50097; "Req. Reserved Quantity"; Decimal)
        {
        }
        field(50098; "Qty Returned"; Decimal)
        {
        }
        field(50099; "Archive No."; Code[20])
        {
        }
        field(50100; "Qty. Not Returned"; Decimal)
        {
        }
        field(50101; "Store Issue Line No"; Integer)
        {
        }
        field(50102; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";
        }
        field(50103; "Operation No."; Code[10])
        {
            Caption = 'Operation No.';
            TableRelation = "Prod. Order Routing Line"."Operation No." WHERE(Status = CONST(Released),
                                                                              "Prod. Order No." = FIELD("Prod. Order No."),
                                                                              "Routing No." = FIELD("Routing No."));
        }
        field(50104; "Work Center No."; Code[20])
        {
            Caption = 'Work Center No.';
            TableRelation = "Work Center";
        }
        field(50105; Finished; Boolean)
        {
            Caption = 'Finished';
        }
        field(50106; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            TableRelation = "Prod. Order Line"."Line No." WHERE(Status = FILTER(Released ..),
                                                                 "Prod. Order No." = FIELD("Prod. Order No."));
        }
        field(50107; "Overhead Rate"; Decimal)
        {
            Caption = 'Overhead Rate';
            DecimalPlaces = 0 : 5;
        }
        field(50108; "MPS Order"; Boolean)
        {
            Caption = 'MPS Order';
        }
        field(50109; "Planning Flexibility"; Option)
        {
            Caption = 'Planning Flexibility';
            OptionCaption = 'Unlimited,None';
            OptionMembers = Unlimited,"None";
        }
        field(50110; "Safety Lead Time"; DateFormula)
        {
            Caption = 'Safety Lead Time';
        }
        field(50111; "Routing Reference No."; Integer)
        {
            Caption = 'Routing Reference No.';
        }
        field(50112; Convert; Boolean)
        {
            Description = 'To cater for converting partial lines';
        }
        field(50113; Converted; Boolean)
        {
            Description = 'To cater for conveted lines';
            Editable = false;
        }
        field(50114; "Save Qty. to Order"; Decimal)
        {
            Editable = false;
        }
        field(50115; "From Issue Archive No"; Code[20])
        {
        }
        field(50116; "Partially Returned"; Boolean)
        {
        }
        field(50117; "Fully Returned"; Boolean)
        {
        }
        field(50118; "Store Return No."; Code[20])
        {
        }

    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Doc. No. Occurrence", "Version No.", "Line No.", "Archive No.")
        {
            SumIndexFields = Amount, "Amount Including VAT";
        }
        key(Key2; "Document Type", "Document No.", "Line No.", "Doc. No. Occurrence", "Version No.")
        {
        }
        key(Key3; "Buy-from Vendor No.")
        {
        }
        key(Key4; "Pay-to Vendor No.")
        {
        }
        key(Key5; "Location Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    var
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        PurchCommentLineArch.SETRANGE("Document Type", "Document Type");
        PurchCommentLineArch.SETRANGE("No.", "No.");
        PurchCommentLineArch.SETRANGE("Document Line No.", "Line No.");
        PurchCommentLineArch.SETRANGE("Doc. No. Occurrence", "Doc. No. Occurrence");
        PurchCommentLineArch.SETRANGE("Version No.", "Version No.");
        IF NOT PurchCommentLineArch.ISEMPTY THEN
            PurchCommentLineArch.DELETEALL;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        Text049: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text050: Label 'Cancelled.';
        Text051: Label 'must have the same sign as the receipt';
        Text052: Label 'The quantity that you are trying to invoice is greater than the quantity in receipt %1.';
        Text053: Label 'must have the same sign as the return shipment';
        Text054: Label 'The quantity that you are trying to invoice is greater than the quantity in return shipment %1.';

    /// <summary>
    /// Description for GetCaptionClass.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <returns>Return variable "Text[80]".</returns>
    local procedure GetCaptionClass(FieldNumber: Integer): Text[80];
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        IF NOT PurchaseHeaderArchive.GET("Document Type", "Document No.", "Doc. No. Occurrence", "Version No.") THEN BEGIN
            PurchaseHeaderArchive."No." := '';
            PurchaseHeaderArchive.INIT;
        END;
        IF PurchaseHeaderArchive."Prices Including VAT" THEN
            EXIT('2,1,' + GetFieldCaption(FieldNumber))
        ELSE
            EXIT('2,0,' + GetFieldCaption(FieldNumber));
    end;

    /// <summary>
    /// Description for GetFieldCaption.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <returns>Return variable "Text[100]".</returns>
    local procedure GetFieldCaption(FieldNumber: Integer): Text[100];
    var
        "Field": Record Field;
    begin
        Field.GET(DATABASE::"Purchase Line", FieldNumber);
        EXIT(Field."Field Caption");
    end;

    /// <summary>
    /// Description for ShowDimensions.
    /// </summary>
    procedure ShowDimensions();
    var
    //DocDimArchive: Record "5106";
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2 %3', "Document Type", "Document No.", "Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");


    end;

    /// <summary>
    /// Description for ShowLineComments.
    /// </summary>
    procedure ShowLineComments();
    var
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
        PurchArchCommentSheet: Page "Purch. Archive Comment Sheet";
    begin
        PurchCommentLineArch.SETRANGE("Document Type", "Document Type");
        PurchCommentLineArch.SETRANGE("No.", "Document No.");
        PurchCommentLineArch.SETRANGE("Document Line No.", "Line No.");
        PurchCommentLineArch.SETRANGE("Doc. No. Occurrence", "Doc. No. Occurrence");
        PurchCommentLineArch.SETRANGE("Version No.", "Version No.");
        PurchArchCommentSheet.SETTABLEVIEW(PurchCommentLineArch);
        PurchArchCommentSheet.RUNMODAL;
    end;

    /// <summary>
    /// Description for VerifyItemLineDim.
    /// </summary>
    local procedure VerifyItemLineDim();
    begin
        IF ("Dimension Set ID" <> xRec."Dimension Set ID") AND (Type = Type::Item) THEN
            IF ("Qty. Rcd. Not Invoiced" <> 0) OR ("Return Qty. Shipped Not Invd." <> 0) THEN
                IF NOT CONFIRM(Text049, TRUE, TABLECAPTION) THEN
                    ERROR(Text050);
    end;
}

