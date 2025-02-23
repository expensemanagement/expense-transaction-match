tableextension 63081 EMTRM extends "CEM Expense Match"
{
    fields
    {
        field(63080; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(EMTRM1; "Processed")
        {
        }
    }
}