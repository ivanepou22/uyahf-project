/// <summary>
/// Report Purchase Requisition (ID 50053).
/// </summary>
report 50004 "Purchase Requisition"
{
    // version MAG

    DefaultLayout = RDLC;
    RDLCLayout = './Purchase Requisition.rdlc';

    dataset
    {
        dataitem("NFL Requisition Header"; "NFL Requisition Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                WHERE("Document Type" = CONST("Purchase Requisition"),
                                      "No." = FILTER(<> ''));
            RequestFilterFields = "Document Type", "No.", "Request-By No.";
            column(AccountingPeriod_NFLRequisitionHeader; "NFL Requisition Header"."Accounting Period Start Date")
            {
            }
            column(AccountingPeriodEndDate_NFLRequisitionHeader; "NFL Requisition Header"."Accounting Period End Date")
            {
            }
            column(FiscalYear_NFLRequisitionHeader; "NFL Requisition Header"."Fiscal Year Start Date")
            {
            }
            column(FiscalYearEndDate_NFLRequisitionHeader; "NFL Requisition Header"."Fiscal Year End Date")
            {
            }
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
            column(NFL_Requisition_Header__Store_Requisition_No__; "Store Requisition No.")
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
            column(Requested_Receipt_Date; "NFL Requisition Header"."Requested Receipt Date")
            {
            }
            column(NFL_Requisition_Header__Expected_Receipt_Date_; "Expected Receipt Date")
            {
            }
            column(Purchase_RequisitionCaption; Purchase_RequisitionCaptionLbl)
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
            column(NFL_Requisition_Header__Store_Requisition_No__Caption; FIELDCAPTION("Store Requisition No."))
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
            column(Currency_Code; CurrencyCode)
            {
            }
            column(Posting_Description; "NFL Requisition Header"."Posting Description")
            {
            }
            column(Location_Code; "NFL Requisition Header"."Location Code")
            {
            }
            column(LocationCode; LocationCode)
            {
            }
            column(FirstApprover; Approver1)
            {
            }
            column(SecondApprover; Approver2)
            {
            }
            column(ThirdApprover; Approver3)
            {
            }
            column(FourthApprover; Approver4)
            {
            }
            column(FirstDateOfApproval; ApprovalDate1)
            {
            }
            column(SecondDateOfApproval; ApprovalDate2)
            {
            }
            column(ThirdDateOfApproval; ApprovalDate3)
            {
            }
            column(FourthDateOfApproval; ApprovalDate4)
            {
            }
            column(AppPositionOne; JobTitle1)
            {
            }
            column(AppPositionTwo; JobTitle2)
            {
            }
            column(AppPositionThree; JobTitle3)
            {
            }
            column(AppPositionFour; JobTitle4)
            {
            }
            column(PDEntity_NFLRequisitionHeader; "NFL Requisition Header"."PD Entity")
            {
            }
            column(WrksServSup; "Procurement Category")
            {
            }
            column(ITB; "ITB Number")
            {
            }
            column(ContractNo; "Contract No.")
            {
            }
            column(ProcumentPlanReference_NFLRequisitionHeader; "NFL Requisition Header"."Procument Plan Reference")
            {
            }
            column(RequestByName; gvRequestByName)
            {
            }
            column(EmployeePostion; gvEmployeePosition)
            {
            }
            column(RequestDate; "NFL Requisition Header"."Order Date")
            {
            }
            column(Approver1Comment; Approver1Comment)
            {
            }
            column(Approver2Comment; Approver2Comment)
            {
            }
            column(Approver3Comment; Approver3Comment)
            {
            }
            column(Approver4Comment; Approver4Comment)
            {
            }
            column(ShortcutDimValueName1; ShortcutDimValueName1)
            {
            }
            column(ShortcutDimValueName2; ShortcutDimValueName2)
            {
            }
            column(CompanyInfo_Name; CompanyInfo.Name)
            {
            }
            column(CompanyInfo_PostCode_; CompanyInfo."Post Code")
            {
            }
            column(CompanyInfo__Home_Page_; CompanyInfo."Home Page")
            {
            }
            column(CompanyInfo_VATRegNo_; CompanyInfo."VAT Registration No.")
            {
            }
            column(Company_City_; CompanyInfo.City)
            {
            }
            column(CompanyInfo_Country_; CompanyInfo."Country/Region Code")
            {
            }
            column(CompanyInfo__Phone_No__; CompanyInfo."Phone No.")
            {
            }
            column(CompanyInfo__Fax_No__; CompanyInfo."Fax No.")
            {
            }
            column(CompanyInfo__E_Mail_; CompanyInfo."E-Mail")
            {
            }
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            {
            }
            column(Header_Label_; HeaderLabel)
            {
            }
            column(Procurement_Category_; ProcurementCategory)
            {
            }
            column(LocationCode_NFLRequisitionHeader; "NFL Requisition Header"."Location Code")
            {
            }
            column(ShortcutDimension1Code_NFLRequisitionHeader; "NFL Requisition Header"."Shortcut Dimension 1 Code")
            {
            }
            column(ShortcutDimension2Code_NFLRequisitionHeader; "NFL Requisition Header"."Shortcut Dimension 2 Code")
            {
            }
            column(PostingDescription_NFLRequisitionHeader; "NFL Requisition Header"."Posting Description")
            {
            }
            column(ProcurementCategory_NFLRequisitionHeader; "NFL Requisition Header"."Procurement Category")
            {
            }
            column(SpecialInstructionProgram_NFLRequisitionHeader; "NFL Requisition Header"."Special Instruction/Program")
            {
            }
            column(DeliveryPeriod_NFLRequisitionHeader; "NFL Requisition Header"."Delivery Period")
            {
            }
            column(Label1; gvDimension1Label)
            {
            }
            column(Label2; gvDimension2Label)
            {
            }
            column(Label3; gvDimension3Label)
            {
            }
            column(Label4; gvDimension4Label)
            {
            }
            column(Label5; gvDimension5Label)
            {
            }
            column(Label6; gvDimension6Label)
            {
            }
            column(Label7; gvDimension7Label)
            {
            }
            column(Label8; gvDimension8Label)
            {
            }
            column(Name1; gvDim1Name)
            {
            }
            column(Name2; gvDim2Name)
            {
            }
            column(Name3; gvDim3Name)
            {
            }
            column(Name4; gvDim4Name)
            {
            }
            column(Name5; gvDim5Name)
            {
            }
            column(Name6; gvDim6Name)
            {
            }
            column(Name7; gvDim7Name)
            {
            }
            column(Name8; gvDim8Name)
            {
            }
            column(Code1; gvDim1Code)
            {
            }
            column(Code2; gvDim2Code)
            {
            }
            column(Code3; gvDim3Code)
            {
            }
            column(Code8; gvDim8Code)
            {
            }
            column(To_NFLRequisitionHeader; "NFL Requisition Header"."To.")
            {
            }
            column(BudgetCode_NFLRequisitionHeader; "NFL Requisition Header"."Budget Code")
            {
            }
            column(TotalAmount_NFLRequisitionHeader; "NFL Requisition Header"."Amount Including VAT")
            {
            }
            column(RequestByName_NFLRequisitionHeader; "NFL Requisition Header"."Request-By Name")
            {
            }
            column(OrderDate_NFLRequisitionHeader; "NFL Requisition Header"."Order Date")
            {
            }
            column(FirstApp; FullNames[1])
            {
            }
            column(SecondApp; FullNames[2])
            {
            }
            column(ThirdApp; FullNames[3])
            {
            }
            column(FourthApp; FullNames[4])
            {
            }
            column(FifthApp; FullNames[5])
            {
            }
            column(FirstApproverDesignation; JobTitle[1])
            {
            }
            column(SecondApproverDesignation; JobTitle[2])
            {
            }
            column(ThirdApproverDesignation; JobTitle[3])
            {
            }
            column(FouthApproverDesignation; JobTitle[4])
            {
            }
            column(FiftyApproverDesignation; JobTitle[5])
            {
            }
            column(Approver1Date; ApproverDate[1])
            {
            }
            column(Approver2Date; ApproverDate[2])
            {
            }
            column(Approver3Date; ApproverDate[3])
            {
            }
            column(Approver4Date; ApproverDate[4])
            {
            }
            column(Approver5Date; ApproverDate[5])
            {
            }
            column(RequestorDesignation; RequestorDesignation)
            {
            }
            dataitem("NFL Requisition Line"; "NFL Requisition Line")
            {
                DataItemLinkReference = "NFL Requisition Header";
                DataItemLink = "Document Type" = FIELD("Document Type"),
                               "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(BudgetComment_NFLRequisitionLine; "NFL Requisition Line"."Budget Comment")
                {
                }
                column(BuyfromVendorNo_NFLRequisitionLine; "NFL Requisition Line"."Buy-from Vendor No.")
                {
                }
                column(ShortcutDimension1Code_NFLRequisitionLine; "NFL Requisition Line"."Shortcut Dimension 1 Code")
                {
                }
                column(BudgetAmountasatDate_NFLRequisitionLine; "NFL Requisition Line"."Budget Amount as at Date")
                {
                }
                column(BudgetAmountfortheYear_NFLRequisitionLine; "NFL Requisition Line"."Budget Amount for the Year")
                {
                }
                column(ActualAmountasatDate_NFLRequisitionLine; "NFL Requisition Line"."Actual Amount as at Date")
                {
                }
                column(ActualAmountfortheYear_NFLRequisitionLine; "NFL Requisition Line"."Actual Amount for the Year")
                {
                }
                column(BalanceonBudgetasatDate_NFLRequisitionLine; "NFL Requisition Line"."Balance on Budget as at Date")
                {
                }
                column(BalanceonBudgetfortheYear_NFLRequisitionLine; "NFL Requisition Line"."Balance on Budget for the Year")
                {
                }
                column(BudgetCommentasatDate_NFLRequisitionLine; "NFL Requisition Line"."Budget Comment as at Date")
                {
                }
                column(BudgetCommentfortheYear_NFLRequisitionLine; "NFL Requisition Line"."Budget Comment for the Year")
                {
                }
                column(CommitmentAmountfortheYear_NFLRequisitionLine; "NFL Requisition Line"."Commitment Amount for the Year")
                {
                }
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
                column(Description2_NFLRequisitionLine; "NFL Requisition Line"."Description 2")
                {
                }
                column(NFL_Requisition_Line__Unit_of_Measure_; "Unit of Measure")
                {
                }
                column(NFL_Requisition_Line_Quantity; Quantity)
                {
                }
                column(NFL_Requisition_Line_Amount; Amount)
                {
                }
                column(NFL_Requisition_Line__Buy_from_Vendor_No__; "Buy-from Vendor No.")
                {
                }
                column(NFL_Requisition_Line__Unit_Cost__LCY__; "Unit Cost (LCY)")
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
                column(NFL_Requisition_Line__Unit_of_Measure_Caption; NFL_Requisition_Line__Unit_of_Measure_CaptionLbl)
                {
                }
                column(QtyCaption; QtyCaptionLbl)
                {
                }
                column(NFL_Requisition_Line_AmountCaption; FIELDCAPTION(Amount))
                {
                }
                column(NFL_Requisition_Line__Buy_from_Vendor_No__Caption; FIELDCAPTION("Buy-from Vendor No."))
                {
                }
                column(NFL_Requisition_Line__Unit_Cost__LCY__Caption; FIELDCAPTION("Unit Cost (LCY)"))
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
                column(on; x)
                {
                }
                column(Quantity_NFLRequisitionLine; "NFL Requisition Line".Quantity)
                {
                }
                column(DirectUnitCost_NFLRequisitionLine; "NFL Requisition Line"."Direct Unit Cost")
                {
                }
                column(TotalAmount; TotalAmount)
                {
                }

                trigger OnAfterGetRecord();
                var
                    NFLRequisitionLines: Record "NFL Requisition Line";
                begin
                    TotalAmount := 0;

                    x := x + 1;

                    "NFL Requisition Line".SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");

                    "NFL Requisition Line".CALCFIELDS("Budget Amount for the Year");
                    "NFL Requisition Line".CALCFIELDS("Actual Amount for the Year");
                    "NFL Requisition Line".CALCFIELDS("Commitment Amount for the Year");

                    NFLRequisitionLines.Reset();
                    NFLRequisitionLines.SetRange(NFLRequisitionLines."Document No.", "NFL Requisition Line"."Document No.");
                    NFLRequisitionLines.SetRange(NFLRequisitionLines."Document Type", "NFL Requisition Line"."Document Type");
                    if NFLRequisitionLines.FindFirst() then begin
                        repeat
                            TotalAmount += (NFLRequisitionLines.Quantity * NFLRequisitionLines."Direct Unit Cost");
                        until NFLRequisitionLines.Next() = 0;
                    end;
                end;
            }

            dataitem("Approval Entry"; "Approval Entry")
            {
                DataItemLinkReference = "NFL Requisition Header";
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = where(status = filter(Approved));
                column(Approver_Id; "Approver ID")
                {
                }
                column(Escalated_Id; "Escalated By")
                {
                }
                column(LastDateTimeModified; "Last Date-Time Modified")
                {
                }
            }

            trigger OnAfterGetRecord();
            begin
                IF "NFL Requisition Header"."Currency Code" <> '' THEN
                    CurrencyCode := 'Currency:' + ' ' + "NFL Requisition Header"."Currency Code"
                ELSE
                    CurrencyCode := 'Currency: UGX';
                GetApprovers;

                //, Get Dimension codes and names
                gvGeneralLedgerSetup.GET;
                gvDimension1Label := gvGeneralLedgerSetup."Shortcut Dimension 1 Code";
                gvDimension2Label := gvGeneralLedgerSetup."Shortcut Dimension 2 Code";
                gvDimension3Label := gvGeneralLedgerSetup."Shortcut Dimension 3 Code";
                gvDimension4Label := gvGeneralLedgerSetup."Shortcut Dimension 4 Code";
                gvDimension5Label := gvGeneralLedgerSetup."Shortcut Dimension 5 Code";
                gvDimension6Label := gvGeneralLedgerSetup."Shortcut Dimension 6 Code";
                gvDimension7Label := gvGeneralLedgerSetup."Shortcut Dimension 7 Code";
                gvDimension8Label := gvGeneralLedgerSetup."Shortcut Dimension 8 Code";

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension1Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim1Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim1Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension2Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim2Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim2Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension3Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim3Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim3Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension4Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim4Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim4Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension5Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim5Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim5Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension6Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim6Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim6Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension7Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim7Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim7Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                gvDimensionSetEntry.RESET;
                gvDimensionSetEntry.SETRANGE("Dimension Set ID", "NFL Requisition Header"."Dimension Set ID");
                gvDimensionSetEntry.SETRANGE("Dimension Code", gvDimension8Label);
                IF gvDimensionSetEntry.FIND('-') THEN BEGIN
                    gvDimensionSetEntry.CALCFIELDS("Dimension Value Name");
                    gvDim8Name := gvDimensionSetEntry."Dimension Value Name";
                    gvDim8Code := gvDimensionSetEntry."Dimension Value Code";
                END;

                // - END
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

    trigger OnPreReport();
    begin
        CompanyInfo.GET;
        CompanyInfo.CALCFIELDS(Picture);
    end;

    var
        PageConst: Label 'Page';
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Purchase_RequisitionCaptionLbl: Label 'Purchase Requisition';
        Request_DateCaptionLbl: Label 'Request Date';
        NFL_Requisition_Line__Unit_of_Measure_CaptionLbl: Label 'UOM';
        QtyCaptionLbl: Label 'Qty';
        CurrencyCode: Text[50];
        x: Integer;
        Approver1: Text[80];
        Approver2: Text[80];
        Approver3: Text[80];
        Approver4: Text[80];
        LocationCode: Text[40];
        LocRec: Record Location;
        ApproverRec: Record "Approval Entry";
        ApprovalDate1: Date;
        ApprovalDate2: Date;
        ApprovalDate3: Date;
        ApprovalDate4: Date;
        Signature1: Integer;
        JobTitle1: Text[80];
        JobTitle2: Text[80];
        JobTitle3: Text[80];
        JobTitle4: Text[80];
        LvUser: Record "User Setup";
        LvUser2: Record "User Setup";
        LvUser3: Record "User Setup";
        LvUser4: Record "User Setup";
        GvUsers: Record User;
        gvRequestByName: Text[80];
        gvEmployeeRec: Record Employee;
        gvEmployeePosition: Text[80];
        // gvNFLApprovalCommentLine: Record "NFL Approval Comment Line";
        Approver1Comment: Text;
        Approver2Comment: Text;
        Approver3Comment: Text;
        Approver4Comment: Text;
        gvNFLApproverCommentLineUserID: Code[100];
        DimensionSetEntry: Record "Dimension Set Entry";
        ShortcutDimValueName1: Text;
        ShortcutDimValueName2: Text;
        CompanyInfo: Record "Company Information";
        HeaderLabel: Label 'PURCHASE REQUISITION';
        ProcurementCategory: Label 'Procurement Category';
        "---MAG---": Integer;
        gvDimensionSetEntry: Record "Dimension Set Entry";
        gvGeneralLedgerSetup: Record "General Ledger Setup";
        gvDimension1Label: Text;
        gvDimension2Label: Text;
        gvDimension3Label: Text;
        gvDimension4Label: Text;
        gvDimension5Label: Text;
        gvDimension6Label: Text;
        gvDimension7Label: Text;
        gvDimension8Label: Text;
        gvDim1Code: Code[20];
        gvDim2Code: Code[20];
        gvDim3Code: Code[20];
        gvDim4Code: Code[20];
        gvDim5Code: Code[20];
        gvDim6Code: Code[20];
        gvDim7Code: Code[20];
        gvDim8Code: Code[20];
        gvDim1Name: Text;
        gvDim2Name: Text;
        gvDim3Name: Text;
        gvDim4Name: Text;
        gvDim5Name: Text;
        gvDim6Name: Text;
        gvDim7Name: Text;
        gvDim8Name: Text;
        ApprovalEntry: Record "Approval Entry";
        ApproverID: array[20] of Code[100];
        i: Integer;
        User: Record User;
        FullNames: array[20] of Text[100];
        JobTitle: array[20] of Text[80];
        Employee: Record Employee;
        RequestorDesignation: Text;
        gvEmployee: Record Employee;
        ApproverDate: array[20] of DateTime;
        TotalAmount: Decimal;

    /// <summary>
    /// Description for GetApprovers.
    /// </summary>
    procedure GetApprovers();
    var
        i: Integer;
        LvPurchReq: Record "NFL Requisition Header";
        LvApprovalEntry: Record "Approval Entry";
        ApproverName: array[5] of Text[80];
        LvUser: Record User;
    begin
        //Get requestor job title.
        gvEmployee.SETRANGE("No.", "NFL Requisition Header"."Request-By No.");
        IF gvEmployee.FINDFIRST THEN
            RequestorDesignation := gvEmployee."Job Title";

        //Get approvers
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Table ID", '50069');
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Document No.", "NFL Requisition Header"."No.");
        LvApprovalEntry.SETFILTER(LvApprovalEntry.Status, 'Approved');
        i := 1;

        IF LvApprovalEntry.FIND('-') THEN
            REPEAT
                ApproverID[i] := LvApprovalEntry."Approver ID";
                ApproverDate[i] := LvApprovalEntry."Last Date-Time Modified";
                User.SETRANGE("User Name", ApproverID[i]);
                IF User.FINDFIRST THEN BEGIN
                    FullNames[i] := User."Full Name";
                END;
                i += 1;
            UNTIL LvApprovalEntry.NEXT = 0;
        //END
    end;
}

