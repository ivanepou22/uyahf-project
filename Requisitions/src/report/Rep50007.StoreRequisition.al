/// <summary>
/// Report Store Requisition (ID 50057).
/// </summary>
report 50007 "Store Requisition"
{
    // version NFL02.001,6.0.02

    DefaultLayout = RDLC;
    RDLCLayout = './Store Requisition.rdlc';

    dataset
    {
        dataitem("NFL Requisition Header"; "NFL Requisition Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                WHERE("Document Type" = CONST("Store Requisition"),
                                      "No." = FILTER(<> ''));
            RequestFilterFields = "Document Type", "No.", "Request-By No.";
            column(PageConst_________FORMAT_CurrReport_PAGENO_; PageConst + ' ' + FORMAT(CurrReport.PAGENO))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(USERID; USERID)
            {
            }
            column(NFL_Requisition_Header__No__; "No.")
            {
            }
            column(NFL_Requisition_Header__Requestor_ID_; "Requestor ID")
            {
            }
            column(NFL_Requisition_Header_Status; Status)
            {
            }
            column(NFL_Requisition_Header__Request_By_No__; "Request-By No.")
            {
            }
            column(NFL_Requisition_Header__Request_By_Name_; "Request-By Name")
            {
            }
            column(NFL_Requisition_Header__Order_Date_; "Order Date")
            {
            }
            column(NFL_Requisition_Header__Expected_Receipt_Date_; "Expected Receipt Date")
            {
            }
            column(Store_RequisitionCaption; Store_RequisitionCaptionLbl)
            {
            }
            column(NOT_FOR_ISSUINGCaption; NOT_FOR_ISSUINGCaptionLbl)
            {
            }
            column(NFL_Requisition_Header__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(NFL_Requisition_Header__Requestor_ID_Caption; FIELDCAPTION("Requestor ID"))
            {
            }
            column(NFL_Requisition_Header_StatusCaption; FIELDCAPTION(Status))
            {
            }
            column(NFL_Requisition_Header__Request_By_No__Caption; FIELDCAPTION("Request-By No."))
            {
            }
            column(NFL_Requisition_Header__Request_By_Name_Caption; FIELDCAPTION("Request-By Name"))
            {
            }
            column(Request_DateCaption; Request_DateCaptionLbl)
            {
            }
            column(NFL_Requisition_Header__Expected_Receipt_Date_Caption; FIELDCAPTION("Expected Receipt Date"))
            {
            }
            column(NFL_Requisition_Header_Document_Type; "Document Type")
            {
            }
            column(Location_Name; LocationCode)
            {
            }
            dataitem("NFL Requisition Line"; "NFL Requisition Line")
            {
                DataItemLinkReference = "NFL Requisition Header";
                DataItemLink = "Document Type" = FIELD("Document Type"),
                               "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(NFL_Requisition_Line_Type; Type)
                {
                }
                column(NFL_Requisition_Line__No__; "No.")
                {
                }
                column(NFL_Requisition_Line__Location_Code_; "Location Code")
                {
                }
                column(NFL_Requisition_Line_Description; Description)
                {
                }
                column(NFL_Requisition_Line__Unit_of_Measure_; "Unit of Measure")
                {
                }
                column(NFL_Requisition_Line__Qty__Requested_; "Qty. Requested")
                {
                }
                column(NFL_Requisition_Line__Unit_Cost_; "Unit Cost")
                {
                }
                column(NFL_Requisition_Line__Total_Cost_; "Total Cost")
                {
                }
                column(NFL_Requisition_Line__Inventory_Charge_A_c_; "Inventory Charge A/c")
                {
                }
                column(NFL_Requisition_Line__Qty__Requested__Control1102754038; "Qty. Requested")
                {
                }
                column(NFL_Requisition_Line__Total_Cost__Control1102754039; "Total Cost")
                {
                }
                column(NFL_Requisition_Line_TypeCaption; FIELDCAPTION(Type))
                {
                }
                column(NFL_Requisition_Line__No__Caption; FIELDCAPTION("No."))
                {
                }
                column(NFL_Requisition_Line__Location_Code_Caption; FIELDCAPTION("Location Code"))
                {
                }
                column(NFL_Requisition_Line_DescriptionCaption; FIELDCAPTION(Description))
                {
                }
                column(NFL_Requisition_Line__Unit_of_Measure_Caption; FIELDCAPTION("Unit of Measure"))
                {
                }
                column(QtyCaption; QtyCaptionLbl)
                {
                }
                column(NFL_Requisition_Line__Unit_Cost_Caption; FIELDCAPTION("Unit Cost"))
                {
                }
                column(NFL_Requisition_Line__Total_Cost_Caption; FIELDCAPTION("Total Cost"))
                {
                }
                column(NFL_Requisition_Line__Inventory_Charge_A_c_Caption; FIELDCAPTION("Inventory Charge A/c"))
                {
                }
                column(TotalCaption; TotalCaptionLbl)
                {
                }
                column(NFL_Requisition_Line_Document_Type; "Document Type")
                {
                }
                column(NFL_Requisition_Line_Document_No_; "Document No.")
                {
                }
                column(NFL_Requisition_Line_Line_No_; "Line No.")
                {
                }
                column(Count_Entries; x)
                {
                }

                trigger OnAfterGetRecord();
                begin
                    x := x + 1;
                end;

                trigger OnPreDataItem();
                begin
                    x := 0;
                end;
            }

            trigger OnAfterGetRecord();
            begin
                IF "NFL Requisition Header"."Location Code" <> '' THEN BEGIN
                    GvLocation.GET("NFL Requisition Header"."Location Code");
                    LocationCode := GvLocation.Name;
                END;
            end;

            trigger OnPreDataItem();
            begin
                LastFieldNo := FIELDNO("No.");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        PageConst: Label 'Page';
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Store_RequisitionCaptionLbl: Label 'Store Requisition';
        NOT_FOR_ISSUINGCaptionLbl: Label 'NOT FOR ISSUING';
        Request_DateCaptionLbl: Label 'Request Date';
        QtyCaptionLbl: Label 'Qty';
        TotalCaptionLbl: Label 'Total';
        x: Integer;
        GvLocation: Record Location;
        LocationCode: Text[50];
}

