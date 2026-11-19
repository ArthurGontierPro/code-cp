/* mindist2.c -- low-weight codewords of a binary code of length n <= 128, by two information sets.
   Usage: mindist2 n k t FIXLO FIXHI PRINTW < rows
   rows: 2k lines "LO HI" (hex, the word's bits 0..63 and 64..127). The first k rows are a generator
   G that is the identity on an information set S, the next k rows a generator G' of the same code
   that is the identity on the complement of S (the caller, verify_p1.py, builds and checks both).
   Every codeword c = m G = m' G' with m = c restricted to S and m' = c off S, so a word of weight
   <= 2t+1 has <= t ones on one side and is found by enumerating all combinations of <= t rows of G
   and of G'. Prints
     minw W        the smallest weight among the enumerated words (exact whenever W <= 2t+1)
     minw_fixed V  the same among the words whose support contains every bit of FIX (FIXLO/FIXHI)
     word LO HI    each enumerated word of weight <= PRINTW (duplicates possible; -1 prints none)
   Compiled with -fopenmp the first row index is split between threads. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
typedef unsigned __int128 u128;
static int n, k, t, printw;
static u128 R[2][128], FIX;
static int popc(u128 x) { return __builtin_popcountll((uint64_t)x) + __builtin_popcountll((uint64_t)(x >> 64)); }
static void dfs(int g, int start, int depth, u128 w, int *mw, int *mf) {
  int c = popc(w);
  if (c < *mw) *mw = c;
  if ((w & FIX) == FIX && c < *mf) *mf = c;
  if (c <= printw) {
    #pragma omp critical(pr)
    printf("word %016llx %016llx\n", (unsigned long long)(uint64_t)(w >> 64), (unsigned long long)(uint64_t)w);
  }
  if (depth == t) return;
  for (int i = start; i < k; i++) dfs(g, i + 1, depth + 1, w ^ R[g][i], mw, mf);
}
int main(int argc, char **argv) {
  if (argc != 7) { fprintf(stderr, "usage: mindist2 n k t FIXLO FIXHI PRINTW < rows\n"); return 2; }
  n = atoi(argv[1]); k = atoi(argv[2]); t = atoi(argv[3]); printw = atoi(argv[6]);
  FIX = ((u128)strtoull(argv[5], 0, 16) << 64) | strtoull(argv[4], 0, 16);
  for (int g = 0; g < 2; g++)
    for (int i = 0; i < k; i++) {
      unsigned long long lo, hi;
      if (scanf("%llx %llx", &lo, &hi) != 2) { fprintf(stderr, "bad input\n"); return 2; }
      R[g][i] = ((u128)hi << 64) | lo;
    }
  int MW = 1 << 30, MF = 1 << 30;
  for (int g = 0; g < 2; g++) {
    #pragma omp parallel for schedule(dynamic, 1) reduction(min : MW, MF)
    for (int i = 0; i < k; i++) {
      int mw = 1 << 30, mf = 1 << 30;
      dfs(g, i + 1, 1, R[g][i], &mw, &mf);
      if (mw < MW) MW = mw;
      if (mf < MF) MF = mf;
    }
  }
  printf("minw %d\nminw_fixed %d\n", MW, MF);
  return 0;
}
