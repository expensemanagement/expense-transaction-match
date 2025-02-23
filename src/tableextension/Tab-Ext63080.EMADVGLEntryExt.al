tableextension 63080 "EMADV GL Entry Ext" extends "G/L Entry"
{
    fields
    {
        field(63080; "Expense Entry No."; Integer)
        {
            Caption = 'Expense Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "CEM Expense";
            BlankZero = true;
        }
    }
}

