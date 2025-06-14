/* Definition section */
%{
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>

   #define YY_NO_UNPUT
   #define YY_NO_INPUT
   #define print_token(token) \
       printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

   int line_num = 0;
   int comment_num = 0;
   int last_comment_line = -1;

   void count_comment_line() {
       if(line_num != last_comment_line) {
            // printf("%d %d\n", line_num, last_comment_line);
            comment_num++;
            last_comment_line = line_num;
       }
   }
%}



/* Define regular expression label */
%x COMMENT
letter      [a-zA-Z_]
digit       [0-9]
func        fn\ {letter}
println     println
print       print
ident       {letter}({letter}|{digit})*
comment     "//"[^\n]*
string      \"[^\"\n]*\"
if          "if"
else        "else" 
for         "for"
i32         "i32"
f32         "f32"
dotdot      ".."
bool        "bool"
true        "true"
false       "false"
let         "let"
mut         "mut"
return      "return"
break       "break"
as          "as"
in          "in"
while       "while"
loop        "loop"
intlit      [0-9]+
floatlit    [0-9]+"."[0-9]+


/* Rules section */
%%
{func}      { yyless(3); print_token("FUNC"); }
{print}     { print_token("PRINT"); }
{println}   { print_token("PRINTLN"); }
{if}        { print_token("IF"); }
{else}      { print_token("ELSE"); }
{for}       { print_token("FOR"); }
{i32}       { print_token("INT"); }
{f32}       { print_token("FLOAT"); }
{dotdot}    { print_token("DOTDOT"); }
{bool}      { print_token("BOOL"); }
{true}      { print_token("TRUE"); }
{false}     { print_token("FALSE"); }
{let}       { print_token("LET"); }
{mut}       { print_token("MUT"); }
{return}    { print_token("RETURN"); }
{break}     { print_token("BREAK"); }
{as}        { print_token("AS"); }
{in}        { print_token("IN"); }
{while}     { print_token("WHILE"); }
{loop}      { print_token("LOOP"); }
{comment}   { print_token("COMMENT"); count_comment_line(); }
"/*"           { count_comment_line(); BEGIN(COMMENT); printf("%s", yytext); }
<COMMENT>"*/"  { print_token("MUTI_LINE_COMMENT"); BEGIN(INITIAL); }
<COMMENT>\n    { printf("\n"); line_num++; count_comment_line(); }
<COMMENT>.     { printf("%s", yytext); }
{string}    { 
    int len = yyleng;
    char *left = (char *)malloc(2); strncpy(left, yytext, 1); left[1] = '\0';
    char *right = (char *)malloc(2); strncpy(right, yytext + len - 1, 1); right[1] = '\0';
    char *str = (char *)malloc(sizeof(len - 1)); strncpy(str, yytext + 1, len - 2);
    str[len - 2] = '\0';
    yytext = left;
    print_token("QUOTA");
    yytext = str;
    if (str[0] != '\0') {
        print_token("STRING_LIT");
    }
    yytext = right;
    print_token("QUOTA");
    free(left); free(right); free(str);
}
{intlit}    { print_token("INT_LIT"); }
{floatlit}  { print_token("FLOAT_LIT"); }
{ident}     { print_token("IDENT"); }

"+"         { print_token("ADD"); }
"-"         { print_token("SUB"); }
"*"         { print_token("MUL"); }
"/"         { print_token("QUO"); }
"%"         { print_token("REM"); }
">"         { print_token("GTR"); }
"<"         { print_token("LSS"); }
">="        { print_token("GEQ"); }
"<="        { print_token("LEQ"); }
"=="        { print_token("EQL"); }
"!="        { print_token("NEQ"); }
"="         { print_token("ASSIGN"); }
"+="        { print_token("ADD_ASSIGN"); }
"-="        { print_token("SUB_ASSIGN"); }
"*="        { print_token("MUL_ASSIGN"); }
"/="        { print_token("QUO_ASSIGN"); }
"%="        { print_token("REM_ASSIGN"); }
"&"         { print_token("BAND"); }
"|"         { print_token("BOR"); }
"~"         { print_token("BNOT"); }
"&&"        { print_token("LAND"); }
"||"        { print_token("LOR"); }
"!"         { print_token("NOT"); }
"("         { print_token("LPAREN"); }
")"         { print_token("RPAREN"); }
"["         { print_token("LBRACK"); }
"]"         { print_token("RBRACK"); }
"{"         { print_token("LBRACE"); }
"}"         { print_token("RBRACE"); }
";"         { print_token("SEMICOLON"); }
","         { print_token("COMMA"); }
"\""        { print_token("QUOTA"); }
"\n"        { line_num++; print_token("NEWLINE"); }
":"         { print_token("COLON"); }
"<<"        { print_token("LSHIFT"); }
">>"        { print_token("RSHIFT"); }
"->"        { print_token("ARROW"); }

<<EOF>>     { line_num++; yyterminate(); }
[ \t]+      {;}
.           {;}
%%

/*  C Code section */
int yywrap(void)
{
   return 1;
}

int main(int argc, char *argv[])
{
   if (argc == 2) {
       yyin = fopen(argv[1], "r");
   } else {
       yyin = stdin;
   }
   yylex();
   printf("\nFinish scanning,\n");
   printf("total line: %d\n", line_num);
   printf("comment line: %d\n", comment_num);
   fclose(yyin);
   return 0;
}
