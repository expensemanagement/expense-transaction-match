tableextension 63081 EMTRM extends "CEM Expense Match"
{
    fields
    {
        field(63080; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
        // field(63081; "GL Entry No."; Integer)
        // {
        //     Caption = 'GL Entry No.';
        //     DataClassification = CustomerContent;
        //     TableRelation = "G/L Entry";
        // }
    }
    keys
    {
        key(EMTRM1; "Processed")
        {
        }
    }
}