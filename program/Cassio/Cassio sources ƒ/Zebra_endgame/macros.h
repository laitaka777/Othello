/*
   File:          macros.h

   Created:       May 31, 1998

   Modified:      July 31, 2002

   Author:        Gunnar Andersson (gunnar@radagast.se)

   Contents:      Some globally used macros.
*/



#ifndef MACROS_H
#define MACROS_H



#ifdef __cplusplus
extern "C" {
#endif



#define MAX(a,b)                (((a) > (b)) ? (a) : (b))

#define MIN(a,b)                (((a) < (b)) ? (a) : (b))

#define SQR(a)                  ((a) * (a))


/* Convert index to square, e.g. 27 -> g2 */
#define TO_SQUARE(index)        'a'+(index % 10)-1,'0'+(index / 10)


/* Define the inline directive when available */
#if defined( __GNUC__ )&& !defined( __cplusplus )
#define INLINE __inline__
#else
#define INLINE
#endif



#ifdef __cplusplus
}
#endif



#endif  /* MACROS_H */
