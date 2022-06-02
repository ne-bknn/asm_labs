void _start() {
  static unsigned short a = 10;
  static unsigned short b = 20;
  static unsigned int   c = 30;
  static unsigned short d = 50;
  static unsigned int   e = 70;

  unsigned int   result = (a*e-b*c+(d/b))/((b+c)*a);
}
