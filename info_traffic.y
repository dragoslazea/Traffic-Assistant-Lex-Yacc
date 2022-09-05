%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <float.h>
#include <math.h>
#include <stdbool.h>

typedef struct {
    char* from;
    char* to;
    char* way;
    int distance;
    float time;
    char* period;
} route;

char locations[5][256] = {
    "Bucuresti",
    "Pitesti",
    "Cluj-Napoca",
    "Alba-Iulia",
    "Sibiu"
};

int distances[5][5] = {
    {   0, 108, 325, 268, 216 }, 
    { 108,   0, 234, 167, 119 },
    { 325, 234,   0,  78, 116 },
    { 268, 167,   78,  0,  52 },
    { 216, 119, 116,  52,   0 }
};

route routes[8] = {

    { 
        "Bucuresti",
        "Cluj-Napoca",
        "Bucuresti -> Pitesti -> Sibiu -> Alba-Iulia -> Turda -> Cluj-Napca",
        454,
        6.5f,
        "during the week"
    },

    { 
        "Bucuresti",
        "Cluj-Napoca",
        "Bucuresti -> Ploiesti -> Brasov -> Sighisoara -> Turda -> Cluj-Napca",
        457,
        6.57f,
        "in weekend"
    },

    { 
        "Bucuresti",
        "Cluj-Napoca",
        "Bucuresti -> Ploiesti -> Brasov -> Sighisoara -> Turda -> Cluj-Napca",
        457,
        6.35f,
        "during the week"
    },

    { 
        "Bucuresti",
        "Cluj-Napoca",
        "Bucuresti -> Pitesti -> Sibiu -> Alba-Iulia -> Turda -> Cluj-Napca",
        454,
        7.21f,
        "in weekend"
    },

    { 
        "Cluj-Napoca",
        "Sibiu",
        "Cluj-Napoca -> Turda -> Teius -> Alba-Iulia -> Sebes -> Sibiu",
        168,
        2.05f,
        "during the week"
    },

    { 
        "Cluj-Napoca",
        "Sibiu",
        "Cluj-Napoca -> Turda -> Teius -> Alba-Iulia -> Sebes -> Sibiu",
        168,
        1.45f,
        "in weekend"
    },

    { 
        "Cluj-Napoca",
        "Sibiu",
        "Cluj-Napoca -> Turda -> Teius -> Blaj -> Copsa-Mica -> Sibiu",
        183,
        2.52f,
        "during the week"
    },

    { 
        "Cluj-Napoca",
        "Sibiu",
        "Cluj-Napoca -> Turda -> Teius -> Blaj -> Copsa-Mica -> Sibiu",
        183,
        2.35f,
        "in weekend"
    }
};

char* s;

int yylex();
void yyerror(const char* err);

int get_location_id(char* location);
void get_distance(char* locationA, char* locationB);
void find_fastest_slowest_route_in_period(char* locationA, char* locationB, char* quantifier, char* period);
void find_shortest_longest_route(char* locationA, char* locationB, char* quantifier);
void find_route_intermediate(char* locationA, char* locationB, char* intermediate);
void find_route_two_intermediates(char* locationA, char* locationB, char* intermediate1, char* intermediate2);
bool check_if_exists(route r, route rs[], int n);
bool is_substring(char* substr, char* str);
void find_route_time(char* locationA, char* locationB, char* modifier, int hours, int min, char* period);
void find_route_time_intermediate(char* locationA, char* locationB, char* modifier, int hours, int min, char* period, char* intermediate);

%}

%union {
    char* strval;
    int ival;
}

%token WHICH IS THE DISTANCE BETWEEN AND ROUTE FROM TO THERE A MOVING_THROUGH_VERB_SINGULAR MOVING_THROUGH_VERB_PLURAL CONTAINS_VERB_SINGULAR CONTAINS_VERB_PLURAL THROUGH THAN DURATION_VERB_PLURAL DURATION_VERB_SINGULAR HOURS MINUTES HOW FAR AN ARE ANY ROUTES OF
%token<strval> LOCATION DISTANCE_QUANTIFIER PERIOD DISTANCE_UNIT TIME_QUANTIFIER MODIFIER
%token<ival> NUM

%start line

%%

new_line    : '\n'
            |
            ;

line    : line question new_line
        |
        ;

wh_question_beginning_singular          : WHICH IS THE
                                        ;

                            
indefinite_article              : A
                                | AN
                                ;

moving_structure_singular       : MOVING_THROUGH_VERB_SINGULAR THROUGH
                                | CONTAINS_VERB_SINGULAR
                                ;

moving_structure_plural         : MOVING_THROUGH_VERB_PLURAL THROUGH
                                | CONTAINS_VERB_PLURAL
                                ;

relative_structure_through_singular     : WHICH moving_structure_singular
                                        ;


relative_structure_through_plural       : WHICH moving_structure_plural
                                        ;

relative_structure_time_singular        : WHICH DURATION_VERB_SINGULAR
                                        ;

relative_structure_time_plural          : WHICH DURATION_VERB_PLURAL
                                        ;

yes_no_question_beginning_singular      : IS THERE indefinite_article
                                        ;

yes_no_question_beginning_plural        : ARE THERE
                                        | ARE THERE ANY
                                        ;

distance_question_beginning     : WHICH IS THE DISTANCE BETWEEN
                                | HOW FAR ARE
                                ;

yes_no_route_question_beginning_singular        : yes_no_question_beginning_singular ROUTE
                                                ;

yes_no_route_question_beginning_plural          : yes_no_question_beginning_plural ROUTES
                                                ;

distance_question   : distance_question_beginning LOCATION AND LOCATION '?'                                                         { get_distance($2, $4); }
                    ;

intermediate_question_singular  : yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION relative_structure_through_singular LOCATION '?'                   { find_route_intermediate($3, $5, $7); }
                                | yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION relative_structure_through_singular LOCATION AND LOCATION '?'      { find_route_two_intermediates($3, $5, $7, $9); }
                                ;

intermediate_question_plural    : yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION relative_structure_through_plural LOCATION '?'                       { find_route_intermediate($3, $5, $7); }
                                | yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION relative_structure_through_plural LOCATION AND LOCATION '?'          { find_route_two_intermediates($3, $5, $7, $9); }
                                ;

intermediate_question   : intermediate_question_singular
                        | intermediate_question_plural
                        ;

yes_no_route_time_question_singular     : yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION relative_structure_time_singular MODIFIER THAN NUM HOURS NUM MINUTES PERIOD '?'        { find_route_time($3, $5, $7, $9, $11, $13); } 
                                        ;

yes_no_route_time_question_plural       : yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION relative_structure_time_plural MODIFIER THAN NUM HOURS NUM MINUTES PERIOD '?'            { find_route_time($3, $5, $7, $9, $11, $13); } 
                                        ;

yes_no_route_time_intermediate_question_singular        : yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION relative_structure_time_singular MODIFIER THAN NUM HOURS NUM MINUTES PERIOD AND relative_structure_through_singular LOCATION '?'       { find_route_time_intermediate($3, $5, $7, $9, $11, $13, $16); }     
                                                        | yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION relative_structure_time_singular MODIFIER THAN NUM HOURS NUM MINUTES PERIOD AND moving_structure_singular LOCATION '?'                 { find_route_time_intermediate($3, $5, $7, $9, $11, $13, $16); }
                                                        | yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION PERIOD relative_structure_time_singular MODIFIER THAN NUM HOURS NUM MINUTES AND relative_structure_through_singular LOCATION '?'       { find_route_time_intermediate($3, $5, $8, $10, $12, $6, $16); }     
                                                        | yes_no_route_question_beginning_singular FROM LOCATION TO LOCATION PERIOD relative_structure_time_singular MODIFIER THAN NUM HOURS NUM MINUTES AND moving_structure_singular LOCATION '?'                 { find_route_time_intermediate($3, $5, $8, $10, $12, $6, $16); }
                                                        ;

yes_no_route_time_intermediate_question_plural          : yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION relative_structure_time_plural MODIFIER THAN NUM HOURS NUM MINUTES PERIOD AND relative_structure_through_plural LOCATION '?'             { find_route_time_intermediate($3, $5, $7, $9, $11, $13, $16); }                 
                                                        | yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION relative_structure_time_plural MODIFIER THAN NUM HOURS NUM MINUTES PERIOD AND moving_structure_plural LOCATION '?'                       { find_route_time_intermediate($3, $5, $7, $9, $11, $13, $16); }            
                                                        | yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION PERIOD relative_structure_time_plural MODIFIER THAN NUM HOURS NUM MINUTES AND relative_structure_through_singular LOCATION '?'       { find_route_time_intermediate($3, $5, $8, $10, $12, $6, $16); }     
                                                        | yes_no_route_question_beginning_plural FROM LOCATION TO LOCATION PERIOD relative_structure_time_plural MODIFIER THAN NUM HOURS NUM MINUTES AND moving_structure_singular LOCATION '?'                 { find_route_time_intermediate($3, $5, $8, $10, $12, $6, $16); }
                                                        ;

route_time_intermediate_question                : yes_no_route_time_intermediate_question_singular
                                                | yes_no_route_time_intermediate_question_plural
                                                ;

yes_no_route_time_question      : yes_no_route_time_question_plural
                                | yes_no_route_time_question_singular
                                ;

wh_route_time_question  : wh_question_beginning_singular TIME_QUANTIFIER ROUTE FROM LOCATION TO LOCATION PERIOD '?'                                     { find_fastest_slowest_route_in_period($5, $7, $2, $8); }
                        | wh_question_beginning_singular TIME_QUANTIFIER ROUTE PERIOD FROM LOCATION TO LOCATION '?'                                     { find_fastest_slowest_route_in_period($6, $8, $2, $4); } 
                        ;

route_time_question     : wh_route_time_question
                        | yes_no_route_time_question 
                        ;

route_distance_question : wh_question_beginning_singular DISTANCE_QUANTIFIER ROUTE FROM LOCATION TO LOCATION '?'                    { find_shortest_longest_route($5, $7, $2); }
                        ;

route_question      : route_time_question
                    | route_distance_question
                    | intermediate_question
                    | route_time_intermediate_question
                    ;

question    : distance_question
            | route_question
            ;


%%

int get_location_id(char* location) {
    int location_id = -1;
    for(int i = 0; i < 10; i++) {
        if(strcmp(location, locations[i]) == 0) {
            location_id = i;
            break;
        }
    }

    return location_id;
}

void get_distance(char* locationA, char* locationB) {
    int idA = get_location_id(locationA);
    int idB = get_location_id(locationB);

    printf("The distance between %s and %s is %d km.\n\n", locationA, locationB, distances[idA][idB]);
}

void find_fastest_slowest_route_in_period(char* locationA, char* locationB, char* quantifier, char* period) {
    route found_route = { "None", "None", "None", -1, FLT_MAX, "None" };

    if (strcmp(quantifier, "slowest") == 0) {
        found_route.time = FLT_MIN;
    }

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0) {
            if (strcmp(routes[i].period, period) == 0) {
                if (strcmp(quantifier, "fastest") == 0 && routes[i].time < found_route.time) {
                    found_route = routes[i];
                }
                else if (strcmp(quantifier, "slowest") == 0 && routes[i].time > found_route.time) {
                    found_route = routes[i];
                }
            }
        }
    }

    if (found_route.distance == -1) {
        printf("There is no information about routes from %s to %s %s.\n", locationA, locationB, period);
    }
    else {
        int hours = floor(found_route.time);
        int mins = round((found_route.time - hours) * 100);
        printf("The %s route from %s to %s %s is:\n\t%s\n\ttime: %dh %dmin.\n\n", quantifier, locationA, locationB, period, found_route.way, hours, mins);
    }
}

void find_shortest_longest_route(char* locationA, char* locationB, char* quantifier) {
    route found_route = { "None", "None", "None", INT_MAX, -1.0f, "None" };

    if (strcmp(quantifier, "longest") == 0) {
        found_route.distance = INT_MIN;
    }

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0) {
            if (strcmp(quantifier, "shortest") == 0 && routes[i].distance < found_route.distance) {
                found_route = routes[i];
            }
            else if (strcmp(quantifier, "longest") == 0 && routes[i].distance > found_route.distance) {
                found_route = routes[i];
            }
        }
    }

    if (abs(found_route.time + 1.0f) < 1e-10) {
        printf("There is no information about routes from %s to %s.\n", locationA, locationB);
    }
    else {
        printf("The %s route from %s to %s is:\n\t%s\n\tdistance: %d km\n\n", quantifier, locationA, locationB, found_route.way, found_route.distance);
    }
}

bool check_if_exists(route r, route rs[], int n) {
    for (int i = 0; i < n; i++) {
        if (!strcmp(r.way, rs[i].way)) {
            return true;
        }
    }

    return false;
}

bool is_substring(char* substr, char* str) {
    char* ptr = strstr(substr, str);

    if (ptr != NULL) {
        return true;
    }

    return false;
}

void find_route_intermediate(char* locationA, char* locationB, char* intermediate) {
    route found_routes[8];
    int count = 0;

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0) {
            char* ptr = strstr(routes[i].way, intermediate);

            if (ptr != NULL && !check_if_exists(routes[i], found_routes, count)) {
                found_routes[count] = routes[i];
                count++;
            }
        }
    }

    if (count) {
        
        if (count == 1) {
            printf("Yes, the route from %s to %s that goes through %s is:\n\t%s\n\n", locationA, locationB, intermediate, found_routes[0].way);
        }
        else {
            printf("Yes, the following routes from %s to %s go through %s:\n", locationA, locationB, intermediate);
            for (int i = 0; i < count; i++) {
                printf("\t%s\n", found_routes[i].way);
            }
            printf("\n");
        }
        
    }
    else {
        printf("No, there is no route from %s to %s which goes through %s.\n\n", locationA, locationB, intermediate);
    }

}

void find_route_two_intermediates(char* locationA, char* locationB, char* intermediate1, char* intermediate2) {
    route found_routes[8];
    int count = 0;

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0) {
            char* ptr1 = strstr(routes[i].way, intermediate1);
            char* ptr2 = strstr(routes[i].way, intermediate2);

            if (ptr1 != NULL && ptr2 != NULL && ptr2 > ptr1 && !check_if_exists(routes[i], found_routes, count)) {
                    found_routes[count] = routes[i];
                    count++;
            }
        }
    }

    if (count) {
        
        if (count == 1) {
            printf("Yes, the route from %s to %s that goes through %s and %s is:\n\t%s\n\n", locationA, locationB, intermediate1, intermediate2, found_routes[0].way);
        }
        else {
            printf("Yes, the following routes from %s to %s go through %s and %s:\n", locationA, locationB, intermediate1, intermediate2);
            for (int i = 0; i < count; i++) {
                printf("\t%s\n", found_routes[i].way);
            }
            printf("\n");
        }
        
    }
    else {
        printf("No, there is no route from %s to %s which goes through %s and %s.\n\n", locationA, locationB, intermediate1, intermediate2);
    }
}

void find_route_time(char* locationA, char* locationB, char* modifier, int hours, int min, char* period) {
    route found_routes[8];
    int count = 0;
    float time = (hours * 100.0f + min) / 100.0f;

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0 && strcmp(routes[i].period, period) == 0) {

            if (strcmp(modifier, "less") == 0) {
                if (routes[i].time < time && !check_if_exists(routes[i], found_routes, count)) {
                    found_routes[count] = routes[i];
                    count++;
                }
            }
            else {
                if (routes[i].time > time && !check_if_exists(routes[i], found_routes, count)) {
                    found_routes[count] = routes[i];
                    count++;
                }
            }
        }
    }

    if (count) {

        if (count == 1) {
            int h = floor(found_routes[0].time);
            int mins = round((found_routes[0].time - h) * 100);
            printf("Yes, the route from %s to %s which needs %s than %dh %dmin %s is:\n\t%s\n\ttime: %dh %dmin\n\n", locationA, locationB, modifier, hours, min, period, found_routes[0].way, h, mins);
        }
        else {
            printf("Yes, the following routes from %s to %s need %s than %dh %dmin %s:\n", locationA, locationB, modifier, hours, min, period);
            for (int i = 0; i < count; i++) {
                int h = floor(found_routes[i].time);
                int mins = round((found_routes[i].time - h) * 100);
                printf("\t%s\n\t\ttime: %dh %dmin\n", found_routes[i].way, h, mins);
            }
            printf("\n");
        }
        
    }
    else {
        printf("No, there is no route from %s to %s which needs %s than %dh %dmin %s.\n\n", locationA, locationB, modifier, hours, min, period);
    }
}

void find_route_time_intermediate(char* locationA, char* locationB, char* modifier, int hours, int min, char* period, char* intermediate) {
    route found_routes[8];
    int count = 0;
    float time = (hours * 100.0f + min) / 100.0f;

    for (int i = 0; i < 8; i++) {
        if (strcmp(routes[i].from, locationA) == 0 && strcmp(routes[i].to, locationB) == 0 && strcmp(routes[i].period, period) == 0) {

            if (strcmp(modifier, "less") == 0) {
                if (routes[i].time < time && !check_if_exists(routes[i], found_routes, count)) {
                    found_routes[count] = routes[i];
                    count++;
                }
            }
            else {
                if (routes[i].time > time && !check_if_exists(routes[i], found_routes, count)) {
                    found_routes[count] = routes[i];
                    count++;
                }
            }
        }
    }

    
    route final_routes[8];
    int count_final = 0;

    if (count > 0) {
       
        for (int i = 0; i < count; i++) {
            if (strcmp(found_routes[i].from, locationA) == 0 && strcmp(found_routes[i].to, locationB) == 0) {
                char* ptr = strstr(found_routes[i].way, intermediate);

                if (ptr != NULL && !check_if_exists(found_routes[i], final_routes, count_final)) {
                    final_routes[count_final] = found_routes[i];
                    count_final++;
                }
            }
        }

        if (count_final == 1) {
            int h = floor(final_routes[0].time);
            int mins = round((final_routes[0].time - h) * 100);
            printf("Yes, the route from %s to %s which needs %s than %dh %dmin %s and goes through %s:\n\t%s\n\ttime: %dh %dmin\n\n", locationA, locationB, modifier, hours, min, period, intermediate, found_routes[0].way, h, mins);
        }
        else if (count_final > 1) {
            printf("Yes, the following routes from %s to %s need %s than %dh %dmin %s and go through %s:\n", locationA, locationB, modifier, hours, min, period, intermediate);
            for (int i = 0; i < count; i++) {
                int h = floor(final_routes[i].time);
                int minutes = round((final_routes[i].time - floor(final_routes[i].time)) * 100);
                printf("\t%s\n\t\ttime: %dh %dmin\n", final_routes[i].way, h, minutes);
            }
            printf("\n");
        }
        else {
            printf("No, there is no route from %s to %s which needs %s than %dh %dmin %s and goes through %s.\n\n", locationA, locationB, modifier, hours, min, period, intermediate);
        }
    }
    
    else {
        printf("No, there is no route from %s to %s which needs %s than %dh %dmin %s and goes through %s.\n\n", locationA, locationB, modifier, hours, min, period, intermediate);
    }
}