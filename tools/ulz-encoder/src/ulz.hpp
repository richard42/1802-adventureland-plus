/*

ULZ.HPP - An ultra-fast LZ77 data compression library

Written and placed in the public domain by Ilya Muravyov

*/

#ifndef ULZ_HPP_INCLUDED
#define ULZ_HPP_INCLUDED

class ULZ
{
public:
  typedef unsigned char U8;
  typedef unsigned short U16;
  typedef unsigned int U32;
  typedef unsigned long long U64;

  static const int EXCESS=16;

  static const int WINDOW_BITS=17; // Hard-coded
  static const int WINDOW_SIZE=1<<WINDOW_BITS;
  static const int WINDOW_MASK=WINDOW_SIZE-1;

  static const int MIN_MATCH=4;

  static const int HASH_BITS=19;
  static const int HASH_SIZE=1<<HASH_BITS;
  static const int NIL=-1;

  int HashTable[HASH_SIZE];
  int Prev[WINDOW_SIZE];

  // Utils

  template<typename T>
  inline T Min(T a, T b)
  {
    return (a<b)?a:b;
  }

  template<typename T>
  inline T Max(T a, T b)
  {
    return (a>b)?a:b;
  }

  inline U16 UnalignedLoad16(void* p)
  {
    return *reinterpret_cast<const U16*>(p);
  }

  inline U32 UnalignedLoad32(void* p)
  {
    return *reinterpret_cast<const U32*>(p);
  }

  inline void UnalignedStore16(void* p, U16 x)
  {
    *reinterpret_cast<U16*>(p)=x;
  }

  inline void UnalignedCopy64(void* d, void* s)
  {
    *reinterpret_cast<U64*>(d)=*reinterpret_cast<const U64*>(s);
  }

  inline void WildCopy(U8* d, U8* s, int n)
  {
    UnalignedCopy64(d, s);

    for (int i=8; i<n; i+=8)
      UnalignedCopy64(d+i, s+i);
  }

  inline U32 Hash32(void* p)
  {
    return (UnalignedLoad32(p)*0x9E3779B9)>>(32-HASH_BITS);
  }

  inline void EncodeMod(U8*& p, U32 x)
  {
    while (x>=128)
    {
      *p++=128+(x&127);
      x>>=7;
    }
    *p++=x;
  }

  inline U32 DecodeMod(U8*& p)
  {
    U32 x=0;
    for (int i=0; i<=21; i+=7)
    {
      const U32 c=*p++;
      x+=(c&127)<<i;
      if (c<128)
        break;
    }
    return x;
  }

  // LZ77

  int CompressFast(U8* in, int in_len, U8* out)
  {
    for (int i=0; i<HASH_SIZE; ++i)
      HashTable[i]=NIL;

    U8* op=out;
    int anchor=0;

    int p=0;
    while (p<in_len)
    {
      int best_len=0;
      int dist=0;

      const int max_match=in_len-p;
      if (max_match>=MIN_MATCH)
      {
        const int limit=Max(p-WINDOW_SIZE, NIL);

        const U32 h=Hash32(&in[p]);
        int s=HashTable[h];
        HashTable[h]=p;

        if (s>limit && UnalignedLoad32(&in[s])==UnalignedLoad32(&in[p]))
        {
          int len=MIN_MATCH;
          while (len<max_match && in[s+len]==in[p+len])
            ++len;

          best_len=len;
          dist=p-s;
        }
      }

      if (best_len==MIN_MATCH && (p-anchor)>=(7+128))
        best_len=0;

      if (best_len>=MIN_MATCH)
      {
        const int len=best_len-MIN_MATCH;
        const int token=((dist>>12)&16)+Min(len, 15);

        if (anchor!=p)
        {
          const int run=p-anchor;
          if (run>=7)
          {
            *op++=(7<<5)+token;
            EncodeMod(op, run-7);
          }
          else
            *op++=(run<<5)+token;

          WildCopy(op, &in[anchor], run);
          op+=run;
        }
        else
          *op++=token;

        if (len>=15)
          EncodeMod(op, len-15);

        UnalignedStore16(op, dist);
        op+=2;

        anchor=p+best_len;
        ++p;
        HashTable[Hash32(&in[p])]=p++;
        HashTable[Hash32(&in[p])]=p++;
        HashTable[Hash32(&in[p])]=p++;
        p=anchor;
      }
      else
        ++p;
    }

    if (anchor!=p)
    {
      const int run=p-anchor;
      if (run>=7)
      {
        *op++=7<<5;
        EncodeMod(op, run-7);
      }
      else
        *op++=run<<5;

      WildCopy(op, &in[anchor], run);
      op+=run;
    }

    return op-out;
  }
  
  unsigned int FindLog2(unsigned int value)
  {
    int bits = 0;
    do
    {
      bits++;
      value = value >> 1;
    } while (value > 0);
    return bits;
  }

  int Compress(U8* in, int in_len, U8* out, int level)
  {
    if (level<1 || level>9)
      return -1;
    const int max_chain=(level<9)?1<<level:1<<13;

    for (int i=0; i<HASH_SIZE; ++i)
      HashTable[i]=NIL;

    int iCopyLenLog2[16];
    int iMatchLenLog2[16];
    int iDistLenLog2[16];
    for (int i = 0; i < 16; i++)
    {
        iCopyLenLog2[i] = iMatchLenLog2[i] = iDistLenLog2[i] = 0;
    }

    U8* op=out;
    int anchor=0;

    int p=0;
    int num_tokens=0;
    while (p<in_len)
    {
      int best_len=0;
      int dist=0;

      const int max_match=in_len-p;
      if (max_match>=MIN_MATCH)
      {
        const int limit=Max(p-WINDOW_SIZE, NIL);
        int chain_len=max_chain;

        int s=HashTable[Hash32(&in[p])];
        while (s>limit)
        {
          if (in[s+best_len]==in[p+best_len]
              && UnalignedLoad32(&in[s])==UnalignedLoad32(&in[p]))
          {
            int len=MIN_MATCH;
            while (len<max_match && in[s+len]==in[p+len])
              ++len;

            if (len>best_len)
            {
              best_len=len;
              dist=p-s;

              if (len==max_match)
                break;
            }
          }

          if (--chain_len==0)
            break;

          s=Prev[s&WINDOW_MASK];
        }
      }

      if (best_len==MIN_MATCH && (p-anchor)>=(15+128))
        best_len=0;

      if (level>=5 && best_len>=MIN_MATCH && best_len<max_match
          && (p-anchor)!=14)
      {
        const int x=p+1;
        const int target_len=best_len+1;

        const int limit=Max(x-WINDOW_SIZE, NIL);
        int chain_len=max_chain;

        int s=HashTable[Hash32(&in[x])];
        while (s>limit)
        {
          if (in[s+best_len]==in[x+best_len]
              && UnalignedLoad32(&in[s])==UnalignedLoad32(&in[x]))
          {
            int len=MIN_MATCH;
            while (len<target_len && in[s+len]==in[x+len])
              ++len;

            if (len==target_len)
            {
              best_len=0;
              break;
            }
          }

          if (--chain_len==0)
            break;

          s=Prev[s&WINDOW_MASK];
        }
      }

      if (best_len>=MIN_MATCH)
      {
        const int len=best_len-MIN_MATCH;
        const int token=Min(len, 15);

        if (anchor!=p)
        {
          const int run=p-anchor;
          iCopyLenLog2[FindLog2(run)]++;
          iMatchLenLog2[FindLog2(len)]++;
          iDistLenLog2[FindLog2(dist)]++;
          if (run>=15)
          {
            *op++=(15<<4)+token;
            EncodeMod(op, run-15);
          }
          else
            *op++=(run<<4)+token;

          WildCopy(op, &in[anchor], run);
          op+=run;
        }
        else
        {
          iCopyLenLog2[0]++;
          iMatchLenLog2[FindLog2(len)]++;
          iDistLenLog2[FindLog2(dist)]++;
          *op++=token;
        }
        num_tokens++;

        if (len>=15)
          EncodeMod(op, len-15);

        EncodeMod(op, dist);

        while (best_len--!=0)
        {
          const U32 h=Hash32(&in[p]);
          Prev[p&WINDOW_MASK]=HashTable[h];
          HashTable[h]=p++;
        }
        anchor=p;
      }
      else
      {
        const U32 h=Hash32(&in[p]);
        Prev[p&WINDOW_MASK]=HashTable[h];
        HashTable[h]=p++;
      }
    }

    if (anchor!=p)
    {
      const int run=p-anchor;
      iCopyLenLog2[FindLog2(run)]++;
      iMatchLenLog2[0]++;
      if (run>=15)
      {
        *op++=15<<4;
        EncodeMod(op, run-15);
      }
      else
        *op++=run<<4;

      num_tokens++;
      WildCopy(op, &in[anchor], run);
      op+=run;
    }

    printf("Total compression tokens: %i\n", num_tokens);
    printf("Value size log 2:\n");
    printf("Copy length:  ");
    for (int i = 0; i < 16; i++) printf("%04i ", iCopyLenLog2[i]);
    printf("\nMatch length: ");
    for (int i = 0; i < 16; i++) printf("%04i ", iMatchLenLog2[i]);
    printf("\nDist length:  ");
    for (int i = 0; i < 16; i++) printf("%04i ", iDistLenLog2[i]);
    printf("\n");

    return op-out;
  }

  int Decompress(U8* in, int in_len, U8* out, int out_len)
  {
    U8* op=out;
    U8* ip=in;
    const U8* ip_end=ip+in_len;
    const U8* op_end=op+out_len;

    while (ip<ip_end)
    {
      const int token=*ip++;

      if (token>=16)
      {
        int run=token>>4;
        if (run==15)
          run+=DecodeMod(ip);
        if ((op_end-op)<run || (ip_end-ip)<run) // Overrun check
          return -1;

        WildCopy(op, ip, run);
        op+=run;
        ip+=run;
        if (ip>=ip_end)
          break;
      }

      int len=(token&15)+MIN_MATCH;
      if (len==(15+MIN_MATCH))
        len+=DecodeMod(ip);
      if ((op_end-op)<len) // Overrun check
        return -1;

      const int dist=DecodeMod(ip);
      U8* cp=op-dist;
      if ((op-out)<dist) // Range check
        return -1;

      if (dist>=8)
      {
        WildCopy(op, cp, len);
        op+=len;
      }
      else
      {
        *op++=*cp++;
        *op++=*cp++;
        *op++=*cp++;
        *op++=*cp++;
        while (len--!=4)
          *op++=*cp++;
      }
    }

    return (ip==ip_end)?op-out:-1;
  }
};

#endif // ULZ_HPP_INCLUDED
