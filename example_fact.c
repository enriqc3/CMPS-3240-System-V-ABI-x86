#include <stdio.h>

// A recursive factorial function that accepts n as the only argument
int my_fact( int );

int main( void ) {
    // Call the recursive factorial function
    int result = my_fact( 13 );
    // Display the result
    printf( "13! = %d\n", result );
    // Return
    return 0;
}

int my_fact( int arg ) {
    if( arg <= 1 )
        return 1;
    else
        return arg * my_fact( arg - 1 );
}
