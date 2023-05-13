/// <summary>
/// Table NFL Requisition Header (ID 50066).
/// </summary>
table 50005 "NFL Requisition Header"
{
    // version NFL02.003,6.0.02

    Caption = 'NFL Requisition Header';
    DataCaptionFields = "No.", "Buy-from Vendor Name", "Request-By Name";

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

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF ("Buy-from Vendor No." <> xRec."Buy-from Vendor No.") AND
                   (xRec."Buy-from Vendor No." <> '')
                THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed := CONFIRM(Text004, FALSE, FIELDCAPTION("Buy-from Vendor No."));
                    IF Confirmed THEN BEGIN
                        ReqnLine.SETRANGE("Document Type", "Document Type");
                        ReqnLine.SETRANGE("Document No.", "No.");
                        IF "Buy-from Vendor No." = '' THEN BEGIN
                            IF NOT ReqnLine.ISEMPTY THEN
                                ERROR(
                                  Text005,
                                  FIELDCAPTION("Buy-from Vendor No."));
                            INIT;
                            PurchSetup.GET;
                            "No. Series" := xRec."No. Series";
                            InitRecord;
                            IF xRec."Receiving No." <> '' THEN BEGIN
                                "Receiving No. Series" := xRec."Receiving No. Series";
                                "Receiving No." := xRec."Receiving No.";
                            END;
                            IF xRec."Posting No." <> '' THEN BEGIN
                                "Posting No. Series" := xRec."Posting No. Series";
                                "Posting No." := xRec."Posting No.";
                            END;
                            IF xRec."Return Shipment No." <> '' THEN BEGIN
                                "Return Shipment No. Series" := xRec."Return Shipment No. Series";
                                "Return Shipment No." := xRec."Return Shipment No.";
                            END;
                            IF xRec."Prepayment No." <> '' THEN BEGIN
                                "Prepayment No. Series" := xRec."Prepayment No. Series";
                                "Prepayment No." := xRec."Prepayment No.";
                            END;
                            IF xRec."Prepmt. Cr. Memo No." <> '' THEN BEGIN
                                "Prepmt. Cr. Memo No. Series" := xRec."Prepmt. Cr. Memo No. Series";
                                "Prepmt. Cr. Memo No." := xRec."Prepmt. Cr. Memo No.";
                            END;
                            EXIT;
                        END;
                        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                            ReqnLine.SETFILTER("Quantity Received", '<>0')
                        ELSE
                            IF "Document Type" = "Document Type"::"Store Return" THEN BEGIN
                                ReqnLine.SETRANGE("Buy-from Vendor No.", xRec."Buy-from Vendor No.");
                                ReqnLine.SETFILTER("Receipt No.", '<>%1', '');
                            END;
                        IF ReqnLine.FINDFIRST THEN
                            IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                                ReqnLine.TESTFIELD("Quantity Received", 0)
                            ELSE
                                ReqnLine.TESTFIELD("Receipt No.", '');

                        ReqnLine.SETRANGE("Receipt No.");
                        ReqnLine.SETRANGE("Quantity Received");
                        ReqnLine.SETRANGE("Buy-from Vendor No.");

                        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN BEGIN
                            ReqnLine.SETFILTER("Prepmt. Amt. Inv.", '<>0');
                            IF ReqnLine.FIND('-') THEN
                                ReqnLine.TESTFIELD("Prepmt. Amt. Inv.", 0);
                            ReqnLine.SETRANGE("Prepmt. Amt. Inv.");
                        END;

                        IF "Document Type" = "Document Type"::"Imprest Cash Voucher" THEN
                            ReqnLine.SETFILTER("Return Qty. Shipped", '<>0')
                        ELSE
                            IF "Document Type" = "Document Type"::"Cash Voucher" THEN BEGIN
                                ReqnLine.SETRANGE("Buy-from Vendor No.", xRec."Buy-from Vendor No.");
                                ReqnLine.SETFILTER("Return Shipment No.", '<>%1', '');
                            END;
                        IF ReqnLine.FINDFIRST THEN
                            IF "Document Type" = "Document Type"::"Imprest Cash Voucher" THEN
                                ReqnLine.TESTFIELD("Return Qty. Shipped", 0)
                            ELSE
                                ReqnLine.TESTFIELD("Return Shipment No.", '');

                        ReqnLine.RESET;
                    END ELSE BEGIN
                        Rec := xRec;
                        EXIT;
                    END;
                END;

                GetVend("Buy-from Vendor No.");
                Vend.CheckBlockedVendOnDocs(Vend, FALSE);
                Vend.TESTFIELD("Gen. Bus. Posting Group");
                "Buy-from Vendor Name" := Vend.Name;
                "Buy-from Vendor Name 2" := Vend."Name 2";
                "Buy-from Address" := Vend.Address;
                "Buy-from Address 2" := Vend."Address 2";
                "Buy-from City" := Vend.City;
                "Buy-from Post Code" := Vend."Post Code";
                "Buy-from County" := Vend.County;
                "Buy-from Country/Region Code" := Vend."Country/Region Code";
                IF NOT SkipBuyFromContact THEN
                    "Buy-from Contact" := Vend.Contact;
                "Gen. Bus. Posting Group" := Vend."Gen. Bus. Posting Group";
                "VAT Bus. Posting Group" := Vend."VAT Bus. Posting Group";
                "Tax Area Code" := Vend."Tax Area Code";
                "Tax Liable" := Vend."Tax Liable";
                "VAT Country/Region Code" := Vend."Country/Region Code";
                "VAT Registration No." := Vend."VAT Registration No.";
                VALIDATE("Lead Time Calculation", Vend."Lead Time Calculation");
                "Responsibility Center" := UserMgt.GetRespCenter(1, Vend."Responsibility Center");
                VALIDATE("Sell-to Customer No.", '');
                VALIDATE("Location Code", UserMgt.GetLocation(1, Vend."Location Code", "Responsibility Center"));

                IF "Buy-from Vendor No." = xRec."Pay-to Vendor No." THEN BEGIN
                    IF "ReceivedPurchLinesExist`" OR ReturnShipmentExist THEN BEGIN
                        TESTFIELD("VAT Bus. Posting Group", xRec."VAT Bus. Posting Group");
                        TESTFIELD("Gen. Bus. Posting Group", xRec."Gen. Bus. Posting Group");
                    END;
                END;

                "Buy-from IC Partner Code" := Vend."IC Partner Code";
                "Send IC Document" := ("Buy-from IC Partner Code" <> '') AND ("IC Direction" = "IC Direction"::Outgoing);

                IF Vend."Pay-to Vendor No." <> '' THEN
                    VALIDATE("Pay-to Vendor No.", Vend."Pay-to Vendor No.")
                ELSE BEGIN
                    IF "Buy-from Vendor No." = "Pay-to Vendor No." THEN
                        SkipPayToContact := TRUE;
                    VALIDATE("Pay-to Vendor No.", "Buy-from Vendor No.");
                    SkipPayToContact := FALSE;
                END;
                "Order Address Code" := '';

                VALIDATE("Order Address Code");

                IF (xRec."Buy-from Vendor No." <> "Buy-from Vendor No.") OR
                   (xRec."Currency Code" <> "Currency Code") OR
                   (xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group") OR
                   (xRec."VAT Bus. Posting Group" <> "VAT Bus. Posting Group")
                THEN
                    RecreatePurchLines(FIELDCAPTION("Buy-from Vendor No."));

                IF NOT SkipBuyFromContact THEN
                    UpdateBuyFromCont("Buy-from Vendor No.");
            end;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate();
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    PurchSetup.GET;
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                END;

                CreateDimension(DATABASE::"NFL Requisition Header", "No.");
            end;
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;

            trigger OnValidate();
            var
            //TempDocDim: Record "357" temporary;
            begin
                TESTFIELD(Status, Status::Open);
                IF (xRec."Pay-to Vendor No." <> "Pay-to Vendor No.") AND
                   (xRec."Pay-to Vendor No." <> '')
                THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed := CONFIRM(Text004, FALSE, FIELDCAPTION("Pay-to Vendor No."));
                    IF Confirmed THEN BEGIN
                        ReqnLine.SETRANGE("Document Type", "Document Type");
                        ReqnLine.SETRANGE("Document No.", "No.");

                        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                            ReqnLine.SETFILTER("Quantity Received", '<>0');
                        IF "Document Type" = "Document Type"::"Store Return" THEN
                            ReqnLine.SETFILTER("Receipt No.", '<>%1', '');
                        IF ReqnLine.FINDFIRST THEN
                            IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                                ReqnLine.TESTFIELD("Quantity Received", 0)
                            ELSE
                                ReqnLine.TESTFIELD("Receipt No.", '');

                        ReqnLine.SETRANGE("Receipt No.");
                        ReqnLine.SETRANGE("Quantity Received");

                        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN BEGIN
                            ReqnLine.SETFILTER("Prepmt. Amt. Inv.", '<>0');
                            IF ReqnLine.FIND('-') THEN
                                ReqnLine.TESTFIELD("Prepmt. Amt. Inv.", 0);
                            ReqnLine.SETRANGE("Prepmt. Amt. Inv.");
                        END;

                        IF "Document Type" = "Document Type"::"Imprest Cash Voucher" THEN
                            ReqnLine.SETFILTER("Return Qty. Shipped", '<>0');
                        IF "Document Type" = "Document Type"::"Cash Voucher" THEN
                            ReqnLine.SETFILTER("Return Shipment No.", '<>%1', '');
                        IF ReqnLine.FINDFIRST THEN
                            IF "Document Type" = "Document Type"::"Imprest Cash Voucher" THEN
                                ReqnLine.TESTFIELD("Return Qty. Shipped", 0)
                            ELSE
                                ReqnLine.TESTFIELD("Return Shipment No.", '');

                        ReqnLine.RESET;
                    END ELSE
                        Rec."Pay-to Vendor No." := xRec."Pay-to Vendor No.";
                END;

                GetVend("Pay-to Vendor No.");
                Vend.CheckBlockedVendOnDocs(Vend, FALSE);
                Vend.TESTFIELD("Vendor Posting Group");

                "Pay-to Name" := Vend.Name;
                "Pay-to Name 2" := Vend."Name 2";
                "Pay-to Address" := Vend.Address;
                "Pay-to Address 2" := Vend."Address 2";
                "Pay-to City" := Vend.City;
                "Pay-to Post Code" := Vend."Post Code";
                "Pay-to County" := Vend.County;
                "Pay-to Country/Region Code" := Vend."Country/Region Code";
                IF NOT SkipPayToContact THEN
                    "Pay-to Contact" := Vend.Contact;
                "Payment Terms Code" := Vend."Payment Terms Code";

                IF "Document Type" = "Document Type"::"Cash Voucher" THEN BEGIN
                    "Payment Method Code" := '';
                    IF PaymentTerms.GET("Payment Terms Code") THEN
                        IF PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" THEN
                            "Payment Method Code" := Vend."Payment Method Code"
                END ELSE
                    "Payment Method Code" := Vend."Payment Method Code";

                "Shipment Method Code" := Vend."Shipment Method Code";
                "Vendor Posting Group" := Vend."Vendor Posting Group";
                "Gen. Bus. Posting Group" := Vend."Gen. Bus. Posting Group";
                GLSetup.GET;
                IF GLSetup."Bill-to/Sell-to VAT Calc." = GLSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." THEN
                    "VAT Bus. Posting Group" := Vend."VAT Bus. Posting Group";
                "Prices Including VAT" := Vend."Prices Including VAT";
                "Currency Code" := Vend."Currency Code";
                "Invoice Disc. Code" := Vend."Invoice Disc. Code";
                "Language Code" := Vend."Language Code";
                "Purchaser Code" := Vend."Purchaser Code";
                VALIDATE("Payment Terms Code");
                VALIDATE("Payment Method Code");
                VALIDATE("Currency Code");
                "VAT Registration No." := Vend."VAT Registration No.";
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    "Prepayment %" := Vend."Prepayment %";

                IF "Pay-to Vendor No." = xRec."Pay-to Vendor No." THEN BEGIN
                    IF "ReceivedPurchLinesExist`" THEN
                        TESTFIELD("Currency Code", xRec."Currency Code");
                END;

                /*TempDocDim.GetDimensions(DATABASE::"NFL Requisition Header","Document Type","No.",0,TempDocDim);

                CreateDim(
                  DATABASE::Vendor,"Pay-to Vendor No.",
                  DATABASE::"Salesperson/Purchaser","Purchaser Code",
                  DATABASE::Campaign,"Campaign No.",
                  DATABASE::"Responsibility Center","Responsibility Center");

                IF (xRec."Buy-from Vendor No." = "Buy-from Vendor No.") AND
                   (xRec."Pay-to Vendor No." <> "Pay-to Vendor No.")
                THEN
                  RecreatePurchLines(FIELDCAPTION("Pay-to Vendor No."))
                ELSE
                  IF (xRec."Pay-to Vendor No." <> '') AND ReqnLinesExist THEN
                    TempDocDim.UpdateAllLineDim(DATABASE::"NFL Requisition Header","Document Type","No.",TempDocDim);
                */

                IF NOT SkipPayToContact THEN
                    UpdatePayToCont("Pay-to Vendor No.");

                "Pay-to IC Partner Code" := Vend."IC Partner Code";

            end;
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
                //PostCode.LookUpCity("Pay-to City","Pay-to Post Code",TRUE);
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
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));

            trigger OnValidate();
            begin
                IF ("Document Type" = "Document Type"::"Purchase Requisition") AND
                   (xRec."Ship-to Code" <> "Ship-to Code")
                THEN BEGIN
                    ReqnLine.SETRANGE("Document Type", ReqnLine."Document Type"::"Purchase Requisition");
                    ReqnLine.SETRANGE("Document No.", "No.");
                    ReqnLine.SETFILTER("Sales Order Line No.", '<>0');
                    IF NOT ReqnLine.ISEMPTY THEN
                        ERROR(
                          Text006,
                          FIELDCAPTION("Ship-to Code"));
                END;

                IF "Ship-to Code" <> '' THEN BEGIN
                    ShipToAddr.GET("Sell-to Customer No.", "Ship-to Code");
                    "Ship-to Name" := ShipToAddr.Name;
                    "Ship-to Name 2" := ShipToAddr."Name 2";
                    "Ship-to Address" := ShipToAddr.Address;
                    "Ship-to Address 2" := ShipToAddr."Address 2";
                    "Ship-to City" := ShipToAddr.City;
                    "Ship-to Post Code" := ShipToAddr."Post Code";
                    "Ship-to County" := ShipToAddr.County;
                    "Ship-to Country/Region Code" := ShipToAddr."Country/Region Code";
                    "Ship-to Contact" := ShipToAddr.Contact;
                    "Shipment Method Code" := ShipToAddr."Shipment Method Code";
                    IF ShipToAddr."Location Code" <> '' THEN
                        VALIDATE("Location Code", ShipToAddr."Location Code");
                END ELSE BEGIN
                    TESTFIELD("Sell-to Customer No.");
                    Cust.GET("Sell-to Customer No.");
                    "Ship-to Name" := Cust.Name;
                    "Ship-to Name 2" := Cust."Name 2";
                    "Ship-to Address" := Cust.Address;
                    "Ship-to Address 2" := Cust."Address 2";
                    "Ship-to City" := Cust.City;
                    "Ship-to Post Code" := Cust."Post Code";
                    "Ship-to County" := Cust.County;
                    "Ship-to Country/Region Code" := Cust."Country/Region Code";
                    "Ship-to Contact" := Cust.Contact;
                    "Shipment Method Code" := Cust."Shipment Method Code";
                    IF Cust."Location Code" <> '' THEN
                        VALIDATE("Location Code", Cust."Location Code");
                END;
            end;
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
                //PostCode.LookUpCity("Ship-to City","Ship-to Post Code",TRUE);
            end;

            trigger OnValidate();
            begin
                /*IF "Date Received" = 0D THEN
                  PostCode.ValidateCity("Ship-to City","Ship-to Post Code");*/

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

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF ("Document Type" IN ["Document Type"::"Store Requisition", "Document Type"::"Purchase Requisition"]) AND
                   NOT ("Order Date" = xRec."Order Date")
                THEN
                    PriceMessageIfPurchLinesExist(FIELDCAPTION("Order Date"));
            end;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate();
            begin
                //TESTFIELD(Status,Status::Open);
                TestNoSeriesDate(
                  "Posting No.", "Posting No. Series",
                  FIELDCAPTION("Posting No."), FIELDCAPTION("Posting No. Series"));
                TestNoSeriesDate(
                  "Prepayment No.", "Prepayment No. Series",
                  FIELDCAPTION("Prepayment No."), FIELDCAPTION("Prepayment No. Series"));
                TestNoSeriesDate(
                  "Prepmt. Cr. Memo No.", "Prepmt. Cr. Memo No. Series",
                  FIELDCAPTION("Prepmt. Cr. Memo No."), FIELDCAPTION("Prepmt. Cr. Memo No. Series"));

                VALIDATE("Document Date", "Posting Date");

                IF ("Document Type" IN ["Document Type"::"Store Return", "Document Type"::"Cash Voucher"]) AND
                   NOT ("Posting Date" = xRec."Posting Date")
                THEN
                    PriceMessageIfPurchLinesExist(FIELDCAPTION("Posting Date"));

                IF "Currency Code" <> '' THEN BEGIN
                    UpdateCurrencyFactor;
                    IF "Currency Factor" <> xRec."Currency Factor" THEN
                        ConfirmUpdateCurrencyFactor;
                END;
                IF ReqnLinesExist THEN
                    JobUpdatePurchLines;

                GetFiscalYearAndAccountingPeriod("Posting Date");
                IF ReqnLinesExist THEN
                    UpdateAllLineDateFilters("Posting Date");
            end;
        }
        field(21; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION("Expected Receipt Date"));
            end;
        }
        field(22; "Posting Description"; Text[50])
        {
            Caption = 'Posting Description';
        }
        field(23; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";

            trigger OnValidate();
            begin
                IF ("Payment Terms Code" <> '') AND ("Document Date" <> 0D) THEN BEGIN
                    PaymentTerms.GET("Payment Terms Code");
                    IF (("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND
                        NOT PaymentTerms."Calc. Pmt. Disc. on Cr. Memos")
                    THEN BEGIN
                        VALIDATE("Due Date", "Document Date");
                        VALIDATE("Pmt. Discount Date", 0D);
                        VALIDATE("Payment Discount %", 0);
                    END ELSE BEGIN
                        "Due Date" := CALCDATE(PaymentTerms."Due Date Calculation", "Document Date");
                        "Pmt. Discount Date" := CALCDATE(PaymentTerms."Discount Date Calculation", "Document Date");
                        VALIDATE("Payment Discount %", PaymentTerms."Discount %")
                    END;
                END ELSE BEGIN
                    VALIDATE("Due Date", "Document Date");
                    VALIDATE("Pmt. Discount Date", 0D);
                    VALIDATE("Payment Discount %", 0);
                END;
                IF xRec."Payment Terms Code" = "Prepmt. Payment Terms Code" THEN
                    VALIDATE("Prepmt. Payment Terms Code", "Payment Terms Code");
            end;
        }
        field(24; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(25; "Payment Discount %"; Decimal)
        {
            Caption = 'Payment Discount %';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                IF NOT (CurrFieldNo IN [0, FIELDNO("Posting Date"), FIELDNO("Document Date")]) THEN
                    TESTFIELD(Status, Status::Open);
                GLSetup.GET;
                IF "Payment Discount %" < GLSetup."VAT Tolerance %" THEN
                    "VAT Base Discount %" := "Payment Discount %"
                ELSE
                    "VAT Base Discount %" := GLSetup."VAT Tolerance %";
                VALIDATE("VAT Base Discount %");
            end;
        }
        field(26; "Pmt. Discount Date"; Date)
        {
            Caption = 'Pmt. Discount Date';
        }
        field(27; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(28; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF ("Location Code" <> xRec."Location Code") AND
                   (xRec."Buy-from Vendor No." = "Buy-from Vendor No.")
                THEN
                    MessageIfPurchLinesExist(FIELDCAPTION("Location Code"));

                UpdateShipToAddress;

                IF "Location Code" = '' THEN BEGIN
                    IF InvtSetup.GET THEN
                        "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
                END ELSE BEGIN
                    IF Location.GET("Location Code") THEN;
                    "Inbound Whse. Handling Time" := Location."Inbound Whse. Handling Time";
                END;
            end;
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                TESTFIELD("Posting Date");
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                UpdateAllLineDateFilters("Posting Date");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(31; "Vendor Posting Group"; Code[10])
        {
            Caption = 'Vendor Posting Group';
            Editable = false;
            TableRelation = "Vendor Posting Group";
        }
        field(32; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate();
            begin
                IF NOT (CurrFieldNo IN [0, FIELDNO("Posting Date")]) OR ("Currency Code" <> xRec."Currency Code") THEN
                    TESTFIELD(Status, Status::Open);
                IF (CurrFieldNo <> FIELDNO("Currency Code")) AND ("Currency Code" = xRec."Currency Code") THEN
                    UpdateCurrencyFactor
                ELSE BEGIN
                    IF "Currency Code" <> xRec."Currency Code" THEN BEGIN
                        UpdateCurrencyFactor;
                        RecreatePurchLines(FIELDCAPTION("Currency Code"));
                    END ELSE
                        IF "Currency Code" <> '' THEN BEGIN
                            UpdateCurrencyFactor;
                            IF "Currency Factor" <> xRec."Currency Factor" THEN
                                ConfirmUpdateCurrencyFactor;
                        END;
                END;
            end;
        }
        field(33; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;

            trigger OnValidate();
            begin
                IF "Currency Factor" <> xRec."Currency Factor" THEN
                    UpdatePurchLines(FIELDCAPTION("Currency Factor"));
            end;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';

            trigger OnValidate();
            var
                PurchLine: Record "Purchase Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
                TESTFIELD(Status, Status::Open);

                IF "Prices Including VAT" <> xRec."Prices Including VAT" THEN BEGIN
                    ReqnLine.SETRANGE("Document Type", "Document Type");
                    ReqnLine.SETRANGE("Document No.", "No.");
                    ReqnLine.SETFILTER("Direct Unit Cost", '<>%1', 0);
                    ReqnLine.SETFILTER("VAT %", '<>%1', 0);
                    IF ReqnLine.FINDFIRST THEN BEGIN
                        RecalculatePrice :=
                          CONFIRM(
                            STRSUBSTNO(
                              Text025 +
                              Text027,
                              FIELDCAPTION("Prices Including VAT"), ReqnLine.FIELDCAPTION("Direct Unit Cost")),
                            TRUE);
                        // ReqnLine.SetReqnHeader(Rec);

                        IF "Currency Code" = '' THEN
                            Currency.InitRoundingPrecision
                        ELSE
                            Currency.GET("Currency Code");

                        REPEAT
                            ReqnLine.TESTFIELD("Quantity Invoiced", 0);
                            ReqnLine.TESTFIELD("Prepmt. Amt. Inv.", 0);
                            IF NOT RecalculatePrice THEN BEGIN
                                ReqnLine."VAT Difference" := 0;
                                ReqnLine.InitOutstandingAmount;
                            END ELSE
                                IF "Prices Including VAT" THEN BEGIN
                                    ReqnLine."Direct Unit Cost" :=
                                      ROUND(
                                        ReqnLine."Direct Unit Cost" * (1 + ReqnLine."VAT %" / 100),
                                        Currency."Unit-Amount Rounding Precision");
                                    IF ReqnLine.Quantity <> 0 THEN BEGIN
                                        ReqnLine."Line Discount Amount" :=
                                          ROUND(
                                            ReqnLine.Quantity * ReqnLine."Direct Unit Cost" * ReqnLine."Line Discount %" / 100,
                                            Currency."Amount Rounding Precision");
                                        ReqnLine.VALIDATE("Inv. Discount Amount",
                                          ROUND(
                                            ReqnLine."Inv. Discount Amount" * (1 + ReqnLine."VAT %" / 100),
                                            Currency."Amount Rounding Precision"));
                                    END;
                                END ELSE BEGIN
                                    ReqnLine."Direct Unit Cost" :=
                                      ROUND(
                                        ReqnLine."Direct Unit Cost" / (1 + ReqnLine."VAT %" / 100),
                                        Currency."Unit-Amount Rounding Precision");
                                    IF ReqnLine.Quantity <> 0 THEN BEGIN
                                        ReqnLine."Line Discount Amount" :=
                                          ROUND(
                                            ReqnLine.Quantity * ReqnLine."Direct Unit Cost" * ReqnLine."Line Discount %" / 100,
                                            Currency."Amount Rounding Precision");
                                        ReqnLine.VALIDATE("Inv. Discount Amount",
                                          ROUND(
                                            ReqnLine."Inv. Discount Amount" / (1 + ReqnLine."VAT %" / 100),
                                            Currency."Amount Rounding Precision"));
                                    END;
                                END;
                            ReqnLine.MODIFY;
                        UNTIL ReqnLine.NEXT = 0;
                    END;
                END;
            end;
        }
        field(37; "Invoice Disc. Code"; Code[20])
        {
            Caption = 'Invoice Disc. Code';

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                MessageIfPurchLinesExist(FIELDCAPTION("Invoice Disc. Code"));
            end;
        }
        field(41; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;

            trigger OnValidate();
            begin
                MessageIfPurchLinesExist(FIELDCAPTION("Language Code"));
            end;
        }
        field(43; "Purchaser Code"; Code[10])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate();
            var
                //TempDocDim: Record "357" temporary;
                ApprovalEntry: Record "Approval Entry";
            begin
                ApprovalEntry.SETRANGE("Table ID", DATABASE::"NFL Requisition Header");
                ApprovalEntry.SETRANGE("Document Type", "Document Type");
                ApprovalEntry.SETRANGE("Document No.", "No.");
                ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
                IF ApprovalEntry.FIND('-') THEN
                    ERROR(Text042, FIELDCAPTION("Purchaser Code"));

                //TempDocDim.GetDimensions(DATABASE::"NFL Requisition Header","Document Type","No.",0,TempDocDim);

                CreateDim(
                  DATABASE::"Salesperson/Purchaser", "Purchaser Code",
                  DATABASE::Vendor, "Pay-to Vendor No.",
                  DATABASE::Campaign, "Campaign No.",
                  DATABASE::"Responsibility Center", "Responsibility Center");

                /*IF ReqnLinesExist THEN
                  TempDocDim.UpdateAllLineDim(DATABASE::"NFL Requisition Header","Document Type","No.",TempDocDim);
                 */

            end;
        }
        field(45; "Order Class"; Code[10])
        {
            Caption = 'Order Class';
        }
        field(46; Comment; Boolean)
        {
            CalcFormula = Exist("Purch. Comment Line" WHERE("Document Type" = FIELD("Document Type"),
                                                             "No." = FIELD("No."),
                                                             "Document Line No." = CONST(0)));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(47; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(51; "On Hold"; Code[3])
        {
            Caption = 'On Hold';
        }
        field(52; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(53; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';

            trigger OnLookup();
            begin
                TESTFIELD("Bal. Account No.", '');
                VendLedgEntry.SETCURRENTKEY("Vendor No.", Open, Positive, "Due Date");
                VendLedgEntry.SETRANGE("Vendor No.", "Pay-to Vendor No.");
                VendLedgEntry.SETRANGE(Open, TRUE);
                IF "Applies-to Doc. No." <> '' THEN BEGIN
                    VendLedgEntry.SETRANGE("Document Type", "Applies-to Doc. Type");
                    VendLedgEntry.SETRANGE("Document No.", "Applies-to Doc. No.");
                    IF VendLedgEntry.FINDFIRST THEN;
                    VendLedgEntry.SETRANGE("Document Type");
                    VendLedgEntry.SETRANGE("Document No.");
                END ELSE
                    IF "Applies-to Doc. Type" <> 0 THEN BEGIN
                        VendLedgEntry.SETRANGE("Document Type", "Applies-to Doc. Type");
                        IF VendLedgEntry.FINDFIRST THEN;
                        VendLedgEntry.SETRANGE("Document Type");
                    END ELSE
                        IF Amount <> 0 THEN BEGIN
                            VendLedgEntry.SETRANGE(Positive, Amount < 0);
                            IF VendLedgEntry.FINDFIRST THEN;
                            VendLedgEntry.SETRANGE(Positive);
                        END;
                //ApplyVendEntries.SetPurch(Rec,VendLedgEntry,ReqnHeader.FIELDNO("Applies-to Doc. No."));
                ApplyVendEntries.SETTABLEVIEW(VendLedgEntry);
                ApplyVendEntries.SETRECORD(VendLedgEntry);
                ApplyVendEntries.LOOKUPMODE(TRUE);
                IF ApplyVendEntries.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    ApplyVendEntries.GetVendLedgEntry(VendLedgEntry);
                    GenJnlApply.CheckAgainstApplnCurrency(
                      "Currency Code", VendLedgEntry."Currency Code", GenJnILine."Account Type"::Vendor, TRUE);
                    "Applies-to Doc. Type" := VendLedgEntry."Document Type";
                    "Applies-to Doc. No." := VendLedgEntry."Document No.";
                END;
                CLEAR(ApplyVendEntries);
            end;

            trigger OnValidate();
            begin
                IF "Applies-to Doc. No." <> '' THEN
                    TESTFIELD("Bal. Account No.", '');

                IF ("Applies-to Doc. No." <> xRec."Applies-to Doc. No.") AND (xRec."Applies-to Doc. No." <> '') AND
                   ("Applies-to Doc. No." <> '')
                THEN BEGIN
                    SetAmountToApply("Applies-to Doc. No.", "Buy-from Vendor No.");
                    SetAmountToApply(xRec."Applies-to Doc. No.", "Buy-from Vendor No.");
                END ELSE
                    IF ("Applies-to Doc. No." <> xRec."Applies-to Doc. No.") AND (xRec."Applies-to Doc. No." = '') THEN
                        SetAmountToApply("Applies-to Doc. No.", "Buy-from Vendor No.")
                    ELSE
                        IF ("Applies-to Doc. No." <> xRec."Applies-to Doc. No.") AND ("Applies-to Doc. No." = '') THEN
                            SetAmountToApply(xRec."Applies-to Doc. No.", "Buy-from Vendor No.");
            end;
        }
        field(55; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account";

            trigger OnValidate();
            begin
                IF "Bal. Account No." <> '' THEN
                    CASE "Bal. Account Type" OF
                        "Bal. Account Type"::"G/L Account":
                            BEGIN
                                GLAcc.GET("Bal. Account No.");
                                GLAcc.CheckGLAcc;
                                GLAcc.TESTFIELD("Direct Posting", TRUE);
                            END;
                        "Bal. Account Type"::"Bank Account":
                            BEGIN
                                BankAcc.GET("Bal. Account No.");
                                BankAcc.TESTFIELD(Blocked, FALSE);
                                BankAcc.TESTFIELD("Currency Code", "Currency Code");
                            END;
                    END;
            end;
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
            CalcFormula = Sum("Purchase Line".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                            "Document No." = FIELD("No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("NFL Requisition Line"."Line Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                          "Document No." = FIELD("No.")));
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
            Editable = false;
            TableRelation = "Purch. Rcpt. Header";
        }
        field(65; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            Editable = false;
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

            trigger OnValidate();
            begin
                IF ("Document Type" = "Document Type"::"Purchase Requisition") AND
                   (xRec."Sell-to Customer No." <> "Sell-to Customer No.")
                THEN BEGIN
                    ReqnLine.SETRANGE("Document Type", ReqnLine."Document Type"::"Purchase Requisition");
                    ReqnLine.SETRANGE("Document No.", "No.");
                    ReqnLine.SETFILTER("Sales Order Line No.", '<>0');
                    IF NOT ReqnLine.ISEMPTY THEN
                        ERROR(
                          Text006,
                          FIELDCAPTION("Sell-to Customer No."));
                END;

                IF "Sell-to Customer No." = '' THEN
                    VALIDATE("Location Code", UserMgt.GetLocation(1, '', "Responsibility Center"))
                ELSE
                    VALIDATE("Ship-to Code", '');
            end;
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

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF (xRec."Buy-from Vendor No." = "Buy-from Vendor No.") AND
                   (xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group")
                THEN
                    IF GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") THEN BEGIN
                        "VAT Bus. Posting Group" := GenBusPostingGrp."Def. VAT Bus. Posting Group";
                        RecreatePurchLines(FIELDCAPTION("Gen. Bus. Posting Group"));
                    END;
            end;
        }
        field(76; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION("Transaction Type"));
            end;
        }
        field(77; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION("Transport Method"));
            end;
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
                //PostCode.LookUpCity("Buy-from City","Buy-from Post Code",TRUE);
            end;

            trigger OnValidate();
            begin
                /*IF "Date Received" = 0D THEN
                  PostCode.ValidateCity("Buy-from City","Buy-from Post Code");*/

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
                //PostCode.LookUpPostCode("Pay-to City","Pay-to Post Code",TRUE);
            end;

            trigger OnValidate();
            begin
                /*IF "Date Received" = 0D THEN
                  PostCode.ValidatePostCode("Pay-to City","Pay-to Post Code");*/

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
                //PostCode.LookUpPostCode("Buy-from City","Buy-from Post Code",TRUE);
            end;

            trigger OnValidate();
            begin
                /*IF "Date Received" = 0D THEN
                  PostCode.ValidatePostCode("Buy-from City","Buy-from Post Code");*/

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

            trigger OnValidate();
            begin
                "VAT Country/Region Code" := "Buy-from Country/Region Code";
            end;
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
                //PostCode.LookUpPostCode("Ship-to City","Ship-to Post Code",TRUE);
            end;

            trigger OnValidate();
            begin
                /*IF "Date Received" = 0D THEN
                  PostCode.ValidatePostCode("Ship-to City","Ship-to Post Code");*/

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

            trigger OnValidate();
            var
                PayToVend: Record Vendor;
            begin
                IF "Order Address Code" <> '' THEN BEGIN
                    OrderAddr.GET("Buy-from Vendor No.", "Order Address Code");
                    "Buy-from Vendor Name" := OrderAddr.Name;
                    "Buy-from Vendor Name 2" := OrderAddr."Name 2";
                    "Buy-from Address" := OrderAddr.Address;
                    "Buy-from Address 2" := OrderAddr."Address 2";
                    "Buy-from City" := OrderAddr.City;
                    "Buy-from Contact" := OrderAddr.Contact;
                    "Buy-from Post Code" := OrderAddr."Post Code";
                    "Buy-from County" := OrderAddr.County;
                    "Buy-from Country/Region Code" := OrderAddr."Country/Region Code";
                    "VAT Country/Region Code" := OrderAddr."Country/Region Code";

                    IF ("Document Type" = "Document Type"::"Imprest Cash Voucher") OR
                       ("Document Type" = "Document Type"::"Cash Voucher")
                    THEN BEGIN
                        "Ship-to Name" := OrderAddr.Name;
                        "Ship-to Name 2" := OrderAddr."Name 2";
                        "Ship-to Address" := OrderAddr.Address;
                        "Ship-to Address 2" := OrderAddr."Address 2";
                        "Ship-to City" := OrderAddr.City;
                        "Ship-to Post Code" := OrderAddr."Post Code";
                        "Ship-to County" := OrderAddr.County;
                        "Ship-to Country/Region Code" := OrderAddr."Country/Region Code";
                        "Ship-to Contact" := OrderAddr.Contact;
                    END

                END ELSE BEGIN
                    GetVend("Buy-from Vendor No.");
                    "Buy-from Vendor Name" := Vend.Name;
                    "Buy-from Vendor Name 2" := Vend."Name 2";
                    "Buy-from Address" := Vend.Address;
                    "Buy-from Address 2" := Vend."Address 2";
                    "Buy-from City" := Vend.City;
                    "Buy-from Contact" := Vend.Contact;
                    "Buy-from Post Code" := Vend."Post Code";
                    "Buy-from County" := Vend.County;
                    "Buy-from Country/Region Code" := Vend."Country/Region Code";
                    "VAT Country/Region Code" := Vend."Country/Region Code";

                    IF ("Document Type" = "Document Type"::"Imprest Cash Voucher") OR
                       ("Document Type" = "Document Type"::"Cash Voucher")
                    THEN BEGIN
                        "Ship-to Name" := Vend.Name;
                        "Ship-to Name 2" := Vend."Name 2";
                        "Ship-to Address" := Vend.Address;
                        "Ship-to Address 2" := Vend."Address 2";
                        "Ship-to City" := Vend.City;
                        "Ship-to Post Code" := Vend."Post Code";
                        "Ship-to County" := Vend.County;
                        "Ship-to Country/Region Code" := Vend."Country/Region Code";
                        "Ship-to Contact" := Vend.Contact;
                        "Shipment Method Code" := Vend."Shipment Method Code";
                        IF Vend."Location Code" <> '' THEN
                            VALIDATE("Location Code", Vend."Location Code");
                    END

                END;
            end;
        }
        field(97; "Entry Point"; Code[10])
        {
            Caption = 'Entry Point';
            TableRelation = "Entry/Exit Point";

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION("Entry Point"));
            end;
        }
        field(98; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(99; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate();
            begin
                //TESTFIELD(Status,Status::Open);
                VALIDATE("Payment Terms Code");
                VALIDATE("Prepmt. Payment Terms Code");
            end;
        }
        field(101; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION(Area));
            end;
        }
        field(102; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";

            trigger OnValidate();
            begin
                UpdatePurchLines(FIELDCAPTION("Transaction Specification"));
            end;
        }
        field(104; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";

            trigger OnValidate();
            begin
                PaymentMethod.INIT;
                IF "Payment Method Code" <> '' THEN
                    PaymentMethod.GET("Payment Method Code");
                "Bal. Account Type" := PaymentMethod."Bal. Account Type";
                "Bal. Account No." := PaymentMethod."Bal. Account No.";
                IF "Bal. Account No." <> '' THEN BEGIN
                    TESTFIELD("Applies-to Doc. No.", '');
                    TESTFIELD("Applies-to ID", '');
                END;
            end;
        }
        field(107; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(108; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnLookup();
            begin
                WITH ReqnHeader DO BEGIN
                    ReqnHeader := Rec;
                    PurchSetup.GET;
                    TestNoSeries;
                    IF NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, "Posting No. Series") THEN
                        VALIDATE("Posting No. Series");
                    Rec := ReqnHeader;
                END;
            end;

            trigger OnValidate();
            begin
                IF "Posting No. Series" <> '' THEN BEGIN
                    PurchSetup.GET;
                    TestNoSeries;
                    NoSeriesMgt.TestSeries(GetPostingNoSeriesCode, "Posting No. Series");
                END;
                TESTFIELD("Posting No.", '');
            end;
        }
        field(109; "Receiving No. Series"; Code[10])
        {
            Caption = 'Receiving No. Series';
            TableRelation = "No. Series";

            trigger OnLookup();
            begin
                WITH ReqnHeader DO BEGIN
                    ReqnHeader := Rec;
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Receipt Nos.");
                    IF NoSeriesMgt.LookupSeries(PurchSetup."Posted Receipt Nos.", "Receiving No. Series") THEN
                        VALIDATE("Receiving No. Series");
                    Rec := ReqnHeader;
                END;
            end;

            trigger OnValidate();
            begin
                IF "Receiving No. Series" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Receipt Nos.");
                    NoSeriesMgt.TestSeries(PurchSetup."Posted Receipt Nos.", "Receiving No. Series");
                END;
                TESTFIELD("Receiving No.", '');
            end;
        }
        field(114; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                MessageIfPurchLinesExist(FIELDCAPTION("Tax Area Code"));
            end;
        }
        field(115; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                MessageIfPurchLinesExist(FIELDCAPTION("Tax Liable"));
            end;
        }
        field(116; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF (xRec."Buy-from Vendor No." = "Buy-from Vendor No.") AND
                   (xRec."VAT Bus. Posting Group" <> "VAT Bus. Posting Group")
                THEN
                    RecreatePurchLines(FIELDCAPTION("VAT Bus. Posting Group"));
            end;
        }
        field(118; "Applies-to ID"; Code[20])
        {
            Caption = 'Applies-to ID';

            trigger OnValidate();
            var
                TempVendLedgEntry: Record "Vendor Ledger Entry";
            begin
                IF "Applies-to ID" <> '' THEN
                    TESTFIELD("Bal. Account No.", '');
                IF ("Applies-to ID" <> xRec."Applies-to ID") AND (xRec."Applies-to ID" <> '') THEN BEGIN
                    VendLedgEntry.SETCURRENTKEY("Vendor No.", Open);
                    VendLedgEntry.SETRANGE("Vendor No.", "Pay-to Vendor No.");
                    VendLedgEntry.SETRANGE(Open, TRUE);
                    VendLedgEntry.SETRANGE("Applies-to ID", xRec."Applies-to ID");
                    IF VendLedgEntry.FINDFIRST THEN
                        VendEntrySetApplID.SetApplId(VendLedgEntry, TempVendLedgEntry, '');
                    VendLedgEntry.RESET;
                END;
            end;
        }
        field(119; "VAT Base Discount %"; Decimal)
        {
            Caption = 'VAT Base Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate();
            begin
                GLSetup.GET;
                IF "VAT Base Discount %" > GLSetup."VAT Tolerance %" THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed :=
                          CONFIRM(
                            Text007 +
                            Text008, FALSE,
                            FIELDCAPTION("VAT Base Discount %"),
                            GLSetup.FIELDCAPTION("VAT Tolerance %"),
                            GLSetup.TABLECAPTION);
                    IF NOT Confirmed THEN
                        "VAT Base Discount %" := xRec."VAT Base Discount %";
                END;

                IF ("VAT Base Discount %" = xRec."VAT Base Discount %") AND
                   (CurrFieldNo <> 0)
                THEN
                    EXIT;

                ReqnLine.SETRANGE("Document Type", "Document Type");
                ReqnLine.SETRANGE("Document No.", "No.");
                ReqnLine.SETFILTER(Type, '<>%1', ReqnLine.Type::" ");
                ReqnLine.SETFILTER(Quantity, '<>0');

                ReqnLine.LOCKTABLE;
                IF ReqnLine.FINDSET THEN BEGIN
                    MODIFY;
                    REPEAT
                        ReqnLine.UpdateAmounts;
                        ReqnLine.MODIFY;
                    UNTIL ReqnLine.NEXT = 0;
                END;
                ReqnLine.RESET;
            end;
        }
        field(120; Status; Option)
        {
            Caption = 'Status';
            Editable = true;
            OptionCaption = 'Open,Released,Pending Approval,Pending Prepayment';
            OptionMembers = Open,Released,"Pending Approval","Pending Prepayment";

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // Message(Format(Rec.Status));
                // if Rec.Status = Rec.Status::Released then begin
                //     Rec.CreatePurchaseRequisitionCommitmentEntries();
                // end;
            end;
        }
        field(121; "Invoice Discount Calculation"; Option)
        {
            Caption = 'Invoice Discount Calculation';
            Editable = false;
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(122; "Invoice Discount Value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Value';
            Editable = false;
        }
        field(123; "Send IC Document"; Boolean)
        {
            Caption = 'Send IC Document';

            trigger OnValidate();
            begin
                IF "Send IC Document" THEN BEGIN
                    TESTFIELD("Buy-from IC Partner Code");
                    TESTFIELD("IC Direction", "IC Direction"::Outgoing);
                END;
            end;
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

            trigger OnValidate();
            begin
                IF "IC Direction" = "IC Direction"::Incoming THEN
                    "Send IC Document" := FALSE;
            end;
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

            trigger OnValidate();
            begin
                IF CurrFieldNo <> 0 THEN
                    UpdatePurchLines(FIELDCAPTION("Prepayment %"));
            end;
        }
        field(135; "Prepayment No. Series"; Code[10])
        {
            Caption = 'Prepayment No. Series';
            TableRelation = "No. Series";

            trigger OnLookup();
            begin
                WITH ReqnHeader DO BEGIN
                    ReqnHeader := Rec;
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Prepmt. Inv. Nos.");
                    IF NoSeriesMgt.LookupSeries(PurchSetup."Posted Prepmt. Inv. Nos.", "Prepayment No. Series") THEN
                        VALIDATE("Prepayment No. Series");
                    Rec := ReqnHeader;
                END;
            end;

            trigger OnValidate();
            begin
                IF "Prepayment No. Series" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Prepmt. Inv. Nos.");
                    NoSeriesMgt.TestSeries(PurchSetup."Posted Prepmt. Inv. Nos.", "Prepayment No. Series");
                END;
                TESTFIELD("Prepayment No. Series", '');
            end;
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

            trigger OnLookup();
            begin
                WITH ReqnHeader DO BEGIN
                    ReqnHeader := Rec;
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Prepmt. Cr. Memo Nos.");
                    IF NoSeriesMgt.LookupSeries(PurchSetup."Posted Prepmt. Cr. Memo Nos.", "Prepmt. Cr. Memo No. Series") THEN
                        VALIDATE("Prepmt. Cr. Memo No. Series");
                    Rec := ReqnHeader;
                END;
            end;

            trigger OnValidate();
            begin
                IF "Prepmt. Cr. Memo No. Series" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Prepmt. Cr. Memo Nos.");
                    NoSeriesMgt.TestSeries(PurchSetup."Posted Prepmt. Cr. Memo Nos.", "Prepmt. Cr. Memo No. Series");
                END;
                TESTFIELD("Prepmt. Cr. Memo No. Series", '');
            end;
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
                IF ("Prepmt. Payment Terms Code" <> '') AND ("Document Date" <> 0D) THEN BEGIN
                    PaymentTerms.GET("Prepmt. Payment Terms Code");
                    IF (("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND
                        NOT PaymentTerms."Calc. Pmt. Disc. on Cr. Memos")
                    THEN BEGIN
                        VALIDATE("Prepayment Due Date", "Document Date");
                        VALIDATE("Prepmt. Pmt. Discount Date", 0D);
                        VALIDATE("Prepmt. Payment Discount %", 0);
                    END ELSE BEGIN
                        "Prepayment Due Date" := CALCDATE(PaymentTerms."Due Date Calculation", "Document Date");
                        "Prepmt. Pmt. Discount Date" := CALCDATE(PaymentTerms."Discount Date Calculation", "Document Date");
                        VALIDATE("Prepmt. Payment Discount %", PaymentTerms."Discount %")
                    END;
                END ELSE BEGIN
                    VALIDATE("Prepayment Due Date", "Document Date");
                    VALIDATE("Prepmt. Pmt. Discount Date", 0D);
                    VALIDATE("Prepmt. Payment Discount %", 0);
                END;
            end;
        }
        field(144; "Prepmt. Payment Discount %"; Decimal)
        {
            Caption = 'Prepmt. Payment Discount %';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                IF NOT (CurrFieldNo IN [0, FIELDNO("Posting Date"), FIELDNO("Document Date")]) THEN
                    TESTFIELD(Status, Status::Open);
                GLSetup.GET;
                IF "Payment Discount %" < GLSetup."VAT Tolerance %" THEN
                    "VAT Base Discount %" := "Payment Discount %"
                ELSE
                    "VAT Base Discount %" := GLSetup."VAT Tolerance %";
                VALIDATE("VAT Base Discount %");
            end;
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

            trigger OnLookup();
            begin
                ShowDocDim;
            end;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
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
        field(5048; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }
        field(5050; "Campaign No."; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;

            trigger OnValidate();
            var
            //TempDocDim: Record "357" temporary;
            begin
                //TempDocDim.GetDimensions(DATABASE::"NFL Requisition Header","Document Type","No.",0,TempDocDim);

                CreateDim(
                  DATABASE::Campaign, "Campaign No.",
                  DATABASE::Vendor, "Pay-to Vendor No.",
                  DATABASE::"Salesperson/Purchaser", "Purchaser Code",
                  DATABASE::"Responsibility Center", "Responsibility Center");

                /*IF ReqnLinesExist THEN
                  TempDocDim.UpdateAllLineDim(DATABASE::"NFL Requisition Header","Document Type","No.",TempDocDim);
                */

            end;
        }
        field(5052; "Buy-from Contact No."; Code[20])
        {
            Caption = 'Buy-from Contact No.';
            TableRelation = Contact;

            trigger OnLookup();
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                IF "Buy-from Vendor No." <> '' THEN BEGIN
                    IF Cont.GET("Buy-from Contact No.") THEN
                        Cont.SETRANGE("Company No.", Cont."Company No.")
                    ELSE BEGIN
                        ContBusinessRelation.RESET;
                        ContBusinessRelation.SETCURRENTKEY("Link to Table", "No.");
                        ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
                        ContBusinessRelation.SETRANGE("No.", "Buy-from Vendor No.");
                        IF ContBusinessRelation.FINDFIRST THEN
                            Cont.SETRANGE("Company No.", ContBusinessRelation."Contact No.")
                        ELSE
                            Cont.SETRANGE("No.", '');
                    END;
                END;

                IF "Buy-from Contact No." <> '' THEN
                    IF Cont.GET("Buy-from Contact No.") THEN;
                IF PAGE.RUNMODAL(0, Cont) = ACTION::LookupOK THEN BEGIN
                    xRec := Rec;
                    VALIDATE("Buy-from Contact No.", Cont."No.");
                END;
            end;

            trigger OnValidate();
            var
                ContBusinessRelation: Record "Contact Business Relation";
                Cont: Record Contact;
            begin
                TESTFIELD(Status, Status::Open);

                IF ("Buy-from Contact No." <> xRec."Buy-from Contact No.") AND
                   (xRec."Buy-from Contact No." <> '')
                THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed := CONFIRM(Text004, FALSE, FIELDCAPTION("Buy-from Contact No."));
                    IF Confirmed THEN BEGIN
                        ReqnLine.SETRANGE("Document Type", "Document Type");
                        ReqnLine.SETRANGE("Document No.", "No.");
                        IF ("Buy-from Contact No." = '') AND ("Buy-from Vendor No." = '') THEN BEGIN
                            IF NOT ReqnLine.ISEMPTY THEN
                                ERROR(
                                  Text005,
                                  FIELDCAPTION("Buy-from Contact No."));
                            INIT;
                            PurchSetup.GET;
                            InitRecord;
                            "No. Series" := xRec."No. Series";
                            IF xRec."Receiving No." <> '' THEN BEGIN
                                "Receiving No. Series" := xRec."Receiving No. Series";
                                "Receiving No." := xRec."Receiving No.";
                            END;
                            IF xRec."Posting No." <> '' THEN BEGIN
                                "Posting No. Series" := xRec."Posting No. Series";
                                "Posting No." := xRec."Posting No.";
                            END;
                            IF xRec."Return Shipment No." <> '' THEN BEGIN
                                "Return Shipment No. Series" := xRec."Return Shipment No. Series";
                                "Return Shipment No." := xRec."Return Shipment No.";
                            END;
                            IF xRec."Prepayment No." <> '' THEN BEGIN
                                "Prepayment No. Series" := xRec."Prepayment No. Series";
                                "Prepayment No." := xRec."Prepayment No.";
                            END;
                            IF xRec."Prepmt. Cr. Memo No." <> '' THEN BEGIN
                                "Prepmt. Cr. Memo No. Series" := xRec."Prepmt. Cr. Memo No. Series";
                                "Prepmt. Cr. Memo No." := xRec."Prepmt. Cr. Memo No.";
                            END;
                            EXIT;
                        END;
                    END ELSE BEGIN
                        Rec := xRec;
                        EXIT;
                    END;
                END;

                IF ("Buy-from Vendor No." <> '') AND ("Buy-from Contact No." <> '') THEN BEGIN
                    Cont.GET("Buy-from Contact No.");
                    ContBusinessRelation.RESET;
                    ContBusinessRelation.SETCURRENTKEY("Link to Table", "No.");
                    ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
                    ContBusinessRelation.SETRANGE("No.", "Buy-from Vendor No.");
                    IF ContBusinessRelation.FINDFIRST THEN
                        IF ContBusinessRelation."Contact No." <> Cont."Company No." THEN
                            ERROR(Text038, Cont."No.", Cont.Name, "Buy-from Vendor No.");
                END;

                UpdateBuyFromVend("Buy-from Contact No.");
            end;
        }
        field(5053; "Pay-to Contact No."; Code[20])
        {
            Caption = 'Pay-to Contact No.';
            TableRelation = Contact;

            trigger OnLookup();
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                IF "Pay-to Vendor No." <> '' THEN BEGIN
                    IF Cont.GET("Pay-to Contact No.") THEN
                        Cont.SETRANGE("Company No.", Cont."Company No.")
                    ELSE BEGIN
                        ContBusinessRelation.RESET;
                        ContBusinessRelation.SETCURRENTKEY("Link to Table", "No.");
                        ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
                        ContBusinessRelation.SETRANGE("No.", "Pay-to Vendor No.");
                        IF ContBusinessRelation.FINDFIRST THEN
                            Cont.SETRANGE("Company No.", ContBusinessRelation."Contact No.")
                        ELSE
                            Cont.SETRANGE("No.", '');
                    END;
                END;

                IF "Pay-to Contact No." <> '' THEN
                    IF Cont.GET("Pay-to Contact No.") THEN;
                IF PAGE.RUNMODAL(0, Cont) = ACTION::LookupOK THEN BEGIN
                    xRec := Rec;
                    VALIDATE("Pay-to Contact No.", Cont."No.");
                END;
            end;

            trigger OnValidate();
            var
                ContBusinessRelation: Record "Contact Business Relation";
                Cont: Record Contact;
            begin
                TESTFIELD(Status, Status::Open);

                IF ("Pay-to Contact No." <> xRec."Pay-to Contact No.") AND
                   (xRec."Pay-to Contact No." <> '')
                THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed := CONFIRM(Text004, FALSE, FIELDCAPTION("Pay-to Contact No."));
                    IF Confirmed THEN BEGIN
                        ReqnLine.SETRANGE("Document Type", "Document Type");
                        ReqnLine.SETRANGE("Document No.", "No.");
                        IF ("Pay-to Contact No." = '') AND ("Pay-to Vendor No." = '') THEN BEGIN
                            IF NOT ReqnLine.ISEMPTY THEN
                                ERROR(
                                  Text005,
                                  FIELDCAPTION("Pay-to Contact No."));
                            INIT;
                            PurchSetup.GET;
                            InitRecord;
                            "No. Series" := xRec."No. Series";
                            IF xRec."Receiving No." <> '' THEN BEGIN
                                "Receiving No. Series" := xRec."Receiving No. Series";
                                "Receiving No." := xRec."Receiving No.";
                            END;
                            IF xRec."Posting No." <> '' THEN BEGIN
                                "Posting No. Series" := xRec."Posting No. Series";
                                "Posting No." := xRec."Posting No.";
                            END;
                            IF xRec."Return Shipment No." <> '' THEN BEGIN
                                "Return Shipment No. Series" := xRec."Return Shipment No. Series";
                                "Return Shipment No." := xRec."Return Shipment No.";
                            END;
                            IF xRec."Prepayment No." <> '' THEN BEGIN
                                "Prepayment No. Series" := xRec."Prepayment No. Series";
                                "Prepayment No." := xRec."Prepayment No.";
                            END;
                            IF xRec."Prepmt. Cr. Memo No." <> '' THEN BEGIN
                                "Prepmt. Cr. Memo No. Series" := xRec."Prepmt. Cr. Memo No. Series";
                                "Prepmt. Cr. Memo No." := xRec."Prepmt. Cr. Memo No.";
                            END;
                            EXIT;
                        END;
                    END ELSE BEGIN
                        "Pay-to Contact No." := xRec."Pay-to Contact No.";
                        EXIT;
                    END;
                END;

                IF ("Pay-to Vendor No." <> '') AND ("Pay-to Contact No." <> '') THEN BEGIN
                    Cont.GET("Pay-to Contact No.");
                    ContBusinessRelation.RESET;
                    ContBusinessRelation.SETCURRENTKEY("Link to Table", "No.");
                    ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
                    ContBusinessRelation.SETRANGE("No.", "Pay-to Vendor No.");
                    IF ContBusinessRelation.FINDFIRST THEN
                        IF ContBusinessRelation."Contact No." <> Cont."Company No." THEN
                            ERROR(Text038, Cont."No.", Cont.Name, "Pay-to Vendor No.");
                END;

                UpdatePayToVend("Pay-to Contact No.");
            end;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF NOT UserMgt.CheckRespCenter(1, "Responsibility Center") THEN
                    ERROR(
                      Text028,
                      RespCenter.TABLECAPTION, UserMgt.GetPurchasesFilter);

                "Location Code" := UserMgt.GetLocation(1, '', "Responsibility Center");
                IF "Location Code" = '' THEN BEGIN
                    IF InvtSetup.GET THEN
                        "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
                END ELSE BEGIN
                    IF Location.GET("Location Code") THEN;
                    "Inbound Whse. Handling Time" := Location."Inbound Whse. Handling Time";
                END;

                UpdateShipToAddress;

                CreateDim(
                  DATABASE::"Responsibility Center", "Responsibility Center",
                  DATABASE::Vendor, "Pay-to Vendor No.",
                  DATABASE::"Salesperson/Purchaser", "Purchaser Code",
                  DATABASE::Campaign, "Campaign No.");

                IF xRec."Responsibility Center" <> "Responsibility Center" THEN BEGIN
                    RecreatePurchLines(FIELDCAPTION("Responsibility Center"));
                    "Assigned User ID" := '';
                END;
            end;
        }
        field(5752; "Completely Received"; Boolean)
        {
            CalcFormula = Min("Purchase Line"."Completely Received" WHERE("Document Type" = FIELD("Document Type"),
                                                                           "Document No." = FIELD("No."),
                                                                           Type = FILTER(<> ' '),
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

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF "Promised Receipt Date" <> 0D THEN
                    ERROR(
                      Text034,
                      FIELDCAPTION("Requested Receipt Date"),
                      FIELDCAPTION("Promised Receipt Date"));

                IF "Requested Receipt Date" <> xRec."Requested Receipt Date" THEN
                    UpdatePurchLines(FIELDCAPTION("Requested Receipt Date"));
            end;
        }
        field(5791; "Promised Receipt Date"; Date)
        {
            Caption = 'Promised Receipt Date';

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF "Promised Receipt Date" <> xRec."Promised Receipt Date" THEN
                    UpdatePurchLines(FIELDCAPTION("Promised Receipt Date"));
            end;
        }
        field(5792; "Lead Time Calculation"; DateFormula)
        {
            Caption = 'Lead Time Calculation';

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF "Lead Time Calculation" <> xRec."Lead Time Calculation" THEN
                    UpdatePurchLines(FIELDCAPTION("Lead Time Calculation"));
            end;
        }
        field(5793; "Inbound Whse. Handling Time"; DateFormula)
        {
            Caption = 'Inbound Whse. Handling Time';

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                IF "Inbound Whse. Handling Time" <> xRec."Inbound Whse. Handling Time" THEN
                    UpdatePurchLines(FIELDCAPTION("Inbound Whse. Handling Time"));
            end;
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

            trigger OnLookup();
            begin
                WITH ReqnHeader DO BEGIN
                    ReqnHeader := Rec;
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Return Shpt. Nos.");
                    IF NoSeriesMgt.LookupSeries(PurchSetup."Posted Return Shpt. Nos.", "Return Shipment No. Series") THEN
                        VALIDATE("Return Shipment No. Series");
                    Rec := ReqnHeader;
                END;
            end;

            trigger OnValidate();
            begin
                IF "Return Shipment No. Series" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Posted Return Shpt. Nos.");
                    NoSeriesMgt.TestSeries(PurchSetup."Posted Return Shpt. Nos.", "Return Shipment No. Series");
                END;
                TESTFIELD("Return Shipment No.", '');
            end;
        }
        field(5803; Ship; Boolean)
        {
            Caption = 'Ship';
        }
        field(5804; "Last Return Shipment No."; Code[20])
        {
            Caption = 'Last Return Shipment No.';
            Editable = false;
            TableRelation = "Return Shipment Header";
        }
        field(9000; "Assigned User ID"; Code[100])
        {
            Caption = 'Assigned User ID';
            TableRelation = "User Setup";

            trigger OnValidate();
            begin
                IF NOT UserMgt.CheckRespCenter(1, "Responsibility Center", "Assigned User ID") THEN
                    ERROR(Text049, "Assigned User ID", RespCenter.TABLECAPTION, UserMgt.GetPurchasesFilter("Assigned User ID"));
            end;
        }
        field(50000; "Request-By No."; Code[100])
        {
            TableRelation = Employee."No.";

            trigger OnValidate();
            var
                Employee: Record Employee;
            begin
                TESTFIELD(Status, Status::Open);

                Employee.GET("Request-By No.");
                IF Employee."Middle Name" = '' THEN
                    "Request-By Name" := Employee."First Name" + ' ' + Employee."Last Name"
                ELSE
                    "Request-By Name" := Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";

                //Copy the Dimensions
                Employee.GET("Request-By No.");
                "Shortcut Dimension 1 Code" := Employee."Global Dimension 1 Code";
                "Shortcut Dimension 2 Code" := Employee."Global Dimension 2 Code";

                //AMI 121109 Dimension saving from the Employee Table
                VALIDATE("Shortcut Dimension 1 Code");
                VALIDATE("Shortcut Dimension 2 Code");
                //End AMI

                //End Dimensions


                //
                ReqnLine.RESET;
                ReqnLine.SETRANGE("Document Type", "Document Type");
                ReqnLine.SETRANGE("Document No.", "No.");
                //Modify
                IF ReqnLine.FINDSET THEN BEGIN
                    ReqnLine.MODIFYALL("Request-By No.", "Request-By No.");
                    ReqnLine.MODIFYALL("Request-By Name", "Request-By Name");
                END;


                IF ("Request-By No." <> xRec."Request-By No.") AND
                 (xRec."Request-By No." <> '')
                 THEN BEGIN
                    IF HideValidationDialog THEN
                        Confirmed := TRUE
                    ELSE
                        Confirmed := CONFIRM(Text004, FALSE, FIELDCAPTION("Request-By No."));

                    IF Confirmed THEN BEGIN
                        ReqnLine.RESET;
                        ReqnLine.SETRANGE("Document Type", "Document Type");
                        ReqnLine.SETRANGE("Document No.", "No.");
                        //Modify
                        IF ReqnLine.FINDSET THEN BEGIN
                            ReqnLine.MODIFYALL("Request-By No.", "Request-By No.");
                            ReqnLine.MODIFYALL("Request-By Name", "Request-By Name");
                        END;

                        IF "Request-By No." = '' THEN BEGIN
                            IF NOT ReqnLine.ISEMPTY THEN BEGIN
                                ERROR(
                                Text005,
                                FIELDCAPTION("Request-By No."));
                                INIT;
                                PurchSetup.GET;
                                "No. Series" := xRec."No. Series";
                                InitRecord;
                            END;

                            IF xRec."Posting No." <> '' THEN BEGIN
                                "Posting No. Series" := xRec."Posting No. Series";
                                "Posting No." := xRec."Posting No.";
                            END;

                            IF "Document Type" = "Document Type"::"Store Requisition" THEN
                                ReqnLine.SETFILTER("Qty. Requested", '<>0');
                        END;
                        ReqnLine.RESET;

                    END ELSE BEGIN
                        Rec := xRec;
                        EXIT;

                    END;
                END;
            end;


        }
        field(50001; "Request-By Name"; Text[50])
        {
            Editable = false;
            FieldClass = Normal;

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
        field(50007; "Approver ID"; Code[100])
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
            Editable = false;
            TableRelation = "G/L Budget Name";

            trigger OnValidate();
            begin
                TESTFIELD("Posting Date");
                IF ReqnLinesExist THEN BEGIN
                    UpdateAllLineBudget("Budget Code");
                    UpdateAllLineDateFilters("Posting Date");
                END;
            end;
        }
        field(50020; Archieved; Boolean)
        {
            Editable = false;
        }
        field(50022; "Sent to Budget Controller"; Boolean)
        {
            Editable = false;
        }
        field(50023; "Prepared by"; Code[50])
        {
            Editable = false;
        }
        field(50024; "Requisition Details Total"; Decimal)
        {
            CalcFormula = Sum("Purchase Requisition Detail".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                          "Document No." = FIELD("No.")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50025; "Requisition Lines Total"; Decimal)
        {
            CalcFormula = Sum("NFL Requisition Line"."Line Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                          "Document No." = FIELD("No.")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
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

            trigger OnValidate();
            var
            // NFLUsers: Record "NFL Users";
            begin
                // TESTFIELD(Status, Status::Open);
                // IF NFLUsers.GET(USERID) THEN BEGIN
                //     IF "Document Type" <> "Document Type"::"Store Return" THEN BEGIN
                //         IF NOT NFLUsers."Edit Store/Purch Req. Validity" THEN
                //             ERROR('You do not have permission to change this document validity date')
                //         ELSE
                //             IF "Valid to Date" < "Document Date" THEN
                //                 ERROR('Validity date entered is invalid');
                //     END ELSE BEGIN
                //         IF NOT NFLUsers."Edit Store Return Validity" THEN
                //             ERROR('You do not have permission to change this document validity date')
                //         ELSE
                //             IF "Valid to Date" < "Document Date" THEN
                //                 ERROR('Validity date entered is invalid');
                //     END;
                // END ELSE
                //     ERROR('You do not have permission to change this document validity date');
            end;
        }
        field(50040; "PD Entity"; Text[60])
        {
        }
        field(50041; "Procurement Category"; Option)
        {
            OptionCaption = ' ,Supplies,Works and Construction,Services';
            OptionMembers = " ",Supplies,"Works and Construction",Services;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
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
                ValidateShortcutDimCode(8, "Hub Code");
            end;
        }
        field(50114; Process; Boolean)
        {
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // Message('Updadte');
                // Rec.Validate(Status);
                // Message(Format(Rec.Status));
            end;
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.")
        {
        }
        key(Key2; "No.", "Document Type")
        {
        }
        key(Key3; "Document Type", "Buy-from Vendor No.", "No.")
        {
        }
        key(Key4; "Buy-from Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    var
        lvStoreReqLine: Record "NFL Requisition Line";
        FromDocDim: Record "Document Dimension";
    begin
        // TESTFIELD(Status, Status::Open);

        IF NOT UserMgt.CheckRespCenter(1, "Responsibility Center") THEN
            ERROR(
              Text023,
              RespCenter.TABLECAPTION, UserMgt.GetPurchasesFilter);

        ReqnLine.SETRANGE("Document Type", "Document Type");
        ReqnLine.SETRANGE("Document No.", "No.");
        ReqnLine.SETRANGE(Type, ReqnLine.Type::"Charge (Item)");
        DeletePurchaseLines;
        ReqnLine.SETRANGE(Type);
        DeletePurchaseLines;

        // MAG - 25TH SEPT. 2018
        PurchaseRequisitionDetail.SETRANGE("Document Type", "Document Type");
        PurchaseRequisitionDetail.SETRANGE("Document No.", "No.");
        PurchaseRequisitionDetail.DELETEALL;
        // MAG - END.

        // IE commented all this function
        //CSM End
        // ApprovalMgt.DeleteApprovalEntry(DATABASE::"NFL Requisition Header", "Document Type", "No.");
        // ReqnLine.LOCKTABLE;

        WhseRequest.SETRANGE("Source Type", DATABASE::"NFL Requisition Line");
        WhseRequest.SETRANGE("Source Subtype", "Document Type");
        WhseRequest.SETRANGE("Source No.", "No.");
        WhseRequest.DELETEALL(TRUE);

        ReqnLine.SETRANGE("Document Type", "Document Type");
        ReqnLine.SETRANGE("Document No.", "No.");
        ReqnLine.SETRANGE(Type, ReqnLine.Type::"Charge (Item)");
        DeletePurchaseLines;
        ReqnLine.SETRANGE(Type);
        DeletePurchaseLines;

        PurchCommentLine.SETRANGE("Document Type", "Document Type");
        PurchCommentLine.SETRANGE("No.", "No.");
        PurchCommentLine.DELETEALL;

        //cmm 060809 delete store req.
        IF "Document Type" = "Document Type"::"Store Requisition" THEN BEGIN
            IF CONFIRM('Do you wish to delete the header and the lines?') THEN BEGIN
                lvStoreReqLine.RESET;
                lvStoreReqLine.SETFILTER("Document Type", FORMAT(lvStoreReqLine."Document Type"::"Store Requisition"));
                lvStoreReqLine.SETFILTER("Document No.", "No.");

                //delete the record and dimensions
                FromDocDim.RESET;
                FromDocDim.SETFILTER("Table ID", '%1|%2', DATABASE::"NFL Requisition Header", DATABASE::"NFL Requisition Line");
                FromDocDim.SETFILTER(FromDocDim."Document Type", '%1', FromDocDim."Document Type"::"Store Requisition");
                FromDocDim.SETFILTER(FromDocDim."Document No.", "No.");
                IF FromDocDim.FINDSET THEN FromDocDim.DELETEALL;
                lvStoreReqLine.DELETEALL;
                DELETE;
            END;
        END;
        //end cmm
    end;

    trigger OnInsert();
    begin
        PurchSetup.GET;

        IF "No." = '' THEN BEGIN
            TestNoSeries;
            NoSeriesMgt.InitSeries(GetNoSeriesCode, xRec."No. Series", "Posting Date", "No.", "No. Series");
        END;

        InitRecord;

        IF GETFILTER("Buy-from Vendor No.") <> '' THEN
            IF GETRANGEMIN("Buy-from Vendor No.") = GETRANGEMAX("Buy-from Vendor No.") THEN
                VALIDATE("Buy-from Vendor No.", GETRANGEMIN("Buy-from Vendor No."));
        //CAW 240908 EA-LAYER
        IF GETFILTER("Request-By No.") <> '' THEN
            IF GETRANGEMIN("Request-By No.") = GETRANGEMAX("Request-By No.") THEN
                VALIDATE("Request-By No.", GETRANGEMIN("Request-By No."));
        //CAW END


        "Doc. No. Occurrence" := ArchiveManagement.GetNextOccurrenceNo(DATABASE::"NFL Requisition Header", "Document Type", "No.");

        "Requestor ID" := USERID;

        UpdateValidityDate;
    end;

    trigger OnModify();
    begin
        //CMM 011009 PROHIBIT modification of released store req
        IF ("Document Type" = "Document Type"::"Store Requisition") AND (Status <> Status::Open) AND
        (Status <> xRec.Status) THEN
            ERROR('Status must be Open inorder to change');
        //end CMM
    end;

    trigger OnRename();
    begin
        ERROR(Text003, TABLECAPTION);
    end;

    var
        Text000: Label 'Do you want to print receipt %1?';
        Text001: Label 'Do you want to print invoice %1?';
        Text002: Label 'Do you want to print credit memo %1?';
        Text003: Label 'You cannot rename a %1.';
        Text004: Label 'Do you want to change %1? The lines will also be modified.';
        Text005: Label 'You cannot reset %1 because the document still has one or more lines.';
        Text006: Label 'You cannot change %1 because the order is associated with one or more sales orders.';
        Text007: Label '%1 is greater than %2 in the %3 table.\';
        Text008: Label 'Confirm change?';
        Text009: Label '"Deleting this document will cause a gap in the number series for receipts. "';
        Text010: Label 'An empty receipt %1 will be created to fill this gap in the number series.\\';
        Text011: Label 'Do you want to continue?';
        Text012: Label '"Deleting this document will cause a gap in the number series for posted invoices. "';
        Text013: Label 'An empty posted invoice %1 will be created to fill this gap in the number series.\\';
        Text014: Label '"Deleting this document will cause a gap in the number series for posted credit memos. "';
        Text015: Label 'An empty posted credit memo %1 will be created to fill this gap in the number series.\\';
        Text016: Label 'If you change %1, the existing purchase lines will be deleted and new purchase lines based on the new information in the header will be created.\\';
        Text018: Label 'You must delete the existing purchase lines before you can change %1.';
        Text019: Label 'You have changed %1 on the purchase header, but it has not been changed on the existing purchase lines.\';
        Text020: Label 'You must update the existing purchase lines manually.';
        Text021: Label 'The change may affect the exchange rate used on the price calculation of the purchase lines.';
        Text022: Label 'Do you want to update the exchange rate?';
        Text023: Label 'You cannot delete this document. Your identification is set up to process from %1 %2 only.';
        Text024: Label 'Do you want to print return shipment %1?';
        Text025: Label '"You have modified the %1 field. Note that the recalculation of VAT may cause penny differences, so you must check the amounts afterwards. "';
        Text027: Label 'Do you want to update the %2 field on the lines to reflect the new value of %1?';
        Text028: Label 'Your identification is set up to process from %1 %2 only.';
        Text029: Label '"Deleting this document will cause a gap in the number series for return shipments. "';
        Text030: Label 'An empty return shipment %1 will be created to fill this gap in the number series.\\';
        Text032: Label 'You have modified %1.\\';
        Text033: Label 'Do you want to update the lines?';
        PurchSetup: Record "Purchases & Payables Setup";
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
        ReqnLine: Record "NFL Requisition Line";
        xReqnLine: Record "NFL Requisition Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vend: Record Vendor;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        CurrExchRate: Record "Currency Exchange Rate";
        ReqnHeader: Record "NFL Requisition Header";
        PurchCommentLine: Record "Purch. Comment Line";
        ShipToAddr: Record "Ship-to Address";
        Cust: Record Customer;
        CompanyInfo: Record "Company Information";
        PostCode: Record "Post Code";
        OrderAddr: Record "Order Address";
        BankAcc: Record "Bank Account";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ReturnShptHeader: Record "Return Shipment Header";
        PurchInvHeaderPrepmt: Record "Purch. Inv. Header";
        PurchCrMemoHeaderPrepmt: Record "Purch. Cr. Memo Hdr.";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenJnILine: Record "Gen. Journal Line";
        RespCenter: Record "Responsibility Center";
        Location: Record Location;
        WhseRequest: Record "Warehouse Request";
        InvtSetup: Record "Inventory Setup";
        //DocDim: Record "357"; // IE Table does not exist in the current version
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TransferExtendedText: Codeunit "Transfer Extended Text";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        PurchPost: Codeunit "Purch.-Post";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        DimMgt: Codeunit DimensionManagement;
        ApprovalMgt: Codeunit "Approvals Management";
        UserMgt: Codeunit "User Setup Management";
        ArchiveManagement: Codeunit "ArchiveManagement";
        ReserveReqnLine: Codeunit "Purch. Line-Reserve";
        ApplyVendEntries: Page "Apply Vendor Entries";
        CurrencyDate: Date;
        HideValidationDialog: Boolean;
        Confirmed: Boolean;
        Text034: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text037: Label 'Contact %1 %2 is not related to vendor %3.';
        Text038: Label 'Contact %1 %2 is related to a different company than vendor %3.';
        Text039: Label 'Contact %1 %2 is not related to a vendor.';
        SkipBuyFromContact: Boolean;
        SkipPayToContact: Boolean;
        Text040: TextConst ENU = 'You can not change the %1 field because %2 %3 has %4 = %5 and the %6 has already been assigned %7 %8.';
        Text041: Label 'The purchase %1 %2 has item tracking. Do you want to delete it anyway?';
        Text042: Label 'You must cancel the approval process if you wish to change the %1.';
        Text043: Label 'Do you want to print prepayment invoice %1?';
        Text044: Label 'Do you want to print prepayment credit memo %1?';
        Text045: Label '"Deleting this document will cause a gap in the number series for prepayment invoices. "';
        Text046: Label 'An empty prepayment invoice %1 will be created to fill this gap in the number series.\\';
        Text047: Label '"Deleting this document will cause a gap in the number series for prepayment credit memos. "';
        Text049: Label '%1 is set up to process from %2 %3 only.';
        ANFSetup: Record "General Ledger Setup";
        NFLPurchLine: Record "NFL Requisition Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        gvDimensionSetEntry: Record "Dimension Set Entry";
        globalVarNFLRequisitionHeader: Record "NFL Requisition Header";
        PurchaseRequisitionDetail: Record "Purchase Requisition Detail";
        gvCommitmentEntry: Record "Commitment Entry";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";

    /// <summary>
    /// Description for InitRecord.
    /// </summary>
    procedure InitRecord();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        ANFSetup.GET;
        CASE "Document Type" OF
            "Document Type"::"Purchase Requisition":
                BEGIN
                    IF ("No. Series" <> '') AND
                       (ANFSetup."Store Requisition Nos" = ANFSetup."Store Requisition Nos")
                    THEN
                        "Posting No. Series" := "No. Series"
                    ELSE
                        NoSeriesMgt.SetDefaultSeries("Posting No. Series", ANFSetup."Store Requisition Nos");
                    // MAG 4TH SEPT. 2018
                    GeneralLedgerSetup.GET;
                    GeneralLedgerSetup.TESTFIELD("Approved Budget");
                    "Budget Code" := GeneralLedgerSetup."Approved Budget";
                    "Prepared by" := USERID;
                END;

            "Document Type"::"Store Requisition":
                BEGIN
                    IF ("No. Series" <> '') AND
                       (ANFSetup."Store Requisition Nos" = ANFSetup."Store Requisition Nos")
                    THEN
                        "Posting No. Series" := "No. Series"
                    ELSE
                        NoSeriesMgt.SetDefaultSeries("Posting No. Series", ANFSetup."Store Requisition Nos");
                END;
        END;

        IF "Document Type" IN ["Document Type"::"Purchase Requisition", "Document Type"::"Store Return", "Document Type"::"Imprest Cash Voucher"] THEN
            "Order Date" := WORKDATE;

        IF "Document Type" = "Document Type"::"Store Return" THEN
            "Expected Receipt Date" := WORKDATE;

        IF NOT ("Document Type" IN ["Document Type"::"HR Cash Voucher", "Document Type"::"Store Requisition"]) AND
           ("Posting Date" = 0D)
        THEN
            "Posting Date" := WORKDATE;

        IF PurchSetup."Default Posting Date" = PurchSetup."Default Posting Date"::"No Date" THEN
            "Posting Date" := 0D;

        "Document Date" := WORKDATE;

        //VALIDATE("Sell-to Customer No.",'');

        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN BEGIN
            GLSetup.GET;
            Correction := GLSetup."Mark Cr. Memos as Corrections";
        END;

        // "Posting Description" := FORMAT("Document Type") + ' ' + "No."; // MAG 25TH MAY 2018. Ensure that a user enters a posting descriptions.

        IF InvtSetup.GET THEN
            "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";

        "Responsibility Center" := UserMgt.GetRespCenter(1, "Responsibility Center");

        GetFiscalYearAndAccountingPeriod("Posting Date"); // MAG 6TH AUG. 2018
    end;

    /// <summary>
    /// Description for AssistEdit.
    /// </summary>
    /// <param name="OldReqnHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure AssistEdit(OldReqnHeader: Record "NFL Requisition Header"): Boolean;
    begin
        ANFSetup.GET;
        TestNoSeries;
        IF NoSeriesMgt.SelectSeries(GetNoSeriesCode, OldReqnHeader."No. Series", "No. Series") THEN BEGIN
            PurchSetup.GET;
            TestNoSeries;
            NoSeriesMgt.SetSeries("No.");
            EXIT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for TestNoSeries.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    local procedure TestNoSeries(): Boolean;
    begin
        ANFSetup.GET;
        CASE "Document Type" OF
            "Document Type"::"Store Requisition":
                ANFSetup.TESTFIELD("Store Requisition Nos");

            "Document Type"::"Purchase Requisition":
                ANFSetup.TESTFIELD("Purchase Requisition Nos");

            "Document Type"::"Store Return":
                ANFSetup.TESTFIELD("Store Return Nos");

        END;
    end;

    /// <summary>
    /// Description for GetNoSeriesCode.
    /// </summary>
    /// <returns>Return variable "Code[10]".</returns>
    local procedure GetNoSeriesCode(): Code[10];
    begin
        CASE "Document Type" OF
            "Document Type"::"Store Requisition":
                EXIT(ANFSetup."Store Requisition Nos");
            "Document Type"::"Purchase Requisition":
                EXIT(ANFSetup."Purchase Requisition Nos");
            "Document Type"::"Store Return":
                EXIT(ANFSetup."Store Return Nos");
        END;
    end;

    /// <summary>
    /// Description for GetPostingNoSeriesCode.
    /// </summary>
    /// <returns>Return variable "Code[10]".</returns>
    local procedure GetPostingNoSeriesCode(): Code[10];
    begin
    end;

    /// <summary>
    /// Description for TestNoSeriesDate.
    /// </summary>
    /// <param name="No">Parameter of type Code[20].</param>
    /// <param name="NoSeriesCode">Parameter of type Code[10].</param>
    /// <param name="NoCapt">Parameter of type Text[1024].</param>
    /// <param name="NoSeriesCapt">Parameter of type Text[1024].</param>
    local procedure TestNoSeriesDate(No: Code[20]; NoSeriesCode: Code[10]; NoCapt: Text[1024]; NoSeriesCapt: Text[1024]);
    var
        NoSeries: Record "No. Series";
    begin
        IF (No <> '') AND (NoSeriesCode <> '') THEN BEGIN
            NoSeries.GET(NoSeriesCode);
            IF NoSeries."Date Order" THEN
                ERROR(
                  Text040,
                  FIELDCAPTION("Posting Date"), NoSeriesCapt, NoSeriesCode,
                  NoSeries.FIELDCAPTION("Date Order"), NoSeries."Date Order", "Document Type",
                  NoCapt, No);
        END;
    end;

    /// <summary>
    /// Description for ConfirmDeletion.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure ConfirmDeletion(): Boolean;
    begin
        /*PurchPost.TestDeleteHeader(
          Rec,PurchRcptHeader,PurchInvHeader,PurchCrMemoHeader,
          ReturnShptHeader,PurchInvHeaderPrepmt,PurchCrMemoHeaderPrepmt);
        IF PurchRcptHeader."No." <> '' THEN
          IF NOT CONFIRM(
               Text009 +
               Text010 +
               Text011,TRUE,
               PurchRcptHeader."No.")
          THEN
            EXIT;
        IF PurchInvHeader."No." <> '' THEN
          IF NOT CONFIRM(
               Text012 +
               Text013 +
               Text011,TRUE,
               PurchInvHeader."No.")
          THEN
            EXIT;
        IF PurchCrMemoHeader."No." <> '' THEN
          IF NOT CONFIRM(
               Text014 +
               Text015 +
               Text011,TRUE,
               PurchCrMemoHeader."No.")
          THEN
            EXIT;
        IF ReturnShptHeader."No." <> '' THEN
          IF NOT CONFIRM(
               Text029 +
               Text030 +
               Text011,TRUE,
               ReturnShptHeader."No.")
          THEN
            EXIT;
        IF "Prepayment No." <> '' THEN
          IF NOT CONFIRM(
               Text044 +
               Text045 +
               Text011,TRUE,
               PurchInvHeaderPrepmt."No.")
          THEN
            EXIT;
        IF "Prepmt. Cr. Memo No." <> '' THEN
          IF NOT CONFIRM(
               Text046 +
               Text047 +
               Text011,TRUE,
               PurchCrMemoHeaderPrepmt."No.")
          THEN
            EXIT;
        EXIT(TRUE);
        */

    end;

    /// <summary>
    /// Description for GetVend.
    /// </summary>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    local procedure GetVend(VendNo: Code[20]);
    begin
        IF VendNo <> Vend."No." THEN
            Vend.GET(VendNo);
    end;

    /// <summary>
    /// Description for ReqnLinesExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure ReqnLinesExist(): Boolean;
    begin
        ReqnLine.RESET;
        ReqnLine.SETRANGE("Document Type", "Document Type");
        ReqnLine.SETRANGE("Document No.", "No.");
        EXIT(ReqnLine.FINDFIRST);
    end;

    /// <summary>
    /// Description for ReqnDetailLinesExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure ReqnDetailLinesExist(): Boolean;
    begin
        PurchaseRequisitionDetail.RESET;
        PurchaseRequisitionDetail.SETRANGE("Document Type", "Document Type");
        PurchaseRequisitionDetail.SETRANGE("Document No.", "No.");
        EXIT(PurchaseRequisitionDetail.FINDFIRST);
    end;

    /// <summary>
    /// Description for RecreatePurchLines.
    /// </summary>
    /// <param name="ChangedFieldName">Parameter of type Text[100].</param>
    procedure RecreatePurchLines(ChangedFieldName: Text[100]);
    var
        ReqnLineTmp: Record "NFL Requisition Line" temporary;
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
        TempInteger: Record Integer temporary;
        ExtendedTextAdded: Boolean;
    begin
        IF ReqnLinesExist THEN BEGIN
            IF HideValidationDialog THEN
                Confirmed := TRUE
            ELSE
                Confirmed :=
                  CONFIRM(
                    Text016 +
                    Text004, FALSE, ChangedFieldName);
            IF Confirmed THEN BEGIN
                //DocDim.LOCKTABLE; // IE Table removed in the current version
                ReqnLine.LOCKTABLE;
                ItemChargeAssgntPurch.LOCKTABLE;
                MODIFY;

                ReqnLine.RESET;
                ReqnLine.SETRANGE("Document Type", "Document Type");
                ReqnLine.SETRANGE("Document No.", "No.");
                IF ReqnLine.FINDSET THEN BEGIN
                    REPEAT
                        ReqnLine.TESTFIELD("Quantity Received", 0);
                        ReqnLine.TESTFIELD("Quantity Invoiced", 0);
                        ReqnLine.TESTFIELD("Return Qty. Shipped", 0);
                        ReqnLine.CALCFIELDS("Reserved Qty. (Base)");
                        ReqnLine.TESTFIELD("Reserved Qty. (Base)", 0);
                        ReqnLine.TESTFIELD("Receipt No.", '');
                        ReqnLine.TESTFIELD("Return Shipment No.", '');
                        ReqnLine.TESTFIELD("Sales Order No.", '');
                        ReqnLine.TESTFIELD("Blanket Order No.", '');
                        ReqnLine.TESTFIELD("Prepmt. Amt. Inv.", 0);
                        ReqnLineTmp := ReqnLine;
                        IF ReqnLine.Nonstock THEN BEGIN
                            ReqnLine.Nonstock := FALSE;
                            ReqnLine.MODIFY;
                        END;
                        ReqnLineTmp.INSERT;
                    UNTIL ReqnLine.NEXT = 0;

                    ItemChargeAssgntPurch.SETRANGE("Document Type", "Document Type");
                    ItemChargeAssgntPurch.SETRANGE("Document No.", "No.");
                    IF ItemChargeAssgntPurch.FINDSET THEN BEGIN
                        REPEAT
                            TempItemChargeAssgntPurch.INIT;
                            TempItemChargeAssgntPurch := ItemChargeAssgntPurch;
                            TempItemChargeAssgntPurch.INSERT;
                        UNTIL ItemChargeAssgntPurch.NEXT = 0;
                        ItemChargeAssgntPurch.DELETEALL;
                    END;

                    ReqnLine.DELETEALL(TRUE);

                    ReqnLine.INIT;
                    ReqnLine."Line No." := 0;
                    ReqnLineTmp.FINDSET;
                    ExtendedTextAdded := FALSE;
                    REPEAT
                        IF ReqnLineTmp."Attached to Line No." = 0 THEN BEGIN
                            ReqnLine.INIT;
                            ReqnLine."Line No." := ReqnLine."Line No." + 10000;
                            ReqnLine.VALIDATE(Type, ReqnLineTmp.Type);
                            IF ReqnLineTmp."No." = '' THEN BEGIN
                                ReqnLine.VALIDATE(Description, ReqnLineTmp.Description);
                                ReqnLine.VALIDATE("Description 2", ReqnLineTmp."Description 2");
                            END ELSE BEGIN
                                ReqnLine.VALIDATE("No.", ReqnLineTmp."No.");
                                IF ReqnLine.Type <> ReqnLine.Type::" " THEN BEGIN
                                    ReqnLine.VALIDATE("Unit of Measure Code", ReqnLineTmp."Unit of Measure Code");
                                    ReqnLine.VALIDATE("Variant Code", ReqnLineTmp."Variant Code");
                                    IF (ReqnLineTmp."Job No." <> '') AND (ReqnLineTmp."Job Task No." <> '') THEN BEGIN
                                        ReqnLine.VALIDATE("Job No.", ReqnLineTmp."Job No.");
                                        ReqnLine.VALIDATE("Job Task No.", ReqnLineTmp."Job Task No.");
                                        ReqnLine."Job Line Type" := ReqnLineTmp."Job Line Type";
                                    END;
                                    IF ReqnLineTmp.Quantity <> 0 THEN
                                        ReqnLine.VALIDATE(Quantity, ReqnLineTmp.Quantity);
                                    ReqnLine."Sales Order No." := ReqnLineTmp."Sales Order No.";
                                    ReqnLine."Sales Order Line No." := ReqnLineTmp."Sales Order Line No.";
                                    ReqnLine."Drop Shipment" := ReqnLine."Sales Order Line No." <> 0;
                                    ReqnLine."Prod. Order No." := ReqnLineTmp."Prod. Order No.";
                                    ReqnLine."Routing No." := ReqnLineTmp."Routing No.";
                                    ReqnLine."Routing Reference No." := ReqnLineTmp."Routing Reference No.";
                                    ReqnLine."Operation No." := ReqnLineTmp."Operation No.";
                                    ReqnLine."Work Center No." := ReqnLineTmp."Work Center No.";
                                    ReqnLine."Prod. Order Line No." := ReqnLineTmp."Prod. Order Line No.";
                                    ReqnLine."Overhead Rate" := ReqnLineTmp."Overhead Rate";
                                END;
                            END;
                            ReqnLine.INSERT;
                            ExtendedTextAdded := FALSE;

                            IF ReqnLine.Type = ReqnLine.Type::Item THEN BEGIN
                                ClearItemAssgntPurchFilter(TempItemChargeAssgntPurch);
                                TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Type", ReqnLineTmp."Document Type");
                                TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. No.", ReqnLineTmp."Document No.");
                                TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Line No.", ReqnLineTmp."Line No.");
                                IF TempItemChargeAssgntPurch.FINDSET THEN BEGIN
                                    REPEAT
                                        IF NOT TempItemChargeAssgntPurch.MARK THEN BEGIN
                                            TempItemChargeAssgntPurch."Applies-to Doc. Line No." := ReqnLine."Line No.";
                                            TempItemChargeAssgntPurch.Description := ReqnLine.Description;
                                            TempItemChargeAssgntPurch.MODIFY;
                                            TempItemChargeAssgntPurch.MARK(TRUE);
                                        END;
                                    UNTIL TempItemChargeAssgntPurch.NEXT = 0;
                                END;
                            END;
                            IF ReqnLine.Type = ReqnLine.Type::"Charge (Item)" THEN BEGIN
                                TempInteger.INIT;
                                TempInteger.Number := ReqnLine."Line No.";
                                TempInteger.INSERT;
                            END;
                        END ELSE
                            IF NOT ExtendedTextAdded THEN BEGIN
                                //TransferExtendedText.PurchCheckIfAnyExtText(ReqnLine,TRUE);
                                //TransferExtendedText.InsertPurchExtText(ReqnLine);
                                ReqnLine.FINDLAST;
                                ExtendedTextAdded := TRUE;
                            END;
                    UNTIL ReqnLineTmp.NEXT = 0;

                    ClearItemAssgntPurchFilter(TempItemChargeAssgntPurch);
                    ReqnLineTmp.SETRANGE(Type, ReqnLine.Type::"Charge (Item)");
                    IF ReqnLineTmp.FINDSET THEN
                        REPEAT
                            TempItemChargeAssgntPurch.SETRANGE("Document Line No.", ReqnLineTmp."Line No.");
                            IF TempItemChargeAssgntPurch.FINDSET THEN BEGIN
                                REPEAT
                                    TempInteger.FINDFIRST;
                                    ItemChargeAssgntPurch.INIT;
                                    ItemChargeAssgntPurch := TempItemChargeAssgntPurch;
                                    ItemChargeAssgntPurch."Document Line No." := TempInteger.Number;
                                    ItemChargeAssgntPurch.VALIDATE("Unit Cost", 0);
                                    ItemChargeAssgntPurch.INSERT;
                                UNTIL TempItemChargeAssgntPurch.NEXT = 0;
                                TempInteger.DELETE;
                            END;
                        UNTIL ReqnLineTmp.NEXT = 0;

                    ReqnLineTmp.SETRANGE(Type);
                    ReqnLineTmp.DELETEALL;
                    ClearItemAssgntPurchFilter(TempItemChargeAssgntPurch);
                    TempItemChargeAssgntPurch.DELETEALL;
                END;
            END ELSE
                ERROR(
                  Text018, ChangedFieldName);
        END;
    end;

    procedure MessageIfPurchLinesExist(ChangedFieldName: Text[100]);
    begin
        IF ReqnLinesExist AND NOT HideValidationDialog THEN
            MESSAGE(
              Text019 +
              Text020,
              ChangedFieldName);
    end;

    procedure PriceMessageIfPurchLinesExist(ChangedFieldName: Text[100]);
    begin
        IF ReqnLinesExist AND NOT HideValidationDialog THEN
            MESSAGE(
              Text019 +
              Text021, ChangedFieldName);
    end;

    local procedure UpdateCurrencyFactor();
    begin
        IF "Currency Code" <> '' THEN BEGIN
            IF ("Document Type" IN ["Document Type"::"Store Requisition", "Document Type"::"HR Cash Voucher"]) AND
               ("Posting Date" = 0D)
            THEN
                CurrencyDate := WORKDATE
            ELSE
                CurrencyDate := "Posting Date";

            "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, "Currency Code");
        END ELSE
            "Currency Factor" := 0;
    end;

    local procedure ConfirmUpdateCurrencyFactor();
    begin
        IF HideValidationDialog THEN
            Confirmed := TRUE
        ELSE
            Confirmed := CONFIRM(Text022, FALSE);
        IF Confirmed THEN
            VALIDATE("Currency Factor")
        ELSE
            "Currency Factor" := xRec."Currency Factor";
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean);
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure UpdatePurchLines(ChangedFieldName: Text[100]);
    var
        UpdateConfirmed: Boolean;
    begin
        IF ReqnLinesExist THEN BEGIN

            IF NOT GUIALLOWED THEN
                UpdateConfirmed := TRUE
            ELSE
                CASE ChangedFieldName OF
                    FIELDCAPTION("Expected Receipt Date"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                    FIELDCAPTION("Requested Receipt Date"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                    FIELDCAPTION("Promised Receipt Date"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                    FIELDCAPTION("Lead Time Calculation"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                    FIELDCAPTION("Inbound Whse. Handling Time"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                    FIELDCAPTION("Prepayment %"):
                        UpdateConfirmed := CONFIRM(STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));

                END;
            // MAG 14TH SEPT. 2018
            ReqnLine.VALIDATE("Balance on Budget as at Date");
            ReqnLine.VALIDATE("Balance on Budget for the Year");
            ReqnLine.VALIDATE("Bal. on Budget for the Quarter");
            ReqnLine.VALIDATE("Bal. on Budget for the Month");
            // MAG - END.

            //DocDim.LOCKTABLE; IE table removed from the current version
            ReqnLine.LOCKTABLE;


            MODIFY;

            REPEAT
                xReqnLine := ReqnLine;
                CASE ChangedFieldName OF
                    FIELDCAPTION("Expected Receipt Date"):
                        IF UpdateConfirmed AND (ReqnLine."No." <> '') THEN
                            ReqnLine.VALIDATE("Expected Receipt Date", "Expected Receipt Date");
                    FIELDCAPTION("Currency Factor"):
                        IF ReqnLine.Type <> ReqnLine.Type::" " THEN
                            ReqnLine.VALIDATE("Direct Unit Cost");
                    FIELDCAPTION("Transaction Type"):
                        ReqnLine.VALIDATE("Transaction Type", "Transaction Type");
                    FIELDCAPTION("Transport Method"):
                        ReqnLine.VALIDATE("Transport Method", "Transport Method");
                    FIELDCAPTION("Entry Point"):
                        ReqnLine.VALIDATE("Entry Point", "Entry Point");
                    FIELDCAPTION(Area):
                        ReqnLine.VALIDATE(Area, Area);
                    FIELDCAPTION("Transaction Specification"):
                        ReqnLine.VALIDATE("Transaction Specification", "Transaction Specification");
                    FIELDCAPTION("Requested Receipt Date"):
                        IF UpdateConfirmed AND (ReqnLine."No." <> '') THEN
                            ReqnLine.VALIDATE("Requested Receipt Date", "Requested Receipt Date");
                    FIELDCAPTION("Prepayment %"):
                        IF ReqnLine."No." <> '' THEN
                            ReqnLine.VALIDATE("Prepayment %", "Prepayment %");
                    FIELDCAPTION("Promised Receipt Date"):
                        IF UpdateConfirmed AND (ReqnLine."No." <> '') THEN
                            ReqnLine.VALIDATE("Promised Receipt Date", "Promised Receipt Date");
                    FIELDCAPTION("Lead Time Calculation"):
                        IF UpdateConfirmed AND (ReqnLine."No." <> '') THEN
                            ReqnLine.VALIDATE("Lead Time Calculation", "Lead Time Calculation");
                    FIELDCAPTION("Inbound Whse. Handling Time"):
                        IF UpdateConfirmed AND (ReqnLine."No." <> '') THEN
                            ReqnLine.VALIDATE("Inbound Whse. Handling Time", "Inbound Whse. Handling Time");
                END;

                // MAG 14TH SEPT. 2018
                ReqnLine.VALIDATE("Balance on Budget as at Date");
                ReqnLine.VALIDATE("Balance on Budget for the Year");
                ReqnLine.VALIDATE("Bal. on Budget for the Quarter");
                ReqnLine.VALIDATE("Bal. on Budget for the Month");
                // MAG - END.

                ReqnLine.MODIFY(TRUE);
            //ReserveReqnLine.VerifyChange(ReqnLine,xReqnLine);

            UNTIL ReqnLine.NEXT = 0;
        END;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20]);
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin
        SourceCodeSetup.GET;
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(TableID, No, SourceCodeSetup.Purchases, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        IF (OldDimSetID <> "Dimension Set ID") AND PurchLinesExist THEN BEGIN
            MODIFY;
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        END;



        /*DimMgt.GetDefaultDim(
          TableID,No,SourceCodeSetup.Purchases,
          "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");

        IF ("No." <> '') AND ("Document Type"="Document Type"::"Store Requisition") THEN
          DimMgt.UpdateDocDefaultDim(
            DATABASE::"NFL Requisition Header",DocDim."Document Type"::"Store Requisition","No.",0,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");

        IF ("No." <> '') AND ("Document Type"="Document Type"::"Purchase Requisition") THEN
          DimMgt.UpdateDocDefaultDim(
            DATABASE::"NFL Requisition Header",DocDim."Document Type"::"Purchase Requisition","No.",0,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        //cmm 131109 store return dimensions
        IF ("No." <> '') AND ("Document Type"="Document Type"::"Store Return") THEN
          DimMgt.UpdateDocDefaultDim(
            DATABASE::"NFL Requisition Header",DocDim."Document Type"::"Store Return","No.",0,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        //end cmm
        */

    end;

    /// <summary>
    /// Description for ValidateShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <param name="ShortcutDimCode">Parameter of type Code[20].</param>
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify;

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify;
            if PurchLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    /// <summary>
    /// Description for ReceivedPurchLinesExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure "ReceivedPurchLinesExist`"(): Boolean;
    begin
        ReqnLine.RESET;
        ReqnLine.SETRANGE("Document Type", "Document Type");
        ReqnLine.SETRANGE("Document No.", "No.");
        ReqnLine.SETFILTER("Quantity Received", '<>0');
        EXIT(ReqnLine.FINDFIRST);
    end;

    /// <summary>
    /// Description for ReturnShipmentExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure ReturnShipmentExist(): Boolean;
    begin
        ReqnLine.RESET;
        ReqnLine.SETRANGE("Document Type", "Document Type");
        ReqnLine.SETRANGE("Document No.", "No.");
        ReqnLine.SETFILTER("Return Qty. Shipped", '<>0');
        EXIT(ReqnLine.FINDFIRST);
    end;

    /// <summary>
    /// Description for UpdateShipToAddress.
    /// </summary>
    local procedure UpdateShipToAddress();
    begin
        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
            EXIT;

        IF ("Location Code" <> '') AND
           Location.GET("Location Code") AND
           ("Sell-to Customer No." = '')
        THEN BEGIN
            "Ship-to Name" := Location.Name;
            "Ship-to Name 2" := Location."Name 2";
            "Ship-to Address" := Location.Address;
            "Ship-to Address 2" := Location."Address 2";
            "Ship-to City" := Location.City;
            "Ship-to Post Code" := Location."Post Code";
            "Ship-to County" := Location.County;
            "Ship-to Country/Region Code" := Location."Country/Region Code";
            "Ship-to Contact" := Location.Contact;
        END;

        IF ("Location Code" = '') AND
           ("Sell-to Customer No." = '')
        THEN BEGIN
            CompanyInfo.GET;
            "Ship-to Code" := '';
            "Ship-to Name" := CompanyInfo."Ship-to Name";
            "Ship-to Name 2" := CompanyInfo."Ship-to Name 2";
            "Ship-to Address" := CompanyInfo."Ship-to Address";
            "Ship-to Address 2" := CompanyInfo."Ship-to Address 2";
            "Ship-to City" := CompanyInfo."Ship-to City";
            "Ship-to Post Code" := CompanyInfo."Ship-to Post Code";
            "Ship-to County" := CompanyInfo."Ship-to County";
            "Ship-to Country/Region Code" := CompanyInfo."Ship-to Country/Region Code";
            "Ship-to Contact" := CompanyInfo."Ship-to Contact";
        END;
    end;

    /// <summary>
    /// Description for DeletePurchaseLines.
    /// </summary>
    local procedure DeletePurchaseLines();
    begin
        IF ReqnLine.FINDSET THEN BEGIN
            HandleItemTrackingDeletion;
            REPEAT
                ReqnLine.SuspendStatusCheck(TRUE);
                ReqnLine.DELETE(TRUE);
            UNTIL ReqnLine.NEXT = 0;
        END;
    end;

    /// <summary>
    /// Description for HandleItemTrackingDeletion.
    /// </summary>
    procedure HandleItemTrackingDeletion();
    var
        ReservEntry: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
    begin
        WITH ReservEntry DO BEGIN
            RESET;
            SETCURRENTKEY(
              "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
              "Source Batch Name", "Source Prod. Order Line", "Reservation Status");
            SETRANGE("Source Type", DATABASE::"NFL Requisition Line");
            SETRANGE("Source Subtype", "Document Type");
            SETRANGE("Source ID", "No.");
            SETRANGE("Source Batch Name", '');
            SETRANGE("Source Prod. Order Line", 0);
            SETFILTER("Item Tracking", '> %1', "Item Tracking"::None);
            IF ISEMPTY THEN
                EXIT;

            IF HideValidationDialog OR NOT GUIALLOWED THEN
                Confirmed := TRUE
            ELSE
                Confirmed := CONFIRM(Text041, FALSE, LOWERCASE(FORMAT("Document Type")), "No.");

            IF NOT Confirmed THEN
                ERROR('');

            IF FINDSET THEN
                REPEAT
                    ReservEntry2 := ReservEntry;
                    ReservEntry2.ClearItemTrackingFields;
                    ReservEntry2.MODIFY;
                UNTIL NEXT = 0;
        END;
    end;


    local procedure ClearItemAssgntPurchFilter(var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)");
    begin
        TempItemChargeAssgntPurch.SETRANGE("Document Line No.");
        TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Type");
        TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. No.");
        TempItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Line No.");
    end;

    /// <summary>
    /// Description for UpdateBuyFromCont.
    /// </summary>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    procedure UpdateBuyFromCont(VendorNo: Code[20]);
    var
        ContBusRel: Record "Contact Business Relation";
        Vend: Record Vendor;
    begin
        IF Vend.GET(VendorNo) THEN BEGIN
            IF Vend."Primary Contact No." <> '' THEN
                "Buy-from Contact No." := Vend."Primary Contact No."
            ELSE BEGIN
                ContBusRel.RESET;
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Vendor);
                ContBusRel.SETRANGE("No.", "Buy-from Vendor No.");
                IF ContBusRel.FINDFIRST THEN
                    "Buy-from Contact No." := ContBusRel."Contact No."
                ELSE
                    "Buy-from Contact No." := '';
            END;
            "Buy-from Contact" := Vend.Contact;
        END;
    end;

    /// <summary>
    /// Description for UpdatePayToCont.
    /// </summary>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    procedure UpdatePayToCont(VendorNo: Code[20]);
    var
        ContBusRel: Record "Contact Business Relation";
        Cont: Record "Contact";
        Vend: Record Vendor;
    begin
        IF Vend.GET(VendorNo) THEN BEGIN
            IF Vend."Primary Contact No." <> '' THEN
                "Pay-to Contact No." := Vend."Primary Contact No."
            ELSE BEGIN
                ContBusRel.RESET;
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Vendor);
                ContBusRel.SETRANGE("No.", "Pay-to Vendor No.");
                IF ContBusRel.FINDFIRST THEN
                    "Pay-to Contact No." := ContBusRel."Contact No."
                ELSE
                    "Pay-to Contact No." := '';
            END;
            "Pay-to Contact" := Vend.Contact;
        END;
    end;

    /// <summary>
    /// Description for UpdateBuyFromVend.
    /// </summary>
    /// <param name="ContactNo">Parameter of type Code[20].</param>
    procedure UpdateBuyFromVend(ContactNo: Code[20]);
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Vend: Record Vendor;
        Cont: Record Contact;
    begin
        IF Cont.GET(ContactNo) THEN BEGIN
            "Buy-from Contact No." := Cont."No.";
            IF Cont.Type = Cont.Type::Person THEN
                "Buy-from Contact" := Cont.Name
            ELSE
                IF Vend.GET("Buy-from Vendor No.") THEN
                    "Buy-from Contact" := Vend.Contact
                ELSE
                    "Buy-from Contact" := ''
        END ELSE BEGIN
            "Buy-from Contact" := '';
            EXIT;
        END;

        ContBusinessRelation.RESET;
        ContBusinessRelation.SETCURRENTKEY("Link to Table", "Contact No.");
        ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
        ContBusinessRelation.SETRANGE("Contact No.", Cont."Company No.");
        IF ContBusinessRelation.FINDFIRST THEN BEGIN
            IF ("Buy-from Vendor No." <> '') AND
               ("Buy-from Vendor No." <> ContBusinessRelation."No.")
            THEN
                ERROR(Text037, Cont."No.", Cont.Name, "Buy-from Vendor No.")
            ELSE
                IF "Buy-from Vendor No." = '' THEN BEGIN
                    SkipBuyFromContact := TRUE;
                    VALIDATE("Buy-from Vendor No.", ContBusinessRelation."No.");
                    SkipBuyFromContact := FALSE;
                END;
        END ELSE
            ERROR(Text039, Cont."No.", Cont.Name);

        IF ("Buy-from Vendor No." = "Pay-to Vendor No.") OR
           ("Pay-to Vendor No." = '')
        THEN
            VALIDATE("Pay-to Contact No.", "Buy-from Contact No.");
    end;

    /// <summary>
    /// Description for UpdatePayToVend.
    /// </summary>
    /// <param name="ContactNo">Parameter of type Code[20].</param>
    procedure UpdatePayToVend(ContactNo: Code[20]);
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Vend: Record Vendor;
        Cont: Record Contact;
    begin
        IF Cont.GET(ContactNo) THEN BEGIN
            "Pay-to Contact No." := Cont."No.";
            IF Cont.Type = Cont.Type::Person THEN
                "Pay-to Contact" := Cont.Name
            ELSE
                IF Vend.GET("Pay-to Vendor No.") THEN
                    "Pay-to Contact" := Vend.Contact
                ELSE
                    "Pay-to Contact" := '';
        END ELSE BEGIN
            "Pay-to Contact" := '';
            EXIT;
        END;

        ContBusinessRelation.RESET;
        ContBusinessRelation.SETCURRENTKEY("Link to Table", "Contact No.");
        ContBusinessRelation.SETRANGE("Link to Table", ContBusinessRelation."Link to Table"::Vendor);
        ContBusinessRelation.SETRANGE("Contact No.", Cont."Company No.");
        IF ContBusinessRelation.FINDFIRST THEN BEGIN
            IF "Pay-to Vendor No." = '' THEN BEGIN
                SkipPayToContact := TRUE;
                VALIDATE("Pay-to Vendor No.", ContBusinessRelation."No.");
                SkipPayToContact := FALSE;
            END ELSE
                IF "Pay-to Vendor No." <> ContBusinessRelation."No." THEN
                    ERROR(Text037, Cont."No.", Cont.Name, "Pay-to Vendor No.");
        END ELSE
            ERROR(Text039, Cont."No.", Cont.Name);
    end;

    /// <summary>
    /// Description for CreateInvtPutAwayPick.
    /// </summary>
    procedure CreateInvtPutAwayPick();
    var
        WhseRequest: Record "Warehouse Request";
    begin
        TESTFIELD(Status, Status::Released);

        WhseRequest.RESET;
        WhseRequest.SETCURRENTKEY("Source Document", "Source No.");
        CASE "Document Type" OF
            "Document Type"::"Purchase Requisition":
                WhseRequest.SETRANGE("Source Document", WhseRequest."Source Document"::"Purchase Order");
            "Document Type"::"Imprest Cash Voucher":
                WhseRequest.SETRANGE("Source Document", WhseRequest."Source Document"::"Purchase Return Order");
        END;
        WhseRequest.SETRANGE("Source No.", "No.");
        REPORT.RUNMODAL(REPORT::"Create Invt Put-away/Pick/Mvmt", TRUE, FALSE, WhseRequest);
    end;

    /// <summary>
    /// Description for ShowDocDim.
    /// </summary>
    procedure ShowDocDim();
    var
        OldDimSetID: Integer;
        CustomFunctionsAndEVents: Codeunit "Custom Functions And EVents";
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          CustomFunctionsAndEVents.EditDimensionSet2(
            "Dimension Set ID", STRSUBSTNO('%1 %2', "Document Type", "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        IF OldDimSetID <> "Dimension Set ID" THEN BEGIN
            MODIFY;
            IF PurchLinesExist THEN
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        END;


        /*DocDim.SETRANGE("Table ID",DATABASE::"NFL Requisition Header");
        IF "Document Type" = "Document Type"::"Store Requisition" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Store Requisition");
        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Purchase Requisition");

        //CMM 131109 show doc dimensions for the store return
        IF "Document Type" = "Document Type"::"Store Return" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Store Return");
        //end cmm

        DocDim.SETRANGE("Document No.","No.");
        DocDim.SETRANGE("Line No.",0);
        DocDims.SETTABLEVIEW(DocDim);
        DocDims.RUNMODAL;

        IF "Document Type" = "Document Type"::"Store Requisition" THEN
          GET("Document Type"::"Store Requisition","No.");
        IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
          GET("Document Type"::"Purchase Requisition","No.");
        IF "Document Type" = "Document Type"::"Store Return" THEN
          GET("Document Type"::"Store Return","No.");*/

        //GET("Document Type","No.");

    end;

    /// <summary>
    /// Description for SetAmountToApply.
    /// </summary>
    /// <param name="AppliesToDocNo">Parameter of type Code[20].</param>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    procedure SetAmountToApply(AppliesToDocNo: Code[20]; VendorNo: Code[20]);
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.SETCURRENTKEY("Document No.");
        VendLedgEntry.SETRANGE("Document No.", AppliesToDocNo);
        VendLedgEntry.SETRANGE("Vendor No.", VendorNo);
        VendLedgEntry.SETRANGE(Open, TRUE);
        IF VendLedgEntry.FINDFIRST THEN BEGIN
            IF VendLedgEntry."Amount to Apply" = 0 THEN BEGIN
                VendLedgEntry.CALCFIELDS("Remaining Amount");
                VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
            END ELSE
                VendLedgEntry."Amount to Apply" := 0;
            CODEUNIT.RUN(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);
        END;
    end;

    /// <summary>
    /// Description for SetShipToForSpecOrder.
    /// </summary>
    procedure SetShipToForSpecOrder();
    begin
        IF Location.GET("Location Code") THEN BEGIN
            "Ship-to Code" := '';
            "Ship-to Name" := Location.Name;
            "Ship-to Name 2" := Location."Name 2";
            "Ship-to Address" := Location.Address;
            "Ship-to Address 2" := Location."Address 2";
            "Ship-to City" := Location.City;
            "Ship-to Post Code" := Location."Post Code";
            "Ship-to County" := Location.County;
            "Ship-to Country/Region Code" := Location."Country/Region Code";
            "Ship-to Contact" := Location.Contact;
            "Location Code" := Location.Code;
        END ELSE BEGIN
            CompanyInfo.GET;
            "Ship-to Code" := '';
            "Ship-to Name" := CompanyInfo."Ship-to Name";
            "Ship-to Name 2" := CompanyInfo."Ship-to Name 2";
            "Ship-to Address" := CompanyInfo."Ship-to Address";
            "Ship-to Address 2" := CompanyInfo."Ship-to Address 2";
            "Ship-to City" := CompanyInfo."Ship-to City";
            "Ship-to Post Code" := CompanyInfo."Ship-to Post Code";
            "Ship-to County" := CompanyInfo."Ship-to County";
            "Ship-to Country/Region Code" := CompanyInfo."Ship-to Country/Region Code";
            "Ship-to Contact" := CompanyInfo."Ship-to Contact";
            "Location Code" := '';
        END;
    end;

    /// <summary>
    /// Description for JobUpdatePurchLines.
    /// </summary>
    procedure JobUpdatePurchLines();
    begin
        WITH ReqnLine DO BEGIN
            SETFILTER("Job No.", '<>%1', '');
            SETFILTER("Job Task No.", '<>%1', '');
            LOCKTABLE;
            IF FIND('-') THEN BEGIN
                REPEAT
                    JobSetCurrencyFactor;
                    VALIDATE(Quantity);
                    MODIFY;
                UNTIL NEXT = 0;
            END;
        END
    end;

    /// <summary>
    /// Description for GetPstdDocLinesToRevere.
    /// </summary>
    procedure GetPstdDocLinesToRevere();
    var
        PurchPostedDocLines: Page "Posted Purchase Document Lines";
    begin
        GetVend("Buy-from Vendor No.");
        //PurchPostedDocLines.SetToReqnHeader(Rec);
        PurchPostedDocLines.SETRECORD(Vend);
        PurchPostedDocLines.LOOKUPMODE := TRUE;
        IF PurchPostedDocLines.RUNMODAL = ACTION::LookupOK THEN
            // LF  PurchPostedDocLines.CopyLineToDoc;

            CLEAR(PurchPostedDocLines);
    end;

    /// <summary>
    /// Description for CalcInvDiscForHeader.
    /// </summary>
    procedure CalcInvDiscForHeader();
    var
        PurchaseInvDisc: Codeunit "Purch.-Calc.Discount";
    begin
        //PurchaseInvDisc.CalculateIncDiscForHeader(Rec);
    end;

    /// <summary>
    /// Description for UpdateValidityDate.
    /// </summary>
    procedure UpdateValidityDate();
    var
        NFLSetup: Record "General Ledger Setup";
    begin
        //CMM 120809 CALCULATE VALIDITY PERIOD
        NFLSetup.GET;
        IF "Document Type" = "Document Type"::"Store Requisition" THEN BEGIN
            IF FORMAT(NFLSetup."Store Req. Validity Period") <> '' THEN
                "Valid to Date" := CALCDATE(NFLSetup."Store Req. Validity Period", "Document Date");
        END
        ELSE
            IF "Document Type" = "Document Type"::"Purchase Requisition" THEN BEGIN
                IF FORMAT(NFLSetup."Purch. Req. Validity Period") <> '' THEN
                    "Valid to Date" := CALCDATE(NFLSetup."Purch. Req. Validity Period", "Document Date");
            END
            ELSE
                IF "Document Type" = "Document Type"::"Store Return" THEN BEGIN
                    IF FORMAT(NFLSetup."Store Return Validity Period") <> '' THEN
                        "Valid to Date" := CALCDATE(NFLSetup."Store Return Validity Period", "Document Date");
                END;
        //END CMM
    end;

    /// <summary>
    /// Description for CalcBudgetAndAmount.
    /// </summary>
    /// <param name="NFL Req. Header No.">Parameter of type Code[10].</param>
    procedure CalcBudgetAndAmount("NFL Req. Header No.": Code[10]);
    begin
    end;

    /// <summary>
    /// Description for LookupShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <param name="ShortcutDimCode">Parameter of type Code[20].</param>
    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        /*DimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
        IF "Line No." <> 0 THEN BEGIN
          IF "Document Type" = "Document Type"::"Store Requisition" THEN
                DimMgt.SaveDocDim(
                  DATABASE::"NFL Requisition Line",6,"Document No.",
                  "Line No.",FieldNumber,ShortcutDimCode)
          //cmm 161109 save the doc dims according to type in doc dim table
          ELSE IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                DimMgt.SaveDocDim(
                  DATABASE::"NFL Requisition Line",7,"Document No.",
                  "Line No.",FieldNumber,ShortcutDimCode)
          ELSE IF  "Document Type" = "Document Type"::"Store Return" THEN
                DimMgt.SaveDocDim(
                  DATABASE::"NFL Requisition Line",8,"Document No.",
                  "Line No.",FieldNumber,ShortcutDimCode);
          //end cmm
          MODIFY;
        END ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);*/

        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);

    end;

    /// <summary>
    /// Description for ShowShortcutDimCode.
    /// </summary>
    /// <param name="ShortcutDimCode">Parameter of type array[8] of Code[20].</param>
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20]);
    begin
        /*IF "Line No." <> 0 THEN BEGIN
          IF "Document Type" = "Document Type"::"Store Requisition" THEN
                DimMgt.ShowDocDim(
                  DATABASE::"NFL Requisition Line",6,"Document No.",
                  "Line No.",ShortcutDimCode)
          ELSE IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                DimMgt.ShowDocDim(
                  DATABASE::"NFL Requisition Line",7,"Document No.",
                  "Line No.",ShortcutDimCode)
          ELSE IF "Document Type" = "Document Type"::"Store Return" THEN
                DimMgt.ShowDocDim(
                  DATABASE::"NFL Requisition Line",8,"Document No.",
                  "Line No.",ShortcutDimCode)


        END ELSE
          DimMgt.ShowTempDim(ShortcutDimCode);*/

        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);

    end;

    /// <summary>
    /// Description for PurchLinesExist.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchLinesExist(): Boolean;
    begin
        NFLPurchLine.RESET;
        NFLPurchLine.SETRANGE("Document Type", "Document Type");
        NFLPurchLine.SETRANGE("Document No.", "No.");
        EXIT(NFLPurchLine.FINDFIRST);
    end;

    /// <summary>
    /// Description for UpdateAllLineDim.
    /// </summary>
    /// <param name="NewParentDimSetID">Parameter of type Integer.</param>
    /// <param name="OldParentDimSetID">Parameter of type Integer.</param>
    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer);
    var
        NewDimSetID: Integer;
        ReceivedShippedItemLineDimChangeConfirmed: Boolean;
    begin
        // Update all lines with changed dimensions.

        IF NewParentDimSetID = OldParentDimSetID THEN
            EXIT;
        IF NOT CONFIRM('You may have changed a dimension.\\Do you want to update the lines?') THEN
            EXIT;

        NFLPurchLine.RESET;
        NFLPurchLine.SETRANGE("Document Type", "Document Type");
        NFLPurchLine.SETRANGE("Document No.", "No.");
        NFLPurchLine.LOCKTABLE;
        IF NFLPurchLine.FIND('-') THEN
            REPEAT
                NewDimSetID := DimMgt.GetDeltaDimSetID(NFLPurchLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                IF NFLPurchLine."Dimension Set ID" <> NewDimSetID THEN BEGIN
                    NFLPurchLine."Dimension Set ID" := NewDimSetID;

                    /*IF NOT HideValidationDialog AND GUIALLOWED THEN
                      VerifyReceivedShippedItemLineDimChange(ReceivedShippedItemLineDimChangeConfirmed);*/

                    DimMgt.UpdateGlobalDimFromDimSetID(
                      NFLPurchLine."Dimension Set ID", NFLPurchLine."Shortcut Dimension 1 Code", NFLPurchLine."Shortcut Dimension 2 Code");
                    NFLPurchLine.MODIFY;
                END;
            UNTIL NFLPurchLine.NEXT = 0;

    end;

    /// <summary>
    /// Description for CreateDimension.
    /// </summary>
    /// <param name="Type1">Parameter of type Integer.</param>
    /// <param name="No1">Parameter of type Code[20].</param>
    procedure CreateDimension(Type1: Integer; No1: Code[20]);
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin

        SourceCodeSetup.GET;
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.GetDefaultDimID(TableID, No, SourceCodeSetup."NFL Requisition Header", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        IF (OldDimSetID <> "Dimension Set ID") AND ReqnLinesExist THEN BEGIN
            MODIFY;
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        END;
    end;

    /// <summary>
    /// Description for ---MAG.
    /// </summary>
    local procedure "---MAG---"();
    begin
    end;

    /// <summary>
    /// Description for UpdateAllLineBudget.
    /// </summary>
    /// <param name="BudgetCode">Parameter of type Code[10].</param>
    local procedure UpdateAllLineBudget(BudgetCode: Code[10]);
    var
        NewBudgetCode: Code[10];
        lvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
        // Update all lines with changed budget code.

        lvNFLRequisitionLine.RESET;
        lvNFLRequisitionLine.SETRANGE("Document No.", "No.");
        lvNFLRequisitionLine.LOCKTABLE;
        IF lvNFLRequisitionLine.FIND('-') THEN
            REPEAT
                lvNFLRequisitionLine."Budget Code" := BudgetCode;
                lvNFLRequisitionLine."Accounting Period Start Date" := "Accounting Period Start Date";
                lvNFLRequisitionLine."Accounting Period End Date" := "Accounting Period End Date";

                lvNFLRequisitionLine."Fiscal Year Start Date" := "Fiscal Year Start Date";
                lvNFLRequisitionLine."Fiscal Year End Date" := "Fiscal Year End Date";

                lvNFLRequisitionLine."Filter to Date Start Date" := "Filter to Date Start Date";
                lvNFLRequisitionLine."Filter to Date End Date" := "Filter to Date End Date";

                lvNFLRequisitionLine."Quarter Start Date" := "Quarter Start Date";
                lvNFLRequisitionLine."Quarter End Date" := "Quarter End Date";

                lvNFLRequisitionLine.MODIFY;
            UNTIL lvNFLRequisitionLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for GetFiscalYearAndAccountingPeriod.
    /// </summary>
    /// <param name="parDate">Parameter of type Date.</param>
    local procedure GetFiscalYearAndAccountingPeriod(var parDate: Date);
    var
        lvAccountingPeriod: Record "Accounting Period";
        lvAccountingPeriod2: Record "Accounting Period";
        lvStartingDate: Date;
        lvEndingDate: Date;
        NewDate: Date;
        lvFiscalYearStartingDate: Date;
        lvFiscalYearEndingDate: Date;
        lvFound: Boolean;
        lvQtrOneStartDate: Date;
        lvQtrTwoStartDate: Date;
        lvQtrThreeStartDate: Date;
        lvQtrFourStartDate: Date;
        DateStart: Date;
        DateEnd: Date;
        lvQtrStartDate: Date;
        lvQtrEndDate: Date;
        lvQtrFound: Boolean;
    begin
        // MAG 2ND AUG. 2018 - BEGIN
        lvStartingDate := DMY2DATE(1, DATE2DMY(parDate, 2), DATE2DMY(parDate, 3));
        lvEndingDate := CALCDATE('<CM>', parDate);
        VALIDATE("Accounting Period Start Date", lvStartingDate);
        VALIDATE("Accounting Period End Date", lvEndingDate);
        //VALIDATE("Accounting Period", FORMAT(lvStartingDate) + '..' + FORMAT(lvEndingDate));

        // Get Fiscal Year Start Date basing on the posting date entered.
        lvAccountingPeriod2.SETFILTER("Starting Date", '<=%1', lvStartingDate);
        IF lvAccountingPeriod2.FIND('-') THEN BEGIN
            REPEAT
                IF lvAccountingPeriod2."New Fiscal Year" = TRUE THEN BEGIN
                    lvFiscalYearStartingDate := lvAccountingPeriod2."Starting Date";
                END;
            UNTIL lvAccountingPeriod2.NEXT = 0;
        END ELSE
            ERROR('There is no accounting period in the selected posting date');


        // Get Fiscal Year End Date basing on the posting date entered.
        lvAccountingPeriod.SETFILTER("Starting Date", '>=%1', lvStartingDate);
        IF lvAccountingPeriod.FIND('-') THEN BEGIN
            REPEAT
                // The second condition prevents from having a fiscal year of one month. e.g. if the specified date falls in the month of July
                IF (lvAccountingPeriod."New Fiscal Year" = TRUE)
                AND (lvAccountingPeriod."Starting Date" <> lvFiscalYearStartingDate)
                THEN BEGIN
                    lvFiscalYearEndingDate := CALCDATE('-1D', lvAccountingPeriod."Starting Date"); // end of the previous month.
                    lvFound := TRUE;
                END;
            UNTIL lvFound OR (lvAccountingPeriod.NEXT = 0);
        END ELSE
            ERROR('There is no accounting period in the selected posting date');

        VALIDATE("Filter to Date Start Date", lvFiscalYearStartingDate);
        VALIDATE("Filter to Date End Date", parDate);

        VALIDATE("Fiscal Year Start Date", lvFiscalYearStartingDate);
        VALIDATE("Fiscal Year End Date", lvFiscalYearEndingDate);

        //VALIDATE("Filter to Date", FORMAT(lvFiscalYearStartingDate) + '..'+ FORMAT(parDate)); // Filter to date starts from the begining of the fiscal year to the posting date
        //VALIDATE("Fiscal Year", FORMAT(lvFiscalYearStartingDate) + '..' + FORMAT(lvFiscalYearEndingDate));

        // Get Quarter in which a date falls.
        DateStart := lvFiscalYearStartingDate;
        DateEnd := lvFiscalYearEndingDate;

        // Loop all Quarters and find where the posting date falls.
        WHILE (DateStart < DateEnd) AND (lvQtrFound = FALSE) DO BEGIN
            IF (parDate >= DateStart) AND (parDate <= CALCDATE('3M', DateStart)) THEN BEGIN
                lvQtrStartDate := DateStart;
                lvQtrEndDate := CALCDATE('3M', DateStart);
                lvQtrEndDate := CALCDATE('-1D', lvQtrEndDate);
                VALIDATE("Quarter Start Date", lvQtrStartDate);
                VALIDATE("Quarter End Date", lvQtrEndDate);
                // VALIDATE(Quarter, FORMAT(lvQtrStartDate) + '..' + FORMAT(lvQtrEndDate));
                lvQtrFound := TRUE;
            END;
            DateStart := CALCDATE('3M', DateStart);
        END;

        // MAG - END.
    end;

    local procedure UpdateAllLineDateFilters(PostingDate: Date);
    var
        NewBudgetCode: Code[10];
        lvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
        // Update all lines with changed budget code.

        lvNFLRequisitionLine.RESET;
        lvNFLRequisitionLine.SETRANGE("Document No.", "No.");
        lvNFLRequisitionLine.LOCKTABLE;
        IF lvNFLRequisitionLine.FIND('-') THEN
            REPEAT
                GetFiscalYearAndAccountingPeriod(PostingDate);
                lvNFLRequisitionLine."Accounting Period Start Date" := "Accounting Period Start Date"; // Month in which the posting date falls.
                lvNFLRequisitionLine."Accounting Period End Date" := "Accounting Period End Date";
                lvNFLRequisitionLine."Fiscal Year Start Date" := "Fiscal Year Start Date";    // Fiscal Year
                lvNFLRequisitionLine."Fiscal Year End Date" := "Fiscal Year End Date";
                lvNFLRequisitionLine."Filter to Date Start Date" := "Filter to Date Start Date";   // From Start of Fiscal Year to the Posting Date
                lvNFLRequisitionLine."Filter to Date End Date" := "Filter to Date End Date";
                lvNFLRequisitionLine."Quarter Start Date" := "Quarter Start Date"; // Quarter in which the posting date falls.
                lvNFLRequisitionLine."Quarter End Date" := "Quarter End Date";
                lvNFLRequisitionLine.VALIDATE("Accounting Period Start Date");
                lvNFLRequisitionLine.VALIDATE("Accounting Period End Date");
                lvNFLRequisitionLine.VALIDATE("Filter to Date Start Date");
                lvNFLRequisitionLine.VALIDATE("Filter to Date End Date");
                lvNFLRequisitionLine.VALIDATE("Fiscal Year Start Date");
                lvNFLRequisitionLine.VALIDATE("Fiscal Year End Date");
                lvNFLRequisitionLine.VALIDATE("Quarter Start Date");
                lvNFLRequisitionLine.VALIDATE("Quarter End Date");
                lvNFLRequisitionLine.MODIFY;
            UNTIL lvNFLRequisitionLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for ReverseCommitment.
    /// </summary>
    /// <param name="NFLRequisitionLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="DocumentStatus">Parameter of type Code[20].</param>
    procedure ReverseCommitment(var NFLRequisitionLine: Record "NFL Requisition Line"; DocumentStatus: Code[20]);
    begin
        // SEJ 13th FEB. 2019, Reverse out commitment.
        gvCommitmentEntry.SETRANGE("Entry No.", NFLRequisitionLine."Commitment Entry No.");
        IF gvCommitmentEntry.FIND('-') THEN BEGIN
            IF NOT lastCommitmentEntry.FINDLAST THEN
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
            ELSE
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;
            // reversedCommitmentEntry.INIT;
            reversedCommitmentEntry := lastCommitmentEntry;
            reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
            reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
            reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
            reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
            reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
            reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
            reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
            reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
            reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
            reversedCommitmentEntry.Quantity := 1 * gvCommitmentEntry.Quantity;
            reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
            reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
            reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
            reversedCommitmentEntry.Reversed := TRUE;
            reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
            reversedCommitmentEntry."User ID" := USERID;
            reversedCommitmentEntry."Source Code" := DocumentStatus;
            reversedCommitmentEntry.INSERT;
            gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
            gvCommitmentEntry."Document Type" := reversedCommitmentEntry."Document Type";
            gvCommitmentEntry.MODIFY;
        END;
        // MAG - END.
    end;

    /// <summary>
    /// Description for StorePurchDocument.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="InteractionExist">Parameter of type Boolean.</param>
    procedure StorePurchDocument(var PurchHeader: Record "NFL Requisition Header");
    begin
        PurchHeader.TestField("Converted to Order", true);
        PurchHeader.TestField(Commited, true);
        PurchHeader.Validate(Archieved, true);
        PurchHeader.Modify();
        Message('Purchase Requisition %1 has been archived Successfully.', PurchHeader."No.");
    end;

    /// <summary>
    /// StorePurchDocumentModified.
    /// </summary>
    /// <param name="PurchHeader">VAR Record "NFL Requisition Header".</param>
    /// <param name="InteractionExist">Boolean.</param>
    procedure StorePurchDocumentModified(var PurchHeader: Record "NFL Requisition Header"; InteractionExist: Boolean);
    var
        PurchLine: Record "NFL Requisition Line";
        // PurchHeaderArchive: Record "NFL Requisition Header Archive";
        // PurchLineArchive: Record "NFL Requisition Line Archive";
        NFLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        // PurchHeaderArchive.INIT;
        // PurchHeaderArchive.TRANSFERFIELDS(PurchHeader);
        // PurchHeaderArchive."Archived By" := USERID;
        // PurchHeaderArchive."Date Archived" := WORKDATE;
        // PurchHeaderArchive."Time Archived" := TIME;
        // PurchHeaderArchive."Version No." := GetNextVersionNomodified(
        //   DATABASE::"NFL Requisition Header", PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Doc. No. Occurrence");
        // PurchHeaderArchive."Interaction Exist" := InteractionExist;
        // IF PurchHeader."Document Type" = PurchHeader."Document Type"::"Store Requisition" THEN BEGIN
        //     NFLSetup.GET;
        //     NFLSetup.TESTFIELD("Store Req. Archive No. Series");
        //     PurchHeaderArchive."Archive No." := NoSeriesMgt.GetNextNo(NFLSetup."Store Req. Archive No. Series", TODAY, TRUE);
        //     PurchHeaderArchive."Created from" := PurchHeader."Document Type"::"Store Requisition";
        // END;

        // IF PurchHeader."Document Type" = PurchHeader."Document Type"::"Store Return" THEN BEGIN
        //     NFLSetup.GET;
        //     NFLSetup.TESTFIELD(NFLSetup."Store Return Archive No series");
        //     PurchHeaderArchive."Archive No." := NoSeriesMgt.GetNextNo(NFLSetup."Store Return Archive No series", TODAY, TRUE);
        //     PurchHeaderArchive."Created from" := PurchHeader."Document Type"::"Store Return";
        // END;

        // //csm
        // PurchHeaderArchive.INSERT;

        // StoreDocDim(
        //   DATABASE::"NFL Requisition Header", PurchHeader."Document Type",
        //   PurchHeader."No.", 0, PurchHeader."Doc. No. Occurrence", PurchHeaderArchive."Version No.",
        //    DATABASE::"NFL Requisition Header Archive");

        // StorePurchDocumentComments(
        //   PurchHeader."Document Type", PurchHeader."No.",
        //   PurchHeader."Doc. No. Occurrence", PurchHeaderArchive."Version No.");

        // PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
        // PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        // IF PurchLine.FINDSET THEN
        //     REPEAT
        //         WITH PurchLineArchive DO BEGIN
        //             INIT;
        //             TRANSFERFIELDS(PurchLine);
        //             "Doc. No. Occurrence" := PurchHeader."Doc. No. Occurrence";
        //             "Version No." := PurchHeaderArchive."Version No.";
        //             PurchLineArchive."Archive No." := PurchHeaderArchive."Archive No.";
        //             IF PurchLineArchive."Archive No." <> '' THEN BEGIN
        //                 IF (PurchHeader."Document Type" = PurchHeader."Document Type"::"Purchase Requisition") THEN BEGIN
        //                     PurchLineArchive."Transfer to Item Jnl" := FALSE;
        //                     IF PurchLine."Make Purchase Req." THEN BEGIN
        //                         PurchLine."Transferred To Purch. Req." := TRUE;
        //                         PurchLine."Qty To Make Purch. Req." := 0;
        //                     END;
        //                     PurchLine."Make Purchase Req." := FALSE;
        //                     PurchLine.MODIFY;

        //                 END;
        //             END;
        //             INSERT;
        //             StoreDocDim(
        //               DATABASE::"NFL Requisition Line", PurchLine."Document Type", PurchLine."Document No.",
        //               PurchLine."Line No.", PurchHeader."Doc. No. Occurrence", "Version No.",
        //                DATABASE::"NFL Requisition Line Archive");
        //         END;
        //         ReverseCommitment(PurchLine, FORMAT(PurchHeader."Document Type"));
        //     UNTIL PurchLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for GetNextVersionNo.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition".</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <returns>Return variable "Integer".</returns>
    procedure GetNextVersionNo(TableId: Integer; DocType: Option "Store Requisition","Purchase Requisition"; DocNo: Code[20]; DocNoOccurrence: Integer): Integer;
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    // PurchHeaderArchive: Record "NFL Requisition Header Archive";
    begin
        CASE TableId OF
            DATABASE::"Sales Header":
                BEGIN
                    SalesHeaderArchive.LOCKTABLE;
                    SalesHeaderArchive.SETRANGE("Document Type", DocType);
                    SalesHeaderArchive.SETRANGE("No.", DocNo);
                    SalesHeaderArchive.SETRANGE("Doc. No. Occurrence", DocNoOccurrence);
                    IF SalesHeaderArchive.FINDLAST THEN
                        EXIT(SalesHeaderArchive."Version No." + 1)
                    ELSE
                        EXIT(1);
                END;
            DATABASE::"NFL Requisition Header":
                BEGIN
                    // PurchHeaderArchive.LockTable();
                    // PurchHeaderArchive.SetRange("Document Type", DocType);
                    // PurchHeaderArchive.SetRange("No.", DocNo);
                    // PurchHeaderArchive.SetRange("Doc. No. Occurrence", DocNoOccurrence);
                    // if PurchHeaderArchive.FindLast then
                    //     exit(PurchHeaderArchive."Version No." + 1);

                    // exit(1);
                END;
        END;
    end;

    /// <summary>
    /// GetNextVersionNomodified.
    /// </summary>
    /// <param name="TableId">Integer.</param>
    /// <param name="DocType">Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order".</param>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocNoOccurrence">Integer.</param>
    /// <returns>Return variable VersionNo of type Integer.</returns>
    procedure GetNextVersionNomodified(TableId: Integer; DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocNo: Code[20]; DocNoOccurrence: Integer) VersionNo: Integer
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    // PurchHeaderArchive: Record "NFL Requisition Header Archive";
    begin
        case TableId of
            DATABASE::"Sales Header":
                begin
                    SalesHeaderArchive.LockTable();
                    SalesHeaderArchive.SetRange("Document Type", DocType);
                    SalesHeaderArchive.SetRange("No.", DocNo);
                    SalesHeaderArchive.SetRange("Doc. No. Occurrence", DocNoOccurrence);
                    if SalesHeaderArchive.FindLast then
                        exit(SalesHeaderArchive."Version No." + 1);

                    exit(1);
                end;
            DATABASE::"NFL Requisition Header":
                begin
                    // PurchHeaderArchive.LockTable();
                    // PurchHeaderArchive.SetRange("Document Type", DocType);
                    // PurchHeaderArchive.SetRange("No.", DocNo);
                    // PurchHeaderArchive.SetRange("Doc. No. Occurrence", DocNoOccurrence);
                    // if PurchHeaderArchive.FindLast then
                    //     exit(PurchHeaderArchive."Version No." + 1);

                    // exit(1);
                end;
            else begin
                OnGetNextVersionNo(TableId, DocType, DocNo, DocNoOccurrence, VersionNo);
                exit(VersionNo)
            end;
        end;
    end;


    /// <summary>
    /// Description for StoreDocDim.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <param name="VersionNo">Parameter of type Integer.</param>
    /// <param name="NewTableID">Parameter of type Integer.</param>
    procedure StoreDocDim(TableId: Integer; DocType: Option; DocNo: Code[20]; LineNo: Integer; DocNoOccurrence: Integer; VersionNo: Integer; NewTableID: Integer);
    begin
    end;

    /// <summary>
    /// Description for StorePurchDocumentComments.
    /// </summary>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <param name="VersionNo">Parameter of type Integer.</param>
    local procedure StorePurchDocumentComments(DocType: Option; DocNo: Code[20]; DocNoOccurrence: Integer; VersionNo: Integer);
    var
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        //ERROR('%1',DocType);
        IF DocType = 1 THEN
            PurchCommentLine.SETRANGE("Document Type", PurchCommentLine."Document Type"::"Posted Return Shipment");

        IF DocType = 0 THEN
            PurchCommentLine.SETRANGE("Document Type", PurchCommentLine."Document Type"::"Posted Credit Memo");

        //PurchCommentLine.SETRANGE("Document Type",DocType);
        PurchCommentLine.SETRANGE("No.", DocNo);
        IF PurchCommentLine.FINDSET THEN
            REPEAT
                PurchCommentLineArch.INIT;
                PurchCommentLineArch.TRANSFERFIELDS(PurchCommentLine);
                PurchCommentLineArch."Doc. No. Occurrence" := DocNoOccurrence;
                PurchCommentLineArch."Version No." := VersionNo;
                PurchCommentLineArch.INSERT;
            UNTIL PurchCommentLine.NEXT = 0;
    end;

    /// <summary>
    /// CreatePurchaseRequisitionCommitmentEntries.
    /// </summary>
    procedure CreatePurchaseRequisitionCommitmentEntries()
    var
        Text001: Label 'There is nothing to release for %1 %2.';
        PurchSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
        WhsePurchRelease: Codeunit "Whse.-Purch. Release";
        Text002: Label 'This document can only be released when the approval process is complete.';
        Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
        "---MAG---": Integer;
        ApprovalEntry: Record "Approval Entry";
        CommitmentEntry: Record "Commitment Entry";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        // gvCommitmentEntry: Record "Commission Class";
        gvPurchLine: Record "Purchase Line";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        NFLRequisitionLine: Record "NFL Requisition Line";
        gvNFLRequisitionLine: Record "NFL Requisition Line";
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        PurchLine: Record "NFL Requisition Line";
        TempVATAmountLine0: Record "VAT Amount Line" temporary;
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        NotOnlyDropShipment: Boolean;
        "===cmm==odc reservation": Integer;
        ReqLine: Record "NFL Requisition Line";
        ReserveMgt: Codeunit "Reservation Management";
        // ReserveMgtMod: Codeunit "Reservation Management Copy";
        FullAutoReservation: Boolean;
        Item2: Record Item;
        GLAccount: Record "G/L Account";
    begin
        NFLRequisitionLine.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
        NFLRequisitionLine.SETRANGE("Document No.", Rec."No.");
        // NFLRequisitionLine.SetRange(NFLRequisitionLine.Convert, true);
        NFLRequisitionLine.SetRange(NFLRequisitionLine.Committed, false);
        NFLRequisitionLine.SETFILTER("Commitment Entry No.", '%1', 0);
        IF NFLRequisitionLine.FINDFIRST THEN
            REPEAT
                IF NOT CommitmentEntry.FINDLAST THEN
                    CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1
                ELSE
                    CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1;
                CommitmentEntry.INIT;
                IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::"G/L Account" THEN BEGIN
                    GLAccount.SETRANGE("No.", NFLRequisitionLine."No.");
                    GLAccount.SETRANGE("Prepayment Account", TRUE);
                    IF GLAccount.FIND('-') THEN BEGIN
                        CommitmentEntry."G/L Account No." := NFLRequisitionLine."Control Account";
                        CommitmentEntry."Prepayment Commitment" := TRUE;
                    END ELSE
                        CommitmentEntry."G/L Account No." := NFLRequisitionLine."No.";
                END ELSE
                    IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::Item THEN BEGIN
                        Item.SETRANGE("No.", NFLRequisitionLine."No.");
                        IF Item.FINDFIRST THEN
                            GeneralPostingSetup.SETRANGE("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                        IF GeneralPostingSetup.FINDFIRST THEN
                            CommitmentEntry."G/L Account No." := GeneralPostingSetup."Purch. Account"
                    END ELSE
                        IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::"Fixed Asset" THEN BEGIN
                            FADepreciationBook.SETRANGE("FA No.", NFLRequisitionLine."No.");
                            IF FADepreciationBook.FINDFIRST THEN
                                FAPostingGroup.SETRANGE(Code, FADepreciationBook."FA Posting Group");
                            IF FAPostingGroup.FINDFIRST THEN
                                CommitmentEntry."G/L Account No." := FAPostingGroup."Acquisition Cost Account";
                        END;
                CommitmentEntry.Description := NFLRequisitionLine.Description;
                CommitmentEntry.VALIDATE("Document Type", NFLRequisitionLine."Document Type");
                CommitmentEntry."Document No." := NFLRequisitionLine."Document No.";
                CommitmentEntry."Posting Date" := "Document Date";
                CommitmentEntry.TESTFIELD("Posting Date");
                CommitmentEntry."Dimension Set ID" := NFLRequisitionLine."Dimension Set ID";
                CommitmentEntry."Global Dimension 1 Code" := NFLRequisitionLine."Shortcut Dimension 1 Code";
                CommitmentEntry."Global Dimension 2 Code" := NFLRequisitionLine."Shortcut Dimension 2 Code";
                CommitmentEntry.Amount := NFLRequisitionLine.Quantity * NFLRequisitionLine."Unit Cost (LCY)";
                CommitmentEntry."Source Code" := 'Released';
                CommitmentEntry."User ID" := USERID;

                IF CommitmentEntry.Amount > 0 THEN
                    CommitmentEntry."Debit Amount" := CommitmentEntry.Amount
                ELSE
                    CommitmentEntry."Credit Amount" := CommitmentEntry.Amount;
                GeneralLedgerSetup.GET;
                CurrencyFactor := CurrencyExchangeRate.ExchangeRate("Posting Date", GeneralLedgerSetup."Additional Reporting Currency");
                CommitmentEntry."Additional-Currency Amount" := ROUND(CommitmentEntry.Amount * CurrencyFactor, Currency."Amount Rounding Precision");
                IF CommitmentEntry."Additional-Currency Amount" > 0 THEN
                    CommitmentEntry."Add.-Currency Debit Amount" := CommitmentEntry."Additional-Currency Amount"
                ELSE
                    CommitmentEntry."Add.-Currency Credit Amount" := CommitmentEntry."Additional-Currency Amount";
                CommitmentEntry.INSERT;
                NFLRequisitionLine."Commitment Entry No." := CommitmentEntry."Entry No.";
                NFLRequisitionLine.Committed := true;
                NFLRequisitionLine.MODIFY;
            UNTIL NFLRequisitionLine.NEXT = 0;
        Commited := TRUE;
        //END

        //PurchLine.SetPurchHeader(Rec);
        PurchLine.CalcVATAmountLines(0, Rec, PurchLine, TempVATAmountLine0);
        PurchLine.CalcVATAmountLines(1, Rec, PurchLine, TempVATAmountLine1);
        PurchLine.UpdateVATOnLines(0, Rec, PurchLine, TempVATAmountLine0);
        PurchLine.UpdateVATOnLines(1, Rec, PurchLine, TempVATAmountLine1);

        MODIFY(TRUE);
        //reserve items on release of document
        IF "Document Type" = "Document Type"::"Store Requisition" THEN BEGIN
            ReqLine.RESET;
            ReqLine.SETRANGE("Document Type", "Document Type");
            ReqLine.SETRANGE(ReqLine."Document No.", "No.");
            ReqLine.SETFILTER(Type, '%1', ReqLine.Type::Item);
            ReqLine.SETFILTER(ReqLine."No.", '<>%1', '');
            IF ReqLine.FINDFIRST THEN BEGIN
                REPEAT
                    Item2.GET(ReqLine."No.");
                    IF Item2.Reserve = Item2.Reserve::Always THEN BEGIN
                        IF ReqLine."Qty To Transfer to Item Jnl" <> 0 THEN BEGIN
                            // ReserveMgtMod.SetRequisitionLine(ReqLine);
                            FullAutoReservation := FALSE;
                            ReserveMgt.AutoReserve(FullAutoReservation, '', WORKDATE, ReqLine."Qty To Transfer to Item Jnl", 0);
                            CLEAR(ReserveMgt);
                        END;
                    END;
                UNTIL ReqLine.NEXT = 0;
            END;
        END;

    end;


    /// <summary>
    /// CheckBudget.
    /// </summary>
    procedure CheckBudget();
    begin
        // New vision requires that all requisition out of budget are escaladed to the CEO/CFO
        // for approval.
        TESTFIELD(Rec."Budget Code");
        TESTFIELD(Rec."Shortcut Dimension 1 Code");
    end;

    /// <summary>
    /// Description for ReversePurchaseRequisitionCommitmentEntries.
    /// </summary>
    local procedure ReversePurchaseRequisitionCommitmentEntries();
    var
        gvNFLRequisitionLine: Record "NFL Requisition Line";
    begin
        //Reverse commitment on converting requistion to order for a released purchase requisistion document.
        IF Rec.Commited = TRUE THEN BEGIN
            gvNFLRequisitionLine.SETRANGE("Document No.", Rec."No.");
            IF gvNFLRequisitionLine.FIND('-') THEN
                REPEAT
                    gvCommitmentEntry.SETRANGE(gvCommitmentEntry."Entry No.", gvNFLRequisitionLine."Commitment Entry No.");
                    IF gvCommitmentEntry.FIND('-') THEN
                        IF NOT lastCommitmentEntry.FINDLAST THEN
                            lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
                        ELSE
                            lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;
                    reversedCommitmentEntry.INIT;
                    reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
                    reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
                    reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
                    reversedCommitmentEntry."Document Type" := gvCommitmentEntry."Document Type";
                    reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
                    reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
                    reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
                    reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
                    reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
                    reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
                    reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
                    reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
                    reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
                    reversedCommitmentEntry."Additional-Currency Amount" := -1 * gvCommitmentEntry."Additional-Currency Amount";
                    reversedCommitmentEntry."Add.-Currency Debit Amount" := -1 * gvCommitmentEntry."Add.-Currency Debit Amount";
                    reversedCommitmentEntry."Add.-Currency Credit Amount" := -1 * gvCommitmentEntry."Add.-Currency Credit Amount";
                    reversedCommitmentEntry.Reversed := TRUE;
                    reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
                    reversedCommitmentEntry."User ID" := USERID;
                    reversedCommitmentEntry."Source Code" := 'converted to order';
                    gvCommitmentEntry.Reversed := TRUE;
                    gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
                    reversedCommitmentEntry.INSERT;
                    gvCommitmentEntry.MODIFY;
                    gvNFLRequisitionLine."Commitment Entry No." := 0; //Reset the commited purchase line back to zero.
                    gvNFLRequisitionLine.MODIFY;
                UNTIL gvNFLRequisitionLine.NEXT = 0;
        END;
        Rec.Commited := FALSE;
        //END
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var NFLRequisitionHeader: Record "NFL Requisition Header"; var xNFLRequisitionHeader: Record "NFL Requisition Header"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var NFLRequisitionHeader: Record "NFL Requisition Header"; xNFLRequisitionHeader: Record "NFL Requisition Header"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetNextVersionNo(TableId: Integer; DocType: Option; DocNo: Code[20]; DocNoOccurrence: Integer; var VersionNo: Integer)
    begin
    end;
}

