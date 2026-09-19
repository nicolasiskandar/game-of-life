# Game of Life

An implementation of Conway's Game of Life in OCaml.

This repository contains a library and two executables. The library implements
the automaton twice, once over a dense array and once over a sparse set of live
cells, and supplies a parser for the run-length-encoded pattern format. The
executables provide a terminal animation and a graphical renderer. The purpose
of the project is pedagogical: it demonstrates a small, strictly modular OCaml
codebase in which pure functions are separated from effects and every module
declares its interface explicitly in an `.mli`.

---

## 1. Background

The Game of Life is a cellular automaton introduced by the mathematician John
Conway in 1970, popularized through Martin Gardner's column in *Scientific
American* [1]. It is a "zero-player game": its evolution is fully determined by
its initial configuration, given the transition rule of Section 2.

The automaton lives on a grid of cells, each of which is alive or dead. At each
generation every cell inspects the states of its eight neighbors, the Moore
neighborhood, and changes state according to a rule that depends only on the
number of live neighbors. Despite its simplicity, the rule is known to be
capable of universal computation, in the sense that configurations exist that
simulate a universal Turing machine.

A finite implementation must commit to a boundary policy. The present library
ships with two: the dense engine treats the grid as toroidal (cells on the
edges wrap around), and the sparse engine treats the plane as having no
boundary at all. Section 3 discusses the consequences.

---

## 2. The rules

Let the state of a cell be denoted by `s`, with value 1 for alive and 0 for
dead, and let `n` denote the number of live cells among its eight neighbors.
The state at the next generation is

```
s' = 1  if  s = 1 and n ∈ {2, 3}
s' = 1  if  s = 0 and n = 3
s' = 0  otherwise.
```

The rule is conventionally written as B3/S23: a dead cell is born when it has
exactly three live neighbors, and a live cell survives when it has two or
three. The four familiar cases follow.

1. Underpopulation. A live cell with `n < 2` dies.
2. Survival. A live cell with `n = 2` or `n = 3` lives.
3. Overpopulation. A live cell with `n > 3` dies.
4. Reproduction. A dead cell with `n = 3` becomes alive.

Both simulation engines derive their behavior from the single function
`Rules.next_state` in `lib/rules.ml`.

---

## 3. Implementation

The library is organized as a strict acyclic dependency graph.

| Module         | Depends on                        |
| -------------- | --------------------------------- |
| `Cell`         | none                              |
| `Boundary`     | none                              |
| `Moore`        | none                              |
| `Rle`          | none                              |
| `Grid`         | `Cell`                            |
| `Rules`        | `Cell`                            |
| `Neighborhood` | `Grid`, `Boundary`, `Moore`       |
| `Patterns`     | `Grid`                            |
| `Simulation`   | `Grid`, `Rules`, `Neighborhood`   |
| `Sparse`       | `Rules`, `Moore`                  |
| `Render`       | `Grid`                            |
| `Terminal`     | `Render`, `Simulation`            |
| `View`         | `Grid`, `Simulation`              |

The graph is acyclic. `Cell` supplies the type `Alive | Dead`. `Grid` provides
the dense representation together with `make_grid`, `index`, `get`, and `set`;
`Boundary` implements the wrapping used by the toroidal engine. `Moore` and
`Neighborhood` supply the shared eight-neighbor geometry and the live-neighbor
count, and `Rules` encodes Section 2. `Simulation` provides `step` and
`run_generations`. `Patterns` seeds a grid from an offset list and bundles the
glider, blinker, and block. `Rle` parses the pattern format of Section 3.4.
`Sparse` provides the set-based engine. `Render` maps a grid to a string and is
pure; `Terminal` and the graphical `View` animate it, and are the only modules
that perform I/O.

The design has three properties worth stating explicitly.

1. **Single responsibility.** Each module addresses one concern. The original
   `board` module was split into `Cell`, `Grid`, `Boundary`, `Moore`,
   `Neighborhood`, `Rules`, `Simulation`, and `Patterns`.
2. **Explicit interfaces.** Every module is accompanied by an `.mli` that
   names its public values and hides its internals.
3. **Purity at the center.** The modules of the library, with the single
   exception of `Terminal`, are pure functions of their inputs. Effects are
   confined to the leaves of the dependency graph.

### 3.1 The dense engine

The dense engine stores the cells of an H by W grid in a flat array of `H * W`
elements and updates every element in each generation, so the cost is
`O(H * W)` regardless of population. Because births can occur in the row below
a live cell, the engine reads from the previous generation and writes into a
fresh array. The boundary policy is toroidal: `Boundary.wrap` maps a shifted
index back into the range `[0, n)`.

### 3.2 The sparse engine

The sparse engine represents the configuration as a set of live cells. In each
generation it considers the live cells together with all of their neighbors,
since these are the only positions where the rule can change the state. The
cost is therefore `O(P)` where `P` is the number of live cells and their
neighbors, rather than `O(H * W)`.

The two engines agree exactly on configurations whose evolution never reaches
the boundary, where the toroidal and unwrapped interpretations coincide. The
test suite exploits this equivalence.

### 3.3 Rendering

`Render.render` produces a string from a grid and a pair of characters. It
performs no output; printing and the animation loop are the responsibility of
`Terminal`. The separation keeps the rendering function testable without
spawning a terminal.

### 3.4 The pattern format

Patterns are distributed in the run-length-encoded format. Each file is a
header line

```
x = <width>, y = <height>, rule = B3/S23
```

followed by the encoded body. The body is a sequence of runs terminated by `!`;
a run is an optional count followed by a tag, and the sequence is terminated by
`!`. The tags are the following.

| Tag  | Meaning        |
| ---- | -------------- |
| `o`  | live cell(s)   |
| `b`  | dead cell(s)   |
| `$`  | end of row     |
| `!`  | end of pattern |

A run without a count has length 1. For example, `3o!` places three live cells
in a row, and `bob$2bo$3o!` encodes a glider. The function `Rle.parse_rle_body`
returns the pattern as a list of offsets relative to the origin.

---

## 4. Usage

### 4.1 Prerequisites

An opam switch with OCaml at least 4.14 and dune at least 3.0.

```
opam install graphics ounit2
```

### 4.2 Build and test

```
dune build
dune test
```

`dune build` compiles the library and both executables. `dune test` runs the
suites described in Section 5.

### 4.3 Terminal frontend

```
dune exec bin/main.exe [options]
```

The accepted options are the following.

| Option            | Default | Meaning                        |
| ----------------- | ------- | ------------------------------ |
| `--width`         | 20      | Grid width in columns          |
| `--height`        | 10      | Grid height in rows            |
| `--generations`   | 100     | Number of generations to run   |
| `--pattern`       | none    | Path to a pattern file in RLE  |

With no `--pattern`, the program seeds a glider near the top-left corner.
Examples:

```
dune exec bin/main.exe
dune exec bin/main.exe -- --width 40 --height 20 --generations 200
dune exec bin/main.exe -- --pattern patterns/blinker.rle
```

### 4.4 Graphical frontend

```
dune exec bin_gui/main_gui.exe
```

This opens a 40 by 30 window and animates a glider through 300 generations.
It requires a display and the X11 libraries.

### 4.5 Bundled patterns

The directory `patterns/` contains three files.

| File             | Pattern  | Behavior                            |
| ---------------- | -------- | ----------------------------------- |
| `glider.rle`     | Glider   | Translates one cell diagonally over four generations |
| `blinker.rle`    | Blinker  | A 2-cycle vertical and horizontal oscillator |
| `block.rle`      | Block    | An immobile still life.             |

Any valid RLE file can be loaded with `--pattern`.

---

## 5. Testing

The test suite is split into one file per module under `test/`.

| Suite        | Cases | Coverage                                             |
| ------------ | ----- | ---------------------------------------------------- |
| `grid`       | 3     | Dimensions, initial state, set/get roundtrip         |
| `rules`      | 5     | Each of the four rules over all neighbor counts      |
| `simulation` | 4     | Blinker cycle, block fixpoint, wraparound, `run_generations` |
| `rle`        | 3     | Parsing of glider, blinker, and block bodies         |
| `sparse`     | 2     | Sparse and dense engines agree on block and glider   |

There are 17 tests in total. The `sparse` suite is the most consequential:
it asserts the property of Section 3.2, that the two engines compute the same
successor on configurations that stay away from the boundary.

---

## 6. Project layout

```
.
├── dune-project               package metadata; generates game_of_life.opam
├── lib/                       the library
│   ├── cell.ml/.mli           the state type Alive | Dead
│   ├── grid.ml/.mli           dense grid: index, make_grid, get, set
│   ├── boundary.ml/.mli       toroidal wrap
│   ├── moore.ml/.mli          eight-neighbor offsets
│   ├── neighborhood.ml/.mli   live-neighbor counting
│   ├── rules.ml/.mli          the transition rule of Section 2
│   ├── simulation.ml/.mli     step, run_generations
│   ├── patterns.ml/.mli       seeding and the bundled patterns
│   ├── rle.ml/.mli            pattern parser and file loader
│   ├── sparse.ml/.mli         the set-based engine
│   ├── render.ml/.mli         pure grid-to-string rendering
│   └── terminal.ml/.mli       terminal clearing and animation
├── bin/                       the terminal executable (cli.ml/.mli, main.ml)
├── bin_gui/                   the graphical executable (view.ml/.mli, main_gui.ml)
├── test/                      one suite per module (17 tests)
└── patterns/                  bundled RLE files (glider, blinker, block)
```

---

## 7. References

[1] M. Gardner, "Mathematical Games," *Scientific American* 223, no. 4
(October 1970). The column that introduced the Game of Life to a wide audience.

[2] "Conway's Game of Life," Wikipedia. Accessed 2026.
https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
