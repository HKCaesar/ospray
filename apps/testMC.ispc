#include "ospray/math/vec.ih"

#define BLOCK_SIZE 64

/* for each triangle, we store 3x(2x3) bits: 3edges times two vertices per edge times 3 bits to ende the 8 possible index values per edge */
//uniform int32 triangleEdgeBitsByCellCase[256][5];

const uniform int edgeIDbyCellCase[256][16] = {
{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 0 0 */
{ 0, 3, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 1 1 */
{ 0, 9, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 2 1 */
{ 1, 3, 8, 9, 1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 3 2 */
{ 1, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 4 1 */
{ 0, 3, 8, 1, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 5 3 */
{ 9, 11, 2, 0, 9, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 6 2 */
{ 2, 3, 8, 2, 8, 11, 11, 8, 9, -1, -1, -1, -1, -1, -1, -1}, /* 7 5 */
{ 3, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 8 1 */
{ 0, 2, 10, 8, 0, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 9 2 */
{ 1, 0, 9, 2, 10, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 10 3 */
{ 1, 2, 10, 1, 10, 9, 9, 10, 8, -1, -1, -1, -1, -1, -1, -1}, /* 11 5 */
{ 3, 1, 11, 10, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 12 2 */
{ 0, 1, 11, 0, 11, 8, 8, 11, 10, -1, -1, -1, -1, -1, -1, -1}, /* 13 5 */
{ 3, 0, 9, 3, 9, 10, 10, 9, 11, -1, -1, -1, -1, -1, -1, -1}, /* 14 5 */
{ 9, 11, 8, 11, 10, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 15 8 */
{ 4, 8, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 16 1 */
{ 4, 0, 3, 7, 4, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 17 2 */
{ 0, 9, 1, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 18 3 */
{ 4, 9, 1, 4, 1, 7, 7, 1, 3, -1, -1, -1, -1, -1, -1, -1}, /* 19 5 */
{ 1, 11, 2, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 20 4 */
{ 3, 7, 4, 3, 4, 0, 1, 11, 2, -1, -1, -1, -1, -1, -1, -1}, /* 21 7 */
{ 9, 11, 2, 9, 2, 0, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1}, /* 22 7 */
{ 2, 9, 11, 2, 7, 9, 2, 3, 7, 7, 4, 9, -1, -1, -1, -1}, /* 23 14 */
{ 8, 7, 4, 3, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 24 3 */
{10, 7, 4, 10, 4, 2, 2, 4, 0, -1, -1, -1, -1, -1, -1, -1}, /* 25 5 */
{ 9, 1, 0, 8, 7, 4, 2, 10, 3, -1, -1, -1, -1, -1, -1, -1}, /* 26 6 */
{ 4, 10, 7, 9, 10, 4, 9, 2, 10, 9, 1, 2, -1, -1, -1, -1}, /* 27 9 */
{ 3, 1, 11, 3, 11, 10, 7, 4, 8, -1, -1, -1, -1, -1, -1, -1}, /* 28 7 */
{ 1, 11, 10, 1, 10, 4, 1, 4, 0, 7, 4, 10, -1, -1, -1, -1}, /* 29 11 */
{ 4, 8, 7, 9, 10, 0, 9, 11, 10, 10, 3, 0, -1, -1, -1, -1}, /* 30 12 */
{ 4, 10, 7, 4, 9, 10, 9, 11, 10, -1, -1, -1, -1, -1, -1, -1}, /* 31 5 */
{ 9, 4, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 32 1 */
{ 9, 4, 5, 0, 3, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 33 3 */
{ 0, 4, 5, 1, 0, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 34 2 */
{ 8, 4, 5, 8, 5, 3, 3, 5, 1, -1, -1, -1, -1, -1, -1, -1}, /* 35 5 */
{ 1, 11, 2, 9, 4, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 36 3 */
{ 3, 8, 0, 1, 11, 2, 4, 5, 9, -1, -1, -1, -1, -1, -1, -1}, /* 37 6 */
{ 5, 11, 2, 5, 2, 4, 4, 2, 0, -1, -1, -1, -1, -1, -1, -1}, /* 38 5 */
{ 2, 5, 11, 3, 5, 2, 3, 4, 5, 3, 8, 4, -1, -1, -1, -1}, /* 39 9 */
{ 9, 4, 5, 2, 10, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 40 4 */
{ 0, 2, 10, 0, 10, 8, 4, 5, 9, -1, -1, -1, -1, -1, -1, -1}, /* 41 7 */
{ 0, 4, 5, 0, 5, 1, 2, 10, 3, -1, -1, -1, -1, -1, -1, -1}, /* 42 7 */
{ 2, 5, 1, 2, 8, 5, 2, 10, 8, 4, 5, 8, -1, -1, -1, -1}, /* 43 11 */
{11, 10, 3, 11, 3, 1, 9, 4, 5, -1, -1, -1, -1, -1, -1, -1}, /* 44 7 */
{ 4, 5, 9, 0, 1, 8, 8, 1, 11, 8, 11, 10, -1, -1, -1, -1}, /* 45 12 */
{ 5, 0, 4, 5, 10, 0, 5, 11, 10, 10, 3, 0, -1, -1, -1, -1}, /* 46 14 */
{ 5, 8, 4, 5, 11, 8, 11, 10, 8, -1, -1, -1, -1, -1, -1, -1}, /* 47 5 */
{ 9, 8, 7, 5, 9, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 48 2 */
{ 9, 0, 3, 9, 3, 5, 5, 3, 7, -1, -1, -1, -1, -1, -1, -1}, /* 49 5 */
{ 0, 8, 7, 0, 7, 1, 1, 7, 5, -1, -1, -1, -1, -1, -1, -1}, /* 50 5 */
{ 1, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 51 8 */
{ 9, 8, 7, 9, 7, 5, 11, 2, 1, -1, -1, -1, -1, -1, -1, -1}, /* 52 7 */
{11, 2, 1, 9, 0, 5, 5, 0, 3, 5, 3, 7, -1, -1, -1, -1}, /* 53 12 */
{ 8, 2, 0, 8, 5, 2, 8, 7, 5, 11, 2, 5, -1, -1, -1, -1}, /* 54 11 */
{ 2, 5, 11, 2, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1}, /* 55 5 */
{ 7, 5, 9, 7, 9, 8, 3, 2, 10, -1, -1, -1, -1, -1, -1, -1}, /* 56 7 */
{ 9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 10, 7, -1, -1, -1, -1}, /* 57 14 */
{ 2, 10, 3, 0, 8, 1, 1, 8, 7, 1, 7, 5, -1, -1, -1, -1}, /* 58 12 */
{10, 1, 2, 10, 7, 1, 7, 5, 1, -1, -1, -1, -1, -1, -1, -1}, /* 59 5 */
{ 9, 8, 5, 8, 7, 5, 11, 3, 1, 11, 10, 3, -1, -1, -1, -1}, /* 60 10 */
{ 5, 0, 7, 5, 9, 0, 7, 0, 10, 1, 11, 0, 10, 0, 11, -1}, /* 61 7 */
{10, 0, 11, 10, 3, 0, 11, 0, 5, 8, 7, 0, 5, 0, 7, -1}, /* 62 7 */
{10, 5, 11, 7, 5, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 63 2 */
{11, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 64 1 */
{ 0, 3, 8, 5, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 65 4 */
{ 9, 1, 0, 5, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 66 3 */
{ 1, 3, 8, 1, 8, 9, 5, 6, 11, -1, -1, -1, -1, -1, -1, -1}, /* 67 7 */
{ 1, 5, 6, 2, 1, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 68 2 */
{ 1, 5, 6, 1, 6, 2, 3, 8, 0, -1, -1, -1, -1, -1, -1, -1}, /* 69 7 */
{ 9, 5, 6, 9, 6, 0, 0, 6, 2, -1, -1, -1, -1, -1, -1, -1}, /* 70 5 */
{ 5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, -1, -1, -1, -1}, /* 71 11 */
{ 2, 10, 3, 11, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 72 3 */
{10, 8, 0, 10, 0, 2, 11, 5, 6, -1, -1, -1, -1, -1, -1, -1}, /* 73 7 */
{ 0, 9, 1, 2, 10, 3, 5, 6, 11, -1, -1, -1, -1, -1, -1, -1}, /* 74 6 */
{ 5, 6, 11, 1, 2, 9, 9, 2, 10, 9, 10, 8, -1, -1, -1, -1}, /* 75 12 */
{ 6, 10, 3, 6, 3, 5, 5, 3, 1, -1, -1, -1, -1, -1, -1, -1}, /* 76 5 */
{ 0, 10, 8, 0, 5, 10, 0, 1, 5, 5, 6, 10, -1, -1, -1, -1}, /* 77 14 */
{ 3, 6, 10, 0, 6, 3, 0, 5, 6, 0, 9, 5, -1, -1, -1, -1}, /* 78 9 */
{ 6, 9, 5, 6, 10, 9, 10, 8, 9, -1, -1, -1, -1, -1, -1, -1}, /* 79 5 */
{ 5, 6, 11, 4, 8, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 80 3 */
{ 4, 0, 3, 4, 3, 7, 6, 11, 5, -1, -1, -1, -1, -1, -1, -1}, /* 81 7 */
{ 1, 0, 9, 5, 6, 11, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1}, /* 82 6 */
{11, 5, 6, 1, 7, 9, 1, 3, 7, 7, 4, 9, -1, -1, -1, -1}, /* 83 12 */
{ 6, 2, 1, 6, 1, 5, 4, 8, 7, -1, -1, -1, -1, -1, -1, -1}, /* 84 7 */
{ 1, 5, 2, 5, 6, 2, 3, 4, 0, 3, 7, 4, -1, -1, -1, -1}, /* 85 10 */
{ 8, 7, 4, 9, 5, 0, 0, 5, 6, 0, 6, 2, -1, -1, -1, -1}, /* 86 12 */
{ 7, 9, 3, 7, 4, 9, 3, 9, 2, 5, 6, 9, 2, 9, 6, -1}, /* 87 7 */
{ 3, 2, 10, 7, 4, 8, 11, 5, 6, -1, -1, -1, -1, -1, -1, -1}, /* 88 6 */
{ 5, 6, 11, 4, 2, 7, 4, 0, 2, 2, 10, 7, -1, -1, -1, -1}, /* 89 12 */
{ 0, 9, 1, 4, 8, 7, 2, 10, 3, 5, 6, 11, -1, -1, -1, -1}, /* 90 13 */
{ 9, 1, 2, 9, 2, 10, 9, 10, 4, 7, 4, 10, 5, 6, 11, -1}, /* 91 6 */
{ 8, 7, 4, 3, 5, 10, 3, 1, 5, 5, 6, 10, -1, -1, -1, -1}, /* 92 12 */
{ 5, 10, 1, 5, 6, 10, 1, 10, 0, 7, 4, 10, 0, 10, 4, -1}, /* 93 7 */
{ 0, 9, 5, 0, 5, 6, 0, 6, 3, 10, 3, 6, 8, 7, 4, -1}, /* 94 6 */
{ 6, 9, 5, 6, 10, 9, 4, 9, 7, 7, 9, 10, -1, -1, -1, -1}, /* 95 3 */
{11, 9, 4, 6, 11, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 96 2 */
{ 4, 6, 11, 4, 11, 9, 0, 3, 8, -1, -1, -1, -1, -1, -1, -1}, /* 97 7 */
{11, 1, 0, 11, 0, 6, 6, 0, 4, -1, -1, -1, -1, -1, -1, -1}, /* 98 5 */
{ 8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 11, 1, -1, -1, -1, -1}, /* 99 14 */
{ 1, 9, 4, 1, 4, 2, 2, 4, 6, -1, -1, -1, -1, -1, -1, -1}, /* 100 5 */
{ 3, 8, 0, 1, 9, 2, 2, 9, 4, 2, 4, 6, -1, -1, -1, -1}, /* 101 12 */
{ 0, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 102 8 */
{ 8, 2, 3, 8, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1}, /* 103 5 */
{11, 9, 4, 11, 4, 6, 10, 3, 2, -1, -1, -1, -1, -1, -1, -1}, /* 104 7 */
{ 0, 2, 8, 2, 10, 8, 4, 11, 9, 4, 6, 11, -1, -1, -1, -1}, /* 105 10 */
{ 3, 2, 10, 0, 6, 1, 0, 4, 6, 6, 11, 1, -1, -1, -1, -1}, /* 106 12 */
{ 6, 1, 4, 6, 11, 1, 4, 1, 8, 2, 10, 1, 8, 1, 10, -1}, /* 107 7 */
{ 9, 4, 6, 9, 6, 3, 9, 3, 1, 10, 3, 6, -1, -1, -1, -1}, /* 108 11 */
{ 8, 1, 10, 8, 0, 1, 10, 1, 6, 9, 4, 1, 6, 1, 4, -1}, /* 109 7 */
{ 3, 6, 10, 3, 0, 6, 0, 4, 6, -1, -1, -1, -1, -1, -1, -1}, /* 110 5 */
{ 6, 8, 4, 10, 8, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 111 2 */
{ 7, 6, 11, 7, 11, 8, 8, 11, 9, -1, -1, -1, -1, -1, -1, -1}, /* 112 5 */
{ 0, 3, 7, 0, 7, 11, 0, 11, 9, 6, 11, 7, -1, -1, -1, -1}, /* 113 11 */
{11, 7, 6, 1, 7, 11, 1, 8, 7, 1, 0, 8, -1, -1, -1, -1}, /* 114 9 */
{11, 7, 6, 11, 1, 7, 1, 3, 7, -1, -1, -1, -1, -1, -1, -1}, /* 115 5 */
{ 1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, -1, -1, -1, -1}, /* 116 14 */
{ 2, 9, 6, 2, 1, 9, 6, 9, 7, 0, 3, 9, 7, 9, 3, -1}, /* 117 7 */
{ 7, 0, 8, 7, 6, 0, 6, 2, 0, -1, -1, -1, -1, -1, -1, -1}, /* 118 5 */
{ 7, 2, 3, 6, 2, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 119 2 */
{ 2, 10, 3, 11, 8, 6, 11, 9, 8, 8, 7, 6, -1, -1, -1, -1}, /* 120 12 */
{ 2, 7, 0, 2, 10, 7, 0, 7, 9, 6, 11, 7, 9, 7, 11, -1}, /* 121 7 */
{ 1, 0, 8, 1, 8, 7, 1, 7, 11, 6, 11, 7, 2, 10, 3, -1}, /* 122 6 */
{10, 1, 2, 10, 7, 1, 11, 1, 6, 6, 1, 7, -1, -1, -1, -1}, /* 123 3 */
{ 8, 6, 9, 8, 7, 6, 9, 6, 1, 10, 3, 6, 1, 6, 3, -1}, /* 124 7 */
{ 0, 1, 9, 10, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 125 4 */
{ 7, 0, 8, 7, 6, 0, 3, 0, 10, 10, 0, 6, -1, -1, -1, -1}, /* 126 3 */
{ 7, 6, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 127 1 */
{ 7, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 128 1 */
{ 3, 8, 0, 10, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 129 3 */
{ 0, 9, 1, 10, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 130 4 */
{ 8, 9, 1, 8, 1, 3, 10, 6, 7, -1, -1, -1, -1, -1, -1, -1}, /* 131 7 */
{11, 2, 1, 6, 7, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 132 3 */
{ 1, 11, 2, 3, 8, 0, 6, 7, 10, -1, -1, -1, -1, -1, -1, -1}, /* 133 6 */
{ 2, 0, 9, 2, 9, 11, 6, 7, 10, -1, -1, -1, -1, -1, -1, -1}, /* 134 7 */
{ 6, 7, 10, 2, 3, 11, 11, 3, 8, 11, 8, 9, -1, -1, -1, -1}, /* 135 12 */
{ 7, 3, 2, 6, 7, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 136 2 */
{ 7, 8, 0, 7, 0, 6, 6, 0, 2, -1, -1, -1, -1, -1, -1, -1}, /* 137 5 */
{ 2, 6, 7, 2, 7, 3, 0, 9, 1, -1, -1, -1, -1, -1, -1, -1}, /* 138 7 */
{ 1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, -1, -1, -1, -1}, /* 139 14 */
{11, 6, 7, 11, 7, 1, 1, 7, 3, -1, -1, -1, -1, -1, -1, -1}, /* 140 5 */
{11, 6, 7, 1, 11, 7, 1, 7, 8, 1, 8, 0, -1, -1, -1, -1}, /* 141 9 */
{ 0, 7, 3, 0, 11, 7, 0, 9, 11, 6, 7, 11, -1, -1, -1, -1}, /* 142 11 */
{ 7, 11, 6, 7, 8, 11, 8, 9, 11, -1, -1, -1, -1, -1, -1, -1}, /* 143 5 */
{ 6, 4, 8, 10, 6, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 144 2 */
{ 3, 10, 6, 3, 6, 0, 0, 6, 4, -1, -1, -1, -1, -1, -1, -1}, /* 145 5 */
{ 8, 10, 6, 8, 6, 4, 9, 1, 0, -1, -1, -1, -1, -1, -1, -1}, /* 146 7 */
{ 9, 6, 4, 9, 3, 6, 9, 1, 3, 10, 6, 3, -1, -1, -1, -1}, /* 147 11 */
{ 6, 4, 8, 6, 8, 10, 2, 1, 11, -1, -1, -1, -1, -1, -1, -1}, /* 148 7 */
{ 1, 11, 2, 3, 10, 0, 0, 10, 6, 0, 6, 4, -1, -1, -1, -1}, /* 149 12 */
{ 4, 8, 10, 4, 10, 6, 0, 9, 2, 2, 9, 11, -1, -1, -1, -1}, /* 150 10 */
{11, 3, 9, 11, 2, 3, 9, 3, 4, 10, 6, 3, 4, 3, 6, -1}, /* 151 7 */
{ 8, 3, 2, 8, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1}, /* 152 5 */
{ 0, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 153 8 */
{ 1, 0, 9, 2, 4, 3, 2, 6, 4, 4, 8, 3, -1, -1, -1, -1}, /* 154 12 */
{ 1, 4, 9, 1, 2, 4, 2, 6, 4, -1, -1, -1, -1, -1, -1, -1}, /* 155 5 */
{ 8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 11, -1, -1, -1, -1}, /* 156 14 */
{11, 0, 1, 11, 6, 0, 6, 4, 0, -1, -1, -1, -1, -1, -1, -1}, /* 157 5 */
{ 4, 3, 6, 4, 8, 3, 6, 3, 11, 0, 9, 3, 11, 3, 9, -1}, /* 158 7 */
{11, 4, 9, 6, 4, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 159 2 */
{ 4, 5, 9, 7, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 160 3 */
{ 0, 3, 8, 4, 5, 9, 10, 6, 7, -1, -1, -1, -1, -1, -1, -1}, /* 161 6 */
{ 5, 1, 0, 5, 0, 4, 7, 10, 6, -1, -1, -1, -1, -1, -1, -1}, /* 162 7 */
{10, 6, 7, 8, 4, 3, 3, 4, 5, 3, 5, 1, -1, -1, -1, -1}, /* 163 12 */
{ 9, 4, 5, 11, 2, 1, 7, 10, 6, -1, -1, -1, -1, -1, -1, -1}, /* 164 6 */
{ 6, 7, 10, 1, 11, 2, 0, 3, 8, 4, 5, 9, -1, -1, -1, -1}, /* 165 13 */
{ 7, 10, 6, 5, 11, 4, 4, 11, 2, 4, 2, 0, -1, -1, -1, -1}, /* 166 12 */
{ 3, 8, 4, 3, 4, 5, 3, 5, 2, 11, 2, 5, 10, 6, 7, -1}, /* 167 6 */
{ 7, 3, 2, 7, 2, 6, 5, 9, 4, -1, -1, -1, -1, -1, -1, -1}, /* 168 7 */
{ 9, 4, 5, 0, 6, 8, 0, 2, 6, 6, 7, 8, -1, -1, -1, -1}, /* 169 12 */
{ 3, 2, 6, 3, 6, 7, 1, 0, 5, 5, 0, 4, -1, -1, -1, -1}, /* 170 10 */
{ 6, 8, 2, 6, 7, 8, 2, 8, 1, 4, 5, 8, 1, 8, 5, -1}, /* 171 7 */
{ 9, 4, 5, 11, 6, 1, 1, 6, 7, 1, 7, 3, -1, -1, -1, -1}, /* 172 12 */
{ 1, 11, 6, 1, 6, 7, 1, 7, 0, 8, 0, 7, 9, 4, 5, -1}, /* 173 6 */
{ 4, 11, 0, 4, 5, 11, 0, 11, 3, 6, 7, 11, 3, 11, 7, -1}, /* 174 7 */
{ 7, 11, 6, 7, 8, 11, 5, 11, 4, 4, 11, 8, -1, -1, -1, -1}, /* 175 3 */
{ 6, 5, 9, 6, 9, 10, 10, 9, 8, -1, -1, -1, -1, -1, -1, -1}, /* 176 5 */
{ 3, 10, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, -1, -1, -1, -1}, /* 177 9 */
{ 0, 8, 10, 0, 10, 5, 0, 5, 1, 5, 10, 6, -1, -1, -1, -1}, /* 178 14 */
{ 6, 3, 10, 6, 5, 3, 5, 1, 3, -1, -1, -1, -1, -1, -1, -1}, /* 179 5 */
{ 1, 11, 2, 9, 10, 5, 9, 8, 10, 10, 6, 5, -1, -1, -1, -1}, /* 180 12 */
{ 0, 3, 10, 0, 10, 6, 0, 6, 9, 5, 9, 6, 1, 11, 2, -1}, /* 181 6 */
{10, 5, 8, 10, 6, 5, 8, 5, 0, 11, 2, 5, 0, 5, 2, -1}, /* 182 7 */
{ 6, 3, 10, 6, 5, 3, 2, 3, 11, 11, 3, 5, -1, -1, -1, -1}, /* 183 3 */
{ 5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, -1, -1, -1, -1}, /* 184 11 */
{ 9, 6, 5, 9, 0, 6, 0, 2, 6, -1, -1, -1, -1, -1, -1, -1}, /* 185 5 */
{ 1, 8, 5, 1, 0, 8, 5, 8, 6, 3, 2, 8, 6, 8, 2, -1}, /* 186 7 */
{ 1, 6, 5, 2, 6, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 187 2 */
{ 1, 6, 3, 1, 11, 6, 3, 6, 8, 5, 9, 6, 8, 6, 9, -1}, /* 188 7 */
{11, 0, 1, 11, 6, 0, 9, 0, 5, 5, 0, 6, -1, -1, -1, -1}, /* 189 3 */
{ 0, 8, 3, 5, 11, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 190 4 */
{11, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 191 1 */
{10, 11, 5, 7, 10, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 192 2 */
{10, 11, 5, 10, 5, 7, 8, 0, 3, -1, -1, -1, -1, -1, -1, -1}, /* 193 7 */
{ 5, 7, 10, 5, 10, 11, 1, 0, 9, -1, -1, -1, -1, -1, -1, -1}, /* 194 7 */
{11, 5, 7, 11, 7, 10, 9, 1, 8, 8, 1, 3, -1, -1, -1, -1}, /* 195 10 */
{10, 2, 1, 10, 1, 7, 7, 1, 5, -1, -1, -1, -1, -1, -1, -1}, /* 196 5 */
{ 0, 3, 8, 1, 7, 2, 1, 5, 7, 7, 10, 2, -1, -1, -1, -1}, /* 197 12 */
{ 9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 10, -1, -1, -1, -1}, /* 198 14 */
{ 7, 2, 5, 7, 10, 2, 5, 2, 9, 3, 8, 2, 9, 2, 8, -1}, /* 199 7 */
{ 2, 11, 5, 2, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1}, /* 200 5 */
{ 8, 0, 2, 8, 2, 5, 8, 5, 7, 11, 5, 2, -1, -1, -1, -1}, /* 201 11 */
{ 9, 1, 0, 5, 3, 11, 5, 7, 3, 3, 2, 11, -1, -1, -1, -1}, /* 202 12 */
{ 9, 2, 8, 9, 1, 2, 8, 2, 7, 11, 5, 2, 7, 2, 5, -1}, /* 203 7 */
{ 1, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 204 8 */
{ 0, 7, 8, 0, 1, 7, 1, 5, 7, -1, -1, -1, -1, -1, -1, -1}, /* 205 5 */
{ 9, 3, 0, 9, 5, 3, 5, 7, 3, -1, -1, -1, -1, -1, -1, -1}, /* 206 5 */
{ 9, 7, 8, 5, 7, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 207 2 */
{ 5, 4, 8, 5, 8, 11, 11, 8, 10, -1, -1, -1, -1, -1, -1, -1}, /* 208 5 */
{ 5, 4, 0, 5, 0, 10, 5, 10, 11, 10, 0, 3, -1, -1, -1, -1}, /* 209 14 */
{ 0, 9, 1, 8, 11, 4, 8, 10, 11, 11, 5, 4, -1, -1, -1, -1}, /* 210 12 */
{11, 4, 10, 11, 5, 4, 10, 4, 3, 9, 1, 4, 3, 4, 1, -1}, /* 211 7 */
{ 2, 1, 5, 2, 5, 8, 2, 8, 10, 4, 8, 5, -1, -1, -1, -1}, /* 212 11 */
{ 0, 10, 4, 0, 3, 10, 4, 10, 5, 2, 1, 10, 5, 10, 1, -1}, /* 213 7 */
{ 0, 5, 2, 0, 9, 5, 2, 5, 10, 4, 8, 5, 10, 5, 8, -1}, /* 214 7 */
{ 9, 5, 4, 2, 3, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 215 4 */
{ 2, 11, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, -1, -1, -1, -1}, /* 216 9 */
{ 5, 2, 11, 5, 4, 2, 4, 0, 2, -1, -1, -1, -1, -1, -1, -1}, /* 217 5 */
{ 3, 2, 11, 3, 11, 5, 3, 5, 8, 4, 8, 5, 0, 9, 1, -1}, /* 218 6 */
{ 5, 2, 11, 5, 4, 2, 1, 2, 9, 9, 2, 4, -1, -1, -1, -1}, /* 219 3 */
{ 8, 5, 4, 8, 3, 5, 3, 1, 5, -1, -1, -1, -1, -1, -1, -1}, /* 220 5 */
{ 0, 5, 4, 1, 5, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 221 2 */
{ 8, 5, 4, 8, 3, 5, 9, 5, 0, 0, 5, 3, -1, -1, -1, -1}, /* 222 3 */
{ 9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 223 1 */
{ 4, 7, 10, 4, 10, 9, 9, 10, 11, -1, -1, -1, -1, -1, -1, -1}, /* 224 5 */
{ 0, 3, 8, 4, 7, 9, 9, 7, 10, 9, 10, 11, -1, -1, -1, -1}, /* 225 12 */
{ 1, 10, 11, 1, 4, 10, 1, 0, 4, 7, 10, 4, -1, -1, -1, -1}, /* 226 11 */
{ 3, 4, 1, 3, 8, 4, 1, 4, 11, 7, 10, 4, 11, 4, 10, -1}, /* 227 7 */
{ 4, 7, 10, 9, 4, 10, 9, 10, 2, 9, 2, 1, -1, -1, -1, -1}, /* 228 9 */
{ 9, 4, 7, 9, 7, 10, 9, 10, 1, 2, 1, 10, 0, 3, 8, -1}, /* 229 6 */
{10, 4, 7, 10, 2, 4, 2, 0, 4, -1, -1, -1, -1, -1, -1, -1}, /* 230 5 */
{10, 4, 7, 10, 2, 4, 8, 4, 3, 3, 4, 2, -1, -1, -1, -1}, /* 231 3 */
{ 2, 11, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, -1, -1, -1, -1}, /* 232 14 */
{ 9, 7, 11, 9, 4, 7, 11, 7, 2, 8, 0, 7, 2, 7, 0, -1}, /* 233 7 */
{ 3, 11, 7, 3, 2, 11, 7, 11, 4, 1, 0, 11, 4, 11, 0, -1}, /* 234 7 */
{ 1, 2, 11, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 235 4 */
{ 4, 1, 9, 4, 7, 1, 7, 3, 1, -1, -1, -1, -1, -1, -1, -1}, /* 236 5 */
{ 4, 1, 9, 4, 7, 1, 0, 1, 8, 8, 1, 7, -1, -1, -1, -1}, /* 237 3 */
{ 4, 3, 0, 7, 3, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 238 2 */
{ 4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 239 1 */
{ 9, 8, 11, 11, 8, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 240 8 */
{ 3, 9, 0, 3, 10, 9, 10, 11, 9, -1, -1, -1, -1, -1, -1, -1}, /* 241 5 */
{ 0, 11, 1, 0, 8, 11, 8, 10, 11, -1, -1, -1, -1, -1, -1, -1}, /* 242 5 */
{ 3, 11, 1, 10, 11, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 243 2 */
{ 1, 10, 2, 1, 9, 10, 9, 8, 10, -1, -1, -1, -1, -1, -1, -1}, /* 244 5 */
{ 3, 9, 0, 3, 10, 9, 1, 9, 2, 2, 9, 10, -1, -1, -1, -1}, /* 245 3 */
{ 0, 10, 2, 8, 10, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 246 2 */
{ 3, 10, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 247 1 */
{ 2, 8, 3, 2, 11, 8, 11, 9, 8, -1, -1, -1, -1, -1, -1, -1}, /* 248 5 */
{ 9, 2, 11, 0, 2, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 249 2 */
{ 2, 8, 3, 2, 11, 8, 0, 8, 1, 1, 8, 11, -1, -1, -1, -1}, /* 250 3 */
{ 1, 2, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 251 1 */
{ 1, 8, 3, 9, 8, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 252 2 */
{ 0, 1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 253 1 */
{ 0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, /* 254 1 */
{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1} /* 255 0 */
};

const uniform int numberOfTrianglesByCellCase[256] = {
0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 2,
1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 3,
1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 3,
2, 3, 3, 2, 3, 4, 4, 3, 3, 4, 4, 3, 4, 5, 5, 2,
1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 3,
2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 4,
2, 3, 3, 4, 3, 4, 2, 3, 3, 4, 4, 5, 4, 5, 3, 2,
3, 4, 4, 3, 4, 5, 3, 2, 4, 5, 5, 4, 5, 2, 4, 1,
1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 3,
2, 3, 3, 4, 3, 4, 4, 5, 3, 2, 4, 3, 4, 3, 5, 2,
2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 4,
3, 4, 4, 3, 4, 5, 5, 4, 4, 3, 5, 2, 5, 4, 2, 1,
2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 2, 3, 3, 2,
3, 4, 4, 5, 4, 5, 5, 2, 4, 3, 5, 4, 3, 2, 4, 1,
3, 4, 4, 5, 4, 5, 3, 4, 4, 5, 5, 2, 3, 4, 2, 1,
2, 3, 3, 2, 3, 4, 2, 1, 3, 2, 4, 1, 2, 1, 1, 0
};

const uniform int edgeVerticesByEdgeID[12][2] = { {0,1}, {1,2}, {3,2}, 
                                                  {0,3}, {4,5}, {5,6},
                                                  {7,6}, {4,7}, {0,4},
                                                  {1,5}, {3,7}, {2,6} };


struct Field {
  vec3i size;
  vec3i blocks;
  float *voxel;
};

export void *uniform createField(uniform int sx, uniform int sy, uniform int sz, float *uniform voxel) {
  uniform Field *uniform field = uniform new uniform Field;
  field->size.x = sx;
  field->size.y = sy;
  field->size.z = sz;
  field->voxel = voxel;
  return field;
}

typedef unsigned int32 CellRef;

#define MAX_CELL_REFS 512

struct CellRefList {
  uniform int32 size; // size of list in this block
  uniform int32 total; // size of total list across all blocks
  uniform CellRef cellRef[MAX_CELL_REFS];
  uniform CellRefList *uniform next;
};

inline void append(uniform CellRefList &list, varying CellRef ref)
{
  foreach_active(lane) {
    if (list.size == MAX_CELL_REFS) {
      CellRefList *uniform newList = uniform new uniform CellRefList;
      newList->next = list.next;
      list.next = newList;

      foreach(i = 0 ... MAX_CELL_REFS)
        newList->cellRef[i] = list.cellRef[i];

      newList->size = list.size;
      list.size = 0;
    }
    uniform int uRef = extract(ref,lane);
    list.cellRef[list.size] = uRef; 
    list.size++;
    list.total++;
  }
}

inline void init(uniform CellRefList &list)
{ list.size = 0; list.total = 0; list.next = NULL;  }

struct BlockState {
  // cell ref list by number of triangles in cell
  CellRefList cellRefList[5];
};

void init(uniform BlockState &block)
{ for (uniform int i=0;i<5;i++) init(block.cellRefList[i]); }


inline vec3f makeRelativeVertex(const int vID)
{
  return make_vec3f(vID & 1 ? 1.f : 0.f,
                    vID & 2 ? 1.f : 0.f,
                    vID & 4 ? 1.f : 0.f);
}

inline vec3f makeInterpolatedVertex(const float isoval, const varying float vertexValue[8], const int id0, const int id1)
{
  const vec3f v0pos = makeRelativeVertex(id0);
  const vec3f v1pos = makeRelativeVertex(id1);
  const float v0val = vertexValue[id0];
  const float v1val = vertexValue[id1];
  const float w = (isoval - v0val) / (v1val-v0val);
  return lerp(w, v0pos, v1pos);
}

void doCellsForTriangleCount(const float isoValue,
                             Field *uniform field,
                             uniform BlockState &block,
                             const uniform int triCount)
{
  CellRefList *uniform list = &block.cellRefList[triCount];

  const uniform int dx = 1;
  const uniform int dy = field->size.x;
  const uniform int dz = field->size.y*dy;
  
  while (list) {
    foreach (cellRefID = 0 ... list->size) {
      CellRef ref = list->cellRef[cellRefID];
      const int iiz = ref & 255;
      const int iiy = (ref >> 8) & 255;
      const int iix = (ref >> 16) & 255;
      const int cellCase = (ref >> 24) & 255;

      const vec3f baseVertex = make_vec3f(iix,iiy,iiz);

      varying float vertexValue[8];
      foreach_unique(uz in iiz) {
        const float *uniform const voxel = (float *uniform)field->voxel + uz * dz;
        const int ofs0 = iix + dx * iiy;
        vertexValue[0] = (voxel        )[ofs0];
        vertexValue[1] = (voxel      +1)[ofs0];
        vertexValue[2] = (voxel   +dy  )[ofs0];
        vertexValue[3] = (voxel   +dy+1)[ofs0];
        vertexValue[4] = (voxel+dz     )[ofs0];
        vertexValue[5] = (voxel+dz   +1)[ofs0];
        vertexValue[6] = (voxel+dz+dy  )[ofs0];
        vertexValue[7] = (voxel+dz+dy+1)[ofs0];
      }
      
      uniform int edgeIDofs = 0;
      for (uniform int triID=0;triID<triCount;triID++) {
        // TODO: merge these into 8+8+8bit values in the table, then
        // it's a single gather. even better, merge the 3*2 vertex IDs
        // into 6+6+6 bits, and store this; thus also get rid of the
        // six 'edgeVerticesByEdgeID' indirections.
        const int edgeID0 = edgeIDbyCellCase[cellCase][edgeIDofs++];
        const int edgeID1 = edgeIDbyCellCase[cellCase][edgeIDofs++];
        const int edgeID2 = edgeIDbyCellCase[cellCase][edgeIDofs++];
        
        const int vertexID00 = edgeVerticesByEdgeID[edgeID0][0];
        const int vertexID01 = edgeVerticesByEdgeID[edgeID0][1];
        const vec3f vertex0 = baseVertex+makeInterpolatedVertex(isoValue,vertexValue,vertexID00,vertexID01);

        const int vertexID10 = edgeVerticesByEdgeID[edgeID1][0];
        const int vertexID11 = edgeVerticesByEdgeID[edgeID1][1];
        const vec3f vertex1 = baseVertex+makeInterpolatedVertex(isoValue,vertexValue,vertexID10,vertexID11);

        const int vertexID20 = edgeVerticesByEdgeID[edgeID2][0];
        const int vertexID21 = edgeVerticesByEdgeID[edgeID2][1];
        const vec3f vertex2 = baseVertex+makeInterpolatedVertex(isoValue,vertexValue,vertexID20,vertexID21);
      }
      
      
    }
    list = list->next;
  }
}
                             


task void mcTask(Field *uniform field, const float isoValue)
{
  uniform int blockID = taskIndex;
  uniform vec3i blockIdx = make_vec3i(blockID % field->blocks.x,
                                      (blockID / field->blocks.x) % field->blocks.y,
                                      (blockID / (field->blocks.x*field->blocks.y)));
  //  print("blockIdx % % %\n",blockIdx.x,blockIdx.y,blockIdx.z);

  uniform BlockState block;
  init(block);

  const uniform int dx = 1;
  const uniform int dy = field->size.x;
  const uniform int dz = field->size.y*dy;
  
  const uniform int x0 = blockIdx.x * BLOCK_SIZE;
  const uniform int y0 = blockIdx.y * BLOCK_SIZE;
  const uniform int z0 = blockIdx.z * BLOCK_SIZE;
  
  const uniform int x1 = min(x0+BLOCK_SIZE,field->size.x-1);
  const uniform int y1 = min(y0+BLOCK_SIZE,field->size.y-1);
  const uniform int z1 = min(z0+BLOCK_SIZE,field->size.z-1);
  
  const uniform blockSize_x = x1-x0;
  const uniform blockSize_y = y1-y0;
  const uniform blockSize_z = z1-z0;

  const uniform int64 offset64 = z0 * ((int64)dz) + y0 * dy + x0 * dx;
  const float *uniform voxel00 = field->voxel + offset64;

  uniform int numCellsFound = 0;
  for (uniform int iz=0;iz<blockSize_z;iz++)
    for (uniform int iy=0;iy<blockSize_y;iy++) 
      foreach(ix = 0 ... blockSize_x) {
        //        print("% % %\n",ix,iy,iz);
        const float *uniform voxel = voxel00 + iy * dy + iz * dz;

#if 1
        // WARNING: this is how kitware seems to be reading the
        // values, and even though I don't understand why it would
        // have 'y backwards' I'm not going to argue, and simply use
        // the same to make sure my addressing into their edge tables
        // is the same.
        const float v000 = (voxel        )[ix];
        const float v001 = (voxel      +1)[ix];
        const float v010 = (voxel   +dy+1)[ix];
        const float v011 = (voxel   +dy  )[ix];
        const float v100 = (voxel+dz     )[ix];
        const float v101 = (voxel+dz   +1)[ix];
        const float v110 = (voxel+dz+dy+1)[ix];
        const float v111 = (voxel+dz+dy  )[ix];
#else
        const float v000 = (voxel        )[ix];
        const float v001 = (voxel      +1)[ix];
        const float v010 = (voxel   +dy  )[ix];
        const float v011 = (voxel   +dy+1)[ix];
        const float v100 = (voxel+dz     )[ix];
        const float v101 = (voxel+dz   +1)[ix];
        const float v110 = (voxel+dz+dy  )[ix];
        const float v111 = (voxel+dz+dy+1)[ix];
#endif

        int cellCase = 0;
        if (v000 >= isoValue) cellCase |=   1;
        if (v001 >= isoValue) cellCase |=   2;
        if (v010 >= isoValue) cellCase |=   4;
        if (v011 >= isoValue) cellCase |=   8;
        if (v100 >= isoValue) cellCase |=  16;
        if (v101 >= isoValue) cellCase |=  32;
        if (v110 >= isoValue) cellCase |=  64;
        if (v111 >= isoValue) cellCase |= 128;
        if (cellCase == 0 || cellCase == 255) continue;

        int numTrianglesInCell = numberOfTrianglesByCellCase[cellCase];
        int cellRef 
          = (cellCase << 24)
          | (iz << 16)
          | (iy << 8)
          | iz;
        foreach_unique(numTris in numTrianglesInCell) {
          append(block.cellRefList[numTris],cellRef);
        }

        // print("% % % case %\n",ix,iy,iz,cellCase);
        numCellsFound += reduce_add(1);
      }

  // print("blockIdx % % %: found % cells, %:%:%:% tris\n",blockIdx.x,blockIdx.y,blockIdx.z,numCellsFound,
  //       block.cellRefList[1].total,
  //       block.cellRefList[2].total,
  //       block.cellRefList[3].total,
  //       block.cellRefList[4].total
  //       );

  for (uniform int triCountCase=1;triCountCase<5;triCountCase++)
    doCellsForTriangleCount(isoValue,field,block,triCountCase);
}

export void marchingCubes(void *uniform _field, uniform float isoValue)
{
  Field *uniform field = (Field *uniform)_field;
  field->blocks = make_vec3i((field->size.x+BLOCK_SIZE-2)/BLOCK_SIZE,
                             (field->size.y+BLOCK_SIZE-2)/BLOCK_SIZE,
                             (field->size.z+BLOCK_SIZE-2)/BLOCK_SIZE);
  
  uniform int numBlocks = field->blocks.x * field->blocks.y * field->blocks.z;
  launch[numBlocks] mcTask(field,isoValue);
}
