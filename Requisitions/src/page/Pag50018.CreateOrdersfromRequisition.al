/// <summary>
/// Page Create Orders from Requisition (ID 50211).
/// </summary>
page 50018 "Create Orders from Requisition"
{
    // version NFL02.002

    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "NFL Requisition Line";
    SourceTableView = SORTING("Document Type", "Document No.", "Line No.")
                      ORDER(Ascending)
                      WHERE("Document Type" = CONST("Purchase Requisition"),
                            "Direct Unit Cost" = FILTER(> 0),
                            Quantity = FILTER(> 0),
                            "Buy-from Vendor No." = FILTER(<> ''));

    layout
    {
        area(content)
        {
            field("Vendor No."; "Vendor No.")
            {
                Caption = 'Vendor No.';
                Lookup = true;
                LookupPageID = "Vendor List";
                TableRelation = Vendor."No.";

                trigger OnValidate();
                begin
                    SETFILTER("Buy-from Vendor No.", "Vendor No.");
                end;
            }
            repeater(Group)
            {
                field("Include in Purch. Order"; "Include in Purch. Order")
                {

                    trigger OnValidate();
                    var
                        PurchReqHeader: Record "NFL Requisition Header";
                    begin
                        IF "Include in Purch. Order" THEN BEGIN
                            PurchReqHeader.GET("Document Type", "Document No.");
                            IF (PurchReqHeader."Valid to Date" > 0D) AND (PurchReqHeader."Valid to Date" < TODAY) THEN
                                ERROR('The line is already expired');
                        END;
                    end;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    Editable = false;
                }
                field("Document No."; "Document No.")
                {
                    Editable = false;
                }
                field("No."; "No.")
                {
                    Editable = false;
                }
                field(Description; Description)
                {
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    Editable = false;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    Editable = false;
                }
                field("Line Amount"; "Line Amount")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Make Order")
            {
                Caption = 'Make Order';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    /*IF "Vendor No."='' THEN
                      ERROR('Input the Vendor No. Filter');
                    */
                    PurchaseOrderLine.SETFILTER("Document Type", FORMAT(PurchaseOrderLine."Document Type"::"Purchase Requisition"));
                    PurchaseOrderLine.SETFILTER("Buy-from Vendor No.", "Vendor No.");
                    PurchaseOrderLine.SETFILTER("Include in Purch. Order", 'YES');
                    IF NOT PurchaseOrderLine.FINDFIRST THEN
                        ERROR('No Selected Requisition Lines to include in the Order');


                    MakePurchOrder;

                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        SETFILTER("Document No.", '');

        //
        IF ExtCustCode <> '' THEN
            "Vendor No." := ExtCustCode;
    end;

    var
        "Vendor No.": Code[20];
        Text000: Label 'Do you want to Make a Purchase Order from the selected lines?';
        Text001: Label 'Order Number %1 has been Created from the selected Requisition Lines';
        "====AMI====": Integer;
        PurchaseOrderHdr: Record "Purchase Header";
        PurchaseOrderLine: Record "NFL Requisition Line";
        PurchaseOrderLine2: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        LineNo: Integer;
        ExtCustCode: Code[20];
        PurchaseReqLine: Record "NFL Requisition Line";
        ANFSetup: Record "NFL Setup";
        i: Integer;
        DocNo: array[30] of Code[20];
        DocDim: Codeunit "DimensionManagement";
        Text003: Label 'Do you want to convert the Requisition to an Order?';
        Text004: Label 'Purchase Order number %1 was created';
        Text005: Label 'Purchase Orders Number %1- %2 have been created';

    /// <summary>
    /// Description for MakePurchOrder.
    /// </summary>
    procedure MakePurchOrder();
    var
        LastVendor: Code[20];
        "====AMI====": Integer;
        PurchaseOrderHdr: Record "Purchase Header";
        PurchaseOrderLine: Record "Purchase Line";
        PurchaseOrderLine2: Record "NFL Requisition Line";
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LineNo: Integer;
        OldPurchCommentLine: Record "Purch. Comment Line";
        FromDocDim: Record "Document Dimension";
        ToDocDim: Record "Document Dimension";
        Vend: Record Vendor;
        PrevVendorNo: Code[20];
        NextDocNo: Code[20];
    begin
        /*IF NOT CONFIRM(Text000,FALSE) THEN
          EXIT;

        LineNo:=10000;
        PurchSetup.GET;

        PurchaseOrderHdr.INIT;
        PurchaseOrderHdr."Document Type":=PurchaseOrderHdr."Document Type"::Order ;
        //Increament them number series hereof
        PurchaseOrderHdr."No." := NoSeriesMgt.GetNextNo(PurchSetup."Order Nos.",TODAY,TRUE);
        PurchaseOrderHdr.VALIDATE(PurchaseOrderHdr."Buy-from Vendor No.","Vendor No." );
        PurchaseOrderHdr.INSERT(TRUE);

        LastVendor:='';
        //Insert the Line Item Line
        PurchaseOrderLine.RESET;
        PurchaseOrderLine.SETCURRENTKEY("Buy-from Vendor No.");
        PurchaseOrderLine.SETFILTER("Document Type", FORMAT(PurchaseOrderLine."Document Type"::"Purchase Requisition"));
        PurchaseOrderLine.SETFILTER("Buy-from Vendor No.","Vendor No." );
        PurchaseOrderLine.SETFILTER("Include in Purch. Order",'YES');
        IF PurchaseOrderLine.FINDSET THEN

            REPEAT

              PurchaseOrderLine2.INIT;
              PurchaseOrderLine2."Buy-from Vendor No." := "Vendor No.";
              PurchaseOrderLine2."Document Type" := PurchaseOrderLine2."Document Type"::Order;
              PurchaseOrderLine2.VALIDATE("Document No.",PurchaseOrderHdr."No.");
              PurchaseOrderLine2.VALIDATE("Buy-from Vendor No.","Vendor No.");
              PurchaseOrderLine2.VALIDATE("Pay-to Vendor No.","Vendor No.");
              PurchaseOrderLine2."Line No." := LineNo;
              PurchaseOrderLine2.Type := PurchaseOrderLine.Type;
              PurchaseOrderLine2.VALIDATE("No.",PurchaseOrderLine."No.");
              PurchaseOrderLine2.VALIDATE(Quantity,PurchaseOrderLine.Quantity);
              PurchaseOrderLine2.VALIDATE("Direct Unit Cost",PurchaseOrderLine."Direct Unit Cost");
              PurchaseOrderLine2.VALIDATE("Unit Cost (LCY)",PurchaseOrderLine."Unit Cost (LCY)");
              PurchaseOrderLine2.VALIDATE("Line Amount",PurchaseOrderLine."Line Amount");
              PurchaseOrderLine2.INSERT(TRUE);
              LineNo := LineNo + 10000;

          UNTIL PurchaseOrderLine.NEXT = 0;

        //Return the confirmation message to his highness tha valued system user!
         MESSAGE(Text001,PurchaseOrderHdr."No.");

        //But now the unchecking of lines needs to be done so the user does't uncon*** recreate another holy order
        PurchaseOrderLine.RESET;
        PurchaseOrderLine.SETFILTER("Document Type", FORMAT(PurchaseOrderLine."Document Type"::"Purchase Requisition"));
        PurchaseOrderLine.SETFILTER("Buy-from Vendor No.","Vendor No." );
        PurchaseOrderLine.SETFILTER("Include in Purch. Order",'YES');
        IF PurchaseOrderLine.FINDSET THEN
         PurchaseOrderLine.MODIFYALL("Include in Purch. Order",FALSE );
        */

        IF NOT CONFIRM(Text000, FALSE) THEN
            EXIT;

        //TESTFIELD("Document Type","Document Type"::"Purchase Requisition ");
        PurchSetup.GET;
        PurchaseReqLine.RESET;
        PurchaseReqLine.SETCURRENTKEY("Buy-from Vendor No.");
        PurchaseReqLine.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
        PurchaseReqLine.SETFILTER("Include in Purch. Order", 'YES');
        //PurchaseReqLine.SETFILTER("Document No.","No.");

        FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");
        //ToDocDim.SETRANGE("Table ID",DATABASE::"NFL Requisition Line");
        i := 0;    //to capture the first number
        PrevVendorNo := '';
        CLEAR(DocNo);
        IF PurchaseReqLine.FINDFIRST THEN BEGIN
            REPEAT
                PurchaseReqLine.TESTFIELD(PurchaseReqLine."Buy-from Vendor No.");
                IF PurchaseReqLine."Buy-from Vendor No." <> PrevVendorNo THEN   //create new header
                  BEGIN
                    Vend.GET(PurchaseReqLine."Buy-from Vendor No.");
                    Vend.CheckBlockedVendOnDocs(Vend, FALSE);
                    PurchaseOrderHdr.INIT;
                    NextDocNo := NoSeriesMgt.GetNextNo(PurchSetup."Order Nos.", TODAY, TRUE);
                    PurchaseOrderHdr."No." := NextDocNo;

                    PurchaseOrderHdr."Document Type" := PurchaseOrderHdr."Document Type"::Order;
                    PurchaseOrderHdr."Buy-from Vendor No." := PurchaseReqLine."Buy-from Vendor No.";

                    PurchaseOrderHdr."No. Printed" := 0;
                    //PurchaseOrderHdr."Store Requisition No.":= "Store Requisition No.";
                    // PurchaseOrderHdr."Purchase Requisition No.":=  "No.";
                    PurchaseOrderHdr.Status := PurchaseOrderHdr.Status::Open;
                    PurchaseOrderHdr."Order Date" := "Order Date";
                    //IF "Posting Date" <> 0D THEN
                    PurchaseOrderHdr."Posting Date" := WORKDATE;
                    PurchaseOrderHdr."Document Date" := WORKDATE;
                    // PurchaseOrderHdr."Purchase Requisition No.":= PurchaseReqLine."Document No.";
                    PurchaseOrderHdr."Expected Receipt Date" := PurchaseReqLine."Expected Receipt Date";
                    //PurchaseOrderHdr."Date Received" := 0D;
                    //PurchaseOrderHdr."Time Received" := 0T;
                    //PurchaseOrderHdr."Date Sent" := 0D;
                    //PurchaseOrderHdr."Time Sent" := 0T;


                    PurchaseOrderHdr.INSERT(TRUE);
                    PurchaseOrderHdr.VALIDATE(PurchaseOrderHdr."Buy-from Vendor No.");
                    PurchaseOrderHdr.MODIFY;
                    LineNo := 0;
                    i += 1;
                    DocNo[i] := PurchaseOrderHdr."No.";

                    //Insert the Line Item Line
                    PurchaseOrderLine2.RESET;
                    PurchaseOrderLine2.SETFILTER("Document Type", FORMAT(PurchaseOrderLine2."Document Type"::"Purchase Requisition"));
                    PurchaseOrderLine2.SETFILTER("Buy-from Vendor No.", PurchaseReqLine."Buy-from Vendor No.");
                    //PurchaseOrderLine2.SETFILTER(PurchaseOrderLine2."Document No.","No.");
                    PurchaseOrderLine2.SETFILTER("Include in Purch. Order", 'YES');
                    IF PurchaseOrderLine2.FINDSET THEN
                        REPEAT
                            LineNo += 10000;
                            PurchaseOrderLine.LOCKTABLE;
                            PurchaseOrderLine.INIT;
                            PurchaseOrderLine.TRANSFERFIELDS(PurchaseOrderLine2);
                            PurchaseOrderLine."Document Type" := PurchaseOrderLine."Document Type"::Order;
                            PurchaseOrderLine."Document No." := NextDocNo;
                            PurchaseOrderLine."Line No." := LineNo;
                            PurchaseOrderLine.INSERT(TRUE);
                            PurchaseOrderLine."Gen. Bus. Posting Group" := PurchaseOrderHdr."Gen. Bus. Posting Group";
                            PurchaseOrderLine.MODIFY;


                        UNTIL PurchaseOrderLine2.NEXT = 0;

                    //copying line dimensions to line on quote
                    FromDocDim.SETRANGE("Table ID", DATABASE::"NFL Requisition Line");

                    IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Store Requisition" THEN
                        FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Store Requisition");
                    IF PurchaseReqLine."Document Type" = PurchaseReqLine."Document Type"::"Purchase Requisition" THEN
                        FromDocDim.SETRANGE("Document Type", FromDocDim."Document Type"::"Purchase Requisition");
                    FromDocDim.SETRANGE(FromDocDim."Document No.", PurchaseReqLine."Document No.");
                    FromDocDim.SETRANGE(FromDocDim."Line No.", PurchaseReqLine."Line No.");
                    "Dimension Set ID" := PurchaseReqLine."Dimension Set ID";

                    /*DocDim.MoveDocDimToDocDim(
                    FromDocDim,
                    DATABASE::"Purchase Line",
                    PurchaseOrderHdr."No.",
                    PurchaseOrderLine."Document Type",
                    PurchaseOrderLine."Line No."); */

                    PrevVendorNo := PurchaseReqLine."Buy-from Vendor No.";

                END;
            UNTIL PurchaseReqLine.NEXT = 0;
        END;

        COMMIT;

        //Confirmation message
        IF i = 1 THEN
            MESSAGE(Text004, DocNo[1])
        ELSE
            MESSAGE(Text005, DocNo[1], DocNo[i]);


        PurchaseReqLine.RESET;
        PurchaseReqLine.SETFILTER("Document Type", FORMAT(PurchaseReqLine."Document Type"::"Purchase Requisition"));
        PurchaseReqLine.SETFILTER("Buy-from Vendor No.", "Vendor No.");
        PurchaseReqLine.SETFILTER("Include in Purch. Order", 'YES');
        IF PurchaseReqLine.FINDSET THEN
            PurchaseReqLine.MODIFYALL("Include in Purch. Order", FALSE);

    end;

    /// <summary>
    /// Description for GetVendorCode.
    /// </summary>
    /// <param name="MyCode">Parameter of type Code[20].</param>
    procedure GetVendorCode(MyCode: Code[20]);
    begin
        ExtCustCode := MyCode;
    end;

    /// <summary>
    /// Description for VendorNoOnInputChange.
    /// </summary>
    /// <param name="Text">Parameter of type Text[1024].</param>
    local procedure VendorNoOnInputChange(var Text: Text[1024]);
    begin
        SETFILTER("Buy-from Vendor No.", "Vendor No.");
    end;
}

