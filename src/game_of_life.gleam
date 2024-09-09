import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

pub type Cell {
  Dead
  Alive
}

pub type Grid =
  List(List(Cell))

@external(erlang, "timer", "sleep")
fn wait(milis: Int) -> Nil

pub fn main() {
  run_game(5, 4, 10)
}

pub fn create_grid(width: Int, height: Int) -> Grid {
  use _ <- list.map(list.range(1, height))
  use _ <- list.map(list.range(1, width))
  random_cell_state()
}

fn random_cell_state() -> Cell {
  case int.random(2) {
    0 -> Dead
    _ -> Alive
  }
}

fn display_grid(grid: Grid) {
  use row <- list.each(grid)
  let formated =
    list.map(row, fn(cell) {
      case cell {
        Alive -> "*"
        Dead -> "-"
      }
    })

  io.print("| ")
  list.each(formated, fn(cell) { io.print(cell <> " ") })
  io.println("|")
}

fn get_neighbors(grid: Grid, x: Int, y: Int) -> List(Cell) {
  let directions = [
    #(1, 0),
    #(1, 1),
    #(0, 1),
    #(-1, 1),
    #(-1, 0),
    #(-1, -1),
    #(0, -1),
    #(1, -1),
  ]

  list.map(directions, fn(dir) { get_cell(grid, x + dir.0, y + dir.1) })
}

fn get_cell(grid: Grid, row: Int, collumn: Int) -> Cell {
  case at(grid, row) {
    Some(cell_row) -> {
      case at(cell_row, collumn) {
        Some(x) -> x
        None -> Dead
      }
    }
    None -> Dead
  }
}

fn next_cell_state(cell: Cell, alive_neighbors: Int) -> Cell {
  case cell, alive_neighbors {
    Alive, 2 -> Dead
    Alive, 3 -> Dead
    Alive, _ -> Alive
    Dead, 3 -> Alive
    Dead, _ -> Dead
  }
}

fn update_grid(grid: Grid) -> Grid {
  use row, x <- list.index_map(grid)
  use cell, y <- list.index_map(row)

  let alive_neighbors =
    get_neighbors(grid, x, y)
    |> list.map(fn(c) { c == Alive })
    |> list.length()

  next_cell_state(cell, alive_neighbors)
}

fn run_game(width: Int, height: Int, generations: Int) {
  let grid = create_grid(width, height)
  loop(grid, generations)
}

fn loop(grid: Grid, generation: Int) {
  case generation {
    0 -> Nil
    _ -> {
      let new_grid = update_grid(grid)
      display_grid(grid)
      io.println("")
      wait(500)
      loop(new_grid, generation - 1)
    }
  }
}

// fn all_cells_died(grid: Grid) -> Bool {
//  use row <- list.all(grid)
//  list.all(row, fn(cell) { cell == Dead })
//}

fn at(xs: List(a), idx: Int) -> Option(a) {
  case xs, idx {
    [], x if x < 0 -> None
    [], _ -> None
    [x, ..], 0 -> Some(x)
    [_, ..rest], idx -> at(rest, idx - 1)
  }
}
