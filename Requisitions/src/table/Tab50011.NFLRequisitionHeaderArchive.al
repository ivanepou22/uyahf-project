/// <summary>
/// Table NFL Requisition Header Archive (ID 50075).
/// </summary>
table 50011 "NFL Requisition Header Archive"
{
    // version NFL02.000,6.0.02

    Caption = 'NFL Requisition Header Archive';
    DataCaptionFields = "No.", "Buy-from Vendor Name", "Version No.";

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
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(5; "Pay-to Name"; Text[50])
        {
            Caption = 'Pay-to Name';
        }
        field(6; "Pay-to Name 2"; Text[50])
        {
            Caption = 'Pay-to Name 2';
        }
        field(7; "Pay-to Address"; Text[50])
        {
            Caption = 'Pay-to Address';
        }
        field(8; "Pay-to Address 2"; Text[50])
        {
            Caption = 'Pay-to Address 2';
        }
        field(9; "Pay-to City"; Text[30])
        {
            Caption = 'Pay-to City';

            trigger OnLookup();
            begin
                PostCode.ValidateCity(
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnValidate();
            begin
                PostCode.ValidateCity(
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(10; "Pay-to Contact"; Text[50])
        {
            Caption = 'Pay-to Contact';
        }
        field(11; "Your Reference"; Text[30])
        {
            Caption = 'Your Reference';
        }
        field(12; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
        }
        field(13; "Ship-to Name"; Text[50])
        {
            Caption = 'Ship-to Name';
        }
        field(14; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
        }
        field(15; "Ship-to Address"; Text[50])
        {
            Caption = 'Ship-to Address';
        }
        field(16; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(17; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';

            trigger OnLookup();
            begin
                //PostCode.LookUpCity("Ship-to City","Ship-to Post Code",FALSE);
                PostCode.ValidateCity(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnValidate();
            begin
                //PostCode.ValidateCity("Ship-to City","Ship-to Post Code");
                PostCode.ValidateCity(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(18; "Ship-to Contact"; Text[50])
        {
            Caption = 'Ship-to Contact';
        }
        field(19; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(21; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(22; "Posting Description"; Text[50])
        {
            Caption = 'Posting Description';
        }
        field(23; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(24; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(25; "Payment Discount %"; Decimal)
        {
            Caption = 'Payment Discount %';
            DecimalPlaces = 0 : 5;
        }
        field(26; "Pmt. Discount Date"; Date)
        {
            Caption = 'Pmt. Discount Date';
        }
        field(27; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(28; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(31; "Vendor Posting Group"; Code[10])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
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
            MinValue = 0;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(37; "Invoice Disc. Code"; Code[20])
        {
            Caption = 'Invoice Disc. Code';
        }
        field(41; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(43; "Purchaser Code"; Code[10])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(45; "Order Class"; Code[10])
        {
            Caption = 'Order Class';
        }
        field(46; Comment; Boolean)
        {
            CalcFormula = Exist("Purch. Comment Line Archive" WHERE("Document Type" = FIELD("Document Type"),
                                                                     "No." = FIELD("No."),
                                                                     "Document Line No." = CONST(0),
                                                                     "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                                                     "Version No." = FIELD("Version No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(47; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
        }
        field(51; "On Hold"; Code[3])
        {
            Caption = 'On Hold';
        }
        field(52; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = '" ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund"';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(53; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
        field(55; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(57; Receive; Boolean)
        {
            Caption = 'Receive';
        }
        field(58; Invoice; Boolean)
        {
            Caption = 'Invoice';
        }
        field(60; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Purchase Line Archive".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                    "Document No." = FIELD("No."),
                                                                    "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                                                    "Version No." = FIELD("Version No.")));
            Caption = 'Amount';
            FieldClass = FlowField;
        }
        field(61; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Purchase Line Archive"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("No."),
                                                                                    "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                                                                    "Version No." = FIELD("Version No.")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; "Receiving No."; Code[20])
        {
            Caption = 'Receiving No.';
        }
        field(63; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
        }
        field(64; "Last Receiving No."; Code[20])
        {
            Caption = 'Last Receiving No.';
            TableRelation = "Purch. Rcpt. Header";
        }
        field(65; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            TableRelation = "Purch. Inv. Header";
        }
        field(66; "Vendor Order No."; Code[20])
        {
            Caption = 'Vendor Order No.';
        }
        field(67; "Vendor Shipment No."; Code[20])
        {
            Caption = 'Vendor Shipment No.';
        }
        field(68; "Vendor Invoice No."; Code[20])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(69; "Vendor Cr. Memo No."; Code[20])
        {
            Caption = 'Vendor Cr. Memo No.';
        }
        field(70; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
        }
        field(72; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
        }
        field(73; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(76; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(77; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(78; "VAT Country/Region Code"; Code[10])
        {
            Caption = 'VAT Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(79; "Buy-from Vendor Name"; Text[50])
        {
            Caption = 'Buy-from Vendor Name';
        }
        field(80; "Buy-from Vendor Name 2"; Text[50])
        {
            Caption = 'Buy-from Vendor Name 2';
        }
        field(81; "Buy-from Address"; Text[50])
        {
            Caption = 'Buy-from Address';
        }
        field(82; "Buy-from Address 2"; Text[50])
        {
            Caption = 'Buy-from Address 2';
        }
        field(83; "Buy-from City"; Text[30])
        {
            Caption = 'Buy-from City';

            trigger OnLookup();
            begin
                //PostCode.LookUpCity("Buy-from City","Buy-from Post Code",FALSE);
                PostCode.ValidateCity(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnValidate();
            begin
                //PostCode.ValidateCity("Buy-from City","Buy-from Post Code");
                PostCode.ValidateCity(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(84; "Buy-from Contact"; Text[50])
        {
            Caption = 'Buy-from Contact';
        }
        field(85; "Pay-to Post Code"; Code[20])
        {
            Caption = 'Pay-to Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                //PostCode.LookUpPostCode("Pay-to City","Pay-to Post Code",FALSE);
            end;

            trigger OnValidate();
            begin
                //PostCode.ValidatePostCode("Pay-to City","Pay-to Post Code");
                PostCode.ValidatePostCode(
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(86; "Pay-to County"; Text[30])
        {
            Caption = 'Pay-to County';
        }
        field(87; "Pay-to Country/Region Code"; Code[10])
        {
            Caption = 'Pay-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(88; "Buy-from Post Code"; Code[20])
        {
            Caption = 'Buy-from Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                //PostCode.LookUpPostCode("Buy-from City","Buy-from Post Code",FALSE);
                PostCode.ValidatePostCode(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnValidate();
            begin
                //PostCode.ValidatePostCode("Buy-from City","Buy-from Post Code");
                PostCode.ValidatePostCode(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(89; "Buy-from County"; Text[30])
        {
            Caption = 'Buy-from County';
        }
        field(90; "Buy-from Country/Region Code"; Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(91; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                //PostCode.LookUpPostCode("Ship-to City","Ship-to Post Code",FALSE);
                PostCode.ValidatePostCode(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnValidate();
            begin
                //PostCode.ValidatePostCode("Ship-to City","Ship-to Post Code");
                PostCode.ValidatePostCode(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(92; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
        }
        field(93; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(94; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(95; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            TableRelation = "Order Address".Code WHERE("Vendor No." = FIELD("Buy-from Vendor No."));
        }
        field(97; "Entry Point"; Code[10])
        {
            Caption = 'Entry Point';
            TableRelation = "Entry/Exit Point";
        }
        field(98; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(99; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(101; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(102; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(104; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(107; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(108; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(109; "Receiving No. Series"; Code[10])
        {
            Caption = 'Receiving No. Series';
            TableRelation = "No. Series";
        }
        field(114; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(115; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(116; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(118; "Applies-to ID"; Code[20])
        {
            Caption = 'Applies-to ID';
        }
        field(119; "VAT Base Discount %"; Decimal)
        {
            Caption = 'VAT Base Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(120; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
        }
        field(121; "Invoice Discount Calculation"; Option)
        {
            Caption = 'Invoice Discount Calculation';
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(122; "Invoice Discount Value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Value';
        }
        field(123; "Send IC Document"; Boolean)
        {
            Caption = 'Send IC Document';
        }
        field(124; "IC Status"; Option)
        {
            Caption = 'IC Status';
            OptionCaption = 'New,Pending,Sent';
            OptionMembers = New,Pending,Sent;
        }
        field(125; "Buy-from IC Partner Code"; Code[20])
        {
            Caption = 'Buy-from IC Partner Code';
            Editable = false;
            TableRelation = "IC Partner";
        }
        field(126; "Pay-to IC Partner Code"; Code[20])
        {
            Caption = 'Pay-to IC Partner Code';
            Editable = false;
            TableRelation = "IC Partner";
        }
        field(129; "IC Direction"; Option)
        {
            Caption = 'IC Direction';
            OptionCaption = 'Outgoing,Incoming';
            OptionMembers = Outgoing,Incoming;
        }
        field(130; "Prepayment No."; Code[20])
        {
            Caption = 'Prepayment No.';
        }
        field(131; "Last Prepayment No."; Code[20])
        {
            Caption = 'Last Prepayment No.';
            TableRelation = "Sales Invoice Header";
        }
        field(132; "Prepmt. Cr. Memo No."; Code[20])
        {
            Caption = 'Prepmt. Cr. Memo No.';
        }
        field(133; "Last Prepmt. Cr. Memo No."; Code[20])
        {
            Caption = 'Last Prepmt. Cr. Memo No.';
            TableRelation = "Sales Invoice Header";
        }
        field(134; "Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(135; "Prepayment No. Series"; Code[10])
        {
            Caption = 'Prepayment No. Series';
            TableRelation = "No. Series";
        }
        field(136; "Compress Prepayment"; Boolean)
        {
            Caption = 'Compress Prepayment';
            InitValue = true;
        }
        field(137; "Prepayment Due Date"; Date)
        {
            Caption = 'Prepayment Due Date';
        }
        field(138; "Prepmt. Cr. Memo No. Series"; Code[10])
        {
            Caption = 'Prepmt. Cr. Memo No. Series';
            TableRelation = "No. Series";
        }
        field(139; "Prepmt. Posting Description"; Text[50])
        {
            Caption = 'Prepmt. Posting Description';
        }
        field(142; "Prepmt. Pmt. Discount Date"; Date)
        {
            Caption = 'Prepmt. Pmt. Discount Date';
        }
        field(143; "Prepmt. Payment Terms Code"; Code[10])
        {
            Caption = 'Prepmt. Payment Terms Code';
            TableRelation = "Payment Terms";

            trigger OnValidate();
            var
                PaymentTerms: Record "Payment Terms";
            begin
            end;
        }
        field(144; "Prepmt. Payment Discount %"; Decimal)
        {
            Caption = 'Prepmt. Payment Discount %';
            DecimalPlaces = 0 : 5;
        }
        field(151; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            Editable = false;
        }
        field(160; "Job Queue Status"; Option)
        {
            Caption = 'Job Queue Status';
            Editable = false;
            OptionCaption = ' ,Scheduled for Posting,Error,Posting';
            OptionMembers = " ","Scheduled for Posting",Error,Posting;

            trigger OnLookup();
            var
                JobQueueEntry: Record "Job Queue Entry";
            begin
                IF "Job Queue Status" = "Job Queue Status"::" " THEN
                    EXIT;
                JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
            end;
        }
        field(161; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(5042; "Interaction Exist"; Boolean)
        {
            Caption = 'Interaction Exist';
        }
        field(5043; "No. of Archived Versions"; Integer)
        {
            CalcFormula = Max("Purchase Header Archive"."Version No." WHERE("Document Type" = FIELD("Document Type"),
                                                                             "No." = FIELD("No."),
                                                                             "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence")));
            Caption = 'No. of Archived Versions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5044; "Time Archived"; Time)
        {
            Caption = 'Time Archived';
        }
        field(5045; "Date Archived"; Date)
        {
            Caption = 'Date Archived';
        }
        field(5046; "Archived By"; Code[20])
        {
            Caption = 'Archived By';
        }
        field(5047; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(5048; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }
        field(5050; "Campaign No."; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;
        }
        field(5052; "Buy-from Contact No."; Code[20])
        {
            Caption = 'Buy-from Contact No.';
            TableRelation = Contact;
        }
        field(5053; "Pay-to Contact No."; Code[20])
        {
            Caption = 'Pay-to Contact No.';
            TableRelation = Contact;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(5752; "Completely Received"; Boolean)
        {
            CalcFormula = Min("Purchase Line Archive"."Completely Received" WHERE("Document Type" = FIELD("Document Type"),
                                                                                   "Document No." = FIELD("No."),
                                                                                   "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                                                                   "Version No." = FIELD("Version No."),
                                                                                   "Expected Receipt Date" = FIELD("Date Filter"),
                                                                                   "Location Code" = FIELD("Location Filter")));
            Caption = 'Completely Received';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5753; "Posting from Whse. Ref."; Integer)
        {
            Caption = 'Posting from Whse. Ref.';
        }
        field(5754; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
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
        field(5796; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(5800; "Vendor Authorization No."; Code[20])
        {
            Caption = 'Vendor Authorization No.';
        }
        field(5801; "Return Shipment No."; Code[20])
        {
            Caption = 'Return Shipment No.';
        }
        field(5802; "Return Shipment No. Series"; Code[10])
        {
            Caption = 'Return Shipment No. Series';
            TableRelation = "No. Series";
        }
        field(5803; Ship; Boolean)
        {
            Caption = 'Ship';
        }
        field(5804; "Last Return Shipment No."; Code[20])
        {
            Caption = 'Last Return Shipment No.';
            TableRelation = "Return Shipment Header";
        }
        field(9000; "Assigned User ID"; Code[20])
        {
            Caption = 'Assigned User ID';
            TableRelation = "User Setup";
        }
        field(50000; "Request-By No."; Code[20])
        {
            TableRelation = Employee."No.";

            trigger OnValidate();
            var
                Employee: Record Employee;
            begin
            end;
        }
        field(50001; "Request-By Name"; Text[50])
        {
            Editable = false;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(50002; "Purchase Requisition No."; Code[20])
        {
        }
        field(50003; "Created Quotes"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Quote)));
            FieldClass = FlowField;
        }
        field(50004; "Store Requisition No."; Code[20])
        {
        }
        field(50005; "Requestor ID"; Code[100])
        {
            TableRelation = "User Setup"."User ID";
        }
        field(50006; "External Reference No."; Code[20])
        {
        }
        field(50007; "Approver ID"; Code[20])
        {
        }
        field(50009; "Procument Plan Reference"; Code[20])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(50010; "Converted to Order"; Boolean)
        {
            Caption = 'Converted to Order';
            Description = 'Ensures that the purchase requisition is converted once to an order';
            Editable = false;
        }
        field(50011; "Converted to Quote"; Boolean)
        {
            Caption = 'Converted to Quote';
            Description = 'Ensures that the purchase requisition is converted once to a quote';
            Editable = false;
        }
        field(50012; "Special Instruction/Program"; Text[100])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(50013; "Delivery Period"; Text[30])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(50014; Commited; Boolean)
        {
            Description = 'Identifies whether the purchase requisition has been commited';
            Editable = false;
        }
        field(50015; "To."; Text[50])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(50016; "Budget Code"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }
        field(50020; Archieved; Boolean)
        {
            Editable = false;
        }
        field(50022; "Sent to Budget Controller"; Boolean)
        {
            Editable = false;
        }
        field(50024; "Requisition Details Total"; Decimal)
        {
        }
        field(50025; "Requisition Lines Total"; Decimal)
        {
        }
        field(50026; "Accounting Period Start Date"; Date)
        {
            Editable = false;
        }
        field(50027; "Accounting Period End Date"; Date)
        {
            Editable = false;
        }
        field(50028; "Fiscal Year Start Date"; Date)
        {
            Editable = false;
        }
        field(50029; "Fiscal Year End Date"; Date)
        {
            Editable = false;
        }
        field(50030; "Filter to Date Start Date"; Date)
        {
            Editable = false;
        }
        field(50031; "Filter to Date End Date"; Date)
        {
            Editable = false;
        }
        field(50032; "Quarter Start Date"; Date)
        {
            Editable = false;
        }
        field(50033; "Quarter End Date"; Date)
        {
            Editable = false;
        }
        field(50034; "Budget At Date Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("NFL Requisition Line" where("Document No." = field("No."), Type = filter("G/L Account"), "Document Type" = field("Document Type"), "G/L Account Type" = filter("Income Statement"), "Exceeded at Date Budget" = filter(true)));
            Editable = false;
        }
        field(50035; "Month Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("NFL Requisition Line" where("Document No." = field("No."), Type = filter("G/L Account"), "Document Type" = field("Document Type"), "G/L Account Type" = filter("Income Statement"), "Exceeded Month Budget" = filter(true)));
            Editable = false;
        }
        field(50036; "Quarter Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("NFL Requisition Line" where("Document No." = field("No."), Type = filter("G/L Account"), "Document Type" = field("Document Type"), "G/L Account Type" = filter("Income Statement"), "Exceeded Quarter Budget" = filter(true)));
            Editable = false;
        }
        field(50037; "Year Budget Exceeded"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("NFL Requisition Line" where("Document No." = field("No."), Type = filter("G/L Account"), "Document Type" = field("Document Type"), "G/L Account Type" = filter("Income Statement"), "Exceeded Year Budget" = filter(true)));
            Editable = false;
        }
        field(50038; "Return Date"; Date)
        {
        }
        field(50039; "Valid to Date"; Date)
        {
        }
        field(50040; "PD Entity"; Text[60])
        {
        }
        field(50041; "Procurement Category"; Option)
        {
            OptionCaption = ' ,Supplies,Works and Construction,Services';
            OptionMembers = " ",Supplies,"Works and Construction",Services;
        }
        field(50042; "ITB Number"; Code[20])
        {
        }
        field(50043; "Contract No."; Code[20])
        {
        }
        field(50044; "Release date"; Date)
        {
        }
        field(50045; "Date Received"; Date)
        {
            Caption = 'Date Received';
        }
        field(50046; "Time Received"; Time)
        {
            Caption = 'Time Received';
        }
        field(50047; "BizTalk Purchase Quote"; Boolean)
        {
            Caption = 'BizTalk Purchase Quote';
        }
        field(50048; "BizTalk Purch. Order Cnfmn."; Boolean)
        {
            Caption = 'BizTalk Purch. Order Cnfmn.';
        }
        field(50049; "BizTalk Purchase Invoice"; Boolean)
        {
            Caption = 'BizTalk Purchase Invoice';
        }
        field(50050; "BizTalk Purchase Receipt"; Boolean)
        {
            Caption = 'BizTalk Purchase Receipt';
        }
        field(50051; "BizTalk Purchase Credit Memo"; Boolean)
        {
            Caption = 'BizTalk Purchase Credit Memo';
        }
        field(50052; "Date Sent"; Date)
        {
            Caption = 'Date Sent';
        }
        field(50053; "Time Sent"; Time)
        {
            Caption = 'Time Sent';
        }
        field(50054; "BizTalk Request for Purch. Qte"; Boolean)
        {
            Caption = 'BizTalk Request for Purch. Qte';
        }
        field(50055; "BizTalk Purchase Order"; Boolean)
        {
            Caption = 'BizTalk Purchase Order';
        }
        field(50056; "Vendor Quote No."; Code[20])
        {
            Caption = 'Vendor Quote No.';
        }
        field(50057; "BizTalk Document Sent"; Boolean)
        {
            Caption = 'BizTalk Document Sent';
        }
        field(50058; "Wrks/Srvcs/Sup"; Option)
        {
            Description = 'Added to design form 5 Report';
            OptionCaption = 'Supplies,Works,Non-Consultancy Services';
            OptionMembers = Supplies,Works,"Non-Consultancy Services";
        }
        field(50113; "Hub Code"; Code[50])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('SUB COST CENTRE'), Blocked = filter(false));

            trigger OnValidate();
            begin
                //ValidateShortcutDimCode(8, "Hub Code");
            end;
        }
        field(50114; "Archive No."; Code[20])
        {
        }
        field(50115; "Created from"; Option)
        {
            OptionMembers = " ","Item Journal","Purchase Requisition";
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.", "Doc. No. Occurrence", "Version No.", "Archive No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
    begin
        PurchaseLineArchive.SETRANGE("Document Type", "Document Type");
        PurchaseLineArchive.SETRANGE("Document No.", "No.");
        PurchaseLineArchive.SETRANGE("Doc. No. Occurrence", "Doc. No. Occurrence");
        PurchaseLineArchive.SETRANGE("Version No.", "Version No.");
        PurchaseLineArchive.DELETEALL;

        PurchCommentLineArch.SETRANGE("Document Type", "Document Type");
        PurchCommentLineArch.SETRANGE("No.", "No.");
        PurchCommentLineArch.SETRANGE("Doc. No. Occurrence", "Doc. No. Occurrence");
        PurchCommentLineArch.SETRANGE("Version No.", "Version No.");
        PurchCommentLineArch.DELETEALL;
    end;

    var
        PostCode: Record "Post Code";
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
}

