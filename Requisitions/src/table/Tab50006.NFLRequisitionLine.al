/// <summary>
/// Table NFL Requisition Line (ID 50067).
/// </summary>
table 50006 "NFL Requisition Line"
{
    // version NFL02.002

    Caption = 'NFL Requisition Line';
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
            Editable = true;
            TableRelation = Vendor;

            trigger OnValidate();
            begin
                "Pay-to Vendor No." := "Buy-from Vendor No.";
                IF "Buy-from Vendor No." <> '' THEN BEGIN
                    gvVendor.SETRANGE("No.", "Buy-from Vendor No.");
                    IF gvVendor.FINDFIRST THEN
                        VALIDATE("Gen. Bus. Posting Group", gvVendor."Gen. Bus. Posting Group");
                END ELSE
                    VALIDATE("Gen. Bus. Posting Group", '');
            end;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "NFL Requisition Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,"Fixed Asset","Charge (Item)";

            trigger OnValidate();
            begin
                GetReqnHeader;
                ApprovedByBudgetMonitorOfficer;

                TestStatusOpen;

                TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                TESTFIELD("Quantity Received", 0);
                TESTFIELD("Receipt No.", '');

                TESTFIELD("Return Qty. Shipped Not Invd.", 0);
                TESTFIELD("Return Qty. Shipped", 0);
                TESTFIELD("Return Shipment No.", '');

                TESTFIELD("Prepmt. Amt. Inv.", 0);

                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION(Type), "Sales Order No.");
                IF Type <> xRec.Type THEN BEGIN
                    IF Quantity <> 0 THEN BEGIN
                        //ReservePurchLine.VerifyChange(Rec,xRec);
                        CALCFIELDS("Reserved Qty. (Base)");
                        TESTFIELD("Reserved Qty. (Base)", 0);
                        //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    END;
                    IF xRec.Type IN [Type::Item, Type::"Fixed Asset"] THEN BEGIN
                        IF Quantity <> 0 THEN
                            ReqnHeader.TESTFIELD(Status, ReqnHeader.Status::Open);
                        DeleteItemChargeAssgnt("Document Type", "Document No.", "Line No.");
                    END;
                    IF xRec.Type = Type::"Charge (Item)" THEN
                        DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");
                END;
                TempPurchLine := Rec;
                //DimMgt.DeleteDocDim(DATABASE::"NFL Requisition Line","Document Type","Document No.","Line No.");
                INIT;
                Type := TempPurchLine.Type;
                "System-Created Entry" := TempPurchLine."System-Created Entry";
                VALIDATE("FA Posting Type");

                IF Type = Type::Item THEN
                    "Allow Item Charge Assignment" := TRUE
                ELSE
                    "Allow Item Charge Assignment" := FALSE;

                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::"Pending Approval");
                ReqnHeader2.VALIDATE("Budget Code");
            end;
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
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge";

            trigger OnValidate();
            var
                ICPartner: Record "IC Partner";
                // ItemCrossReference: Record "Item Cross Reference";
                PrepmtMgt: Codeunit "Prepayment Mgt.";
                GLAccount: Record "G/L Account";
            begin
                TestStatusOpen;
                TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                TESTFIELD("Quantity Received", 0);
                TESTFIELD("Receipt No.", '');

                TESTFIELD("Prepmt. Amt. Inv.", 0);

                TESTFIELD("Return Qty. Shipped Not Invd.", 0);
                TESTFIELD("Return Qty. Shipped", 0);
                TESTFIELD("Return Shipment No.", '');

                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("No."), "Sales Order No.");

                IF "Special Order" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("No."), "Special Order Sales No.");


                IF "No." <> xRec."No." THEN BEGIN
                    IF (Quantity <> 0) AND ItemExists(xRec."No.") THEN BEGIN
                        //ReservePurchLine.VerifyChange(Rec,xRec);
                        CALCFIELDS("Reserved Qty. (Base)");
                        TESTFIELD("Reserved Qty. (Base)", 0);
                        IF Type = Type::Item THEN;
                        //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    END;
                    IF Type = Type::Item THEN
                        DeleteItemChargeAssgnt("Document Type", "Document No.", "Line No.");
                    IF Type = Type::"Charge (Item)" THEN
                        DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");
                END;
                TempPurchLine := Rec;
                INIT;
                Type := TempPurchLine.Type;
                "No." := TempPurchLine."No.";
                IF "No." = '' THEN
                    EXIT;
                IF Type <> Type::" " THEN
                    Quantity := TempPurchLine.Quantity;

                "System-Created Entry" := TempPurchLine."System-Created Entry";

                //GetReqnHeader;
                //ReqnHeader.TESTFIELD("Buy-from Vendor No.");


                GetReqnHeader;
                IF (ReqnHeader."Document Type" = ReqnHeader."Document Type"::"Store Requisition") OR
                 (ReqnHeader."Document Type" = ReqnHeader."Document Type"::"Purchase Requisition") OR
                 (ReqnHeader."Document Type" = ReqnHeader."Document Type"::"Store Return") THEN BEGIN
                    "Request-By No." := ReqnHeader."Request-By No.";
                    "Request-By Name" := ReqnHeader."Request-By Name";
                    ReqnHeader.TESTFIELD("Request-By No.");
                END ELSE
                    ReqnHeader.TESTFIELD("Buy-from Vendor No.");

                "Buy-from Vendor No." := ReqnHeader."Buy-from Vendor No.";
                "Currency Code" := ReqnHeader."Currency Code";
                "Currency Factor" := ReqnHeader."Currency Factor";
                "Expected Receipt Date" := ReqnHeader."Expected Receipt Date";
                VALIDATE("Shortcut Dimension 1 Code", ReqnHeader."Shortcut Dimension 1 Code");
                VALIDATE("Shortcut Dimension 2 Code", ReqnHeader."Shortcut Dimension 2 Code");
                VALIDATE("Dimension Set ID", ReqnHeader."Dimension Set ID");
                VALIDATE("Budget Code", ReqnHeader."Budget Code");
                VALIDATE("Accounting Period Start Date", ReqnHeader."Accounting Period Start Date");
                VALIDATE("Accounting Period End Date", ReqnHeader."Accounting Period End Date");
                VALIDATE("Fiscal Year Start Date", ReqnHeader."Fiscal Year Start Date");
                VALIDATE("Fiscal Year End Date", ReqnHeader."Fiscal Year End Date");
                VALIDATE("Filter to Date Start Date", ReqnHeader."Filter to Date Start Date");
                VALIDATE("Filter to Date End Date", ReqnHeader."Filter to Date End Date");
                VALIDATE("Quarter Start Date", ReqnHeader."Quarter Start Date");
                VALIDATE("Quarter End Date", ReqnHeader."Quarter End Date");
                "Location Code" := ReqnHeader."Location Code";
                "Transaction Type" := ReqnHeader."Transaction Type";
                "Transport Method" := ReqnHeader."Transport Method";
                "Pay-to Vendor No." := ReqnHeader."Pay-to Vendor No.";
                "Gen. Bus. Posting Group" := ReqnHeader."Gen. Bus. Posting Group";
                "VAT Bus. Posting Group" := ReqnHeader."VAT Bus. Posting Group";
                "Entry Point" := ReqnHeader."Entry Point";
                Area := ReqnHeader.Area;
                "Transaction Specification" := ReqnHeader."Transaction Specification";
                "Tax Area Code" := ReqnHeader."Tax Area Code";
                "Tax Liable" := ReqnHeader."Tax Liable";
                IF NOT "System-Created Entry" AND ("Document Type" = "Document Type"::"Purchase Requisition") AND (Type <> Type::" ") THEN
                    "Prepayment %" := ReqnHeader."Prepayment %";
                "Prepayment Tax Area Code" := ReqnHeader."Tax Area Code";
                "Prepayment Tax Liable" := ReqnHeader."Tax Liable";
                "Responsibility Center" := ReqnHeader."Responsibility Center";

                "Requested Receipt Date" := ReqnHeader."Requested Receipt Date";
                "Promised Receipt Date" := ReqnHeader."Promised Receipt Date";
                "Inbound Whse. Handling Time" := ReqnHeader."Inbound Whse. Handling Time";
                "Order Date" := ReqnHeader."Order Date";
                UpdateLeadTimeFields;
                UpdateDates;

                CASE Type OF
                    Type::" ":
                        BEGIN
                            StdTxt.GET("No.");
                            Description := StdTxt.Description;
                            "Allow Item Charge Assignment" := FALSE;
                        END;
                    Type::"G/L Account":
                        BEGIN
                            GLAcc.GET("No.");
                            GLAcc.CheckGLAcc;
                            IF NOT "System-Created Entry" THEN
                                GLAcc.TESTFIELD("Direct Posting", TRUE);
                            "Control Account" := GLAcc."No."; // MAG
                            Description := GLAcc.Name;
                            "Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
                            "VAT Prod. Posting Group" := GLAcc."VAT Prod. Posting Group";
                            "Tax Group Code" := GLAcc."Tax Group Code";
                            "Allow Invoice Disc." := FALSE;
                            "Allow Item Charge Assignment" := FALSE;
                        END;
                    Type::Item:
                        BEGIN
                            GetItem;
                            GetGLSetup;
                            Item.TESTFIELD(Blocked, FALSE);
                            Item.TESTFIELD("Inventory Posting Group");
                            Item.TESTFIELD("Gen. Prod. Posting Group");

                            //MAG 21st June 2017, Populate Control Account for items. This is just used for commitment reporting
                            gvItem.SETRANGE("No.", "No.");
                            IF gvItem.FINDFIRST THEN BEGIN
                                gvItem.TESTFIELD("Gen. Prod. Posting Group");
                                gvGeneralPostingSetup.SETRANGE("Gen. Prod. Posting Group", gvItem."Gen. Prod. Posting Group");
                                gvGeneralPostingSetup.SETRANGE("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");
                                IF gvGeneralPostingSetup.FINDFIRST THEN
                                    "Control Account" := gvGeneralPostingSetup."Purch. Account";
                            END;
                            //MAG - END

                            "Posting Group" := Item."Inventory Posting Group";
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit Price (LCY)" := Item."Unit Price";
                            "Units per Parcel" := Item."Units per Parcel";
                            "Indirect Cost %" := Item."Indirect Cost %";
                            "Overhead Rate" := Item."Overhead Rate";
                            "Allow Invoice Disc." := Item."Allow Invoice Disc.";
                            "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                            "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
                            "Tax Group Code" := Item."Tax Group Code";
                            Nonstock := Item."Created From Nonstock Item";
                            "Item Category Code" := Item."Item Category Code";
                            //"Product Group Code" := Item."Product Group Code";
                            "Allow Item Charge Assignment" := TRUE;
                            //PrepmtMgt.SetPurchPrepaymentPct(Rec,ReqnHeader."Posting Date");

                            IF Item."Price Includes VAT" THEN BEGIN
                                IF NOT VATPostingSetup.GET(
                                     Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group")
                                THEN
                                    VATPostingSetup.INIT;
                                CASE VATPostingSetup."VAT Calculation Type" OF
                                    VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                                        VATPostingSetup."VAT %" := 0;
                                    VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                                        ERROR(
                                          Text002,
                                          VATPostingSetup.FIELDCAPTION("VAT Calculation Type"),
                                          VATPostingSetup."VAT Calculation Type");
                                END;
                                "Unit Price (LCY)" :=
                                  ROUND("Unit Price (LCY)" / (1 + VATPostingSetup."VAT %" / 100),
                                    GLSetup."Unit-Amount Rounding Precision");
                            END;

                            IF ReqnHeader."Language Code" <> '' THEN
                                GetItemTranslation;

                            "Unit of Measure Code" := Item."Purch. Unit of Measure";
                        END;
                    // Type::Resource: IEPOU
                    //     ERROR(Text003);
                    Type::"Fixed Asset":
                        BEGIN
                            FA.GET("No.");
                            FA.TESTFIELD(Inactive, FALSE);
                            FA.TESTFIELD(Blocked, FALSE);
                            GetFAPostingGroup;
                            Description := FA.Description;
                            "Description 2" := FA."Description 2";
                            "Allow Invoice Disc." := FALSE;
                            "Allow Item Charge Assignment" := FALSE;
                            // MAG 16th sept 2017, Get Commitment control account
                            gvFADepreciationBook.SETRANGE("FA No.", FA."No.");
                            IF gvFADepreciationBook.FINDFIRST THEN BEGIN
                                FAPostingGroup.SETRANGE(Code, gvFADepreciationBook."FA Posting Group");
                                IF FAPostingGroup.FINDFIRST THEN BEGIN
                                    IF ("FA Posting Type" = "FA Posting Type"::"Acquisition Cost") OR ("FA Posting Type" = "FA Posting Type"::" ") THEN
                                        "Control Account" := FAPostingGroup."Acquisition Cost Account"
                                    ELSE
                                        IF "FA Posting Type" = "FA Posting Type"::Maintenance THEN
                                            "Control Account" := FAPostingGroup."Maintenance Expense Account";
                                END;
                            END;
                            // MAG - END.
                        END;
                    Type::"Charge (Item)":
                        BEGIN
                            ItemCharge.GET("No.");
                            Description := ItemCharge.Description;
                            "Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
                            "VAT Prod. Posting Group" := ItemCharge."VAT Prod. Posting Group";
                            "Tax Group Code" := ItemCharge."Tax Group Code";
                            "Allow Invoice Disc." := FALSE;
                            "Allow Item Charge Assignment" := FALSE;
                            "Indirect Cost %" := 0;
                            "Overhead Rate" := 0;
                        END;
                END;

                VALIDATE("Prepayment %");

                IF Type <> Type::" " THEN BEGIN
                    IF Type <> Type::"Fixed Asset" THEN
                        VALIDATE("VAT Prod. Posting Group");
                    Quantity := xRec.Quantity;
                    VALIDATE("Unit of Measure Code");
                    IF Quantity <> 0 THEN BEGIN
                        InitOutstanding;
                        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
                            InitQtyToShip
                        ELSE
                            InitQtyToReceive;
                    END;
                    UpdateWithWarehouseReceive;
                    UpdateDirectUnitCost(FIELDNO("No."));
                    "Job No." := xRec."Job No.";
                    "Job Line Type" := xRec."Job Line Type";
                    IF xRec."Job Task No." <> '' THEN
                        VALIDATE("Job Task No.", xRec."Job Task No.");
                END;

                CreateDim(
                  DimMgt.TypeToTableID3(Type), "No.",
                  DATABASE::Job, "Job No.",
                  DATABASE::"Responsibility Center", "Responsibility Center",
                  DATABASE::"Work Center", "Work Center No.");
                //DistIntegration.EnterPurchaseItemCrossRef(Rec);

                GetDefaultBin;

                ReqnHeader.GET("Document Type", "Document No.");
                IF ReqnHeader."Send IC Document" THEN
                    CASE Type OF
                        Type::" ", Type::"Charge (Item)":
                            BEGIN
                                "IC Partner Ref. Type" := Type;
                                "IC Partner Reference" := "No.";
                            END;
                        Type::"G/L Account":
                            BEGIN
                                "IC Partner Ref. Type" := Type;
                                "IC Partner Reference" := GLAcc."Default IC Partner G/L Acc. No";
                            END;
                        Type::Item:
                            BEGIN
                                ICPartner.GET(ReqnHeader."Buy-from IC Partner Code");
                                CASE ICPartner."Outbound Purch. Item No. Type" OF
                                    ICPartner."Outbound Purch. Item No. Type"::"Common Item No.":
                                        VALIDATE("IC Partner Ref. Type", "IC Partner Ref. Type"::"Common Item No.");
                                    ICPartner."Outbound Purch. Item No. Type"::"Internal No.":
                                        BEGIN
                                            "IC Partner Ref. Type" := "IC Partner Ref. Type"::Item;
                                            "IC Partner Reference" := "No.";
                                        END;
                                    ICPartner."Outbound Purch. Item No. Type"::"Cross Reference":
                                        BEGIN
                                            // VALIDATE("IC Partner Ref. Type", "IC Partner Ref. Type"::"Cross Reference");
                                            // ItemCrossReference.SETRANGE("Cross-Reference Type",
                                            //   ItemCrossReference."Cross-Reference Type"::Vendor);
                                            // ItemCrossReference.SETRANGE("Cross-Reference Type No.",
                                            //   "Buy-from Vendor No.");
                                            // ItemCrossReference.SETRANGE("Item No.", "No.");
                                            // IF ItemCrossReference.FINDFIRST THEN
                                            //     "IC Partner Reference" := ItemCrossReference."Cross-Reference No.";
                                        END;
                                    ICPartner."Outbound Purch. Item No. Type"::"Vendor Item No.":
                                        BEGIN
                                            "IC Partner Ref. Type" := "IC Partner Ref. Type"::"Vendor Item No.";
                                            "IC Partner Reference" := "Vendor Item No.";
                                        END;
                                END;
                            END;
                        Type::"Fixed Asset":
                            BEGIN
                                "IC Partner Ref. Type" := "IC Partner Ref. Type"::" ";
                                "IC Partner Reference" := '';
                            END;
                    END;

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JTUpdatePurchLinePrices;
                END;

                // MAG 6TH AUG. 2018.
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.

                //Add account type.
                if Type = Type::"G/L Account" then begin
                    GLAccount.Get("No.");
                    if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement" then begin
                        "G/L Account Type" := "G/L Account Type"::"Income Statement";
                    end else
                        if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Balance Sheet" then begin
                            "G/L Account Type" := "G/L Account Type"::"Balance Sheet";
                        end;
                end;

            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate();
            begin
                TestStatusOpen;

                IF xRec."Location Code" <> "Location Code" THEN BEGIN
                    TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                    TESTFIELD("Receipt No.", '');

                    TESTFIELD("Return Qty. Shipped Not Invd.", 0);
                    TESTFIELD("Return Shipment No.", '');
                END;

                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Location Code"), "Sales Order No.");

                IF "Location Code" <> xRec."Location Code" THEN
                    InitItemAppl;

                IF (xRec."Location Code" <> "Location Code") AND (Quantity <> 0) THEN BEGIN
                    //ReservePurchLine.VerifyChange(Rec,xRec);
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    UpdateWithWarehouseReceive;
                END;
                "Bin Code" := '';

                IF Type = Type::Item THEN
                    UpdateDirectUnitCost(FIELDNO("Location Code"));

                IF "Location Code" = '' THEN BEGIN
                    IF InvtSetup.GET THEN
                        "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
                END ELSE
                    IF Location.GET("Location Code") THEN
                        "Inbound Whse. Handling Time" := Location."Inbound Whse. Handling Time";

                UpdateLeadTimeFields;
                UpdateDates;

                GetDefaultBin;
            end;
        }
        field(8; "Posting Group"; Code[10])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST("Fixed Asset")) "FA Posting Group";
        }
        field(10; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';

            trigger OnValidate();
            var
                CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
            begin
                /*IF NOT TrackingBlocked THEN
                  CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);
                */

                IF "Expected Receipt Date" <> 0D THEN
                    VALIDATE(
                      "Planned Receipt Date",
                      CalendarMgmt.CalcDateBOC2(InternalLeadTimeDays, "Expected Receipt Date", CustomCalendarChange, TRUE))
                ELSE
                    VALIDATE("Planned Receipt Date", "Expected Receipt Date");

            end;
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';

            trigger OnValidate();
            begin
                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::"Pending Approval");
            end;
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

            trigger OnValidate();
            var
                lvUserSetup: Record "User Setup";
            begin
                // Added by SEJ on 18th Feb. 2019 to allow Proc Staff to modify the Quantity on Approved PR
                ApprovedByBudgetMonitorOfficer;
                //End of this Check

                VALIDATE("Qty. to Order", Quantity);

                IF "Drop Shipment" AND ("Document Type" <> "Document Type"::"Store Return") THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION(Quantity), "Sales Order No.");
                "Quantity (Base)" := CalcBaseQty(Quantity);
                IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN BEGIN
                    IF (Quantity * "Return Qty. Shipped" < 0) OR
                       ((ABS(Quantity) < ABS("Return Qty. Shipped")) AND ("Return Shipment No." = '')) THEN
                        FIELDERROR(Quantity, STRSUBSTNO(Text004, FIELDCAPTION("Return Qty. Shipped")));
                    IF ("Quantity (Base)" * "Return Qty. Shipped (Base)" < 0) OR
                       ((ABS("Quantity (Base)") < ABS("Return Qty. Shipped (Base)")) AND ("Return Shipment No." = ''))
                    THEN
                        FIELDERROR("Quantity (Base)", STRSUBSTNO(Text004, FIELDCAPTION("Return Qty. Shipped (Base)")));
                END ELSE BEGIN
                    IF (Quantity * "Quantity Received" < 0) OR
                       ((ABS(Quantity) < ABS("Quantity Received")) AND ("Receipt No." = ''))
                    THEN
                        FIELDERROR(Quantity, STRSUBSTNO(Text004, FIELDCAPTION("Quantity Received")));
                    IF ("Quantity (Base)" * "Qty. Received (Base)" < 0) OR
                       ((ABS("Quantity (Base)") < ABS("Qty. Received (Base)")) AND ("Receipt No." = ''))
                    THEN
                        FIELDERROR("Quantity (Base)", STRSUBSTNO(Text004, FIELDCAPTION("Qty. Received (Base)")));
                END;

                IF (Type = Type::"Charge (Item)") AND (CurrFieldNo <> 0) THEN BEGIN
                    IF (Quantity * "Qty. Assigned" < 0) OR (ABS(Quantity) < ABS("Qty. Assigned")) THEN
                        FIELDERROR(Quantity, STRSUBSTNO(Text004, FIELDCAPTION("Qty. Assigned")));
                    UpdateItemChargeAssgnt;
                END;

                IF (xRec.Quantity <> Quantity) OR (xRec."Quantity (Base)" <> "Quantity (Base)") OR
                   (Rec."No." = xRec."No.")
                THEN BEGIN
                    InitOutstanding;
                    IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
                        InitQtyToShip
                    ELSE
                        InitQtyToReceive;
                END;
                IF (Quantity * xRec.Quantity < 0) OR (Quantity = 0) THEN
                    InitItemAppl;

                IF Type = Type::Item THEN
                    UpdateDirectUnitCost(FIELDNO(Quantity))
                ELSE
                    VALIDATE("Line Discount %");

                IF (xRec.Quantity <> Quantity) OR (xRec."Quantity (Base)" <> "Quantity (Base)") THEN BEGIN
                    //ReservePurchLine.VerifyQuantity(Rec,xRec);
                    UpdateWithWarehouseReceive;
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    CheckApplToItemLedgEntry;
                END;

                IF (xRec.Quantity <> Quantity) AND (Quantity = 0) AND
                   ((Amount <> 0) OR ("Amount Including VAT" <> 0) OR ("VAT Base Amount" <> 0))
                THEN BEGIN
                    //Amount := 0;
                    //"Amount Including VAT" := 0;
                    "VAT Base Amount" := 0;
                END;
                SetDefaultQuantity;

                IF ("Document Type" = "Document Type"::"Store Return") AND ("Prepayment %" <> 0) THEN
                    UpdatePrePaymentAmounts;

                //
                VALIDATE(Amount);
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
                TestStatusOpen;
            end;
        }
        field(16; "Outstanding Quantity"; Decimal)
        {
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(17; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                IF "Qty. to Invoice" = MaxQtyToInvoice THEN
                    InitQtyToInvoice
                ELSE
                    "Qty. to Invoice (Base)" := CalcBaseQty("Qty. to Invoice");
                IF ("Qty. to Invoice" * Quantity < 0) OR (ABS("Qty. to Invoice") > ABS(MaxQtyToInvoice)) THEN
                    ERROR(
                      Text006,
                      MaxQtyToInvoice);
                IF ("Qty. to Invoice (Base)" * "Quantity (Base)" < 0) OR (ABS("Qty. to Invoice (Base)") > ABS(MaxQtyToInvoiceBase)) THEN
                    ERROR(
                      Text007,
                      MaxQtyToInvoiceBase);
                "VAT Difference" := 0;
                CalcInvDiscToInvoice;
                CalcPrepaymentToDeduct;
            end;
        }
        field(18; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                IF (CurrFieldNo <> 0) AND
                   (Type = Type::Item) AND
                   ("Qty. to Receive" <> 0) AND
                   (NOT "Drop Shipment")
                THEN
                    CheckWarehouse;

                IF "Qty. to Receive" = Quantity - "Quantity Received" THEN
                    InitQtyToReceive
                ELSE BEGIN
                    "Qty. to Receive (Base)" := CalcBaseQty("Qty. to Receive");
                    InitQtyToInvoice;
                END;
                IF ("Qty. to Receive" * Quantity < 0) OR
                   (ABS("Qty. to Receive") > ABS("Outstanding Quantity")) OR
                   (Quantity * "Outstanding Quantity" < 0)
                THEN
                    ERROR(
                      Text008,
                      "Outstanding Quantity");
                IF ("Qty. to Receive (Base)" * "Quantity (Base)" < 0) OR
                   (ABS("Qty. to Receive (Base)") > ABS("Outstanding Qty. (Base)")) OR
                   ("Quantity (Base)" * "Outstanding Qty. (Base)" < 0)
                THEN
                    ERROR(
                      Text009,
                      "Outstanding Qty. (Base)");

                IF (CurrFieldNo <> 0) AND (Type = Type::Item) AND ("Qty. to Receive" < 0) THEN
                    CheckApplToItemLedgEntry;
            end;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FIELDNO("Direct Unit Cost"));
            Caption = 'Direct Unit Cost';

            trigger OnValidate();
            begin
                VALIDATE("Line Discount %");
                VALIDATE(Amount);
                // MAG 5TH SEPT. 2018, Compute Direct Unit Cost (LCY)
                GetReqnHeader;
                ApprovedByBudgetMonitorOfficer;
                TestStatusOpen;

                //"Direct Unit Cost" := ROUND("Direct Unit Cost" ,Currency."Amount Rounding Precision");
                IF ReqnHeader."Currency Code" <> '' THEN BEGIN
                    ReqnHeader.TESTFIELD("Currency Factor");
                    "Direct Unit Cost (LCY)" :=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate, "Currency Code",
                        "Direct Unit Cost", ReqnHeader."Currency Factor");
                END ELSE
                    "Direct Unit Cost (LCY)" := "Direct Unit Cost";

                // MAG - END.
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';

            trigger OnValidate();
            begin
                TestStatusOpen;
                TESTFIELD("No.");
                TESTFIELD(Quantity);

                IF "Prod. Order No." <> '' THEN
                    ERROR(
                      Text99000000,
                      FIELDCAPTION("Unit Cost (LCY)"));

                IF CurrFieldNo = FIELDNO("Unit Cost (LCY)") THEN
                    IF Type = Type::Item THEN BEGIN
                        GetItem;
                        IF Item."Costing Method" = Item."Costing Method"::Standard THEN
                            ERROR(
                              Text010,
                              FIELDCAPTION("Unit Cost (LCY)"), Item.FIELDCAPTION("Costing Method"), Item."Costing Method");
                    END;

                UnitCostCurrency := "Unit Cost (LCY)";
                GetReqnHeader;
                IF ReqnHeader."Currency Code" <> '' THEN BEGIN
                    ReqnHeader.TESTFIELD("Currency Factor");
                    GetGLSetup;
                    UnitCostCurrency :=
                      ROUND(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                          GetDate, "Currency Code",
                          "Unit Cost (LCY)", ReqnHeader."Currency Factor"),
                        GLSetup."Unit-Amount Rounding Precision");
                END;

                IF ("Direct Unit Cost" <> 0) AND
                   ("Direct Unit Cost" <> ("Line Discount Amount" / Quantity))
                THEN
                    "Indirect Cost %" :=
                      ROUND(
                        (UnitCostCurrency - "Direct Unit Cost" + "Line Discount Amount" / Quantity) /
                        ("Direct Unit Cost" - "Line Discount Amount" / Quantity) * 100, 0.00001)
                ELSE
                    "Indirect Cost %" := 0;

                UpdateSalesCost;

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JTUpdatePurchLinePrices;
                END;

                VALIDATE(Amount);
            end;
        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate();
            var
                lvUserSetup: Record "User Setup";
            begin
                // Added by SEJ on 18th Feb. 2019 to allow Proc Staff to modify the Quantity on Approved PR
                ApprovedByBudgetMonitorOfficer;
                //TestStatusOpen;
                // End of Check
                GetReqnHeader;
                "Line Discount Amount" :=
                  ROUND(
                    ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") *
                    "Line Discount %" / 100,
                    Currency."Amount Rounding Precision");
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
                UpdateUnitCost;
            end;
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';

            trigger OnValidate();
            begin
                TestStatusOpen;
                TESTFIELD(Quantity);
                IF ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") <> 0 THEN
                    "Line Discount %" :=
                      ROUND(
                        "Line Discount Amount" /
                        ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") * 100,
                        0.00001)
                ELSE
                    "Line Discount %" := 0;
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts;
                UpdateUnitCost;
            end;
        }
        field(29; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;

            trigger OnValidate();
            begin
                GetReqnHeader;
                ApprovedByBudgetMonitorOfficer;         // MAG

                Amount := ROUND(Amount, Currency."Amount Rounding Precision");
                CASE "VAT Calculation Type" OF
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            "VAT Base Amount" :=
                              ROUND(Amount * (1 - ReqnHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              ROUND(Amount + "VAT Base Amount" * "VAT %" / 100, Currency."Amount Rounding Precision");
                        END;
                    "VAT Calculation Type"::"Full VAT":
                        IF Amount <> 0 THEN
                            FIELDERROR(Amount,
                              STRSUBSTNO(
                                Text011, FIELDCAPTION("VAT Calculation Type"),
                                "VAT Calculation Type"));
                    "VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            ReqnHeader.TESTFIELD("VAT Base Discount %", 0);
                            "VAT Base Amount" := Amount;
                            IF "Use Tax" THEN
                                "Amount Including VAT" := "VAT Base Amount"
                            ELSE BEGIN
                                "Amount Including VAT" :=
                                  Amount +
                                  ROUND(
                                    SalesTaxCalculate.CalculateTax(
                                      "Tax Area Code", "Tax Group Code", "Tax Liable", ReqnHeader."Posting Date",
                                      "VAT Base Amount", "Quantity (Base)", ReqnHeader."Currency Factor"),
                                    Currency."Amount Rounding Precision");
                                IF "VAT Base Amount" <> 0 THEN
                                    "VAT %" :=
                                      ROUND(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount", 0.00001)
                                ELSE
                                    "VAT %" := 0;
                            END;
                        END;
                END;

                InitOutstandingAmount;
                UpdateUnitCost;
            end;
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;

            trigger OnValidate();
            begin
                GetReqnHeader;
                "Amount Including VAT" := ROUND("Amount Including VAT", Currency."Amount Rounding Precision");
                CASE "VAT Calculation Type" OF
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            Amount :=
                              ROUND(
                                "Amount Including VAT" /
                                (1 + (1 - ReqnHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                                Currency."Amount Rounding Precision");
                            "VAT Base Amount" :=
                              ROUND(Amount * (1 - ReqnHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                        END;
                    "VAT Calculation Type"::"Full VAT":
                        BEGIN
                            Amount := 0;
                            "VAT Base Amount" := 0;
                        END;
                    "VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            ReqnHeader.TESTFIELD("VAT Base Discount %", 0);
                            IF "Use Tax" THEN BEGIN
                                Amount := "Amount Including VAT";
                                "VAT Base Amount" := Amount;
                            END ELSE BEGIN
                                Amount :=
                                  ROUND(
                                    SalesTaxCalculate.ReverseCalculateTax(
                                      "Tax Area Code", "Tax Group Code", "Tax Liable", ReqnHeader."Posting Date",
                                      "Amount Including VAT", "Quantity (Base)", ReqnHeader."Currency Factor"),
                                    Currency."Amount Rounding Precision");
                                "VAT Base Amount" := Amount;
                                IF "VAT Base Amount" <> 0 THEN
                                    "VAT %" :=
                                      ROUND(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount", 0.00001)
                                ELSE
                                    "VAT %" := 0;
                            END;
                        END;
                END;

                InitOutstandingAmount;
                UpdateUnitCost;
                // MAG 6TH AUG. 2018.
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG-END
            end;
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

            trigger OnValidate();
            begin
                TestStatusOpen;
                IF ("Allow Invoice Disc." <> xRec."Allow Invoice Disc.") AND
                   (NOT "Allow Invoice Disc.")
                THEN BEGIN
                    "Inv. Discount Amount" := 0;
                    "Inv. Disc. Amount to Invoice" := 0;
                    UpdateAmounts;
                    UpdateUnitCost;
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
                //IF "Currency Factor" <> xRec."Currency Factor" THEN
                // UpdatePurchLines(FIELDCAPTION("Currency Factor"));
                // MAG
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
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

            trigger OnLookup();
            begin
                SelectItemEntry;
            end;

            trigger OnValidate();
            begin
                IF "Appl.-to Item Entry" <> 0 THEN
                    "Location Code" := CheckApplToItemLedgEntry;
            end;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                TestStatusOpen;
                ApprovedByBudgetMonitorOfficer;        // MAG

                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                TestStatusOpen;
                ApprovedByBudgetMonitorOfficer;
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");

                //IVAN
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                //END IVAN
            end;
        }
        field(45; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;

            trigger OnValidate();
            var
                Job: Record Job;
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                VALIDATE("Job Task No.", '');
                IF "Job No." = '' THEN BEGIN
                    CreateDim(
                      DATABASE::Job, "Job No.",
                      DimMgt.TypeToTableID3(Type), "No.",
                      DATABASE::"Responsibility Center", "Responsibility Center",
                      DATABASE::"Work Center", "Work Center No.");
                    EXIT;
                END;

                IF NOT (Type IN [Type::Item, Type::"G/L Account"]) THEN
                    FIELDERROR("Job No.", STRSUBSTNO(Text012, FIELDCAPTION(Type), Type));
                Job.GET("Job No.");
                Job.TestBlocked;
                "Job Currency Code" := Job."Currency Code";

                CreateDim(
                  DATABASE::Job, "Job No.",
                  DimMgt.TypeToTableID3(Type), "No.",
                  DATABASE::"Responsibility Center", "Responsibility Center",
                  DATABASE::"Work Center", "Work Center No.");
            end;
        }
        field(54; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate();
            begin
                TESTFIELD("No.");
                TestStatusOpen;

                IF Type = Type::"Charge (Item)" THEN
                    TESTFIELD("Indirect Cost %", 0);

                IF (Type = Type::Item) AND ("Prod. Order No." = '') THEN BEGIN
                    GetItem;
                    IF Item."Costing Method" = Item."Costing Method"::Standard THEN
                        ERROR(
                          Text010,
                          FIELDCAPTION("Indirect Cost %"), Item.FIELDCAPTION("Costing Method"), Item."Costing Method");
                END;

                UpdateUnitCost;
            end;
        }
        field(57; "Outstanding Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Outstanding Amount';
            Editable = false;

            trigger OnValidate();
            var
                Currency2: Record Currency;
            begin
                GetReqnHeader;
                Currency2.InitRoundingPrecision;
                IF ReqnHeader."Currency Code" <> '' THEN
                    "Outstanding Amount (LCY)" :=
                      ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Outstanding Amount", ReqnHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                ELSE
                    "Outstanding Amount (LCY)" :=
                      ROUND("Outstanding Amount", Currency2."Amount Rounding Precision");
            end;
        }
        field(58; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(59; "Amt. Rcd. Not Invoiced"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced';
            Editable = false;

            trigger OnValidate();
            var
                Currency2: Record Currency;
            begin
                GetReqnHeader;
                Currency2.InitRoundingPrecision;
                IF ReqnHeader."Currency Code" <> '' THEN
                    "Amt. Rcd. Not Invoiced (LCY)" :=
                      ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Amt. Rcd. Not Invoiced", ReqnHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                ELSE
                    "Amt. Rcd. Not Invoiced (LCY)" :=
                      ROUND("Amt. Rcd. Not Invoiced", Currency2."Amount Rounding Precision");
            end;
        }
        field(60; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(61; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(63; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            Editable = false;
        }
        field(64; "Receipt Line No."; Integer)
        {
            Caption = 'Receipt Line No.';
            Editable = false;
        }
        field(67; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(68; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amount';
            Editable = false;

            trigger OnValidate();
            begin
                TESTFIELD(Quantity);
                UpdateAmounts;
                UpdateUnitCost;
                CalcInvDiscToInvoice;
            end;
        }
        field(70; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';

            trigger OnValidate();
            begin
                IF ReqnHeader."Send IC Document" AND
                   ("IC Partner Ref. Type" = "IC Partner Ref. Type"::"Vendor Item No.")
                THEN
                    "IC Partner Reference" := "Vendor Item No.";
            end;
        }
        field(71; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Sales Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate();
            begin
                IF (xRec."Sales Order No." <> "Sales Order No.") AND (Quantity <> 0) THEN BEGIN
                    //ReservePurchLine.VerifyChange(Rec,xRec);
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                END;
            end;
        }
        field(72; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Sales Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                         "Document No." = FIELD("Sales Order No."));

            trigger OnValidate();
            begin
                IF (xRec."Sales Order Line No." <> "Sales Order Line No.") AND (Quantity <> 0) THEN BEGIN
                    //ReservePurchLine.VerifyChange(Rec,xRec);
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                END;
            end;
        }
        field(73; "Drop Shipment"; Boolean)
        {
            Caption = 'Drop Shipment';
            Editable = false;

            trigger OnValidate();
            begin
                IF (xRec."Drop Shipment" <> "Drop Shipment") AND (Quantity <> 0) THEN BEGIN
                    //ReservePurchLine.VerifyChange(Rec,xRec);
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                END;
                IF "Drop Shipment" THEN BEGIN
                    "Bin Code" := '';
                    EVALUATE("Inbound Whse. Handling Time", '<0D>');
                    VALIDATE("Inbound Whse. Handling Time");
                    InitOutstanding;
                    InitQtyToReceive;
                END;
            end;
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate();
            begin
                IF xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" THEN
                    IF GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") THEN
                        VALIDATE("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(75; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate();
            begin
                TestStatusOpen;
                IF xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" THEN
                    IF GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp, "Gen. Prod. Posting Group") THEN
                        VALIDATE("VAT Prod. Posting Group", GenProdPostingGrp."Def. VAT Prod. Posting Group");
            end;
        }
        field(77; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
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
            TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                              "Document No." = FIELD("Document No."));
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

            trigger OnValidate();
            begin
                UpdateAmounts;
            end;
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';

            trigger OnValidate();
            begin
                UpdateAmounts;
            end;
        }
        field(87; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate();
            begin
                TestStatusOpen;
                UpdateAmounts;
            end;
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';

            trigger OnValidate();
            begin
                UpdateAmounts;
            end;
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate();
            begin
                VALIDATE("VAT Prod. Posting Group");
            end;
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate();
            begin
                //TestStatusOpen;
                VATPostingSetup.GET("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                "VAT Difference" := 0;
                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                CASE "VAT Calculation Type" OF
                    "VAT Calculation Type"::"Reverse Charge VAT",
                  "VAT Calculation Type"::"Sales Tax":
                        "VAT %" := 0;
                    "VAT Calculation Type"::"Full VAT":
                        BEGIN
                            TESTFIELD(Type, Type::"G/L Account");
                            VATPostingSetup.TESTFIELD("Purchase VAT Account");
                            TESTFIELD("No.", VATPostingSetup."Purchase VAT Account");
                        END;
                END;
                IF ReqnHeader."Prices Including VAT" AND (Type = Type::Item) THEN
                    "Direct Unit Cost" :=
                      ROUND(
                        "Direct Unit Cost" * (100 + "VAT %") / (100 + xRec."VAT %"),
                        Currency."Unit-Amount Rounding Precision");
                UpdateAmounts;
            end;
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(92; "Outstanding Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Outstanding Amount (LCY)';
            Editable = false;
        }
        field(93; "Amt. Rcd. Not Invoiced (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amt. Rcd. Not Invoiced (LCY)';
            Editable = false;
        }
        field(95; "Reserved Quantity"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                  "Source Ref. No." = FIELD("Line No."),
                                                                  "Source Type" = CONST(39),
                                                                  "Source Subtype" = FIELD("Document Type"),
                                                                  "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(97; "Blanket Order No."; Code[20])
        {
            Caption = 'Blanket Order No.';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup();
            begin
                BlanketOrderLookup;
            end;

            trigger OnValidate();
            begin
                IF "Blanket Order No." = '' THEN
                    "Blanket Order Line No." := 0
                ELSE
                    VALIDATE("Blanket Order Line No.");
            end;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            Caption = 'Blanket Order Line No.';
            TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = CONST("Blanket Order"),
                                                              "Document No." = FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup();
            begin
                BlanketOrderLookup;
            end;

            trigger OnValidate();
            begin
                IF "Blanket Order Line No." <> 0 THEN BEGIN
                    ReqnLine2.GET("Document Type"::"HR Cash Voucher", "Blanket Order No.", "Blanket Order Line No.");
                    ReqnLine2.TESTFIELD(Type, Type);
                    ReqnLine2.TESTFIELD("No.", "No.");
                    ReqnLine2.TESTFIELD("Pay-to Vendor No.", "Pay-to Vendor No.");
                    ReqnLine2.TESTFIELD("Buy-from Vendor No.", "Buy-from Vendor No.");
                END;
            end;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;

            trigger OnValidate();
            begin
                //cmm 171109 update total cost
                "Total Cost" := "Unit Cost" * "Qty. Requested";
                //end cmm
            end;
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(103; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Line Amount"));
            Caption = 'Line Amount';
            Editable = false;

            trigger OnValidate();
            begin
                TESTFIELD(Type);
                TESTFIELD(Quantity);
                TESTFIELD("Direct Unit Cost");

                GetReqnHeader;
                "Line Amount" := ROUND("Line Amount", Currency."Amount Rounding Precision");
                VALIDATE(
                  "Line Discount Amount", ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") - "Line Amount");
            end;
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
        }
        field(105; "Inv. Disc. Amount to Invoice"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Amount to Invoice';
            Editable = false;
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(107; "IC Partner Ref. Type"; Option)
        {
            Caption = 'IC Partner Ref. Type';
            OptionCaption = ' ,G/L Account,Item,,,Charge (Item),Cross Reference,Common Item No.,Vendor Item No.';
            OptionMembers = " ","G/L Account",Item,,,"Charge (Item)","Cross Reference","Common Item No.","Vendor Item No.";

            trigger OnValidate();
            begin
                IF "IC Partner Code" <> '' THEN
                    "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                IF "IC Partner Ref. Type" <> xRec."IC Partner Ref. Type" THEN
                    "IC Partner Reference" := '';
                IF "IC Partner Ref. Type" = "IC Partner Ref. Type"::"Common Item No." THEN BEGIN
                    IF Item."No." <> "No." THEN
                        Item.GET("No.");
                    "IC Partner Reference" := Item."Common Item No.";
                END;
            end;
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
                IF "No." <> '' THEN
                    CASE "IC Partner Ref. Type" OF
                        "IC Partner Ref. Type"::"G/L Account":
                            BEGIN
                                IF ICGLAccount.GET("IC Partner Reference") THEN;
                                IF PAGE.RUNMODAL(PAGE::"IC G/L Account List", ICGLAccount) = ACTION::LookupOK THEN
                                    VALIDATE("IC Partner Reference", ICGLAccount."No.");
                            END;
                        "IC Partner Ref. Type"::Item:
                            BEGIN
                                IF Item.GET("IC Partner Reference") THEN;
                                IF PAGE.RUNMODAL(PAGE::"Item List", Item) = ACTION::LookupOK THEN
                                    VALIDATE("IC Partner Reference", Item."No.");
                            END;
                        "IC Partner Ref. Type"::"Cross Reference":
                            BEGIN
                                // GetReqnHeader;
                                // ItemCrossReference.RESET;
                                // ItemCrossReference.SETCURRENTKEY("Cross-Reference Type", "Cross-Reference Type No.");
                                // ItemCrossReference.SETFILTER(
                                //   "Cross-Reference Type", '%1|%2',
                                //   ItemCrossReference."Cross-Reference Type"::Vendor,
                                //   ItemCrossReference."Cross-Reference Type"::" ");
                                // ItemCrossReference.SETFILTER("Cross-Reference Type No.", '%1|%2', ReqnHeader."Buy-from Vendor No.", '');
                                // IF PAGE.RUNMODAL(PAGE::"Cross Reference List", ItemCrossReference) = ACTION::LookupOK THEN
                                //     VALIDATE("IC Partner Reference", ItemCrossReference."Cross-Reference No.");
                            END;
                        "IC Partner Ref. Type"::"Vendor Item No.":
                            BEGIN
                                GetReqnHeader;
                                ItemVendorCatalog.SETCURRENTKEY("Vendor No.");
                                ItemVendorCatalog.SETRANGE("Vendor No.", ReqnHeader."Buy-from Vendor No.");
                                IF PAGE.RUNMODAL(PAGE::"Vendor Item Catalog", ItemVendorCatalog) = ACTION::LookupOK THEN
                                    VALIDATE("IC Partner Reference", ItemVendorCatalog."Vendor Item No.");
                            END;
                    END;
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
                IF "Prepayment %" <> 0 THEN BEGIN
                    TESTFIELD("Document Type", "Document Type"::"Purchase Requisition");
                    TESTFIELD(Type);
                    TESTFIELD("No.");
                    GenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                    IF GenPostingSetup."Purch. Prepayments Account" <> '' THEN BEGIN
                        GLAcc.GET(GenPostingSetup."Purch. Prepayments Account");
                        VATPostingSetup.GET("VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group");
                    END ELSE
                        CLEAR(VATPostingSetup);
                    "Prepayment VAT %" := VATPostingSetup."VAT %";
                    "Prepmt. VAT Calc. Type" := VATPostingSetup."VAT Calculation Type";
                    "Prepayment VAT Identifier" := VATPostingSetup."VAT Identifier";
                    CASE "Prepmt. VAT Calc. Type" OF
                        "VAT Calculation Type"::"Reverse Charge VAT",
                      "VAT Calculation Type"::"Sales Tax":
                            "Prepayment VAT %" := 0;
                        "VAT Calculation Type"::"Full VAT":
                            FIELDERROR("Prepmt. VAT Calc. Type", STRSUBSTNO(Text036, "Prepmt. VAT Calc. Type"));
                    END;
                    "Prepayment Tax Group Code" := GLAcc."Tax Group Code";
                END;

                TestStatusOpen;

                IF Type <> Type::" " THEN
                    UpdateAmounts;
            end;
        }
        field(110; "Prepmt. Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt. Line Amount"));
            Caption = 'Prepmt. Line Amount';
            MinValue = 0;

            trigger OnValidate();
            begin
                TestStatusOpen;
                TESTFIELD("Line Amount");
                IF "Prepmt. Line Amount" < "Prepmt. Amt. Inv." THEN
                    FIELDERROR("Prepmt. Line Amount", STRSUBSTNO(Text038, "Prepmt. Amt. Inv."));
                IF "Prepmt. Line Amount" > "Line Amount" THEN
                    FIELDERROR("Prepmt. Line Amount", STRSUBSTNO(Text039, "Line Amount"));
                VALIDATE("Prepayment %", ROUND("Prepmt. Line Amount" * 100 / "Line Amount", 0.00001));
            end;
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

            trigger OnValidate();
            begin
                UpdateAmounts;
            end;
        }
        field(119; "Prepayment Tax Liable"; Boolean)
        {
            Caption = 'Prepayment Tax Liable';

            trigger OnValidate();
            begin
                UpdateAmounts;
            end;
        }
        field(120; "Prepayment Tax Group Code"; Code[10])
        {
            Caption = 'Prepayment Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate();
            begin
                TestStatusOpen;
                UpdateAmounts;
            end;
        }
        field(121; "Prepmt Amt to Deduct"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Prepmt Amt to Deduct"));
            Caption = 'Prepmt Amt to Deduct';
            MinValue = 0;

            trigger OnValidate();
            begin
                IF "Prepmt Amt to Deduct" > "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" THEN
                    FIELDERROR(
                      "Prepmt Amt to Deduct",
                      STRSUBSTNO(Text039, "Prepmt. Amt. Inv." - "Prepmt Amt Deducted"));

                IF "Prepmt Amt to Deduct" > "Qty. to Invoice" * "Prepmt Amt Deducted" THEN
                    FIELDERROR(
                      "Prepmt Amt to Deduct",
                      STRSUBSTNO(Text039, "Qty. to Invoice" * "Prepmt Amt Deducted"));
            end;
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
        field(129; "Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. (LCY)';
            Editable = false;
        }
        field(130; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";

            trigger OnValidate();
            begin
                IF "IC Partner Code" <> '' THEN BEGIN
                    TESTFIELD(Type, Type::"G/L Account");
                    GetReqnHeader;
                    ReqnHeader.TESTFIELD("Buy-from IC Partner Code", '');
                    ReqnHeader.TESTFIELD("Pay-to IC Partner Code", '');
                    VALIDATE("IC Partner Ref. Type", "IC Partner Ref. Type"::"G/L Account");
                END;
            end;
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

            trigger OnValidate();
            begin
                TestStatusOpen;
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(1001; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF "Job Task No." = '' THEN BEGIN
                    CLEAR(JobJnlLine);
                    "Job Line Type" := "Job Line Type"::" ";
                    JTUpdatePurchLinePrices;
                    EXIT;
                END;

                JobSetCurrencyFactor;
                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JTUpdatePurchLinePrices;
                END;
            end;
        }
        field(1002; "Job Line Type"; Option)
        {
            Caption = 'Job Line Type';
            OptionCaption = ' ,Schedule,Contract,Both Schedule and Contract';
            OptionMembers = " ",Schedule,Contract,"Both Schedule and Contract";

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);
            end;
        }
        field(1003; "Job Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Unit Price';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);
                //  CMM 261109 remove obsolete code
                /*
                IF TestJobTask THEN BEGIN
                  UpdateJobJnlLine;
                  JobJnlLine.SetUpdateFromUnitPrice;
                  JobJnlLine.VALIDATE("Unit Price","Job Unit Price");
                  JobJnlLine.VALIDATE("Line Discount %","Job Line Discount %");
                  JTUpdatePurchLinePrices
                END;  */
                //end cmm

            end;
        }
        field(1004; "Job Total Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Total Price';
            Editable = false;
        }
        field(1005; "Job Line Amount"; Decimal)
        {
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Amount", "Job Line Amount");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1006; "Job Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Discount Amount';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Discount Amount", "Job Line Discount Amount");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1007; "Job Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Discount %", "Job Line Discount %");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1008; "Job Unit Price (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Unit Price (LCY)';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Discount %", "Job Line Discount %");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1009; "Job Total Price (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Total Price (LCY)';
            Editable = false;
        }
        field(1010; "Job Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount (LCY)';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Amount (LCY)", "Job Line Amount (LCY)");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1011; "Job Line Disc. Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Disc. Amount (LCY)';

            trigger OnValidate();
            begin
                TESTFIELD("Receipt No.", '');
                IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
                    TESTFIELD("Quantity Received", 0);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JobJnlLine.VALIDATE("Unit Price (LCY)", "Job Unit Price (LCY)");
                    JobJnlLine.VALIDATE("Line Discount Amount (LCY)", "Job Line Disc. Amount (LCY)");
                    JTUpdatePurchLinePrices
                END;
            end;
        }
        field(1012; "Job Currency Factor"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Currency Factor';
        }
        field(1013; "Job Currency Code"; Code[20])
        {
            Caption = 'Job Currency Code';
        }
        field(5401; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            TableRelation = "Production Order"."No." WHERE(Status = CONST(Released));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Prod. Order No."), "Sales Order No.");

                //AddOnIntegrMgt.ValidateProdOrderOnPurchLine(Rec);
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate();
            begin
                IF "Variant Code" <> '' THEN
                    TESTFIELD(Type, Type::Item);
                TestStatusOpen;

                IF xRec."Variant Code" <> "Variant Code" THEN BEGIN
                    TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                    TESTFIELD("Receipt No.", '');

                    TESTFIELD("Return Qty. Shipped Not Invd.", 0);
                    TESTFIELD("Return Shipment No.", '');
                END;

                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Variant Code"), "Sales Order No.");

                IF Type = Type::Item THEN
                    UpdateDirectUnitCost(FIELDNO("Variant Code"));

                IF (xRec."Variant Code" <> "Variant Code") AND (Quantity <> 0) THEN BEGIN
                    // ReservePurchLine.VerifyChange(Rec,xRec);
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    InitItemAppl;
                END;

                UpdateLeadTimeFields;
                UpdateDates;
                GetDefaultBin;
                //DistIntegration.EnterPurchaseItemCrossRef(Rec);

                IF TestJobTask THEN BEGIN
                    UpdateJobJnlLine;
                    JTUpdatePurchLinePrices;
                END
            end;
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';

            trigger OnLookup();
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                IF (("Document Type" IN ["Document Type"::"Purchase Requisition", "Document Type"::"Store Requisition"]) AND (Quantity < 0)) OR
                   (("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND (Quantity >= 0))
                THEN
                    BinCode := WMSManagement.BinContentLookUp("Location Code", "No.", "Variant Code", '', "Bin Code")
                ELSE
                    BinCode := WMSManagement.BinLookUp("Location Code", "No.", "Variant Code", '');

                IF BinCode <> '' THEN
                    VALIDATE("Bin Code", BinCode);
            end;

            trigger OnValidate();
            var
                WMSManagement: Codeunit "WMS Management";
            begin
                IF "Bin Code" <> '' THEN
                    IF (("Document Type" IN ["Document Type"::"Purchase Requisition", "Document Type"::"Store Return"]) AND (Quantity < 0)) OR
                       (("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND (Quantity >= 0))
                    THEN
                        WMSManagement.FindBinContent("Location Code", "Bin Code", "No.", "Variant Code", '')
                    ELSE
                        WMSManagement.FindBin("Location Code", "Bin Code", '');

                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Bin Code"), "Sales Order No.");

                TESTFIELD(Type, Type::Item);
                TESTFIELD("Location Code");

                IF "Bin Code" <> '' THEN BEGIN
                    GetLocation("Location Code");
                    Location.TESTFIELD("Bin Mandatory");
                    CheckWarehouse;
                END;
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate();
            var
                UnitOfMeasureTranslation: Record "Unit of Measure Translation";
            begin
                TestStatusOpen;
                TESTFIELD("Quantity Received", 0);
                TESTFIELD("Qty. Received (Base)", 0);
                TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                IF "Drop Shipment" THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Unit of Measure Code"), "Sales Order No.");
                IF (xRec."Unit of Measure" <> "Unit of Measure") AND (Quantity <> 0) THEN
                    //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
                    UpdateDirectUnitCost(FIELDNO("Unit of Measure Code"));
                IF "Unit of Measure Code" = '' THEN
                    "Unit of Measure" := ''
                ELSE BEGIN
                    UnitOfMeasure.GET("Unit of Measure Code");
                    "Unit of Measure" := UnitOfMeasure.Description;
                    GetReqnHeader;
                    IF ReqnHeader."Language Code" <> '' THEN BEGIN
                        UnitOfMeasureTranslation.SETRANGE(Code, "Unit of Measure Code");
                        UnitOfMeasureTranslation.SETRANGE("Language Code", ReqnHeader."Language Code");
                        IF UnitOfMeasureTranslation.FINDFIRST THEN
                            "Unit of Measure" := UnitOfMeasureTranslation.Description;
                    END;
                END;
                //DistIntegration.EnterPurchaseItemCrossRef(Rec);
                IF "Prod. Order No." = '' THEN BEGIN
                    IF (Type = Type::Item) AND ("No." <> '') THEN BEGIN
                        GetItem;
                        "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                        "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
                        "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                        "Unit Volume" := Item."Unit Volume" * "Qty. per Unit of Measure";
                        "Units per Parcel" := ROUND(Item."Units per Parcel" / "Qty. per Unit of Measure", 0.00001);
                        IF "Qty. per Unit of Measure" > xRec."Qty. per Unit of Measure" THEN
                            InitItemAppl;
                        UpdateUOMQtyPerStockQty;
                    END ELSE
                        "Qty. per Unit of Measure" := 1;
                END ELSE
                    "Qty. per Unit of Measure" := 0;

                VALIDATE(Quantity);
            end;
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TESTFIELD("Qty. per Unit of Measure", 1);
                VALIDATE(Quantity, "Quantity (Base)");
                UpdateDirectUnitCost(FIELDNO("Quantity (Base)"));
            end;
        }
        field(5416; "Outstanding Qty. (Base)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5417; "Qty. to Invoice (Base)"; Decimal)
        {
            Caption = 'Qty. to Invoice (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TESTFIELD("Qty. per Unit of Measure", 1);
                VALIDATE("Qty. to Invoice", "Qty. to Invoice (Base)");
            end;
        }
        field(5418; "Qty. to Receive (Base)"; Decimal)
        {
            Caption = 'Qty. to Receive (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TESTFIELD("Qty. per Unit of Measure", 1);
                VALIDATE("Qty. to Receive", "Qty. to Receive (Base)");
            end;
        }
        field(5458; "Qty. Rcd. Not Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Rcd. Not Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5460; "Qty. Received (Base)"; Decimal)
        {
            Caption = 'Qty. Received (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5495; "Reserved Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Source Type" = CONST(39),
                                                                           "Source Subtype" = FIELD("Document Type"),
                                                                           "Source ID" = FIELD("Document No."),
                                                                           "Source Ref. No." = FIELD("Line No."),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5600; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5601; "FA Posting Type"; Option)
        {
            Caption = 'FA Posting Type';
            OptionCaption = ' ,Acquisition Cost,Maintenance';
            OptionMembers = " ","Acquisition Cost",Maintenance;

            trigger OnValidate();
            begin
                IF Type = Type::"Fixed Asset" THEN BEGIN
                    TESTFIELD("Job No.", '');
                    IF "FA Posting Type" = "FA Posting Type"::" " THEN
                        "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
                    GetFAPostingGroup
                END ELSE BEGIN
                    "Depreciation Book Code" := '';
                    "FA Posting Date" := 0D;
                    "Salvage Value" := 0;
                    "Depr. until FA Posting Date" := FALSE;
                    "Depr. Acquisition Cost" := FALSE;
                    "Maintenance Code" := '';
                    "Insurance No." := '';
                    "Budgeted FA No." := '';
                    "Duplicate in Depreciation Book" := '';
                    "Use Duplication List" := FALSE;
                END;
            end;
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";

            trigger OnValidate();
            begin
                GetFAPostingGroup;
            end;
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

            trigger OnValidate();
            begin
                IF "Budgeted FA No." <> '' THEN BEGIN
                    FA.GET("Budgeted FA No.");
                    FA.TESTFIELD("Budgeted Asset", TRUE);
                END;
            end;
        }
        field(5612; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";

            trigger OnValidate();
            begin
                "Use Duplication List" := FALSE;
            end;
        }
        field(5613; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';

            trigger OnValidate();
            begin
                "Duplicate in Depreciation Book" := '';
            end;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";

            trigger OnValidate();
            begin
                CreateDim(
                  DATABASE::"Responsibility Center", "Responsibility Center",
                  DimMgt.TypeToTableID3(Type), "No.",
                  DATABASE::Job, "Job No.",
                  DATABASE::"Work Center", "Work Center No.");
            end;
        }
        field(5705; "Cross-Reference No."; Code[20])
        {
            Caption = 'Cross-Reference No.';

            trigger OnLookup();
            begin
                CrossReferenceNoLookUp;
            end;

            trigger OnValidate();
            var
            // ReturnedCrossRef: Record "Item Cross Reference";
            begin
                GetReqnHeader;
                "Buy-from Vendor No." := ReqnHeader."Buy-from Vendor No.";

                // ReturnedCrossRef.INIT;
                // IF "Cross-Reference No." <> '' THEN BEGIN
                //     //DistIntegration.ICRLookupPurchaseItem(Rec,ReturnedCrossRef);
                //     VALIDATE("No.", ReturnedCrossRef."Item No.");
                //     IF ReturnedCrossRef."Variant Code" <> '' THEN
                //         VALIDATE("Variant Code", ReturnedCrossRef."Variant Code");
                //     IF ReturnedCrossRef."Unit of Measure" <> '' THEN
                //         VALIDATE("Unit of Measure Code", ReturnedCrossRef."Unit of Measure");
                //     UpdateDirectUnitCost(FIELDNO("Cross-Reference No."));
                // END;

                // "Unit of Measure (Cross Ref.)" := ReturnedCrossRef."Unit of Measure";
                // "Cross-Reference Type" := ReturnedCrossRef."Cross-Reference Type";
                // "Cross-Reference Type No." := ReturnedCrossRef."Cross-Reference Type No.";
                // "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";

                // IF ReturnedCrossRef.Description <> '' THEN
                //     Description := ReturnedCrossRef.Description;

                IF ReqnHeader."Send IC Document" AND (ReqnHeader."IC Direction" = ReqnHeader."IC Direction"::Outgoing) THEN BEGIN
                    "IC Partner Ref. Type" := "IC Partner Ref. Type"::"Cross Reference";
                    "IC Partner Reference" := "Cross-Reference No.";
                END;
            end;
        }
        field(5706; "Unit of Measure (Cross Ref.)"; Code[10])
        {
            Caption = 'Unit of Measure (Cross Ref.)';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(5707; "Cross-Reference Type"; Option)
        {
            Caption = 'Cross-Reference Type';
            OptionCaption = ' ,Customer,Vendor,Bar Code';
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

            trigger OnValidate();
            begin
                IF PurchasingCode.GET("Purchasing Code") THEN BEGIN
                    "Drop Shipment" := PurchasingCode."Drop Shipment";
                    "Special Order" := PurchasingCode."Special Order";
                END ELSE
                    "Drop Shipment" := FALSE;
                VALIDATE("Drop Shipment", "Drop Shipment");
            end;
        }
        field(5712; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            TableRelation = "Product Group".Code WHERE("Item Category Code" = FIELD("Item Category Code"));
        }
        field(5713; "Special Order"; Boolean)
        {
            Caption = 'Special Order';

            trigger OnValidate();
            begin
                IF (xRec."Special Order" <> "Special Order") AND (Quantity <> 0) THEN;
                // WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5714; "Special Order Sales No."; Code[20])
        {
            Caption = 'Special Order Sales No.';
            TableRelation = IF ("Special Order" = CONST(True)) "Sales Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate();
            begin
                IF (xRec."Special Order Sales No." <> "Special Order Sales No.") AND (Quantity <> 0) THEN;
                //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5715; "Special Order Sales Line No."; Integer)
        {
            Caption = 'Special Order Sales Line No.';
            TableRelation = IF ("Special Order" = CONST(True)) "Sales Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                         "Document No." = FIELD("Special Order Sales No."));

            trigger OnValidate();
            begin
                IF (xRec."Special Order Sales Line No." <> "Special Order Sales Line No.") AND (Quantity <> 0) THEN;
                //WhseValidateSourceLine.PurchaseLineVerifyChange(Rec,xRec);
            end;
        }
        field(5750; "Whse. Outstanding Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("Warehouse Receipt Line"."Qty. Outstanding (Base)" WHERE("Source Type" = CONST(39),
                                                                                        "Source Subtype" = FIELD("Document Type"),
                                                                                        "Source No." = FIELD("Document No."),
                                                                                        "Source Line No." = FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5752; "Completely Received"; Boolean)
        {
            Caption = 'Completely Received';
            Editable = false;
        }
        field(5790; "Requested Receipt Date"; Date)
        {
            Caption = 'Requested Receipt Date';

            trigger OnValidate();
            var
                CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
            begin
                TestStatusOpen;
                IF (CurrFieldNo <> 0) AND
                   ("Promised Receipt Date" <> 0D)
                THEN
                    ERROR(
                      Text023,
                      FIELDCAPTION("Requested Receipt Date"),
                      FIELDCAPTION("Promised Receipt Date"));

                IF "Requested Receipt Date" <> 0D THEN
                    VALIDATE("Order Date",
                      CalendarMgmt.CalcDateBOC2(AdjustDateFormula("Lead Time Calculation"), "Requested Receipt Date", CustomCalendarChange, FALSE))
                ELSE
                    IF "Requested Receipt Date" <> xRec."Requested Receipt Date" THEN
                        GetUpdateBasicDates;
            end;
        }
        field(5791; "Promised Receipt Date"; Date)
        {
            Caption = 'Promised Receipt Date';

            trigger OnValidate();
            begin
                IF CurrFieldNo <> 0 THEN
                    IF "Promised Receipt Date" <> 0D THEN
                        VALIDATE("Planned Receipt Date", "Promised Receipt Date")
                    ELSE
                        VALIDATE("Requested Receipt Date")
                ELSE
                    VALIDATE("Planned Receipt Date", "Promised Receipt Date");
            end;
        }
        field(5792; "Lead Time Calculation"; DateFormula)
        {
            Caption = 'Lead Time Calculation';

            trigger OnValidate();
            begin
                TestStatusOpen;
                IF "Requested Receipt Date" <> 0D THEN BEGIN
                    VALIDATE("Planned Receipt Date");
                END ELSE
                    GetUpdateBasicDates;
            end;
        }
        field(5793; "Inbound Whse. Handling Time"; DateFormula)
        {
            Caption = 'Inbound Whse. Handling Time';

            trigger OnValidate();
            begin
                TestStatusOpen;
                IF ("Promised Receipt Date" <> 0D) OR
                   ("Requested Receipt Date" <> 0D)
                THEN
                    VALIDATE("Planned Receipt Date")
                ELSE
                    VALIDATE("Expected Receipt Date");
            end;
        }
        field(5794; "Planned Receipt Date"; Date)
        {
            Caption = 'Planned Receipt Date';

            trigger OnValidate();
            var
                CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
            begin
                TestStatusOpen;
                IF "Promised Receipt Date" <> 0D THEN BEGIN
                    IF "Planned Receipt Date" <> 0D THEN
                        "Expected Receipt Date" :=
                          CalendarMgmt.CalcDateBOC(InternalLeadTimeDays, "Planned Receipt Date", CustomCalendarChange, FALSE)
                    ELSE
                        "Expected Receipt Date" := "Planned Receipt Date";
                    //IF NOT TrackingBlocked THEN
                    //CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);
                END ELSE
                    IF "Planned Receipt Date" <> 0D THEN
                        "Order Date" :=
                          CalendarMgmt.CalcDateBOC2(AdjustDateFormula("Lead Time Calculation"), "Planned Receipt Date", CustomCalendarChange, FALSE)
                    ELSE
                        GetUpdateBasicDates;
            end;
        }
        field(5795; "Order Date"; Date)
        {
            Caption = 'Order Date';

            trigger OnValidate();
            var
                CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
            begin
                TestStatusOpen;
                IF (CurrFieldNo <> 0) AND
                   ("Document Type" = "Document Type"::"Purchase Requisition") AND
                   ("Order Date" < WORKDATE) AND
                   ("Order Date" <> 0D)
                THEN
                    MESSAGE(
                      Text018,
                      FIELDCAPTION("Order Date"), "Order Date", WORKDATE);

                IF "Order Date" <> 0D THEN
                    "Planned Receipt Date" :=
                      CalendarMgmt.CalcDateBOC(AdjustDateFormula("Lead Time Calculation"), "Order Date", CustomCalendarChange, TRUE);

                IF "Planned Receipt Date" <> 0D THEN
                    "Expected Receipt Date" :=
                      CalendarMgmt.CalcDateBOC(InternalLeadTimeDays, "Planned Receipt Date", CustomCalendarChange, FALSE)
                ELSE
                    "Expected Receipt Date" := "Planned Receipt Date";

                //IF NOT TrackingBlocked THEN
                //CheckDateConflict.PurchLineCheck(Rec,CurrFieldNo <> 0);
            end;
        }
        field(5800; "Allow Item Charge Assignment"; Boolean)
        {
            Caption = 'Allow Item Charge Assignment';
            InitValue = true;

            trigger OnValidate();
            begin
                CheckItemChargeAssgnt;
            end;
        }
        field(5801; "Qty. to Assign"; Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Purch)"."Qty. to Assign" WHERE("Document Type" = FIELD("Document Type"),
                                                                                       "Document No." = FIELD("Document No."),
                                                                                       "Document Line No." = FIELD("Line No.")));
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5802; "Qty. Assigned"; Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Purch)"."Qty. Assigned" WHERE("Document Type" = FIELD("Document Type"),
                                                                                      "Document No." = FIELD("Document No."),
                                                                                      "Document Line No." = FIELD("Line No.")));
            Caption = 'Qty. Assigned';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5803; "Return Qty. to Ship"; Decimal)
        {
            Caption = 'Return Qty. to Ship';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                IF (CurrFieldNo <> 0) AND
                   (Type = Type::Item) AND
                   ("Return Qty. to Ship" <> 0) AND
                   (NOT "Drop Shipment")
                THEN
                    CheckWarehouse;

                IF "Return Qty. to Ship" = Quantity - "Return Qty. Shipped" THEN
                    InitQtyToShip
                ELSE BEGIN
                    "Return Qty. to Ship (Base)" := CalcBaseQty("Return Qty. to Ship");
                    InitQtyToInvoice;
                END;
                IF ("Return Qty. to Ship" * Quantity < 0) OR
                   (ABS("Return Qty. to Ship") > ABS("Outstanding Quantity")) OR
                   (Quantity * "Outstanding Quantity" < 0)
                THEN
                    ERROR(
                      Text020,
                      "Outstanding Quantity");
                IF ("Return Qty. to Ship (Base)" * "Quantity (Base)" < 0) OR
                   (ABS("Return Qty. to Ship (Base)") > ABS("Outstanding Qty. (Base)")) OR
                   ("Quantity (Base)" * "Outstanding Qty. (Base)" < 0)
                THEN
                    ERROR(
                      Text021,
                      "Outstanding Qty. (Base)");

                IF (CurrFieldNo <> 0) AND (Type = Type::Item) AND ("Return Qty. to Ship" > 0) THEN
                    CheckApplToItemLedgEntry;
            end;
        }
        field(5804; "Return Qty. to Ship (Base)"; Decimal)
        {
            Caption = 'Return Qty. to Ship (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TESTFIELD("Qty. per Unit of Measure", 1);
                VALIDATE("Return Qty. to Ship", "Return Qty. to Ship (Base)");
            end;
        }
        field(5805; "Return Qty. Shipped Not Invd."; Decimal)
        {
            Caption = 'Return Qty. Shipped Not Invd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5806; "Ret. Qty. Shpd Not Invd.(Base)"; Decimal)
        {
            Caption = 'Ret. Qty. Shpd Not Invd.(Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5807; "Return Shpd. Not Invd."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd.';
            Editable = false;

            trigger OnValidate();
            var
                Currency2: Record Currency;
            begin
                GetReqnHeader;
                Currency2.InitRoundingPrecision;
                IF ReqnHeader."Currency Code" <> '' THEN
                    "Return Shpd. Not Invd. (LCY)" :=
                      ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Return Shpd. Not Invd.", ReqnHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                ELSE
                    "Return Shpd. Not Invd. (LCY)" :=
                      ROUND("Return Shpd. Not Invd.", Currency2."Amount Rounding Precision");
            end;
        }
        field(5808; "Return Shpd. Not Invd. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Return Shpd. Not Invd. (LCY)';
            Editable = false;
        }
        field(5809; "Return Qty. Shipped"; Decimal)
        {
            Caption = 'Return Qty. Shipped';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5810; "Return Qty. Shipped (Base)"; Decimal)
        {
            Caption = 'Return Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(6600; "Return Shipment No."; Code[20])
        {
            Caption = 'Return Shipment No.';
            Editable = false;
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

            trigger OnValidate();
            begin
                IF "Return Reason Code" = '' THEN
                    UpdateDirectUnitCost(FIELDNO("Return Reason Code"));

                IF ReturnReason.GET("Return Reason Code") THEN BEGIN
                    IF ReturnReason."Default Location Code" <> '' THEN
                        VALIDATE("Location Code", ReturnReason."Default Location Code");
                    IF ReturnReason."Inventory Value Zero" THEN
                        VALIDATE("Direct Unit Cost", 0)
                    ELSE
                        UpdateDirectUnitCost(FIELDNO("Return Reason Code"));
                END;
            end;
        }
        field(50000; "Qty. Requested"; Decimal)
        {
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            var
            // ReserveReqLine: Codeunit "Req-Line Reserve2";
            begin
                /*IF "Line No."<> 0 THEN BEGIN
                  IF "Document Type" = "Document Type"::"Store Requisition" THEN BEGIN
                    IF Type = Type::Item THEN BEGIN
                      IF (xRec."Qty. Requested" <> "Qty. Requested") THEN
                        ReserveReqLine.VerifyQuantity(Rec,xRec);
                    END;
                  END;
                END;  */
                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::Open);
                //cmm 171109 calculate total cost
                "Total Cost" := "Unit Cost" * "Qty. Requested";
                //end cmm

            end;
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

            trigger OnValidate();
            begin
                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::Open);
            end;
        }
        field(50004; "Pay to Type"; Option)
        {
            OptionCaption = ' ,Vendor,Staff,Other';
            OptionMembers = " ",Vendor,Staff,Other;
        }
        field(50005; "Pay to No."; Code[20])
        {
            TableRelation = IF ("Pay to Type" = FILTER(Vendor)) Vendor."No."
            ELSE
            IF ("Pay to Type" = FILTER(Staff)) Employee."No.";

            trigger OnValidate();
            var
                EmpRec: Record Employee;
                VendRec: Record Vendor;
            begin
                CASE "Pay to Type" OF
                    "Pay to Type"::Vendor:
                        BEGIN
                            IF "Pay to No." <> '' THEN BEGIN
                                VendRec.GET("Pay to No.");
                                "Pay to Name" := VendRec.Name;
                            END;
                        END;
                    "Pay to Type"::Staff:
                        BEGIN
                            IF "Pay to No." <> '' THEN BEGIN
                                EmpRec.GET("Pay to No.");
                                "Pay to Name" := EmpRec.FullName;
                            END;
                        END;
                END;
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
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
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

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END
            end;
        }
        field(50017; "Budget Amount as at Date"; Decimal)
        {
            Caption = 'Budget Amount as at Date';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Control Account"),
                                                               Date = FIELD("Filter to Date Filter")));

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018.
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50018; "Budget Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                             "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Control Account"),
                                                               Date = FIELD("Fiscal Year Date Filter")));
            Caption = 'Budget Amount for the Year';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50019; "Budget Remark"; Text[100])
        {
        }
        field(50020; "Total Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50021; Department; Code[20])
        {
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(3, Department);
            end;
        }
        field(50023; "Actual Amount as at Date"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Control Account"),
                                                        "Posting Date" = FIELD("Filter to Date Filter")));
            Caption = 'Actual Amount as at Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50024; "Actual Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Control Account"),
                                                        "Posting Date" = FIELD("Fiscal Year Date Filter")));
            Caption = 'Actual Amount for the Year';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50025; "Balance on Budget as at Date"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            begin
                // MAG 5TH SEPT. 2018
                SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
                CALCFIELDS("Budget Amount as at Date");
                CALCFIELDS("Actual Amount as at Date");
                CALCFIELDS("Commitment Amount as at Date");

                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            "Line Amount", "Currency Factor");
                    END ELSE
                        LineAmount := "Line Amount";
                END;


                "Balance on Budget as at Date" := "Budget Amount as at Date" - LineAmount
                                                  - ("Actual Amount as at Date") - "Commitment Amount as at Date";

                IF "Balance on Budget as at Date" < 0 THEN
                    "Budget Comment as at Date" := 'Out of Budget'
                ELSE
                    "Budget Comment as at Date" := 'Within Budget';

                IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                    "Budget Comment" := 'Within Budget';
                    "Exceeded at Date Budget" := false;
                end
                ELSE begin
                    "Budget Comment" := 'Out of Budget';
                    "Exceeded at Date Budget" := true;
                end;

            end;
        }
        field(50026; "Balance on Budget for the Year"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            begin
                // MAG 5TH SEPT. 2018
                SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
                CALCFIELDS("Budget Amount for the Year");
                CALCFIELDS("Actual Amount for the Year");
                CALCFIELDS("Commitment Amount for the Year");
                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            "Line Amount", "Currency Factor");
                    END ELSE
                        LineAmount := "Line Amount";
                END;


                "Balance on Budget for the Year" := "Budget Amount for the Year" - LineAmount
                                                  - ("Actual Amount for the Year") - "Commitment Amount for the Year";

                IF "Balance on Budget for the Year" < 0 THEN
                    "Budget Comment for the Year" := 'Out of Budget'
                ELSE
                    "Budget Comment for the Year" := 'Within Budget';

                IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                    "Budget Comment" := 'Within Budget';
                    "Exceeded Year Budget" := false;
                end
                ELSE begin
                    "Budget Comment" := 'Out of Budget';
                    "Exceeded Year Budget" := true;
                end;


                // MAG - END.
            end;
        }
        field(50027; "Bal. on Budget for the Month"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            var
                lvNFLRequisitionLine: Record "NFL Requisition Line";
            begin

                SETFILTER("Month Date Filter", '%1..%2', "Accounting Period Start Date", "Accounting Period End Date");
                CALCFIELDS("Budget Amount for the Month");
                CALCFIELDS("Actual Amount for the Month");
                CALCFIELDS("Commitment Amt for the Month");
                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");
                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            "Line Amount", "Currency Factor");
                    END ELSE
                        LineAmount := "Line Amount";
                END;

                "Bal. on Budget for the Month" := "Budget Amount for the Month" - LineAmount
                                                  - ("Actual Amount for the Month") - "Commitment Amt for the Month";

                IF "Bal. on Budget for the Month" < 0 THEN
                    "Budget Comment for the Month" := 'Out of Budget'
                ELSE
                    "Budget Comment for the Month" := 'Within Budget';

                IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                    "Budget Comment" := 'Within Budget';
                    "Exceeded Month Budget" := false;
                end
                ELSE begin
                    "Budget Comment" := 'Out of Budget';
                    "Exceeded Month Budget" := true;
                end;
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
                //MAG 13TH FEB 2017
                IF "Converted to Order" = TRUE THEN
                    ERROR('The selected line has already been converted to an order');

                //Check whether the source document for the requisition line has been approved and released
                NFLRequisitionHeader.SETFILTER("No.", "Document No.");
                NFLRequisitionHeader.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
                // IF NFLRequisitionHeader.FINDFIRST THEN
                //     IF ApprovalMgt.PrePostApprovalCheck(BankReconn, NFLRequisitionHeader, PaymentJnl) THEN;
                // //MAG-END
            end;
        }
        field(50031; "Inventory Charge A/c"; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate();
            begin
                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::Open);
            end;
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
            TableRelation = "G/L Account"."No.";

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                ApprovedByBudgetMonitorOfficer;

                IF Type = Type::"G/L Account" THEN BEGIN
                    GLAccount.SETRANGE("No.", "No.");
                    IF GLAccount.FIND('-') THEN BEGIN
                        IF GLAccount."Prepayment Account" = FALSE THEN BEGIN
                            ERROR('You can only change the Expense Account for only Prepayment related Account No.');
                        END;
                    END;
                END;

                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
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
            //DecimalPlaces = 0 : 5;

            trigger OnValidate();
            var
                lvUserSetup: Record "User Setup";
            begin
                // Added by SEJ on 18th Feb. 2019 to allow Proc Staff to modify the Quantity on Approved PR
                //ApprovedByBudgetMonitorOfficer;
                //TestStatusOpen;
                // End of Check
                IF "Qty. to Order" > Quantity THEN
                    ERROR('Qty To order. must be less than or equal to the quantity');
                "Qty. Not Ordered" := Quantity - "Qty. to Order";

                IF ((("Qty. to Order" < 0) XOR ("Qty. Not Ordered" < 0)) AND (Quantity <> 0) AND ("Qty. to Order" <> 0)) THEN
                    ERROR('You are can not order more than %1', "Qty. Not Ordered");

                //VALIDATE("Qty. to Invoice","Qty. to Order");

                //VALIDATE("Qty. to Receive","Qty. to Order");

                //MAG - END
            end;
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
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Control Account"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Filter to Date Filter")));
            Caption = 'Commitment Amount as at Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50057; "Commitment Amount for the Year"; Decimal)
        {
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Control Account"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Fiscal Year Date Filter")));
            Caption = 'Commitment Amount for the Year';
            Editable = false;
            FieldClass = FlowField;
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
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Control Account"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Month Date Filter")));
            Caption = 'Commitment Amt for the Month';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50060; "Commitment Amt for the Quarter"; Decimal)
        {
            CalcFormula = Sum("Commitment Entry".Amount WHERE("G/L Account No." = FIELD("Control Account"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "Posting Date" = FIELD("Quarter Date Filter")));
            Caption = 'Commitment Amt for the Quarter';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50061; "Actual Amount for the Month"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Control Account"),
                                                        "Posting Date" = FIELD("Month Date Filter")));
            Caption = 'Actual Amount for the Month';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50062; "Actual Amount for the Quarter"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                        "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                        "G/L Account No." = FIELD("Control Account"),
                                                        "Posting Date" = FIELD("Quarter Date Filter")));
            Caption = 'Actual Amount for the Quarter';
            Editable = false;
            FieldClass = FlowField;
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
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Control Account"),
                                                               Date = FIELD("Month Date Filter")));
            Caption = 'Budget Amount for the Month';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50066; "Budget Amount for the Quarter"; Decimal)
        {
            CalcFormula = Sum("G/L Budget Entry".Amount WHERE("Budget Name" = FIELD("Budget Code"),
                                                               "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                               "Global Dimension 2 Code" = field("Shortcut Dimension 2 Code"),
                                                               "G/L Account No." = FIELD("Control Account"),
                                                               Date = FIELD("Quarter Date Filter")));
            Caption = 'Budget Amount for the Quarter';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                // MAG 6TH AUG. 2018
                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50069; "Bal. on Budget for the Quarter"; Decimal)
        {
            Caption = 'Bal. on Budget for the Quarter';
            Editable = false;

            trigger OnValidate();
            begin
                // MAG
                SETFILTER("Quarter Date Filter", '%1..%2', "Quarter Start Date", "Quarter End Date");
                CALCFIELDS("Budget Amount for the Quarter");
                CALCFIELDS("Actual Amount for the Quarter");
                CALCFIELDS("Commitment Amt for the Quarter");

                CommitmentEntry.SETRANGE("Entry No.", "Commitment Entry No.");

                IF CommitmentEntry.FINDFIRST THEN      // Prevent double subtraction incase there is already a commitment.
                    LineAmount := 0
                ELSE BEGIN
                    IF "Currency Code" <> '' THEN BEGIN
                        TESTFIELD("Currency Factor");
                        LineAmount :=
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GetDate, "Currency Code",
                            "Line Amount", "Currency Factor");
                    END ELSE
                        LineAmount := "Line Amount";
                END;


                "Bal. on Budget for the Quarter" := "Budget Amount for the Quarter" - LineAmount
                                                  - ("Actual Amount for the Quarter") - "Commitment Amt for the Quarter";

                IF "Bal. on Budget for the Quarter" < 0 THEN
                    "Budget Comment for the Quarter" := 'Out of Budget'
                ELSE
                    "Budget Comment for the Quarter" := 'Within Budget';

                IF ("Budget Comment as at Date" = 'Within Budget') AND ("Budget Comment for the Month" = 'Within Budget') THEN begin
                    "Budget Comment" := 'Within Budget';
                    "Exceeded Quarter Budget" := false;
                end
                ELSE begin
                    "Budget Comment" := 'Out of Budget';
                    "Exceeded Quarter Budget" := true;
                end;
            end;
        }
        field(50070; "Direct Unit Cost (LCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FIELDNO("Direct Unit Cost (LCY)"));
            Caption = 'Direct Unit Cost (LCY)';
            Description = 'Handles the LCY Amount for Direct Unit Cost';
            Editable = false;

            trigger OnValidate();
            begin

                VALIDATE("Balance on Budget as at Date");
                VALIDATE("Balance on Budget for the Year");
                VALIDATE("Bal. on Budget for the Quarter");
                VALIDATE("Bal. on Budget for the Month");
                // MAG - END.
            end;
        }
        field(50071; "Line Amount (LCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Line Amount (LCY)"));
            Caption = 'Line Amount (LCY)';
            Description = 'Handles the LCY Amount for Line Amount';
            Editable = false;

            trigger OnValidate();
            begin
                /*
                TESTFIELD(Type);
                TESTFIELD(Quantity);
                TESTFIELD("Direct Unit Cost");

                GetReqnHeader;
                "Line Amount" := ROUND("Line Amount",Currency."Amount Rounding Precision");
                VALIDATE(
                  "Line Discount Amount",ROUND(Quantity * "Direct Unit Cost",Currency."Amount Rounding Precision") - "Line Amount");
                 */

            end;
        }
        field(50072; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";

            trigger OnValidate();
            begin
                GetReqnHeader;
                DeferralPostDate := gvNFLReqHeader."Posting Date";

                /*
               DeferralUtilities.DeferralCodeOnValidate(
                 "Deferral Code",DeferralUtilities.GetSalesDeferralDocType,'','',
                 "Document Type","Document No.","Line No.",
                 GetDeferralAmount,DeferralPostDate,
                 Description,SalesHeader."Currency Code");

               */

            end;
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
            Editable = false;
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

            trigger OnValidate();
            begin
                //ReqnHeader2.GET("Document Type","Document No.");
                //ReqnHeader2.TESTFIELD(Status,ReqnHeader2.Status::Open);
            end;
        }
        field(50091; "Qty To Make Purch. Req."; Decimal)
        {

            trigger OnValidate();
            begin
                //ReqnHeader2.GET("Document Type","Document No.");
                //ReqnHeader2.TESTFIELD(Status,ReqnHeader2.Status::Open);
            end;
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
            CalcFormula = - Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   //"Source Type" = CONST(39006291),
                                                                   "Source Subtype" = FIELD("Document Type"),
                                                                   "Reservation Status" = CONST(Reservation)));
            FieldClass = FlowField;
        }
        field(50098; "Qty Returned"; Decimal)
        {

            trigger OnValidate();
            var
                lvStoreReturn: Record "NFL Requisition Line";
            begin
                ReqnHeader2.GET("Document Type", "Document No.");
                ReqnHeader2.TESTFIELD(Status, ReqnHeader2.Status::Open);

                IF "Line No." <> 0 THEN BEGIN
                    IF "Document Type" = "Document Type"::"Store Return" THEN
                        IF "Qty Returned" > "Qty. Requested" THEN
                            ERROR('Qty Returned must not be greater than Qty Borrowed')
                END;
            end;
        }
        field(50099; "Archive No."; Code[20])
        {
        }
        field(50100; "Qty. Not Returned"; Decimal)
        {

            trigger OnValidate();
            var
                lvStoreReturn: Record "NFL Requisition Line";
            begin
            end;
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

            trigger OnValidate();
            var
                ProdOrderRtngLine: Record "Prod. Order Routing Line";
            begin
                IF "Operation No." = '' THEN
                    EXIT;

                TESTFIELD(Type, Type::Item);
                TESTFIELD("Prod. Order No.");
                TESTFIELD("Routing No.");

                ProdOrderRtngLine.GET(
                  ProdOrderRtngLine.Status::Released,
                  "Prod. Order No.",
                  "Routing Reference No.",
                  "Routing No.",
                  "Operation No.");

                ProdOrderRtngLine.TESTFIELD(
                  Type,
                  ProdOrderRtngLine.Type::"Work Center");

                "Expected Receipt Date" := ProdOrderRtngLine."Ending Date";
                VALIDATE("Work Center No.", ProdOrderRtngLine."No.");
                VALIDATE("Direct Unit Cost", ProdOrderRtngLine."Direct Unit Cost");
            end;
        }
        field(50104; "Work Center No."; Code[20])
        {
            Caption = 'Work Center No.';
            TableRelation = "Work Center";

            trigger OnValidate();
            begin
                IF Type = Type::"Charge (Item)" THEN
                    TESTFIELD("Work Center No.", '');
                IF "Work Center No." = '' THEN
                    EXIT;

                WorkCenter.GET("Work Center No.");
                "Gen. Prod. Posting Group" := WorkCenter."Gen. Prod. Posting Group";
                "Overhead Rate" := WorkCenter."Overhead Rate";
                VALIDATE("Indirect Cost %", WorkCenter."Indirect Cost %");

                CreateDim(
                  DATABASE::"Work Center", "Work Center No.",
                  DimMgt.TypeToTableID3(Type), "No.",
                  DATABASE::Job, "Job No.",
                  DATABASE::"Responsibility Center", "Responsibility Center");
            end;
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

            trigger OnValidate();
            begin
                VALIDATE("Indirect Cost %");
            end;
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

            trigger OnValidate();
            begin
                IF "Planning Flexibility" <> xRec."Planning Flexibility" THEN;
                //ReservePurchLine.UpdatePlanningFlexibility(Rec);
            end;
        }
        field(50110; "Safety Lead Time"; DateFormula)
        {
            Caption = 'Safety Lead Time';

            trigger OnValidate();
            begin
                VALIDATE("Inbound Whse. Handling Time");
            end;
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
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = Amount, "Amount Including VAT";
        }
        key(Key2; "Document No.", "Line No.", "Document Type")
        {
        }
        key(Key3; "Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key4; "Document Type", "Pay-to Vendor No.", "Currency Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Outstanding Amount", "Amt. Rcd. Not Invoiced", "Outstanding Amount (LCY)", "Amt. Rcd. Not Invoiced (LCY)";
        }
        key(Key5; "Document Type", "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key6; "Document Type", Type, "Prod. Order No.", "Prod. Order Line No.", "Routing No.", "Operation No.")
        {
        }
        key(Key7; "Document Type", "Document No.", "Location Code")
        {
        }
        key(Key8; "Document Type", "Receipt No.", "Receipt Line No.")
        {
        }
        key(Key9; Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Document Type", "Expected Receipt Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key10; "Document Type", "Buy-from Vendor No.")
        {
        }
        key(Key11; "Buy-from Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    var
        //DocDim: Record "357";
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        TestStatusOpen;
        IF NOT StatusCheckSuspended AND (ReqnHeader.Status = ReqnHeader.Status::Released) AND
           (Type IN [Type::"G/L Account", Type::"Charge (Item)"])
        THEN
            VALIDATE(Quantity, 0);

        //DocDim.LOCKTABLE;
        IF (Quantity <> 0) AND ItemExists("No.") THEN BEGIN
            //ReservePurchLine.DeleteLine(Rec);
            IF "Receipt No." = '' THEN
                TESTFIELD("Qty. Rcd. Not Invoiced", 0);
            IF "Return Shipment No." = '' THEN
                TESTFIELD("Return Qty. Shipped Not Invd.", 0);

            CALCFIELDS("Reserved Qty. (Base)");
            TESTFIELD("Reserved Qty. (Base)", 0);
            //WhseValidateSourceLine.PurchaseLineDelete(Rec);
        END;

        IF ("Document Type" = "Document Type"::"Purchase Requisition") AND (Quantity <> "Quantity Invoiced") THEN
            TESTFIELD("Prepmt. Amt. Inv.", 0);

        IF "Sales Order Line No." <> 0 THEN BEGIN
            LOCKTABLE;
            SalesOrderLine.LOCKTABLE;
            SalesOrderLine.GET(SalesOrderLine."Document Type"::Order, "Sales Order No.", "Sales Order Line No.");
            SalesOrderLine."Purchase Order No." := '';
            SalesOrderLine."Purch. Order Line No." := 0;
            SalesOrderLine.MODIFY;
        END;

        IF "Special Order Sales Line No." <> 0 THEN BEGIN
            LOCKTABLE;
            SalesOrderLine.LOCKTABLE;
            IF "Document Type" = "Document Type"::"Purchase Requisition" THEN BEGIN
                SalesOrderLine.GET(SalesOrderLine."Document Type"::Order, "Special Order Sales No.", "Special Order Sales Line No.");
                SalesOrderLine."Special Order Purchase No." := '';
                SalesOrderLine."Special Order Purch. Line No." := 0;
                SalesOrderLine.MODIFY;
            END ELSE BEGIN
                IF SalesOrderLine.GET(SalesOrderLine."Document Type"::Order, "Special Order Sales No.", "Special Order Sales Line No.") THEN BEGIN
                    SalesOrderLine."Special Order Purchase No." := '';
                    SalesOrderLine."Special Order Purch. Line No." := 0;
                    SalesOrderLine.MODIFY;
                END;
            END;
        END;

        //NonstockItemMgt.DelNonStockPurch(Rec);

        /*IF "Document Type" = "Document Type"::"4" THEN BEGIN
          ReqnLine2.RESET;
          ReqnLine2.SETCURRENTKEY("Document Type","Blanket Order No.","Blanket Order Line No.");
          ReqnLine2.SETRANGE("Blanket Order No.","Document No.");
          ReqnLine2.SETRANGE("Blanket Order Line No.","Line No.");
          IF ReqnLine2.FINDFIRST THEN
            ReqnLine2.TESTFIELD("Blanket Order Line No.",0);
        END;

        IF Type = Type::Item THEN
          DeleteItemChargeAssgnt("Document Type","Document No.","Line No.");

        IF Type = Type::"Charge (Item)" THEN
          DeleteChargeChargeAssgnt("Document Type","Document No.","Line No.");

        ReqnLine2.RESET;
        ReqnLine2.SETRANGE("Document Type","Document Type");
        ReqnLine2.SETRANGE("Document No.","Document No.");
        ReqnLine2.SETRANGE("Attached to Line No.","Line No.");
        ReqnLine2.DELETEALL(TRUE);
        DimMgt.DeleteDocDim(DATABASE::"NFL Requisition Line","Document Type","Document No.","Line No.");

        PurchCommentLine.SETRANGE("Document Type","Document Type");
        PurchCommentLine.SETRANGE("No.","Document No.");
        PurchCommentLine.SETRANGE("Document Line No.","Line No.");
        IF NOT PurchCommentLine.ISEMPTY THEN
          PurchCommentLine.DELETEALL; *///hak20121118

        //cmm 150809 delete reservation entries when item No is changed
        DeleteReservationEntries;
        //END CMM

    end;

    trigger OnInsert();
    var
        //DocDim: Record "357"; IE
        //lvGenPostingSetup: Record 252; IE
        //lvItem: Record 27; IE

        lvGenPostingSetup: Record "General Posting Setup";
        lvItem: Record Item;
    begin
        TestStatusOpen;
        //AMI

        //DocDim.LOCKTABLE; IE
        //LOCKTABLE; IE
        ReqnHeader."No." := '';

        /*
        IF "Document Type" = "Document Type"::"Store Requisition" THEN
            DimMgt.InsertDocDim(
              DATABASE::"NFL Requisition Line",6,"Document No.","Line No.",
                  "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        //cmm 161109 use dimensions to save in relevant doc type in Doc dim
        ELSE IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
            DimMgt.InsertDocDim(
              DATABASE::"NFL Requisition Line",7,"Document No.","Line No.",
              "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        ELSE IF "Document Type" = "Document Type"::"Store Return" THEN
            DimMgt.InsertDocDim(
              DATABASE::"NFL Requisition Line",8,"Document No.","Line No.",
              "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        //end cmm

        //cmm 171109 odc-show invt. adjustment acc
        IF Type= Type::Item THEN BEGIN
           IF "No." <> '' THEN BEGIN
            lvItem.GET("No.");
            IF lvGenPostingSetup.GET('',lvItem."Gen. Prod. Posting Group") THEN
               "Inventory Charge A/c" :=  lvGenPostingSetup."Inventory Adjmt. Account";
           END;
        END;
        //end cmm
        */

    end;

    trigger OnModify();
    begin
        IF ("Document Type" = "Document Type"::"HR Cash Voucher") AND
           ((Type <> xRec.Type) OR ("No." <> xRec."No."))
        THEN BEGIN
            ReqnLine2.RESET;
            ReqnLine2.SETCURRENTKEY("Document Type", "Blanket Order No.", "Blanket Order Line No.");
            ReqnLine2.SETRANGE("Blanket Order No.", "Document No.");
            ReqnLine2.SETRANGE("Blanket Order Line No.", "Line No.");
            IF ReqnLine2.FINDSET THEN
                REPEAT
                    ReqnLine2.TESTFIELD(Type, Type);
                    ReqnLine2.TESTFIELD("No.", "No.");
                UNTIL ReqnLine2.NEXT = 0;
        END;

        //AMI
        /*IF ((Quantity <> 0) OR (xRec.Quantity <> 0)) AND ItemExists(xRec."No.") THEN
          ReservePurchLine.VerifyChange(Rec,xRec);
         */
        //cmm 150809 delete reservation entries when item No is changed
        IF "Document Type" = "Document Type"::"Store Requisition" THEN BEGIN
            IF (("No." <> xRec."No.") AND (xRec.Type = xRec.Type::Item)) OR ((xRec.Type = xRec.Type::Item) AND (xRec.Type <> Type)) THEN BEGIN
                DeleteReservationEntries;
            END;
        END;
        //END CMM

    end;

    trigger OnRename();
    begin
        ERROR(Text000, TABLECAPTION);
    end;

    var

        gvNFLReqHeader: Record "NFL Requisition Header";
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change %1 because the order line is associated with sales order %2.';
        Text002: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        Text003: Label 'You cannot purchase resources.';
        Text004: Label 'must not be less than %1';
        Text006: Label 'You cannot invoice more than %1 units.';
        Text007: Label 'You cannot invoice more than %1 base units.';
        Text008: Label 'You cannot receive more than %1 units.';
        Text009: Label 'You cannot receive more than %1 base units.';
        Text010: Label 'You cannot change %1 when %2 is %3.';
        Text011: Label '" must be 0 when %1 is %2."';
        Text012: TextConst ENU = 'must not be specified when %1 = %2';
        Text014: Label 'Change %1 from %2 to %3?';
        Text016: TextConst ENU = '%1 is required for %2 = %3.';
        Text017: Label '\The entered information will be disregarded by warehouse operations.';
        Text018: Label '%1 %2 is earlier than the work date %3.';
        Text020: Label 'You cannot return more than %1 units.';
        Text021: Label 'You cannot return more than %1 base units.';
        Text022: Label 'You cannot change %1, if item charge is already posted.';
        Text023: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text029: Label 'must be positive.';
        Text030: Label 'must be negative.';
        Text031: Label 'You cannot define item tracking on this line because it is linked to production order %1.';
        Text032: Label '%1 must not be greater than %2.';
        Text033: Label '"Warehouse "';
        Text034: Label '"Inventory "';
        Text035: Label '%1 units for %2 %3 have already been returned or transferred. Therefore, only %4 units can be returned.';
        Text036: Label 'You must cancel the existing approval for this document to be able to change the %1 field.';
        Text037: Label 'cannot be %1.';
        Text038: Label 'cannot be less than %1.';
        Text039: Label 'cannot be more than %1.';
        Text99000000: Label 'You cannot change %1 when the purchase order is associated to a production order.';
        ReqnHeader: Record "NFL Requisition Header";
        ReqnLine2: Record "NFL Requisition Line";
        TempPurchLine: Record "NFL Requisition Line";
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        ItemTranslation: Record "Item Translation";
        SalesOrderLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        StdTxt: Record "Standard Text";
        //ReqnHeader2: Record "NFL Requisition Header";
        FA: Record "Fixed Asset";
        FADeprBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        ReservEntry: Record "Reservation Entry";
        ItemVariant: Record "Item Variant";
        UnitOfMeasure: Record "Unit of Measure";
        ItemCharge: Record "Item Charge";

        PurchPriceCalcMgt: Codeunit "NFL Purch. Price Calc. Mgt.";

        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        SKU: Record "Stockkeeping Unit";
        WorkCenter: Record "Work Center";
        PurchasingCode: Record Purchasing;
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        GLSetup: Record "General Ledger Setup";
        ReturnReason: Record "Return Reason";
        ItemVend: Record "Item Vendor";
        //ReserveReqLine: Codeunit "Req-Line Reserve2";
        CalChange: Record "Customized Calendar Change";
        JobJnlLine: Record "Job Journal Line";
        Reservation: Page Reservation;
        ItemAvailByDate: Page "Item Availability by Periods";
        ItemAvailByVar: Page "Item Availability by Variant";
        ItemAvailByLoc: Page "Item Availability by Location";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        AddOnIntegrMgt: Codeunit AddOnIntegrManagement;
        DimMgt: Codeunit "DimensionManagement";
        DistIntegration: Codeunit "Dist. Integration";
        //NonstockItemMgt: Codeunit "Nonstock Item Management"; IE
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        //PurchPriceCalcMgt: Codeunit "NFL Purch. Price Calc. Mgt.";
        CalendarMgmt: Codeunit "Calendar Management";
        TrackingBlocked: Boolean;
        StatusCheckSuspended: Boolean;
        GLSetupRead: Boolean;
        UnitCostCurrency: Decimal;
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        Text041: Label 'Do you want to update the Job Task prices?';
        UpdateFromVAT: Boolean;
        Text042: Label 'You cannot return more than the %1 units that you have received for %2 %3.';
        Text043: Label 'must be positive when %1 is not 0.';
        "====CMM==": Integer;
        ReserveMgt: Codeunit "Reservation Management";
        // ReserveReqLine: Codeunit "Req-Line Reserve2";
        ReqnHeader2: Record "NFL Requisition Header";
        Text044: Label 'You cannot change %1 because this purchase order is associated with %2 %3.';
        Text046: Label 'Microsoft Dynamics NAV will not update %1 when changing %2 because a prepayment invoice has been posted. Do you want to continue?';
        Text047: Label '%1 can only be set when %2 is set.';
        Text048: Label '%1 cannot be changed when %2 is set.';
        Text049: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text050: Label 'Cancelled.';
        Text051: Label 'must have the same sign as the receipt';
        Text052: Label 'The quantity that you are trying to invoice is greater than the quantity in receipt %1.';
        Text053: Label 'must have the same sign as the return shipment';
        Text054: Label 'The quantity that you are trying to invoice is greater than the quantity in return shipment %1.';
        TotalAmount: Decimal;
        AmountRequested: Decimal;
        gvVendor: Record Vendor;
        gvItem: Record Item;
        gvGeneralPostingSetup: Record "General Posting Setup";
        gvFixedAsset: Record "Fixed Asset";
        gvFADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        CommitmentEntry: Record "Commitment Entry";
        LineAmount: Decimal;
        GLAccount: Record "G/L Account";
        DeferralPostDate: Date;
        LoggedInUser: Code[50];
        AmountComment: Text[50];
        ChangeAmountComment: Report "Change Amount Comment";
        // NFLRequisitionCommentLine: Record "NFL Requisition Comment Line";
        Counter1: Integer;
        Counter2: Integer;
        NewCommitmentEntryNo: Integer;
        gvUserSetup: Record "User Setup";
        Text055: Label 'User %1 is not in the setup';
        Text056: Label 'The Requisition line cell can only be modified by the Budget monitoring officer';
        Text057: Label 'You can modify a document that you have already approved';

    /// <summary>
    /// Description for InitOutstanding.
    /// </summary>
    procedure InitOutstanding();
    begin
        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN BEGIN
            "Outstanding Quantity" := Quantity - "Return Qty. Shipped";
            "Outstanding Qty. (Base)" := "Quantity (Base)" - "Return Qty. Shipped (Base)";
            "Return Qty. Shipped Not Invd." := "Return Qty. Shipped" - "Quantity Invoiced";
            "Ret. Qty. Shpd Not Invd.(Base)" := "Return Qty. Shipped (Base)" - "Qty. Invoiced (Base)";
        END ELSE BEGIN
            "Outstanding Quantity" := Quantity - "Quantity Received";
            "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Received (Base)";
            "Qty. Rcd. Not Invoiced" := "Quantity Received" - "Quantity Invoiced";
            "Qty. Rcd. Not Invoiced (Base)" := "Qty. Received (Base)" - "Qty. Invoiced (Base)";
        END;
        "Completely Received" := (Quantity <> 0) AND ("Outstanding Quantity" = 0);
        InitOutstandingAmount;
    end;

    /// <summary>
    /// Description for InitOutstandingAmount.
    /// </summary>
    procedure InitOutstandingAmount();
    var
        AmountInclVAT: Decimal;
    begin
        IF Quantity = 0 THEN BEGIN
            "Outstanding Amount" := 0;
            "Outstanding Amount (LCY)" := 0;
            "Amt. Rcd. Not Invoiced" := 0;
            "Amt. Rcd. Not Invoiced (LCY)" := 0;
            "Return Shpd. Not Invd." := 0;
            "Return Shpd. Not Invd. (LCY)" := 0;
        END ELSE BEGIN
            GetReqnHeader;
            IF ReqnHeader.Status = ReqnHeader.Status::Released THEN
                AmountInclVAT := "Amount Including VAT"
            ELSE
                IF ReqnHeader."Prices Including VAT" THEN
                    AmountInclVAT := "Line Amount" - "Inv. Discount Amount"
                ELSE
                    IF "VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax" THEN BEGIN
                        IF "Use Tax" THEN
                            AmountInclVAT := "Line Amount" - "Inv. Discount Amount"
                        ELSE
                            AmountInclVAT :=
                              "Line Amount" - "Inv. Discount Amount" +
                              ROUND(
                                SalesTaxCalculate.CalculateTax(
                                  "Tax Area Code", "Tax Group Code", "Tax Liable", ReqnHeader."Posting Date",
                                  "Line Amount" - "Inv. Discount Amount", "Quantity (Base)", ReqnHeader."Currency Factor"),
                                Currency."Amount Rounding Precision")
                    END ELSE
                        AmountInclVAT :=
                          ROUND(
                            ("Line Amount" - "Inv. Discount Amount") *
                            (1 + "VAT %" / 100 * (1 - ReqnHeader."VAT Base Discount %" / 100)),
                            Currency."Amount Rounding Precision");
            VALIDATE(
              "Outstanding Amount",
              ROUND(
                AmountInclVAT * "Outstanding Quantity" / Quantity,
                Currency."Amount Rounding Precision"));
            IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
                VALIDATE(
                  "Return Shpd. Not Invd.",
                  ROUND(
                    AmountInclVAT * "Return Qty. Shipped Not Invd." / Quantity,
                    Currency."Amount Rounding Precision"))
            ELSE
                VALIDATE(
                  "Amt. Rcd. Not Invoiced",
                  ROUND(
                    AmountInclVAT * "Qty. Rcd. Not Invoiced" / Quantity,
                    Currency."Amount Rounding Precision"));
        END;
    end;

    procedure InitQtyToReceive();
    begin
        "Qty. to Receive" := "Outstanding Quantity";
        "Qty. to Receive (Base)" := "Outstanding Qty. (Base)";

        InitQtyToInvoice;
    end;

    procedure InitQtyToShip();
    begin
        "Return Qty. to Ship" := "Outstanding Quantity";
        "Return Qty. to Ship (Base)" := "Outstanding Qty. (Base)";

        InitQtyToInvoice;
    end;

    procedure InitQtyToInvoice();
    begin
        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;
        CalcInvDiscToInvoice;
        IF ReqnHeader."Document Type" <> ReqnHeader."Document Type"::"Store Return" THEN
            CalcPrepaymentToDeduct;
    end;

    local procedure InitItemAppl();
    begin
        "Appl.-to Item Entry" := 0;
    end;

    procedure MaxQtyToInvoice(): Decimal;
    begin
        IF "Prepayment Line" THEN
            EXIT(1);
        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
            EXIT("Return Qty. Shipped" + "Return Qty. to Ship" - "Quantity Invoiced")
        ELSE
            EXIT("Quantity Received" + "Qty. to Receive" - "Quantity Invoiced");
    end;

    procedure MaxQtyToInvoiceBase(): Decimal;
    begin
        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
            EXIT("Return Qty. Shipped (Base)" + "Return Qty. to Ship (Base)" - "Qty. Invoiced (Base)")
        ELSE
            EXIT("Qty. Received (Base)" + "Qty. to Receive (Base)" - "Qty. Invoiced (Base)");
    end;

    procedure CalcInvDiscToInvoice();
    var
        OldInvDiscAmtToInv: Decimal;
    begin
        GetReqnHeader;
        OldInvDiscAmtToInv := "Inv. Disc. Amount to Invoice";
        IF Quantity = 0 THEN
            VALIDATE("Inv. Disc. Amount to Invoice", 0)
        ELSE
            VALIDATE(
              "Inv. Disc. Amount to Invoice",
              ROUND(
                "Inv. Discount Amount" * "Qty. to Invoice" / Quantity,
                Currency."Amount Rounding Precision"));

        IF OldInvDiscAmtToInv <> "Inv. Disc. Amount to Invoice" THEN BEGIN
            IF ReqnHeader.Status = ReqnHeader.Status::Released THEN
                "Amount Including VAT" := "Amount Including VAT" - "VAT Difference";
            "VAT Difference" := 0;
        END;
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal;
    begin
        IF "Prod. Order No." = '' THEN
            TESTFIELD("Qty. per Unit of Measure");
        EXIT(ROUND(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure SelectItemEntry();
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SETCURRENTKEY("Item No.", Open);
        ItemLedgEntry.SETRANGE("Item No.", "No.");
        ItemLedgEntry.SETRANGE(Open, TRUE);
        ItemLedgEntry.SETRANGE(Positive, TRUE);
        IF "Location Code" <> '' THEN
            ItemLedgEntry.SETRANGE("Location Code", "Location Code");
        ItemLedgEntry.SETRANGE("Variant Code", "Variant Code");

        IF PAGE.RUNMODAL(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK THEN
            VALIDATE("Appl.-to Item Entry", ItemLedgEntry."Entry No.");
    end;

    /// <summary>
    /// Description for SetReqnHeader.
    /// </summary>
    /// <param name="NewReqnHeader">Parameter of type Record "NFL Requisition Header".</param>
    procedure SetReqnHeader(NewReqnHeader: Record "NFL Requisition Header");
    begin
        ReqnHeader := NewReqnHeader;

        IF ReqnHeader."Currency Code" = '' THEN
            Currency.InitRoundingPrecision
        ELSE BEGIN
            ReqnHeader.TESTFIELD("Currency Factor");
            Currency.GET(ReqnHeader."Currency Code");
            Currency.TESTFIELD("Amount Rounding Precision");
        END;
    end;

    /// <summary>
    /// Description for GetReqnHeader.
    /// </summary>
    local procedure GetReqnHeader();
    begin
        TESTFIELD("Document No.");
        IF ("Document Type" <> ReqnHeader."Document Type") OR ("Document No." <> ReqnHeader."No.") THEN BEGIN
            ReqnHeader.GET("Document Type", "Document No.");
            IF ReqnHeader."Currency Code" = '' THEN
                Currency.InitRoundingPrecision
            ELSE BEGIN
                ReqnHeader.TESTFIELD("Currency Factor");
                Currency.GET(ReqnHeader."Currency Code");
                Currency.TESTFIELD("Amount Rounding Precision");
            END;
        END;
    end;

    local procedure GetItem();
    begin
        TESTFIELD("No.");
        IF Item."No." <> "No." THEN
            Item.GET("No.");
    end;

    /// <summary>
    /// Description for UpdateDirectUnitCost.
    /// </summary>
    /// <param name="CalledByFieldNo">Parameter of type Integer.</param>
    local procedure UpdateDirectUnitCost(CalledByFieldNo: Integer);
    begin
        IF ((CalledByFieldNo <> CurrFieldNo) AND (CurrFieldNo <> 0)) OR
           ("Prod. Order No." <> '')
        THEN
            EXIT;

        IF Type = Type::Item THEN BEGIN
            GetReqnHeader;

            PurchPriceCalcMgt.FindPurchLinePrice(ReqnHeader, Rec, CalledByFieldNo);
            PurchPriceCalcMgt.FindPurchLineLineDisc(ReqnHeader, Rec);
            VALIDATE("Direct Unit Cost");

            IF CalledByFieldNo IN [FIELDNO("No."), FIELDNO("Variant Code"), FIELDNO("Location Code")] THEN BEGIN
                GetItem;
                ItemVend.INIT;
                ItemVend."Vendor No." := "Buy-from Vendor No.";
                ItemVend."Variant Code" := "Variant Code";
                Item.FindItemVend(ItemVend, "Location Code");
                VALIDATE("Vendor Item No.", ItemVend."Vendor Item No.");
            END;
        END;
    end;

    /// <summary>
    /// Description for UpdateUnitCost.
    /// </summary>
    procedure UpdateUnitCost();
    var
        DiscountAmountPerQty: Decimal;
    begin
        GetReqnHeader;
        GetGLSetup;
        IF Quantity = 0 THEN
            DiscountAmountPerQty := 0
        ELSE
            DiscountAmountPerQty :=
              ROUND(("Line Discount Amount" + "Inv. Discount Amount") / Quantity,
                GLSetup."Unit-Amount Rounding Precision");

        IF ReqnHeader."Prices Including VAT" THEN
            "Unit Cost" :=
              ("Direct Unit Cost" - DiscountAmountPerQty) * (1 + "Indirect Cost %" / 100) / (1 + "VAT %" / 100) +
              GetOverheadRateFCY
        ELSE
            "Unit Cost" :=
              ("Direct Unit Cost" - DiscountAmountPerQty) * (1 + "Indirect Cost %" / 100) +
              GetOverheadRateFCY;

        IF ReqnHeader."Currency Code" <> '' THEN BEGIN
            ReqnHeader.TESTFIELD("Currency Factor");
            "Unit Cost (LCY)" :=
              CurrExchRate.ExchangeAmtFCYToLCY(
                GetDate, "Currency Code",
                "Unit Cost", ReqnHeader."Currency Factor");
        END ELSE
            "Unit Cost (LCY)" := "Unit Cost";

        IF (Type = Type::Item) AND ("Prod. Order No." = '') THEN BEGIN
            GetItem;
            IF Item."Costing Method" = Item."Costing Method"::Standard THEN BEGIN
                IF GetSKU THEN
                    "Unit Cost (LCY)" := SKU."Unit Cost" * "Qty. per Unit of Measure"
                ELSE
                    "Unit Cost (LCY)" := Item."Unit Cost" * "Qty. per Unit of Measure";
            END;
        END;

        "Unit Cost (LCY)" := ROUND("Unit Cost (LCY)", GLSetup."Unit-Amount Rounding Precision");
        IF ReqnHeader."Currency Code" <> '' THEN
            Currency.TESTFIELD("Unit-Amount Rounding Precision");
        "Unit Cost" := ROUND("Unit Cost", Currency."Unit-Amount Rounding Precision");

        IF Type = Type::"Charge (Item)" THEN
            UpdateItemChargeAssgnt;

        UpdateSalesCost;

        IF TestJobTask AND NOT UpdateFromVAT THEN BEGIN
            UpdateJobJnlLine;
            JTUpdatePurchLinePrices;
        END;
    end;

    /// <summary>
    /// Description for UpdateAmounts.
    /// </summary>
    procedure UpdateAmounts();
    begin
        IF CurrFieldNo <> FIELDNO("Allow Invoice Disc.") THEN
            TESTFIELD(Type);
        GetReqnHeader;

        IF "Line Amount" <> xRec."Line Amount" THEN
            "VAT Difference" := 0;
        IF "Line Amount" <> ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") - "Line Discount Amount" THEN BEGIN
            "Line Amount" :=
              ROUND(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") - "Line Discount Amount";
            "VAT Difference" := 0;
        END;

        IF "Prepayment %" <> 0 THEN BEGIN
            IF Quantity < 0 THEN
                FIELDERROR(Quantity, STRSUBSTNO(Text043, FIELDCAPTION("Prepayment %")));
            IF "Direct Unit Cost" < 0 THEN
                FIELDERROR("Direct Unit Cost", STRSUBSTNO(Text043, FIELDCAPTION("Prepayment %")));
        END;
        IF ReqnHeader.Status = ReqnHeader.Status::Released THEN
            UpdateVATAmounts;

        InitOutstandingAmount;
        // MAG 5TH SEPT. 2018, Compute Line Amount (LCY)
        IF ReqnHeader."Currency Code" <> '' THEN BEGIN
            ReqnHeader.TESTFIELD("Currency Factor");
            "Line Amount (LCY)" :=
              CurrExchRate.ExchangeAmtFCYToLCY(
                GetDate, "Currency Code",
                "Line Amount", ReqnHeader."Currency Factor");
        END ELSE
            "Line Amount (LCY)" := "Line Amount";
        // MAG - END.
    end;

    /// <summary>
    /// Description for UpdateVATAmounts.
    /// </summary>
    local procedure UpdateVATAmounts();
    var
        PurchLine2: Record "NFL Requisition Line";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
    begin
        ReqnLine2.SETRANGE("Document Type", "Document Type");
        ReqnLine2.SETRANGE("Document No.", "Document No.");
        ReqnLine2.SETFILTER("Line No.", '<>%1', "Line No.");
        IF "Line Amount" = 0 THEN
            IF xRec."Line Amount" >= 0 THEN
                ReqnLine2.SETFILTER(Amount, '>%1', 0)
            ELSE
                ReqnLine2.SETFILTER(Amount, '<%1', 0)
        ELSE
            IF "Line Amount" > 0 THEN
                ReqnLine2.SETFILTER(Amount, '>%1', 0)
            ELSE
                ReqnLine2.SETFILTER(Amount, '<%1', 0);
        ReqnLine2.SETRANGE("VAT Identifier", "VAT Identifier");
        ReqnLine2.SETRANGE("Tax Group Code", "Tax Group Code");

        IF "Line Amount" = "Inv. Discount Amount" THEN BEGIN
            Amount := 0;
            "VAT Base Amount" := 0;
            "Amount Including VAT" := 0;
            IF "Line No." <> 0 THEN
                IF MODIFY THEN
                    IF ReqnLine2.FINDLAST THEN BEGIN
                        ReqnLine2.UpdateAmounts;
                        ReqnLine2.MODIFY;
                    END;
        END ELSE BEGIN
            TotalLineAmount := 0;
            TotalInvDiscAmount := 0;
            TotalAmount := 0;
            TotalAmountInclVAT := 0;
            TotalQuantityBase := 0;
            IF ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") OR
               (("VAT Calculation Type" IN
                 ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"]) AND ("VAT %" <> 0))
            THEN
                IF ReqnLine2.FINDSET THEN
                    REPEAT
                        TotalLineAmount := TotalLineAmount + ReqnLine2."Line Amount";
                        TotalInvDiscAmount := TotalInvDiscAmount + ReqnLine2."Inv. Discount Amount";
                        TotalAmount := TotalAmount + ReqnLine2.Amount;
                        TotalAmountInclVAT := TotalAmountInclVAT + ReqnLine2."Amount Including VAT";
                        TotalQuantityBase := TotalQuantityBase + ReqnLine2."Quantity (Base)";
                    UNTIL ReqnLine2.NEXT = 0;

            IF ReqnHeader."Prices Including VAT" THEN
                CASE "VAT Calculation Type" OF
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            Amount :=
                              ROUND(
                                (TotalLineAmount - TotalInvDiscAmount + "Line Amount" - "Inv. Discount Amount") / (1 + "VAT %" / 100),
                                Currency."Amount Rounding Precision") -
                              TotalAmount;
                            "VAT Base Amount" :=
                              ROUND(
                                Amount * (1 - ReqnHeader."VAT Base Discount %" / 100),
                                Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              TotalLineAmount + "Line Amount" -
                              ROUND(
                                (TotalAmount + Amount) * (ReqnHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT;
                        END;
                    "VAT Calculation Type"::"Full VAT":
                        BEGIN
                            Amount := 0;
                            "VAT Base Amount" := 0;
                        END;
                    "VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            ReqnHeader.TESTFIELD("VAT Base Discount %", 0);
                            "Amount Including VAT" :=
                              ROUND("Line Amount" - "Inv. Discount Amount", Currency."Amount Rounding Precision");
                            IF "Use Tax" THEN
                                Amount := "Amount Including VAT"
                            ELSE
                                Amount :=
                                  ROUND(
                                    SalesTaxCalculate.ReverseCalculateTax(
                                      "Tax Area Code", "Tax Group Code", "Tax Liable", ReqnHeader."Posting Date",
                                      TotalAmountInclVAT + "Amount Including VAT", TotalQuantityBase + "Quantity (Base)",
                                      ReqnHeader."Currency Factor"),
                                    Currency."Amount Rounding Precision") -
                                  TotalAmount;
                            "VAT Base Amount" := Amount;
                            IF "VAT Base Amount" <> 0 THEN
                                "VAT %" :=
                                  ROUND(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount", 0.00001)
                            ELSE
                                "VAT %" := 0;
                        END;
                END
            ELSE
                CASE "VAT Calculation Type" OF
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            Amount := ROUND("Line Amount" - "Inv. Discount Amount", Currency."Amount Rounding Precision");
                            "VAT Base Amount" :=
                              ROUND(Amount * (1 - ReqnHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              TotalAmount + Amount +
                              ROUND(
                                (TotalAmount + Amount) * (1 - ReqnHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT;
                        END;
                    "VAT Calculation Type"::"Full VAT":
                        BEGIN
                            Amount := 0;
                            "VAT Base Amount" := 0;
                            "Amount Including VAT" := "Line Amount" - "Inv. Discount Amount";
                        END;
                    "VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            Amount := ROUND("Line Amount" - "Inv. Discount Amount", Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                            IF "Use Tax" THEN
                                "Amount Including VAT" := Amount
                            ELSE
                                "Amount Including VAT" :=
                                  TotalAmount + Amount +
                                  ROUND(
                                    SalesTaxCalculate.CalculateTax(
                                      "Tax Area Code", "Tax Group Code", "Tax Liable", ReqnHeader."Posting Date",
                                      (TotalAmount + Amount), (TotalQuantityBase + "Quantity (Base)"),
                                      ReqnHeader."Currency Factor"),
                                    Currency."Amount Rounding Precision") -
                                  TotalAmountInclVAT;
                            IF "VAT Base Amount" <> 0 THEN
                                "VAT %" :=
                                  ROUND(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount", 0.00001)
                            ELSE
                                "VAT %" := 0;
                        END;
                END;
        END;
    end;

    /// <summary>
    /// Description for UpdateSalesCost.
    /// </summary>
    local procedure UpdateSalesCost();
    begin
        CASE TRUE OF
            "Sales Order Line No." <> 0:
                // Drop Shipment
                SalesOrderLine.GET(
                  SalesOrderLine."Document Type"::Order,
                  "Sales Order No.",
                  "Sales Order Line No.");
            "Special Order Sales Line No." <> 0:
                // Special Order
                BEGIN
                    IF NOT
                      SalesOrderLine.GET(
                        SalesOrderLine."Document Type"::Order,
                        "Special Order Sales No.",
                        "Special Order Sales Line No.")
                    THEN
                        EXIT;
                END;
            ELSE
                EXIT;
        END;
        SalesOrderLine."Unit Cost (LCY)" := "Unit Cost (LCY)" * SalesOrderLine."Qty. per Unit of Measure" / "Qty. per Unit of Measure";
        SalesOrderLine."Unit Cost" := "Unit Cost" * SalesOrderLine."Qty. per Unit of Measure" / "Qty. per Unit of Measure";
        SalesOrderLine.VALIDATE("Unit Cost (LCY)");
        IF NOT RECORDLEVELLOCKING THEN
            LOCKTABLE(TRUE, TRUE);
        SalesOrderLine.MODIFY;
    end;

    /// <summary>
    /// Description for GetFAPostingGroup.
    /// </summary>
    local procedure GetFAPostingGroup();
    var
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
    begin
        IF (Type <> Type::"Fixed Asset") OR ("No." = '') THEN
            EXIT;
        IF "Depreciation Book Code" = '' THEN BEGIN
            FASetup.GET;
            "Depreciation Book Code" := FASetup."Default Depr. Book";
            IF NOT FADeprBook.GET("No.", "Depreciation Book Code") THEN
                "Depreciation Book Code" := '';
            IF "Depreciation Book Code" = '' THEN
                EXIT;
        END;
        IF "FA Posting Type" = "FA Posting Type"::" " THEN
            "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
        FADeprBook.GET("No.", "Depreciation Book Code");
        FADeprBook.TESTFIELD("FA Posting Group");
        FAPostingGr.GET(FADeprBook."FA Posting Group");
        IF "FA Posting Type" = "FA Posting Type"::"Acquisition Cost" THEN BEGIN
            FAPostingGr.TESTFIELD("Acquisition Cost Account");
            LocalGLAcc.GET(FAPostingGr."Acquisition Cost Account");
            "G/L Expense A/c" := FAPostingGr."Acquisition Cost Account"; // MAG 16TH SEPT 2017
        END ELSE BEGIN
            FAPostingGr.TESTFIELD("Maintenance Expense Account");
            LocalGLAcc.GET(FAPostingGr."Maintenance Expense Account");
            "G/L Expense A/c" := FAPostingGr."Maintenance Expense Account"; // MAG 16TH SEPT 2017
        END;
        LocalGLAcc.CheckGLAcc;
        LocalGLAcc.TESTFIELD("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        "Gen. Prod. Posting Group" := LocalGLAcc."Gen. Prod. Posting Group";
        "Tax Group Code" := LocalGLAcc."Tax Group Code";
        VALIDATE("VAT Prod. Posting Group", LocalGLAcc."VAT Prod. Posting Group");
    end;

    /// <summary>
    /// Description for UpdateUOMQtyPerStockQty.
    /// </summary>
    procedure UpdateUOMQtyPerStockQty();
    begin
        GetItem;
        "Unit Cost (LCY)" := Item."Unit Cost" * "Qty. per Unit of Measure";
        "Unit Price (LCY)" := Item."Unit Price" * "Qty. per Unit of Measure";
        GetReqnHeader;
        IF ReqnHeader."Currency Code" <> '' THEN
            "Unit Cost" :=
              CurrExchRate.ExchangeAmtLCYToFCY(
                GetDate, ReqnHeader."Currency Code",
                "Unit Cost (LCY)", ReqnHeader."Currency Factor")
        ELSE
            "Unit Cost" := "Unit Cost (LCY)";
        UpdateDirectUnitCost(FIELDNO("Unit of Measure Code"));
    end;

    /// <summary>
    /// Description for ShowReservation.
    /// </summary>
    procedure ShowReservation();
    begin
        TESTFIELD(Type, Type::Item);
        TESTFIELD("Prod. Order No.", '');
        TESTFIELD("No.");
        CLEAR(Reservation);
        //Reservation.SetNFLReqLine(Rec);
        Reservation.RUNMODAL;
    end;

    /// <summary>
    /// Description for ShowReservationEntries.
    /// </summary>
    /// <param name="Modal">Parameter of type Boolean.</param>
    procedure ShowReservationEntries(Modal: Boolean);
    begin
        TESTFIELD(Type, Type::Item);
        TESTFIELD("No.");
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, TRUE);
        //ReservePurchLine.FilterReservFor(ReservEntry,Rec);
        IF Modal THEN
            PAGE.RUNMODAL(PAGE::"Reservation Entries", ReservEntry)
        ELSE
            PAGE.RUN(PAGE::"Reservation Entries", ReservEntry);
    end;

    /// <summary>
    /// Description for GetDate.
    /// </summary>
    /// <returns>Return variable "Date".</returns>
    procedure GetDate(): Date;
    begin
        IF ("Document Type" IN ["Document Type"::"HR Cash Voucher", "Document Type"::"Store Requisition"]) AND
           (ReqnHeader."Posting Date" = 0D)
        THEN
            EXIT(WORKDATE);
        EXIT(ReqnHeader."Posting Date");
    end;

    /// <summary>
    /// Description for Signed.
    /// </summary>
    /// <param name="Value">Parameter of type Decimal.</param>
    /// <returns>Return variable "Decimal".</returns>
    procedure Signed(Value: Decimal): Decimal;
    begin
        CASE "Document Type" OF
            "Document Type"::"Store Requisition",
          "Document Type"::"Purchase Requisition",
          "Document Type"::"Store Return",
          "Document Type"::"HR Cash Voucher":
                EXIT(Value);
            "Document Type"::"Imprest Cash Voucher",
          "Document Type"::"Cash Voucher":
                EXIT(-Value);
        END;
    end;

    /// <summary>
    /// ItemAvailability.
    /// </summary>
    /// <param name="AvailabilityType">Option Date,Variant,Location,Bin.</param>
    procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin);
    begin
        TESTFIELD(Type, Type::Item);
        TESTFIELD("No.");
        Item.RESET;
        Item.GET("No.");
        Item.SETRANGE("No.", "No.");
        Item.SETRANGE("Date Filter", 0D, "Expected Receipt Date");

        CASE AvailabilityType OF
            AvailabilityType::Date:
                BEGIN
                    Item.SETRANGE("Variant Filter", "Variant Code");
                    Item.SETRANGE("Location Filter", "Location Code");
                    CLEAR(ItemAvailByDate);
                    ItemAvailByDate.LOOKUPMODE(TRUE);
                    ItemAvailByDate.SETRECORD(Item);
                    ItemAvailByDate.SETTABLEVIEW(Item);
                    IF ItemAvailByDate.RUNMODAL = ACTION::LookupOK THEN
                        IF "Expected Receipt Date" <> ItemAvailByDate.GetLastDate THEN
                            IF CONFIRM(
                                 Text014, TRUE, FIELDCAPTION("Expected Receipt Date"),
                                 "Expected Receipt Date", ItemAvailByDate.GetLastDate)
                            THEN
                                VALIDATE("Expected Receipt Date", ItemAvailByDate.GetLastDate);
                END;
            AvailabilityType::Variant:
                BEGIN
                    Item.SETRANGE("Location Filter", "Location Code");
                    CLEAR(ItemAvailByVar);
                    ItemAvailByVar.LOOKUPMODE(TRUE);
                    ItemAvailByVar.SETRECORD(Item);
                    ItemAvailByVar.SETTABLEVIEW(Item);
                    IF ItemAvailByVar.RUNMODAL = ACTION::LookupOK THEN
                        IF "Variant Code" <> ItemAvailByVar.GetLastVariant THEN
                            IF CONFIRM(
                                 Text014, TRUE, FIELDCAPTION("Variant Code"), "Variant Code",
                                 ItemAvailByVar.GetLastVariant)
                            THEN
                                VALIDATE("Variant Code", ItemAvailByVar.GetLastVariant);
                END;
            AvailabilityType::Location:
                BEGIN
                    Item.SETRANGE("Variant Filter", "Variant Code");
                    CLEAR(ItemAvailByLoc);
                    ItemAvailByLoc.LOOKUPMODE(TRUE);
                    ItemAvailByLoc.SETRECORD(Item);
                    ItemAvailByLoc.SETTABLEVIEW(Item);
                    IF ItemAvailByLoc.RUNMODAL = ACTION::LookupOK THEN
                        IF "Location Code" <> ItemAvailByLoc.GetLastLocation THEN
                            IF CONFIRM(
                                 Text014, TRUE, FIELDCAPTION("Location Code"), "Location Code",
                                 ItemAvailByLoc.GetLastLocation)
                            THEN
                                VALIDATE("Location Code", ItemAvailByLoc.GetLastLocation);
                END;
        END;
    end;

    /// <summary>
    /// BlanketOrderLookup.
    /// </summary>
    procedure BlanketOrderLookup();
    begin
        ReqnLine2.RESET;
        ReqnLine2.SETCURRENTKEY("Document Type", Type, "No.");
        ReqnLine2.SETRANGE("Document Type", "Document Type"::"HR Cash Voucher");
        ReqnLine2.SETRANGE(Type, Type);
        ReqnLine2.SETRANGE("No.", "No.");
        ReqnLine2.SETRANGE("Pay-to Vendor No.", "Pay-to Vendor No.");
        ReqnLine2.SETRANGE("Buy-from Vendor No.", "Buy-from Vendor No.");
        IF PAGE.RUNMODAL(PAGE::"Purchase Lines", ReqnLine2) = ACTION::LookupOK THEN BEGIN
            ReqnLine2.TESTFIELD("Document Type", "Document Type"::"HR Cash Voucher");
            "Blanket Order No." := ReqnLine2."Document No.";
            VALIDATE("Blanket Order Line No.", ReqnLine2."Line No.");
        END;
    end;

    /// <summary>
    /// BlockDynamicTracking.
    /// </summary>
    /// <param name="SetBlock">Boolean.</param>
    procedure BlockDynamicTracking(SetBlock: Boolean);
    begin
        TrackingBlocked := SetBlock;
        ReservePurchLine.Block(SetBlock);
    end;

    /// <summary>
    /// ShowDimensions.
    /// </summary>
    procedure ShowDimensions();
    begin
        /*TESTFIELD("Document No.");
        TESTFIELD("Line No.");
        DocDim.SETRANGE("Table ID",DATABASE::"NFL Requisition Line");
        IF "Document Type"= "Document Type"::"Store Requisition" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Store Requisition");
        IF "Document Type"= "Document Type"::"Purchase Requisition" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Purchase Requisition");
        IF "Document Type"= "Document Type"::"Store Return" THEN
          DocDim.SETRANGE("Document Type",DocDim."Document Type"::"Store Return"); //CSM
        DocDim.SETRANGE("Document No.","Document No.");
        DocDim.SETRANGE("Line No.","Line No.");
        DocDimensions.SETTABLEVIEW(DocDim);
        DocDimensions.RUNMODAL;*/

        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2 %3', "Document Type", "Document No.", "Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

    end;

    /// <summary>
    /// Description for OpenItemTrackingLines.
    /// </summary>
    procedure OpenItemTrackingLines();
    begin
        TESTFIELD(Type, Type::Item);
        TESTFIELD("No.");
        IF "Prod. Order No." <> '' THEN
            ERROR(Text031, "Prod. Order No.");

        TESTFIELD("Qty To Transfer to Item Jnl");

        // ReserveReqLine.CallItemTracking(Rec);
    end;

    /// <summary>
    /// Description for CreateDim.
    /// </summary>
    /// <param name="Type1">Parameter of type Integer.</param>
    /// <param name="No1">Parameter of type Code[20].</param>
    /// <param name="Type2">Parameter of type Integer.</param>
    /// <param name="No2">Parameter of type Code[20].</param>
    /// <param name="Type3">Parameter of type Integer.</param>
    /// <param name="No3">Parameter of type Code[20].</param>
    /// <param name="Type4">Parameter of type Integer.</param>
    /// <param name="No4">Parameter of type Code[20].</param>
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20]);
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
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

        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID, No, SourceCodeSetup.Purchases, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            Rec."Dimension Set ID", DATABASE::Vendor);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");


        /*DimMgt.GetPreviousDocDefaultDim(
          DATABASE::"NFL Requisition Header","Document Type","Document No.",0,
          DATABASE::Vendor,"Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        DimMgt.GetDefaultDim(
          TableID,No,SourceCodeSetup.Purchases,
          "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        IF "Line No." <> 0 THEN
          DimMgt.UpdateDocDefaultDim(
            DATABASE::"NFL Requisition Line","Document Type","Document No.","Line No.",
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code"); */

    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        /*DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
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
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);  */

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        // MAG 6TH AUG. 2018
        VALIDATE("Balance on Budget as at Date");
        VALIDATE("Balance on Budget for the Year");
        VALIDATE("Bal. on Budget for the Quarter");
        VALIDATE("Bal. on Budget for the Month");
        // MAG - END.

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
    /// Description for GetSKU.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GetSKU(): Boolean;
    begin
        TESTFIELD("No.");
        IF (SKU."Location Code" = "Location Code") AND
           (SKU."Item No." = "No.") AND
           (SKU."Variant Code" = "Variant Code")
        THEN
            EXIT(TRUE);
        IF SKU.GET("Location Code", "No.", "Variant Code") THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    /// <summary>
    /// Description for ShowItemChargeAssgnt.
    /// </summary>
    procedure ShowItemChargeAssgnt();
    var
        ItemChargeAssgnts: Page "Item Charge Assignment (Purch)";
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
    begin
        GET("Document Type", "Document No.", "Line No.");
        TESTFIELD(Type, Type::"Charge (Item)");
        TESTFIELD("No.");
        TESTFIELD(Quantity);

        ItemChargeAssgntPurch.RESET;
        ItemChargeAssgntPurch.SETRANGE("Document Type", "Document Type");
        ItemChargeAssgntPurch.SETRANGE("Document No.", "Document No.");
        ItemChargeAssgntPurch.SETRANGE("Document Line No.", "Line No.");
        ItemChargeAssgntPurch.SETRANGE("Item Charge No.", "No.");
        IF NOT ItemChargeAssgntPurch.FINDLAST THEN BEGIN
            ItemChargeAssgntPurch."Document Type" := "Document Type";
            ItemChargeAssgntPurch."Document No." := "Document No.";
            ItemChargeAssgntPurch."Document Line No." := "Line No.";
            ItemChargeAssgntPurch."Item Charge No." := "No.";
            GetReqnHeader;
            IF ("Inv. Discount Amount" = 0) AND (NOT ReqnHeader."Prices Including VAT") THEN
                ItemChargeAssgntPurch."Unit Cost" := "Unit Cost"
            ELSE
                IF ReqnHeader."Prices Including VAT" THEN
                    ItemChargeAssgntPurch."Unit Cost" :=
                      ROUND(
                        ("Line Amount" - "Inv. Discount Amount") / Quantity / (1 + "VAT %" / 100),
                        Currency."Unit-Amount Rounding Precision")
                ELSE
                    ItemChargeAssgntPurch."Unit Cost" :=
                      ROUND(
                        ("Line Amount" - "Inv. Discount Amount") / Quantity,
                        Currency."Unit-Amount Rounding Precision");
        END;

        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN
            AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch, "Return Shipment No.")
        ELSE
            AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch, "Receipt No.");
        CLEAR(AssignItemChargePurch);
        COMMIT;

        //ItemChargeAssgnts.Initialize(Rec,ItemChargeAssgntPurch."Unit Cost");
        ItemChargeAssgnts.RUNMODAL;
        CALCFIELDS("Qty. to Assign");
    end;

    procedure UpdateItemChargeAssgnt();
    begin
        CALCFIELDS("Qty. Assigned");
        IF "Quantity Invoiced" > "Qty. Assigned" THEN
            ERROR(Text032, FIELDCAPTION("Quantity Invoiced"), FIELDCAPTION("Qty. Assigned"));
        ItemChargeAssgntPurch.RESET;
        ItemChargeAssgntPurch.SETRANGE("Document Type", "Document Type");
        ItemChargeAssgntPurch.SETRANGE("Document No.", "Document No.");
        ItemChargeAssgntPurch.SETRANGE("Document Line No.", "Line No.");
        IF (CurrFieldNo <> 0) AND ("Unit Cost" <> xRec."Unit Cost") THEN BEGIN
            ItemChargeAssgntPurch.SETFILTER("Qty. Assigned", '<>0');
            IF ItemChargeAssgntPurch.FINDFIRST THEN
                ERROR(Text022,
                  FIELDCAPTION("Unit Cost"));
            ItemChargeAssgntPurch.SETRANGE("Qty. Assigned");
        END;

        IF (CurrFieldNo <> 0) AND (Quantity <> xRec.Quantity) THEN BEGIN
            ItemChargeAssgntPurch.SETFILTER("Qty. Assigned", '<>0');
            IF ItemChargeAssgntPurch.FINDFIRST THEN
                ERROR(Text022,
                  FIELDCAPTION(Quantity));
            ItemChargeAssgntPurch.SETRANGE("Qty. Assigned");
        END;

        IF ItemChargeAssgntPurch.FINDSET THEN BEGIN
            GetReqnHeader;
            REPEAT
                IF ("Inv. Discount Amount" = 0) AND (NOT ReqnHeader."Prices Including VAT") THEN BEGIN
                    IF ItemChargeAssgntPurch."Unit Cost" <> "Unit Cost" THEN BEGIN
                        ItemChargeAssgntPurch."Unit Cost" := "Unit Cost";
                        ItemChargeAssgntPurch.VALIDATE("Qty. to Assign");
                        ItemChargeAssgntPurch.MODIFY;
                    END;
                END ELSE
                    IF ReqnHeader."Prices Including VAT" THEN BEGIN
                        IF ItemChargeAssgntPurch."Unit Cost" <> ROUND(
                             ("Line Amount" - "Inv. Discount Amount") / Quantity / (1 + "VAT %" / 100),
                             Currency."Unit-Amount Rounding Precision")
                        THEN BEGIN
                            ItemChargeAssgntPurch."Unit Cost" :=
                              ROUND(
                                ("Line Amount" - "Inv. Discount Amount") / Quantity / (1 + "VAT %" / 100),
                                Currency."Unit-Amount Rounding Precision");
                            ItemChargeAssgntPurch.VALIDATE("Qty. to Assign");
                            ItemChargeAssgntPurch.MODIFY;
                        END;
                    END ELSE
                        IF ItemChargeAssgntPurch."Unit Cost" <> ROUND(
                             ("Line Amount" - "Inv. Discount Amount") / Quantity,
                             Currency."Unit-Amount Rounding Precision")
                        THEN BEGIN
                            ItemChargeAssgntPurch."Unit Cost" :=
                              ROUND(
                                ("Line Amount" - "Inv. Discount Amount") / Quantity,
                                Currency."Unit-Amount Rounding Precision");
                            ItemChargeAssgntPurch.VALIDATE("Qty. to Assign");
                            ItemChargeAssgntPurch.MODIFY;
                        END;
            UNTIL ItemChargeAssgntPurch.NEXT = 0;
            CALCFIELDS("Qty. to Assign");
        END;
    end;

    /// <summary>
    /// Description for DeleteItemChargeAssgnt.
    /// </summary>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocLineNo">Parameter of type Integer.</param>
    local procedure DeleteItemChargeAssgnt(DocType: Option; DocNo: Code[20]; DocLineNo: Integer);
    begin
        ItemChargeAssgntPurch.SETCURRENTKEY(
          "Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.");
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Type", DocType);
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. No.", DocNo);
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Line No.", DocLineNo);
        IF NOT ItemChargeAssgntPurch.ISEMPTY THEN
            ItemChargeAssgntPurch.DELETEALL(TRUE);
    end;

    /// <summary>
    /// Description for DeleteChargeChargeAssgnt.
    /// </summary>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocLineNo">Parameter of type Integer.</param>
    local procedure DeleteChargeChargeAssgnt(DocType: Option; DocNo: Code[20]; DocLineNo: Integer);
    begin
        IF "Quantity Invoiced" <> 0 THEN BEGIN
            CALCFIELDS("Qty. Assigned");
            TESTFIELD("Qty. Assigned", "Quantity Invoiced");
        END;
        ItemChargeAssgntPurch.RESET;
        ItemChargeAssgntPurch.SETRANGE("Document Type", DocType);
        ItemChargeAssgntPurch.SETRANGE("Document No.", DocNo);
        ItemChargeAssgntPurch.SETRANGE("Document Line No.", DocLineNo);
        IF NOT ItemChargeAssgntPurch.ISEMPTY THEN
            ItemChargeAssgntPurch.DELETEALL;
    end;

    /// <summary>
    /// Description for CheckItemChargeAssgnt.
    /// </summary>
    procedure CheckItemChargeAssgnt();
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.SETCURRENTKEY(
          "Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.");
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Type", "Document Type");
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. No.", "Document No.");
        ItemChargeAssgntPurch.SETRANGE("Applies-to Doc. Line No.", "Line No.");
        ItemChargeAssgntPurch.SETRANGE("Document Type", "Document Type");
        ItemChargeAssgntPurch.SETRANGE("Document No.", "Document No.");
        IF ItemChargeAssgntPurch.FINDSET THEN BEGIN
            TESTFIELD("Allow Item Charge Assignment");
            REPEAT
                ItemChargeAssgntPurch.TESTFIELD("Qty. to Assign", 0);
            UNTIL ItemChargeAssgntPurch.NEXT = 0;
        END;
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
        Field.GET(DATABASE::"NFL Requisition Line", FieldNumber);
        EXIT(Field."Field Caption");
    end;

    /// <summary>
    /// Description for GetCaptionClass.
    /// </summary>
    /// <param name="FieldNumber">Parameter of type Integer.</param>
    /// <returns>Return variable "Text[80]".</returns>
    local procedure GetCaptionClass(FieldNumber: Integer): Text[80];
    begin
        IF NOT ReqnHeader.GET("Document Type", "Document No.") THEN BEGIN
            ReqnHeader."No." := '';
            ReqnHeader.INIT;
        END;
        IF ReqnHeader."Prices Including VAT" THEN
            EXIT('2,1,' + GetFieldCaption(FieldNumber))
        ELSE
            EXIT('2,0,' + GetFieldCaption(FieldNumber));
    end;

    /// <summary>
    /// Description for TestStatusOpen.
    /// </summary>
    local procedure TestStatusOpen();
    begin
        IF StatusCheckSuspended THEN
            EXIT;
        GetReqnHeader;

        //IF Type <> Type::" " THEN
        //ReqnHeader.TESTFIELD(Status,ReqnHeader.Status::Open); // Original code commeted out by MAG

        // MAG 12TH SEPT. 2018, Amount can be changed by procurement even when the order is released but with a comment.
        // Commitment that was created when the document was released must be reversed and a new commitment with a new amount registered.
        IF Type <> Type::" " THEN
            IF ("Direct Unit Cost" <> xRec."Direct Unit Cost") OR (Quantity <> xRec.Quantity) THEN BEGIN
                IF ReqnHeader.Status = ReqnHeader.Status::Released THEN BEGIN
                    LoggedInUser := USERID;
                    CheckPermissionsForChangingAmount(LoggedInUser);
                    Counter1 := CountNFLRequisitionCommentLines("Document Type", "Document No.", "Line No.");
                    ChangeAmountComment.SetCompositeKey("Document No.", "Document Type", "Line No.", xRec."Direct Unit Cost", "Direct Unit Cost");
                    ChangeAmountComment.RUNMODAL;
                    Counter2 := CountNFLRequisitionCommentLines("Document Type", "Document No.", "Line No.");
                    IF Counter1 = Counter2 THEN
                        ERROR('Change Amount request has been Aborted!')
                    ELSE BEGIN
                        ChangeAmountComment.ReverseCommitment("Commitment Entry No.");
                        NewCommitmentEntryNo := ChangeAmountComment.CreateCommitment("Document No.", "Document Type", "Line No.", "Direct Unit Cost", Quantity);
                        VALIDATE("Commitment Entry No.", NewCommitmentEntryNo);
                    END;
                END;
            END ELSE
                ReqnHeader.TESTFIELD(Status, ReqnHeader.Status::"Pending Approval");
        // MAG - END.
    end;

    /// <summary>
    /// Description for SuspendStatusCheck.
    /// </summary>
    /// <param name="Suspend">Parameter of type Boolean.</param>
    procedure SuspendStatusCheck(Suspend: Boolean);
    begin
        StatusCheckSuspended := Suspend;
    end;

    /// <summary>
    /// Description for UpdateLeadTimeFields.
    /// </summary>
    procedure UpdateLeadTimeFields();
    var
        StartingDate: Date;
    begin
        IF Type = Type::Item THEN BEGIN
            GetReqnHeader;
            IF "Document Type" IN
               ["Document Type"::"Store Requisition", "Document Type"::"Purchase Requisition"]
            THEN
                StartingDate := ReqnHeader."Order Date"
            ELSE
                StartingDate := ReqnHeader."Posting Date";

            EVALUATE("Lead Time Calculation",
              LeadTimeMgt.PurchaseLeadTime(
                "No.", "Location Code", "Variant Code",
                "Buy-from Vendor No."));
            IF FORMAT("Lead Time Calculation") = '' THEN
                "Lead Time Calculation" := ReqnHeader."Lead Time Calculation";
            EVALUATE("Safety Lead Time", LeadTimeMgt.SafetyLeadTime("No.", "Location Code", "Variant Code"));
        END;
    end;

    /// <summary>
    /// Description for GetUpdateBasicDates.
    /// </summary>
    procedure GetUpdateBasicDates();
    begin
        GetReqnHeader;
        IF ReqnHeader."Expected Receipt Date" <> 0D THEN
            VALIDATE("Expected Receipt Date", ReqnHeader."Expected Receipt Date")
        ELSE
            VALIDATE("Order Date", ReqnHeader."Order Date");
    end;

    /// <summary>
    /// Description for UpdateDates.
    /// </summary>
    procedure UpdateDates();
    begin
        IF "Promised Receipt Date" <> 0D THEN
            VALIDATE("Promised Receipt Date")
        ELSE
            IF "Requested Receipt Date" <> 0D THEN
                VALIDATE("Requested Receipt Date")
            ELSE
                GetUpdateBasicDates;
    end;

    /// <summary>
    /// Description for InternalLeadTimeDays.
    /// </summary>
    /// <returns>Return variable "Text[30]".</returns>
    procedure InternalLeadTimeDays(): Text[30];
    var
        SafetyLeadTime: DateFormula;
        TotalDays: DateFormula;
    begin
        IF FORMAT("Safety Lead Time") = '' THEN
            EVALUATE(SafetyLeadTime, '<0D>')
        ELSE
            SafetyLeadTime := "Safety Lead Time";
        IF NOT (COPYSTR(FORMAT(SafetyLeadTime), 1, 1) IN ['+', '-']) THEN
            EVALUATE(SafetyLeadTime, '+' + FORMAT(SafetyLeadTime));
        EVALUATE(TotalDays,
          '<' +
          FORMAT(CALCDATE(FORMAT("Inbound Whse. Handling Time") +
              FORMAT(SafetyLeadTime), WORKDATE) - WORKDATE) +
          'D>');
        EXIT(FORMAT(TotalDays));
    end;

    /// <summary>
    /// Description for UpdateVATOnLines.
    /// </summary>
    /// <param name="QtyType">Parameter of type Option General,Invoicing,Shipping.</param>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="VATAmountLine">Parameter of type Record "VAT Amount Line".</param>
    procedure UpdateVATOnLines(QtyType: Option General,Invoicing,Shipping; var PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; var VATAmountLine: Record "VAT Amount Line");
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        Currency: Record Currency;
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
        InvDiscAmount: Decimal;
        LineAmountToInvoice: Decimal;
    begin
        IF QtyType = QtyType::Shipping THEN
            EXIT;
        IF ReqnHeader."Currency Code" = '' THEN
            Currency.InitRoundingPrecision
        ELSE
            Currency.GET(ReqnHeader."Currency Code");

        TempVATAmountLineRemainder.DELETEALL;

        WITH PurchLine DO BEGIN
            SETRANGE("Document Type", ReqnHeader."Document Type");
            SETRANGE("Document No.", ReqnHeader."No.");
            SETFILTER(Type, '>0');
            SETFILTER(Quantity, '<>0');
            CASE QtyType OF
                QtyType::Invoicing:
                    SETFILTER("Qty. to Invoice", '<>0');
                QtyType::Shipping:
                    SETFILTER("Qty. to Receive", '<>0');
            END;
            LOCKTABLE;
            IF FINDSET THEN
                REPEAT
                    VATAmountLine.GET("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", "Line Amount" >= 0);
                    IF VATAmountLine.Modified THEN BEGIN
                        xRecRef.GETTABLE(PurchLine);
                        IF NOT TempVATAmountLineRemainder.GET(
                             "VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", "Line Amount" >= 0)
                        THEN BEGIN
                            TempVATAmountLineRemainder := VATAmountLine;
                            TempVATAmountLineRemainder.INIT;
                            TempVATAmountLineRemainder.INSERT;
                        END;

                        IF QtyType = QtyType::General THEN
                            LineAmountToInvoice := "Line Amount"
                        ELSE
                            LineAmountToInvoice :=
                              ROUND("Line Amount" * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");

                        IF "Allow Invoice Disc." THEN BEGIN
                            IF VATAmountLine."Inv. Disc. Base Amount" = 0 THEN
                                InvDiscAmount := 0
                            ELSE BEGIN
                                IF QtyType = QtyType::General THEN
                                    LineAmountToInvoice := "Line Amount"
                                ELSE
                                    LineAmountToInvoice :=
                                      ROUND("Line Amount" * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");
                                TempVATAmountLineRemainder."Invoice Discount Amount" :=
                                  TempVATAmountLineRemainder."Invoice Discount Amount" +
                                  VATAmountLine."Invoice Discount Amount" * LineAmountToInvoice /
                                  VATAmountLine."Inv. Disc. Base Amount";
                                InvDiscAmount :=
                                  ROUND(
                                    TempVATAmountLineRemainder."Invoice Discount Amount", Currency."Amount Rounding Precision");
                                TempVATAmountLineRemainder."Invoice Discount Amount" :=
                                  TempVATAmountLineRemainder."Invoice Discount Amount" - InvDiscAmount;
                            END;
                            IF QtyType = QtyType::General THEN BEGIN
                                "Inv. Discount Amount" := InvDiscAmount;
                                CalcInvDiscToInvoice;
                            END ELSE
                                "Inv. Disc. Amount to Invoice" := InvDiscAmount;
                        END ELSE
                            InvDiscAmount := 0;
                        IF QtyType = QtyType::General THEN
                            IF ReqnHeader."Prices Including VAT" THEN BEGIN
                                IF (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount" = 0) OR
                                   ("Line Amount" = 0)
                                THEN BEGIN
                                    VATAmount := 0;
                                    NewAmountIncludingVAT := 0;
                                END ELSE BEGIN
                                    VATAmount :=
                                      TempVATAmountLineRemainder."VAT Amount" +
                                      VATAmountLine."VAT Amount" *
                                      ("Line Amount" - "Inv. Discount Amount") /
                                      (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount");
                                    NewAmountIncludingVAT :=
                                      TempVATAmountLineRemainder."Amount Including VAT" +
                                      VATAmountLine."Amount Including VAT" *
                                      ("Line Amount" - "Inv. Discount Amount") /
                                      (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount");
                                END;
                                NewAmount :=
                                  ROUND(NewAmountIncludingVAT, Currency."Amount Rounding Precision") -
                                  ROUND(VATAmount, Currency."Amount Rounding Precision");
                                NewVATBaseAmount :=
                                  ROUND(
                                    NewAmount * (1 - ReqnHeader."VAT Base Discount %" / 100),
                                    Currency."Amount Rounding Precision");
                            END ELSE BEGIN
                                IF "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" THEN BEGIN
                                    VATAmount := "Line Amount" - "Inv. Discount Amount";
                                    NewAmount := 0;
                                    NewVATBaseAmount := 0;
                                END ELSE BEGIN
                                    NewAmount := "Line Amount" - "Inv. Discount Amount";
                                    NewVATBaseAmount :=
                                      ROUND(
                                        NewAmount * (1 - ReqnHeader."VAT Base Discount %" / 100),
                                        Currency."Amount Rounding Precision");
                                    IF VATAmountLine."VAT Base" = 0 THEN
                                        VATAmount := 0
                                    ELSE
                                        VATAmount :=
                                          TempVATAmountLineRemainder."VAT Amount" +
                                          VATAmountLine."VAT Amount" * NewAmount / VATAmountLine."VAT Base";
                                END;
                                NewAmountIncludingVAT := NewAmount + ROUND(VATAmount, Currency."Amount Rounding Precision");
                            END
                        ELSE BEGIN
                            IF (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount") = 0 THEN
                                VATDifference := 0
                            ELSE
                                VATDifference :=
                                  TempVATAmountLineRemainder."VAT Difference" +
                                  VATAmountLine."VAT Difference" * (LineAmountToInvoice - InvDiscAmount) /
                                  (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount");
                            IF LineAmountToInvoice = 0 THEN
                                "VAT Difference" := 0
                            ELSE
                                "VAT Difference" := ROUND(VATDifference, Currency."Amount Rounding Precision");
                        END;

                        IF (QtyType = QtyType::General) AND (ReqnHeader.Status = ReqnHeader.Status::Released) THEN BEGIN
                            Amount := NewAmount;
                            "Amount Including VAT" := ROUND(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := NewVATBaseAmount;
                        END;
                        InitOutstanding;
                        IF NOT ((Type = Type::"Charge (Item)") AND ("Quantity Invoiced" <> "Qty. Assigned")) THEN BEGIN
                            SetUpdateFromVAT(TRUE);
                            UpdateUnitCost;
                        END;
                        MODIFY;
                        RecRef.GETTABLE(PurchLine);
                        //ChangeLogMgt.LogModification(RecRef,xRecRef); //HAK18112013

                        TempVATAmountLineRemainder."Amount Including VAT" :=
                          NewAmountIncludingVAT - ROUND(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                        TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                        TempVATAmountLineRemainder."VAT Difference" := VATDifference - "VAT Difference";
                        TempVATAmountLineRemainder.MODIFY;
                    END;
                UNTIL NEXT = 0;
            SETRANGE(Type);
            SETRANGE(Quantity);
            SETRANGE("Qty. to Invoice");
            SETRANGE("Qty. to Receive");
        END;
    end;

    /// <summary>
    /// Description for CalcVATAmountLines.
    /// </summary>
    /// <param name="QtyType">Parameter of type Option General,Invoicing,Shipping.</param>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="VATAmountLine">Parameter of type Record "290".</param>
    procedure CalcVATAmountLines(QtyType: Option General,Invoicing,Shipping; var PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; var VATAmountLine: Record "VAT Amount Line");
    var
        PrevVatAmountLine: Record "VAT Amount Line";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        QtyFactor: Decimal;
        PurchSetup: Record "Purchases & Payables Setup";
        PurchLine3: Record "NFL Requisition Line";
        RoundingLineInserted: Boolean;
        TotalVATAmount: Decimal;
    begin
        IF ReqnHeader."Currency Code" = '' THEN
            Currency.InitRoundingPrecision
        ELSE
            Currency.GET(ReqnHeader."Currency Code");

        VATAmountLine.DELETEALL;

        WITH PurchLine DO BEGIN
            SETRANGE("Document Type", ReqnHeader."Document Type");
            SETRANGE("Document No.", ReqnHeader."No.");
            SETFILTER(Type, '>0');
            SETFILTER(Quantity, '<>0');
            PurchSetup.GET;
            IF PurchSetup."Invoice Rounding" THEN BEGIN
                PurchLine3.COPYFILTERS(PurchLine);
                RoundingLineInserted := (PurchLine3.COUNT <> PurchLine.COUNT) AND NOT PurchLine."Prepayment Line";
            END;
            IF FINDSET THEN
                REPEAT
                    IF "VAT Calculation Type" IN
                       ["VAT Calculation Type"::"Reverse Charge VAT", "VAT Calculation Type"::"Sales Tax"]
                    THEN
                        "VAT %" := 0;
                    IF NOT VATAmountLine.GET(
                         "VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", "Line Amount" >= 0)
                    THEN BEGIN
                        VATAmountLine.INIT;
                        VATAmountLine."VAT Identifier" := "VAT Identifier";
                        VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                        VATAmountLine."Tax Group Code" := "Tax Group Code";
                        VATAmountLine."Use Tax" := "Use Tax";
                        VATAmountLine."VAT %" := "VAT %";
                        VATAmountLine.Modified := TRUE;
                        VATAmountLine.Positive := "Line Amount" >= 0;
                        VATAmountLine.INSERT;
                    END;
                    CASE QtyType OF
                        QtyType::General:
                            BEGIN
                                VATAmountLine.Quantity := VATAmountLine.Quantity + "Quantity (Base)";
                                VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + "Line Amount";
                                IF "Allow Invoice Disc." THEN
                                    VATAmountLine."Inv. Disc. Base Amount" :=
                                      VATAmountLine."Inv. Disc. Base Amount" + "Line Amount";
                                VATAmountLine."Invoice Discount Amount" :=
                                  VATAmountLine."Invoice Discount Amount" + "Inv. Discount Amount";
                                VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + "VAT Difference";
                                IF "Prepayment Line" THEN
                                    VATAmountLine."Includes Prepayment" := TRUE;
                                VATAmountLine.MODIFY;
                            END;
                        QtyType::Invoicing:
                            BEGIN
                                CASE TRUE OF
                                    ("Document Type" IN ["Document Type"::"Purchase Requisition", "Document Type"::"Store Return"]) AND
                                    (NOT ReqnHeader.Receive) AND ReqnHeader.Invoice AND (NOT "Prepayment Line"):
                                        BEGIN
                                            IF "Receipt No." = '' THEN BEGIN
                                                QtyFactor := GetAbsMin("Qty. to Invoice", "Qty. Rcd. Not Invoiced") / Quantity;
                                                VATAmountLine.Quantity :=
                                                  VATAmountLine.Quantity + GetAbsMin("Qty. to Invoice (Base)", "Qty. Rcd. Not Invoiced (Base)");
                                            END ELSE BEGIN
                                                QtyFactor := "Qty. to Invoice" / Quantity;
                                                VATAmountLine.Quantity := VATAmountLine.Quantity + "Qty. to Invoice (Base)";
                                            END;
                                        END;
                                    ("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND
                                    (NOT ReqnHeader.Ship) AND ReqnHeader.Invoice:
                                        BEGIN
                                            QtyFactor := GetAbsMin("Qty. to Invoice", "Return Shpd. Not Invd.") / Quantity;
                                            VATAmountLine.Quantity :=
                                              VATAmountLine.Quantity + GetAbsMin("Qty. to Invoice (Base)", "Ret. Qty. Shpd Not Invd.(Base)");
                                        END;
                                    ELSE BEGIN
                                        QtyFactor := "Qty. to Invoice" / Quantity;
                                        VATAmountLine.Quantity := VATAmountLine.Quantity + "Qty. to Invoice (Base)";
                                    END;
                                END;
                                VATAmountLine."Line Amount" :=
                                  VATAmountLine."Line Amount" +
                                  ROUND("Line Amount" * QtyFactor, Currency."Amount Rounding Precision");
                                IF "Allow Invoice Disc." THEN
                                    VATAmountLine."Inv. Disc. Base Amount" :=
                                      VATAmountLine."Inv. Disc. Base Amount" +
                                      ROUND("Line Amount" * QtyFactor, Currency."Amount Rounding Precision");
                                IF (ReqnHeader."Invoice Discount Calculation" <> ReqnHeader."Invoice Discount Calculation"::Amount) THEN
                                    VATAmountLine."Invoice Discount Amount" :=
                                      VATAmountLine."Invoice Discount Amount" +
                                      ROUND("Inv. Discount Amount" * QtyFactor, Currency."Amount Rounding Precision")
                                ELSE
                                    VATAmountLine."Invoice Discount Amount" :=
                                      VATAmountLine."Invoice Discount Amount" + "Inv. Disc. Amount to Invoice";
                                VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + "VAT Difference";
                                IF "Prepayment Line" THEN
                                    VATAmountLine."Includes Prepayment" := TRUE;
                                VATAmountLine.MODIFY;
                            END;
                        QtyType::Shipping:
                            BEGIN
                                IF "Document Type" IN
                                   ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]
                                THEN BEGIN
                                    QtyFactor := "Return Qty. to Ship" / Quantity;
                                    VATAmountLine.Quantity := VATAmountLine.Quantity + "Return Qty. to Ship (Base)";
                                END ELSE BEGIN
                                    QtyFactor := "Qty. to Receive" / Quantity;
                                    VATAmountLine.Quantity := VATAmountLine.Quantity + "Qty. to Receive (Base)";
                                END;
                                VATAmountLine."Line Amount" :=
                                  VATAmountLine."Line Amount" +
                                  ROUND("Line Amount" * QtyFactor, Currency."Amount Rounding Precision");
                                IF "Allow Invoice Disc." THEN
                                    VATAmountLine."Inv. Disc. Base Amount" :=
                                      VATAmountLine."Inv. Disc. Base Amount" +
                                      ROUND("Line Amount" * QtyFactor, Currency."Amount Rounding Precision");
                                VATAmountLine."Invoice Discount Amount" :=
                                  VATAmountLine."Invoice Discount Amount" +
                                  ROUND("Inv. Discount Amount" * QtyFactor, Currency."Amount Rounding Precision");
                                VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + "VAT Difference";
                                IF "Prepayment Line" THEN
                                    VATAmountLine."Includes Prepayment" := TRUE;
                                VATAmountLine.MODIFY;
                            END;
                    END;
                    IF RoundingLineInserted THEN
                        TotalVATAmount := TotalVATAmount + "Amount Including VAT" - Amount;
                UNTIL NEXT = 0;
            SETRANGE(Type);
            SETRANGE(Quantity);
        END;

        WITH VATAmountLine DO
            IF FINDSET THEN
                REPEAT
                    IF (PrevVatAmountLine."VAT Identifier" <> "VAT Identifier") OR
                       (PrevVatAmountLine."VAT Calculation Type" <> "VAT Calculation Type") OR
                       (PrevVatAmountLine."Tax Group Code" <> "Tax Group Code") OR
                       (PrevVatAmountLine."Use Tax" <> "Use Tax")
                    THEN
                        PrevVatAmountLine.INIT;
                    IF ReqnHeader."Prices Including VAT" THEN BEGIN
                        CASE "VAT Calculation Type" OF
                            "VAT Calculation Type"::"Normal VAT",
                            "VAT Calculation Type"::"Reverse Charge VAT":
                                BEGIN
                                    "VAT Base" :=
                                      ROUND(
                                        ("Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
                                        Currency."Amount Rounding Precision") - "VAT Difference";
                                    "VAT Amount" :=
                                      "VAT Difference" +
                                      ROUND(
                                        PrevVatAmountLine."VAT Amount" +
                                        ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference") *
                                        (1 - ReqnHeader."VAT Base Discount %" / 100),
                                        Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    "Amount Including VAT" := "VAT Base" + "VAT Amount";
                                    IF Positive THEN
                                        PrevVatAmountLine.INIT
                                    ELSE BEGIN
                                        PrevVatAmountLine := VATAmountLine;
                                        PrevVatAmountLine."VAT Amount" :=
                                          ("Line Amount" - "Invoice Discount Amount" - "VAT Base" - "VAT Difference") *
                                          (1 - ReqnHeader."VAT Base Discount %" / 100);
                                        PrevVatAmountLine."VAT Amount" :=
                                          PrevVatAmountLine."VAT Amount" -
                                          ROUND(PrevVatAmountLine."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    END;
                                END;
                            "VAT Calculation Type"::"Full VAT":
                                BEGIN
                                    "VAT Base" := 0;
                                    "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                                    "Amount Including VAT" := "VAT Amount";
                                END;
                            "VAT Calculation Type"::"Sales Tax":
                                BEGIN
                                    "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount";
                                    IF "Use Tax" THEN
                                        "VAT Base" := "Amount Including VAT"
                                    ELSE
                                        "VAT Base" :=
                                          ROUND(
                                            SalesTaxCalculate.ReverseCalculateTax(
                                              ReqnHeader."Tax Area Code", "Tax Group Code", ReqnHeader."Tax Liable",
                                              ReqnHeader."Posting Date", "Amount Including VAT", Quantity, ReqnHeader."Currency Factor"),
                                            Currency."Amount Rounding Precision");
                                    "VAT Amount" := "VAT Difference" + "Amount Including VAT" - "VAT Base";
                                    IF "VAT Base" = 0 THEN
                                        "VAT %" := 0
                                    ELSE
                                        "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base", 0.00001);
                                END;
                        END;
                    END ELSE BEGIN
                        CASE "VAT Calculation Type" OF
                            "VAT Calculation Type"::"Normal VAT",
                            "VAT Calculation Type"::"Reverse Charge VAT":
                                BEGIN
                                    "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                                    "VAT Amount" :=
                                      "VAT Difference" +
                                      ROUND(
                                        PrevVatAmountLine."VAT Amount" +
                                        "VAT Base" * "VAT %" / 100 * (1 - ReqnHeader."VAT Base Discount %" / 100),
                                        Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    "Amount Including VAT" := "Line Amount" - "Invoice Discount Amount" + "VAT Amount";
                                    IF Positive THEN
                                        PrevVatAmountLine.INIT
                                    ELSE BEGIN
                                        PrevVatAmountLine := VATAmountLine;
                                        PrevVatAmountLine."VAT Amount" :=
                                          "VAT Base" * "VAT %" / 100 * (1 - ReqnHeader."VAT Base Discount %" / 100);
                                        PrevVatAmountLine."VAT Amount" :=
                                          PrevVatAmountLine."VAT Amount" -
                                          ROUND(PrevVatAmountLine."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    END;
                                END;
                            "VAT Calculation Type"::"Full VAT":
                                BEGIN
                                    "VAT Base" := 0;
                                    "VAT Amount" := "VAT Difference" + "Line Amount" - "Invoice Discount Amount";
                                    "Amount Including VAT" := "VAT Amount";
                                END;
                            "VAT Calculation Type"::"Sales Tax":
                                BEGIN
                                    "VAT Base" := "Line Amount" - "Invoice Discount Amount";
                                    IF "Use Tax" THEN
                                        "VAT Amount" := 0
                                    ELSE
                                        "VAT Amount" :=
                                          SalesTaxCalculate.CalculateTax(
                                            ReqnHeader."Tax Area Code", "Tax Group Code", ReqnHeader."Tax Liable",
                                            ReqnHeader."Posting Date", "VAT Base", Quantity, ReqnHeader."Currency Factor");
                                    IF "VAT Base" = 0 THEN
                                        "VAT %" := 0
                                    ELSE
                                        "VAT %" := ROUND(100 * "VAT Amount" / "VAT Base", 0.00001);
                                    "VAT Amount" :=
                                      "VAT Difference" +
                                      ROUND("VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection);
                                    "Amount Including VAT" := "VAT Base" + "VAT Amount";
                                END;
                        END;
                    END;
                    IF RoundingLineInserted THEN
                        TotalVATAmount := TotalVATAmount - "VAT Amount";
                    "Calculated VAT Amount" := "VAT Amount" - "VAT Difference";
                    MODIFY;
                UNTIL NEXT = 0;

        IF RoundingLineInserted AND (TotalVATAmount <> 0) THEN
            IF VATAmountLine.GET(PurchLine."VAT Identifier", PurchLine."VAT Calculation Type",
                 PurchLine."Tax Group Code", PurchLine."Use Tax", PurchLine."Line Amount" >= 0)
            THEN BEGIN
                VATAmountLine."VAT Amount" := VATAmountLine."VAT Amount" + TotalVATAmount;
                VATAmountLine."Amount Including VAT" := VATAmountLine."Amount Including VAT" + TotalVATAmount;
                VATAmountLine."Calculated VAT Amount" := VATAmountLine."Calculated VAT Amount" + TotalVATAmount;
                VATAmountLine.MODIFY;
            END;
    end;

    /// <summary>
    /// Description for UpdateWithWarehouseReceive.
    /// </summary>
    procedure UpdateWithWarehouseReceive();
    begin
        IF Type = Type::Item THEN
            CASE TRUE OF
                ("Document Type" IN ["Document Type"::"Store Requisition", "Document Type"::"Purchase Requisition"]) AND (Quantity >= 0):
                    IF Location.RequireReceive("Location Code") THEN
                        VALIDATE("Qty. to Receive", 0)
                    ELSE
                        VALIDATE("Qty. to Receive", "Outstanding Quantity");
                ("Document Type" IN ["Document Type"::"Store Requisition", "Document Type"::"Purchase Requisition"]) AND (Quantity < 0):
                    IF Location.RequireShipment("Location Code") THEN
                        VALIDATE("Qty. to Receive", 0)
                    ELSE
                        VALIDATE("Qty. to Receive", "Outstanding Quantity");
                ("Document Type" = "Document Type"::"Imprest Cash Voucher") AND (Quantity >= 0):
                    IF Location.RequireShipment("Location Code") THEN
                        VALIDATE("Return Qty. to Ship", 0)
                    ELSE
                        VALIDATE("Return Qty. to Ship", "Outstanding Quantity");
                ("Document Type" = "Document Type"::"Imprest Cash Voucher") AND (Quantity < 0):
                    IF Location.RequireReceive("Location Code") THEN
                        VALIDATE("Return Qty. to Ship", 0)
                    ELSE
                        VALIDATE("Return Qty. to Ship", "Outstanding Quantity");
            END;
    end;

    /// <summary>
    /// Description for CheckWarehouse.
    /// </summary>
    local procedure CheckWarehouse();
    var
        Location2: Record "Location";
        WhseSetup: Record "Warehouse Setup";
        ShowDialog: Option " ",Message,Error;
        DialogText: Text[50];
    begin
        GetLocation("Location Code");
        IF "Location Code" = '' THEN BEGIN
            WhseSetup.GET;
            Location2."Require Shipment" := WhseSetup."Require Shipment";
            Location2."Require Pick" := WhseSetup."Require Pick";
            Location2."Require Receive" := WhseSetup."Require Receive";
            Location2."Require Put-away" := WhseSetup."Require Put-away";
        END ELSE
            Location2 := Location;

        DialogText := Text033;
        IF ("Document Type" IN ["Document Type"::"Purchase Requisition", "Document Type"::"Imprest Cash Voucher"]) AND
           Location2."Directed Put-away and Pick"
        THEN BEGIN
            ShowDialog := ShowDialog::Error;
            IF (("Document Type" = "Document Type"::"Purchase Requisition") AND (Quantity >= 0)) OR
               (("Document Type" = "Document Type"::"Imprest Cash Voucher") AND (Quantity < 0))
            THEN
                DialogText :=
                  DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Receive"))
            ELSE
                DialogText :=
                  DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Shipment"));
        END ELSE BEGIN
            IF (("Document Type" = "Document Type"::"Purchase Requisition") AND (Quantity >= 0) AND
                (Location2."Require Receive" OR Location2."Require Put-away")) OR
               (("Document Type" = "Document Type"::"Imprest Cash Voucher") AND (Quantity < 0) AND
                (Location2."Require Receive" OR Location2."Require Put-away"))
            THEN BEGIN
                IF WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"NFL Requisition Line",
                     "Document Type",
                     "Document No.",
                     "Line No.",
                     0,
                     Quantity)
                THEN
                    ShowDialog := ShowDialog::Error
                ELSE
                    IF Location2."Require Receive" THEN
                        ShowDialog := ShowDialog::Message;
                IF Location2."Require Receive" THEN
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Receive"))
                ELSE BEGIN
                    DialogText := Text034;
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Put-away"));
                END;
            END;

            IF (("Document Type" = "Document Type"::"Purchase Requisition") AND (Quantity < 0) AND
                (Location2."Require Shipment" OR Location2."Require Pick")) OR
               (("Document Type" = "Document Type"::"Imprest Cash Voucher") AND (Quantity >= 0) AND
                (Location2."Require Shipment" OR Location2."Require Pick"))
            THEN BEGIN
                IF WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"NFL Requisition Line",
                     "Document Type",
                     "Document No.",
                     "Line No.",
                     0,
                     Quantity)
                THEN
                    ShowDialog := ShowDialog::Error
                ELSE
                    IF Location2."Require Shipment" THEN
                        ShowDialog := ShowDialog::Message;
                IF Location2."Require Shipment" THEN
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Shipment"))
                ELSE BEGIN
                    DialogText := Text034;
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FIELDNO("Require Pick"));
                END;
            END;
        END;

        CASE ShowDialog OF
            ShowDialog::Message:
                MESSAGE(Text016 + Text017, DialogText, FIELDCAPTION("Line No."), "Line No.");
            ShowDialog::Error:
                ERROR(Text016, DialogText, FIELDCAPTION("Line No."), "Line No.")
        END
    end;

    /// <summary>
    /// Description for GetOverheadRateFCY.
    /// </summary>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetOverheadRateFCY(): Decimal;
    var
        QtyPerUOM: Decimal;
    begin
        IF "Prod. Order No." = '' THEN
            QtyPerUOM := "Qty. per Unit of Measure"
        ELSE BEGIN
            GetItem;
            QtyPerUOM := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
        END;

        EXIT(
          CurrExchRate.ExchangeAmtLCYToFCY(
            GetDate, "Currency Code", "Overhead Rate" * QtyPerUOM, ReqnHeader."Currency Factor"));
    end;

    /// <summary>
    /// Description for GetItemTranslation.
    /// </summary>
    procedure GetItemTranslation();
    begin
        GetReqnHeader;
        IF ItemTranslation.GET("No.", "Variant Code", ReqnHeader."Language Code") THEN BEGIN
            Description := ItemTranslation.Description;
            "Description 2" := ItemTranslation."Description 2";
        END;
    end;

    /// <summary>
    /// Description for GetGLSetup.
    /// </summary>
    local procedure GetGLSetup();
    begin
        IF NOT GLSetupRead THEN
            GLSetup.GET;
        GLSetupRead := TRUE;
    end;

    /// <summary>
    /// Description for AdjustDateFormula.
    /// </summary>
    /// <param name="DateFormulatoAdjust">Parameter of type DateFormula.</param>
    /// <returns>Return variable "Text[30]".</returns>
    procedure AdjustDateFormula(DateFormulatoAdjust: DateFormula): Text[30];
    begin
        IF FORMAT(DateFormulatoAdjust) <> '' THEN
            EXIT(FORMAT(DateFormulatoAdjust));
        EVALUATE(DateFormulatoAdjust, '<0D>');
        EXIT(FORMAT(DateFormulatoAdjust));
    end;

    /// <summary>
    /// Description for GetLocation.
    /// </summary>
    /// <param name="LocationCode">Parameter of type Code[10].</param>
    local procedure GetLocation(LocationCode: Code[10]);
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    /// <summary>
    /// Description for RowID1.
    /// </summary>
    /// <returns>Return variable "Text[250]".</returns>
    procedure RowID1(): Text[250];
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        EXIT(ItemTrackingMgt.ComposeRowID(DATABASE::"NFL Requisition Line", "Document Type",
            "Document No.", '', 0, "Line No."));
    end;

    /// <summary>
    /// Description for GetDefaultBin.
    /// </summary>
    local procedure GetDefaultBin();
    var
        WMSManagement: Codeunit "WMS Management";
    begin
        IF Type <> Type::Item THEN
            EXIT;

        IF (Quantity * xRec.Quantity > 0) AND
           ("No." = xRec."No.") AND
           ("Location Code" = xRec."Location Code") AND
           ("Variant Code" = xRec."Variant Code")
        THEN
            EXIT;

        "Bin Code" := '';
        IF "Drop Shipment" THEN
            EXIT;

        IF ("Location Code" <> '') AND ("No." <> '') THEN BEGIN
            GetLocation("Location Code");
            IF Location."Bin Mandatory" AND NOT Location."Directed Put-away and Pick" THEN
                WMSManagement.GetDefaultBin("No.", "Variant Code", "Location Code", "Bin Code");
        END;
    end;

    /// <summary>
    /// Description for CrossReferenceNoLookUp.
    /// </summary>
    procedure CrossReferenceNoLookUp();
    var
    // ItemCrossReference: Record "Item Cross Reference";
    begin
        IF Type = Type::Item THEN BEGIN
            // GetReqnHeader;
            // ItemCrossReference.RESET;
            // ItemCrossReference.SETCURRENTKEY("Cross-Reference Type", "Cross-Reference Type No.");
            // ItemCrossReference.SETFILTER(
            //   "Cross-Reference Type", '%1|%2',
            //   ItemCrossReference."Cross-Reference Type"::Vendor,
            //   ItemCrossReference."Cross-Reference Type"::" ");
            // ItemCrossReference.SETFILTER("Cross-Reference Type No.", '%1|%2', ReqnHeader."Buy-from Vendor No.", '');
            // IF PAGE.RUNMODAL(PAGE::cross ref, ItemCrossReference) = ACTION::LookupOK THEN BEGIN
            //     VALIDATE("Cross-Reference No.", ItemCrossReference."Cross-Reference No.");
            //     PurchPriceCalcMgt.FindPurchLinePrice(ReqnHeader, Rec, FIELDNO("Cross-Reference No."));
            //     PurchPriceCalcMgt.FindPurchLineLineDisc(ReqnHeader, Rec);
            //     VALIDATE("Direct Unit Cost");
            // END;
        END;
    end;

    /// <summary>
    /// Description for ItemExists.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure ItemExists(ItemNo: Code[20]): Boolean;
    var
        Item2: Record Item;
    begin
        IF Type = Type::Item THEN
            IF NOT Item2.GET(ItemNo) THEN
                EXIT(FALSE);
        EXIT(TRUE);
    end;

    /// <summary>
    /// Description for GetAbsMin.
    /// </summary>
    /// <param name="QtyToHandle">Parameter of type Decimal.</param>
    /// <param name="QtyHandled">Parameter of type Decimal.</param>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetAbsMin(QtyToHandle: Decimal; QtyHandled: Decimal): Decimal;
    begin
        IF ABS(QtyHandled) < ABS(QtyToHandle) THEN
            EXIT(QtyHandled)
        ELSE
            EXIT(QtyToHandle);
    end;

    /// <summary>
    /// Description for CheckApplToItemLedgEntry.
    /// </summary>
    /// <returns>Return variable "Code[10]".</returns>
    local procedure CheckApplToItemLedgEntry(): Code[10];
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        QtyBase: Decimal;
        RemainingQty: Decimal;
        ReturnedQty: Decimal;
        RemainingtobeReturnedQty: Decimal;
        ApplyRec: Record "Item Application Entry";
    begin
        IF "Appl.-to Item Entry" = 0 THEN
            EXIT;

        TESTFIELD(Type, Type::Item);
        TESTFIELD(Quantity);
        TESTFIELD("Prod. Order No.", '');
        IF "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"] THEN BEGIN
            IF Quantity < 0 THEN
                FIELDERROR(Quantity, Text029);
        END ELSE BEGIN
            IF Quantity > 0 THEN
                FIELDERROR(Quantity, Text030);
        END;
        ItemLedgEntry.GET("Appl.-to Item Entry");
        ItemLedgEntry.TESTFIELD(Positive, TRUE);

        ItemLedgEntry.TESTFIELD("Item No.", "No.");
        ItemLedgEntry.TESTFIELD("Variant Code", "Variant Code");
        CASE TRUE OF
            CurrFieldNo = Rec.FIELDNO(Quantity):
                QtyBase := "Quantity (Base)";
            "Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]:
                QtyBase := "Return Qty. to Ship (Base)";
            ELSE BEGIN
                QtyBase := "Qty. to Receive (Base)";
                ItemLedgEntry.TESTFIELD(Open, TRUE);
            END;
        END;

        IF ABS(QtyBase) > ItemLedgEntry.Quantity THEN
            ERROR(
              Text042,
              ItemLedgEntry.Quantity, ItemLedgEntry.FIELDCAPTION("Document No."),
              ItemLedgEntry."Document No.");

        IF ABS(QtyBase) > ItemLedgEntry."Remaining Quantity" THEN BEGIN
            RemainingQty := ItemLedgEntry."Remaining Quantity";
            ReturnedQty := ApplyRec.Returned(ItemLedgEntry."Entry No.");
            RemainingtobeReturnedQty := ItemLedgEntry.Quantity - ReturnedQty;
            IF NOT ("Qty. per Unit of Measure" = 0) THEN BEGIN
                RemainingQty := ROUND(RemainingQty / "Qty. per Unit of Measure", 0.00001);
                ReturnedQty := ROUND(ReturnedQty / "Qty. per Unit of Measure", 0.00001);
                RemainingtobeReturnedQty := ROUND(RemainingtobeReturnedQty / "Qty. per Unit of Measure", 0.00001);
            END;

            IF ("Document Type" IN ["Document Type"::"Imprest Cash Voucher", "Document Type"::"Cash Voucher"]) AND
               (RemainingtobeReturnedQty < ABS(QtyBase))
            THEN
                ERROR(
                  Text035,
                  ReturnedQty, ItemLedgEntry.FIELDCAPTION("Document No."),
                  ItemLedgEntry."Document No.", RemainingtobeReturnedQty);
        END;

        EXIT(ItemLedgEntry."Location Code");
    end;

    /// <summary>
    /// Description for CalcPrepaymentToDeduct.
    /// </summary>
    local procedure CalcPrepaymentToDeduct();
    begin
        IF (Quantity - "Quantity Invoiced") <> 0 THEN BEGIN
            GetReqnHeader;
            IF ReqnHeader."Prices Including VAT" THEN
                "Prepmt Amt to Deduct" :=
                  ROUND(
                    ROUND((("Prepmt. Amt. Inv." - "Prepmt Amt Deducted") * "Qty. to Invoice" / (Quantity - "Quantity Invoiced")) /
                    (1 + ("VAT %" / 100)), Currency."Amount Rounding Precision") * (1 + ("VAT %" / 100)),
                    Currency."Amount Rounding Precision")
            ELSE
                "Prepmt Amt to Deduct" :=
                  ROUND(
                   ("Prepmt. Amt. Inv." - "Prepmt Amt Deducted") * "Qty. to Invoice" / (Quantity - "Quantity Invoiced"),
                    Currency."Amount Rounding Precision");
        END ELSE
            "Prepmt Amt to Deduct" := 0
    end;

    /// <summary>
    /// Description for UpdateJobJnlLine.
    /// </summary>
    local procedure UpdateJobJnlLine();
    var
        Item2: Record Item;
    begin
        GetReqnHeader;
        ReqnHeader.TESTFIELD("Posting Date");
        CLEAR(JobJnlLine);
        JobJnlLine.DontCheckStdCost;
        JobJnlLine.VALIDATE("Job No.", "Job No.");
        JobJnlLine.VALIDATE("Job Task No.", "Job Task No.");
        JobJnlLine.VALIDATE("Posting Date", ReqnHeader."Posting Date");
        JobJnlLine.SetCurrencyFactor("Job Currency Factor");
        IF Type = Type::"G/L Account" THEN
            JobJnlLine.VALIDATE(Type, JobJnlLine.Type::"G/L Account")
        ELSE
            JobJnlLine.VALIDATE(Type, JobJnlLine.Type::Item);
        JobJnlLine.VALIDATE("No.", "No.");
        JobJnlLine.VALIDATE("Variant Code", "Variant Code");
        JobJnlLine.VALIDATE("Unit of Measure Code", "Unit of Measure Code");
        JobJnlLine.VALIDATE(Quantity, Quantity);
        IF Type = Type::Item THEN BEGIN
            Item2.GET("No.");
            IF Item2."Costing Method" = Item2."Costing Method"::Standard THEN
                JobJnlLine.VALIDATE("Unit Cost (LCY)", Item2."Standard Cost")
            ELSE
                JobJnlLine.VALIDATE("Unit Cost (LCY)", "Unit Cost (LCY)");
        END ELSE
            JobJnlLine.VALIDATE("Unit Cost (LCY)", "Unit Cost (LCY)");
        IF (CurrFieldNo = FIELDNO(Quantity)) AND (JobJnlLine."Unit Price" <> "Job Unit Price") THEN
            IF NOT CONFIRM(Text041) THEN
                JobJnlLine.VALIDATE("Unit Price", "Job Unit Price");
    end;

    /// <summary>
    /// Description for TestJobTask.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure TestJobTask(): Boolean;
    begin
        EXIT(("Job No." <> '') AND ("Job Task No." <> '') AND (Type IN [Type::"G/L Account", Type::Item]));
    end;

    /// <summary>
    /// Description for JTUpdatePurchLinePrices.
    /// </summary>
    local procedure JTUpdatePurchLinePrices();
    begin
        "Job Unit Price" := JobJnlLine."Unit Price";
        "Job Total Price" := JobJnlLine."Total Price";
        "Job Unit Price (LCY)" := JobJnlLine."Unit Price (LCY)";
        "Job Total Price (LCY)" := JobJnlLine."Total Price (LCY)";
        "Job Line Amount (LCY)" := JobJnlLine."Line Amount (LCY)";
        "Job Line Disc. Amount (LCY)" := JobJnlLine."Line Discount Amount (LCY)";
        "Job Line Amount" := JobJnlLine."Line Amount";
        "Job Line Discount %" := JobJnlLine."Line Discount %";
        "Job Line Discount Amount" := JobJnlLine."Line Discount Amount";
    end;

    /// <summary>
    /// Description for JobSetCurrencyFactor.
    /// </summary>
    procedure JobSetCurrencyFactor();
    begin
        GetReqnHeader;
        ReqnHeader.TESTFIELD("Posting Date");
        CLEAR(JobJnlLine);
        JobJnlLine.VALIDATE("Job No.", "Job No.");
        JobJnlLine.VALIDATE("Job Task No.", "Job Task No.");
        JobJnlLine.VALIDATE("Posting Date", ReqnHeader."Posting Date");
        "Job Currency Factor" := JobJnlLine."Currency Factor";
    end;

    /// <summary>
    /// Description for SetUpdateFromVAT.
    /// </summary>
    /// <param name="UpdateFromVAT2">Parameter of type Boolean.</param>
    procedure SetUpdateFromVAT(UpdateFromVAT2: Boolean);
    begin
        UpdateFromVAT := UpdateFromVAT2;
    end;

    /// <summary>
    /// Description for InitQtyToReceive2.
    /// </summary>
    procedure InitQtyToReceive2();
    begin
        "Qty. to Receive" := "Outstanding Quantity";
        "Qty. to Receive (Base)" := "Outstanding Qty. (Base)";

        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;

        CalcInvDiscToInvoice;

        CalcPrepaymentToDeduct;
    end;

    /// <summary>
    /// Description for ShowLineComments.
    /// </summary>
    procedure ShowLineComments();
    var
    // PurchCommentLine: Record "NFL Requisition Comment Line";
    // PurchCommentSheet: Page "NFL Requsition Comment Sheet";
    begin
        TESTFIELD("Document No.");
        TESTFIELD("Line No.");
        // IF "Document Type" = "Document Type"::"Purchase Requisition" THEN
        //     PurchCommentLine.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");

        // IF "Document Type" = "Document Type"::"Store Requisition" THEN
        //     PurchCommentLine.SETRANGE("Document Type", "Document Type"::"Store Requisition");

        // PurchCommentLine.SETRANGE("No.", "Document No.");
        // PurchCommentLine.SETRANGE("Document Line No.", "Line No.");
        // PurchCommentSheet.SETTABLEVIEW(PurchCommentLine);
        // PurchCommentSheet.RUNMODAL;
    end;

    /// <summary>
    /// Description for SetDefaultQuantity.
    /// </summary>
    procedure SetDefaultQuantity();
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.GET;
        IF PurchSetup."Default Qty. to Receive" = PurchSetup."Default Qty. to Receive"::Blank THEN BEGIN
            IF "Document Type" = "Document Type"::"Purchase Requisition" THEN BEGIN
                "Qty. to Receive" := 0;
                "Qty. to Receive (Base)" := 0;
                "Qty. to Invoice" := 0;
                "Qty. to Invoice (Base)" := 0;
            END;
            IF "Document Type" = "Document Type"::"Imprest Cash Voucher" THEN BEGIN
                "Return Qty. to Ship" := 0;
                "Return Qty. to Ship (Base)" := 0;
            END;
        END;
    end;

    /// <summary>
    /// Description for UpdatePrePaymentAmounts.
    /// </summary>
    local procedure UpdatePrePaymentAmounts();
    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        PurchOrderLine: Record "NFL Requisition Line";
    begin
        IF NOT ReceiptLine.GET("Receipt No.", "Receipt Line No.") THEN
            "Prepmt Amt to Deduct" := 0
        ELSE BEGIN
            IF PurchOrderLine.GET(PurchOrderLine."Document Type"::"Purchase Requisition", ReceiptLine."Order No.", ReceiptLine."Order Line No.")
          THEN
                "Prepmt Amt to Deduct" :=
                  ROUND((PurchOrderLine."Prepmt. Amt. Inv." - PurchOrderLine."Prepmt Amt Deducted") *
                         Quantity / (PurchOrderLine.Quantity - PurchOrderLine."Quantity Invoiced"), Currency."Amount Rounding Precision")
            ELSE
                "Prepmt Amt to Deduct" := 0;
        END;

        GetReqnHeader;
        IF ReqnHeader."Prices Including VAT" THEN BEGIN
            "Prepmt. Line Amount" := ROUND("Prepmt Amt to Deduct" * (1 + ("Prepayment VAT %" / 100)), Currency."Amount Rounding Precision");
            "Prepmt. Amt. Incl. VAT" := "Prepmt. Line Amount";
        END ELSE BEGIN
            "Prepmt. Line Amount" := "Prepmt Amt to Deduct";
            "Prepmt. Amt. Incl. VAT" := ROUND("Prepmt Amt to Deduct" * (1 + ("Prepayment VAT %" / 100)), Currency."Amount Rounding Precision"
          );
        END;
        "Prepmt. Amt. Inv." := "Prepmt. Line Amount";
        "Prepayment Amount" := "Prepmt Amt to Deduct";
        "Prepmt. VAT Base Amt." := "Prepmt Amt to Deduct";
        "Prepmt. Amount Inv. Incl. VAT" := "Prepmt. Line Amount";
        "Prepmt Amt Deducted" := 0;
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

    /// <summary>
    /// Description for ===CMM.
    /// </summary>
    procedure "===CMM=="();
    begin
    end;

    /// <summary>
    /// AutoReserve.
    /// </summary>
    procedure AutoReserve();
    var
        FullAutoReservation: Boolean;
    begin
        /*TESTFIELD(Type,Type::Item);
        TESTFIELD("No.");

        IF "Qty. Requested" <> 0 THEN BEGIN
          ReserveMgt.SetRequisitionLine(Rec);
          FullAutoReservation:=FALSE;
          ReserveMgt.AutoReserve(FullAutoReservation,'',WORKDATE,"Qty. Requested");
        END; */

    end;

    /// <summary>
    /// Description for ShowReqReservationEntries.
    /// </summary>
    procedure ShowReqReservationEntries();
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, TRUE);
        // ReserveReqLine.FilterReservFor(ReservEntry, Rec);
        PAGE.RUNMODAL(PAGE::"Reservation Entries", ReservEntry);
    end;

    /// <summary>
    /// Description for DeleteReservationEntries.
    /// </summary>
    procedure DeleteReservationEntries();
    begin
        CLEAR(ReserveMgt);
        //ReserveMgt.SetRequisitionLine(Rec);
        //ReserveMgt.DeleteReservEntries(TRUE,0);
        CLEAR(ReserveMgt);
    end;

    /// <summary>
    /// Description for ==CMM.
    /// </summary>
    procedure "==CMM==="();
    begin
    end;

    /// <summary>
    /// Description for CalcRunningQty.
    /// </summary>
    procedure CalcRunningQty() Qty: Decimal;
    var
        lvNFLReqLine: Record "NFL Requisition Line";
    begin
        lvNFLReqLine.SETRANGE(lvNFLReqLine."Document Type", "Document Type");
        lvNFLReqLine.SETRANGE(lvNFLReqLine."Document No.", "Document No.");
        lvNFLReqLine.SETFILTER("Line No.", '<=%1', "Line No.");
        Qty := 0;
        IF lvNFLReqLine.FINDFIRST THEN
            REPEAT
                Qty += lvNFLReqLine."Qty. Requested";
            UNTIL lvNFLReqLine.NEXT = 0;
        EXIT(Qty);
    end;

    /// <summary>
    /// Description for CalcRunningAmt.
    /// </summary>
    procedure CalcRunningAmt() Amt: Decimal;
    var
        lvNFLReqLine: Record "NFL Requisition Line";
    begin
        lvNFLReqLine.SETRANGE(lvNFLReqLine."Document Type", "Document Type");
        lvNFLReqLine.SETRANGE(lvNFLReqLine."Document No.", "Document No.");
        lvNFLReqLine.SETFILTER("Line No.", '<=%1', "Line No.");
        Amt := 0;
        IF lvNFLReqLine.FINDFIRST THEN
            REPEAT
                Amt += lvNFLReqLine."Total Cost";
            UNTIL lvNFLReqLine.NEXT = 0;
        EXIT(Amt);
    end;

    /// <summary>
    /// Description for ===MAG.
    /// </summary>
    local procedure "===MAG==="();
    begin
    end;

    /// <summary>
    /// Description for ValidateAmountRequested.
    /// </summary>
    local procedure ValidateAmountRequested();
    begin

        /*
        gvNFLReqLine.RESET;
        CLEAR(TotalAmount);
        gvNFLReqLine.SETRANGE("Document Type","Document Type");
        gvNFLReqLine.SETRANGE("Document No.","Document No.");
        IF gvNFLReqLine.FIND('-') THEN REPEAT
          TotalAmount += gvNFLReqLine."Line Amount";
        UNTIL gvNFLReqLine.NEXT = 0;

        gvNFLReqHeader.RESET;
        gvNFLReqHeader.SETRANGE("Document Type",gvNFLReqLine."Document Type");
        gvNFLReqHeader.SETRANGE("No.",gvNFLReqLine."Document No.");
        IF gvNFLReqHeader.FIND('-') THEN BEGIN
          gvNFLReqHeader."Total Amount" := TotalAmount;
          gvNFLReqHeader.MODIFY;
        END;
          */

    end;

    /// <summary>
    /// Description for CheckPermissionsForChangingAmount.
    /// </summary>
    /// <param name="Username">Parameter of type Code[50].</param>
    local procedure CheckPermissionsForChangingAmount(var Username: Code[50]);
    var
        lvUserSetup: Record "User Setup";
    begin
        // MAG 12TH SEPT. 2018
        IF NOT lvUserSetup.GET(Username) THEN
            ERROR(Username + ' not found in the User Setup')
        ELSE BEGIN
            IF lvUserSetup."Change Amount on Approved Req." = FALSE THEN
                ERROR(Username + ' has no permissions to Change Amount on Approved Purchase Requisitions');
        END;
        // MAG - END.
    end;

    /// <summary>
    /// Description for CountNFLRequisitionCommentLines.
    /// </summary>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition","Store Return".</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    /// <returns>Return variable "Integer".</returns>
    local procedure CountNFLRequisitionCommentLines(var DocType: Option "Store Requisition","Purchase Requisition","Store Return"; var DocNo: Code[20]; var LineNo: Integer): Integer;
    begin
        // MAG 13TH SEPT. 2018, Count Number of comment lines. Used later to check whether a new comment has been inserted.
        // NFLRequisitionCommentLine.SETRANGE("No.", DocNo);
        // NFLRequisitionCommentLine.SETRANGE("Document Type", DocType);
        // NFLRequisitionCommentLine.SETRANGE("Document Line No.", LineNo);
        // EXIT(NFLRequisitionCommentLine.COUNT);
        // MAG - END.
    end;

    /// <summary>
    /// Description for ApprovedByBudgetMonitorOfficer.
    /// </summary>
    local procedure ApprovedByBudgetMonitorOfficer();
    var
        lvNFLApprovalEntry: Record "Approval Entry";
        lvUserSetup: Record "User Setup";
    begin
        // Prevent Editing of lines once the budget monitoring officer has done the budget checks.
        // Editing should only happen when the NFL Approval Entry is open on the budget monitor's desk
        lvUserSetup.RESET;
        lvUserSetup.SETRANGE("User ID", USERID);
        IF lvUserSetup.FIND('-') THEN BEGIN
            IF (lvUserSetup."Budget Controller" = TRUE) OR (lvUserSetup."Change Amount on Approved Req." = TRUE) THEN BEGIN
                IF lvUserSetup."Budget Controller" = TRUE THEN BEGIN
                    lvNFLApprovalEntry.SETRANGE("Document No.", "Document No.");
                    lvNFLApprovalEntry.SETRANGE("Approver ID", lvUserSetup."User ID");
                    lvNFLApprovalEntry.SETRANGE(Status, lvNFLApprovalEntry.Status::Open);
                    IF NOT lvNFLApprovalEntry.FINDFIRST THEN
                        ERROR(Text057);
                END
            END ELSE
                ERROR(Text056)
        END ELSE
            ERROR(Text055, USERID);
    end;
}

