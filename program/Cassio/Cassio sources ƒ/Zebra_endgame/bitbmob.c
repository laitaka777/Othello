/*
   File:          bitbmob.c

   Created:       November 22, 1999
   
   Modified:      November 14, 2004

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:
*/



#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "bitbmob.h"
#include "bitboard.h"



static unsigned long long dir_mask0;
static unsigned long long dir_mask1;
static unsigned long long dir_mask2;
static unsigned long long dir_mask3;
static unsigned long long dir_mask4;
static unsigned long long dir_mask5;
static unsigned long long dir_mask6;
static unsigned long long dir_mask7;
static unsigned long long c0f;
static unsigned long long c33;
static unsigned long long c55;



static const unsigned int mask_low[100] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0x1u, 0x2u, 0x4u, 0x8u, 0x10u, 0x20u, 0x40u, 0x80u, 0,
  0, 0x100u, 0x200u, 0x400u, 0x800u, 0x1000u, 0x2000u, 0x4000u, 0x8000u, 0,
  0, 0x10000u, 0x20000u, 0x40000u, 0x80000u, 0x100000u, 0x200000u, 0x400000u, 0x800000u, 0,
  0, 0x1000000u, 0x2000000u, 0x4000000u, 0x8000000u, 0x10000000u, 0x20000000u, 0x40000000u, 0x80000000u, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
static const unsigned int mask_high[100] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0x1u, 0x2u, 0x4u, 0x8u, 0x10u, 0x20u, 0x40u, 0x80u, 0,
  0, 0x100u, 0x200u, 0x400u, 0x800u, 0x1000u, 0x2000u, 0x4000u, 0x8000u, 0,
  0, 0x10000u, 0x20000u, 0x40000u, 0x80000u, 0x100000u, 0x200000u, 0x400000u, 0x800000u, 0,
  0, 0x1000000u, 0x2000000u, 0x4000000u, 0x8000000u, 0x10000000u, 0x20000000u, 0x40000000u, 0x80000000u, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};


void
init_mmx( void ) {
  dir_mask0 = 0x007e7e7e7e7e7e00ULL;
  dir_mask1 = 0x00ffffffffffff00ULL;
  dir_mask2 = 0x007e7e7e7e7e7e00ULL;
  dir_mask3 = 0x7e7e7e7e7e7e7e7eULL;
  dir_mask4 = 0x7e7e7e7e7e7e7e7eULL;
  dir_mask5 = 0x007e7e7e7e7e7e00ULL;
  dir_mask6 = 0x00ffffffffffff00ULL;
  dir_mask7 = 0x007e7e7e7e7e7e00ULL;
  c0f = 0x0f0f0f0f0f0f0f0fULL;
  c33 = 0x3333333333333333ULL;
  c55 = 0x5555555555555555ULL;
}




// Slow but portable popcount and mobility codes.


static int
pop_count_loop( BitBoard bits ) {
  unsigned int count = 0;

  while ( bits.high ) {
    bits.high &= (bits.high - 1);
    count++;
  }

  while ( bits.low ) {
    bits.low &= (bits.low - 1);
    count++;
  }

  return count;
}



static BitBoard
generate_all_loop( const BitBoard my_bits,
		   const BitBoard opp_bits ) {
  BitBoard moves = { 0, 0 };
  int sq = end_move_list[END_MOVE_LIST_HEAD].succ;

  for ( ; sq != END_MOVE_LIST_TAIL; sq = end_move_list[sq].succ ) {
    switch ( sq ) {
    case 11:
      /* Right */
      if ( (opp_bits.low + 0x00000002ul) & my_bits.low & 0x000000fcul )
        goto FEASIBLE;
      /* Down */
      if ( opp_bits.low & 0x00000100ul ) {
        if ( opp_bits.low & 0x00010000ul ) {
          if ( opp_bits.low & 0x01000000ul ) {
            if ( opp_bits.high & 0x00000001ul ) {
              if ( opp_bits.high & 0x00000100ul ) {
                if ( opp_bits.high & 0x00010000ul ) {
                  if ( my_bits.high & 0x01000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00010000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000100ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000001ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.high & 0x00000010ul ) {
              if ( opp_bits.high & 0x00002000ul ) {
                if ( opp_bits.high & 0x00400000ul ) {
                  if ( my_bits.high & 0x80000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00400000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00002000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000010ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 18:
      /* Left */
      if ( (((my_bits.low & 0x0000003ful) << 1) + opp_bits.low) &
           0x00000080ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.high & 0x00000008ul ) {
              if ( opp_bits.high & 0x00000400ul ) {
                if ( opp_bits.high & 0x00020000ul ) {
                  if ( my_bits.high & 0x01000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00020000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000400ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000008ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00008000ul ) {
        if ( opp_bits.low & 0x00800000ul ) {
          if ( opp_bits.low & 0x80000000ul ) {
            if ( opp_bits.high & 0x00000080ul ) {
              if ( opp_bits.high & 0x00008000ul ) {
                if ( opp_bits.high & 0x00800000ul ) {
                  if ( my_bits.high & 0x80000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00800000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00008000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000080ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 81:
      /* Right */
      if ( (opp_bits.high + 0x02000000ul) & my_bits.high & 0xfc000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.low & 0x10000000ul ) {
              if ( opp_bits.low & 0x00200000ul ) {
                if ( opp_bits.low & 0x00004000ul ) {
                  if ( my_bits.low & 0x00000080ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00004000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00200000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x10000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00010000ul ) {
        if ( opp_bits.high & 0x00000100ul ) {
          if ( opp_bits.high & 0x00000001ul ) {
            if ( opp_bits.low & 0x01000000ul ) {
              if ( opp_bits.low & 0x00010000ul ) {
                if ( opp_bits.low & 0x00000100ul ) {
                  if ( my_bits.low & 0x00000001ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00000100ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00010000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x01000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 88:
      /* Left */
      if ( (((my_bits.high & 0x3f000000ul) << 1) + opp_bits.high) &
           0x80000000ul )
        goto FEASIBLE;
      /* Up */
      if ( opp_bits.high & 0x00800000ul ) {
        if ( opp_bits.high & 0x00008000ul ) {
          if ( opp_bits.high & 0x00000080ul ) {
            if ( opp_bits.low & 0x80000000ul ) {
              if ( opp_bits.low & 0x00800000ul ) {
                if ( opp_bits.low & 0x00008000ul ) {
                  if ( my_bits.low & 0x00000080ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00008000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00800000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x80000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.low & 0x08000000ul ) {
              if ( opp_bits.low & 0x00040000ul ) {
                if ( opp_bits.low & 0x00000200ul ) {
                  if ( my_bits.low & 0x00000001ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00000200ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00040000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x08000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 12:
      /* Right */
      if ( (opp_bits.low + 0x00000004ul) & my_bits.low & 0x000000f8ul )
        goto FEASIBLE;
      /* Down */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( opp_bits.low & 0x00020000ul ) {
          if ( opp_bits.low & 0x02000000ul ) {
            if ( opp_bits.high & 0x00000002ul ) {
              if ( opp_bits.high & 0x00000200ul ) {
                if ( opp_bits.high & 0x00020000ul ) {
                  if ( my_bits.high & 0x02000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00020000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000200ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000002ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.high & 0x00000020ul ) {
              if ( opp_bits.high & 0x00004000ul ) {
                if ( my_bits.high & 0x00800000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00004000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000020ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 17:
      /* Left */
      if ( (((my_bits.low & 0x0000001ful) << 1) + opp_bits.low) &
           0x00000040ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.high & 0x00000004ul ) {
              if ( opp_bits.high & 0x00000200ul ) {
                if ( my_bits.high & 0x00010000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000200ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000004ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( opp_bits.low & 0x00400000ul ) {
          if ( opp_bits.low & 0x40000000ul ) {
            if ( opp_bits.high & 0x00000040ul ) {
              if ( opp_bits.high & 0x00004000ul ) {
                if ( opp_bits.high & 0x00400000ul ) {
                  if ( my_bits.high & 0x40000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00400000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00004000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000040ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 21:
      /* Right */
      if ( (opp_bits.low + 0x00000200ul) & my_bits.low & 0x0000fc00ul )
        goto FEASIBLE;
      /* Down */
      if ( opp_bits.low & 0x00010000ul ) {
        if ( opp_bits.low & 0x01000000ul ) {
          if ( opp_bits.high & 0x00000001ul ) {
            if ( opp_bits.high & 0x00000100ul ) {
              if ( opp_bits.high & 0x00010000ul ) {
                if ( my_bits.high & 0x01000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00010000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000100ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.high & 0x00001000ul ) {
              if ( opp_bits.high & 0x00200000ul ) {
                if ( my_bits.high & 0x40000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00200000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00001000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 28:
      /* Left */
      if ( (((my_bits.low & 0x00003f00ul) << 1) + opp_bits.low) &
           0x00008000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.high & 0x00000800ul ) {
              if ( opp_bits.high & 0x00040000ul ) {
                if ( my_bits.high & 0x02000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00040000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000800ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00800000ul ) {
        if ( opp_bits.low & 0x80000000ul ) {
          if ( opp_bits.high & 0x00000080ul ) {
            if ( opp_bits.high & 0x00008000ul ) {
              if ( opp_bits.high & 0x00800000ul ) {
                if ( my_bits.high & 0x80000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00800000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00008000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 71:
      /* Right */
      if ( (opp_bits.high + 0x00020000ul) & my_bits.high & 0x00fc0000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.low & 0x00100000ul ) {
              if ( opp_bits.low & 0x00002000ul ) {
                if ( my_bits.low & 0x00000040ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00002000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00100000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000100ul ) {
        if ( opp_bits.high & 0x00000001ul ) {
          if ( opp_bits.low & 0x01000000ul ) {
            if ( opp_bits.low & 0x00010000ul ) {
              if ( opp_bits.low & 0x00000100ul ) {
                if ( my_bits.low & 0x00000001ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000100ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00010000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 78:
      /* Left */
      if ( (((my_bits.high & 0x003f0000ul) << 1) + opp_bits.high) &
           0x00800000ul )
        goto FEASIBLE;
      /* Up */
      if ( opp_bits.high & 0x00008000ul ) {
        if ( opp_bits.high & 0x00000080ul ) {
          if ( opp_bits.low & 0x80000000ul ) {
            if ( opp_bits.low & 0x00800000ul ) {
              if ( opp_bits.low & 0x00008000ul ) {
                if ( my_bits.low & 0x00000080ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00008000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00800000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.low & 0x00080000ul ) {
              if ( opp_bits.low & 0x00000400ul ) {
                if ( my_bits.low & 0x00000002ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000400ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00080000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 82:
      /* Right */
      if ( (opp_bits.high + 0x04000000ul) & my_bits.high & 0xf8000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.low & 0x20000000ul ) {
              if ( opp_bits.low & 0x00400000ul ) {
                if ( my_bits.low & 0x00008000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00400000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x20000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( opp_bits.high & 0x00000200ul ) {
          if ( opp_bits.high & 0x00000002ul ) {
            if ( opp_bits.low & 0x02000000ul ) {
              if ( opp_bits.low & 0x00020000ul ) {
                if ( opp_bits.low & 0x00000200ul ) {
                  if ( my_bits.low & 0x00000002ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00000200ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00020000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x02000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 87:
      /* Left */
      if ( (((my_bits.high & 0x1f000000ul) << 1) + opp_bits.high) &
           0x40000000ul )
        goto FEASIBLE;
      /* Up */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( opp_bits.high & 0x00004000ul ) {
          if ( opp_bits.high & 0x00000040ul ) {
            if ( opp_bits.low & 0x40000000ul ) {
              if ( opp_bits.low & 0x00400000ul ) {
                if ( opp_bits.low & 0x00004000ul ) {
                  if ( my_bits.low & 0x00000040ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00004000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00400000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x40000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.low & 0x04000000ul ) {
              if ( opp_bits.low & 0x00020000ul ) {
                if ( my_bits.low & 0x00000100ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00020000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x04000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 22:
      /* Right */
      if ( (opp_bits.low + 0x00000400ul) & my_bits.low & 0x0000f800ul )
        goto FEASIBLE;
      /* Down */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( opp_bits.low & 0x02000000ul ) {
          if ( opp_bits.high & 0x00000002ul ) {
            if ( opp_bits.high & 0x00000200ul ) {
              if ( opp_bits.high & 0x00020000ul ) {
                if ( my_bits.high & 0x02000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00020000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000200ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.high & 0x00002000ul ) {
              if ( opp_bits.high & 0x00400000ul ) {
                if ( my_bits.high & 0x80000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00400000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00002000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 27:
      /* Left */
      if ( (((my_bits.low & 0x00001f00ul) << 1) + opp_bits.low) &
           0x00004000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.high & 0x00000400ul ) {
              if ( opp_bits.high & 0x00020000ul ) {
                if ( my_bits.high & 0x01000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00020000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000400ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( opp_bits.low & 0x40000000ul ) {
          if ( opp_bits.high & 0x00000040ul ) {
            if ( opp_bits.high & 0x00004000ul ) {
              if ( opp_bits.high & 0x00400000ul ) {
                if ( my_bits.high & 0x40000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00400000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00004000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 72:
      /* Right */
      if ( (opp_bits.high + 0x00040000ul) & my_bits.high & 0x00f80000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.low & 0x00200000ul ) {
              if ( opp_bits.low & 0x00004000ul ) {
                if ( my_bits.low & 0x00000080ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00004000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00200000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( opp_bits.high & 0x00000002ul ) {
          if ( opp_bits.low & 0x02000000ul ) {
            if ( opp_bits.low & 0x00020000ul ) {
              if ( opp_bits.low & 0x00000200ul ) {
                if ( my_bits.low & 0x00000002ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000200ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00020000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 77:
      /* Left */
      if ( (((my_bits.high & 0x001f0000ul) << 1) + opp_bits.high) &
           0x00400000ul )
        goto FEASIBLE;
      /* Up */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( opp_bits.high & 0x00000040ul ) {
          if ( opp_bits.low & 0x40000000ul ) {
            if ( opp_bits.low & 0x00400000ul ) {
              if ( opp_bits.low & 0x00004000ul ) {
                if ( my_bits.low & 0x00000040ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00004000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00400000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.low & 0x00040000ul ) {
              if ( opp_bits.low & 0x00000200ul ) {
                if ( my_bits.low & 0x00000001ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000200ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00040000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 13:
      /* Right */
      if ( (opp_bits.low + 0x00000008ul) & my_bits.low & 0x000000f0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000001ul) << 1) + opp_bits.low) &
           0x00000004ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( my_bits.low & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x04000000ul ) {
            if ( opp_bits.high & 0x00000004ul ) {
              if ( opp_bits.high & 0x00000400ul ) {
                if ( opp_bits.high & 0x00040000ul ) {
                  if ( my_bits.high & 0x04000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00040000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000400ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000004ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x20000000ul ) {
            if ( opp_bits.high & 0x00000040ul ) {
              if ( my_bits.high & 0x00008000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000040ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 16:
      /* Right */
      if ( (opp_bits.low + 0x00000040ul) & my_bits.low & 0x00000080ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x0000000ful) << 1) + opp_bits.low) &
           0x00000020ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x04000000ul ) {
            if ( opp_bits.high & 0x00000002ul ) {
              if ( my_bits.high & 0x00000100ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000002ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x20000000ul ) {
            if ( opp_bits.high & 0x00000020ul ) {
              if ( opp_bits.high & 0x00002000ul ) {
                if ( opp_bits.high & 0x00200000ul ) {
                  if ( my_bits.high & 0x20000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00200000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00002000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000020ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( my_bits.low & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 31:
      /* Right */
      if ( (opp_bits.low + 0x00020000ul) & my_bits.low & 0x00fc0000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( my_bits.low & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x01000000ul ) {
        if ( opp_bits.high & 0x00000001ul ) {
          if ( opp_bits.high & 0x00000100ul ) {
            if ( opp_bits.high & 0x00010000ul ) {
              if ( my_bits.high & 0x01000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00010000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000100ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00000100ul ) {
        if ( my_bits.low & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.high & 0x00000800ul ) {
            if ( opp_bits.high & 0x00100000ul ) {
              if ( my_bits.high & 0x20000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00100000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 38:
      /* Left */
      if ( (((my_bits.low & 0x003f0000ul) << 1) + opp_bits.low) &
           0x00800000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.high & 0x00001000ul ) {
            if ( opp_bits.high & 0x00080000ul ) {
              if ( my_bits.high & 0x04000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00080000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x80000000ul ) {
        if ( opp_bits.high & 0x00000080ul ) {
          if ( opp_bits.high & 0x00008000ul ) {
            if ( opp_bits.high & 0x00800000ul ) {
              if ( my_bits.high & 0x80000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00800000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00008000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00008000ul ) {
        if ( my_bits.low & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( my_bits.low & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 61:
      /* Right */
      if ( (opp_bits.high + 0x00000200ul) & my_bits.high & 0x0000fc00ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.low & 0x00080000ul ) {
            if ( opp_bits.low & 0x00001000ul ) {
              if ( my_bits.low & 0x00000020ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00001000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00010000ul ) {
        if ( my_bits.high & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000001ul ) {
        if ( opp_bits.low & 0x01000000ul ) {
          if ( opp_bits.low & 0x00010000ul ) {
            if ( opp_bits.low & 0x00000100ul ) {
              if ( my_bits.low & 0x00000001ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000100ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00010000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( my_bits.high & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 68:
      /* Left */
      if ( (((my_bits.high & 0x00003f00ul) << 1) + opp_bits.high) &
           0x00008000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( my_bits.high & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00800000ul ) {
        if ( my_bits.high & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000080ul ) {
        if ( opp_bits.low & 0x80000000ul ) {
          if ( opp_bits.low & 0x00800000ul ) {
            if ( opp_bits.low & 0x00008000ul ) {
              if ( my_bits.low & 0x00000080ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00008000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00800000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.low & 0x00100000ul ) {
            if ( opp_bits.low & 0x00000800ul ) {
              if ( my_bits.low & 0x00000004ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000800ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 83:
      /* Right */
      if ( (opp_bits.high + 0x08000000ul) & my_bits.high & 0xf0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x01000000ul) << 1) + opp_bits.high) &
           0x04000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00000020ul ) {
            if ( opp_bits.low & 0x40000000ul ) {
              if ( my_bits.low & 0x00800000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x40000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00000004ul ) {
            if ( opp_bits.low & 0x04000000ul ) {
              if ( opp_bits.low & 0x00040000ul ) {
                if ( opp_bits.low & 0x00000400ul ) {
                  if ( my_bits.low & 0x00000004ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00000400ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00040000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x04000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( my_bits.high & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 86:
      /* Right */
      if ( (opp_bits.high + 0x40000000ul) & my_bits.high & 0x80000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x0f000000ul) << 1) + opp_bits.high) &
           0x20000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( my_bits.high & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00000020ul ) {
            if ( opp_bits.low & 0x20000000ul ) {
              if ( opp_bits.low & 0x00200000ul ) {
                if ( opp_bits.low & 0x00002000ul ) {
                  if ( my_bits.low & 0x00000020ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00002000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00200000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x20000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00000004ul ) {
            if ( opp_bits.low & 0x02000000ul ) {
              if ( my_bits.low & 0x00010000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x02000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 14:
      /* Right */
      if ( (opp_bits.low + 0x00000010ul) & my_bits.low & 0x000000e0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000003ul) << 1) + opp_bits.low) &
           0x00000008ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( opp_bits.low & 0x00020000ul ) {
          if ( my_bits.low & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.high & 0x00000008ul ) {
              if ( opp_bits.high & 0x00000800ul ) {
                if ( opp_bits.high & 0x00080000ul ) {
                  if ( my_bits.high & 0x08000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00080000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00000800ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000008ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x40000000ul ) {
            if ( my_bits.high & 0x00000080ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 15:
      /* Right */
      if ( (opp_bits.low + 0x00000020ul) & my_bits.low & 0x000000c0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000007ul) << 1) + opp_bits.low) &
           0x00000010ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x02000000ul ) {
            if ( my_bits.high & 0x00000001ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.high & 0x00000010ul ) {
              if ( opp_bits.high & 0x00001000ul ) {
                if ( opp_bits.high & 0x00100000ul ) {
                  if ( my_bits.high & 0x10000000ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.high & 0x00100000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00001000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000010ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( opp_bits.low & 0x00400000ul ) {
          if ( my_bits.low & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 41:
      /* Right */
      if ( (opp_bits.low + 0x02000000ul) & my_bits.low & 0xfc000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( opp_bits.low & 0x00000400ul ) {
          if ( my_bits.low & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000001ul ) {
        if ( opp_bits.high & 0x00000100ul ) {
          if ( opp_bits.high & 0x00010000ul ) {
            if ( my_bits.high & 0x01000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00010000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00010000ul ) {
        if ( opp_bits.low & 0x00000100ul ) {
          if ( my_bits.low & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00080000ul ) {
            if ( my_bits.high & 0x10000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 48:
      /* Left */
      if ( (((my_bits.low & 0x3f000000ul) << 1) + opp_bits.low) &
           0x80000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00100000ul ) {
            if ( my_bits.high & 0x08000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000080ul ) {
        if ( opp_bits.high & 0x00008000ul ) {
          if ( opp_bits.high & 0x00800000ul ) {
            if ( my_bits.high & 0x80000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00800000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00800000ul ) {
        if ( opp_bits.low & 0x00008000ul ) {
          if ( my_bits.low & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( opp_bits.low & 0x00002000ul ) {
          if ( my_bits.low & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 51:
      /* Right */
      if ( (opp_bits.high + 0x00000002ul) & my_bits.high & 0x000000fcul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x00000800ul ) {
            if ( my_bits.low & 0x00000010ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000100ul ) {
        if ( opp_bits.high & 0x00010000ul ) {
          if ( my_bits.high & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x01000000ul ) {
        if ( opp_bits.low & 0x00010000ul ) {
          if ( opp_bits.low & 0x00000100ul ) {
            if ( my_bits.low & 0x00000001ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000100ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( opp_bits.high & 0x00040000ul ) {
          if ( my_bits.high & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 58:
      /* Left */
      if ( (((my_bits.high & 0x0000003ful) << 1) + opp_bits.high) &
           0x00000080ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( opp_bits.high & 0x00200000ul ) {
          if ( my_bits.high & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00008000ul ) {
        if ( opp_bits.high & 0x00800000ul ) {
          if ( my_bits.high & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x80000000ul ) {
        if ( opp_bits.low & 0x00800000ul ) {
          if ( opp_bits.low & 0x00008000ul ) {
            if ( my_bits.low & 0x00000080ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00008000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x00001000ul ) {
            if ( my_bits.low & 0x00000008ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 84:
      /* Right */
      if ( (opp_bits.high + 0x10000000ul) & my_bits.high & 0xe0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x03000000ul) << 1) + opp_bits.high) &
           0x08000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00000040ul ) {
            if ( my_bits.low & 0x80000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.low & 0x08000000ul ) {
              if ( opp_bits.low & 0x00080000ul ) {
                if ( opp_bits.low & 0x00000800ul ) {
                  if ( my_bits.low & 0x00000008ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00000800ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00080000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x08000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( opp_bits.high & 0x00000200ul ) {
          if ( my_bits.high & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 85:
      /* Right */
      if ( (opp_bits.high + 0x20000000ul) & my_bits.high & 0xc0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x07000000ul) << 1) + opp_bits.high) &
           0x10000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( opp_bits.high & 0x00004000ul ) {
          if ( my_bits.high & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.low & 0x10000000ul ) {
              if ( opp_bits.low & 0x00100000ul ) {
                if ( opp_bits.low & 0x00001000ul ) {
                  if ( my_bits.low & 0x00000010ul ) {
                    goto FEASIBLE;
                  }
                }
                else if ( my_bits.low & 0x00001000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00100000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x10000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00000002ul ) {
            if ( my_bits.low & 0x01000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 23:
      /* Right */
      if ( (opp_bits.low + 0x00000800ul) & my_bits.low & 0x0000f000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000100ul) << 1) + opp_bits.low) &
           0x00000400ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( my_bits.low & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.high & 0x00000004ul ) {
            if ( opp_bits.high & 0x00000400ul ) {
              if ( opp_bits.high & 0x00040000ul ) {
                if ( my_bits.high & 0x04000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00040000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000400ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.high & 0x00000020ul ) {
            if ( opp_bits.high & 0x00004000ul ) {
              if ( my_bits.high & 0x00800000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00004000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 26:
      /* Right */
      if ( (opp_bits.low + 0x00004000ul) & my_bits.low & 0x00008000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000f00ul) << 1) + opp_bits.low) &
           0x00002000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.high & 0x00000004ul ) {
            if ( opp_bits.high & 0x00000200ul ) {
              if ( my_bits.high & 0x00010000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000200ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.high & 0x00000020ul ) {
            if ( opp_bits.high & 0x00002000ul ) {
              if ( opp_bits.high & 0x00200000ul ) {
                if ( my_bits.high & 0x20000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00200000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00002000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( my_bits.low & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 32:
      /* Right */
      if ( (opp_bits.low + 0x00040000ul) & my_bits.low & 0x00f80000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( my_bits.low & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( opp_bits.high & 0x00000002ul ) {
          if ( opp_bits.high & 0x00000200ul ) {
            if ( opp_bits.high & 0x00020000ul ) {
              if ( my_bits.high & 0x02000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00020000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000200ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( my_bits.low & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.high & 0x00001000ul ) {
            if ( opp_bits.high & 0x00200000ul ) {
              if ( my_bits.high & 0x40000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00200000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 37:
      /* Left */
      if ( (((my_bits.low & 0x001f0000ul) << 1) + opp_bits.low) &
           0x00400000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.high & 0x00000800ul ) {
            if ( opp_bits.high & 0x00040000ul ) {
              if ( my_bits.high & 0x02000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00040000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( opp_bits.high & 0x00000040ul ) {
          if ( opp_bits.high & 0x00004000ul ) {
            if ( opp_bits.high & 0x00400000ul ) {
              if ( my_bits.high & 0x40000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00400000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00004000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( my_bits.low & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( my_bits.low & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 62:
      /* Right */
      if ( (opp_bits.high + 0x00000400ul) & my_bits.high & 0x0000f800ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.low & 0x00100000ul ) {
            if ( opp_bits.low & 0x00002000ul ) {
              if ( my_bits.low & 0x00000040ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00002000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( my_bits.high & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( opp_bits.low & 0x02000000ul ) {
          if ( opp_bits.low & 0x00020000ul ) {
            if ( opp_bits.low & 0x00000200ul ) {
              if ( my_bits.low & 0x00000002ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000200ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00020000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( my_bits.high & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 67:
      /* Left */
      if ( (((my_bits.high & 0x00001f00ul) << 1) + opp_bits.high) &
           0x00004000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( my_bits.high & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( my_bits.high & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( opp_bits.low & 0x40000000ul ) {
          if ( opp_bits.low & 0x00400000ul ) {
            if ( opp_bits.low & 0x00004000ul ) {
              if ( my_bits.low & 0x00000040ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00004000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00400000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.low & 0x00080000ul ) {
            if ( opp_bits.low & 0x00000400ul ) {
              if ( my_bits.low & 0x00000002ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000400ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 73:
      /* Right */
      if ( (opp_bits.high + 0x00080000ul) & my_bits.high & 0x00f00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00010000ul) << 1) + opp_bits.high) &
           0x00040000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.low & 0x20000000ul ) {
            if ( opp_bits.low & 0x00400000ul ) {
              if ( my_bits.low & 0x00008000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00400000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.low & 0x04000000ul ) {
            if ( opp_bits.low & 0x00040000ul ) {
              if ( opp_bits.low & 0x00000400ul ) {
                if ( my_bits.low & 0x00000004ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000400ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00040000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( my_bits.high & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 76:
      /* Right */
      if ( (opp_bits.high + 0x00400000ul) & my_bits.high & 0x00800000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x000f0000ul) << 1) + opp_bits.high) &
           0x00200000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( my_bits.high & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.low & 0x20000000ul ) {
            if ( opp_bits.low & 0x00200000ul ) {
              if ( opp_bits.low & 0x00002000ul ) {
                if ( my_bits.low & 0x00000020ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00002000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00200000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.low & 0x04000000ul ) {
            if ( opp_bits.low & 0x00020000ul ) {
              if ( my_bits.low & 0x00000100ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00020000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 24:
      /* Right */
      if ( (opp_bits.low + 0x00001000ul) & my_bits.low & 0x0000e000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000300ul) << 1) + opp_bits.low) &
           0x00000800ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x02000000ul ) {
          if ( my_bits.high & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.high & 0x00000008ul ) {
            if ( opp_bits.high & 0x00000800ul ) {
              if ( opp_bits.high & 0x00080000ul ) {
                if ( my_bits.high & 0x08000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00080000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00000800ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.high & 0x00000040ul ) {
            if ( my_bits.high & 0x00008000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 25:
      /* Right */
      if ( (opp_bits.low + 0x00002000ul) & my_bits.low & 0x0000c000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00000700ul) << 1) + opp_bits.low) &
           0x00001000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.high & 0x00000002ul ) {
            if ( my_bits.high & 0x00000100ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.high & 0x00000010ul ) {
            if ( opp_bits.high & 0x00001000ul ) {
              if ( opp_bits.high & 0x00100000ul ) {
                if ( my_bits.high & 0x10000000ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.high & 0x00100000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00001000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x40000000ul ) {
          if ( my_bits.high & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 42:
      /* Right */
      if ( (opp_bits.low + 0x04000000ul) & my_bits.low & 0xf8000000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x00000800ul ) {
          if ( my_bits.low & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( opp_bits.high & 0x00000200ul ) {
          if ( opp_bits.high & 0x00020000ul ) {
            if ( my_bits.high & 0x02000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00020000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( opp_bits.low & 0x00000200ul ) {
          if ( my_bits.low & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00100000ul ) {
            if ( my_bits.high & 0x20000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 47:
      /* Left */
      if ( (((my_bits.low & 0x1f000000ul) << 1) + opp_bits.low) &
           0x40000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00080000ul ) {
            if ( my_bits.high & 0x04000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( opp_bits.high & 0x00004000ul ) {
          if ( opp_bits.high & 0x00400000ul ) {
            if ( my_bits.high & 0x40000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00400000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( opp_bits.low & 0x00004000ul ) {
          if ( my_bits.low & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x00001000ul ) {
          if ( my_bits.low & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 52:
      /* Right */
      if ( (opp_bits.high + 0x00000004ul) & my_bits.high & 0x000000f8ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x00001000ul ) {
            if ( my_bits.low & 0x00000020ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( opp_bits.high & 0x00020000ul ) {
          if ( my_bits.high & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( opp_bits.low & 0x00020000ul ) {
          if ( opp_bits.low & 0x00000200ul ) {
            if ( my_bits.low & 0x00000002ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000200ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00080000ul ) {
          if ( my_bits.high & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 57:
      /* Left */
      if ( (((my_bits.high & 0x0000001ful) << 1) + opp_bits.high) &
           0x00000040ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00100000ul ) {
          if ( my_bits.high & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( opp_bits.high & 0x00400000ul ) {
          if ( my_bits.high & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( opp_bits.low & 0x00400000ul ) {
          if ( opp_bits.low & 0x00004000ul ) {
            if ( my_bits.low & 0x00000040ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00004000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x00000800ul ) {
            if ( my_bits.low & 0x00000004ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 74:
      /* Right */
      if ( (opp_bits.high + 0x00100000ul) & my_bits.high & 0x00e00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00030000ul) << 1) + opp_bits.high) &
           0x00080000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.low & 0x40000000ul ) {
            if ( my_bits.low & 0x00800000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.low & 0x08000000ul ) {
            if ( opp_bits.low & 0x00080000ul ) {
              if ( opp_bits.low & 0x00000800ul ) {
                if ( my_bits.low & 0x00000008ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00000800ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00080000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00000002ul ) {
          if ( my_bits.low & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 75:
      /* Right */
      if ( (opp_bits.high + 0x00200000ul) & my_bits.high & 0x00c00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00070000ul) << 1) + opp_bits.high) &
           0x00100000ul )
        goto FEASIBLE;
      /* Up right */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00000040ul ) {
          if ( my_bits.low & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.low & 0x10000000ul ) {
            if ( opp_bits.low & 0x00100000ul ) {
              if ( opp_bits.low & 0x00001000ul ) {
                if ( my_bits.low & 0x00000010ul ) {
                  goto FEASIBLE;
                }
              }
              else if ( my_bits.low & 0x00001000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00100000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.low & 0x02000000ul ) {
            if ( my_bits.low & 0x00010000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 33:
      /* Right */
      if ( (opp_bits.low + 0x00080000ul) & my_bits.low & 0x00f00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00010000ul) << 1) + opp_bits.low) &
           0x00040000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( my_bits.high & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( my_bits.low & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.high & 0x00000400ul ) {
            if ( opp_bits.high & 0x00040000ul ) {
              if ( my_bits.high & 0x04000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00040000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000400ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( my_bits.low & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.high & 0x00002000ul ) {
            if ( opp_bits.high & 0x00400000ul ) {
              if ( my_bits.high & 0x80000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00400000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00002000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00000200ul ) {
        if ( my_bits.low & 0x00000001ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 36:
      /* Right */
      if ( (opp_bits.low + 0x00400000ul) & my_bits.low & 0x00800000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x000f0000ul) << 1) + opp_bits.low) &
           0x00200000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.high & 0x00000400ul ) {
            if ( opp_bits.high & 0x00020000ul ) {
              if ( my_bits.high & 0x01000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00020000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000400ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00004000ul ) {
        if ( my_bits.low & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.high & 0x00002000ul ) {
            if ( opp_bits.high & 0x00200000ul ) {
              if ( my_bits.high & 0x20000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00200000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00002000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( my_bits.low & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( my_bits.high & 0x00000080ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( my_bits.low & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 63:
      /* Right */
      if ( (opp_bits.high + 0x00000800ul) & my_bits.high & 0x0000f000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000100ul) << 1) + opp_bits.high) &
           0x00000400ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00020000ul ) {
        if ( my_bits.high & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.low & 0x00200000ul ) {
            if ( opp_bits.low & 0x00004000ul ) {
              if ( my_bits.low & 0x00000080ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00004000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00200000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( my_bits.high & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.low & 0x00040000ul ) {
            if ( opp_bits.low & 0x00000400ul ) {
              if ( my_bits.low & 0x00000004ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000400ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00040000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( my_bits.high & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( my_bits.low & 0x01000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 66:
      /* Right */
      if ( (opp_bits.high + 0x00004000ul) & my_bits.high & 0x00008000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000f00ul) << 1) + opp_bits.high) &
           0x00002000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( my_bits.high & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( my_bits.low & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( my_bits.high & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.low & 0x00200000ul ) {
            if ( opp_bits.low & 0x00002000ul ) {
              if ( my_bits.low & 0x00000020ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00002000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00200000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00400000ul ) {
        if ( my_bits.high & 0x80000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.low & 0x00040000ul ) {
            if ( opp_bits.low & 0x00000200ul ) {
              if ( my_bits.low & 0x00000001ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000200ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00040000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 34:
      /* Right */
      if ( (opp_bits.low + 0x00100000ul) & my_bits.low & 0x00e00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00030000ul) << 1) + opp_bits.low) &
           0x00080000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.high & 0x00000002ul ) {
          if ( my_bits.high & 0x00000100ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( my_bits.low & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.high & 0x00000008ul ) {
          if ( opp_bits.high & 0x00000800ul ) {
            if ( opp_bits.high & 0x00080000ul ) {
              if ( my_bits.high & 0x08000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00080000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( my_bits.low & 0x00000008ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.high & 0x00000020ul ) {
          if ( opp_bits.high & 0x00004000ul ) {
            if ( my_bits.high & 0x00800000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00004000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000020ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00000400ul ) {
        if ( my_bits.low & 0x00000002ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 35:
      /* Right */
      if ( (opp_bits.low + 0x00200000ul) & my_bits.low & 0x00c00000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x00070000ul) << 1) + opp_bits.low) &
           0x00100000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.high & 0x00000004ul ) {
          if ( opp_bits.high & 0x00000200ul ) {
            if ( my_bits.high & 0x00010000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00000200ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00002000ul ) {
        if ( my_bits.low & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.high & 0x00000010ul ) {
          if ( opp_bits.high & 0x00001000ul ) {
            if ( opp_bits.high & 0x00100000ul ) {
              if ( my_bits.high & 0x10000000ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.high & 0x00100000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00001000ul ) {
        if ( my_bits.low & 0x00000010ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.high & 0x00000040ul ) {
          if ( my_bits.high & 0x00008000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000040ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00000800ul ) {
        if ( my_bits.low & 0x00000004ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 43:
      /* Right */
      if ( (opp_bits.low + 0x08000000ul) & my_bits.low & 0xf0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x01000000ul) << 1) + opp_bits.low) &
           0x04000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000002ul ) {
        if ( my_bits.high & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x00001000ul ) {
          if ( my_bits.low & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00040000ul ) {
            if ( my_bits.high & 0x04000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00040000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x00000400ul ) {
          if ( my_bits.low & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00200000ul ) {
            if ( my_bits.high & 0x40000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00200000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00020000ul ) {
        if ( my_bits.low & 0x00000100ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 46:
      /* Right */
      if ( (opp_bits.low + 0x40000000ul) & my_bits.low & 0x80000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x0f000000ul) << 1) + opp_bits.low) &
           0x20000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00040000ul ) {
            if ( my_bits.high & 0x02000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00040000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00400000ul ) {
        if ( my_bits.low & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00200000ul ) {
            if ( my_bits.high & 0x20000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00200000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x00002000ul ) {
          if ( my_bits.low & 0x00000020ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000040ul ) {
        if ( my_bits.high & 0x00008000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x00000800ul ) {
          if ( my_bits.low & 0x00000004ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 53:
      /* Right */
      if ( (opp_bits.high + 0x00000008ul) & my_bits.high & 0x000000f0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000001ul) << 1) + opp_bits.high) &
           0x00000004ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000200ul ) {
        if ( my_bits.high & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x00002000ul ) {
            if ( my_bits.low & 0x00000040ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00002000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00040000ul ) {
          if ( my_bits.high & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x00000400ul ) {
            if ( my_bits.low & 0x00000004ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000400ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00100000ul ) {
          if ( my_bits.high & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x02000000ul ) {
        if ( my_bits.low & 0x00010000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 56:
      /* Right */
      if ( (opp_bits.high + 0x00000040ul) & my_bits.high & 0x00000080ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x0000000ful) << 1) + opp_bits.high) &
           0x00000020ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00080000ul ) {
          if ( my_bits.high & 0x04000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x40000000ul ) {
        if ( my_bits.low & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00200000ul ) {
          if ( my_bits.high & 0x20000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x00002000ul ) {
            if ( my_bits.low & 0x00000020ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00002000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00004000ul ) {
        if ( my_bits.high & 0x00800000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x00000400ul ) {
            if ( my_bits.low & 0x00000002ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000400ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 64:
      /* Right */
      if ( (opp_bits.high + 0x00001000ul) & my_bits.high & 0x0000e000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000300ul) << 1) + opp_bits.high) &
           0x00000800ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00040000ul ) {
        if ( my_bits.high & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.low & 0x20000000ul ) {
          if ( opp_bits.low & 0x00400000ul ) {
            if ( my_bits.low & 0x00008000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00400000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( my_bits.high & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.low & 0x08000000ul ) {
          if ( opp_bits.low & 0x00080000ul ) {
            if ( opp_bits.low & 0x00000800ul ) {
              if ( my_bits.low & 0x00000008ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00000800ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x08000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( my_bits.high & 0x20000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.low & 0x02000000ul ) {
          if ( my_bits.low & 0x00010000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x02000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 65:
      /* Right */
      if ( (opp_bits.high + 0x00002000ul) & my_bits.high & 0x0000c000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000700ul) << 1) + opp_bits.high) &
           0x00001000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00080000ul ) {
        if ( my_bits.high & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.low & 0x40000000ul ) {
          if ( my_bits.low & 0x00800000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00100000ul ) {
        if ( my_bits.high & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.low & 0x10000000ul ) {
          if ( opp_bits.low & 0x00100000ul ) {
            if ( opp_bits.low & 0x00001000ul ) {
              if ( my_bits.low & 0x00000010ul ) {
                goto FEASIBLE;
              }
            }
            else if ( my_bits.low & 0x00001000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x10000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00200000ul ) {
        if ( my_bits.high & 0x40000000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.low & 0x04000000ul ) {
          if ( opp_bits.low & 0x00020000ul ) {
            if ( my_bits.low & 0x00000100ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00020000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x04000000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 44:
      /* Right */
      if ( (opp_bits.low + 0x10000000ul) & my_bits.low & 0xe0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x03000000ul) << 1) + opp_bits.low) &
           0x08000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000004ul ) {
        if ( opp_bits.high & 0x00000200ul ) {
          if ( my_bits.high & 0x00010000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x00002000ul ) {
          if ( my_bits.low & 0x00000040ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.high & 0x00000800ul ) {
          if ( opp_bits.high & 0x00080000ul ) {
            if ( my_bits.high & 0x08000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00080000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x00000800ul ) {
          if ( my_bits.low & 0x00000008ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000800ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.high & 0x00002000ul ) {
          if ( opp_bits.high & 0x00400000ul ) {
            if ( my_bits.high & 0x80000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00400000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00002000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00040000ul ) {
        if ( opp_bits.low & 0x00000200ul ) {
          if ( my_bits.low & 0x00000001ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000200ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 45:
      /* Right */
      if ( (opp_bits.low + 0x20000000ul) & my_bits.low & 0xc0000000ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.low & 0x07000000ul) << 1) + opp_bits.low) &
           0x10000000ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000008ul ) {
        if ( opp_bits.high & 0x00000400ul ) {
          if ( opp_bits.high & 0x00020000ul ) {
            if ( my_bits.high & 0x01000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00020000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x00200000ul ) {
        if ( opp_bits.low & 0x00004000ul ) {
          if ( my_bits.low & 0x00000080ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000010ul ) {
        if ( opp_bits.high & 0x00001000ul ) {
          if ( opp_bits.high & 0x00100000ul ) {
            if ( my_bits.high & 0x10000000ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.high & 0x00100000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x00100000ul ) {
        if ( opp_bits.low & 0x00001000ul ) {
          if ( my_bits.low & 0x00000010ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00001000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00000020ul ) {
        if ( opp_bits.high & 0x00004000ul ) {
          if ( my_bits.high & 0x00800000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00004000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x00080000ul ) {
        if ( opp_bits.low & 0x00000400ul ) {
          if ( my_bits.low & 0x00000002ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00000400ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 54:
      /* Right */
      if ( (opp_bits.high + 0x00000010ul) & my_bits.high & 0x000000e0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000003ul) << 1) + opp_bits.high) &
           0x00000008ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000400ul ) {
        if ( opp_bits.high & 0x00020000ul ) {
          if ( my_bits.high & 0x01000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.low & 0x00200000ul ) {
          if ( opp_bits.low & 0x00004000ul ) {
            if ( my_bits.low & 0x00000080ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00004000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00080000ul ) {
          if ( my_bits.high & 0x08000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.low & 0x00080000ul ) {
          if ( opp_bits.low & 0x00000800ul ) {
            if ( my_bits.low & 0x00000008ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000800ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00080000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00200000ul ) {
          if ( my_bits.high & 0x40000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00200000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x04000000ul ) {
        if ( opp_bits.low & 0x00020000ul ) {
          if ( my_bits.low & 0x00000100ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00020000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    case 55:
      /* Right */
      if ( (opp_bits.high + 0x00000020ul) & my_bits.high & 0x000000c0ul )
        goto FEASIBLE;
      /* Left */
      if ( (((my_bits.high & 0x00000007ul) << 1) + opp_bits.high) &
           0x00000010ul )
        goto FEASIBLE;
      /* Down left */
      if ( opp_bits.high & 0x00000800ul ) {
        if ( opp_bits.high & 0x00040000ul ) {
          if ( my_bits.high & 0x02000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up right */
      if ( opp_bits.low & 0x20000000ul ) {
        if ( opp_bits.low & 0x00400000ul ) {
          if ( my_bits.low & 0x00008000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down */
      if ( opp_bits.high & 0x00001000ul ) {
        if ( opp_bits.high & 0x00100000ul ) {
          if ( my_bits.high & 0x10000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up */
      if ( opp_bits.low & 0x10000000ul ) {
        if ( opp_bits.low & 0x00100000ul ) {
          if ( opp_bits.low & 0x00001000ul ) {
            if ( my_bits.low & 0x00000010ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00001000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00100000ul ) {
          goto FEASIBLE;
        }
      }
      /* Down right */
      if ( opp_bits.high & 0x00002000ul ) {
        if ( opp_bits.high & 0x00400000ul ) {
          if ( my_bits.high & 0x80000000ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.high & 0x00400000ul ) {
          goto FEASIBLE;
        }
      }
      /* Up left */
      if ( opp_bits.low & 0x08000000ul ) {
        if ( opp_bits.low & 0x00040000ul ) {
          if ( opp_bits.low & 0x00000200ul ) {
            if ( my_bits.low & 0x00000001ul ) {
              goto FEASIBLE;
            }
          }
          else if ( my_bits.low & 0x00000200ul ) {
            goto FEASIBLE;
          }
        }
        else if ( my_bits.low & 0x00040000ul ) {
          goto FEASIBLE;
        }
      }
      continue;
    default:
      continue;
    }
 FEASIBLE:

    moves.high |= mask_high[sq];
    moves.low  |= mask_low[sq];
  }

  return moves;
}



int
bitboard_mobility( const BitBoard my_bits,
		   const BitBoard opp_bits ) {
  BitBoard moves = generate_all_loop( my_bits, opp_bits );
  return pop_count_loop( moves );

}



int
weighted_mobility( const BitBoard my_bits,
		   const BitBoard opp_bits ) {

  BitBoard moves = generate_all_loop( my_bits, opp_bits );
  int weighted_mobility = 128 * pop_count_loop( moves );
  const int corner_bonus = 128;

  if ( moves.low & 0x00000001ul )
    weighted_mobility += corner_bonus;
  if ( moves.low & 0x00000080ul )
    weighted_mobility += corner_bonus;
  if ( moves.high & 0x01000000ul )
    weighted_mobility += corner_bonus;
  if ( moves.high & 0x80000000ul )
    weighted_mobility += corner_bonus;

  return weighted_mobility;

}
