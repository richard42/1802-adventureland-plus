/*

ULZ.CPP - An ultra-fast LZ77 compressor

Written and placed in the public domain by Ilya Muravyov

*/

#define _CRT_SECURE_NO_WARNINGS
#define _CRT_DISABLE_PERFCRIT_LOCKS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifndef _MSC_VER
#  define _ftelli64 ftello64
#endif

#include "ulz.hpp"

#define ULZ_MAGIC 0x215A4C55 // "ULZ!"

#define BLOCK_SIZE (1<<24)

void compress_fast(FILE* in, FILE* out)
{
  ULZ* ulz=new ULZ;

  ULZ::U8* in_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];
  ULZ::U8* out_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];

  int raw_len;
  while ((raw_len=fread(in_buf, 1, BLOCK_SIZE, in))>0)
  {
    const int comp_len=ulz->CompressFast(in_buf, raw_len, out_buf);

    fwrite(&comp_len, 1, sizeof(comp_len), out);
    fwrite(out_buf, 1, comp_len, out);

    fprintf(stderr, "%lld -> %lld\r", _ftelli64(in), _ftelli64(out));
  }

  delete ulz;

  delete[] in_buf;
  delete[] out_buf;
}

void compress(FILE* in, FILE* out, int level)
{
  ULZ* ulz=new ULZ;

  ULZ::U8* in_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];
  ULZ::U8* out_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];

  int raw_len;
  while ((raw_len=fread(in_buf, 1, BLOCK_SIZE, in))>0)
  {
    const int comp_len=ulz->Compress(in_buf, raw_len, out_buf, level);

    fwrite(&comp_len, 1, sizeof(comp_len), out);
    fwrite(out_buf, 1, comp_len, out);

    fprintf(stderr, "%lld -> %lld\r", _ftelli64(in), _ftelli64(out));
  }

  delete ulz;

  delete[] in_buf;
  delete[] out_buf;
}

int decompress(FILE* in, FILE* out)
{
  ULZ* ulz=new ULZ;

  ULZ::U8* in_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];
  ULZ::U8* out_buf=new ULZ::U8[BLOCK_SIZE+ULZ::EXCESS];

  int comp_len;
  while (fread(&comp_len, 1, sizeof(comp_len), in)>0)
  {
    if (comp_len<2 || comp_len>(BLOCK_SIZE+ULZ::EXCESS)
        || fread(in_buf, 1, comp_len, in)!=comp_len)
      return -1;

    const int out_len=ulz->Decompress(in_buf, comp_len, out_buf, BLOCK_SIZE);
    if (out_len<0)
      return -1;

    if (fwrite(out_buf, 1, out_len, out)!=out_len)
    {
      perror("Fwrite() failed");
      exit(1);
    }

    fprintf(stderr, "%lld -> %lld\r", _ftelli64(in), _ftelli64(out));
  }

  delete ulz;

  delete[] in_buf;
  delete[] out_buf;

  return 0;
}

int main(int argc, char** argv)
{
  const clock_t start=clock();

  if (argc<3)
  {
    fprintf(stderr,
        "ULZ - An ultra-fast LZ77 compressor, v1.01 BETA\n"
        "Written and placed in the public domain by Ilya Muravyov\n"
        "\n"
        "Usage: ULZ command infile [outfile]\n"
        "\n"
        "Commands:\n"
        "  c[#] Compress; Set the level of compression (1..9)\n"
        "  d    Decompress\n");
    exit(1);
  }

  FILE* in=fopen(argv[2], "rb");
  if (!in)
  {
    perror(argv[2]);
    exit(1);
  }

  char out_name[FILENAME_MAX];
  if (argc<4)
  {
    strcpy(out_name, argv[2]);
    if (*argv[1]=='d')
    {
      const int p=strlen(out_name)-4;
      if (p>0 && strcmp(&out_name[p], ".ulz")==0)
        out_name[p]='\0';
      else
        strcat(out_name, ".out");
    }
    else
      strcat(out_name, ".ulz");
  }
  else
    strcpy(out_name, argv[3]);

  FILE* out=fopen(out_name, "wb");
  if (!out)
  {
    perror(out_name);
    exit(1);
  }

  if (*argv[1]=='c')
  {
    int level=1;
    if (argv[1][1]!='\0')
      level=atoi(&argv[1][1]);
    if (level<1 || level>9)
    {
      fprintf(stderr, "Compression level must be 1 through 9\n");
      exit(1);
    }

    printf("Compressing %s:\n", argv[2]);

    const int magic=ULZ_MAGIC;
    fwrite(&magic, 1, sizeof(magic), out);

    if (level==1)
      compress_fast(in, out);
    else
      compress(in, out, level);
  }
  else if (*argv[1]=='d')
  {
    int magic;
    fread(&magic, 1, sizeof(magic), in);
    if (magic!=ULZ_MAGIC)
    {
      fprintf(stderr, "%s: Not in ULZ format\n", argv[2]);
      exit(1);
    }

    printf("Decompressing %s:\n", argv[2]);

    if (decompress(in, out)!=0)
    {
      fprintf(stderr, "%s: Corrupt input\n", argv[2]);
      exit(1);
    }
  }
  else
  {
    fprintf(stderr, "Unknown command: %s\n", argv[1]);
    exit(1);
  }

  printf("%lld -> %lld in %1.3f sec\n", _ftelli64(in), _ftelli64(out),
      double(clock()-start)/CLOCKS_PER_SEC);

  fclose(in);
  fclose(out);

  return 0;
}
