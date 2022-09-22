#include <time.h>
#include <stdio.h>

char buf[1000];

void test_tm(time_t t)
{
  struct tm *p;
  p = gmtime(&t);
  printf( "%d/%02d/%02d %02d:%02d:%02d\n", p->tm_year + 1900, p->tm_mon +1, p->tm_mday, p->tm_hour, p->tm_min, p->tm_sec );
}

int main()
{

  // time_t のバイト数、ビット数
  printf( "sizeof(time_t) : %d bytes (%d bits) \n", sizeof(time_t), sizeof(time_t)*8 );

  // time_t は整数型か浮動小数点型か
  float a = 1.1;
  double b = 1.1;
  long double c = 1.1;
  if ( a == (time_t)a || b == (time_t)b || c == (time_t)c ) {
    printf( "floating point number type\n" );
  }
  else {
    printf( "integer type\n" );
  }

  printf( "(time_t) 0 :" ); // epoch 次第で結果が変わる
  test_tm( (time_t)0 );

  printf("(time_t)-1 :");// time_t の定義次第で結果が変わる
  test_tm( (time_t)-1 );

  printf("(time_t)0x ffff ffff :"); // unsigned 32bit int の正の最大値
  test_tm( (time_t)0xffffffff );

  printf("(time_t)0x 7fff ffff :"); // signed 32bit int の正の最大値
  test_tm( (time_t)0x7fffffff );

  printf("(time_t)0x 7fff fffe :"); // signed 32bit int の正の最大値 -1
  test_tm( (time_t)0x7ffffffe );

  printf("(time_t)0x 8000 0000 :"); // signed 32bit int の正の最大値 +1
  test_tm( (time_t)0x80000000 );

  printf("(time_t)0x10000 0000 :"); // 33bit を time_t にキャストしたら？
  test_tm( (time_t)0x100000000 );
}
