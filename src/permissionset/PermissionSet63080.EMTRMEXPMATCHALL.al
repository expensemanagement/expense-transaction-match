permissionset 63080 "EMTRM EXPMATCH ALL"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Expense Match All', Locked = true;

    Permissions =
         codeunit "EMTRM Transaction Match Mgt." = X;
}