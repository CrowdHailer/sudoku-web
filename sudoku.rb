require 'rubygems'
require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions

configure :production do
  require 'newrelic_rpm'
end

def random_sudoku
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    sudoku.solve!
    sudoku.to_s.split("")
end

def puzzle(sudoku)
    (0..81).to_a.sample(12).each {|i| sudoku[i] = ""}
    sudoku
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) {|memo, i|
    first_box_index = i / 3 * 3
    three_boxes = boxes[first_box_index, 3]
    three_rows_of_three = three_boxes.map do |box| d
      row_number_in_a_box = i % 3
      first_cell_in_the_row_index = row_number_in_a_box * 3
      box[first_cell_in_the_row_index, 3]
    end
    memo += three_rows_of_three.flatten
  }
end

get '/' do
  sudoku = random_sudoku
  session[:solution] = sudoku
  if session[:current_solution]
    @current_solution = session[:current_solution].chars.map { |e| e == 0 ? "" : e.to_s } 
  else
    @current_solution = puzzle(sudoku.dup)
  end
  erb :index
end

get '/solution' do
    @current_solution = session[:solution]
    erb :index
end

post '/' do
  cells = params["cell"]
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end
