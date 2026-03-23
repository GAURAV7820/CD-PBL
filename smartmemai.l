%{
#include <stdio.h>
#include <string.h>

#define MAX 100

struct Variable{
    char name[50];
    char type[10];
    int isUsed;
    int isDuplicate;
    int line;
};

struct Variable vars[MAX];
int varCount=0;

char currentType[10];
int declarationMode=0;
int lineNo=1;

int findVar(char *name){
    for(int i=0;i<varCount;i++){
        if(strcmp(vars[i].name,name)==0)
            return i;
    }
    return -1;
}
%}

%%

\n { lineNo++; }

(int|float|char|double|long) {
    strcpy(currentType,yytext);
    declarationMode=1;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    if(declarationMode){
        int idx=findVar(yytext);
        if(idx==-1){
            strcpy(vars[varCount].name,yytext);
            strcpy(vars[varCount].type,currentType);
            vars[varCount].isUsed=0;
            vars[varCount].isDuplicate=0;
            vars[varCount].line=lineNo;
            varCount++;
        }else{
            vars[idx].isDuplicate=1;
        }
    }else{
        int idx=findVar(yytext);
        if(idx!=-1){
            vars[idx].isUsed=1;
        }
    }
}

";" { declarationMode=0; }

[0-9]+ { }
"," { }
"=" { }
[ \t]+ { }
. { }

%%

int getSize(char *type){
    if(strcmp(type,"int")==0) return 4;
    if(strcmp(type,"float")==0) return 4;
    if(strcmp(type,"char")==0) return 1;
    if(strcmp(type,"double")==0) return 8;
    if(strcmp(type,"long")==0) return 8;
    return 0;
}

int main(){
    FILE *fp=fopen("input.c","r");
    FILE *report=fopen("report.txt","w");

    if(!fp||!report) return 1;

    yyin=fp;
    yylex();
    fclose(fp);

    int before=0,after=0;

    fprintf(report,"===== SMARTMEMAI ANALYSIS REPORT =====\n");
    fprintf(report,"\n--- Symbol Table ---\n");
    fprintf(report,"Name\tType\tUsed\tLine\n");

    FILE *data=fopen("data.txt","w");
    FILE *names=fopen("names.txt","w");

    for(int i=0;i<varCount;i++){
        fprintf(report,"%s\t\t%s\t\t%s\t\t%d\n",
            vars[i].name,
            vars[i].type,
            vars[i].isUsed?"Yes":"No",
            vars[i].line);

        fprintf(data,"%d %d\n",vars[i].isUsed,vars[i].isDuplicate);
        fprintf(names,"%s\n",vars[i].name);
    }

    fclose(data);
    fclose(names);

    fprintf(report,"\n--- Optimization Report ---\n");

    for(int i=0;i<varCount;i++){
        int size=getSize(vars[i].type);
        before+=size;

        if(vars[i].isUsed)
            after+=size;

        if(!vars[i].isUsed)
            fprintf(report,"Unused variable: %s (line %d)\n",vars[i].name,vars[i].line);

        if(vars[i].isDuplicate)
            fprintf(report,"Duplicate variable: %s (line %d)\n",vars[i].name,vars[i].line);
    }

    fprintf(report,"\n--- Memory Analysis ---\n");
    fprintf(report,"Memory before: %d bytes\n",before);
    fprintf(report,"Memory after: %d bytes\n",after);
    fprintf(report,"Memory saved: %d bytes\n",before-after);

    fclose(report);

    system("python3 ai_model.py");

    report=fopen("report.txt","a");
    fprintf(report,"\n======================================\n");
    fclose(report);

    return 0;
}

int yywrap(){
    return 1;
}