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

pub fn main() {
  let grid = create_grid(7, 5)
  display_grid(grid)

  let neighbors = get_neighbors(grid, 3, 3)
  io.debug(neighbors)
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

fn at(xs: List(a), idx: Int) -> Option(a) {
  case xs, idx {
    [], x if x < 0 -> None
    [], _ -> None
    [x, ..], 0 -> Some(x)
    [_, ..rest], idx -> at(rest, idx - 1)
  }
}
