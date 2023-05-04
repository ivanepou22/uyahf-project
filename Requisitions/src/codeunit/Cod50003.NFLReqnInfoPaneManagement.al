/// <summary>
/// Codeunit NFL Reqn Info-Pane Management (ID 50003).
/// </summary>
codeunit 50003 "NFL Reqn Info-Pane Management"
{
    // version NFL02.001


    trigger OnRun();
    begin
    end;

    var
        Vend: Record Vendor;
        Item: Record Item;
        PurchHeader: Record "NFL Requisition Header";
        PurchPriceCalcMgt: Codeunit "NFL Purch. Price Calc. Mgt.";
        Text00011: Label 'The Ship-to Address has been changed.';

    /// <summary>
    /// Description for CalcNoOfDocuments.
    /// </summary>
    /// <param name="Vend">Parameter of type Record Vendor.</param>
    procedure CalcNoOfDocuments(var Vend: Record Vendor);
    begin
        Vend.CALCFIELDS(
          "No. of Quotes", "No. of Blanket Orders", "No. of Orders", "No. of Invoices",
          "No. of Return Orders", "No. of Credit Memos", "No. of Pstd. Return Shipments", "No. of Pstd. Invoices",
          "No. of Pstd. Receipts", "No. of Pstd. Credit Memos",
          "Buy-from No. Of Archived Doc.");
    end;

    /// <summary>
    /// Description for CalcTotalNoOfDocuments.
    /// </summary>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcTotalNoOfDocuments(VendNo: Code[20]): Integer;
    begin
        GetVend(VendNo);
        WITH Vend DO BEGIN
            CalcNoOfDocuments(Vend);
            EXIT(
              "No. of Quotes" + "No. of Blanket Orders" + "No. of Orders" + "No. of Invoices" +
              "No. of Return Orders" + "No. of Credit Memos" +
              "No. of Pstd. Receipts" + "No. of Pstd. Invoices" +
              "No. of Pstd. Return Shipments" + "No. of Pstd. Credit Memos" +
              "Buy-from No. Of Archived Doc.");
        END;
    end;

    /// <summary>
    /// Description for CalcNoOfOrderAddr.
    /// </summary>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcNoOfOrderAddr(VendNo: Code[20]): Integer;
    begin
        GetVend(VendNo);
        Vend.CALCFIELDS("No. of Order Addresses");
        EXIT(Vend."No. of Order Addresses");
    end;

    /// <summary>
    /// Description for CalcNoOfContacts.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcNoOfContacts(PurchHeader: Record "NFL Requisition Header"): Integer;
    var
        Cont: Record Contact;
        ContBusRelation: Record "Contact Business Relation";
    begin
        Cont.SETCURRENTKEY("Company No.");
        WITH PurchHeader DO
            IF "Buy-from Vendor No." <> '' THEN BEGIN
                IF Cont.GET("Buy-from Contact No.") THEN BEGIN
                    Cont.SETRANGE("Company No.", Cont."Company No.");
                    EXIT(Cont.COUNT);
                END ELSE BEGIN
                    ContBusRelation.RESET;
                    ContBusRelation.SETCURRENTKEY("Link to Table", "No.");
                    ContBusRelation.SETRANGE("Link to Table", ContBusRelation."Link to Table"::Vendor);
                    ContBusRelation.SETRANGE("No.", "Buy-from Vendor No.");
                    IF ContBusRelation.FINDFIRST THEN BEGIN
                        Cont.SETRANGE("Company No.", ContBusRelation."Contact No.");
                        EXIT(Cont.COUNT);
                    END ELSE
                        EXIT(0)
                END;
            END;
    end;

    /// <summary>
    /// Description for CalcAvailability.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Decimal".</returns>
    procedure CalcAvailability(var PurchLine: Record "NFL Requisition Line"): Decimal;
    var
        AvailableToPromise: Codeunit "Available to Promise";
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
        AvailabilityDate: Date;
        LookaheadDateFormula: DateFormula;
    begin
        IF GetItem(PurchLine) THEN BEGIN
            IF PurchLine."Expected Receipt Date" <> 0D THEN
                AvailabilityDate := PurchLine."Expected Receipt Date"
            ELSE
                AvailabilityDate := WORKDATE;

            Item.RESET;
            Item.SETRANGE("Date Filter", 0D, AvailabilityDate);
            Item.SETRANGE("Variant Filter", PurchLine."Variant Code");
            Item.SETRANGE("Location Filter", PurchLine."Location Code");
            Item.SETRANGE("Drop Shipment Filter", FALSE);

            EXIT(
              AvailableToPromise.QtyAvailabletoPromise(
                Item,
                GrossRequirement,
                ScheduledReceipt,
                AvailabilityDate,
                PeriodType,
                LookaheadDateFormula));
        END;
    end;

    /// <summary>
    /// Description for CalcNoOfSubstitutions.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcNoOfSubstitutions(var PurchLine: Record "NFL Requisition Line"): Integer;
    begin
        IF GetItem(PurchLine) THEN BEGIN
            Item.CALCFIELDS("No. of Substitutes");
            EXIT(Item."No. of Substitutes");
        END;
    end;

    /// <summary>
    /// Description for CalcNoOfPurchasePrices.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcNoOfPurchasePrices(var PurchLine: Record "NFL Requisition Line"): Integer;
    begin
        IF GetItem(PurchLine) THEN BEGIN
            GetPurchHeader(PurchLine);
            EXIT(PurchPriceCalcMgt.NoOfPurchLinePrice(PurchHeader, PurchLine, TRUE));
        END;
    end;

    /// <summary>
    /// Description for CalcNoOfPurchLineDisc.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CalcNoOfPurchLineDisc(var PurchLine: Record "NFL Requisition Line"): Integer;
    begin
        IF GetItem(PurchLine) THEN BEGIN
            GetPurchHeader(PurchLine);
            EXIT(PurchPriceCalcMgt.NoOfPurchLineLineDisc(PurchHeader, PurchLine, TRUE));
        END;
    end;

    /// <summary>
    /// Description for DocExist.
    /// </summary>
    /// <param name="CurrentPurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure DocExist(CurrentPurchHeader: Record "NFL Requisition Header"; VendNo: Code[20]): Boolean;
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ReturnShipment: Record "Return Shipment Header";
        PurchHeader: Record "NFL Requisition Header";
    begin
        IF VendNo = '' THEN
            EXIT(FALSE);
        WITH PurchInvHeader DO BEGIN
            SETCURRENTKEY("Buy-from Vendor No.");
            SETRANGE("Buy-from Vendor No.", VendNo);
            IF NOT ISEMPTY THEN
                EXIT(TRUE);
        END;
        WITH PurchRcptHeader DO BEGIN
            SETCURRENTKEY("Buy-from Vendor No.");
            SETRANGE("Buy-from Vendor No.", VendNo);
            IF NOT ISEMPTY THEN
                EXIT(TRUE);
        END;
        WITH PurchCrMemoHeader DO BEGIN
            SETCURRENTKEY("Buy-from Vendor No.");
            SETRANGE("Buy-from Vendor No.", VendNo);
            IF NOT ISEMPTY THEN
                EXIT(TRUE);
        END;
        WITH PurchHeader DO BEGIN
            SETCURRENTKEY("Buy-from Vendor No.");
            SETRANGE("Buy-from Vendor No.", VendNo);
            IF FINDFIRST THEN BEGIN
                IF ("Document Type" <> CurrentPurchHeader."Document Type") OR
                   ("No." <> CurrentPurchHeader."No.")
                THEN
                    EXIT(TRUE);
                IF FIND('>') THEN
                    EXIT(TRUE);
            END;
        END;
        WITH ReturnShipment DO BEGIN
            SETCURRENTKEY("Buy-from Vendor No.");
            SETRANGE("Buy-from Vendor No.", VendNo);
            IF NOT ISEMPTY THEN
                EXIT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for VendCommentExists.
    /// </summary>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure VendCommentExists(VendNo: Code[20]): Boolean;
    begin
        GetVend(VendNo);
        Vend.CALCFIELDS(Comment);
        EXIT(Vend.Comment);
    end;

    /// <summary>
    /// Description for ItemCommentExists.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure ItemCommentExists(var PurchLine: Record "NFL Requisition Line"): Boolean;
    begin
        IF GetItem(PurchLine) THEN BEGIN
            Item.CALCFIELDS(Comment);
            EXIT(Item.Comment);
        END;
    end;

    /// <summary>
    /// Description for LookupVendPurchaseHistory.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    /// <param name="UsePayTo">Parameter of type Boolean.</param>
    procedure LookupVendPurchaseHistory(var PurchHeader: Record "NFL Requisition Header"; VendNo: Code[20]; UsePayTo: Boolean);
    begin
        /*GetVend(VendNo);
        VendPurchHistory.SetToPurchHeader(PurchHeader,UsePayTo);
        VendPurchHistory.SETRECORD(Vend);
        VendPurchHistory.LOOKUPMODE := TRUE;
        VendPurchHistory.RUNMODAL;
        */

    end;

    /// <summary>
    /// Description for LookupOrderAddr.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    procedure LookupOrderAddr(var PurchHeader: Record "NFL Requisition Header");
    var
        OrderAddress: Record "Order Address";
    begin
        WITH PurchHeader DO BEGIN
            OrderAddress.SETRANGE("Vendor No.", "Buy-from Vendor No.");
            IF PAGE.RUNMODAL(0, OrderAddress) = ACTION::LookupOK THEN BEGIN
                VALIDATE("Order Address Code", OrderAddress.Code);
                MODIFY(TRUE);
                MESSAGE(Text00011);
            END;
        END;
    end;

    /// <summary>
    /// Description for LookupContacts.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    procedure LookupContacts(var PurchHeader: Record "NFL Requisition Header");
    var
        Cont: Record Contact;
        ContBusRelation: Record "Contact Business Relation";
    begin
        WITH PurchHeader DO BEGIN
            IF "Buy-from Vendor No." <> '' THEN BEGIN
                IF Cont.GET("Buy-from Contact No.") THEN
                    Cont.SETRANGE("Company No.", Cont."Company No.")
                ELSE BEGIN
                    ContBusRelation.RESET;
                    ContBusRelation.SETCURRENTKEY("Link to Table", "No.");
                    ContBusRelation.SETRANGE("Link to Table", ContBusRelation."Link to Table"::Vendor);
                    ContBusRelation.SETRANGE("No.", "Buy-from Vendor No.");
                    IF ContBusRelation.FINDFIRST THEN
                        Cont.SETRANGE("Company No.", ContBusRelation."Contact No.")
                    ELSE
                        Cont.SETRANGE("No.", '');
                END;

                IF Cont.GET("Buy-from Contact No.") THEN;
            END ELSE
                Cont.SETRANGE("No.", '');
            IF PAGE.RUNMODAL(0, Cont) = ACTION::LookupOK THEN BEGIN
                VALIDATE("Buy-from Contact No.", Cont."No.");
                MODIFY(TRUE);
            END;
        END;
    end;

    /// <summary>
    /// Description for LookupItem.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    procedure LookupItem(PurchLine: Record "NFL Requisition Line");
    begin
        PurchLine.TESTFIELD(Type, PurchLine.Type::Item);
        PurchLine.TESTFIELD("No.");
        GetItem(PurchLine);
        PAGE.RUNMODAL(PAGE::"Item Card", Item);
    end;

    /// <summary>
    /// Description for LookupItemComment.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    procedure LookupItemComment(PurchLine: Record "NFL Requisition Line");
    var
        CommentLine: Record "Comment Line";
    begin
        IF GetItem(PurchLine) THEN BEGIN
            CommentLine.SETRANGE("Table Name", CommentLine."Table Name"::Item);
            CommentLine.SETRANGE("No.", PurchLine."No.");
            PAGE.RUNMODAL(PAGE::"Comment Sheet", CommentLine);
        END;
    end;

    /// <summary>
    /// Description for GetVend.
    /// </summary>
    /// <param name="VendNo">Parameter of type Code[20].</param>
    local procedure GetVend(VendNo: Code[20]);
    begin
        IF VendNo <> '' THEN BEGIN
            IF VendNo <> Vend."No." THEN
                IF NOT Vend.GET(VendNo) THEN
                    CLEAR(Vend);
        END ELSE
            CLEAR(Vend);
    end;

    /// <summary>
    /// Description for GetItem.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GetItem(var PurchLine: Record "NFL Requisition Line"): Boolean;
    begin
        WITH Item DO BEGIN
            IF (PurchLine.Type <> PurchLine.Type::Item) OR (PurchLine."No." = '') THEN
                EXIT(FALSE);

            IF PurchLine."No." <> "No." THEN
                GET(PurchLine."No.");
            EXIT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for GetPurchHeader.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    local procedure GetPurchHeader(PurchLine: Record "NFL Requisition Line");
    begin
        IF (PurchLine."Document Type" <> PurchHeader."Document Type") OR
           (PurchLine."Document No." <> PurchHeader."No.")
        THEN
            PurchHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
    end;

    /// <summary>
    /// Description for CalcNoOfPayToDocuments.
    /// </summary>
    /// <param name="Vend">Parameter of type Record Vendor.</param>
    procedure CalcNoOfPayToDocuments(var Vend: Record Vendor);
    begin
        Vend.CALCFIELDS(
          "Pay-to No. of Quotes", "Pay-to No. of Blanket Orders", "Pay-to No. of Orders", "Pay-to No. of Invoices",
          "Pay-to No. of Return Orders", "Pay-to No. of Credit Memos", "Pay-to No. of Pstd. Receipts",
          "Pay-to No. of Pstd. Invoices", "Pay-to No. of Pstd. Return S.", "Pay-to No. of Pstd. Cr. Memos",
          "Pay-to No. Of Archived Doc.");
    end;

    /// <summary>
    /// Description for CalcAvailability2.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Decimal".</returns>
    procedure CalcAvailability2(var PurchLine: Record "NFL Requisition Line"): Decimal;
    var
        AvailableToPromise: Codeunit "Available to Promise";
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
        AvailabilityDate: Date;
        LookaheadDateFormula: DateFormula;
        lvItemLedgEntry: Record "Item Ledger Entry";
        lvInvtQty: Decimal;
        lvReservEntry: Record "Reservation Entry";
        lvReservedQty: Decimal;
    begin
        lvInvtQty := 0;
        IF PurchLine.Type = PurchLine.Type::Item THEN BEGIN
            lvItemLedgEntry.RESET;
            lvItemLedgEntry.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
            lvItemLedgEntry.SETRANGE(lvItemLedgEntry."Item No.", PurchLine."No.");
            lvItemLedgEntry.SETRANGE(lvItemLedgEntry."Variant Code", PurchLine."Variant Code");
            lvItemLedgEntry.SETRANGE(lvItemLedgEntry."Location Code", PurchLine."Location Code");
            lvItemLedgEntry.CALCSUMS(lvItemLedgEntry.Quantity);
            lvInvtQty := lvItemLedgEntry.Quantity;

            //get reserved quantity
            lvReservEntry.SETCURRENTKEY("Item No.", "Source Type", "Source Subtype", "Reservation Status", "Location Code", "Variant Code");
            lvReservEntry.SETRANGE(lvReservEntry."Item No.", PurchLine."No.");
            lvReservEntry.SETFILTER(lvReservEntry."Source Type", '%1', 32);
            lvReservEntry.SETFILTER(lvReservEntry."Source Subtype", '%1', 0);
            lvReservEntry.SETFILTER(lvReservEntry."Reservation Status", '%1', lvReservEntry."Reservation Status"::Reservation);
            lvReservEntry.SETRANGE(lvReservEntry."Location Code", PurchLine."Location Code");
            lvReservEntry.SETRANGE(lvReservEntry."Variant Code", PurchLine."Variant Code");
            lvReservEntry.CALCSUMS(lvReservEntry."Quantity (Base)");
            lvReservedQty := lvReservEntry."Quantity (Base)";
            EXIT(lvInvtQty - lvReservedQty);
        END
        ELSE
            EXIT(lvInvtQty);
    end;
}

