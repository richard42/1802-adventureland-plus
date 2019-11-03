
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "advland_data.h"

// compile with: gcc -o convert_data convert_data.c

const char *unescaped(const char *pchIn)
{
    static char chOutput[4096];
    
    char *pchOut = chOutput;
    char *pchEscChar;
    while(*pchIn != 0)
    {
        char chIn = *pchIn++;
        if (chIn == '\n')
        {
            *pchOut++ = '\\';
            *pchOut++ = 'n';
        }
        else if (chIn == '"')
        {
            *pchOut++ = '\\';
            *pchOut++ = '"';
        }
        else
        {
            *pchOut++ = chIn;
        }
    }
    *pchOut++ = 0;
    
    return chOutput;
}

int main(int argc, char *argv[])
{
    FILE *pfOut = fopen("adventureland_data.asm", "w");
    
    // write out constants
    fprintf(pfOut, "CL  EQU %i\n", CL);
    fprintf(pfOut, "NL  EQU %i\n", NL);
    fprintf(pfOut, "RL  EQU %i\n", RL);
    fprintf(pfOut, "ML  EQU %i\n", ML);
    fprintf(pfOut, "IL  EQU %i\n", IL);
    fprintf(pfOut, "MX  EQU %i\n", MX);
    fprintf(pfOut, "AR  EQU %i\n", AR);
    fprintf(pfOut, "TT  EQU %i\n", TT);
    fprintf(pfOut, "LN  EQU %i\n", LN);
    fprintf(pfOut, "LI  EQU %i\n", LT);
    fprintf(pfOut, "TR  EQU %i\n", TR);
    fprintf(pfOut, "MAXLINE  EQU %i", MAXLINE);
    fprintf(pfOut, "\n\n");

    // write out C array
    fprintf(pfOut, "; Array C has dimensions %i x 16\n", CL);
    for (int i = 0; i < CL; i++)
    {
        if (i == 0)
            fprintf(pfOut, "Array_C     DB  ");
        else
            fprintf(pfOut, "            DB  ");
        for (int j = 0; j < 16; j++)
        {
            fprintf(pfOut, "$%02X", C[i][j]);
            if (j == 15)
                fprintf(pfOut, "\n");
            else
                fprintf(pfOut, ", ");
        }
    }
    fprintf(pfOut, "\n\n");
   
    // write out NVS array
    fprintf(pfOut, "; Array NVS has dimensions 2 x %i\n", NL);
    for (int i = 0; i < 2; i++)
    {
        if (i == 0)
            fprintf(pfOut, "Array_NVS   BYTE    ");
        else
            fprintf(pfOut, "            BYTE    ");
        for (int j = 0; j < NL; j++)
        {
            int len = strlen(NVS[i][j]);
            if (len == 2)
                fprintf(pfOut, "\"%s\",0,0", NVS[i][j]);
            else if (len == 3)
                fprintf(pfOut, "\"%s\",0", NVS[i][j]);
            else if (len == 4)
                fprintf(pfOut, "\"%s\"", NVS[i][j]);
            else
                fprintf(pfOut, "\"%.4s\"", NVS[i][j]);
            if (j == NL - 1)
                fprintf(pfOut, "\n");
            else if (j % 10 == 9)
                fprintf(pfOut, "\n            BYTE    ");
            else
                fprintf(pfOut, ", ");
        }
    }
    fprintf(pfOut, "\n\n");
    
    // write out RM array
    fprintf(pfOut, "; Array RM has dimensions %i x 6\n", RL);
    for (int i = 0; i < RL; i++)
    {
        if (i == 0)
            fprintf(pfOut, "Array_RM    DB  ");
        else
            fprintf(pfOut, "            DB  ");
        for (int j = 0; j < 6; j++)
        {
            fprintf(pfOut, "%2i", RM[i][j]);
            if (j == 5)
                fprintf(pfOut, "\n");
            else
                fprintf(pfOut, ", ");
        }
    }
    fprintf(pfOut, "\n\n");

    // write out RSS string table
    fprintf(pfOut, "; String table RSS has length %i\n", RL);
    fprintf(pfOut, "Table_RSS   DW  ");
    for (int i = 0; i < RL; i++)
    {
        fprintf(pfOut, "RSS%02i_Msg", i);
        if (i % 10 == 9 || i + 1 == RL)
        {
            fprintf(pfOut, "\n");
            if (i + 1 < RL)
                fprintf(pfOut, "            DW  ");
        }
        else
        {
            fprintf(pfOut, ", ");
        }
    }
    for (int i = 0; i < RL; i++)
    {
        fprintf(pfOut, "RSS%02i_Msg   BYTE    \"%s\", 0\n", i, unescaped(RSS[i]));
    }
    fprintf(pfOut, "\n\n");

    // write out MSS string table
    fprintf(pfOut, "; String table MSS has length %i\n", ML);
    fprintf(pfOut, "Table_MSS   DW  ");
    for (int i = 0; i < ML; i++)
    {
        fprintf(pfOut, "MSS%02i_Msg", i);
        if (i % 10 == 9 || i + 1 == ML)
        {
            fprintf(pfOut, "\n");
            if (i + 1 < ML)
                fprintf(pfOut, "            DW  ");
        }
        else
        {
            fprintf(pfOut, ", ");
        }
    }
    for (int i = 0; i < ML; i++)
    {
        fprintf(pfOut, "MSS%02i_Msg   BYTE    \"%s\", 0\n", i, unescaped(MSS[i]));
    }
    fprintf(pfOut, "\n\n");
    
    // write out IAS string table
    fprintf(pfOut, "; String table IAS has length %i\n", IL);
    fprintf(pfOut, "Table_IAS   DW  ");
    for (int i = 0; i < IL; i++)
    {
        fprintf(pfOut, "IAS%02i_Msg", i);
        if (i % 10 == 9 || i + 1 == IL)
        {
            fprintf(pfOut, "\n");
            if (i + 1 < IL)
                fprintf(pfOut, "            DW  ");
        }
        else
        {
            fprintf(pfOut, ", ");
        }
    }
    for (int i = 0; i < IL; i++)
    {
        fprintf(pfOut, "IAS%02i_Msg   BYTE    \"%s\", 0\n", i, unescaped(IAS[i]));
    }
    fprintf(pfOut, "\n\n");

    // write out I2 array
    fprintf(pfOut, "; Array I2 has length %i\n", IL);
    fprintf(pfOut, "Array_I2    DB  ");
    for (int i = 0; i < IL; i++)
    {
        fprintf(pfOut, "%2i", I2[i]);
        if (i % 10 == 9 || i + 1 == IL)
        {
            fprintf(pfOut, "\n");
            if (i + 1 < IL)
                fprintf(pfOut, "            DB  ");
        }
        else
        {
            fprintf(pfOut, ", ");
        }
    }
    fprintf(pfOut, "\n\n");

   
    fclose(pfOut);
}


