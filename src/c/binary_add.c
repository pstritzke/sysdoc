/* For more information see
 * https://www.youtube.com/watch?v=VBDoT8o4q00
 */

#include <stdlib.h>
#include <stdio.h>

struct sled_matrix {
    unsigned short led1; 
    unsigned short led2;
    unsigned short led3;
    unsigned short led4;
    unsigned short led5;
    unsigned short led6;
    unsigned short led7;
    unsigned short led8;
};

struct shalf_adder{
    unsigned short a;
    unsigned short b;
    
    unsigned short left_led;
    unsigned short right_led;
};

struct sfull_adder{
    unsigned short a;
    unsigned short b;
    unsigned short ci;
    unsigned short co;
    unsigned short sum;
};


int no_input(unsigned short a, unsigned short b) {
    if(a == 0){
        if(b == 0){
            return 0;
        }
    }
}

int and_gate(unsigned short a, unsigned short b){

    if(a == 1){
        if(b == 1){
            return 1;
        }
    }
    return 0;
}

int nand_gate(unsigned short a, unsigned short b) {

    if(and_gate(a, b)) {
        return 0;
    }
    return 1;

}

int or_gate(unsigned short a, unsigned short b) {

    if(and_gate(a, b)) {
        return 1;
    }

    if(no_input(a, b)) {
        return 0;
    }
    
    return 1;
}

int xor_gate(unsigned short a, unsigned short b){

    unsigned short a_helper, b_helper;

    a_helper = or_gate(a, b);
    b_helper = nand_gate(a, b);

    return and_gate(a_helper, b_helper);
}

int half_adder(unsigned short a, unsigned short b, struct shalf_adder  *half_adder) {

    half_adder->a = a;
    half_adder->b = b;

    half_adder->left_led = and_gate(a, b);
    half_adder->right_led = xor_gate(a, b);

    return 0;
}

int full_adder(unsigned short a, unsigned short b, unsigned short ci, struct sfull_adder *full_adder) {

    struct shalf_adder half_a;
    struct shalf_adder half_b;

    half_adder(a, b, &half_a); 
    half_adder(ci, half_a.left_led, &half_b);

    full_adder->a = a;
    full_adder->b = b;
    full_adder->ci = ci;

    full_adder->co = or_gate(half_a.right_led, half_b.right_led);
    full_adder->sum = half_b.left_led;
}

int print_matrix(struct sled_matrix *led_matrix) {

    printf("Dec: 128  64  32  16  8  4  2  1\n");

    printf("Bin:  %d    %d   %d   %d  %d  %d  %d  %d\n",
            led_matrix->led8,
            led_matrix->led7,
            led_matrix->led6,
            led_matrix->led5,
            led_matrix->led4,
            led_matrix->led3,
            led_matrix->led2,
            led_matrix->led1
          );
    
    return 0;
}


int main(int argc, char* argv[]) {

    struct sled_matrix led_matrix;

    led_matrix.led8 = 0;
    led_matrix.led7 = 0;
    led_matrix.led6 = 0;
    led_matrix.led5 = 0;
    led_matrix.led4 = 0;
    led_matrix.led3 = 0;
    led_matrix.led2 = 0;
    led_matrix.led1 = 0;

    struct sfull_adder full;

    full_adder(1, 1, 1, &full);

    led_matrix.led1 = full.co;
    led_matrix.led2 = full.sum;

    print_matrix(&led_matrix);

    return 0;
}
