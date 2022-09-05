%{
#include "y.tab.h"
%}

%%
Which|which                         return WHICH;
Is|is                               return IS;
How|how                             return HOW;
far                                 return FAR;
the                                 return THE;
distance                            return DISTANCE;
between                             return BETWEEN;
from                                return FROM;
to                                  return TO;
and                                 return AND;
route                               return ROUTE;
routes                              return ROUTES;
there                               return THERE;
a                                   return A;
an                                  return AN;
Are|are                             return ARE;
any                                 return ANY;
goes|passes                         return MOVING_THROUGH_VERB_SINGULAR;
contains                            return CONTAINS_VERB_SINGULAR;
go|pass                             return MOVING_THROUGH_VERB_PLURAL;
contain                             return CONTAINS_VERB_PLURAL;
through                             return THROUGH;
h                                   return HOURS;
min                                 return MINUTES;
needs|takes                         return DURATION_VERB_SINGULAR;
need|take                           return DURATION_VERB_PLURAL;
than                                return THAN;
of                                  return OF;

less|more {
    yylval.strval = strdup(yytext);
    return MODIFIER;
}

shortest|longest {
    yylval.strval = strdup(yytext);
    return DISTANCE_QUANTIFIER;
} 

fastest|slowest {
    yylval.strval = strdup(yytext);
    return TIME_QUANTIFIER;
} 

"in weekend"|"during the week" {
    yylval.strval = strdup(yytext);
    return PERIOD;
}

([A-Z][a-z]*)|([A-Z][a-z]*-[A-Z][a-z]*) {
    yylval.strval = strdup(yytext);
    return LOCATION;
}

0|[1-9][0-9]* { 
    yylval.ival = atoi(yytext);
    return NUM;
}

\n|[?]              return yytext[0];

. ;

%%